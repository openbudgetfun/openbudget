import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_realtime_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/budget_shell_screen.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  const entityId = 'test-budget-1';

  Widget buildSubject() {
    // Use non-parameterized paths to satisfy GoRouter constraints in tests.
    final router = GoRouter(
      initialLocation: '/plan',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => BudgetShellScreen(
            navigationShell: navigationShell,
            entityId: entityId,
          ),
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/plan',
                  builder: (_, _) =>
                      const Scaffold(body: Center(child: Text('Plan Tab'))),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/accounts',
                  builder: (_, _) =>
                      const Scaffold(body: Center(child: Text('Accounts Tab'))),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/reflect',
                  builder: (_, _) =>
                      const Scaffold(body: Center(child: Text('Reflect Tab'))),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/more',
                  builder: (_, _) =>
                      const Scaffold(body: Center(child: Text('More Tab'))),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    return ProviderScope(
      overrides: [budgetRealtimeProvider.overrideWith((ref, entityId) {})],
      child: MaterialApp.router(
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    );
  }

  group('BudgetShellScreen', () {
    testWidgets('renders five navigation destinations', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });

    testWidgets('renders tab labels', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Plan'), findsOneWidget);
      expect(find.text('Accounts'), findsOneWidget);
      expect(find.text('Add'), findsOneWidget);
      expect(find.text('Reflect'), findsOneWidget);
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('draws the Add tab as a pink sticker', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final plus = find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.add,
        ),
      );
      expect(plus, findsOneWidget);
      final sticker = tester.widget<Container>(
        find.ancestor(of: plus, matching: find.byType(Container)).first,
      );
      final decoration = sticker.decoration! as ObRoughDecoration;
      expect(decoration.color, const ObPalette.paper().action);
      expect(decoration.shadow, const ObPalette.paper().printShadow);
    });

    testWidgets('shows Plan tab content initially', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Plan Tab'), findsOneWidget);
    });

    testWidgets('tapping Accounts tab navigates to accounts', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Accounts'));
      await tester.pumpAndSettle();

      expect(find.text('Accounts Tab'), findsOneWidget);
    });

    testWidgets('tapping Add tab shows bottom sheet', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // The add transaction sheet should appear
      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.text('Add Income'), findsOneWidget);
      expect(find.text('Add Expense'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
    });

    testWidgets('tapping Reflect tab navigates to reports', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reflect'));
      await tester.pumpAndSettle();

      expect(find.text('Reflect Tab'), findsOneWidget);
    });

    testWidgets('android back navigates through tab history', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Accounts'));
      await tester.pumpAndSettle();
      expect(find.text('Accounts Tab'), findsOneWidget);

      await tester.tap(find.text('Reflect'));
      await tester.pumpAndSettle();
      expect(find.text('Reflect Tab'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Accounts Tab'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Plan Tab'), findsOneWidget);
    });

    testWidgets('tapping More tab navigates to more', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      expect(find.text('More Tab'), findsOneWidget);
    });

    testWidgets('re-tapping More tab opens quick actions sheet', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('More'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Recurring Transactions'), findsOneWidget);
      expect(find.text('Payees'), findsOneWidget);
    });
  });
}
