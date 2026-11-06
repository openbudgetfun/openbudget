import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ledger_repository.g.dart';

/// The ledger API calls the app makes.
///
/// The app depends on this interface rather than the generated client so
/// tests can supply a fake API without a running server. Posted journals
/// have no update or delete path here: corrections go through
/// [reverseJournal].
abstract interface class LedgerRepository {
  Future<Budget> enableLedger(String budgetId);

  Future<List<LedgerAccount>> listAccounts(
    String budgetId, {
    required bool includeArchived,
  });

  Future<LedgerAccount> createAccount({
    required String budgetId,
    required String code,
    required String name,
    required String type,
    String? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
  });

  Future<LedgerAccount> archiveAccount(String accountId);

  Future<Journal> saveDraftJournal({
    required String budgetId,
    required DateTime date,
    required List<JournalLineInput> lines,
    required String reference,
    required String source,
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
    String budgetId, {
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<LedgerPeriodLock> setLockDate(String budgetId, DateTime lockDate);

  Future<TrialBalanceView> trialBalance(String budgetId, DateTime asOf);
}

/// The production [LedgerRepository], backed by the Serverpod client.
class ServerpodLedgerRepository implements LedgerRepository {
  const ServerpodLedgerRepository(this._client);

  final Client _client;

  @override
  Future<Budget> enableLedger(String budgetId) =>
      _client.ledger.enableLedger(UuidValue.fromString(budgetId));

  @override
  Future<List<LedgerAccount>> listAccounts(
    String budgetId, {
    required bool includeArchived,
  }) => _client.ledger.listAccounts(
    UuidValue.fromString(budgetId),
    includeArchived: includeArchived,
  );

  @override
  Future<LedgerAccount> createAccount({
    required String budgetId,
    required String code,
    required String name,
    required String type,
    String? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
  }) => _client.ledger.createAccount(
    UuidValue.fromString(budgetId),
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
    required String budgetId,
    required DateTime date,
    required List<JournalLineInput> lines,
    required String reference,
    required String source,
    String? journalId,
    String? narration,
  }) => _client.ledger.saveDraftJournal(
    UuidValue.fromString(budgetId),
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
    String budgetId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) => _client.ledger.listJournals(
    UuidValue.fromString(budgetId),
    fromDate: fromDate,
    toDate: toDate,
  );

  @override
  Future<LedgerPeriodLock> setLockDate(String budgetId, DateTime lockDate) =>
      _client.ledger.setLockDate(
        UuidValue.fromString(budgetId),
        lockDate,
      );

  @override
  Future<TrialBalanceView> trialBalance(String budgetId, DateTime asOf) =>
      _client.ledger.trialBalance(UuidValue.fromString(budgetId), asOf);
}

@riverpod
LedgerRepository ledgerRepository(Ref ref) =>
    ServerpodLedgerRepository(ref.watch(serverpodClientProvider));
