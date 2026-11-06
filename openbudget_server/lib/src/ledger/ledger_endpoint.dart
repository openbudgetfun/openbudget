import 'package:openbudget_server/src/budgets/budget_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/ledger/ledger_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for a budget's double-entry books.
///
/// All methods require authentication and check budget ownership. Posted
/// journals have no update or delete path anywhere in this API: corrections
/// go through `reverseJournal`.
class LedgerEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Enables ledger accounting on a sole-trader or company budget and seeds
  /// its chart of accounts from the jurisdiction template.
  Future<Budget> enableLedger(Session session, UuidValue budgetId) async {
    final budget = await LedgerService.enableLedger(
      session,
      budgetId: budgetId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return budget;
  }

  /// Lists the budget's ledger accounts.
  Future<List<LedgerAccount>> listAccounts(
    Session session,
    UuidValue budgetId, {
    bool includeArchived = false,
  }) => LedgerService.listAccounts(
    session,
    budgetId: budgetId,
    includeArchived: includeArchived,
  );

  /// Adds an account to the budget's chart of accounts.
  Future<LedgerAccount> createAccount(
    Session session,
    UuidValue budgetId,
    String code,
    String name,
    String type, {
    String? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
  }) async {
    final account = await LedgerService.createAccount(
      session,
      budgetId: budgetId,
      code: code,
      name: name,
      type: type,
      systemRole: systemRole,
      currencyCode: currencyCode,
      taxCategoryCode: taxCategoryCode,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return account;
  }

  /// Archives an account so it stops accepting postings.
  Future<LedgerAccount> archiveAccount(
    Session session,
    UuidValue accountId,
  ) async {
    final account = await LedgerService.archiveAccount(
      session,
      accountId: accountId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(account.budgetId);
    return account;
  }

  /// Saves a draft journal: creates one, or replaces the lines of an
  /// existing draft when [journalId] is given.
  Future<Journal> saveDraftJournal(
    Session session,
    UuidValue budgetId,
    DateTime date,
    List<JournalLineInput> lines, {
    UuidValue? journalId,
    String reference = '',
    String? narration,
    String source = 'manual',
  }) async {
    final journal = await LedgerService.saveDraftJournal(
      session,
      budgetId: budgetId,
      date: date,
      lines: lines,
      journalId: journalId,
      reference: reference,
      narration: narration,
      source: source,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return journal;
  }

  /// Deletes a draft journal. Posted journals cannot be deleted.
  Future<void> deleteDraftJournal(
    Session session,
    UuidValue journalId,
  ) async {
    await LedgerService.deleteDraftJournal(session, journalId: journalId);
  }

  /// Posts a draft journal, making it immutable.
  Future<Journal> postJournal(Session session, UuidValue journalId) async {
    final journal = await LedgerService.postJournal(
      session,
      journalId: journalId,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(journal.budgetId);
    return journal;
  }

  /// Reverses a posted journal on [date] with a mirror journal.
  Future<Journal> reverseJournal(
    Session session,
    UuidValue journalId,
    DateTime date,
  ) async {
    final reversal = await LedgerService.reverseJournal(
      session,
      journalId: journalId,
      date: date,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(reversal.budgetId);
    return reversal;
  }

  /// Lists the budget's journals between the optional inclusive dates,
  /// newest first.
  Future<List<Journal>> listJournals(
    Session session,
    UuidValue budgetId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) => LedgerService.listJournals(
    session,
    budgetId: budgetId,
    fromDate: fromDate,
    toDate: toDate,
  );

  /// Lists one journal's lines, oldest first.
  Future<List<JournalLine>> listJournalLines(
    Session session,
    UuidValue journalId,
  ) => LedgerService.listJournalLines(session, journalId: journalId);

  /// The budget's period lock, or null when no lock date has been set.
  Future<LedgerPeriodLock?> getLockDate(
    Session session,
    UuidValue budgetId,
  ) => LedgerService.getLockDate(session, budgetId: budgetId);

  /// Sets or moves the budget's period lock date.
  Future<LedgerPeriodLock> setLockDate(
    Session session,
    UuidValue budgetId,
    DateTime lockDate,
  ) async {
    final lock = await LedgerService.setLockDate(
      session,
      budgetId: budgetId,
      lockDate: lockDate,
    );
    BudgetRealtimeNotifier.notifyBudgetChanged(budgetId);
    return lock;
  }

  /// Computes the trial balance through [asOf] over posted journals.
  Future<TrialBalanceView> trialBalance(
    Session session,
    UuidValue budgetId,
    DateTime asOf,
  ) => LedgerService.trialBalance(session, budgetId: budgetId, asOf: asOf);
}
