import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_providers.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_repository.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ledger_actions_provider.g.dart';

/// Writes to the books, then refreshes what the writes change.
@Riverpod(keepAlive: true)
class LedgerActions extends _$LedgerActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Turns double-entry books on for [budgetId]. One-way: there is no
  /// endpoint that switches a budget back to envelopes.
  Future<Budget> enableLedger({required String budgetId}) async {
    state = const AsyncValue.loading();
    try {
      final budget = await ref
          .read(ledgerRepositoryProvider)
          .enableLedger(budgetId);
      if (ref.mounted) {
        ref
          ..invalidate(budgetDetailProvider(budgetId))
          ..invalidate(ledgerAccountsProvider(budgetId));
        state = const AsyncValue.data(null);
      }
      return budget;
    } on Exception catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(error, stackTrace);
      }
      rethrow;
    }
  }

  /// Saves a draft journal: creates one, or replaces the lines of the
  /// existing draft named by [journalId].
  Future<Journal> saveDraftJournal({
    required String budgetId,
    required DateTime date,
    required List<JournalLineInput> lines,
    required String reference,
    String? journalId,
    String? narration,
  }) async {
    state = const AsyncValue.loading();
    try {
      final journal = await ref
          .read(ledgerRepositoryProvider)
          .saveDraftJournal(
            budgetId: budgetId,
            date: date,
            lines: lines,
            journalId: journalId,
            reference: reference,
            narration: narration,
            source: 'manual',
          );
      if (ref.mounted) {
        ref
          ..invalidate(ledgerJournalsProvider(budgetId))
          ..invalidate(ledgerTrialBalanceProvider);
        state = const AsyncValue.data(null);
      }
      return journal;
    } on Exception catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(error, stackTrace);
      }
      rethrow;
    }
  }

  /// Deletes a draft journal. Posted journals cannot be deleted.
  Future<void> deleteDraftJournal({
    required String budgetId,
    required String journalId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(ledgerRepositoryProvider)
          .deleteDraftJournal(journalId);
      if (ref.mounted) {
        ref.invalidate(ledgerJournalsProvider(budgetId));
        state = const AsyncValue.data(null);
      }
    } on Exception catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(error, stackTrace);
      }
      rethrow;
    }
  }

  /// Posts a draft journal, making it immutable.
  Future<Journal> postJournal({
    required String budgetId,
    required String journalId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final journal = await ref
          .read(ledgerRepositoryProvider)
          .postJournal(journalId);
      if (ref.mounted) {
        ref
          ..invalidate(ledgerJournalsProvider(budgetId))
          ..invalidate(ledgerTrialBalanceProvider);
        state = const AsyncValue.data(null);
      }
      return journal;
    } on Exception catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(error, stackTrace);
      }
      rethrow;
    }
  }

  /// Reverses a posted journal on [date] with a mirror journal.
  Future<Journal> reverseJournal({
    required String budgetId,
    required String journalId,
    required DateTime date,
  }) async {
    state = const AsyncValue.loading();
    try {
      final reversal = await ref
          .read(ledgerRepositoryProvider)
          .reverseJournal(journalId: journalId, date: date);
      if (ref.mounted) {
        ref
          ..invalidate(ledgerJournalsProvider(budgetId))
          ..invalidate(ledgerTrialBalanceProvider);
        state = const AsyncValue.data(null);
      }
      return reversal;
    } on Exception catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(error, stackTrace);
      }
      rethrow;
    }
  }

  /// Sets or moves the budget's period lock date.
  Future<LedgerPeriodLock> setLockDate({
    required String budgetId,
    required DateTime lockDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final lock = await ref
          .read(ledgerRepositoryProvider)
          .setLockDate(budgetId, lockDate);
      if (ref.mounted) {
        ref
          ..invalidate(ledgerJournalsProvider(budgetId))
          ..invalidate(ledgerTrialBalanceProvider);
        state = const AsyncValue.data(null);
      }
      return lock;
    } on Exception catch (error, stackTrace) {
      if (ref.mounted) {
        state = AsyncValue.error(error, stackTrace);
      }
      rethrow;
    }
  }
}
