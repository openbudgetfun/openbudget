import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/ledger/ledger_service.dart';
import 'package:serverpod/serverpod.dart';

/// API surface for an entity's double-entry books.
///
/// All methods require authentication and cross [LedgerService], which checks
/// entity ownership. Posted journals have no update or delete path anywhere
/// in this API: corrections go through [reverseJournal]. Revaluation is not
/// exposed until the revaluation unit exists.
class LedgerEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Enables ledger accounting on a sole-trader or company entity: seeds the
  /// country chart, links one ledger account per money account, and switches
  /// the entity to ledger mode atomically.
  Future<Entity> enableLedger(Session session, UuidValue entityId) =>
      LedgerService.enableLedger(session, entityId);

  /// Lists the entity's ledger accounts.
  Future<List<LedgerAccount>> listAccounts(
    Session session,
    UuidValue entityId, {
    bool includeArchived = false,
  }) => LedgerService.listAccounts(
    session,
    entityId,
    includeArchived: includeArchived,
  );

  /// Adds an account to the entity's chart of accounts.
  Future<LedgerAccount> createAccount(
    Session session,
    UuidValue entityId,
    String code,
    String name,
    LedgerAccountType type, {
    LedgerSystemRole? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
  }) => LedgerService.createAccount(
    session,
    entityId,
    code,
    name,
    type,
    systemRole: systemRole,
    currencyCode: currencyCode,
    taxCategoryCode: taxCategoryCode,
  );

  /// Archives a non-structural account so it stops accepting postings.
  Future<LedgerAccount> archiveAccount(
    Session session,
    UuidValue accountId,
  ) => LedgerService.archiveAccount(session, accountId);

  /// Saves a draft journal: creates one, or replaces the lines of an existing
  /// draft when [journalId] is given.
  Future<Journal> saveDraftJournal(
    Session session,
    UuidValue entityId,
    DateTime date,
    List<JournalLineInput> lines, {
    UuidValue? journalId,
    String reference = '',
    String? narration,
    JournalSource source = JournalSource.manual,
  }) => LedgerService.saveDraftJournal(
    session,
    entityId,
    date,
    lines,
    journalId: journalId,
    reference: reference,
    narration: narration,
    source: source,
  );

  /// Deletes a draft journal. Posted journals cannot be deleted.
  Future<void> deleteDraftJournal(Session session, UuidValue journalId) =>
      LedgerService.deleteDraftJournal(session, journalId);

  /// Posts a draft journal, making it immutable.
  Future<Journal> postJournal(Session session, UuidValue journalId) =>
      LedgerService.postJournal(session, journalId);

  /// Reverses a posted journal on [date] with a mirror journal.
  Future<Journal> reverseJournal(
    Session session,
    UuidValue journalId,
    DateTime date,
  ) => LedgerService.reverseJournal(session, journalId, date);

  /// Lists one bounded page of the entity's journals, newest first.
  Future<List<Journal>> listJournals(
    Session session,
    UuidValue entityId, {
    DateTime? fromDate,
    DateTime? toDate,
    int limit = 100,
    String? cursor,
  }) => LedgerService.listJournals(
    session,
    entityId,
    fromDate: fromDate,
    toDate: toDate,
    limit: limit,
    cursor: cursor,
  );

  /// Lists one journal's lines, oldest first.
  Future<List<JournalLine>> listJournalLines(
    Session session,
    UuidValue journalId,
  ) => LedgerService.listJournalLines(session, journalId);

  /// The entity's period lock, or null when no lock date has been set.
  Future<LedgerPeriodLock?> getLockDate(
    Session session,
    UuidValue entityId,
  ) => LedgerService.getLockDate(session, entityId);

  /// Sets or moves the entity's period lock date.
  Future<LedgerPeriodLock> setLockDate(
    Session session,
    UuidValue entityId,
    DateTime lockDate,
  ) => LedgerService.setLockDate(session, entityId, lockDate);

  /// Computes the trial balance through [asOf] over posted journals.
  Future<TrialBalanceView> trialBalance(
    Session session,
    UuidValue entityId,
    DateTime asOf,
  ) => LedgerService.trialBalance(session, entityId, asOf);

  /// Lists one bounded page of the entity's audit trail, newest first.
  Future<List<AuditEvent>> listAuditEvents(
    Session session,
    UuidValue entityId, {
    DateTime? before,
    int? limit,
  }) => LedgerService.listAuditEvents(
    session,
    entityId,
    before: before,
    limit: limit,
  );
}
