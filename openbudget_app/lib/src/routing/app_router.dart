import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/auth/screens/login_screen.dart';
import 'package:openbudget_app/src/features/auth/screens/register_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/create_budget_screen.dart';
import 'package:openbudget_app/src/features/home/screens/home_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/add_expense_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/add_income_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/transaction_list_screen.dart';
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
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );
}
