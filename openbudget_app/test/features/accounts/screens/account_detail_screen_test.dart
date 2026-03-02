// UuidValue is needed for constructing test model data.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_transactions_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/solana_wallet_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_detail_screen.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

const _budgetId = 'test-budget-id';
const _accountId = '00000000-0000-0000-0000-000000000111';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000010',
);
final _accountUuid = UuidValue.fromString(_accountId);
final _ownerUuid = UuidValue.fromString('00000000-0000-0000-0000-000000000099');
final _walletUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000abc',
);

Budget _makeBudget() => Budget(
  id: _budgetUuid,
  name: 'OpenBudget',
  currencyCode: 'USD',
  ownerId: _ownerUuid,
  createdAt: DateTime(2026),
);

Account _makeAccount({
  String name = 'Daily',
  String accountType = 'checking',
  int balanceCents = 5202000,
  bool onBudget = true,
  bool isClosed = false,
}) => Account(
  id: _accountUuid,
  name: name,
  accountType: accountType,
  balanceCents: balanceCents,
  currencyCode: 'USD',
  budgetId: _budgetUuid,
  onBudget: onBudget,
  sortOrder: 0,
  isClosed: isClosed,
);

Transaction _makeTransaction({
  required String id,
  required String description,
  required int amountCents,
  DateTime? transactionDate,
  String? memo,
  bool cleared = false,
  bool reconciled = false,
}) => Transaction(
  id: UuidValue.fromString(id),
  description: description,
  amountCents: amountCents,
  currencyCode: 'USD',
  budgetId: _budgetUuid,
  accountId: _accountUuid,
  transactionDate: transactionDate ?? DateTime(2026, 9, 3),
  memo: memo,
  cleared: cleared,
  reconciled: reconciled,
);

BudgetSummary _makeSummary() => BudgetSummary(
  budget: _makeBudget(),
  categories: const [],
  totalIncomeCents: 0,
  totalBudgetedCents: 0,
  readyToAssignCents: 0,
  year: 2026,
  month: 9,
);

