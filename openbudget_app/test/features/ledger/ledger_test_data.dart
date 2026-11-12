import 'dart:async';

import 'package:openbudget_app/src/features/ledger/providers/ledger_repository.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

const testEntityId = '00000000-0000-0000-0000-0000000000b001';

/// Kept for the screens that still spell the id `testBudgetId`.
const String testBudgetId = testEntityId;
const testOwnerId = '00000000-0000-0000-0000-0000000000b002';

const bankAccountId = '00000000-0000-0000-0000-0000000000b101';
const salesAccountId = '00000000-0000-0000-0000-0000000000b102';
const officeCostsAccountId = '00000000-0000-0000-0000-0000000000b103';
const archivedAccountId = '00000000-0000-0000-0000-0000000000b104';
const payablesAccountId = '00000000-0000-0000-0000-0000000000b105';

const draftJournalId = '00000000-0000-0000-0000-0000000000c001';
const postedJournalId = '00000000-0000-0000-0000-0000000000c002';
const reversedJournalId = '00000000-0000-0000-0000-0000000000c003';
const reversalJournalId = '00000000-0000-0000-0000-0000000000c004';

Entity testEntity({
  String id = testEntityId,
  String name = 'Studio Budget',
  String baseCurrencyCode = 'GBP',
  AccountingMode accountingMode = AccountingMode.envelope,
  EntityKind kind = EntityKind.soleTrader,
}) => Entity(
  id: UuidValue.fromString(id),
  name: name,
  kind: kind,
  countryCode: 'GB',
  baseCurrencyCode: baseCurrencyCode,
  timeZone: 'Europe/London',
  accountingMode: accountingMode,
  fiscalYearEndMonth: 4,
  fiscalYearEndDay: 5,
  ownerId: UuidValue.fromString(testOwnerId),
  createdAt: DateTime.utc(2026),
);

TaxProfileRecord businessTaxProfile({
  EntityKind entityKind = EntityKind.soleTrader,
  String entityId = testEntityId,
}) => TaxProfileRecord(
  id: UuidValue.fromString('00000000-0000-0000-0000-0000000000b003'),
  entityId: UuidValue.fromString(entityId),
  profileJson: '{"jurisdiction":"GB","entityKind":"${entityKind.name}"}',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026, 6),
);

LedgerAccount ledgerAccount({
  String id = bankAccountId,
  String code = '1000',
  String name = 'Bank',
  LedgerAccountType type = LedgerAccountType.asset,
  bool archived = false,
}) => LedgerAccount(
  id: UuidValue.fromString(id),
  entityId: UuidValue.fromString(testEntityId),
  code: code,
  name: name,
  type: type,
  archivedAt: archived ? DateTime.utc(2026, 8) : null,
  createdAt: DateTime.utc(2026),
);

List<LedgerAccount> testChartOfAccounts() => [
  ledgerAccount(),
  ledgerAccount(
    id: salesAccountId,
    code: '4000',
    name: 'Sales',
    type: LedgerAccountType.income,
  ),
  ledgerAccount(
    id: officeCostsAccountId,
    code: '5000',
    name: 'Office costs',
    type: LedgerAccountType.expense,
  ),
  ledgerAccount(
    id: payablesAccountId,
    code: '2100',
    name: 'Payables',
    type: LedgerAccountType.liability,
  ),
  ledgerAccount(
    id: archivedAccountId,
    code: '1900',
    name: 'Old suspense',
    archived: true,
  ),
];

Journal journal({
  String id = postedJournalId,
  JournalStatus status = JournalStatus.posted,
  String reference = 'JB-2026-0001',
  String? narration = 'Client invoice',
  DateTime? date,
  String? reversalOfJournalId,
}) => Journal(
  id: UuidValue.fromString(id),
  entityId: UuidValue.fromString(testEntityId),
  date: date ?? DateTime.utc(2026, 5, 14),
  reference: reference,
  narration: narration,
  status: status,
  postedAt: status == JournalStatus.draft ? null : DateTime.utc(2026, 5, 14, 9),
  reversalOfJournalId: reversalOfJournalId == null
      ? null
      : UuidValue.fromString(reversalOfJournalId),
  createdAt: DateTime.utc(2026, 5, 14),
);

