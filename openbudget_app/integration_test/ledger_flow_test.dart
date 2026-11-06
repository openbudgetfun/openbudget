import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/ledger/providers/ledger_repository.dart';
import 'package:openbudget_app/src/features/ledger/screens/books_screen.dart';
import 'package:openbudget_app/src/features/ledger/screens/journal_detail_screen.dart';
import 'package:openbudget_app/src/features/ledger/screens/journal_editor_screen.dart';
import 'package:openbudget_app/src/features/more/screens/more_screen.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_repository.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

const _budgetId = '00000000-0000-0000-0000-000000000901';
final _budgetUuid = UuidValue.fromString(_budgetId);
final _ownerUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000902',
);

const _bankAccountId = '00000000-0000-0000-0000-000000000911';
const _salesAccountId = '00000000-0000-0000-0000-000000000912';

var _accountingMode = 'envelope';

Budget _makeBudget() => Budget(
  id: _budgetUuid,
  name: TestData.companyBudgetName,
  currencyCode: 'GBP',
  ownerId: _ownerUuid,
  accountingMode: _accountingMode,
  createdAt: DateTime.utc(2026),
);

LedgerAccount _account(String id, String code, String name, String type) =>
    LedgerAccount(
      id: UuidValue.fromString(id),
      budgetId: _budgetUuid,
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
    _account(_bankAccountId, '1000', 'Bank', 'asset'),
    _account(_salesAccountId, '4000', 'Sales', 'income'),
  ];
  final journals = <Journal>[];
  final linesByJournal = <String, List<JournalLineInput>>{};

  int nextJournalNumber = 1;

  @override
  Future<Budget> enableLedger(String budgetId) async {
    _accountingMode = 'ledger';
    return _makeBudget();
  }

  @override
  Future<List<LedgerAccount>> listAccounts(
    String budgetId, {
    required bool includeArchived,
  }) async => accounts;

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
  Future<LedgerAccount> archiveAccount(String accountId) =>
      throw UnimplementedError();

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
    final stored = Journal(
      id: UuidValue.fromString(
        '00000000-0000-0000-0000-0000000009${nextJournalNumber.toString().padLeft(2, '0')}',
      ),
      budgetId: _budgetUuid,
      date: date,
      reference: reference,
      narration: narration,
      status: 'draft',
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
        ..status = 'posted'
        ..postedAt = DateTime.utc(2026, 11, 6, 9);

  @override
  Future<Journal> reverseJournal({
    required String journalId,
    required DateTime date,
  }) async {
    journals.firstWhere((j) => j.id?.toString() == journalId).status =
        'reversed';
    final reversal = Journal(
      id: UuidValue.fromString(
        '00000000-0000-0000-0000-0000000009${nextJournalNumber.toString().padLeft(2, '0')}',
      ),
      budgetId: _budgetUuid,
      date: date,
      reference: 'JB-2026-000${nextJournalNumber + 1}',
      status: 'posted',
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
          functionalDebitMinor: line.functionalCreditMinor,
          functionalCreditMinor: line.functionalDebitMinor,
          exchangeRate: line.exchangeRate,
          rateDate: date,
          rateSource: 'manual',
        ),
    ];
    return reversal;
  }

  @override
  Future<List<Journal>> listJournals(
    String budgetId, {
    DateTime? fromDate,
    DateTime? toDate,
  }) async => journals;

  @override
  Future<LedgerPeriodLock> setLockDate(
    String budgetId,
    DateTime lockDate,
  ) => throw UnimplementedError();

  @override
  Future<TrialBalanceView> trialBalance(String budgetId, DateTime asOf) async {
    final debitByAccount = <String, int>{};
    final creditByAccount = <String, int>{};
    var totalDebit = 0;
    var totalCredit = 0;

    for (final journal in journals) {
      // Posted journals keep their lines while reversed; the reversal's own
      // posted lines undo them.
      if (journal.status != 'posted' && journal.status != 'reversed') {
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
          accountCode: code,
          accountName: accounts.firstWhere((a) => a.code == code).name,
          accountType: accounts.firstWhere((a) => a.code == code).type,
          debitMinor: debitByAccount[code] ?? 0,
          creditMinor: creditByAccount[code] ?? 0,
          netMinor: (debitByAccount[code] ?? 0) - (creditByAccount[code] ?? 0),
        ),
    ];
    return TrialBalanceView(
      budgetId: _budgetUuid,
      currencyCode: 'GBP',
      asOf: asOf,
      rows: rows,
      totalDebitMinor: totalDebit,
      totalCreditMinor: totalCredit,
    );
  }
}

