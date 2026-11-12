import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_repository.dart';
import 'package:openbudget_app/src/features/ledger/screens/books_screen.dart';
import 'package:openbudget_app/src/features/ledger/screens/journal_detail_screen.dart';
import 'package:openbudget_app/src/features/ledger/screens/journal_editor_screen.dart';
import 'package:openbudget_app/src/features/more/screens/more_screen.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

const String _entityId = TestData.companyEntityId;
final UuidValue _entityUuid = UuidValue.fromString(_entityId);
final UuidValue _ownerUuid = UuidValue.fromString(TestData.ownerId);

const String _bankAccountId = '00000000-0000-0000-0000-000000000911';
const String _salesAccountId = '00000000-0000-0000-0000-000000000912';

/// Flipped by the fake [LedgerRepository.enableLedger], so the entity the
/// More screen reads switches to ledger books mid-flow.
// Flipped by the fake enableLedger, so the entity the More screen reads
// switches to ledger books mid-flow.
AccountingMode _accountingMode = AccountingMode.envelope;

Entity _makeEntity() => Entity(
  id: _entityUuid,
  name: TestData.companyEntityName,
  kind: EntityKind.company,
  countryCode: 'GB',
  baseCurrencyCode: 'GBP',
  timeZone: 'Europe/London',
  accountingMode: _accountingMode,
  fiscalYearEndMonth: 4,
  fiscalYearEndDay: 5,
  ownerId: _ownerUuid,
  createdAt: DateTime.utc(2026),
);

/// The month view the journal editor reads its functional currency from.
BudgetMonthView _makeMonthView() => BudgetMonthView(
  entityId: _entityUuid,
  month: 202611,
  currencyCode: 'GBP',
  summary: BudgetMonthSummary(
    month: 202611,
    incomeMinor: 0,
    uncategorizedMinor: 0,
    fxDifferenceMinor: 0,
    allocatedMinor: 0,
    activityMinor: 0,
    overspentLastMonthMinor: 0,
    assignedInFutureMinor: 0,
    readyToAssignMinor: 0,
    availableMinor: 0,
  ),
  categories: const [],
  envelopes: const [],
);

LedgerAccount _account(
  String id,
  String code,
  String name,
  LedgerAccountType type,
) => LedgerAccount(
  id: UuidValue.fromString(id),
  entityId: _entityUuid,
  code: code,
  name: name,
  type: type,
  createdAt: DateTime.utc(2026),
);

/// A fake books backend: stores drafts, lines and postings in memory and
/// computes the trial balance from its posted journals, so the flow sees
/// the entries it made.
class FakeBooksRepository implements LedgerRepository {
  final accounts = <LedgerAccount>[
    _account(_bankAccountId, '1000', 'Bank', LedgerAccountType.asset),
    _account(_salesAccountId, '4000', 'Sales', LedgerAccountType.income),
  ];
  final journals = <Journal>[];
  final linesByJournal = <String, List<JournalLineInput>>{};

  /// Every journal id passed to [saveDraftJournal], in call order.
  final savedJournalIds = <String?>[];

  LedgerPeriodLock? lock;

  int nextJournalNumber = 1;

  @override
  Future<Entity> enableLedger(String entityId) async {
    _accountingMode = AccountingMode.ledger;
    return _makeEntity();
  }