List<Journal> testJournals() => [
  // Newest first, matching the API's ordering.
  journal(
    id: reversalJournalId,
    reference: 'JB-2026-0004',
    narration: 'Reversal',
    reversalOfJournalId: reversedJournalId,
  ),
  journal(
    id: reversedJournalId,
    status: JournalStatus.reversed,
    reference: 'JB-2026-0003',
    narration: 'Mistaken entry',
  ),
  journal(),
  journal(
    id: draftJournalId,
    status: JournalStatus.draft,
    reference: 'JB-2026-0002',
    narration: 'Not finished',
  ),
];

JournalLineInput testLineInput({
  String accountId = bankAccountId,
  bool debit = true,
  int amount = 5000,
}) => JournalLineInput(
  ledgerAccountId: UuidValue.fromString(accountId),
  currencyCode: 'GBP',
  debitMinor: debit ? amount : 0,
  creditMinor: debit ? 0 : amount,
  baseDebitMinor: debit ? amount : 0,
  baseCreditMinor: debit ? 0 : amount,
  fxRateDate: DateTime(2026, 5, 14),
);

JournalLine journalLine({
  String id = '00000000-0000-0000-0000-0000000000c101',
  String journalId = postedJournalId,
  String accountId = bankAccountId,
  int debitMinor = 5000,
  int creditMinor = 0,
  String currencyCode = 'GBP',
}) => JournalLine(
  id: UuidValue.fromString(id),
  journalId: UuidValue.fromString(journalId),
  ledgerAccountId: UuidValue.fromString(accountId),
  description: creditMinor == 0 ? null : 'Sales',
  debitMinor: debitMinor,
  creditMinor: creditMinor,
  currencyCode: currencyCode,
  baseDebitMinor: debitMinor,
  baseCreditMinor: creditMinor,
  fxRateDate: DateTime.utc(2026, 5, 14),
);

/// The balanced £50.00 pair the test journals were posted with.
List<JournalLine> testJournalLines({String journalId = postedJournalId}) => [
  journalLine(journalId: journalId),
  journalLine(
    id: '00000000-0000-0000-0000-0000000000c111',
    journalId: journalId,
    accountId: salesAccountId,
    debitMinor: 0,
    creditMinor: 5000,
  ),
];

TrialBalanceRowView trialRow({
  String code = '1000',
  String name = 'Bank',
  LedgerAccountType type = LedgerAccountType.asset,
  int debitMinor = 5000,
  int creditMinor = 0,
  String accountId = bankAccountId,
}) => TrialBalanceRowView(
  ledgerAccountId: UuidValue.fromString(accountId),
  accountCode: code,
  accountName: name,
  accountType: type,
  debitMinor: debitMinor,
  creditMinor: creditMinor,
  netMinor: debitMinor - creditMinor,
);

TrialBalanceView trialBalanceView({
  List<TrialBalanceRowView>? rows,
  int totalDebitMinor = 5000,
  int totalCreditMinor = 5000,
  String currencyCode = 'GBP',
  DateTime? asOf,
}) => TrialBalanceView(
  entityId: UuidValue.fromString(testEntityId),
  currencyCode: currencyCode,
  asOf: asOf ?? DateTime.utc(2026, 11, 5),
  rows:
      rows ??
      [
        trialRow(),
        trialRow(
          code: '4000',
          name: 'Sales',
          type: LedgerAccountType.income,
          debitMinor: 0,
          creditMinor: 5000,
          accountId: salesAccountId,
        ),
      ],
  totalDebitMinor: totalDebitMinor,
  totalCreditMinor: totalCreditMinor,
);

