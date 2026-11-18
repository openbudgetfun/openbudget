import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/entities/entity_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/tax/tax_endpoint.dart';
import 'package:openbudget_server/src/tax/tax_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';
import '../support/tax_fake_pack.dart';
import '../support/tax_test_book.dart';

DateTime d(int year, int month, int day) => DateTime.utc(year, month, day);

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
  });

  group('when listing the deadlines of a UK individual', () {
    setUp(() => saveTaxProfile(book.session, book.entity));

    test('then only dates from today to a year ahead come back, soonest '
        'first', () async {
      final deadlines = await endpoint.listDeadlines(
        book.session,
        book.entity.id!,
      );

      expect(deadlines, isNotEmpty);
      for (var index = 0; index < deadlines.length; index++) {
        final deadline = deadlines[index];
        expect(
          deadline.dueDate.isBefore(d(2026, 11, 11)),
          isFalse,
          reason: '${deadline.id} is not in the past',
        );
        expect(
          deadline.dueDate.isAfter(d(2027, 11, 12)),
          isFalse,
          reason: '${deadline.id} is within a year',
        );
        if (index > 0) {
          expect(
            deadlines[index - 1].dueDate.isAfter(deadline.dueDate),
            isFalse,
          );
        }
      }
    });

    test('then each deadline carries its date, days left and source', () async {
      final deadlines = await endpoint.listDeadlines(
        book.session,
        book.entity.id!,
      );
      final onlineReturn = deadlines.firstWhere(
        (deadline) => deadline.id == 'gb.sa.online-return',
      );

      expect(onlineReturn.dueDate, d(2027, 1, 31));
      expect(onlineReturn.daysLeft, 81);
      expect(onlineReturn.kind, 'filing');
      expect(onlineReturn.periodLabel, '2025/26');
      expect(onlineReturn.grade, 'primary');
      expect(onlineReturn.dependsOnProfile, isFalse);
      expect(onlineReturn.source, startsWith('https://www.gov.uk/'));
      expect(onlineReturn.citation, isNotEmpty);
      expect(
        deadlines.any((deadline) => deadline.id == 'gb.sa.balancing-payment'),
        isTrue,
      );
    });

    test('then a date that has passed is left out', () async {
      final deadlines = await endpoint.listDeadlines(
        book.session,
        book.entity.id!,
      );

      // The 2025/26 notice and paper dates fell in October 2026; the 2026/27
      // ones come a year later.
      final notices = deadlines.where(
        (deadline) =>
            deadline.id == 'gb.sa.notify' ||
            deadline.id == 'gb.sa.paper-return',
      );
      expect(notices.map((deadline) => deadline.periodLabel).toSet(), {
        '2026/27',
      });
    });
  });

  group('when the profile decides the dates', () {
    test('then a December year end moves the Corporation Tax return', () async {
      final company = await book.addEntity(
        name: 'December company',
        kind: EntityKind.company,
        fiscalYearEndMonth: 12,
        fiscalYearEndDay: 31,
      );
      await saveTaxProfile(book.session, company);

      final deadlines = await endpoint.listDeadlines(
        book.session,
        company.id!,
      );
      final corporationTaxReturn = deadlines.firstWhere(
        (deadline) => deadline.id == 'gb.ct.return',
      );

      expect(corporationTaxReturn.dueDate, d(2026, 12, 31));
      expect(corporationTaxReturn.periodLabel, 'year to 31 December 2025');
      expect(corporationTaxReturn.dependsOnProfile, isTrue);
    });

    test(
      'then an entity with no saved profile gets the default dates',
      () async {
        final company = await book.addEntity(
          name: 'No profile yet',
          kind: EntityKind.company,
          fiscalYearEndMonth: 3,
          fiscalYearEndDay: 31,
        );

        final deadlines = await endpoint.listDeadlines(
          book.session,
          company.id!,
        );
        final corporationTaxReturn = deadlines.firstWhere(
          (deadline) => deadline.id == 'gb.ct.return',
        );

        expect(corporationTaxReturn.dueDate, d(2027, 3, 31));
        expect(corporationTaxReturn.dependsOnProfile, isTrue);
      },
    );
  });

  group('when a fake pack fixes the dates', () {
    setUp(() async {
      TaxService.packFor = (_) => FakeTaxPack();
      await saveTaxProfile(book.session, book.entity);
    });

    test(
      'then each supported year contributes the dates inside the window',
      () async {
        final deadlines = await endpoint.listDeadlines(
          book.session,
          book.entity.id!,
        );

        expect(
          [
            for (final deadline in deadlines)
              '${deadline.id} ${deadline.dueDate}',
          ],
          [
            'gb.test.amend ${d(2027, 1, 31)}',
            'gb.test.return ${d(2027, 1, 31)}',
          ],
          reason:
              '2025 amends and 2026 returns in January 2027; 2028 is beyond a '
              'year',
        );
      },
    );

    test('then a date due today is included with zero days left', () async {
      TaxService.clock = () => DateTime.utc(2027, 1, 31, 9);

      final deadlines = await endpoint.listDeadlines(
        book.session,
        book.entity.id!,
      );

      expect(deadlines.first.dueDate, d(2027, 1, 31));
      expect(deadlines.first.daysLeft, 0);
    });

    test('then a date due yesterday is left out', () async {
      TaxService.clock = () => DateTime.utc(2027, 2, 1, 9);

      final deadlines = await endpoint.listDeadlines(
        book.session,
        book.entity.id!,
      );

      expect(
        deadlines.any((deadline) => deadline.dueDate == d(2027, 1, 31)),
        isFalse,
      );
    });

    test('then a pack that knows no years gives an empty list', () async {
      TaxService.packFor = (_) => FakeTaxPack(supportedStartYears: const {});

      expect(
        await endpoint.listDeadlines(book.session, book.entity.id!),
        isEmpty,
      );
    });
  });

  group('when the entity has no rule pack', () {
    test('then a Kenyan entity gets an empty list, not an error', () async {
      final kenya = await EntityService.create(
        book.session,
        'Nairobi books',
        EntityKind.individual,
        'KE',
        'KES',
        'Africa/Nairobi',
      );

      expect(await endpoint.listDeadlines(book.session, kenya.id!), isEmpty);
    });
  });

  group('ownership', () {
    test("then another user's entity is forbidden", () async {
      final other = await BudgetTestBook.create(server.anonymousSession());
      await saveTaxProfile(other.session, other.entity);

      await expectLater(
        endpoint.listDeadlines(book.session, other.entity.id!),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('then an unknown entity is not found', () async {
      await expectLater(
        endpoint.listDeadlines(book.session, const Uuid().v7obj()),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('then an anonymous session is rejected', () async {
      await expectLater(
        endpoint.listDeadlines(server.anonymousSession(), book.entity.id!),
        throwsA(isA<AuthenticationRequiredException>()),
      );
    });
  });
}
