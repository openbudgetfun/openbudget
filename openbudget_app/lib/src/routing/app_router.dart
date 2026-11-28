import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_state.dart';
import 'package:openbudget_app/src/features/auth/screens/login_screen.dart';
import 'package:openbudget_app/src/features/auth/screens/register_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_detail_screen.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_shell_screen.dart';
import 'package:openbudget_app/src/features/home/screens/home_screen.dart';
import 'package:openbudget_app/src/logging/navigation_observer.dart';
import 'package:openbudget_app/src/routing/deferred/accounts_screens.dart'
    deferred as accounts;
import 'package:openbudget_app/src/routing/deferred/assistant_screens.dart'
    deferred as assistant;
import 'package:openbudget_app/src/routing/deferred/books_screens.dart'
    deferred as books;
import 'package:openbudget_app/src/routing/deferred/entry_screens.dart'
    deferred as entry;
import 'package:openbudget_app/src/routing/deferred/more_screens.dart'
    deferred as more;
import 'package:openbudget_app/src/routing/deferred/plan_screens.dart'
    deferred as plan;
import 'package:openbudget_app/src/routing/deferred/plus_screens.dart'
    deferred as plus;
import 'package:openbudget_app/src/routing/deferred/reports_screens.dart'
    deferred as reports;
import 'package:openbudget_app/src/routing/deferred/tax_screens.dart'
    deferred as tax;
import 'package:openbudget_app/src/routing/deferred_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// A deferred library of screens: its name and its `loadLibrary`.
typedef _DeferredScreens = ({String name, Future<void> Function() load});

final _DeferredScreens _planScreens = (
  name: 'plan',
  load: () => plan.loadLibrary(),
);
final _DeferredScreens _entryScreens = (
  name: 'entry',
  load: () => entry.loadLibrary(),
);
final _DeferredScreens _accountsScreens = (
  name: 'accounts',
  load: () => accounts.loadLibrary(),
);
final _DeferredScreens _reportsScreens = (
  name: 'reports',
  load: () => reports.loadLibrary(),
);
final _DeferredScreens _moreScreens = (
  name: 'more',
  load: () => more.loadLibrary(),
);
final _DeferredScreens _taxScreens = (
  name: 'tax',
  load: () => tax.loadLibrary(),
);
final _DeferredScreens _booksScreens = (
  name: 'books',
  load: () => books.loadLibrary(),
);
final _DeferredScreens _assistantScreens = (
  name: 'assistant',
  load: () => assistant.loadLibrary(),
);
final _DeferredScreens _plusScreens = (
  name: 'plus',
  load: () => plus.loadLibrary(),
);

/// Every deferred library, most likely to be opened first.
final List<_DeferredScreens> _deferredLibraries = [
  _planScreens,
  _entryScreens,
  _accountsScreens,
  _reportsScreens,
  _moreScreens,
  _taxScreens,
  _booksScreens,
  _assistantScreens,
  _plusScreens,
];

/// Fetches every deferred screen library in the background, in the order a
/// person is likely to open them, so taps after the first screen do not wait
/// on the network. Cheap to call again: each library loads once.
Future<void> preloadDeferredScreens() async {
  for (final library in _deferredLibraries) {
    try {
      await DeferredScreen.preload(library.name, library.load);
    } on Exception {
      // Offline or replaced by a release: the screen retries when opened.
    }
  }
}

