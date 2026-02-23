// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_transactions_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_detail_screen.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_list_screen.dart';
import 'package:openbudget_app/src/features/accounts/screens/add_account_screen.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';

const _budgetId = 'test-budget-id';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000010',
);

Account _makeAccount({
  required String name,
  required int balanceCents,
  required String currencyCode,
  UuidValue? id,
  bool onBudget = true,
  bool isClosed = false,
}) {
  return Account(
    id: id,
    name: name,
    accountType: 'checking',
    balanceCents: balanceCents,
    currencyCode: currencyCode,
    budgetId: _budgetUuid,
    onBudget: onBudget,
    sortOrder: 0,
    isClosed: isClosed,
  );
}

Budget _makeBudget({String currencyCode = 'USD'}) {
  return Budget(
    id: _budgetUuid,
    name: 'OpenBudget',
    currencyCode: currencyCode,
    ownerId: UuidValue.fromString('00000000-0000-0000-0000-000000000099'),
    createdAt: DateTime(2026),
  );
}

BudgetSummary _makeSummary({String currencyCode = 'USD'}) {
  return BudgetSummary(
    budget: _makeBudget(currencyCode: currencyCode),
    categories: const [],
    totalIncomeCents: 0,
    totalBudgetedCents: 0,
    readyToAssignCents: 0,
    year: 2026,
    month: 9,
  );
}

Transaction _makeTransaction({
  required String id,
  required UuidValue accountId,
  required String description,
  required int amountCents,
  bool cleared = false,
  bool reconciled = false,
  DateTime? transactionDate,
}) {
  return Transaction(
    id: UuidValue.fromString(id),
    description: description,
    amountCents: amountCents,
    currencyCode: 'USD',
    budgetId: _budgetUuid,
    accountId: accountId,
    transactionDate: transactionDate ?? DateTime(2026, 9, 3),
    cleared: cleared,
    reconciled: reconciled,
  );
}

