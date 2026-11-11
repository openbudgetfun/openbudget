import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/add_transaction_sheet.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transactions/screens/add_expense_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/add_income_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/transaction_list_screen.dart';
import 'package:openbudget_app/src/features/transfers/screens/create_transfer_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:patrol/patrol.dart';

const _entityId = 'test-budget-id';
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
  totalIncomeMinor: 0,
  totalBudgetedMinor: 0,
  readyToAssignMinor: 0,
  year: 2026,
  month: 9,
);

Transaction _makeTransaction({
  required String id,
  required String description,
  required int amountMinor,
  DateTime? transactionDate,
  bool cleared = false,
  bool reconciled = false,
}) => Transaction(
  id: UuidValue.fromString(id),
  description: description,
  amountMinor: amountMinor,
  currencyCode: 'USD',
  entityId: _budgetUuid,
  accountId: UuidValue.fromString('00000000-0000-0000-0000-000000000111'),
  transactionDate: transactionDate ?? DateTime(2026, 9, 4),
  cleared: cleared,
  reconciled: reconciled,
);

Account _makeAccount({
  required String id,
  required String name,
  required String currencyCode,
}) => Account(
  id: UuidValue.fromString(id),
  name: name,
  accountType: 'checking',
  balanceMinor: 0,
  currencyCode: currencyCode,
  entityId: _budgetUuid,
  onBudget: true,
  sortOrder: 0,
  isClosed: false,
);

