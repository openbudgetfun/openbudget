import 'dart:async';

import 'package:openbudget_app/src/features/ledger/providers/ledger_repository.dart';
import 'package:openbudget_client/openbudget_client.dart';

const testBudgetId = '00000000-0000-0000-0000-0000000000b001';
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

Budget testBudget({
  String id = testBudgetId,
  String name = 'Studio Budget',
  String currencyCode = 'GBP',
  String accountingMode = 'envelope',
}) => Budget(
  id: UuidValue.fromString(id),
  name: name,
  currencyCode: currencyCode,
  ownerId: UuidValue.fromString(testOwnerId),
  accountingMode: accountingMode,
  createdAt: DateTime.utc(2026),
);

TaxProfileRecord businessTaxProfile({
  String entityKind = 'soleTrader',
  String budgetId = testBudgetId,
}) => TaxProfileRecord(
  id: UuidValue.fromString('00000000-0000-0000-0000-0000000000b003'),
  budgetId: UuidValue.fromString(budgetId),
  jurisdiction: 'GB',
  entityKind: entityKind,
  profileJson: '{"entityKind":"$entityKind"}',
  createdAt: DateTime.utc(2026),
  updatedAt: DateTime.utc(2026, 6),
);

LedgerAccount ledgerAccount({
  String id = bankAccountId,
  String code = '1000',
  String name = 'Bank',
  String type = 'asset',
  bool archived = false,
}) => LedgerAccount(
  id: UuidValue.fromString(id),
  budgetId: UuidValue.fromString(testBudgetId),
  code: code,
  name: name,
  type: type,
  archived: archived,
  createdAt: DateTime.utc(2026),
);

List<LedgerAccount> testChartOfAccounts() => [
  ledgerAccount(),
  ledgerAccount(
    id: salesAccountId,
    code: '4000',
    name: 'Sales',
    type: 'income',
  ),
  ledgerAccount(
    id: officeCostsAccountId,
    code: '5000',
    name: 'Office costs',
    type: 'expense',
  ),
  ledgerAccount(
    id: payablesAccountId,
    code: '2100',
    name: 'Payables',
    type: 'liability',
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
  String status = 'posted',
  String reference = 'JB-2026-0001',
  String? narration = 'Client invoice',
  DateTime? date,
  String? reversalOfJournalId,
}) => Journal(
  id: UuidValue.fromString(id),
  budgetId: UuidValue.fromString(testBudgetId),
  date: date ?? DateTime.utc(2026, 5, 14),
  reference: reference,
  narration: narration,
  status: status,
  postedAt: status == 'draft' ? null : DateTime.utc(2026, 5, 14, 9),
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
    status: 'reversed',
    reference: 'JB-2026-0003',
    narration: 'Mistaken entry',
  ),
  journal(),
  journal(
    id: draftJournalId,
    status: 'draft',
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
  functionalDebitMinor: debit ? amount : 0,
  functionalCreditMinor: debit ? 0 : amount,
  exchangeRate: '1',
  rateDate: DateTime(2026, 5, 14),
  rateSource: 'manual',
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
  functionalDebitMinor: debitMinor,
  functionalCreditMinor: creditMinor,
  exchangeRate: '1',
  rateDate: DateTime.utc(2026, 5, 14),
  rateSource: 'manual',
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
  String type = 'asset',
  int debitMinor = 5000,
  int creditMinor = 0,
}) => TrialBalanceRowView(
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
  budgetId: UuidValue.fromString(testBudgetId),
  currencyCode: currencyCode,
  asOf: asOf ?? DateTime.utc(2026, 11, 5),
  rows:
      rows ??
      [
        trialRow(),
        trialRow(
          code: '4000',
          name: 'Sales',
          type: 'income',
          debitMinor: 0,
          creditMinor: 5000,
        ),
      ],
  totalDebitMinor: totalDebitMinor,
  totalCreditMinor: totalCreditMinor,
);

