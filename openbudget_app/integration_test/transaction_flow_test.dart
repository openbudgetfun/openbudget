import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/add_transaction_sheet.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_pages_provider.dart';
import 'package:openbudget_app/src/features/transactions/screens/add_expense_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/add_income_screen.dart';
import 'package:openbudget_app/src/features/transactions/screens/transaction_list_screen.dart';
import 'package:openbudget_app/src/features/transfers/screens/create_transfer_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:patrol/patrol.dart';

import 'common/test_data.dart';

const String _entityId = TestData.gbpEntityId;
final UuidValue _entityUuid = UuidValue.fromString(_entityId);

TransactionView _makeTransactionView(
  Transaction transaction,
) => TransactionView(
  transaction: transaction,
  lines: [
    TransactionLine(
      id: UuidValue.fromString(
        '00000000-0000-0000-0000-0000000007${transaction.id.hashCode.abs() % 90 + 10}',
      ),
      transactionId: transaction.id!,
      amountMinor: transaction.amountMinor,
      baseAmountMinor: transaction.baseAmountMinor,
    ),
  ],
  accountCurrencyCode: transaction.amountMinor < 0 ? 'USD' : 'USD',
  accountName: 'Daily USD',
);

TransactionView _makeTransaction({
  required String id,
  required String description,
  required int amountMinor,
  DateTime? date,
  bool cleared = false,
}) => _makeTransactionView(
  Transaction(
    id: UuidValue.fromString(id),
    entityId: _entityUuid,
    accountId: UuidValue.fromString('00000000-0000-0000-0000-000000000111'),
    date: date ?? DateTime(2026, 9, 4),
    amountMinor: amountMinor,
    baseAmountMinor: amountMinor,
    fxRateDate: date ?? DateTime(2026, 9, 4),
    description: description,
    status: cleared ? TransactionStatus.cleared : TransactionStatus.uncleared,
  ),
);

/// The paged list backed by an in-memory page, with server-side style
/// filtering applied locally so the flow never builds a client.
/// The month view the grouped list reads its base currency from.
BudgetMonthView _makeMonthView() => BudgetMonthView(
  entityId: UuidValue.fromString(_entityId),
  month: 202611,
  currencyCode: 'USD',
  summary: BudgetMonthSummary(
    month: 202611,
    incomeMinor: 0,
    uncategorizedMinor: 0,
    fxDifferenceMinor: 0,
    allocatedMinor: 0,
    activityMinor: 0,
    overspentLastMonthMinor: 0,
    assignedInFutureMinor: 0,
    readyToAssignMinor: 0,
    availableMinor: 0,
  ),
  categories: const [],
  envelopes: const [],
);

class _FakeTransactionPages extends TransactionPages {
  _FakeTransactionPages(this.items);

  final List<TransactionView> items;

  @override
  Future<TransactionPageState> build(String entityId) async =>
      TransactionPageState(filter: const TransactionFilter(), items: items);