  @override
  Future<List<LedgerAccount>> listAccounts(
    String entityId, {
    required bool includeArchived,
  }) async => accounts;

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
  Future<LedgerAccount> archiveAccount(String accountId) =>
      throw UnimplementedError();

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
    savedJournalIds.add(journalId);
    if (journalId != null) {
      // Replacing a draft keeps its id and rewrites its lines.
      final index = journals.indexWhere((j) => j.id?.toString() == journalId);
      if (index != -1) {
        journals[index] = journals[index]
          ..date = date
          ..reference = reference
          ..narration = narration;
        linesByJournal[journalId] = lines;
        return journals[index];
      }
    }
    final stored = Journal(
      id: UuidValue.fromString(
        '00000000-0000-0000-0000-0000000009${nextJournalNumber.toString().padLeft(2, '0')}',
      ),
      entityId: _entityUuid,
      date: date,
      reference: reference,
      narration: narration,
      status: JournalStatus.draft,
      createdAt: DateTime.utc(2026),
    );
    nextJournalNumber++;
    journals.insert(0, stored);
    linesByJournal[stored.id!.toString()] = lines;
    return stored;
  }

  @override
  Future<void> deleteDraftJournal(String journalId) async {
    journals.removeWhere((j) => j.id?.toString() == journalId);
    linesByJournal.remove(journalId);
  }

  @override
  Future<Journal> postJournal(String journalId) async =>
      journals.firstWhere((j) => j.id?.toString() == journalId)
        ..status = JournalStatus.posted
        ..postedAt = DateTime.utc(2026, 11, 6, 9);

  @override
  Future<Journal> reverseJournal({
    required String journalId,
    required DateTime date,
  }) async {
    journals.firstWhere((j) => j.id?.toString() == journalId).status =
        JournalStatus.reversed;
    final reversal = Journal(
      id: UuidValue.fromString(
        '00000000-0000-0000-0000-0000000009${nextJournalNumber.toString().padLeft(2, '0')}',
      ),
      entityId: _entityUuid,
      date: date,
      reference: 'JB-2026-000${nextJournalNumber + 1}',
      status: JournalStatus.posted,
      reversalOfJournalId: UuidValue.fromString(journalId),
      createdAt: DateTime.utc(2026, 11, 6),
    );
    nextJournalNumber++;
    journals.insert(0, reversal);
    nextJournalNumber++;
    linesByJournal[reversal.id!.toString()] = [
      for (final line in linesByJournal[journalId]!)
        JournalLineInput(
          ledgerAccountId: line.ledgerAccountId,
          currencyCode: line.currencyCode,
          debitMinor: line.creditMinor,
          creditMinor: line.debitMinor,
          baseDebitMinor: line.baseCreditMinor,
          baseCreditMinor: line.baseDebitMinor,
          fxRate: line.fxRate,
          fxRateDate: date,
          fxRateSource: FxRateSource.manual,
        ),
    ];
    return reversal;
  }

  @override
  Future<List<Journal>> listJournals(
    String entityId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async => journals;

  /// Returns the stored inputs as the [JournalLine] rows the server would
  /// persist, so the editor and detail screens read back what was saved.
  @override
  Future<List<JournalLine>> listJournalLines(String journalId) async => [
    for (final (index, line)
        in (linesByJournal[journalId] ?? const <JournalLineInput>[]).indexed)
      JournalLine(
        id: UuidValue.fromString(
          '00000000-0000-0000-0000-0000000009${(index + 1).toString().padLeft(2, '0')}',
        ),
        journalId: UuidValue.fromString(journalId),
        ledgerAccountId: line.ledgerAccountId,
        debitMinor: line.debitMinor,
        creditMinor: line.creditMinor,
        currencyCode: line.currencyCode,
        fxRateDate: line.fxRateDate ?? DateTime.utc(2026),
        baseDebitMinor: line.baseDebitMinor,
        baseCreditMinor: line.baseCreditMinor,
        fxRate: line.fxRate,
      ),
  ];

  @override
  Future<LedgerPeriodLock> setLockDate(
    String entityId,
    DateTime lockDate,
  ) async => lock = LedgerPeriodLock(
    id: UuidValue.fromString('00000000-0000-0000-0000-000000000904'),
    entityId: _entityUuid,
    lockDate: lockDate,
    setBy: _ownerUuid,
  );

  @override
  Future<LedgerPeriodLock?> getLockDate(String entityId) async => lock;

  @override
  Future<TrialBalanceView> trialBalance(String entityId, DateTime asOf) async {
    final debitByAccount = <String, int>{};
    final creditByAccount = <String, int>{};
    var totalDebit = 0;
    var totalCredit = 0;

    for (final journal in journals) {
      // Posted journals keep their lines while reversed; the reversal's own
      // posted lines undo them.
      if (journal.status != JournalStatus.posted &&
          journal.status != JournalStatus.reversed) {
        continue;
      }
      if (journal.date.isAfter(asOf)) continue;
      for (final line in linesByJournal[journal.id!.toString()]!) {
        final account = accounts.firstWhere(
          (a) => a.id == line.ledgerAccountId,
        );
        debitByAccount[account.code] =
            (debitByAccount[account.code] ?? 0) + line.debitMinor;
        creditByAccount[account.code] =
            (creditByAccount[account.code] ?? 0) + line.creditMinor;
        totalDebit += line.debitMinor;
        totalCredit += line.creditMinor;
      }
    }
    if (totalDebit != totalCredit) {
      throw Exception('Trial balance is out by ${totalDebit - totalCredit}.');
    }

    final rows = [
      for (final code in debitByAccount.keys.toList()..sort())
        TrialBalanceRowView(
          ledgerAccountId: accounts.firstWhere((a) => a.code == code).id!,
          accountCode: code,
          accountName: accounts.firstWhere((a) => a.code == code).name,
          accountType: accounts.firstWhere((a) => a.code == code).type,
          debitMinor: debitByAccount[code] ?? 0,
          creditMinor: creditByAccount[code] ?? 0,
          netMinor: (debitByAccount[code] ?? 0) - (creditByAccount[code] ?? 0),
        ),
    ];
    return TrialBalanceView(
      entityId: _entityUuid,
      currencyCode: 'GBP',
      asOf: asOf,
      rows: rows,
      totalDebitMinor: totalDebit,
      totalCreditMinor: totalCredit,
    );
  }
}

