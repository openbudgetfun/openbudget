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
import 'package:openbudget_ui/openbudget_ui.dart';

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
    isClosed: false,
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
      theme: OpenBudgetTheme.light,
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

  testWidgets('empty accounts flow navigates to add account with currencies', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp(accounts: const []));
    await tester.pumpAndSettle();

    expect(find.text('No Accounts Yet'), findsOneWidget);
    await tester.tap(find.text('Add Account'));
    await tester.pumpAndSettle();

    expect(find.text('Currency'), findsOneWidget);
    expect(find.text(r'USD ($)'), findsOneWidget);

    await tester.tap(find.text(r'USD ($)'));
    await tester.pumpAndSettle();

    expect(find.text('EUR (€)'), findsOneWidget);
    expect(find.text('GBP (£)'), findsOneWidget);
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
}
