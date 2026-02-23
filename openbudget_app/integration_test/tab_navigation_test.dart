import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_shell_screen.dart';
import 'package:patrol/patrol.dart';

const _budgetId = 'test-budget-id';

Widget _buildApp() {
  final router = GoRouter(
    initialLocation: '/plan',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => BudgetShellScreen(
          navigationShell: navigationShell,
          budgetId: _budgetId,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/plan',
                builder: (_, __) =>
                    const Scaffold(body: Center(child: Text('Plan Tab'))),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/accounts',
                builder: (_, __) =>
                    const Scaffold(body: Center(child: Text('Accounts Tab'))),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reflect',
                builder: (_, __) =>
                    const Scaffold(body: Center(child: Text('Reflect Tab'))),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (_, __) =>
                    const Scaffold(body: Center(child: Text('More Tab'))),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  return MaterialApp.router(
    theme: ThemeData.light(useMaterial3: true),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}

void main() {
  patrolWidgetTest('bottom navigation bar renders all five tabs', ($) async {
    final tester = $.tester;
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Plan'), findsOneWidget);
    expect(find.text('Accounts'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
    expect(find.text('Reflect'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });

  patrolWidgetTest('tapping Accounts tab shows accounts content', ($) async {
    final tester = $.tester;
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Accounts'));
    await tester.pumpAndSettle();

    expect(find.text('Accounts Tab'), findsOneWidget);
  });

  patrolWidgetTest('tapping Add tab shows add transaction sheet', ($) async {
    final tester = $.tester;
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Add Transaction'), findsOneWidget);
    expect(find.text('Add Income'), findsOneWidget);
    expect(find.text('Add Expense'), findsOneWidget);
    expect(find.text('Transfer'), findsOneWidget);
  });

  patrolWidgetTest('dismissing add sheet keeps plan tab visible', ($) async {
    final tester = $.tester;
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('Plan Tab'), findsOneWidget);
  });

  patrolWidgetTest('tab switching works across reflect and more tabs', (
    $,
  ) async {
    final tester = $.tester;
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reflect'));
    await tester.pumpAndSettle();
    expect(find.text('Reflect Tab'), findsOneWidget);

    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    expect(find.text('More Tab'), findsOneWidget);

    await tester.tap(find.text('Plan'));
    await tester.pumpAndSettle();
    expect(find.text('Plan Tab'), findsOneWidget);
  });
}
