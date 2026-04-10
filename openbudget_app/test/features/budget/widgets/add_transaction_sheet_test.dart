import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/widgets/add_transaction_sheet.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const budgetId = 'test-budget-1';

  Widget buildSubject() => MaterialApp(
    theme: OpenBudgetTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(
      // Render the sheet directly as a child instead of via
      // showModalBottomSheet to avoid layout overflow in tests.
      body: AddTransactionSheet(budgetId: budgetId),
    ),
  );

  Widget buildRoutingSubject() {
    final router = GoRouter(
      initialLocation: '/host',
      routes: [
        GoRoute(
          path: '/host',
          builder: (context, state) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  final action =
                      await showModalBottomSheet<AddTransactionAction>(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) =>
                            const AddTransactionSheet(budgetId: budgetId),
                      );
                  if (!context.mounted || action == null) return;
                  switch (action) {
                    case AddTransactionAction.income:
                      context.goNamed(
                        addIncomeRoute,
                        pathParameters: {'id': budgetId},
                      );
                    case AddTransactionAction.expense:
                      context.goNamed(
                        addExpenseRoute,
                        pathParameters: {'id': budgetId},
                      );
                    case AddTransactionAction.transfer:
                      context.goNamed(
                        createTransferRoute,
                        pathParameters: {'id': budgetId},
                      );
                  }
                },
                child: const Text('Open Add Sheet'),
              ),
            ),
          ),
        ),
        GoRoute(
          name: addIncomeRoute,
          path: addIncomePath,
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Income Route'))),
        ),
        GoRoute(
          name: addExpenseRoute,
          path: addExpensePath,
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Expense Route'))),
        ),
        GoRoute(
          name: createTransferRoute,
          path: createTransferPath,
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('Transfer Route'))),
        ),
      ],
    );

    return MaterialApp.router(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }

  group('AddTransactionSheet', () {
    testWidgets('renders title and three action tiles', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.text('Add Income'), findsOneWidget);
      expect(find.text('Add Expense'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
    });

    testWidgets('renders action icons', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
    });

    testWidgets('renders three action cards', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // 3 action tiles = 3 Card widgets
      expect(find.byType(Card), findsNWidgets(3));
    });

    testWidgets('renders chevron trailing icons', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right_rounded), findsNWidgets(3));
    });

    testWidgets('navigates to add income route from sheet action', (
      tester,
    ) async {
      await tester.pumpWidget(buildRoutingSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Add Sheet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Income'));
      await tester.pumpAndSettle();

      expect(find.text('Income Route'), findsOneWidget);
    });

    testWidgets('navigates to add expense route from sheet action', (
      tester,
    ) async {
      await tester.pumpWidget(buildRoutingSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Add Sheet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Expense Route'), findsOneWidget);
    });

    testWidgets('navigates to transfer route from sheet action', (
      tester,
    ) async {
      await tester.pumpWidget(buildRoutingSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Add Sheet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      expect(find.text('Transfer Route'), findsOneWidget);
    });
  });
}
