import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_detail_screen.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_list_screen.dart';
import 'package:openbudget_app/src/features/accounts/screens/add_account_screen.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/auth/screens/login_screen.dart';
import 'package:openbudget_app/src/features/auth/screens/register_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_shell_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/category_detail_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/create_budget_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/edit_plan_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/recent_moves_screen.dart';
import 'package:openbudget_app/src/features/home/screens/home_screen.dart';
import 'package:openbudget_app/src/features/more/screens/more_screen.dart';
import 'package:openbudget_app/src/features/payees/screens/payee_list_screen.dart';
import 'package:openbudget_app/src/features/recurring/screens/recurring_calendar_screen.dart';
import 'package:openbudget_app/src/features/recurring/screens/recurring_list_screen.dart';
import 'package:openbudget_app/src/features/reports/screens/category_trends_screen.dart';
import 'package:openbudget_app/src/features/reports/screens/multi_month_comparison_screen.dart';
import 'package:openbudget_app/src/features/reports/screens/net_worth_screen.dart';
import 'package:openbudget_app/src/features/reports/screens/reports_screen.dart';
import 'package:openbudget_app/src/features/reports/screens/spending_by_payee_screen.dart';
import 'package:openbudget_app/src/features/reports/screens/spending_trends_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/account_settings_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/app_icon_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/currency_settings_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/delete_account_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/display_options_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/plan_settings_screen.dart';
import 'package:openbudget_app/src/features/settings/screens/settings_screen.dart';
import 'package:openbudget_app/src/features/transaction_rules/screens/rule_list_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/add_expense_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/add_income_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/import_transactions_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/split_expense_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/transaction_list_screen.dart';
import 'package:openbudget_app/src/features/transfers/screens/create_transfer_screen.dart';
import 'package:openbudget_app/src/logging/navigation_observer.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

final _shellNavigatorKeys = <GlobalKey<NavigatorState>>[
  GlobalKey<NavigatorState>(debugLabel: 'plan'),
  GlobalKey<NavigatorState>(debugLabel: 'accounts'),
  GlobalKey<NavigatorState>(debugLabel: 'reflect'),
  GlobalKey<NavigatorState>(debugLabel: 'more'),
];

