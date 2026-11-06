import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_actions_provider.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_providers.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_repository.dart';
import '../ledger_test_data.dart';

ProviderContainer _containerWith(LedgerRepository repository) {
  final container = ProviderContainer(
    overrides: [
      ledgerRepositoryProvider.overrideWithValue(repository),
      budgetDetailProvider.overrideWith(
        (ref, id) async => testBudget(),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('ledgerAccountsProvider', () {
    test('lists accounts including archived ones', () async {
      final fake = FakeLedgerRepository();
      final container = _containerWith(fake);

      final accounts = await container.read(
        ledgerAccountsProvider(testBudgetId).future,
      );

      expect(accounts, hasLength(5));
      expect(fake.accountCalls.single.includeArchived, isTrue);
    });

    test('surfaces repository errors', () async {
      final container = _containerWith(
        FakeLedgerRepository(accountsError: Exception('offline')),
      );
      final provider = ledgerAccountsProvider(testBudgetId);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      await Future<void>.delayed(Duration.zero);

      expect(container.read(provider).hasError, isTrue);
    });
  });

  group('ledgerJournalsProvider', () {
    test('returns the journals from the repository', () async {
      final fake = FakeLedgerRepository();
      final container = _containerWith(fake);

      final journals = await container.read(
        ledgerJournalsProvider(testBudgetId).future,
      );

      expect(journals, hasLength(4));
      expect(journals.first.reference, 'JB-2026-0004');
      expect(journals.first.status, 'posted');
    });
  });

  group('ledgerTrialBalanceProvider', () {
    test('passes the as-of date through', () async {
      final fake = FakeLedgerRepository();
      final container = _containerWith(fake);
      final asOf = DateTime(2026, 10, 31);

      final report = await container.read(
        ledgerTrialBalanceProvider(testBudgetId, asOf).future,
      );

      expect(report.totalDebitMinor, 5000);
      expect(fake.trialBalanceCalls.single.asOf, asOf);
    });

    test('asks the repository separately per as-of date', () async {
      final fake = FakeLedgerRepository();
      final container = _containerWith(fake);

      await container.read(
        ledgerTrialBalanceProvider(testBudgetId, DateTime(2026)).future,
      );
      await container.read(
        ledgerTrialBalanceProvider(testBudgetId, DateTime(2026, 10, 31))
            .future,
      );

      expect(
        fake.trialBalanceCalls.map((call) => call.asOf),
        [DateTime(2026), DateTime(2026, 10, 31)],
      );
    });
  });

  group('ledgerActionsProvider', () {
    test('enableLedger forwards to the repository', () async {
      final fake = FakeLedgerRepository();
      final container = _containerWith(fake);

      final budget = await container
          .read(ledgerActionsProvider.notifier)
          .enableLedger(budgetId: testBudgetId);

      expect(budget.accountingMode, 'ledger');
      expect(fake.enabledBudgets, [testBudgetId]);
      expect(container.read(ledgerActionsProvider), const AsyncValue<void>.data(null));
    });

    test('enableLedger records failures and rethrows', () async {
      final container = _containerWith(
        FakeLedgerRepository(enableError: Exception('server said no')),
      );

      await expectLater(
        container
            .read(ledgerActionsProvider.notifier)
            .enableLedger(budgetId: testBudgetId),
        throwsA(isA<Exception>()),
      );
      expect(container.read(ledgerActionsProvider).hasError, isTrue);
    });

    test('saveDraftJournal forwards a manual draft with its lines', () async {
      final fake = FakeLedgerRepository();
      final container = _containerWith(fake);
      final date = DateTime(2026, 5, 14);

      final journal = await container
          .read(ledgerActionsProvider.notifier)
          .saveDraftJournal(
            budgetId: testBudgetId,
            date: date,
            lines: [
              testLineInput(),
              testLineInput(accountId: salesAccountId, debit: false),
            ],
            reference: 'JB-2026-0009',
            narration: 'Client invoice',
          );

      expect(journal.status, 'draft');
      expect(fake.savedDrafts, hasLength(1));
      final saved = fake.savedDrafts.single;
      expect(saved.budgetId, testBudgetId);
      expect(saved.source, 'manual');
      expect(saved.reference, 'JB-2026-0009');
      expect(saved.narration, 'Client invoice');
      expect(saved.lines, hasLength(2));
      expect(saved.lines.first.debitMinor, 5000);
      expect(saved.lines.last.creditMinor, 5000);
    });

    test('deleteDraftJournal removes the draft from the store', () async {
      final fake = FakeLedgerRepository();
      final container = _containerWith(fake);

      await container
          .read(ledgerActionsProvider.notifier)
          .deleteDraftJournal(
            budgetId: testBudgetId,
            journalId: draftJournalId,
          );

      expect(fake.deletedJournals, [draftJournalId]);
      final left = await container.read(
        ledgerJournalsProvider(testBudgetId).future,
      );
      expect(
        left.where((j) => j.id?.toString() == draftJournalId),
        isEmpty,
      );
    });

    test('postJournal flips the draft to posted', () async {
      final fake = FakeLedgerRepository();
      final container = _containerWith(fake);

      final journal = await container
          .read(ledgerActionsProvider.notifier)
          .postJournal(
            budgetId: testBudgetId,
            journalId: draftJournalId,
          );

      expect(fake.postedJournals, [draftJournalId]);
      expect(journal.status, 'posted');
    });

    test('reverseJournal mirrors the original and marks it reversed', () async {
      final fake = FakeLedgerRepository();
      final container = _containerWith(fake);
      final date = DateTime(2026, 11);

      final reversal = await container
          .read(ledgerActionsProvider.notifier)
          .reverseJournal(
            budgetId: testBudgetId,
            journalId: postedJournalId,
            date: date,
          );

      expect(fake.reversedJournals.single, (
        journalId: postedJournalId,
        date: date,
      ));
      expect(reversal.status, 'posted');
      expect(reversal.reversalOfJournalId?.toString(), postedJournalId);
      final left = await container.read(
        ledgerJournalsProvider(testBudgetId).future,
      );
      final original = left.firstWhere(
        (j) => j.id?.toString() == postedJournalId,
      );
      expect(original.status, 'reversed');
    });

    test('setLockDate forwards the chosen date', () async {
      final fake = FakeLedgerRepository();
      final container = _containerWith(fake);
      final date = DateTime(2026, 10, 31);

      final lock = await container
          .read(ledgerActionsProvider.notifier)
          .setLockDate(budgetId: testBudgetId, lockDate: date);

      expect(lock.lockDate, date);
      expect(fake.lockDates.single.lockDate, date);
    });

    test('failed posting records an error state and rethrows', () async {
      final container = _containerWith(
        FakeLedgerRepository(postError: Exception('books locked')),
      );

      await expectLater(
        container
            .read(ledgerActionsProvider.notifier)
            .postJournal(
              budgetId: testBudgetId,
              journalId: draftJournalId,
            ),
        throwsA(isA<Exception>()),
      );
      expect(container.read(ledgerActionsProvider).hasError, isTrue);
    });
  });

  group('fake store integrity', () {
    test('posting a reversal on a fresh fake keeps the store consistent', () async {
      final fake = FakeLedgerRepository();
      final container = _containerWith(fake);

      await container.read(ledgerJournalsProvider(testBudgetId).future);
      await container
          .read(ledgerActionsProvider.notifier)
          .reverseJournal(
            budgetId: testBudgetId,
            journalId: postedJournalId,
            date: DateTime(2026, 11, 2),
          );

      final journals = await container.read(
        ledgerJournalsProvider(testBudgetId).future,
      );
      expect(journals, hasLength(5));
    });
  });
}