LedgerPeriodLock testLock({DateTime? lockDate}) => LedgerPeriodLock(
  id: UuidValue.fromString('00000000-0000-0000-0000-0000000000c010'),
  entityId: UuidValue.fromString(testEntityId),
  lockDate: lockDate ?? DateTime.utc(2026, 10, 31),
  setBy: UuidValue.fromString(testOwnerId),
);

/// An in-memory [LedgerRepository] for widget and provider tests.
class FakeLedgerRepository implements LedgerRepository {
  FakeLedgerRepository({
    this.accounts,
    this.journals,
    this.journalLines,
    this.trialBalanceResult,
    this.lock,
    this.enableError,
    this.accountsError,
    this.journalsError,
    this.linesError,
    this.trialBalanceError,
    this.saveError,
    this.deleteError,
    this.postError,
    this.reverseError,
    this.lockError,
  });

  List<LedgerAccount>? accounts;
  List<Journal>? journals;
  Map<String, List<JournalLine>>? journalLines;
  TrialBalanceView? trialBalanceResult;
  LedgerPeriodLock? lock;
  Exception? enableError;
  Exception? accountsError;
  Exception? journalsError;
  Exception? linesError;
  Exception? trialBalanceError;
  Exception? saveError;
  Exception? deleteError;
  Exception? postError;
  Exception? reverseError;
  Exception? lockError;

  /// When set, every [listJournalLines] call waits on it, so tests control
  /// exactly when the lines arrive.
  Completer<List<JournalLine>>? linesCompleter;

  final List<String> enabledEntities = [];
  final List<String> archivedAccounts = [];
  final List<
    ({
      String entityId,
      DateTime date,
      List<JournalLineInput> lines,
      String? journalId,
      String reference,
      String? narration,
      JournalSource source,
    })
  >
  savedDrafts = [];
  final List<String> deletedJournals = [];
  final List<String> postedJournals = [];
  final List<({String journalId, DateTime date})> reversedJournals = [];
  final List<({String entityId, DateTime lockDate})> lockDates = [];
  final List<({String entityId, DateTime asOf})> trialBalanceCalls = [];
  final List<({String entityId, bool includeArchived})> accountCalls = [];
  final List<String> lineCalls = [];
  final List<String> lockLookups = [];

  int _nextJournalNumber = 10;

  Journal _recordDraft({
    required String journalId,
    required String reference,
    String? narration,
  }) {
    final stored = Journal(
      id: UuidValue.fromString(journalId),
      entityId: UuidValue.fromString(testEntityId),
      date: DateTime.utc(2026, 5, 14),
      reference: reference,
      narration: narration,
      status: JournalStatus.draft,
      createdAt: DateTime.utc(2026, 5, 14),
    );
    journals = [...?journals, stored];
    return stored;
  }

  @override
  Future<Entity> enableLedger(String entityId) async {
    if (enableError != null) throw enableError!;
    enabledEntities.add(entityId);
    return testEntity(accountingMode: AccountingMode.ledger);
  }

  @override
  Future<List<LedgerAccount>> listAccounts(
    String entityId, {
    required bool includeArchived,
  }) async {
    if (accountsError != null) throw accountsError!;
    accountCalls.add((entityId: entityId, includeArchived: includeArchived));
    return accounts ?? testChartOfAccounts();
  }

  @override
  Future<LedgerAccount> createAccount({
    required String entityId,
    required String code,
    required String name,
    required LedgerAccountType type,
    LedgerSystemRole? systemRole,
    String? currencyCode,
    String? taxCategoryCode,
  }) => throw UnimplementedError();

  @override
  Future<LedgerAccount> archiveAccount(String accountId) async {
    archivedAccounts.add(accountId);
    return ledgerAccount(id: accountId, archived: true);
  }

