import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/auth/screens/login_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/create_budget_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: loginPath,
    redirect: (context, state) {
      final isAuthenticated = authState is Authenticated;
      final isOnLogin = state.matchedLocation == loginPath;

      if (!isAuthenticated && !isOnLogin) return loginPath;
      if (isAuthenticated && isOnLogin) return createBudgetPath;

      return null;
    },
    routes: [
      GoRoute(
        name: loginRoute,
        path: loginPath,
        builder: (context, state) => const LoginScreen(),
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
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );
}
