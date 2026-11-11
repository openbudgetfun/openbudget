// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_print

import 'package:openbudget_server/src/budget/budget_month_service.dart';
import 'package:openbudget_server/src/budget/budget_service.dart';
import 'package:openbudget_server/src/budget/budget_validation.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/pg_test_server.dart';
import 'budget_helpers.dart';

void main() {
  late PgTestServer server;
  late BudgetFixture fixture;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
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
    fixture = await BudgetFixture.create(server.anonymousSession());
  });

  tearDown(() {
    TransactionWriter.resetForTests();
    EntityRealtimeNotifier.resetForTests();
    BudgetMonthService.debugAfterActivityQuery = null;
    BudgetMonthService.resetDebugStatementCount();
  });

  Future<void> seedTenYears() async {
    final offBudget = await fixture.book.addAccount(
      name: 'Off budget',
      onBudget: false,
    );
    final rows =
        <
          ({
            DateTime date,
            int amountMinor,
            int baseAmountMinor,
            UuidValue? envelopeId,
          })
        >[];
    final allocations = <MonthlyAllocation>[];
    for (var year = 2017; year <= 2026; year++) {
      for (var month = 1; month <= 12; month++) {
        final date = DateTime.utc(year, month, 5);
        final monthKey = year * 100 + month;
        rows
          ..add((
            date: date,
            amountMinor: 300000,
            baseAmountMinor: 300000,
            envelopeId: null,
          ))
          ..add((
            date: date,
            amountMinor: -120000,
            baseAmountMinor: -120000,
            envelopeId: fixture.envelopes[0].id,
          ))
          ..add((
            date: date,
            amountMinor: -20000,
            baseAmountMinor: -20000,
            envelopeId: fixture.envelopes[1].id,
          ));
        allocations
          ..add(
            MonthlyAllocation(
              entityId: fixture.entityId,
              envelopeId: fixture.envelopes[0].id!,
              month: monthKey,
              allocatedMinor: 100000,
            ),
          )
          ..add(
            MonthlyAllocation(
              entityId: fixture.entityId,
              envelopeId: fixture.envelopes[1].id!,
              month: monthKey,
              allocatedMinor: 50000,
            ),
          );
      }
    }

    await seedTransactionRows(
      fixture.session,
      entityId: fixture.entityId,
      accountId: fixture.account.id!,
      rows: rows,
    );
    await seedTransactionRows(
      fixture.session,
      entityId: fixture.entityId,
      accountId: offBudget.id!,
      rows: [
        for (var year = 2017; year <= 2026; year++)
          for (var month = 1; month <= 12; month++)
            for (var extra = 0; extra < 20; extra++)
              (
                date: DateTime.utc(year, month, 6),
                amountMinor: 1000,
                baseAmountMinor: 1000,
                envelopeId: null,
              ),
      ],
    );
    await MonthlyAllocation.db.insert(fixture.session, allocations);
  }

  test(
    'given ten years of history when read then the fold is exact and stays '
    'bounded to seven statements',
    () async {
      await seedTenYears();

      BudgetMonthService.resetDebugStatementCount();
      final stopwatch = Stopwatch()..start();
      final view = await fixture.month(202612);
      stopwatch.stop();

      expect(view.summary.incomeMinor, 300000);
      expect(view.summary.uncategorizedMinor, 0);
      expect(view.summary.fxDifferenceMinor, 0);
      expect(view.summary.allocatedMinor, 150000);
      expect(view.summary.activityMinor, -140000);
      expect(view.summary.overspentLastMonthMinor, 20000);
      expect(view.summary.assignedInFutureMinor, 0);
      expect(view.summary.readyToAssignMinor, 15620000);
      expect(view.summary.availableMinor, 3580000);
      expect(view.envelopes[0].availableMinor, -20000);
      expect(view.envelopes[1].availableMinor, 3600000);
      await fixture.expectInvariant(view);

      expect(BudgetMonthService.debugStatementCount, 7);
      expect(BudgetMonthService.debugStatementLabels, [
        'entity',
        'envelopeActivity',
        'allocations',
        'uncategorisedFlows',
        'categories',
        'envelopes',
        'goals',
      ]);
      // Printed so the evidence file records the actual measurement, not a
      // claim about the expected time.
      print(
        '10-year plan read: ${stopwatch.elapsedMicroseconds} us, '
        '${BudgetMonthService.debugStatementCount} statements',
      );
    },
  );

  test(
    'given the three aggregate shapes when explained then each is index '
    'backed and the plan is printed',
    () async {
      await seedTenYears();
      final entityId = fixture.entityId.toString();
      final nextMonth = BudgetValidation.firstDayOfNextMonth(202612);

      Future<String> explain(
        String sql,
        Map<String, Object?> parameters, {
        bool forceIndex = false,
      }) async {
        final rows = await fixture.session.db.transaction((transaction) async {
          if (forceIndex) {
            await fixture.session.db.unsafeExecute(
              'SET LOCAL enable_seqscan = off',
              transaction: transaction,
            );
          }
          return fixture.session.db.unsafeQuery(
            'EXPLAIN (ANALYZE, FORMAT JSON) $sql',
            parameters: QueryParameters.named(parameters),
            transaction: transaction,
          );
        });
        final value = rows.first.single;
        return value is String ? value : value.toString();
      }

      final parameters = {
        'entityId': entityId,
        'firstDayOfNextMonth': nextMonth,
      };
      final activityPlan = await explain(
        BudgetMonthService.envelopeActivitySql,
        parameters,
      );
      final allocationPlan = await explain(
        BudgetMonthService.allocationsSql,
        {'entityId': entityId},
      );
      final flowPlan = await explain(
        BudgetMonthService.uncategorisedFlowSql,
        parameters,
      );
      final forcedActivity = await explain(
        BudgetMonthService.envelopeActivitySql,
        parameters,
        forceIndex: true,
      );
      final forcedFlow = await explain(
        BudgetMonthService.uncategorisedFlowSql,
        parameters,
        forceIndex: true,
      );

      expect(forcedActivity, contains('transaction_entity_date_idx'));
      expect(forcedFlow, contains('transaction_entity_date_idx'));
      print('activity plan: $activityPlan');
      print('allocation plan: $allocationPlan');
      print('flow plan: $flowPlan');
    },
  );

  test(
    'given a competing write after the first aggregate when read then the '
    'returned view still comes from one snapshot',
    () async {
      final first = fixture.envelopes.first;
      await fixture.income(5000, date: DateTime.utc(2026, 10, 1));
      await fixture.allocate(202610, {first: 1000});
      final writer = server.authenticatedSession(fixture.book.userId);
      addTearDown(writer.close);

      var writes = 0;
      BudgetMonthService.debugAfterActivityQuery = () async {
        if (writes != 0) return;
        writes = 1;
        await BudgetService.setAllocations(
          writer,
          entityId: fixture.entityId,
          month: 202612,
          allocations: [
            AllocationInput(envelopeId: first.id!, allocatedMinor: 900),
          ],
        );
      };

      final before = await fixture.month(202610);
      expect(writes, 1);
      expect(before.summary.assignedInFutureMinor, 0);
      expect(before.summary.readyToAssignMinor, 4000);
      await fixture.expectInvariant(before);

      final after = await fixture.month(202610);
      expect(after.summary.assignedInFutureMinor, 900);
      expect(after.summary.readyToAssignMinor, 3100);
      await fixture.expectInvariant(after);
    },
  );
}