Widget _deferred(_DeferredScreens library, WidgetBuilder builder) =>
    DeferredScreen(library: library.name, load: library.load, builder: builder);

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
        name: plusRoute,
        path: plusPath,
        builder: (context, state) => _deferred(
          _plusScreens,
          (_) => plus.PlusScreen(status: state.uri.queryParameters['status']),
        ),
      ),
      GoRoute(
        name: agentAccessRoute,
        path: agentAccessPath,
        builder: (context, state) =>
            _deferred(_plusScreens, (_) => plus.AgentAccessScreen()),
      ),
      GoRoute(
        name: createEntityRoute,
        path: createEntityPath,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          child: _deferred(_entryScreens, (_) => entry.CreateEntityScreen()),
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
          final id = state.pathParameters['entityId'];
          if (id == null || id.isEmpty) return homePath;
          final budgetRootPath = '/budgets/$id';
          if (state.uri.path == budgetRootPath) {
            return '$budgetRootPath/plan';
          }
          return null;
        },
        routes: [
          GoRoute(
            name: taxOverviewRoute,
            path: 'tax',
            builder: (context, state) {
              final id = state.pathParameters['entityId']!;
              return _deferred(
                _taxScreens,
                (_) => tax.TaxOverviewScreen(entityId: id),
              );
            },
            routes: [
              GoRoute(
                name: taxProfileRoute,
                path: 'profile',
                builder: (context, state) {
                  final id = state.pathParameters['entityId']!;
                  return _deferred(
                    _taxScreens,
                    (_) => tax.TaxProfileScreen(entityId: id),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            name: booksRoute,
            path: 'books',
            builder: (context, state) {
              final id = state.pathParameters['entityId']!;
              return _deferred(
                _booksScreens,
                (_) => books.BooksScreen(entityId: id),
              );
            },
            routes: [
              GoRoute(
                name: journalNewRoute,
                path: 'journals/new',
                builder: (context, state) {
                  final id = state.pathParameters['entityId']!;
                  return _deferred(
                    _booksScreens,
                    (_) => books.JournalEditorScreen(entityId: id),
                  );
                },
              ),
              GoRoute(
                name: journalEditRoute,
                path: 'journals/:journalId/edit',
                builder: (context, state) {
                  final id = state.pathParameters['entityId']!;
                  final journalId = state.pathParameters['journalId']!;
                  return _deferred(
                    _booksScreens,
                    (_) => books.JournalEditorScreen(
                      entityId: id,
                      journalId: journalId,
                    ),
                  );
                },
              ),
              GoRoute(
                name: journalDetailRoute,
                path: 'journals/:journalId',
                builder: (context, state) {
                  final id = state.pathParameters['entityId']!;
                  final journalId = state.pathParameters['journalId']!;
                  return _deferred(
                    _booksScreens,
                    (_) => books.JournalDetailScreen(
                      entityId: id,
                      journalId: journalId,
                    ),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            name: editPlanRoute,
            path: 'plan/edit',
            builder: (context, state) {
              final id = state.pathParameters['entityId']!;
              return _deferred(
                _planScreens,
                (_) => plan.EditPlanScreen(entityId: id),
              );
            },
          ),
          // Budget shell with bottom tab navigation.
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              final id = state.pathParameters['entityId']!;
              return BudgetShellScreen(
                navigationShell: navigationShell,
                entityId: id,
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
                      final id = state.pathParameters['entityId']!;
                      return BudgetDetailScreen(entityId: id);
                    },
                    routes: [
                      GoRoute(
                        name: recentMovesRoute,
                        path: 'recent-moves',
                        builder: (context, state) {
                          final id = state.pathParameters['entityId']!;
                          return _deferred(
                            _planScreens,
                            (_) => plan.RecentMovesScreen(entityId: id),
                          );
                        },
                        routes: [
                          GoRoute(
                            name: envelopeMovesRoute,
                            path: ':envelopeId',
                            builder: (context, state) {
                              final id = state.pathParameters['entityId']!;
                              final envelopeId =
                                  state.pathParameters['envelopeId']!;
                              return _deferred(
                                _planScreens,
                                (_) => plan.EnvelopeMovesScreen(
                                  entityId: id,
                                  envelopeId: envelopeId,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        name: categoryDetailRoute,
                        path: 'category/:categoryId/envelope/:envelopeId',
                        builder: (context, state) {
                          final id = state.pathParameters['entityId']!;
                          final categoryId =
                              state.pathParameters['categoryId']!;
                          final envelopeId =
                              state.pathParameters['envelopeId']!;
                          return _deferred(
                            _planScreens,
                            (_) => plan.CategoryDetailScreen(
                              entityId: id,
                              categoryId: categoryId,
                              envelopeId: envelopeId,
                            ),
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
                      final id = state.pathParameters['entityId']!;
                      return _deferred(
                        _accountsScreens,
                        (_) => accounts.AccountListScreen(entityId: id),
                      );
                    },
                    routes: [
                      GoRoute(
                        name: addAccountRoute,
                        path: 'add',
                        builder: (context, state) {
                          final id = state.pathParameters['entityId']!;
                          return _deferred(
                            _accountsScreens,
                            (_) => accounts.AddAccountScreen(entityId: id),
                          );
                        },
                      ),
                      GoRoute(
                        name: accountDetailRoute,
                        path: ':accountId',
                        builder: (context, state) {
                          final id = state.pathParameters['entityId']!;
                          final accountId = state.pathParameters['accountId']!;
                          return _deferred(
                            _accountsScreens,
                            (_) => accounts.AccountDetailScreen(
                              entityId: id,
                              accountId: accountId,
                            ),
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
                      final id = state.pathParameters['entityId']!;
                      return _deferred(
                        _reportsScreens,
                        (_) => reports.ReportsScreen(entityId: id),
                      );
                    },
                    routes: [
                      GoRoute(
                        name: spendingTrendsRoute,
                        path: 'trends',
                        builder: (context, state) {
                          final id = state.pathParameters['entityId']!;
                          return _deferred(
                            _reportsScreens,
                            (_) => reports.SpendingTrendsScreen(entityId: id),
                          );
                        },
                      ),
                      GoRoute(
                        name: spendingByPayeeRoute,
                        path: 'payees',
                        builder: (context, state) {
                          final id = state.pathParameters['entityId']!;
                          return _deferred(
                            _reportsScreens,
                            (_) => reports.SpendingByPayeeScreen(entityId: id),
                          );
                        },
                      ),
                      GoRoute(
                        name: categoryTrendsRoute,
                        path: 'category-trends',
                        builder: (context, state) {
                          final id = state.pathParameters['entityId']!;
                          return _deferred(
                            _reportsScreens,
                            (_) => reports.CategoryTrendsScreen(entityId: id),
                          );
                        },
                      ),
                      GoRoute(
                        name: multiMonthComparisonRoute,
                        path: 'comparison',
                        builder: (context, state) {
                          final id = state.pathParameters['entityId']!;
                          return _deferred(
                            _reportsScreens,
                            (_) => reports.MultiMonthComparisonScreen(
                              entityId: id,
                            ),
                          );
                        },
                      ),
                      GoRoute(
                        name: netWorthRoute,
                        path: 'net-worth',
                        builder: (context, state) {
                          final id = state.pathParameters['entityId']!;
                          return _deferred(
                            _reportsScreens,
                            (_) => reports.NetWorthScreen(entityId: id),
                          );
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
                      final id = state.pathParameters['entityId']!;
                      return _deferred(
                        _moreScreens,
                        (_) => more.MoreScreen(entityId: id),
                      );
                    },
                    routes: [
                      GoRoute(
                        name: recurringListRoute,
                        path: 'recurring',
                        builder: (context, state) {
                          final id = state.pathParameters['entityId']!;
                          return _deferred(
                            _moreScreens,
                            (_) => more.RecurringListScreen(entityId: id),
                          );
                        },
                        routes: [
                          GoRoute(
                            name: recurringCalendarRoute,
                            path: 'calendar',
                            builder: (context, state) {
                              final id = state.pathParameters['entityId']!;
                              return _deferred(
                                _moreScreens,
                                (_) =>
                                    more.RecurringCalendarScreen(entityId: id),
                              );
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        name: payeeListRoute,
                        path: 'payees',
                        builder: (context, state) {
                          final id = state.pathParameters['entityId']!;
                          return _deferred(
                            _moreScreens,
                            (_) => more.PayeeListScreen(entityId: id),
                          );
                        },
                      ),
                      GoRoute(
                        name: transactionRulesRoute,
                        path: 'rules',
                        builder: (context, state) {
                          final id = state.pathParameters['entityId']!;
                          return _deferred(
                            _moreScreens,
                            (_) => more.RuleListScreen(entityId: id),
                          );
                        },
                      ),
                      GoRoute(
                        name: importTransactionsRoute,
                        path: 'import',
                        builder: (context, state) {
                          final id = state.pathParameters['entityId']!;
                          return _deferred(
                            _moreScreens,
                            (_) => more.ImportTransactionsScreen(entityId: id),
                          );
                        },
                      ),
                      GoRoute(
                        name: settingsRoute,
                        path: 'settings',
                        builder: (context, state) {
                          final id = state.pathParameters['entityId']!;
                          return _deferred(
                            _moreScreens,
                            (_) => more.SettingsScreen(entityId: id),
                          );
                        },
                        routes: [
                          GoRoute(
                            name: planSettingsRoute,
                            path: 'plan',
                            builder: (context, state) {
                              final id = state.pathParameters['entityId']!;
                              return _deferred(
                                _moreScreens,
                                (_) => more.PlanSettingsScreen(entityId: id),
                              );
                            },
                            routes: [
                              GoRoute(
                                name: currencySettingsRoute,
                                path: 'currency',
                                builder: (context, state) {
                                  final id = state.pathParameters['entityId']!;
                                  return _deferred(
                                    _moreScreens,
                                    (_) => more.CurrencySettingsScreen(
                                      entityId: id,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          GoRoute(
                            name: appIconRoute,
                            path: 'app-icon',
                            builder: (context, state) {
                              final id = state.pathParameters['entityId']!;
                              return _deferred(
                                _moreScreens,
                                (_) => more.AppIconScreen(entityId: id),
                              );
                            },
                          ),
                          GoRoute(
                            name: accountSettingsRoute,
                            path: 'account-settings',
                            builder: (context, state) {
                              final id = state.pathParameters['entityId']!;
                              return _deferred(
                                _moreScreens,
                                (_) => more.AccountSettingsScreen(entityId: id),
                              );
                            },
                            routes: [
                              GoRoute(
                                name: deleteAccountRoute,
                                path: 'delete',
                                builder: (context, state) {
                                  final id = state.pathParameters['entityId']!;
                                  return _deferred(
                                    _moreScreens,
                                    (_) =>
                                        more.DeleteAccountScreen(entityId: id),
                                  );
                                },
                              ),
                            ],
                          ),
                          GoRoute(
                            name: displayOptionsRoute,
                            path: 'display',
                            builder: (context, state) {
                              final id = state.pathParameters['entityId']!;
                              return _deferred(
                                _moreScreens,
                                (_) => more.DisplayOptionsScreen(entityId: id),
                              );
                            },
                          ),
                          GoRoute(
                            name: assistantProviderRoute,
                            path: 'assistant-provider',
                            builder: (context, state) => _deferred(
                              _moreScreens,
                              (_) => more.AssistantProviderScreen(),
                            ),
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
            name: assistantRoute,
            path: 'assistant',
            builder: (context, state) {
              final id = state.pathParameters['entityId']!;
              return _deferred(
                _assistantScreens,
                (_) => assistant.AssistantScreen(entityId: id),
              );
            },
            routes: [
              GoRoute(
                name: assistantProposalsRoute,
                path: 'proposals',
                builder: (context, state) {
                  final id = state.pathParameters['entityId']!;
                  return _deferred(
                    _assistantScreens,
                    (_) => assistant.AssistantProposalsScreen(entityId: id),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            name: addIncomeRoute,
            path: 'income/add',
            builder: (context, state) {
              final id = state.pathParameters['entityId']!;
              return _deferred(
                _entryScreens,
                (_) => entry.AddIncomeScreen(entityId: id),
              );
            },
          ),
          GoRoute(
            name: addExpenseRoute,
            path: 'expenses/add',
            builder: (context, state) {
              final id = state.pathParameters['entityId']!;
              return _deferred(
                _entryScreens,
                (_) => entry.AddExpenseScreen(entityId: id),
              );
            },
          ),
          GoRoute(
            name: transactionListRoute,
            path: 'transactions',
            builder: (context, state) {
              final id = state.pathParameters['entityId']!;
              return _deferred(
                _entryScreens,
                (_) => entry.TransactionListScreen(entityId: id),
              );
            },
          ),
          GoRoute(
            name: createTransferRoute,
            path: 'transfer',
            builder: (context, state) {
              final id = state.pathParameters['entityId']!;
              return _deferred(
                _entryScreens,
                (_) => entry.CreateTransferScreen(entityId: id),
              );
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

class _StartupScreen extends HookWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
