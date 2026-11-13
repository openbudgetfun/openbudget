import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/entities/entity_service.dart';
import 'package:openbudget_server/src/envelopes/envelope_service.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/tax/tax_endpoint.dart';
import 'package:openbudget_server/src/tax/tax_service.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';
import '../support/tax_test_book.dart';

TaxReportLineView? _lineWith(TaxReportView report, String code) {
  for (final line in report.lines) {
    if (line.code == code) return line;
  }
  return null;
}

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
    TransactionWriter.resetForTests();
    TaxService.packFor = TaxRules.forJurisdiction;
    TaxService.clock = () => DateTime.now().toUtc();
    EntityRealtimeNotifier.resetForTests();
    FxService.resetForTests();
  });

  group('when a Kenyan individual tags universal codes', () {
    late Entity kenya;

    setUp(() async {
      // The real creation path, not a direct row insert: entity creation
      // must accept a country with no rule pack.
      kenya = await EntityService.create(
        book.session,
        'Nairobi books',
        EntityKind.individual,
        'KE',
        'KES',
        'Africa/Nairobi',
      );
    });

    test('then the entity is created with Kenyan defaults', () {
      expect(kenya.countryCode, 'KE');
      expect(kenya.baseCurrencyCode, 'KES');
      expect(kenya.fiscalYearEndMonth, 12);
      expect(kenya.fiscalYearEndDay, 31);
    });

    test('then transaction lines accept universal codes', () async {
      final account = await book.addAccount(entity: kenya);
      final view = await createTaxTransaction(
        book.session,
        account,
        amountMinor: 250000,
        lines: [
          TransactionLineInput(
            amountMinor: 250000,
            taxCategoryCode: 'universal.income.employment',
          ),
        ],
      );

      expect(taxLine(view).taxCategoryCode, 'universal.income.employment');
    });

    test('then envelopes accept a universal default category', () async {
      final envelope = await book.addEnvelope(entity: kenya);
      final updated = await EnvelopeService.update(
        book.session,
        envelopeId: envelope.id!,
        taxCategoryCode: 'universal.income.other',
      );

      expect(updated.taxCategoryCode, 'universal.income.other');
    });

    test('then the category list is the universal catalogue', () async {
      final categories = await TaxService.listCategories(
        book.session,
        entityId: kenya.id!,
      );

      final codes = categories.map((category) => category.code).toList();
      final expected = UniversalTaxCategories.categoriesFor(
        EntityKind.individual,
      ).map((category) => category.code);
      expect(codes, expected);
      expect(codes, contains('universal.income.employment'));
      expect(codes, isNot(contains('gb.ind.employment')));
    });

    test('then a universal code outside individual books rejects', () async {
      final account = await book.addAccount(entity: kenya);

      await expectLater(
        createTaxTransaction(
          book.session,
          account,
          lines: [
            TransactionLineInput(
              amountMinor: 5000,
              taxCategoryCode: 'universal.expense.software',
            ),
          ],
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('then an unknown universal code rejects', () async {
      final account = await book.addAccount(entity: kenya);

      await expectLater(
        createTaxTransaction(
          book.session,
          account,
          lines: [
            TransactionLineInput(
              amountMinor: 5000,
              taxCategoryCode: 'universal.income.unknown',
            ),
          ],
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('then a pack code still rejects without a pack', () async {
      final account = await book.addAccount(entity: kenya);

      await expectLater(
        createTaxTransaction(
          book.session,
          account,
          lines: [
            TransactionLineInput(
              amountMinor: 5000,
              taxCategoryCode: 'gb.ind.employment',
            ),
          ],
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('then the report still declines until the universal panel lands '
        '(task U11)', () async {
      final account = await book.addAccount(entity: kenya);
      await createTaxTransaction(
        book.session,
        account,
        amountMinor: 250000,
        lines: [
          TransactionLineInput(
            amountMinor: 250000,
            taxCategoryCode: 'universal.income.employment',
          ),
        ],
      );

      await expectLater(
        endpoint.getReport(book.session, kenya.id!, startYear: 2026),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('when a GB sole trader tags universal codes', () {
    setUp(() async {
      book = await BudgetTestBook.create(
        server.anonymousSession(),
        kind: EntityKind.soleTrader,
      );
      await saveTaxProfile(book.session, book.entity);
    });

    test('then universal.expense.software lands in the report under its '
        'mapped GB code', () async {
      final account = await book.addAccount();
      await createTaxTransaction(
        book.session,
        account,
        amountMinor: -50000,
        date: DateTime.utc(2026, 6, 10),
        lines: [
          TransactionLineInput(
            amountMinor: -50000,
            taxCategoryCode: 'universal.expense.software',
          ),
        ],
      );

      final report = await endpoint.getReport(
        book.session,
        book.entity.id!,
        startYear: 2026,
      );

      final officeCosts = _lineWith(report, 'gb.se.phone_office');
      expect(officeCosts, isNotNull);
      expect(officeCosts!.amountMinor, 50000);
      expect(officeCosts.entryCount, 1);
      expect(report.uncategorizedCount, 0);
      expect(
        report.assumptions.where((line) => line.contains('Caveat')),
        isEmpty,
      );
    });

    test('then an unmapped universal code counts as uncategorised with a '
        'caveat', () async {
      final account = await book.addAccount();
      await createTaxTransaction(
        book.session,
        account,
        amountMinor: -30000,
        date: DateTime.utc(2026, 6, 10),
        lines: [
          TransactionLineInput(
            amountMinor: -30000,
            taxCategoryCode: 'universal.expense.meals',
          ),
        ],
      );

      final report = await endpoint.getReport(
        book.session,
        book.entity.id!,
        startYear: 2026,
      );

      // Meals have no GB sole-trader box: client hospitality is
      // disallowable and staff entertainment is capped, so the entry
      // cannot be placed.
      expect(_lineWith(report, 'gb.se.phone_office'), isNull);
      expect(report.uncategorizedCount, 1);
      expect(
        report.assumptions.where((line) => line.contains('Caveat')),
        hasLength(1),
      );
    });
  });
}