@riverpod
GoRouter appRouter(Ref ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: startupPath,
    observers: [LoggingNavigationObserver()],
    redirect: (context, state) => authRedirectForLocation(
      authState: authState,
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(
        name: startupRoute,
        path: startupPath,
        builder: (context, state) => const _StartupScreen(),
      ),
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
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          child: const CreateBudgetScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        name: budgetDetailRoute,
        path: budgetDetailPath,
        redirect: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null || id.isEmpty) return homePath;
          final budgetRootPath = '/budgets/$id';
          if (state.uri.path == budgetRootPath) {
            return '$budgetRootPath/plan';
          }
          return null;
        },
        routes: [
          GoRoute(
            name: editPlanRoute,
            path: 'plan/edit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return EditPlanScreen(budgetId: id);
            },
          ),
          // Budget shell with bottom tab navigation.
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              final id = state.pathParameters['id']!;
              return BudgetShellScreen(
                navigationShell: navigationShell,
                budgetId: id,
              );
            },
            branches: [
              // Branch 0: Plan (budget detail)
              StatefulShellBranch(
                navigatorKey: _shellNavigatorKeys[0],
                routes: [
                  GoRoute(
                    name: planRoute,
                    path: 'plan',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return BudgetDetailScreen(budgetId: id);
                    },
                    routes: [
                      GoRoute(
                        name: recentMovesRoute,
                        path: 'recent-moves',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return RecentMovesScreen(budgetId: id);
                        },
                        routes: [
                          GoRoute(
                            name: envelopeMovesRoute,
                            path: ':envelopeId',
                            builder: (context, state) {
                              final id = state.pathParameters['id']!;
                              final envelopeId =
                                  state.pathParameters['envelopeId']!;
                              return EnvelopeMovesScreen(
                                budgetId: id,
                                envelopeId: envelopeId,
                              );
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        name: categoryDetailRoute,
                        path: 'category/:categoryId/envelope/:envelopeId',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          final categoryId =
                              state.pathParameters['categoryId']!;
                          final envelopeId =
                              state.pathParameters['envelopeId']!;
                          return CategoryDetailScreen(
                            budgetId: id,
                            categoryId: categoryId,
                            envelopeId: envelopeId,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              // Branch 1: Accounts
              StatefulShellBranch(
                navigatorKey: _shellNavigatorKeys[1],
                routes: [
                  GoRoute(
                    name: accountListRoute,
                    path: 'accounts',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return AccountListScreen(budgetId: id);
                    },
                    routes: [
                      GoRoute(
                        name: addAccountRoute,
                        path: 'add',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return AddAccountScreen(budgetId: id);
                        },
                      ),
                      GoRoute(
                        name: accountDetailRoute,
                        path: ':accountId',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          final accountId = state.pathParameters['accountId']!;
                          return AccountDetailScreen(
                            budgetId: id,
                            accountId: accountId,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              // Branch 2: Reflect (reports)
              StatefulShellBranch(
                navigatorKey: _shellNavigatorKeys[2],
                routes: [
                  GoRoute(
                    name: reportsRoute,
                    path: 'reflect',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return ReportsScreen(budgetId: id);
                    },
                    routes: [
                      GoRoute(
                        name: spendingTrendsRoute,
                        path: 'trends',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return SpendingTrendsScreen(budgetId: id);
                        },
                      ),
                      GoRoute(
                        name: spendingByPayeeRoute,
                        path: 'payees',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return SpendingByPayeeScreen(budgetId: id);
                        },
                      ),
                      GoRoute(
                        name: categoryTrendsRoute,
                        path: 'category-trends',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return CategoryTrendsScreen(budgetId: id);
                        },
                      ),
                      GoRoute(
                        name: multiMonthComparisonRoute,
                        path: 'comparison',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return MultiMonthComparisonScreen(budgetId: id);
                        },
                      ),
                      GoRoute(
                        name: netWorthRoute,
                        path: 'net-worth',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return NetWorthScreen(budgetId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
              // Branch 3: More
              StatefulShellBranch(
                navigatorKey: _shellNavigatorKeys[3],
                routes: [
                  GoRoute(
                    name: moreRoute,
                    path: 'more',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return MoreScreen(budgetId: id);
                    },
                    routes: [
                      GoRoute(
                        name: recurringListRoute,
                        path: 'recurring',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return RecurringListScreen(budgetId: id);
                        },
                        routes: [
                          GoRoute(
                            name: recurringCalendarRoute,
                            path: 'calendar',
                            builder: (context, state) {
                              final id = state.pathParameters['id']!;
                              return RecurringCalendarScreen(budgetId: id);
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        name: payeeListRoute,
                        path: 'payees',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return PayeeListScreen(budgetId: id);
                        },
                      ),
                      GoRoute(
                        name: transactionRulesRoute,
                        path: 'rules',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return RuleListScreen(budgetId: id);
                        },
                      ),
                      GoRoute(
                        name: importTransactionsRoute,
                        path: 'import',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return ImportTransactionsScreen(budgetId: id);
                        },
                      ),
                      GoRoute(
                        name: settingsRoute,
                        path: 'settings',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return SettingsScreen(budgetId: id);
                        },
                        routes: [
                          GoRoute(
                            name: planSettingsRoute,
                            path: 'plan',
                            builder: (context, state) {
                              final id = state.pathParameters['id']!;
                              return PlanSettingsScreen(budgetId: id);
                            },
                            routes: [
                              GoRoute(
                                name: currencySettingsRoute,
                                path: 'currency',
                                builder: (context, state) {
                                  final id = state.pathParameters['id']!;
                                  return CurrencySettingsScreen(budgetId: id);
                                },
                              ),
                            ],
                          ),
                          GoRoute(
                            name: appIconRoute,
                            path: 'app-icon',
                            builder: (context, state) {
                              final id = state.pathParameters['id']!;
                              return AppIconScreen(budgetId: id);
                            },
                          ),
                          GoRoute(
                            name: accountSettingsRoute,
                            path: 'account-settings',
                            builder: (context, state) {
                              final id = state.pathParameters['id']!;
                              return AccountSettingsScreen(budgetId: id);
                            },
                            routes: [
                              GoRoute(
                                name: deleteAccountRoute,
                                path: 'delete',
                                builder: (context, state) {
                                  final id = state.pathParameters['id']!;
                                  return DeleteAccountScreen(budgetId: id);
                                },
                              ),
                            ],
                          ),
                          GoRoute(
                            name: displayOptionsRoute,
                            path: 'display',
                            builder: (context, state) {
                              final id = state.pathParameters['id']!;
                              return DisplayOptionsScreen(budgetId: id);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Routes outside the shell (full-screen overlays).
          GoRoute(
            name: addIncomeRoute,
            path: 'income/add',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AddIncomeScreen(budgetId: id);
            },
          ),
          GoRoute(
            name: addExpenseRoute,
            path: 'expenses/add',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AddExpenseScreen(budgetId: id);
            },
          ),
          GoRoute(
            name: transactionListRoute,
            path: 'transactions',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TransactionListScreen(budgetId: id);
            },
          ),
          GoRoute(
            name: createTransferRoute,
            path: 'transfer',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return CreateTransferScreen(budgetId: id);
            },
          ),
          GoRoute(
            name: splitExpenseRoute,
            path: 'expenses/split',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return SplitExpenseScreen(budgetId: id);
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) {
      final l10n = AppLocalizations.of(context);
      return Scaffold(
        body: Center(
          child: Text(l10n.routerPageNotFound(state.error.toString())),
        ),
      );
    },
  );
}

@visibleForTesting
String? authRedirectForLocation({
  required AuthState authState,
  required String location,
}) {
  final isAuthRoute = location == loginPath || location == registerPath;
  final isStartupRoute = location == startupPath;
  final isAuthenticated = authState is Authenticated;
  final isRestoring = authState is AuthRestoring;

  if (isRestoring) {
    return isStartupRoute ? null : startupPath;
  }

  if (authState is AuthLoading) return null;

  if (!isAuthenticated) {
    return isAuthRoute ? null : loginPath;
  }

  if (isStartupRoute || isAuthRoute) {
    return homePath;
  }

  return null;
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
