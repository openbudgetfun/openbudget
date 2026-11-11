import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ledger_repository.g.dart';

/// The ledger API calls the app makes.
///
/// The app depends on this interface rather than the generated client so
/// tests can supply a fake API without a running server. Posted journals
/// have no update or delete path here: corrections go through
/// [reverseJournal].
abstract interface class LedgerRepository {
  Future<Entity> enableLedger(String entityId);

  Future<List<LedgerAccount>> listAccounts(
    String entityId, {
    required bool includeArchived,
  });

  Future<LedgerAccount> createAccount({
    required String entityId,
    required String code,
    required String name,
    required LedgerAccountType type,
    LedgerSystemRole? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
  });

  Future<LedgerAccount> archiveAccount(String accountId);

  Future<Journal> saveDraftJournal({
    required String entityId,
    required DateTime date,
    required List<JournalLineInput> lines,
    required String reference,
    required JournalSource source,
    String? journalId,
    String? narration,
  });

  Future<void> deleteDraftJournal(String journalId);

  Future<Journal> postJournal(String journalId);

  Future<Journal> reverseJournal({
    required String journalId,
    required DateTime date,
  });

  Future<List<Journal>> listJournals(
    String entityId, {
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// One journal's lines, oldest first.
  Future<List<JournalLine>> listJournalLines(String journalId);

  Future<LedgerPeriodLock> setLockDate(String entityId, DateTime lockDate);

  /// The budget's stored period lock date, or null when none is set.
  Future<LedgerPeriodLock?> getLockDate(String entityId);

  Future<TrialBalanceView> trialBalance(String entityId, DateTime asOf);
}

/// The production [LedgerRepository], backed by the Serverpod client.
class ServerpodLedgerRepository implements LedgerRepository {
  const ServerpodLedgerRepository(this._client);

  final Client _client;

  @override
  Future<Entity> enableLedger(String entityId) =>
      _client.ledger.enableLedger(UuidValue.fromString(entityId));

  @override
  Future<List<LedgerAccount>> listAccounts(
    String entityId, {
    required bool includeArchived,
  }) => _client.ledger.listAccounts(
    UuidValue.fromString(entityId),
    includeArchived: includeArchived,
  );

  @override
  Future<LedgerAccount> createAccount({
    required String entityId,
    required String code,
    required String name,
    required LedgerAccountType type,
    LedgerSystemRole? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
  }) => _client.ledger.createAccount(
    UuidValue.fromString(entityId),
    code,
    name,
    type,
    systemRole: systemRole,
    currencyCode: currencyCode,
    taxCategoryCode: taxCategoryCode,
  );

  @override
  Future<LedgerAccount> archiveAccount(String accountId) =>
      _client.ledger.archiveAccount(UuidValue.fromString(accountId));

  @override
  Future<Journal> saveDraftJournal({
    required String entityId,
    required DateTime date,
    required List<JournalLineInput> lines,
    required String reference,
    required JournalSource source,
    String? journalId,
    String? narration,
  }) => _client.ledger.saveDraftJournal(
    UuidValue.fromString(entityId),
    date,
    lines,
    journalId: journalId == null ? null : UuidValue.fromString(journalId),
    reference: reference,
    narration: narration,
    source: source,
  );

  @override
  Future<void> deleteDraftJournal(String journalId) =>
      _client.ledger.deleteDraftJournal(UuidValue.fromString(journalId));

  @override
  Future<Journal> postJournal(String journalId) =>
      _client.ledger.postJournal(UuidValue.fromString(journalId));

  @override
  Future<Journal> reverseJournal({
    required String journalId,
    required DateTime date,
  }) => _client.ledger.reverseJournal(
    UuidValue.fromString(journalId),
    date,
  );

  @override
  Future<List<Journal>> listJournals(
    String entityId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) => _client.ledger.listJournals(
    UuidValue.fromString(entityId),
    fromDate: fromDate,
    toDate: toDate,
    limit: 200,
  );

  @override
  Future<List<JournalLine>> listJournalLines(String journalId) =>
      _client.ledger.listJournalLines(UuidValue.fromString(journalId));

  @override
  Future<LedgerPeriodLock> setLockDate(String entityId, DateTime lockDate) =>
      _client.ledger.setLockDate(
        UuidValue.fromString(entityId),
        lockDate,
      );

  @override
  Future<LedgerPeriodLock?> getLockDate(String entityId) =>
      _client.ledger.getLockDate(UuidValue.fromString(entityId));

  @override
  Future<TrialBalanceView> trialBalance(String entityId, DateTime asOf) =>
      _client.ledger.trialBalance(UuidValue.fromString(entityId), asOf);
}

@riverpod
LedgerRepository ledgerRepository(Ref ref) =>
    ServerpodLedgerRepository(ref.watch(serverpodClientProvider));
