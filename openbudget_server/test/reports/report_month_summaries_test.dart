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

  Future<void> seedPlan() async {
    final first = fixture.envelopes[0];
    final second = fixture.envelopes[1];
    final euro = await fixture.book.addAccount(
      name: 'Euro wallet',
      currencyCode: 'EUR',
    );

    await fixture.income(100000, date: DateTime.utc(2026, 6, 1));
    await fixture.allocate(202606, {first: 30000});
    await fixture.spend(first, 40000, date: DateTime.utc(2026, 6, 2));
    await fixture.spend(
      first,
      1000,
      date: DateTime.utc(2026, 6, 3),
      accountId: euro.id,
      fxRate: '1.25',
    );
    await fixture.income(50000, date: DateTime.utc(2026, 7, 1));
    await fixture.allocate(202607, {second: 20000});
    await fixture.spend(second, 5000, date: DateTime.utc(2026, 7, 2));
    await fixture.allocate(202608, {first: 10000});
    await fixture.spend(first, 7000, date: DateTime.utc(2026, 8, 31));
    await fixture.spend(first, 1500, date: DateTime.utc(2026, 5, 31));
    await fixture.spend(first, 9000, date: DateTime.utc(2026, 9, 1));
  }

  test(
    'given three plan months when summaries run then each row matches the '
    'single-month fold and base amounts stay exact',
    () async {
      await seedPlan();

      final summaries = await ReportService.monthSummaries(
        fixture.session,
        fixture.entityId,
        202606,
        202608,
      );

      expect(summaries.map((row) => row.month), [202606, 202607, 202608]);
      for (final summary in summaries) {
        final single = (await fixture.month(summary.month)).summary;
        expect(summary.month, single.month);
        expect(summary.incomeMinor, single.incomeMinor);
        expect(summary.uncategorizedMinor, single.uncategorizedMinor);
        expect(summary.fxDifferenceMinor, single.fxDifferenceMinor);
        expect(summary.allocatedMinor, single.allocatedMinor);
        expect(summary.activityMinor, single.activityMinor);
        expect(
          summary.overspentLastMonthMinor,
          single.overspentLastMonthMinor,
        );
        expect(summary.assignedInFutureMinor, single.assignedInFutureMinor);
        expect(summary.readyToAssignMinor, single.readyToAssignMinor);
        expect(summary.availableMinor, single.availableMinor);
      }

      expect(summaries[0].incomeMinor, 100000);
      expect(summaries[0].activityMinor, -41250);
      expect(summaries[0].allocatedMinor, 30000);
      expect(summaries[0].overspentLastMonthMinor, 1500);
      expect(summaries[0].assignedInFutureMinor, 30000);
      expect(summaries[0].readyToAssignMinor, 38500);
      expect(summaries[0].availableMinor, -11250);

      expect(summaries[1].incomeMinor, 50000);
      expect(summaries[1].activityMinor, -5000);
      expect(summaries[1].overspentLastMonthMinor, 11250);
      expect(summaries[1].assignedInFutureMinor, 10000);
      expect(summaries[1].readyToAssignMinor, 77250);
      expect(summaries[1].availableMinor, 15000);

      expect(summaries[2].incomeMinor, 0);
      expect(summaries[2].activityMinor, -7000);
      expect(summaries[2].overspentLastMonthMinor, 0);
      expect(summaries[2].assignedInFutureMinor, 0);
      expect(summaries[2].readyToAssignMinor, 77250);
      expect(summaries[2].availableMinor, 18000);
    },
  );

  test(
    'given an empty entity when summaries run then every month is zero',
    () async {
      final empty = await fixture.book.addEntity(
        name: 'Empty',
        baseCurrencyCode: 'USD',
      );

      final summaries = await ReportService.monthSummaries(
        fixture.session,
        empty.id!,
        202606,
        202608,
      );

      expect(summaries, hasLength(3));
      for (final summary in summaries) {
        expect(summary.incomeMinor, 0);
        expect(summary.uncategorizedMinor, 0);
        expect(summary.fxDifferenceMinor, 0);
        expect(summary.allocatedMinor, 0);
        expect(summary.activityMinor, 0);
        expect(summary.overspentLastMonthMinor, 0);
        expect(summary.assignedInFutureMinor, 0);
        expect(summary.readyToAssignMinor, 0);
        expect(summary.availableMinor, 0);
      }
    },
  );

  test(
    'given another user entity when summaries run then they are refused',
    () async {
      final foreign = await netWorth.addForeignEntity();

      await expectLater(
        ReportService.monthSummaries(
          fixture.session,
          foreign.id!,
          202606,
          202608,
        ),
        throwsA(isA<ForbiddenException>()),
      );
    },
  );

  test(
    'given a reversed range when summaries run then it is rejected',
    () async {
      await expectLater(
        ReportService.monthSummaries(
          fixture.session,
          fixture.entityId,
          202608,
          202606,
        ),
        throwsA(isA<ValidationException>()),
      );
    },
  );

  test(
    'given the report endpoint when summaries run then it returns the same '
    'rows',
    () async {
      await seedPlan();

      final rows = await ReportEndpoint().monthSummaries(
        fixture.session,
        fixture.entityId,
        202606,
        202608,
      );

      expect(rows.map((row) => row.month), [202606, 202607, 202608]);
      expect(rows[0].readyToAssignMinor, 38500);
    },
  );
}
