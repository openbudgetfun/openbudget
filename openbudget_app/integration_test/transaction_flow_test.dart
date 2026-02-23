// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/add_transaction_sheet.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transactions/screens/add_expense_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/add_income_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';

const _budgetId = 'test-budget-id';
final _budgetUuid = UuidValue.fromString(
  '00000000-0000-0000-0000-000000000010',
);
final _ownerUuid = UuidValue.fromString('00000000-0000-0000-0000-000000000099');

Budget _makeBudget() => Budget(
  id: _budgetUuid,
  name: 'OpenBudget',
  currencyCode: 'USD',
  ownerId: _ownerUuid,
  createdAt: DateTime(2026),
);

BudgetSummary _makeSummary() => BudgetSummary(
  budget: _makeBudget(),
  categories: const [],
  totalIncomeCents: 0,
  totalBudgetedCents: 0,
  readyToAssignCents: 0,
  year: 2026,
  month: 9,
);

Widget _buildApp() {
  final router = GoRouter(
    initialLocation: '/budgets/$_budgetId/plan',
    routes: [
      GoRoute(
        name: planRoute,
        path: planPath,
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Plan Route')),
          body: Center(
            child: FilledButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) =>
                    AddTransactionSheet(budgetId: state.pathParameters['id']!),
              ),
              child: const Text('Open Add Sheet'),
            ),
          ),
        ),
      ),
      GoRoute(
        name: addIncomeRoute,
        path: addIncomePath,
        builder: (context, state) =>
            AddIncomeScreen(budgetId: state.pathParameters['id']!),
      ),
      GoRoute(
        name: addExpenseRoute,
        path: addExpensePath,
        builder: (context, state) =>
            AddExpenseScreen(budgetId: state.pathParameters['id']!),
      ),
      GoRoute(
        name: createTransferRoute,
        path: createTransferPath,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Transfer Route'))),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
      budgetSummaryProvider.overrideWith((ref, id) async => _makeSummary()),
      payeeListProvider.overrideWith((ref, id) async => const []),
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

  testWidgets('add transaction sheet routes to add expense', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Add Sheet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Expense'));
    await tester.pumpAndSettle();

    expect(find.text('Add Expense'), findsNWidgets(2));
  });

  testWidgets('add transaction sheet routes to add income', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Add Sheet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Income'));
    await tester.pumpAndSettle();

    expect(find.text('Add Income'), findsNWidgets(2));
  });

  testWidgets('expense screen mode switch routes to income screen', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Add Sheet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Income').first);
    await tester.pumpAndSettle();

    expect(find.text('Add Income'), findsNWidgets(2));
  });

  testWidgets('income screen mode switch routes to expense screen', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Add Sheet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Income'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Expense').first);
    await tester.pumpAndSettle();

    expect(find.text('Add Expense'), findsNWidgets(2));
  });

  testWidgets('add transaction sheet routes to transfer', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Add Sheet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();

    expect(find.text('Transfer Route'), findsOneWidget);
  });

  testWidgets('cancel from add expense returns to plan route', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Add Sheet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Plan Route'), findsOneWidget);
  });

  testWidgets('cancel from add income returns to plan route', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Add Sheet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Income'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Plan Route'), findsOneWidget);
  });
}
