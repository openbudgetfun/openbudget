import 'package:openbudget_app/src/features/ledger/providers/ledger_repository.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ledger_providers.g.dart';

/// The budget's chart of accounts, archived accounts included so the
/// Accounts tab can mark them.
@riverpod
Future<List<LedgerAccount>> ledgerAccounts(Ref ref, String budgetId) => ref
    .watch(ledgerRepositoryProvider)
    .listAccounts(budgetId, includeArchived: true);

/// The budget's journals, newest first.
@riverpod
Future<List<Journal>> ledgerJournals(Ref ref, String budgetId) =>
    ref.watch(ledgerRepositoryProvider).listJournals(budgetId);

/// One journal's lines, oldest first.
@riverpod
Future<List<JournalLine>> ledgerJournalLines(Ref ref, String journalId) =>
    ref.watch(ledgerRepositoryProvider).listJournalLines(journalId);

/// The budget's stored period lock date, or null when none is set.
@riverpod
Future<LedgerPeriodLock?> ledgerLockDate(Ref ref, String budgetId) =>
    ref.watch(ledgerRepositoryProvider).getLockDate(budgetId);

/// The trial balance through the inclusive calendar date [asOf].
@riverpod
Future<TrialBalanceView> ledgerTrialBalance(
  Ref ref,
  String budgetId,
  DateTime asOf,
) => ref.watch(ledgerRepositoryProvider).trialBalance(budgetId, asOf);