Widget _buildApp({String? initialLocation}) {
  final router = GoRouter(
    initialLocation: initialLocation ?? '/budgets/$_entityId/plan',
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
                    AddTransactionSheet(entityId: state.pathParameters['entityId']!),
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
            AddIncomeScreen(entityId: state.pathParameters['entityId']!),
      ),
      GoRoute(
        name: addExpenseRoute,
        path: addExpensePath,
        builder: (context, state) =>
            AddExpenseScreen(entityId: state.pathParameters['entityId']!),
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

Widget _buildTransferFlowApp({
  required List<Account> accounts,
  String? initialLocation,
}) {
  final router = GoRouter(
    initialLocation: initialLocation ?? '/budgets/$_entityId/plan',
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
                    AddTransactionSheet(entityId: state.pathParameters['entityId']!),
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
            AddIncomeScreen(entityId: state.pathParameters['entityId']!),
      ),
      GoRoute(
        name: addExpenseRoute,
        path: addExpensePath,
        builder: (context, state) =>
            AddExpenseScreen(entityId: state.pathParameters['entityId']!),
      ),
      GoRoute(
        name: createTransferRoute,
        path: createTransferPath,
        builder: (context, state) =>
            CreateTransferScreen(entityId: state.pathParameters['entityId']!),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
      budgetSummaryProvider.overrideWith((ref, id) async => _makeSummary()),
      payeeListProvider.overrideWith((ref, id) async => const []),
      accountListProvider.overrideWith((ref, id) async => accounts),
    ],
    child: MaterialApp.router(
      theme: ThemeData.light(useMaterial3: true),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

Widget _buildTransactionListApp({required List<Transaction> transactions}) {
  final router = GoRouter(
    initialLocation: '/budgets/$_entityId/transactions',
    routes: [
      GoRoute(
        name: planRoute,
        path: planPath,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Plan Route'))),
      ),
      GoRoute(
        name: transactionListRoute,
        path: transactionListPath,
        builder: (context, state) =>
            TransactionListScreen(entityId: state.pathParameters['entityId']!),
      ),
      GoRoute(
        name: addIncomeRoute,
        path: addIncomePath,
        builder: (context, state) =>
            AddIncomeScreen(entityId: state.pathParameters['entityId']!),
      ),
      GoRoute(
        name: addExpenseRoute,
        path: addExpensePath,
        builder: (context, state) =>
            AddExpenseScreen(entityId: state.pathParameters['entityId']!),
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
      transactionListProvider.overrideWith((ref, id) async => transactions),
      budgetDetailProvider.overrideWith((ref, id) async => _makeBudget()),
      budgetSummaryProvider.overrideWith((ref, id) async => _makeSummary()),
      payeeListProvider.overrideWith((ref, id) async => const []),
      accountListProvider.overrideWith((ref, id) async => const []),
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
  patrolWidgetTest('add expense route renders add expense screen', ($) async {
    final tester = $.tester;
    await tester.pumpWidget(
      _buildApp(initialLocation: '/budgets/$_entityId/expenses/add'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AddExpenseScreen), findsOneWidget);
  });

  patrolWidgetTest('add income route renders add income screen', ($) async {
    final tester = $.tester;
    await tester.pumpWidget(
      _buildApp(initialLocation: '/budgets/$_entityId/income/add'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AddIncomeScreen), findsOneWidget);
  });

  patrolWidgetTest('expense screen mode switch routes to income screen', (
    $,
  ) async {
    final tester = $.tester;
    await tester.pumpWidget(
      _buildApp(initialLocation: '/budgets/$_entityId/expenses/add'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'Add Income'));
    await tester.pumpAndSettle();

    expect(find.byType(AddIncomeScreen), findsOneWidget);
  });

  patrolWidgetTest('income screen mode switch routes to expense screen', (
    $,
  ) async {
    final tester = $.tester;
    await tester.pumpWidget(
      _buildApp(initialLocation: '/budgets/$_entityId/income/add'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'Add Expense'));
    await tester.pumpAndSettle();

    expect(find.byType(AddExpenseScreen), findsOneWidget);
  });

  patrolWidgetTest('transfer route renders transfer scaffold', ($) async {
    final tester = $.tester;
    await tester.pumpWidget(
      _buildApp(initialLocation: '/budgets/$_entityId/transfer'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Transfer Route'), findsOneWidget);
  });

  patrolWidgetTest(
    'transfer flow prevents selecting same account for source and destination',
    ($) async {
      final tester = $.tester;
      await tester.pumpWidget(
        _buildTransferFlowApp(
          accounts: [
            _makeAccount(
              id: '00000000-0000-0000-0000-000000000601',
              name: 'Checking',
              currencyCode: 'USD',
            ),
            _makeAccount(
              id: '00000000-0000-0000-0000-000000000602',
              name: 'Savings',
              currencyCode: 'USD',
            ),
            _makeAccount(
              id: '00000000-0000-0000-0000-000000000603',
              name: 'Euro Wallet',
              currencyCode: 'EUR',
            ),
          ],
          initialLocation: '/budgets/$_entityId/transfer',
        ),
      );
      await tester.pumpAndSettle();

      final sourceDropdown = find.byType(DropdownButtonFormField<String>).at(0);
      final destinationDropdown = find
          .byType(DropdownButtonFormField<String>)
          .at(1);

      await tester.tap(destinationDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Checking (USD)').last);
      await tester.pumpAndSettle();

      await tester.tap(sourceDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Checking (USD)').last);
      await tester.pumpAndSettle();

      expect(find.text('Checking (USD)'), findsOneWidget);

      await tester.tap(destinationDropdown);
      await tester.pumpAndSettle();

      expect(find.text('Checking (USD)'), findsOneWidget);
      expect(find.text('Savings (USD)'), findsOneWidget);
      expect(find.text('Euro Wallet (EUR)'), findsNothing);
    },
  );

  patrolWidgetTest('cancel from add expense returns to plan route', ($) async {
    final tester = $.tester;
    await tester.pumpWidget(
      _buildApp(initialLocation: '/budgets/$_entityId/expenses/add'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Plan Route'), findsOneWidget);
  });

  patrolWidgetTest('cancel from add income returns to plan route', ($) async {
    final tester = $.tester;
    await tester.pumpWidget(
      _buildApp(initialLocation: '/budgets/$_entityId/income/add'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Plan Route'), findsOneWidget);
  });

  patrolWidgetTest('transaction list status filter shows only uncleared rows', (
    $,
  ) async {
    final tester = $.tester;
    await tester.pumpWidget(
      _buildTransactionListApp(
        transactions: [
          _makeTransaction(
            id: '00000000-0000-0000-0000-000000000301',
            description: 'Grocery Store',
            amountMinor: -5000,
          ),
          _makeTransaction(
            id: '00000000-0000-0000-0000-000000000302',
            description: 'Rent',
            amountMinor: -280000,
            cleared: true,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Grocery Store'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);

    await tester.tap(find.text('Status'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Uncleared'));
    await tester.pumpAndSettle();

    expect(find.text('Grocery Store'), findsOneWidget);
    expect(find.text('Rent'), findsNothing);
  });

  patrolWidgetTest('tapping transaction row opens edit dialog', ($) async {
    final tester = $.tester;
    await tester.pumpWidget(
      _buildTransactionListApp(
        transactions: [
          _makeTransaction(
            id: '00000000-0000-0000-0000-000000000401',
            description: 'Grocery Store',
            amountMinor: -5000,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Grocery Store'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Transaction'), findsOneWidget);
  });

  patrolWidgetTest('long press transaction row opens flag action sheet', (
    $,
  ) async {
    final tester = $.tester;
    await tester.pumpWidget(
      _buildTransactionListApp(
        transactions: [
          _makeTransaction(
            id: '00000000-0000-0000-0000-000000000501',
            description: 'Grocery Store',
            amountMinor: -5000,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Grocery Store'));
    await tester.pumpAndSettle();

    expect(find.text('Set Flag'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, 'Red'), findsOneWidget);
  });
}
