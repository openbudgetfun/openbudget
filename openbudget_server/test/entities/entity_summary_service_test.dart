// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_endpoint.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/entities/entity_summary_service.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:test/test.dart';

import '../budget/budget_helpers.dart';
import '../reports/net_worth_helpers.dart';
import '../support/pg_test_server.dart';

final _now = DateTime.utc(2026, 6, 15, 12);
final _today = DateTime.utc(2026, 6, 15);

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
      clock: () => _now,
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
    EntitySummaryService.resetDebugStatementCount();
  });

  tearDown(() {
    FxService.resetForTests();
    TransactionWriter.resetForTests();
    EntityRealtimeNotifier.resetForTests();
  });

  test(
    'given a funded entity with a schedule and proposals when summaries load '
    'then every headline matches',
    () async {
      final first = fixture.envelopes.first;
      await fixture.income(100000, date: DateTime.utc(2026, 6, 1));
      await fixture.allocate(202606, {first: 40000});
      await fixture.spend(first, 50000, date: DateTime.utc(2026, 6, 2));
      await TransactionWriter.create(
        fixture.session,
        TransactionInput(
          accountId: fixture.account.id!,
          date: DateTime.utc(2026, 6, 3),
          amountMinor: -2500,
          description: 'Unknown',
          lines: const [],
        ),
      );
      await RecurringTransaction.db.insertRow(
        fixture.session,
        RecurringTransaction(
          entityId: fixture.entityId,
          accountId: fixture.account.id!,
          description: 'Due rent',
          amountMinor: -1000,
          frequency: RecurrenceFrequency.monthly,
          nextDate: _today,
        ),
      );
      await RecurringTransaction.db.insertRow(
        fixture.session,
        RecurringTransaction(
          entityId: fixture.entityId,
          accountId: fixture.account.id!,
          description: 'Future rent',
          amountMinor: -1000,
          frequency: RecurrenceFrequency.monthly,
          nextDate: _today.add(const Duration(days: 1)),
        ),
      );
      await RecurringTransaction.db.insertRow(
        fixture.session,
        RecurringTransaction(
          entityId: fixture.entityId,
          accountId: fixture.account.id!,
          description: 'Inactive rent',
          amountMinor: -1000,
          frequency: RecurrenceFrequency.monthly,
          nextDate: _today,
          isActive: false,
        ),
      );
      await AgentProposal.db.insertRow(
        fixture.session,
        AgentProposal(
          userId: fixture.book.userId,
          entityId: fixture.entityId,
          kind: AgentProposalKind.moveMoney,
          payloadJson: '{}',
          summary: 'Move money',
        ),
      );
      await AgentProposal.db.insertRow(
        fixture.session,
        AgentProposal(
          userId: fixture.book.userId,
          entityId: fixture.entityId,
          kind: AgentProposalKind.moveMoney,
          payloadJson: '{}',
          summary: 'Already decided',
          status: AgentProposalStatus.dismissed,
        ),
      );

      final rows = await EntitySummaryService.list(fixture.session);

      final row = rows.single;
      expect(row.entity.id, fixture.book.entity.id);
      expect(row.month, 202606);
      expect(row.readyToAssignMinor, 57500);
      expect(row.overspentEnvelopeCount, 1);
      expect(row.uncategorizedCount, 1);
      expect(row.pendingProposalCount, 1);
      expect(row.dueRecurringCount, 1);
      expect(row.netWorthMinor, 47500);
      expect(row.netWorthComplete, isTrue);
    },
  );

  test(
    'given empty, archived and foreign entities when summaries load then only '
    'the active owned rows appear',
    () async {
      final empty = await fixture.book.addEntity(
        name: 'Empty',
        baseCurrencyCode: 'USD',
      );
      await fixture.book.addEntity(
        name: 'Archived',
        baseCurrencyCode: 'USD',
        archivedAt: _now,
      );
      final foreign = await netWorth.addForeignEntity();

      final rows = await EntitySummaryService.list(fixture.session);

      expect(
        rows.map((row) => row.entity.id).toSet(),
        {fixture.book.entity.id, empty.id},
      );
      expect(
        rows.map((row) => row.entity.id),
        isNot(contains(foreign.id)),
      );
      final emptyRow = rows.singleWhere((row) => row.entity.id == empty.id);
      expect(emptyRow.readyToAssignMinor, isNull);
      expect(emptyRow.overspentEnvelopeCount, 0);
      expect(emptyRow.netWorthMinor, 0);
      expect(emptyRow.netWorthComplete, isTrue);
      expect(emptyRow.uncategorizedCount, 0);
      expect(emptyRow.pendingProposalCount, 0);
      expect(emptyRow.dueRecurringCount, 0);
      expect(emptyRow.month, 202606);
    },
  );

  test(
    'given foreign accounts when summaries load then base net worth uses the '
    'stored rates and reports a missing one',
    () async {
      await fixture.book.addAccount(
        name: 'Euro wallet',
        currencyCode: 'EUR',
        balanceMinor: 1000,
      );
      await fixture.book.addAccount(
        name: 'Pound wallet',
        currencyCode: 'GBP',
        balanceMinor: 1000,
      );
      await netWorth.seedRates(_today, {'EUR': '0.5'});

      final incomplete = (await EntitySummaryService.list(
        fixture.session,
      )).single;
      expect(incomplete.netWorthMinor, 2000);
      expect(incomplete.netWorthComplete, isFalse);

      await netWorth.seedRate(
        currencyCode: 'GBP',
        rateDate: _today,
        rate: '0.8',
      );
      final complete = (await EntitySummaryService.list(fixture.session))
          .single;
      expect(complete.netWorthMinor, 3250);
      expect(complete.netWorthComplete, isTrue);
    },
  );

  test(
    'given two entities at different offsets when summaries load then each '
    'current month follows its own time zone',
    () async {
      FxService.configure(
        apiKey: null,
        baseUrl: null,
        clock: () => DateTime.utc(2026, 6, 30, 23),
        backfillScheduler: (_, _) async {},
      );
      final east = await fixture.book.addEntity(
        name: 'East',
        baseCurrencyCode: 'USD',
        timeZone: 'Pacific/Kiritimati',
      );
      final west = await fixture.book.addEntity(
        name: 'West',
        baseCurrencyCode: 'USD',
        timeZone: 'Pacific/Pago_Pago',
      );
      final eastAccount = await fixture.book.addAccount(
        name: 'East checking',
        entity: east,
      );
      final westAccount = await fixture.book.addAccount(
        name: 'West checking',
        entity: west,
      );
      await TransactionWriter.create(
        fixture.session,
        TransactionInput(
          accountId: eastAccount.id!,
          date: DateTime.utc(2026, 7, 1),
          amountMinor: 1000,
          description: 'July income',
          lines: const [],
        ),
      );
      await TransactionWriter.create(
        fixture.session,
        TransactionInput(
          accountId: westAccount.id!,
          date: DateTime.utc(2026, 6, 30),
          amountMinor: 2000,
          description: 'June income',
          lines: const [],
        ),
      );

      final rows = await EntitySummaryService.list(fixture.session);
      final eastRow = rows.singleWhere((row) => row.entity.id == east.id);
      final westRow = rows.singleWhere((row) => row.entity.id == west.id);

      expect(eastRow.month, 202607);
      expect(eastRow.readyToAssignMinor, 1000);
      expect(westRow.month, 202606);
      expect(westRow.readyToAssignMinor, 2000);
    },
  );

  test(
    'given more entities when summaries load then the statement count stays '
    'fixed',
    () async {
      await fixture.income(1000, date: _today);
      EntitySummaryService.resetDebugStatementCount();
      await EntitySummaryService.list(fixture.session);
      final oneEntityCount = EntitySummaryService.debugStatementCount;

      for (var index = 0; index < 3; index++) {
        final entity = await fixture.book.addEntity(
          name: 'Extra $index',
          baseCurrencyCode: 'USD',
        );
        await fixture.book.addAccount(
          name: 'Extra checking $index',
          entity: entity,
        );
      }
      EntitySummaryService.resetDebugStatementCount();
      await EntitySummaryService.list(fixture.session);

      expect(EntitySummaryService.debugStatementCount, oneEntityCount);
      expect(
        EntitySummaryService.debugStatementLabels,
        containsAll([
          'entities',
          'accounts',
          'envelopeActivity',
          'allocations',
          'uncategorisedFlows',
          'uncategorisedCount',
          'proposals',
          'recurring',
        ]),
      );
    },
  );

  test(
    'given the entity endpoint when summaries load then it delegates to the '
    'service',
    () async {
      final rows = await EntityEndpoint().listSummaries(fixture.session);
      expect(rows.single.entity.id, fixture.book.entity.id);
    },
  );
}