LedgerPeriodLock testLock({DateTime? lockDate}) => LedgerPeriodLock(
  id: UuidValue.fromString('00000000-0000-0000-0000-0000000000c010'),
  budgetId: UuidValue.fromString(testBudgetId),
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

  final List<String> enabledBudgets = [];
  final List<String> archivedAccounts = [];
  final List<
    ({
      String budgetId,
      DateTime date,
      List<JournalLineInput> lines,
      String? journalId,
      String reference,
      String? narration,
      String source,
    })
  >
  savedDrafts = [];
  final List<String> deletedJournals = [];
  final List<String> postedJournals = [];
  final List<({String journalId, DateTime date})> reversedJournals = [];
  final List<({String budgetId, DateTime lockDate})> lockDates = [];
  final List<({String budgetId, DateTime asOf})> trialBalanceCalls = [];
  final List<({String budgetId, bool includeArchived})> accountCalls = [];
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
      budgetId: UuidValue.fromString(testBudgetId),
      date: DateTime.utc(2026, 5, 14),
      reference: reference,
      narration: narration,
      status: 'draft',
      createdAt: DateTime.utc(2026, 5, 14),
    );
    journals = [...?journals, stored];
    return stored;
  }

  @override
  Future<Budget> enableLedger(String budgetId) async {
    if (enableError != null) throw enableError!;
    enabledBudgets.add(budgetId);
    return testBudget(accountingMode: 'ledger');
  }

  @override
  Future<List<LedgerAccount>> listAccounts(
    String budgetId, {
    required bool includeArchived,
  }) async {
    if (accountsError != null) throw accountsError!;
    accountCalls.add((budgetId: budgetId, includeArchived: includeArchived));
    return accounts ?? testChartOfAccounts();
  }

  @override
  Future<LedgerAccount> createAccount({
    required String budgetId,
    required String code,
    required String name,
    required String type,
    String? systemRole,
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
    required String budgetId,
    required DateTime date,
    required List<JournalLineInput> lines,
    required String reference,
    required String source,
    String? journalId,
    String? narration,
  }) async {
    if (saveError != null) throw saveError!;
    savedDrafts.add((
      budgetId: budgetId,
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
          j.copyWith(status: 'posted', postedAt: DateTime.utc(2026, 5, 14, 9))
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
          j.copyWith(status: 'reversed')
        else
          j,
    ];
    final reversal = Journal(
      id: UuidValue.fromString(
        '00000000-0000-0000-0000-0000000000e$_nextJournalNumber',
      ),
      budgetId: UuidValue.fromString(testBudgetId),
      date: date,
      reference: 'JB-2026-000$_nextJournalNumber',
      status: 'posted',
      reversalOfJournalId: UuidValue.fromString(journalId),
      createdAt: DateTime.utc(2026, 5, 15),
    );
    journals = [...?journals, reversal];
    _nextJournalNumber++;
    return reversal;
  }

  @override
  Future<List<Journal>> listJournals(
    String budgetId, {
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
    String budgetId,
    DateTime lockDate,
  ) async {
    if (lockError != null) throw lockError!;
    lockDates.add((budgetId: budgetId, lockDate: lockDate));
    lock = LedgerPeriodLock(
      id: UuidValue.fromString('00000000-0000-0000-0000-0000000000c010'),
      budgetId: UuidValue.fromString(budgetId),
      lockDate: lockDate,
      setBy: UuidValue.fromString(testOwnerId),
    );
    return lock!;
  }

  @override
  Future<LedgerPeriodLock?> getLockDate(String budgetId) async {
    lockLookups.add(budgetId);
    return lock;
  }

  @override
  Future<TrialBalanceView> trialBalance(String budgetId, DateTime asOf) async {
    if (trialBalanceError != null) throw trialBalanceError!;
    trialBalanceCalls.add((budgetId: budgetId, asOf: asOf));
    return trialBalanceResult ?? trialBalanceView(asOf: asOf);
  }
}