Widget _buildApp({
  required List<Account> accounts,
  List<Transaction> accountTransactions = const [],
  String budgetCurrencyCode = 'USD',
}) {
  final router = GoRouter(
    initialLocation: '/budgets/$_budgetId/accounts',
    routes: [
      GoRoute(
        name: accountListRoute,
        path: '/budgets/:id/accounts',
        builder: (context, state) =>
            AccountListScreen(budgetId: state.pathParameters['id']!),
      ),
      GoRoute(
        name: addAccountRoute,
        path: '/budgets/:id/accounts/add',
        builder: (context, state) =>
            AddAccountScreen(budgetId: state.pathParameters['id']!),
      ),
      GoRoute(
        name: accountDetailRoute,
        path: '/budgets/:id/accounts/:accountId',
        builder: (context, state) => AccountDetailScreen(
          budgetId: state.pathParameters['id']!,
          accountId: state.pathParameters['accountId']!,
        ),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      accountListProvider.overrideWith((ref, budgetId) async => accounts),
      accountTransactionsProvider.overrideWith(
        (ref, args) async => accountTransactions,
      ),
      payeeListProvider.overrideWith((ref, budgetId) async => const []),
      budgetSummaryProvider.overrideWith(
        (ref, budgetId) async => _makeSummary(currencyCode: budgetCurrencyCode),
      ),
      budgetDetailProvider.overrideWith(
        (ref, budgetId) async => _makeBudget(currencyCode: budgetCurrencyCode),
      ),
    ],
    child: MaterialApp.router(
      theme: ThemeData.light(useMaterial3: true),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('shows mixed-currency summaries in accounts view', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(
        accounts: [
          _makeAccount(
            name: 'Daily USD',
            balanceCents: 250000,
            currencyCode: 'USD',
          ),
          _makeAccount(
            name: 'Savings EUR',
            balanceCents: 100000,
            currencyCode: 'EUR',
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daily USD'), findsOneWidget);
    expect(find.text('Savings EUR'), findsOneWidget);
    expect(find.textContaining('USD'), findsWidgets);
    expect(find.textContaining('EUR'), findsWidgets);
  });

  testWidgets('empty accounts flow navigates through add account wizard', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp(accounts: const []));
    await tester.pumpAndSettle();

    expect(find.text('No Accounts Yet'), findsOneWidget);
    await tester.tap(find.text('Add Account'));
    await tester.pumpAndSettle();

    expect(find.text('Add Accounts'), findsOneWidget);
    expect(find.text('Search for your bank'), findsOneWidget);
    expect(find.text('Add an Unlinked Account'), findsOneWidget);

    await tester.tap(find.text('Add an Unlinked Account'));
    await tester.pumpAndSettle();

    expect(find.text('Currency'), findsOneWidget);
    expect(find.text(r'USD ($)'), findsOneWidget);

    await tester.tap(find.text(r'USD ($)'));
    await tester.pumpAndSettle();

    expect(find.text('EUR (€)'), findsOneWidget);
    expect(find.text('GBP (£)'), findsOneWidget);
  });

  testWidgets('bank search shortcut moves user to unlinked account flow', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp(accounts: const []));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Account'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chase'));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('Add Unlinked Account'), findsOneWidget);
    expect(
      find.textContaining('Linked connections for "Chase" are coming soon'),
      findsOneWidget,
    );
  });

  testWidgets('account detail flow navigates to detail and back to list', (
    tester,
  ) async {
    final accountId = UuidValue.fromString(
      '00000000-0000-0000-0000-000000000111',
    );
    await tester.pumpWidget(
      _buildApp(
        accounts: [
          _makeAccount(
            id: accountId,
            name: 'Daily USD',
            balanceCents: 250000,
            currencyCode: 'USD',
          ),
        ],
        accountTransactions: [
          Transaction(
            id: UuidValue.fromString('00000000-0000-0000-0000-000000000211'),
            description: 'Rent',
            amountCents: -280000,
            currencyCode: 'USD',
            budgetId: _budgetUuid,
            accountId: accountId,
            transactionDate: DateTime(2026, 9, 3),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daily USD'));
    await tester.pumpAndSettle();
    expect(find.text('Rent'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('Daily USD'), findsOneWidget);
  });

  testWidgets('account detail overflow menu toggles reconciled visibility', (
    tester,
  ) async {
    final accountId = UuidValue.fromString(
      '00000000-0000-0000-0000-000000000111',
    );
    await tester.pumpWidget(
      _buildApp(
        accounts: [
          _makeAccount(
            id: accountId,
            name: 'Daily USD',
            balanceCents: 250000,
            currencyCode: 'USD',
          ),
        ],
        accountTransactions: [
          _makeTransaction(
            id: '00000000-0000-0000-0000-000000000211',
            accountId: accountId,
            description: 'Self storage',
            amountCents: -3000,
          ),
          _makeTransaction(
            id: '00000000-0000-0000-0000-000000000212',
            accountId: accountId,
            description: 'Starting Balance',
            amountCents: 5000000,
            reconciled: true,
            transactionDate: DateTime(2026, 9, 2),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daily USD'));
    await tester.pumpAndSettle();
    expect(find.text('Starting Balance'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hide Reconciled'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Starting Balance'), findsNothing);
    expect(find.text('Self storage'), findsOneWidget);

    await tester.tap(find.textContaining('uncleared transactions'));
    await tester.pumpAndSettle();
    expect(find.text('Self storage'), findsOneWidget);
  });

  testWidgets('closed account edit dialog exposes delete and reopen actions', (
    tester,
  ) async {
    final accountId = UuidValue.fromString(
      '00000000-0000-0000-0000-000000000113',
    );
    await tester.pumpWidget(
      _buildApp(
        accounts: [
          _makeAccount(
            id: accountId,
            name: 'Loan',
            balanceCents: -50000,
            currencyCode: 'USD',
            onBudget: false,
            isClosed: true,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Loan'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit Account'));
    await tester.pumpAndSettle();

    expect(find.text('Delete Permanently'), findsOneWidget);
    expect(find.text('Reopen Account'), findsOneWidget);
  });

  testWidgets('reconcile action opens balance match prompt', (tester) async {
    final accountId = UuidValue.fromString(
      '00000000-0000-0000-0000-000000000114',
    );
    await tester.pumpWidget(
      _buildApp(
        accounts: [
          _makeAccount(
            id: accountId,
            name: 'Daily USD',
            balanceCents: 250000,
            currencyCode: 'USD',
          ),
        ],
        accountTransactions: [
          _makeTransaction(
            id: '00000000-0000-0000-0000-000000000311',
            accountId: accountId,
            description: 'Rent',
            amountCents: -280000,
            cleared: true,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Daily USD'));
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
}
