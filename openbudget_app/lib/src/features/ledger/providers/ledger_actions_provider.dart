import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_providers.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_repository.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ledger_actions_provider.g.dart';

/// Writes to the books, then refreshes what the writes change.
@Riverpod(keepAlive: true)
class LedgerActions extends _$LedgerActions {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  /// Turns double-entry books on for [entityId]. One-way: there is no
  /// endpoint that switches a budget back to envelopes.
  Future<Entity> enableLedger({required String entityId}) async {
    state = const AsyncValue.loading();
    try {
      final entity = await ref
          .read(ledgerRepositoryProvider)
          .enableLedger(entityId);
      if (ref.mounted) {
        ref
          ..invalidate(entityDetailProvider(entityId))
          ..invalidate(ledgerAccountsProvider(entityId));
        state = const AsyncValue.data(null);
      }
      return entity;
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
    required String entityId,
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
            entityId: entityId,
            date: date,
            lines: lines,
            journalId: journalId,
            reference: reference,
            narration: narration,
            source: JournalSource.manual,
          );
      if (ref.mounted) {
        ref
          ..invalidate(ledgerJournalsProvider(entityId))
          ..invalidate(ledgerTrialBalanceProvider);
        final savedId = journal.id?.toString();
        if (savedId != null) {
          ref.invalidate(ledgerJournalLinesProvider(savedId));
        }
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
    required String entityId,
    required String journalId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(ledgerRepositoryProvider).deleteDraftJournal(journalId);
      if (ref.mounted) {
        ref.invalidate(ledgerJournalsProvider(entityId));
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
    required String entityId,
    required String journalId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final journal = await ref
          .read(ledgerRepositoryProvider)
          .postJournal(journalId);
      if (ref.mounted) {
        ref
          ..invalidate(ledgerJournalsProvider(entityId))
          ..invalidate(ledgerTrialBalanceProvider)
          ..invalidate(ledgerJournalLinesProvider(journalId));
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
    required String entityId,
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
          ..invalidate(ledgerJournalsProvider(entityId))
          ..invalidate(ledgerTrialBalanceProvider)
          ..invalidate(ledgerJournalLinesProvider(journalId));
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
    required String entityId,
    required DateTime lockDate,
  }) async {
    state = const AsyncValue.loading();
    try {
      final lock = await ref
          .read(ledgerRepositoryProvider)
          .setLockDate(entityId, lockDate);
      if (ref.mounted) {
        ref
          ..invalidate(ledgerJournalsProvider(entityId))
          ..invalidate(ledgerTrialBalanceProvider)
          ..invalidate(ledgerLockDateProvider(entityId));
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