  @override
  Future<void> apply(TransactionFilter filter) async {
    final filtered = items.where((view) {
      if (filter.status != null && view.transaction.status != filter.status) {
        return false;
      }
      final search = filter.search;
      final description = view.transaction.description.toLowerCase();
      if (search != null &&
          search.isNotEmpty &&
          !description.contains(search.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
    state = AsyncValue.data(
      TransactionPageState(filter: filter, items: filtered),
    );
  }
}

Widget _buildFormApp({String? initialLocation}) {
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
                builder: (_) => AddTransactionSheet(
                  entityId: state.pathParameters['entityId']!,
                ),
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
      entityDetailProvider.overrideWith(
        (ref, id) async => TestData.usdEntity(),
      ),
      accountListProvider.overrideWith(
        (ref, id) async => [TestData.checkingAccount()],
      ),
      payeeListProvider.overrideWith((ref, id) async => const []),
      budgetMonthGroupsProvider.overrideWith((ref, id) async => const []),
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
                builder: (_) => AddTransactionSheet(
                  entityId: state.pathParameters['entityId']!,
                ),
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
      entityDetailProvider.overrideWith(
        (ref, id) async => TestData.usdEntity(),
      ),
      payeeListProvider.overrideWith((ref, id) async => const []),
      budgetMonthGroupsProvider.overrideWith((ref, id) async => const []),
      accountListAllProvider.overrideWith((ref) async => accounts),
    ],
    child: MaterialApp.router(
      theme: ThemeData.light(useMaterial3: true),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    ),
  );
}

Widget _buildTransactionListApp({
  required List<TransactionView> transactions,
}) {
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
      transactionPagesProvider.overrideWith2(
        (entityId) => _FakeTransactionPages(transactions),
      ),
      entityDetailProvider.overrideWith(
        (ref, id) async => TestData.usdEntity(),
      ),
      // The grouped list reads the month view's currency; the real provider
      // would leave a pending server connection behind.
      budgetMonthProvider.overrideWith(
        (ref, entityId) async => _makeMonthView(),
      ),
      payeeListProvider.overrideWith((ref, id) async => const []),
      budgetMonthGroupsProvider.overrideWith((ref, id) async => const []),
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
      _buildFormApp(initialLocation: '/budgets/$_entityId/expenses/add'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AddExpenseScreen), findsOneWidget);
  });

  patrolWidgetTest('add income route renders add income screen', ($) async {
    final tester = $.tester;
    await tester.pumpWidget(
      _buildFormApp(initialLocation: '/budgets/$_entityId/income/add'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AddIncomeScreen), findsOneWidget);
  });

  patrolWidgetTest('expense screen mode switch routes to income screen', (
    $,
  ) async {
    final tester = $.tester;
    await tester.pumpWidget(
      _buildFormApp(initialLocation: '/budgets/$_entityId/expenses/add'),
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
      _buildFormApp(initialLocation: '/budgets/$_entityId/income/add'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'Add Expense'));
    await tester.pumpAndSettle();

    expect(find.byType(AddExpenseScreen), findsOneWidget);
  });

  patrolWidgetTest('transfer route renders transfer scaffold', ($) async {
    final tester = $.tester;
    await tester.pumpWidget(
      _buildFormApp(initialLocation: '/budgets/$_entityId/transfer'),
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
            TestData.checkingAccount(name: 'Checking', currencyCode: 'USD'),
            TestData.checkingAccount(
              id: '00000000-0000-0000-0000-000000000602',
              name: 'Savings',
              currencyCode: 'USD',
            ),
            TestData.checkingAccount(
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

      // Pick Checking for the destination.
      await tester.tap(destinationDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Checking (USD)').last);
      await tester.pumpAndSettle();

      // The source picker excludes the destination's account entirely, so
      // the same account cannot be selected on both sides.
      await tester.tap(sourceDropdown);
      await tester.pumpAndSettle();
      expect(find.text('Checking (USD)'), findsOneWidget);
      expect(find.text('Savings (USD)'), findsOneWidget);
      expect(find.text('Euro Wallet (EUR)'), findsOneWidget);

      // Pick Savings as the source; the destination picker excludes it too.
      await tester.tap(find.text('Savings (USD)').last);
      await tester.pumpAndSettle();
      await tester.tap(destinationDropdown);
      await tester.pumpAndSettle();
      expect(find.text('Savings (USD)'), findsOneWidget);
      expect(find.text('Euro Wallet (EUR)'), findsOneWidget);
    },
  );

  patrolWidgetTest('cancel from add expense returns to plan route', ($) async {
    final tester = $.tester;
    await tester.pumpWidget(
      _buildFormApp(initialLocation: '/budgets/$_entityId/expenses/add'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Plan Route'), findsOneWidget);
  });

  patrolWidgetTest('cancel from add income returns to plan route', ($) async {
    final tester = $.tester;
    await tester.pumpWidget(
      _buildFormApp(initialLocation: '/budgets/$_entityId/income/add'),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Plan Route'), findsOneWidget);
  });

  patrolWidgetTest(
    'transaction list status filter shows only uncleared rows',
    ($) async {
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
    },
  );

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