/// The tax fake only answers the profile lookup that gates the Books entry.
class FakeCompanyTaxRepository implements TaxRepository {
  @override
  Future<TaxProfileRecord?> getProfile(String budgetId) async =>
      TaxProfileRecord(
        id: UuidValue.fromString('00000000-0000-0000-0000-000000000903'),
        budgetId: _budgetUuid,
        jurisdiction: 'GB',
        entityKind: 'company',
        profileJson: '{"entityKind":"company"}',
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026, 6),
      );

  @override
  Future<TaxProfileRecord> saveProfile({
    required String budgetId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
    String? linkedBudgetId,
  }) => throw UnimplementedError();

  @override
  Future<List<TaxCategoryView>> listCategories(String budgetId) =>
      throw UnimplementedError();

  @override
  Future<Envelope> setEnvelopeTaxCategory({
    required String envelopeId,
    String? code,
  }) => throw UnimplementedError();

  @override
  Future<Transaction> setTransactionTax({
    required String transactionId,
    String? code,
    int? businessUsePercent,
    int? salesTaxCents,
  }) => throw UnimplementedError();

  @override
  Future<TaxReportView> getReport(String budgetId, int startYear) =>
      throw UnimplementedError();
}

Widget _buildApp(FakeBooksRepository books) {
  final router = GoRouter(
    initialLocation: morePath.replaceFirst(':id', _budgetId),
    routes: [
      GoRoute(
        name: moreRoute,
        path: morePath,
        builder: (context, state) =>
            MoreScreen(budgetId: state.pathParameters['id']!),
      ),
      GoRoute(
        name: booksRoute,
        path: booksPath,
        builder: (context, state) =>
            BooksScreen(budgetId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            name: journalNewRoute,
            path: 'journals/new',
            builder: (context, state) =>
                JournalEditorScreen(budgetId: state.pathParameters['id']!),
          ),
          GoRoute(
            name: journalDetailRoute,
            path: 'journals/:journalId',
            builder: (context, state) => JournalDetailScreen(
              budgetId: state.pathParameters['id']!,
              journalId: state.pathParameters['journalId']!,
            ),
          ),
        ],
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
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
    'enables books on a company budget, posts a journal, sees the trial '
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

      expect(
        books.journals.single.status,
        TestData.postedLabel.toLowerCase(),
      );

      // The posted journal shows in the trial balance.
      await booksTab.openTrialBalance();
      await tester.pumpAndSettle();

      expect(booksTab.balancedChip, findsOneWidget);
      expect(find.text(TestData.bankAccountRow), findsOneWidget);
      expect(find.textContaining(TestData.journalAmount), findsWidgets);

      // Reverse it from the read-only journal.
      await booksTab.openJournals(tester);
      await tester.pumpAndSettle();
      await tester.tap(booksTab.journalTile(TestData.journalReference));
      await tester.pumpAndSettle();

      final detail = JournalDetailPage(tester);
      expect(detail.postedChip, findsOneWidget);
      expect(detail.readOnlyNote, findsOneWidget);

      await tester.tap(detail.reverseButton);
      await tester.pumpAndSettle();
      expect(detail.reverseDialog, findsOneWidget);
      await tester.tap(detail.reverseConfirmButton);
      await tester.pumpAndSettle();

      expect(detail.reversedChip, findsOneWidget);
      expect(
        books.journals.first.status,
        TestData.postedLabel.toLowerCase(),
      );
      expect(
        books.journals.first.reversalOfJournalId?.toString(),
        books.journals.last.id?.toString(),
      );
    },
  );
}
