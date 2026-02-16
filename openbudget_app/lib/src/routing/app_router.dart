import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_detail_screen.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_list_screen.dart';
import 'package:openbudget_app/src/features/accounts/screens/add_account_screen.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/auth/screens/login_screen.dart';
import 'package:openbudget_app/src/features/auth/screens/register_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/create_budget_screen.dart';
import 'package:openbudget_app/src/features/home/screens/home_screen.dart';
import 'package:openbudget_app/src/features/payees/screens/payee_list_screen.dart';
import 'package:openbudget_app/src/features/recurring/screens/recurring_list_screen.dart';
import 'package:openbudget_app/src/features/reports/screens/net_worth_screen.dart';
import 'package:openbudget_app/src/features/reports/screens/reports_screen.dart';
import 'package:openbudget_app/src/features/reports/screens/spending_trends_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/settings_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/add_expense_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/add_income_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/import_transactions_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/split_expense_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/transaction_list_screen.dart';
import 'package:openbudget_app/src/features/transfers/screens/create_transfer_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authProvider);

  final isAuthenticated = authState is Authenticated;
  final isLoading = authState is AuthLoading;

  return GoRouter(
    initialLocation: loginPath,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthRoute = location == loginPath || location == registerPath;

      if (isLoading) return null;
      if (!isAuthenticated && !isAuthRoute) return loginPath;
      if (isAuthenticated && isAuthRoute) return homePath;

      return null;
    },
    routes: [
      GoRoute(
        name: loginRoute,
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: registerRoute,
        path: registerPath,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        name: homeRoute,
        path: homePath,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        name: createBudgetRoute,
        path: createBudgetPath,
        builder: (context, state) => const CreateBudgetScreen(),
      ),
      GoRoute(
        name: budgetDetailRoute,
        path: budgetDetailPath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BudgetDetailScreen(budgetId: id);
        },
      ),
      GoRoute(
        name: addIncomeRoute,
        path: addIncomePath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AddIncomeScreen(budgetId: id);
        },
      ),
      GoRoute(
        name: addExpenseRoute,
        path: addExpensePath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AddExpenseScreen(budgetId: id);
        },
      ),
      GoRoute(
        name: transactionListRoute,
        path: transactionListPath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return TransactionListScreen(budgetId: id);
        },
      ),
      GoRoute(
        name: accountListRoute,
        path: accountListPath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AccountListScreen(budgetId: id);
        },
      ),
      GoRoute(
        name: accountDetailRoute,
        path: accountDetailPath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final accountId = state.pathParameters['accountId']!;
          return AccountDetailScreen(budgetId: id, accountId: accountId);
        },
      ),
      GoRoute(
        name: addAccountRoute,
        path: addAccountPath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AddAccountScreen(budgetId: id);
        },
      ),
      GoRoute(
        name: payeeListRoute,
        path: payeeListPath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PayeeListScreen(budgetId: id);
        },
      ),
      GoRoute(
        name: createTransferRoute,
        path: createTransferPath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return CreateTransferScreen(budgetId: id);
        },
      ),
      GoRoute(
        name: reportsRoute,
        path: reportsPath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ReportsScreen(budgetId: id);
        },
      ),
      GoRoute(
        name: recurringListRoute,
        path: recurringListPath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return RecurringListScreen(budgetId: id);
        },
      ),
      GoRoute(
        name: splitExpenseRoute,
        path: splitExpensePath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SplitExpenseScreen(budgetId: id);
        },
      ),
      GoRoute(
        name: importTransactionsRoute,
        path: importTransactionsPath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ImportTransactionsScreen(budgetId: id);
        },
      ),
      GoRoute(
        name: netWorthRoute,
        path: netWorthPath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return NetWorthScreen(budgetId: id);
        },
      ),
      GoRoute(
        name: spendingTrendsRoute,
        path: spendingTrendsPath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SpendingTrendsScreen(budgetId: id);
        },
      ),
      GoRoute(
        name: settingsRoute,
        path: settingsPath,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SettingsScreen(budgetId: id);
        },
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );
}
