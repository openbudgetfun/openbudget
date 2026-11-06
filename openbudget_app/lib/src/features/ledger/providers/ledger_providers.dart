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

/// The trial balance through the inclusive calendar date [asOf].
@riverpod
Future<TrialBalanceView> ledgerTrialBalance(
  Ref ref,
  String budgetId,
  DateTime asOf,
) => ref.watch(ledgerRepositoryProvider).trialBalance(budgetId, asOf);
