// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

import 'package:openbudget_server/src/budget/budget_month_service.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
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
    addTearDown(fixture.book.expectBalancesConsistent);
  });

  tearDown(() {
    TransactionWriter.resetForTests();
    EntityRealtimeNotifier.resetForTests();
    BudgetMonthService.debugAfterActivityQuery = null;
    BudgetMonthService.resetDebugStatementCount();
  });

  test(
    'given an empty month when read then every figure is zero and hidden '
    'rows stay in order',
    () async {
      await Category.db.updateRow(
        fixture.session,
        fixture.categories.first.copyWith(isHidden: true),
      );
      await Envelope.db.updateRow(
        fixture.session,
        fixture.envelopes.first.copyWith(isHidden: true),
      );

      final view = await fixture.month(202611);

      expect(view.month, 202611);
      expect(view.currencyCode, 'GBP');
      expect(view.categories, hasLength(2));
      expect(view.categories.first.isHidden, isTrue);
      expect(view.categories.map((row) => row.name), [
        'Category 0',
        'Category 1',
      ]);
      expect(view.envelopes, hasLength(2));
      expect(view.envelopes.first.envelope.isHidden, isTrue);
      expect(view.envelopes.map((row) => row.envelope.name), [
        'Envelope 0',
        'Envelope 1',
      ]);
      for (final row in view.envelopes) {
        expect(row.carryoverMinor, 0);
        expect(row.allocatedMinor, 0);
        expect(row.activityMinor, 0);
        expect(row.availableMinor, 0);
        expect(row.goalUnderfundedMinor, 0);
      }
      expect(view.summary.incomeMinor, 0);
      expect(view.summary.uncategorizedMinor, 0);
      expect(view.summary.fxDifferenceMinor, 0);
      expect(view.summary.allocatedMinor, 0);
      expect(view.summary.activityMinor, 0);
      expect(view.summary.overspentLastMonthMinor, 0);
      expect(view.summary.assignedInFutureMinor, 0);
      expect(view.summary.readyToAssignMinor, 0);
      expect(view.summary.availableMinor, 0);
      await fixture.expectInvariant(view);
    },
  );

  test(
    'given income, splits, a refund and an opening balance when read then '
    'summary and activity are exact',
    () async {
      final first = fixture.envelopes[0];
      final second = fixture.envelopes[1];
      await fixture.openingBalance(100000);
      await fixture.income(200000, date: DateTime.utc(2026, 11, 2));
      await fixture.spend(first, 30000, date: DateTime.utc(2026, 11, 3));
      await fixture.splitSpend({
        first: 10000,
        second: 15000,
      }, date: DateTime.utc(2026, 11, 4));
      await fixture.refund(first, 5000, date: DateTime.utc(2026, 11, 5));

      final view = await fixture.month(202611);

      expect(view.summary.incomeMinor, 300000);
      expect(view.summary.uncategorizedMinor, 0);
      expect(view.summary.fxDifferenceMinor, 0);
      expect(view.summary.allocatedMinor, 0);
      expect(view.summary.activityMinor, -50000);
      expect(view.summary.readyToAssignMinor, 300000);
      expect(view.summary.availableMinor, -50000);
      expect(view.envelopes[0].activityMinor, -35000);
      expect(view.envelopes[1].activityMinor, -15000);
      await fixture.expectInvariant(view);
    },
  );

  test(
    'given an FX revaluation when read then its difference is separate from '
    'income and still reaches Ready to Assign',
    () async {
      await fixture.income(1000, date: DateTime.utc(2026, 10, 1));
      await seedTransaction(
        fixture.session,
        entityId: fixture.entityId,
        accountId: fixture.account.id!,
        date: DateTime.utc(2026, 10, 15),
        amountMinor: 0,
        baseAmountMinor: 250,
        kind: TransactionKind.fxRevaluation,
      );

      final view = await fixture.month(202610);

      expect(view.summary.incomeMinor, 1000);
      expect(view.summary.fxDifferenceMinor, 250);
      expect(view.summary.uncategorizedMinor, 0);
      expect(view.summary.readyToAssignMinor, 1250);
      expect(view.summary.availableMinor, 0);
      await fixture.expectInvariant(view);
    },
  );

  test(
    'given a transaction on the first day after the asked month when read '
    'then the asked month excludes it',
    () async {
      await fixture.income(1000, date: DateTime.utc(2026, 10, 31));
      await fixture.spend(
        fixture.envelopes.first,
        200,
        date: DateTime.utc(2026, 11, 1),
      );

      final october = await fixture.month(202610);
      final november = await fixture.month(202611);

      expect(october.summary.incomeMinor, 1000);
      expect(october.envelopes.first.activityMinor, 0);
      expect(november.summary.incomeMinor, 0);
      expect(november.envelopes.first.activityMinor, -200);
      expect(november.summary.readyToAssignMinor, 1000);
      await fixture.expectInvariant(october);
      await fixture.expectInvariant(november);
    },
  );

  test(
    'given an overspent envelope and a future assignment when read then '
    'carryover floors and the next month is charged',
    () async {
      final first = fixture.envelopes[0];
      final second = fixture.envelopes[1];
      await fixture.income(1000, date: DateTime.utc(2026, 11, 1));
      await fixture.allocate(202611, {first: 800});
      await fixture.spend(first, 1000, date: DateTime.utc(2026, 11, 2));
      await fixture.allocate(202612, {second: 300});

      final november = await fixture.month(202611);
      final december = await fixture.month(202612);

      expect(november.envelopes[0].carryoverMinor, 0);
      expect(november.envelopes[0].availableMinor, -200);
      expect(november.summary.overspentLastMonthMinor, 0);
      expect(november.summary.assignedInFutureMinor, 300);
      expect(november.summary.readyToAssignMinor, -100);
      await fixture.expectInvariant(november);

      expect(december.envelopes[0].carryoverMinor, 0);
      expect(december.envelopes[0].availableMinor, 0);
      expect(december.envelopes[1].allocatedMinor, 300);
      expect(december.envelopes[1].availableMinor, 300);
      expect(december.summary.overspentLastMonthMinor, 200);
      expect(december.summary.readyToAssignMinor, -300);
      await fixture.expectInvariant(december);
    },
  );

  test(
    'given history gaps across a year boundary when read then carryover '
    'survives the empty months',
    () async {
      final first = fixture.envelopes[0];
      await fixture.allocate(202512, {first: 1000});
      await fixture.spend(first, 400, date: DateTime.utc(2025, 12, 5));

      final january = await fixture.month(202601);
      final february = await fixture.month(202602);

      expect(january.envelopes.first.carryoverMinor, 600);
      expect(january.envelopes.first.availableMinor, 600);
      expect(january.summary.readyToAssignMinor, -1000);
      expect(february.envelopes.first.carryoverMinor, 600);
      expect(february.summary.readyToAssignMinor, -1000);
      await fixture.expectInvariant(january);
      await fixture.expectInvariant(february);
    },
  );

  test(
    'given an internal transfer when read then the plan is unchanged',
    () async {
      final secondAccount = await fixture.book.addAccount(name: 'Savings');
      await fixture.income(5000, date: DateTime.utc(2026, 11, 1));
      await fixture.allocate(202611, {fixture.envelopes.first: 2000});
      final before = await fixture.month(202611);

      await TransactionWriter.createTransfer(
        fixture.session,
        TransferInput(
          fromAccountId: fixture.account.id!,
          toAccountId: secondAccount.id!,
          date: DateTime.utc(2026, 11, 2),
          fromAmountMinor: 1500,
        ),
      );
      final after = await fixture.month(202611);

      expect(
        after.summary.readyToAssignMinor,
        before.summary.readyToAssignMinor,
      );
      expect(after.summary.availableMinor, before.summary.availableMinor);
      expect(after.summary.activityMinor, 0);
      expect(after.summary.incomeMinor, before.summary.incomeMinor);
      expect(after.summary.uncategorizedMinor, 0);
      await fixture.expectInvariant(after);
    },
  );

  test(
    'given an off-budget outflow and a cross-entity inflow when read then '
    'both legs stay in the plan',
    () async {
      final offBudget = await fixture.book.addAccount(
        name: 'Brokerage',
        onBudget: false,
      );
      final otherEntity = await fixture.book.addEntity(name: 'Second book');
      final otherAccount = await fixture.book.addAccount(
        name: 'Other checking',
        entity: otherEntity,
      );

      await TransactionWriter.createTransfer(
        fixture.session,
        TransferInput(
          fromAccountId: fixture.account.id!,
          toAccountId: offBudget.id!,
          date: DateTime.utc(2026, 11, 2),
          fromAmountMinor: 300,
          envelopeId: fixture.envelopes.first.id,
        ),
      );
      await TransactionWriter.createTransfer(
        fixture.session,
        TransferInput(
          fromAccountId: fixture.account.id!,
          toAccountId: otherAccount.id!,
          date: DateTime.utc(2026, 11, 3),
          fromAmountMinor: 200,
          envelopeId: fixture.envelopes[1].id,
        ),
      );

      final first = await fixture.month(202611);
      final second = await BudgetMonthService.month(
        fixture.session,
        entityId: otherEntity.id!,
        month: 202611,
      );

      expect(first.envelopes[0].activityMinor, -300);
      expect(first.envelopes[1].activityMinor, -200);
      expect(first.summary.uncategorizedMinor, 0);
      await fixture.expectInvariant(first);
      expect(second.summary.incomeMinor, 200);
      expect(second.summary.readyToAssignMinor, 200);
      await fixture.expectInvariant(second, entityId: otherEntity.id);
    },
  );

  test(
    'given foreign-currency accounts when read then base minor units follow '
    'the stored exact rates',
    () async {
      final usd = await fixture.book.addAccount(
        name: 'US checking',
        currencyCode: 'USD',
      );
      final jpy = await fixture.book.addAccount(
        name: 'Japan wallet',
        currencyCode: 'JPY',
      );
      final kwd = await fixture.book.addAccount(
        name: 'Kuwait wallet',
        currencyCode: 'KWD',
      );
      await fixture.spend(
        fixture.envelopes[0],
        1000,
        accountId: usd.id,
        fxRate: '0.8',
      );
      await fixture.spend(
        fixture.envelopes[1],
        10000,
        accountId: jpy.id,
        fxRate: '0.0055',
      );
      await fixture.spend(
        fixture.envelopes[0],
        1000,
        accountId: kwd.id,
        fxRate: '2.5',
      );

      final view = await fixture.month(202611);

      expect(view.envelopes[0].activityMinor, -1050);
      expect(view.envelopes[1].activityMinor, -5500);
      expect(view.summary.activityMinor, -6550);
      await fixture.expectInvariant(view);
    },
  );

  test(
    'given a yen base currency and a dollar account when read then the base '
    'amount uses the zero-decimal exponent',
    () async {
      final yenBook = await BudgetFixture.create(
        server.anonymousSession(),
        baseCurrencyCode: 'JPY',
        envelopeCount: 1,
      );
      final usd = await yenBook.book.addAccount(
        name: 'US checking',
        currencyCode: 'USD',
      );
      await yenBook.spend(
        yenBook.envelopes.first,
        10000,
        accountId: usd.id,
        fxRate: '150',
      );

      final view = await yenBook.month(202611);

      expect(view.currencyCode, 'JPY');
      expect(view.envelopes.first.activityMinor, -15000);
      await yenBook.expectInvariant(view);
    },
  );

  test(
    'given hidden rows and three goal kinds when read then hidden amounts '
    'count and goal_math decides underfunding',
    () async {
      final extra = await BudgetFixture.create(
        server.anonymousSession(),
        envelopeCount: 3,
      );
      final first = extra.envelopes[0];
      final second = extra.envelopes[1];
      final third = extra.envelopes[2];
      await Category.db.updateRow(
        extra.session,
        extra.categories.first.copyWith(isHidden: true),
      );
      await Envelope.db.updateRow(
        extra.session,
        first.copyWith(isHidden: true),
      );
      await extra.allocate(202611, {first: 1000, second: 100, third: 100});
      await extra.spend(first, 400);
      await EnvelopeGoal.db.insertRow(
        extra.session,
        EnvelopeGoal(
          entityId: extra.entityId,
          envelopeId: first.id!,
          kind: EnvelopeGoalKind.targetBalance,
          amountMinor: 1000,
        ),
      );
      await EnvelopeGoal.db.insertRow(
        extra.session,
        EnvelopeGoal(
          entityId: extra.entityId,
          envelopeId: second.id!,
          kind: EnvelopeGoalKind.monthlyFunding,
          amountMinor: 300,
        ),
      );
      await EnvelopeGoal.db.insertRow(
        extra.session,
        EnvelopeGoal(
          entityId: extra.entityId,
          envelopeId: third.id!,
          kind: EnvelopeGoalKind.targetByDate,
          amountMinor: 1200,
          targetDate: DateTime.utc(2027, 2),
        ),
      );

      final view = await extra.month(202611);

      expect(view.categories.first.isHidden, isTrue);
      expect(view.envelopes.first.envelope.isHidden, isTrue);
      expect(view.summary.availableMinor, 800);
      expect(view.envelopes[0].availableMinor, 600);
      expect(view.envelopes[0].goal?.kind, EnvelopeGoalKind.targetBalance);
      expect(view.envelopes[0].goalUnderfundedMinor, 400);
      expect(view.envelopes[1].goalUnderfundedMinor, 200);
      expect(view.envelopes[2].goalUnderfundedMinor, 267);
      await extra.expectInvariant(view);
    },
  );
}