  @override
  Future<Journal> saveDraftJournal({
    required String entityId,
    required DateTime date,
    required List<JournalLineInput> lines,
    required String reference,
    required JournalSource source,
    String? journalId,
    String? narration,
  }) async {
    if (saveError != null) throw saveError!;
    savedDrafts.add((
      entityId: entityId,
      date: date,
      lines: lines,
      journalId: journalId,
      reference: reference,
      narration: narration,
      source: source,
    ));
    final resolvedId =
        journalId ?? '00000000-0000-0000-0000-0000000000d$_nextJournalNumber';
    _nextJournalNumber++;
    return _recordDraft(
      journalId: resolvedId,
      reference: reference,
      narration: narration,
    )..date = date;
  }

  @override
  Future<void> deleteDraftJournal(String journalId) async {
    if (deleteError != null) throw deleteError!;
    deletedJournals.add(journalId);
    journals = [
      ...(journals ?? testJournals()).where(
        (j) => j.id?.toString() != journalId,
      ),
    ];
  }

  @override
  Future<Journal> postJournal(String journalId) async {
    if (postError != null) throw postError!;
    postedJournals.add(journalId);
    journals = [
      for (final j in journals ?? testJournals())
        if (j.id?.toString() == journalId)
          j.copyWith(
            status: JournalStatus.posted,
            postedAt: DateTime.utc(2026, 5, 14, 9),
          )
        else
          j,
    ];
    return journals!.firstWhere((j) => j.id?.toString() == journalId);
  }

  @override
  Future<Journal> reverseJournal({
    required String journalId,
    required DateTime date,
  }) async {
    if (reverseError != null) throw reverseError!;
    reversedJournals.add((journalId: journalId, date: date));
    journals = [
      for (final j in journals ?? testJournals())
        if (j.id?.toString() == journalId)
          j.copyWith(status: JournalStatus.reversed)
        else
          j,
    ];
    final reversal = Journal(
      id: UuidValue.fromString(
        '00000000-0000-0000-0000-0000000000e$_nextJournalNumber',
      ),
      entityId: UuidValue.fromString(testEntityId),
      date: date,
      reference: 'JB-2026-000$_nextJournalNumber',
      status: JournalStatus.posted,
      reversalOfJournalId: UuidValue.fromString(journalId),
      createdAt: DateTime.utc(2026, 5, 15),
    );
    journals = [...?journals, reversal];
    _nextJournalNumber++;
    return reversal;
  }

  @override
  Future<List<Journal>> listJournals(
    String entityId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (journalsError != null) throw journalsError!;
    return journals ?? testJournals();
  }

  @override
  Future<List<JournalLine>> listJournalLines(String journalId) async {
    if (linesError != null) throw linesError!;
    lineCalls.add(journalId);
    if (linesCompleter != null) return linesCompleter!.future;
    final stored = journalLines?[journalId];
    if (stored != null) return stored;
    return testJournalLines(journalId: journalId);
  }

  @override
  Future<LedgerPeriodLock> setLockDate(
    String entityId,
    DateTime lockDate,
  ) async {
    if (lockError != null) throw lockError!;
    lockDates.add((entityId: entityId, lockDate: lockDate));
    lock = LedgerPeriodLock(
      id: UuidValue.fromString('00000000-0000-0000-0000-0000000000c010'),
      entityId: UuidValue.fromString(entityId),
      lockDate: lockDate,
      setBy: UuidValue.fromString(testOwnerId),
    );
    return lock!;
  }

  @override
  Future<LedgerPeriodLock?> getLockDate(String entityId) async {
    lockLookups.add(entityId);
    return lock;
  }

  @override
  Future<TrialBalanceView> trialBalance(String entityId, DateTime asOf) async {
    if (trialBalanceError != null) throw trialBalanceError!;
    trialBalanceCalls.add((entityId: entityId, asOf: asOf));
    return trialBalanceResult ?? trialBalanceView(asOf: asOf);
  }
}