/// The books tile gates on the entity alone now; the fake answers the
/// lookups the screens make while the flow runs.
class FakeCompanyTaxRepository implements TaxRepository {
  @override
  Future<TaxProfileRecord?> getProfile(String entityId) async => null;

  @override
  Future<TaxProfileRecord> saveProfile({
    required String entityId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
  }) => throw UnimplementedError();

  @override
  Future<List<TaxCategoryView>> listCategories(String entityId) =>
      throw UnimplementedError();

  @override
  Future<Envelope> setEnvelopeTaxCategory({
    required String envelopeId,
    String? code,
  }) => throw UnimplementedError();

  @override
  Future<TransactionView> setLineTax({
    required String transactionLineId,
    String? code,
    int? businessUsePercent,
    int? salesTaxMinor,
  }) => throw UnimplementedError();

  @override
  Future<TaxReportView> getReport(String entityId, int startYear) =>
      throw UnimplementedError();
}

Widget _buildApp(FakeBooksRepository books) {
  final router = GoRouter(
    initialLocation: morePath.replaceFirst(':entityId', _entityId),
    routes: [
      GoRoute(
        name: moreRoute,
        path: morePath,
        builder: (context, state) =>
            MoreScreen(entityId: state.pathParameters['entityId']!),
      ),
      GoRoute(
        name: booksRoute,
        path: booksPath,
        builder: (context, state) =>
            BooksScreen(entityId: state.pathParameters['entityId']!),
        routes: [
          GoRoute(
            name: journalNewRoute,
            path: 'journals/new',
            builder: (context, state) => JournalEditorScreen(
              entityId: state.pathParameters['entityId']!,
            ),
          ),
          GoRoute(
            name: journalEditRoute,
            path: 'journals/:journalId/edit',
            builder: (context, state) => JournalEditorScreen(
              entityId: state.pathParameters['entityId']!,
              journalId: state.pathParameters['journalId'],
            ),
          ),
          GoRoute(
            name: journalDetailRoute,
            path: 'journals/:journalId',
            builder: (context, state) => JournalDetailScreen(
              entityId: state.pathParameters['entityId']!,
              journalId: state.pathParameters['journalId']!,
            ),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      entityDetailProvider.overrideWith((ref, id) async => _makeEntity()),
      budgetMonthProvider.overrideWith(
        (ref, entityId) async => _makeMonthView(),
      ),
      taxRepositoryProvider.overrideWithValue(FakeCompanyTaxRepository()),
      ledgerRepositoryProvider.overrideWithValue(books),
    ],
    child: MaterialApp.router(
      theme: OpenBudgetTheme.light,
      darkTheme: OpenBudgetTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  patrolWidgetTest(
    'enables books on a company entity, posts a journal, sees the trial '
    'balance and reverses the journal',
    ($) async {
      final tester = $.tester;
      final books = FakeBooksRepository();
      await tester.pumpWidget(_buildApp(books));
      await tester.pumpAndSettle();

      final more = MoreTabPage(tester);
      expect(more.enableBooksTile, findsOneWidget);

      await tester.tap(more.enableBooksTile);
      await tester.pumpAndSettle();
      expect(find.textContaining('one-way'), findsOneWidget);

      await tester.tap(find.text(TestData.booksEnableConfirm));
      await tester.pumpAndSettle();

      expect(find.text(TestData.booksEnabledToast), findsOneWidget);

      final booksTab = BooksTabPage(tester);
      expect(booksTab.journalsTab, findsOneWidget);

      // Record a balanced journal.
      await tester.tap(booksTab.newJournalButton);
      await tester.pumpAndSettle();

      final editor = JournalEditorPage(tester);
      expect(editor.title, findsOneWidget);
      await editor.setReference(TestData.journalReference);
      await editor.setNarration(TestData.journalNarration);
      await editor.fillBalanced();
      await editor.scrollToTotals();
      expect(editor.balancedChip, findsOneWidget);

      await tester.tap(editor.postButton);
      await tester.pumpAndSettle();
      expect(editor.postDialog, findsOneWidget);
      await tester.tap(editor.postConfirmButton);
      await tester.pumpAndSettle();

      expect(books.journals.single.status, JournalStatus.posted);

      // The posted journal shows in the trial balance.
      await booksTab.openTrialBalance();
      await tester.pumpAndSettle();

      expect(booksTab.balancedChip, findsOneWidget);
      expect(find.text(TestData.bankAccountRow), findsOneWidget);
      expect(find.textContaining(TestData.journalAmount), findsWidgets);

      // Reverse it from the read-only journal, whose lines are shown.
      await booksTab.openJournals(tester);
      await tester.pumpAndSettle();
      await tester.tap(booksTab.journalTile(TestData.journalReference));
      await tester.pumpAndSettle();

      final detail = JournalDetailPage(tester);
      expect(detail.postedChip, findsOneWidget);
      expect(detail.readOnlyNote, findsOneWidget);

      await detail.scrollToLines();
      expect(detail.linesCard, findsOneWidget);
      expect(find.text('1000'), findsOneWidget);
      expect(find.text(TestData.bankAccountRow), findsOneWidget);
      expect(find.text('4000'), findsOneWidget);
      expect(find.text(TestData.salesAccountRow), findsOneWidget);
      expect(find.textContaining(TestData.journalAmount), findsWidgets);
      expect(detail.totalsRow(0), findsOneWidget);

      await tester.tap(detail.reverseButton);
      await tester.pumpAndSettle();
      expect(detail.reverseDialog, findsOneWidget);
      await tester.tap(detail.reverseConfirmButton);
      await tester.pumpAndSettle();

      expect(detail.reversedChip, findsOneWidget);
      // The fake keeps the reversal entry in front; name both journals by
      // their role so the assertion does not depend on list order.
      final original = books.journals.singleWhere(
        (j) => j.reversalOfJournalId == null,
      );
      final reversal = books.journals.singleWhere(
        (j) => j.reversalOfJournalId != null,
      );
      expect(original.status, JournalStatus.reversed);
      expect(reversal.status, JournalStatus.posted);
      expect(reversal.reversalOfJournalId?.toString(), original.id?.toString());

      // A saved draft reopens with its stored lines and re-save replaces
      // the same draft instead of creating a second one.
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(booksTab.newJournalButton);
      await tester.pumpAndSettle();

      await editor.setReference(TestData.draftJournalReference);
      await editor.fillBalanced();
      await editor.scrollToTotals();
      expect(editor.balancedChip, findsOneWidget);
      await tester.tap(editor.saveDraftButton);
      await tester.pumpAndSettle();

      expect(books.savedJournalIds.last, isNull);
      final draftId = books.journals.first.id!.toString();
      await tester.tap(booksTab.journalTile(TestData.draftJournalReference));
      await tester.pumpAndSettle();

      expect(find.text('Draft'), findsOneWidget);
      await detail.scrollToLines();
      expect(detail.linesCard, findsOneWidget);
      expect(find.textContaining(TestData.journalAmount), findsWidgets);
      expect(detail.editButton, findsOneWidget);
      expect(detail.deleteButton, findsOneWidget);

      await tester.tap(detail.editButton);
      await tester.pumpAndSettle();

      expect(editor.editTitle, findsOneWidget);
      expect(editor.referenceValue(), TestData.draftJournalReference);
      expect(editor.lineAmountValue(0), TestData.journalAmount);
      expect(editor.lineAmountValue(1), TestData.journalAmount);

      await editor.scrollToTotals();
      expect(editor.balancedChip, findsOneWidget);
      await tester.tap(editor.saveDraftButton);
      await tester.pumpAndSettle();

      expect(books.savedJournalIds.last, draftId);
      expect(books.journals, hasLength(3));
      expect(
        books.journals.where((j) => j.id?.toString() == draftId),
        hasLength(1),
      );
      expect(find.text('Draft'), findsOneWidget);
    },
  );
}
