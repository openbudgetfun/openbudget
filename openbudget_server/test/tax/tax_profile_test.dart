import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/tax/tax_endpoint.dart';
import 'package:openbudget_server/src/tax/tax_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';
import '../support/tax_test_book.dart';

void main() {
  late PgTestServer server;
  late BudgetTestBook book;
  late TaxEndpoint endpoint;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    FxService.configure(
      apiKey: null,
      baseUrl: null,
      backfillScheduler: (_, _) async {},
    );
    EntityRealtimeNotifier.debugPublisher = (
      _,
      _,
      _, {
      month,
      accountId,
    }) async {};
    TaxService.packFor = TaxRules.forJurisdiction;
    TaxService.clock = () => DateTime.utc(2026, 11, 11);
    book = await BudgetTestBook.create(server.anonymousSession());
    endpoint = TaxEndpoint();
  });

  tearDown(() {
    TaxService.packFor = TaxRules.forJurisdiction;
    TaxService.clock = () => DateTime.now().toUtc();
    EntityRealtimeNotifier.resetForTests();
    FxService.resetForTests();
  });

  Future<TaxProfileRecord?> getProfile(Entity entity) =>
      endpoint.getProfile(book.session, entity.id!);

  Future<int> profileCount(Entity entity) => TaxProfileRecord.db.count(
    book.session,
    where: (t) => t.entityId.equals(entity.id),
  );

  test('the endpoint requires login', () {
    expect(endpoint.requireLogin, isTrue);
  });

  group('when authenticating', () {
    test('then an unauthenticated caller is rejected', () async {
      final anonymous = server.anonymousSession();

      await expectLater(
        endpoint.getProfile(anonymous, book.entity.id!),
        throwsA(isA<AuthenticationRequiredException>()),
      );
      await expectLater(
        endpoint.saveProfile(
          anonymous,
          book.entity.id!,
          'GB',
          EntityKind.individual.name,
          gbProfileJson(EntityKind.individual),
        ),
        throwsA(isA<AuthenticationRequiredException>()),
      );
    });

    test('then another user cannot read or write any tax data', () async {
      final other = await BudgetTestBook.create(server.anonymousSession());
      final otherEnvelope = await other.addEnvelope();
      final otherAccount = await other.addAccount();
      final otherTransaction = await createTaxTransaction(
        other.session,
        otherAccount,
      );

      await expectLater(
        endpoint.getProfile(book.session, other.entity.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.saveProfile(
          book.session,
          other.entity.id!,
          'GB',
          EntityKind.individual.name,
          gbProfileJson(EntityKind.individual),
        ),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.listCategories(book.session, other.entity.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.getReport(book.session, other.entity.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.setEnvelopeTaxCategory(
          book.session,
          otherEnvelope.id!,
          code: 'gb.ind.employment',
        ),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.setLineTax(
          book.session,
          taxLine(otherTransaction).id!,
          taxCategoryCode: 'gb.ind.employment',
        ),
        throwsA(isA<ForbiddenException>()),
      );
    });
  });

  group('when no profile exists', () {
    test('then getProfile returns null', () async {
      expect(await getProfile(book.entity), isNull);
    });

    test('then listCategories and getReport require a profile', () async {
      await expectLater(
        endpoint.listCategories(book.session, book.entity.id!),
        throwsA(isA<NotFoundException>()),
      );
      await expectLater(
        endpoint.getReport(book.session, book.entity.id!),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('when saving a profile', () {
    test('then the profile round-trips through getProfile', () async {
      final saved = await saveTaxProfile(book.session, book.entity);
      final loaded = await getProfile(book.entity);

      expect(loaded?.id, saved.id);
      expect(loaded?.profileJson, saved.profileJson);
      expect(
        jsonDecode(saved.profileJson),
        containsPair('jurisdiction', 'GB'),
      );
      expect(
        jsonDecode(saved.profileJson),
        containsPair('entityKind', 'individual'),
      );
    });

    test('then a forged identity is rewritten from the entity', () async {
      final saved = await saveTaxProfile(
        book.session,
        book.entity,
        profileJson: jsonEncode({
          'jurisdiction': 'US',
          'entityKind': 'company',
          'scottishTaxpayer': true,
          'notAField': 'dropped',
        }),
      );

      final stored = jsonDecode(saved.profileJson) as Map<String, Object?>;
      expect(stored['jurisdiction'], 'GB');
      expect(stored['entityKind'], 'individual');
      expect(stored['scottishTaxpayer'], isTrue);
      expect(stored, isNot(contains('notAField')));
      expect(stored['accountingPeriodEndMonth'], 4);
      expect(stored['accountingPeriodEndDay'], 5);
    });

    test('then jurisdiction and kind parameters cannot disagree', () async {
      await expectLater(
        saveTaxProfile(
          book.session,
          book.entity,
          jurisdiction: 'US',
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        saveTaxProfile(
          book.session,
          book.entity,
          entityKind: 'company',
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        saveTaxProfile(
          book.session,
          book.entity,
          entityKind: 'partnership',
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(await profileCount(book.entity), 0);
    });

    test('then an unsupported entity country has no fallback', () async {
      final unsupported = await book.addEntity(
        name: 'Elsewhere',
        countryCode: 'ZZ',
      );

      await expectLater(
        endpoint.saveProfile(
          book.session,
          unsupported.id!,
          'ZZ',
          EntityKind.individual.name,
          gbProfileJson(EntityKind.individual),
        ),
        throwsA(
          isA<ValidationException>().having(
            (error) => error.message,
            'message',
            contains('No tax rules are available for ZZ'),
          ),
        ),
      );
      await expectLater(
        endpoint.getProfile(book.session, unsupported.id!),
        throwsA(isA<ValidationException>()),
      );
    });

    test('then malformed JSON rejects without storing a default', () async {
      await expectLater(
        saveTaxProfile(
          book.session,
          book.entity,
          profileJson: '{not-json',
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        saveTaxProfile(
          book.session,
          book.entity,
          profileJson: '[]',
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(await profileCount(book.entity), 0);
    });

    test(
      'then a malformed stored profile fails instead of defaulting',
      () async {
        await saveTaxProfile(book.session, book.entity);
        await book.session.db.unsafeExecute(
          'UPDATE tax_profile SET "profileJson" = @json '
          'WHERE "entityId" = @entityId::uuid',
          parameters: QueryParameters.named({
            'json': '{broken',
            'entityId': book.entity.id!.toString(),
          }),
        );

        await expectLater(
          getProfile(book.entity),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test(
      'then a fiscal year change rewrites the stored profile on read',
      () async {
        final company = await book.addEntity(
          name: 'Company',
          kind: EntityKind.company,
          fiscalYearEndMonth: 3,
          fiscalYearEndDay: 31,
        );
        await saveTaxProfile(
          book.session,
          company,
          profileJson: jsonEncode({
            'jurisdiction': 'GB',
            'entityKind': 'company',
            'accountingPeriodEndMonth': 12,
            'accountingPeriodEndDay': 12,
          }),
        );

        await book.session.db.unsafeExecute(
          'UPDATE "entity" SET "fiscalYearEndMonth" = 6, '
          '"fiscalYearEndDay" = 30 WHERE id = @id::uuid',
          parameters: QueryParameters.named({'id': company.id!.toString()}),
        );

        final loaded = await getProfile(company);
        final stored = jsonDecode(loaded!.profileJson);
        expect((stored as Map<String, Object?>)['accountingPeriodEndMonth'], 6);
        expect(stored['accountingPeriodEndDay'], 30);
      },
    );

    test('then a country and kind change rewrites identity on read', () async {
      await saveTaxProfile(
        book.session,
        book.entity,
        profileJson: jsonEncode({
          'jurisdiction': 'GB',
          'entityKind': 'individual',
          'scottishTaxpayer': true,
          'salesTaxRegistered': true,
        }),
      );

      await book.session.db.unsafeExecute(
        'UPDATE "entity" SET "countryCode" = \'US\', "kind" = \'company\' '
        'WHERE id = @id::uuid',
        parameters: QueryParameters.named({'id': book.entity.id!.toString()}),
      );

      final loaded = await getProfile(book.entity);
      final stored = jsonDecode(loaded!.profileJson) as Map<String, Object?>;
      expect(stored['jurisdiction'], 'US');
      expect(stored['entityKind'], 'company');
      expect(stored['salesTaxRegistered'], isTrue);
      expect(stored, isNot(contains('scottishTaxpayer')));
      expect(TaxProfile.fromJson(stored), isA<UsTaxProfile>());
    });

    test('then the updated time moves on every save', () async {
      var now = DateTime.utc(2026, 11, 11, 9);
      TaxService.clock = () => now;
      final first = await saveTaxProfile(book.session, book.entity);
      now = now.add(const Duration(minutes: 5));
      final second = await saveTaxProfile(book.session, book.entity);

      expect(second.updatedAt.isAfter(first.updatedAt), isTrue);
      expect(second.createdAt, first.createdAt);
    });

    test('then concurrent saves leave exactly one row', () async {
      await Future.wait([
        for (var index = 0; index < 12; index++)
          saveTaxProfile(
            book.session,
            book.entity,
            profileJson: gbProfileJson(
              EntityKind.individual,
              scottishTaxpayer: index.isEven,
            ),
          ),
      ]);

      expect(await profileCount(book.entity), 1);
      expect(await getProfile(book.entity), isNotNull);
    });

    test('then the change event fires only after the row is visible', () async {
      var events = 0;
      String? visibleProfile;
      EntityRealtimeNotifier.debugPublisher =
          (session, entityId, scope, {month, accountId}) async {
            events++;
            final row = await TaxProfileRecord.db.findFirstRow(
              session,
              where: (t) => t.entityId.equals(entityId),
            );
            visibleProfile = row?.profileJson;
          };

      final saved = await saveTaxProfile(book.session, book.entity);

      expect(events, 1);
      expect(visibleProfile, saved.profileJson);
    });

    test('then a rejected save publishes no event', () async {
      var events = 0;
      EntityRealtimeNotifier.debugPublisher =
          (_, _, _, {month, accountId}) async {
            events++;
          };

      await expectLater(
        saveTaxProfile(
          book.session,
          book.entity,
          jurisdiction: 'US',
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(events, 0);
    });
  });

  group('when the entity is archived', () {
    test('then saving a profile is rejected', () async {
      await book.session.db.unsafeExecute(
        'UPDATE "entity" SET "archivedAt" = now() WHERE id = @id::uuid',
        parameters: QueryParameters.named({'id': book.entity.id!.toString()}),
      );

      await expectLater(
        saveTaxProfile(book.session, book.entity),
        throwsA(isA<ValidationException>()),
      );
      expect(await profileCount(book.entity), 0);
    });
  });

  group('when listing categories', () {
    test('then only the entity kind categories are returned', () async {
      final company = await book.addEntity(
        name: 'Company',
        kind: EntityKind.company,
      );
      await saveTaxProfile(book.session, book.entity);
      await saveTaxProfile(
        book.session,
        company,
        profileJson: gbProfileJson(EntityKind.company),
      );

      final personal = await endpoint.listCategories(
        book.session,
        book.entity.id!,
      );
      final business = await endpoint.listCategories(
        book.session,
        company.id!,
      );

      expect(
        personal.map((category) => category.code),
        contains('gb.ind.employment'),
      );
      expect(
        personal.map((category) => category.code),
        isNot(contains('gb.co.turnover')),
      );
      expect(
        business.map((category) => category.code),
        contains('gb.co.turnover'),
      );
      expect(
        business.map((category) => category.code),
        isNot(contains('gb.ind.employment')),
      );
    });
  });

  group('when setting an envelope default', () {
    test('then an unknown or foreign-kind code rejects', () async {
      await saveTaxProfile(book.session, book.entity);
      final envelope = await book.addEnvelope();

      await expectLater(
        endpoint.setEnvelopeTaxCategory(
          book.session,
          envelope.id!,
          code: 'gb.unknown',
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.setEnvelopeTaxCategory(
          book.session,
          envelope.id!,
          code: 'gb.co.turnover',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('then an archived entity rejects the default', () async {
      await saveTaxProfile(book.session, book.entity);
      final envelope = await book.addEnvelope();
      await book.session.db.unsafeExecute(
        'UPDATE "entity" SET "archivedAt" = now() WHERE id = @id::uuid',
        parameters: QueryParameters.named({'id': book.entity.id!.toString()}),
      );

      await expectLater(
        endpoint.setEnvelopeTaxCategory(
          book.session,
          envelope.id!,
          code: 'gb.ind.employment',
        ),
        throwsA(isA<ValidationException>()),
      );
      final stored = await Envelope.db.findById(book.session, envelope.id!);
      expect(stored?.taxCategoryCode, isNull);
    });
  });

  group('when linking a personal entity', () {
    test('then an individual cannot link one', () async {
      final linked = await book.addEntity(name: 'Other personal');
      final individual = await book.addEntity(
        name: 'Individual with link',
        linkedPersonalEntityId: linked.id,
      );

      await expectLater(
        saveTaxProfile(book.session, individual),
        throwsA(isA<ValidationException>()),
      );
    });

    test('then a sole trader must link an individual', () async {
      final company = await book.addEntity(
        name: 'Company',
        kind: EntityKind.company,
      );
      final business = await book.addEntity(
        name: 'Business',
        kind: EntityKind.soleTrader,
        linkedPersonalEntityId: company.id,
      );

      await expectLater(
        saveTaxProfile(book.session, business),
        throwsA(isA<ValidationException>()),
      );
    });

    test('then a sole trader must link the same country', () async {
      final personal = await book.addEntity(
        name: 'US personal',
        countryCode: 'US',
        baseCurrencyCode: 'USD',
      );
      final business = await book.addEntity(
        name: 'Business',
        kind: EntityKind.soleTrader,
        linkedPersonalEntityId: personal.id,
      );

      await expectLater(
        saveTaxProfile(book.session, business),
        throwsA(isA<ValidationException>()),
      );
    });

    test("then another owner's personal entity is rejected", () async {
      final other = await BudgetTestBook.create(server.anonymousSession());
      final business = await book.addEntity(
        name: 'Business',
        kind: EntityKind.soleTrader,
        linkedPersonalEntityId: other.entity.id,
      );

      await expectLater(
        saveTaxProfile(book.session, business),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('then an owned individual in the same country is accepted', () async {
      final business = await book.addEntity(
        name: 'Business',
        kind: EntityKind.soleTrader,
        linkedPersonalEntityId: book.entity.id,
      );

      final saved = await saveTaxProfile(book.session, business);

      expect(saved.entityId, business.id);
      expect(
        jsonDecode(saved.profileJson),
        containsPair('entityKind', 'soleTrader'),
      );
    });
  });

  group('when round-tripping other jurisdictions', () {
    test('then a US profile keeps its fields', () async {
      final entity = await book.addEntity(
        name: 'US family',
        countryCode: 'US',
        baseCurrencyCode: 'USD',
      );
      const profile = UsTaxProfile(
        entityKind: EntityKind.individual,
        filingStatus: UsFilingStatus.qualifyingSurvivingSpouse,
        homeOfficeMethod: UsHomeOfficeMethod.regular,
        specifiedServiceTrade: true,
        foreignEarnedIncomeExclusionMinor: 500000,
        taxpayer65OrOlder: true,
        spouse65OrOlder: true,
        dependents: [
          UsDependent(underSeventeen: true, hasValidSsn: true),
          UsDependent(underSeventeen: false, hasValidSsn: false),
        ],
      );

      final saved = await endpoint.saveProfile(
        book.session,
        entity.id!,
        'US',
        EntityKind.individual.name,
        jsonEncode(profile.toJson()),
      );
      final roundTripped = TaxProfile.fromJson(
        jsonDecode(saved.profileJson) as Map<String, Object?>,
      ) as UsTaxProfile;

      expect(
        roundTripped.filingStatus,
        UsFilingStatus.qualifyingSurvivingSpouse,
      );
      expect(roundTripped.homeOfficeMethod, UsHomeOfficeMethod.regular);
      expect(roundTripped.specifiedServiceTrade, isTrue);
      expect(roundTripped.foreignEarnedIncomeExclusionMinor, 500000);
      expect(roundTripped.dependents, hasLength(2));
      expect(roundTripped.dependents.first.hasValidSsn, isTrue);
      expect(roundTripped.dependents.last.hasValidSsn, isFalse);
    });

    test('then a Nigerian profile keeps its fields', () async {
      final entity = await book.addEntity(
        name: 'Lagos Ltd',
        countryCode: 'NG',
        baseCurrencyCode: 'NGN',
        kind: EntityKind.company,
      );
      const profile = NgTaxProfile(
        entityKind: EntityKind.company,
        smallCompanyCeiling: NgSmallCompanyCeiling.ntaaIntended,
        mneGroupMember: true,
      );

      final saved = await saveTaxProfile(
        book.session,
        entity,
        profileJson: jsonEncode(profile.toJson()),
      );
      final roundTripped = TaxProfile.fromJson(
        jsonDecode(saved.profileJson) as Map<String, Object?>,
      ) as NgTaxProfile;

      expect(
        roundTripped.smallCompanyCeiling,
        NgSmallCompanyCeiling.ntaaIntended,
      );
      expect(roundTripped.mneGroupMember, isTrue);
    });

    test('then a German profile keeps its fields', () async {
      final entity = await book.addEntity(
        name: 'Freelance',
        countryCode: 'DE',
        baseCurrencyCode: 'EUR',
        kind: EntityKind.soleTrader,
      );
      const profile = DeTaxProfile(
        entityKind: EntityKind.soleTrader,
        churchTax: true,
        churchTaxState: DeBundesland.bayern,
        einkunftsArt: DeEinkunftsArt.freiberuflich,
        children: 2,
        statutoryPensionMinor: 600000,
        previousYearTurnoverMinor: 2000000,
        commuteKmOneWay: 18,
        commuteDays: 210,
      );

      final saved = await saveTaxProfile(
        book.session,
        entity,
        profileJson: jsonEncode(profile.toJson()),
      );

      expect(
        TaxProfile.fromJson(
          jsonDecode(saved.profileJson) as Map<String, Object?>,
        ).toJson(),
        profile.toJson(),
      );
    });
  });
}