Widget _buildSubject({List<Transaction>? transactions, Account? account}) {
  final router = GoRouter(
    initialLocation: '/budgets/$_budgetId/accounts/$_accountId',
    routes: [
      GoRoute(
        name: accountListRoute,
        path: accountListPath,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Accounts Route'))),
      ),
      GoRoute(
        name: accountDetailRoute,
        path: accountDetailPath,
        builder: (context, state) => AccountDetailScreen(
          budgetId: state.pathParameters['id']!,
          accountId: state.pathParameters['accountId']!,
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      accountListProvider.overrideWith(
        (ref, budgetId) async => [account ?? _makeAccount()],
      ),
      accountTransactionsProvider.overrideWith(
        (ref, args) async =>
            transactions ??
            [
              _makeTransaction(
                id: '00000000-0000-0000-0000-000000000211',
                description: 'Rent',
                amountCents: -280000,
                memo: 'September rent',
              ),
              _makeTransaction(
                id: '00000000-0000-0000-0000-000000000212',
                description: 'Payroll',
                amountCents: 300000,
                transactionDate: DateTime(2026, 9, 2),
                reconciled: true,
              ),
            ],
      ),
      payeeListProvider.overrideWith((ref, budgetId) async => const []),
      budgetSummaryProvider.overrideWith(
        (ref, budgetId) async => _makeSummary(),
      ),
    ],
    child: MaterialApp.router(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

Widget _buildWalletSubject({
  SolanaWallet? wallet,
  List<SolanaWalletHolding>? holdings,
  List<SolanaWalletTransaction>? walletTransactions,
  List<SolanaWalletTaxYearSummary>? taxYearSummaries,
}) {
  final router = GoRouter(
    initialLocation: '/budgets/$_budgetId/accounts/$_accountId',
    routes: [
      GoRoute(
        name: accountListRoute,
        path: accountListPath,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Accounts Route'))),
      ),
      GoRoute(
        name: accountDetailRoute,
        path: accountDetailPath,
        builder: (context, state) => AccountDetailScreen(
          budgetId: state.pathParameters['id']!,
          accountId: state.pathParameters['accountId']!,
        ),
      ),
    ],
  );

  final testWallet =
      wallet ??
      SolanaWallet(
        id: _walletUuid,
        accountId: _accountUuid,
        budgetId: _budgetUuid,
        address: '8f5PsYfTEvtwFw8szw8RKtAHY8fE6hzJHjxbM6j6YV1z',
        cluster: 'mainnet',
        syncStatus: 'success',
        lastSyncedAt: DateTime(2026, 9, 5, 10, 30),
      );

  final testHoldings =
      holdings ??
      [
        SolanaWalletHolding(
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000ac1'),
          walletId: _walletUuid,
          budgetId: _budgetUuid,
          assetId: 'So11111111111111111111111111111111111111112',
          symbol: 'SOL',
          decimals: 9,
          balanceRaw: '1500000000',
          balanceUi: '1.5',
          isNft: false,
          totalValue: 280,
          estimatedCostBasis: 250,
          estimatedUnrealizedPnl: 30,
          estimatedUnrealizedPnlPercent: 12,
          estimatedRealizedPnl: 8,
          pnlCurrency: 'USD',
          tokenProgram: 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
        ),
        SolanaWalletHolding(
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000ac2'),
          walletId: _walletUuid,
          budgetId: _budgetUuid,
          assetId: 'DustToken1111111111111111111111111111111111',
          symbol: 'DUST',
          decimals: 6,
          balanceRaw: '100',
          balanceUi: '0.0001',
          isNft: false,
          totalValue: 0.0005,
          tokenProgram: 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
        ),
      ];

  final testWalletTransactions =
      walletTransactions ??
      [
        SolanaWalletTransaction(
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000ad1'),
          walletId: _walletUuid,
          budgetId: _budgetUuid,
          signature: 'sig-jup-1',
          slot: 100,
          occurredAt: DateTime(2026, 9, 4, 13),
          description: 'Jupiter swap',
          txType: 'SWAP',
          source: 'JUPITER',
          category: 'Swaps',
          rawJson: '{}',
        ),
        SolanaWalletTransaction(
          id: UuidValue.fromString('00000000-0000-0000-0000-000000000ad2'),
          walletId: _walletUuid,
          budgetId: _budgetUuid,
          signature: 'sig-transfer-1',
          slot: 101,
          occurredAt: DateTime(2026, 9, 5, 9, 15),
          description: 'Transfer to friend',
          txType: 'TRANSFER',
          source: 'SYSTEM_PROGRAM',
          estimatedCostBasis: 10,
          estimatedProceeds: 18,
          estimatedRealizedPnl: 8,
          pnlCurrency: 'USD',
          taxYear: 2026,
          tagsCsv: 'personal',
          rawJson: '{}',
        ),
      ];

  final testTaxYearSummaries =
      taxYearSummaries ??
      [
        SolanaWalletTaxYearSummary(
          walletId: _walletUuid,
          taxYear: 2026,
          transactionCount: 1,
          estimatedRealizedPnl: 8,
          estimatedProceeds: 18,
          estimatedCostBasis: 10,
          pnlCurrency: 'USD',
        ),
      ];

  return ProviderScope(
    overrides: [
      accountListProvider.overrideWith(
        (ref, budgetId) async => [
          _makeAccount(
            name: 'Main Wallet',
            accountType: 'cryptoWallet',
            onBudget: false,
            balanceCents: 28000,
          ),
        ],
      ),
      accountTransactionsProvider.overrideWith((ref, args) async => const []),
      payeeListProvider.overrideWith((ref, budgetId) async => const []),
      budgetSummaryProvider.overrideWith(
        (ref, budgetId) async => _makeSummary(),
      ),
      accountSolanaWalletProvider.overrideWith((ref, args) async => testWallet),
      solanaWalletHoldingsProvider.overrideWith(
        (ref, args) async => testHoldings,
      ),
      solanaWalletTransactionsProvider.overrideWith(
        (ref, args) async => testWalletTransactions,
      ),
      solanaWalletTaxYearSummariesProvider.overrideWith(
        (ref, args) async => testTaxYearSummaries,
      ),
    ],
    child: MaterialApp.router(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

Future<void> _scrollToText(
  WidgetTester tester,
  String text, {
  double delta = 300,
}) async {
  final scrollables = find.byType(Scrollable);
  expect(scrollables, findsWidgets);
  await tester.scrollUntilVisible(
    find.text(text),
    delta,
    scrollable: scrollables.last,
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AccountDetailScreen', () {
    testWidgets('renders account and transaction content', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Daily'), findsOneWidget);
      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('September rent'), findsOneWidget);
      expect(find.text('Payroll'), findsOneWidget);
    });

    testWidgets('back button navigates to account list route', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Accounts Route'), findsOneWidget);
    });

    testWidgets('menu toggle hides reconciled rows', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Payroll'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hide Reconciled'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Payroll'), findsNothing);
      expect(find.text('Rent'), findsOneWidget);
    });

    testWidgets('uncleared shortcut filters to uncleared transactions', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          transactions: [
            _makeTransaction(
              id: '00000000-0000-0000-0000-000000000211',
              description: 'Rent',
              amountCents: -280000,
            ),
            _makeTransaction(
              id: '00000000-0000-0000-0000-000000000212',
              description: 'Gym',
              amountCents: -8000,
              cleared: true,
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Gym'), findsOneWidget);

      await tester.tap(find.textContaining('uncleared transactions'));
      await tester.pumpAndSettle();

      expect(find.text('Rent'), findsOneWidget);
      expect(find.text('Gym'), findsNothing);
    });

    testWidgets('reconcile menu opens balance match prompt', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reconcile'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Does this match your bank balance'),
        findsOneWidget,
      );
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('edit account opens full-screen form fields', (tester) async {
      await tester.pumpWidget(_buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit Account'));
      await tester.pumpAndSettle();

      expect(find.text('Account Nickname'), findsOneWidget);
      expect(find.text('Account Notes'), findsOneWidget);
      expect(find.text('Working Balance'), findsWidgets);
      expect(find.text('Link an Account (Unavailable)'), findsOneWidget);
    });

    testWidgets('loan account renders overview and activity tabs', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildSubject(
          account: _makeAccount(
            name: 'Loan',
            accountType: 'other',
            balanceCents: -125,
            onBudget: false,
          ),
          transactions: [
            _makeTransaction(
              id: '00000000-0000-0000-0000-000000000311',
              description: 'Payment from Daily',
              amountCents: 50000,
            ),
            _makeTransaction(
              id: '00000000-0000-0000-0000-000000000312',
              description: 'Initial Balance',
              amountCents: -50000,
              transactionDate: DateTime(2026, 9),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      await _scrollToText(tester, 'Loan Payoff Overview');
      expect(find.text('Loan Payoff Overview'), findsOneWidget);
      await _scrollToText(tester, 'Create Target');
      expect(find.text('Create Target'), findsOneWidget);

      await tester.tap(find.text('Create Target'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, '400');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Target'), findsOneWidget);
      expect(find.text(r'$400.00'), findsWidgets);

      await tester.tap(find.text('Activity'));
      await tester.pumpAndSettle();

      expect(find.text('Payment from Daily'), findsOneWidget);
      expect(find.text('Payments'), findsOneWidget);
    });
    testWidgets('solana wallet dashboard renders with filters', (tester) async {
      final binding = tester.binding;
      await binding.setSurfaceSize(const Size(1200, 2200));
      addTearDown(() => binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildWalletSubject());
      await tester.pumpAndSettle();

      expect(find.text('Main Wallet'), findsWidgets);
      await _scrollToText(tester, 'Holdings', delta: 200);
      expect(find.text('Holdings'), findsOneWidget);
      await _scrollToText(tester, r'Hide dust assets (< $0.01)');
      expect(find.text(r'Hide dust assets (< $0.01)'), findsOneWidget);
      await _scrollToText(tester, 'SOL', delta: 200);
      expect(find.text('SOL'), findsOneWidget);
      expect(find.text('DUST'), findsNothing);
      await _scrollToText(tester, 'Transaction History');
      expect(find.text('Jupiter swap'), findsOneWidget);
      expect(find.text('Transfer to friend'), findsOneWidget);
      expect(find.text('Transaction History'), findsOneWidget);
      expect(find.textContaining('P&L +'), findsWidgets);
      expect(find.text('Tax 2026'), findsWidgets);
      expect(find.textContaining('Basis'), findsWidgets);
    });

    testWidgets('dust filter can reveal tiny-value holdings', (tester) async {
      final binding = tester.binding;
      await binding.setSurfaceSize(const Size(1200, 2200));
      addTearDown(() => binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildWalletSubject());
      await tester.pumpAndSettle();

      expect(find.text('DUST'), findsNothing);

      await _scrollToText(tester, r'Hide dust assets (< $0.01)');
      final dustChip = find.widgetWithText(
        FilterChip,
        r'Hide dust assets (< $0.01)',
      );
      await tester.ensureVisible(dustChip);
      await tester.tap(dustChip);
      await tester.pumpAndSettle();

      expect(find.text('DUST'), findsOneWidget);
    });

    testWidgets('wallet transaction search and category filter work', (
      tester,
    ) async {
      await tester.pumpWidget(_buildWalletSubject());
      await tester.pumpAndSettle();

      final searchField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.hintText ==
                'Search description, category, tags, memo',
      );
      final scrollables = find.byType(Scrollable);
      expect(scrollables, findsWidgets);
      await tester.scrollUntilVisible(
        searchField,
        300,
        scrollable: scrollables.last,
      );
      await tester.enterText(searchField, 'jupiter');
      await tester.pumpAndSettle();
      expect(find.text('Jupiter swap'), findsOneWidget);
      expect(find.text('Transfer to friend'), findsNothing);

      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Needs category'));
      await tester.pumpAndSettle();

      expect(find.text('Jupiter swap'), findsNothing);
      expect(find.text('Transfer to friend'), findsOneWidget);
    });
    testWidgets('uncategorized wallet transactions show suggested category', (
      tester,
    ) async {
      await tester.pumpWidget(_buildWalletSubject());
      await tester.pumpAndSettle();

      await _scrollToText(tester, 'Transfer to friend');

      expect(find.text('Suggested: Transfers'), findsOneWidget);
    });

    testWidgets('wallet metadata editor pre-fills suggested category', (
      tester,
    ) async {
      final binding = tester.binding;
      await binding.setSurfaceSize(const Size(1200, 2200));
      addTearDown(() => binding.setSurfaceSize(null));

      await tester.pumpWidget(_buildWalletSubject());
      await tester.pumpAndSettle();

      await _scrollToText(tester, 'Transfer to friend');
      final transferCard = find.ancestor(
        of: find.text('Transfer to friend'),
        matching: find.byType(Card),
      );
      final editButton = find.descendant(
        of: transferCard.first,
        matching: find.byTooltip('Edit metadata'),
      );
      final scrollables = find.byType(Scrollable);
      expect(scrollables, findsWidgets);
      await tester.scrollUntilVisible(
        editButton,
        200,
        scrollable: scrollables.last,
      );
      await tester.tap(editButton);
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      final suggestedCategoryField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.decoration?.labelText == 'Category' &&
            widget.controller?.text == 'Transfers',
      );
      expect(suggestedCategoryField, findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Suggested: Transfers'),
        ),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
    });
  });
}
