// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/reports/report_endpoint.dart';
import 'package:openbudget_server/src/reports/report_service.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:test/test.dart';

import '../budget/budget_helpers.dart';
import '../support/pg_test_server.dart';
import 'net_worth_helpers.dart';

void main() {
  late PgTestServer server;
  late BudgetFixture fixture;
  late NetWorthFixture netWorth;
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
      clock: () => DateTime.utc(2026, 6, 15, 12),
      backfillScheduler: (_, _) async {},
    );
    TransactionWriter.debugPublisher = (
      session,
      entityId,
      scope, {
      month,
      accountId,
    }) async {};
    EntityRealtimeNotifier.debugPublisher = (
      session,
      entityId,
      scope, {
      month,
      accountId,
    }) async {};
    fixture = await BudgetFixture.create(
      server.anonymousSession(),
      baseCurrencyCode: 'USD',
    );
    netWorth = NetWorthFixture(server: server, book: fixture.book);
  });

  tearDown(() {
    FxService.resetForTests();
    TransactionWriter.resetForTests();
    EntityRealtimeNotifier.resetForTests();
  });

  Future<void> seedReportingBook() async {
    final first = fixture.envelopes[0];
    final second = fixture.envelopes[1];
    final savings = await fixture.book.addAccount(name: 'Savings');
    final brokerage = await fixture.book.addAccount(
      name: 'Brokerage',
      onBudget: false,
    );
    final otherEntity = await fixture.book.addEntity(
      name: 'Other book',
      baseCurrencyCode: 'USD',
    );
    final otherAccount = await fixture.book.addAccount(
      name: 'Other checking',
      entity: otherEntity,
    );
    final euro = await fixture.book.addAccount(
      name: 'Euro wallet',
      currencyCode: 'EUR',
    );
    final payee = await fixture.book.addPayee(name: 'Shop');

    await fixture.income(10000, date: DateTime.utc(2026, 6, 1));
    await fixture.spend(first, 3000, date: DateTime.utc(2026, 6, 2));
    await fixture.splitSpend({
      first: 1000,
      second: 2000,
    }, date: DateTime.utc(2026, 6, 3));
    await TransactionWriter.createTransfer(
      fixture.session,
      TransferInput(
        fromAccountId: fixture.account.id!,
        toAccountId: savings.id!,
        date: DateTime.utc(2026, 6, 4),
        fromAmountMinor: 5000,
      ),
    );
    await TransactionWriter.createTransfer(
      fixture.session,
      TransferInput(
        fromAccountId: fixture.account.id!,
        toAccountId: brokerage.id!,
        date: DateTime.utc(2026, 6, 5),
        fromAmountMinor: 700,
        envelopeId: first.id,
      ),
    );
    await TransactionWriter.createTransfer(
      fixture.session,
      TransferInput(
        fromAccountId: fixture.account.id!,
        toAccountId: otherAccount.id!,
        date: DateTime.utc(2026, 6, 6),
        fromAmountMinor: 200,
        envelopeId: second.id,
      ),
    );
    await TransactionWriter.create(
      fixture.session,
      TransactionInput(
        accountId: fixture.account.id!,
        date: DateTime.utc(2026, 6, 7),
        amountMinor: -900,
        payeeId: payee.id,
        description: 'Shop',
        lines: [TransactionLineInput(amountMinor: -900, envelopeId: first.id)],
      ),
    );
    await fixture.spend(
      first,
      1000,
      date: DateTime.utc(2026, 6, 8),
      accountId: euro.id,
      fxRate: '1.25',
    );
    await fixture.spend(first, 400, date: DateTime.utc(2026, 6, 30));
    await fixture.spend(first, 1500, date: DateTime.utc(2026, 5, 31));
    await fixture.spend(first, 1200, date: DateTime.utc(2026, 7, 1));
  }

  test(
    'given splits, a multi-currency line and transfers when spending groups '
    'by envelope then base amounts and counts are exact',
    () async {
      await seedReportingBook();

      final rows = await ReportService.spending(
        fixture.session,
        fixture.entityId,
        202606,
        202606,
        ReportGrouping.envelope,
        false,
      );

      expect(rows.map((row) => row.name), [
        'Envelope 0',
        'Envelope 1',
        'No envelope',
      ]);
      expect(rows[0].outflowMinor, -7250);
      expect(rows[0].inflowMinor, 0);
      expect(rows[0].transactionCount, 6);
      expect(rows[0].month, isNull);
      expect(rows[0].groupId, fixture.envelopes[0].id);
      expect(rows[1].outflowMinor, -2200);
      expect(rows[1].transactionCount, 2);
      expect(rows[1].groupId, fixture.envelopes[1].id);
      expect(rows[2].groupId, isNull);
      expect(rows[2].outflowMinor, 0);
      expect(rows[2].inflowMinor, 10000);
      expect(rows[2].transactionCount, 1);
    },
  );

  test(
    'given a three-month range when spending groups by month then each '
    'boundary month keeps only its own rows',
    () async {
      await seedReportingBook();

      final rows = await ReportService.spending(
        fixture.session,
        fixture.entityId,
        202605,
        202607,
        ReportGrouping.envelope,
        true,
      );

      final may = rows.where((row) => row.month == 202605).toList();
      final june = rows.where((row) => row.month == 202606).toList();
      final july = rows.where((row) => row.month == 202607).toList();

      expect(may, hasLength(1));
      expect(may.single.name, 'Envelope 0');
      expect(may.single.outflowMinor, -1500);
      expect(june.map((row) => row.outflowMinor), [-7250, -2200, 0]);
      expect(july, hasLength(1));
      expect(july.single.outflowMinor, -1200);
    },
  );

  test(
    'given a category and payee grouping when spending runs then names come '
    'from the entity lookups and a split counts once',
    () async {
      await seedReportingBook();

      final categories = await ReportService.spending(
        fixture.session,
        fixture.entityId,
        202606,
        202606,
        ReportGrouping.category,
        false,
      );
      expect(categories.map((row) => row.name), [
        'Category 0',
        'Category 1',
        'No category',
      ]);
      expect(categories[0].outflowMinor, -7250);
      expect(categories[1].outflowMinor, -2200);
      expect(categories[2].inflowMinor, 10000);

      final payees = await ReportService.spending(
        fixture.session,
        fixture.entityId,
        202606,
        202606,
        ReportGrouping.payee,
        false,
      );
      expect(payees.map((row) => row.name), ['No payee', 'Shop']);
      expect(payees[0].outflowMinor, -8550);
      expect(payees[0].inflowMinor, 10000);
      expect(payees[0].transactionCount, 7);
      expect(payees[1].outflowMinor, -900);
      expect(payees[1].transactionCount, 1);
    },
  );

  test(
    'given an empty entity when spending runs then it returns no rows',
    () async {
      final empty = await fixture.book.addEntity(
        name: 'Empty',
        baseCurrencyCode: 'USD',
      );

      final rows = await ReportService.spending(
        fixture.session,
        empty.id!,
        202606,
        202606,
        ReportGrouping.envelope,
        false,
      );

      expect(rows, isEmpty);
    },
  );

  test(
    'given another user entity when spending runs then it is refused',
    () async {
      final foreign = await netWorth.addForeignEntity();

      await expectLater(
        ReportService.spending(
          fixture.session,
          foreign.id!,
          202606,
          202606,
          ReportGrouping.envelope,
          false,
        ),
        throwsA(isA<ForbiddenException>()),
      );
    },
  );

  test(
    'given the report endpoint when spending runs then it returns the same '
    'grouping',
    () async {
      await seedReportingBook();

      final rows = await ReportEndpoint().spending(
        fixture.session,
        fixture.entityId,
        202606,
        202606,
        ReportGrouping.envelope,
        false,
      );

      expect(rows.map((row) => row.outflowMinor), [-7250, -2200, 0]);
    },
  );
}
