import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transactions/screens/transaction_list_screen.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

void main() {
  const entityId = 'test-budget-1';

  final ownerId = UuidValue.fromString('00000000-0000-0000-0000-000000000099');

  Budget makeBudget() => Budget(
    id: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
    name: 'My Budget',
    currencyCode: 'USD',
    ownerId: ownerId,
    createdAt: DateTime(2026),
  );

  Transaction makeTx({
    required String id,
    required String description,
    required int amountMinor,
    String currencyCode = 'USD',
    DateTime? date,
    bool cleared = false,
    bool reconciled = false,
    String? flagColor,
    String? memo,
    UuidValue? payeeId,
    UuidValue? envelopeId,
    UuidValue? accountId,
    UuidValue? parentTransactionId,
  }) => Transaction(
    id: UuidValue.fromString(id),
    description: description,
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    entityId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
    transactionDate: date ?? DateTime(2026, 2, 15),
    cleared: cleared,
    reconciled: reconciled,
    flagColor: flagColor,
    memo: memo,
    payeeId: payeeId,
    envelopeId: envelopeId,
    accountId: accountId,
    parentTransactionId: parentTransactionId,
    createdAt: DateTime(2026),
  );

  final sampleTransactions = [
    makeTx(
      id: '00000000-0000-0000-0000-000000000010',
      description: 'Grocery Store',
      amountMinor: -5000,
      date: DateTime(2026, 2, 15),
    ),
    makeTx(
      id: '00000000-0000-0000-0000-000000000011',
      description: 'Monthly Salary',
      amountMinor: 300000,
      date: DateTime(2026, 2, 15),
    ),
    makeTx(
      id: '00000000-0000-0000-0000-000000000012',
      description: 'Coffee Shop',
      amountMinor: -450,
      date: DateTime(2026, 2, 14),
      cleared: true,
    ),
    makeTx(
      id: '00000000-0000-0000-0000-000000000013',
      description: 'Gas Station',
      amountMinor: -3500,
      date: DateTime(2026, 2, 14),
      flagColor: 'red',
      memo: 'Fill up for road trip',
    ),
  ];

  Widget buildSubject({
    List<Transaction>? transactions,
    List<Payee>? payees,
    List<Account>? accounts,
    BudgetSummary? summary,
  }) => ProviderScope(
    overrides: [
      transactionListProvider.overrideWith(
        (ref, id) async => transactions ?? sampleTransactions,
      ),
      budgetDetailProvider.overrideWith((ref, id) async => makeBudget()),
      budgetSummaryProvider.overrideWith(
        (ref, id) async =>
            summary ??
            BudgetSummary(
              budget: makeBudget(),
              categories: const [],
              totalIncomeMinor: 0,
              totalBudgetedMinor: 0,
              readyToAssignMinor: 0,
              year: 2026,
              month: 2,
            ),
      ),
      payeeListProvider.overrideWith((ref, id) async => payees ?? <Payee>[]),
      accountListProvider.overrideWith(
        (ref, id) async => accounts ?? <Account>[],
      ),
    ],
    child: MaterialApp(
      theme: OpenBudgetTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const TransactionListScreen(entityId: entityId),
    ),
  );

  group('TransactionListScreen', () {
    testWidgets('renders loading state initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TransactionListScreen(entityId: entityId),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ObLoadingPanel), findsOneWidget);
    });

    testWidgets('shows Transactions title in app bar', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Transactions'), findsOneWidget);
    });

    testWidgets('displays transaction descriptions', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Grocery Store'), findsOneWidget);
      expect(find.text('Monthly Salary'), findsOneWidget);
      expect(find.text('Coffee Shop'), findsOneWidget);
      expect(find.text('Gas Station'), findsOneWidget);
    });

    testWidgets('renders per-transaction currencies in amount labels', (
      tester,
    ) async {
      final mixedCurrencyTransactions = [
        makeTx(
          id: '00000000-0000-0000-0000-000000000021',
          description: 'USD Expense',
          amountMinor: -5000,
          date: DateTime(2026, 2, 15),
        ),
        makeTx(
          id: '00000000-0000-0000-0000-000000000022',
          description: 'EUR Income',
          amountMinor: 123456,
          currencyCode: 'EUR',
          date: DateTime(2026, 2, 15),
        ),
      ];

      await tester.pumpWidget(
        buildSubject(transactions: mixedCurrencyTransactions),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining(r'-$50.00'), findsOneWidget);
      expect(find.textContaining('€1,234.56'), findsOneWidget);
    });

    testWidgets('shows search field', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.search,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows filter chips (All, Income, Expense)', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
    });

    testWidgets('shows result count', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.textContaining('4'), findsWidgets);
    });

    testWidgets('shows empty state when no transactions', (tester) async {
      await tester.pumpWidget(buildSubject(transactions: []));
      await tester.pumpAndSettle();

      expect(find.byKey(transactionListEmptyKey), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is WiredDoodle && w.kind == WiredDoodleKind.leaf,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders problem panel with retry on load failure', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            transactionListProvider.overrideWith(
              (ref, id) => throw Exception('Could not load transactions'),
            ),
          ],
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TransactionListScreen(entityId: entityId),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not load transactions'), findsOneWidget);
      expect(find.byType(ObStatePanel), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is WiredDoodle && w.kind == WiredDoodleKind.cloud,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows app bar actions when transactions exist', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Sort button
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.sort,
        ),
        findsOneWidget,
      );
      // Selection mode button
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.checkAll,
        ),
        findsOneWidget,
      );
      // CSV export button
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.copy,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows add transaction FAB', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.add,
        ),
        findsOneWidget,
      );
    });

    testWidgets('tapping add FAB opens add transaction sheet', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.text('Add Income'), findsOneWidget);
      expect(find.text('Add Expense'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);
    });

    testWidgets('hides app bar actions when transactions empty', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(transactions: []));
      await tester.pumpAndSettle();

      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.sort,
        ),
        findsNothing,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.checkAll,
        ),
        findsNothing,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.copy,
        ),
        findsNothing,
      );
    });

    testWidgets('filtering by Income shows only income transactions', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      expect(find.text('Monthly Salary'), findsOneWidget);
      expect(find.text('Grocery Store'), findsNothing);
      expect(find.text('Coffee Shop'), findsNothing);
      expect(find.text('Gas Station'), findsNothing);
    });

    testWidgets('filtering by Expense shows only expense transactions', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Monthly Salary'), findsNothing);
      expect(find.text('Grocery Store'), findsOneWidget);
      expect(find.text('Coffee Shop'), findsOneWidget);
      expect(find.text('Gas Station'), findsOneWidget);
    });

    testWidgets('search filters by description', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Coffee');
      await tester.pumpAndSettle();

      expect(find.text('Coffee Shop'), findsOneWidget);
      expect(find.text('Grocery Store'), findsNothing);
      expect(find.text('Monthly Salary'), findsNothing);
      expect(find.text('Gas Station'), findsNothing);
    });

    testWidgets('search filters by memo', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'road trip');
      await tester.pumpAndSettle();

      expect(find.text('Gas Station'), findsOneWidget);
      expect(find.text('Grocery Store'), findsNothing);
    });

    testWidgets('search clear button resets search', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Coffee');
      await tester.pumpAndSettle();
      expect(find.text('Coffee Shop'), findsOneWidget);
      expect(find.text('Grocery Store'), findsNothing);

      // Tap the clear icon in the search field
      await tester.tap(find.byKey(const Key('transaction-search-clear')));
      await tester.pumpAndSettle();

      // All transactions visible again
      expect(find.text('Grocery Store'), findsOneWidget);
      expect(find.text('Coffee Shop'), findsOneWidget);
    });

    testWidgets('shows memo text on transaction with memo', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Fill up for road trip'), findsOneWidget);
    });

    testWidgets('shows status and flag chips on transaction rows', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Coffee Shop is cleared, the other three are not; Gas Station is
      // flagged red, and every expense is unassigned without a summary.
      expect(find.text('Cleared'), findsOneWidget);
      expect(find.text('Uncleared'), findsNWidgets(3));
      expect(find.text('Red'), findsOneWidget);
      expect(find.text('Unassigned'), findsNWidgets(3));
      expect(find.byType(ObToneChip), findsWidgets);
    });

    testWidgets('tapping selection mode button enters selection mode', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.checkAll,
        ),
      );
      await tester.pumpAndSettle();

      // Selection mode shows close button and select/deselect all
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.close,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.selectAll,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.deselect,
        ),
        findsOneWidget,
      );
      // Normal app bar should be gone
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.sort,
        ),
        findsNothing,
      );
    });

    testWidgets('close button exits selection mode', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.checkAll,
        ),
      );
      await tester.pumpAndSettle();

      // Exit selection mode
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.close,
        ),
      );
      await tester.pumpAndSettle();

      // Back to normal app bar
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.sort,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.close,
        ),
        findsNothing,
      );
    });

    testWidgets('select all selects all transactions', (tester) async {
      // The ledger rows carry payee, envelope, and status detail, so use a
      // taller surface to keep all four rows on screen with the bulk bar up.
      tester.view.physicalSize = const Size(640, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.checkAll,
        ),
      );
      await tester.pumpAndSettle();

      // Select all
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.selectAll,
        ),
      );
      await tester.pumpAndSettle();

      // Shows count in app bar title — "4 selected"
      expect(find.textContaining('4'), findsWidgets);
      // Checkboxes should appear
      expect(find.byType(Checkbox), findsNWidgets(4));
    });

    testWidgets('deselect all clears selection', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.checkAll,
        ),
      );
      await tester.pumpAndSettle();

      // Select all then deselect all
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.selectAll,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.deselect,
        ),
      );
      await tester.pumpAndSettle();

      // Bottom bar should not be visible (no items selected)
      expect(find.byKey(const Key('bulk-delete-button')), findsNothing);
    });

    testWidgets('bottom action bar appears when transactions are selected', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.checkAll,
        ),
      );
      await tester.pumpAndSettle();

      // Select all
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.selectAll,
        ),
      );
      await tester.pumpAndSettle();

      // Bottom bar should show action buttons
      expect(find.text('Assign Envelope'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.flag,
        ),
        findsWidgets,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.checkCircle,
        ),
        findsWidgets,
      );
      expect(find.byKey(const Key('bulk-delete-button')), findsOneWidget);
    });

    testWidgets('tapping delete shows confirmation dialog', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter selection mode and select all
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.checkAll,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.selectAll,
        ),
      );
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byKey(const Key('bulk-delete-button')));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Delete Transactions'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('cancel on bulk delete dialog dismisses it', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter selection mode and select all
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.checkAll,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.selectAll,
        ),
      );
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byKey(const Key('bulk-delete-button')));
      await tester.pumpAndSettle();

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog dismissed, still in selection mode
      expect(find.text('Delete Transactions'), findsNothing);
      expect(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.close,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows date group headers', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // The transactions span two dates (Feb 15 and Feb 14, 2026)
      // Date headers should be present
      expect(find.textContaining('February'), findsWidgets);
    });

    testWidgets('shows sort menu with sort options', (tester) async {
      // Use a tall surface to avoid bottom sheet overflow.
      tester.view.physicalSize = const Size(640, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.sort,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sort by'), findsOneWidget);
      expect(find.text('Date (newest first)'), findsOneWidget);
      expect(find.text('Date (oldest first)'), findsOneWidget);
      expect(find.text('Amount (highest first)'), findsOneWidget);
      expect(find.text('Amount (lowest first)'), findsOneWidget);
      expect(find.text('Description (A-Z)'), findsOneWidget);
    });

    testWidgets('shows no-results state when search yields nothing', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'nonexistentxyz');
      await tester.pumpAndSettle();

      expect(find.byKey(transactionListEmptyKey), findsOneWidget);
    });

    testWidgets('shows checkbox on each transaction in selection mode', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.checkAll,
        ),
      );
      await tester.pumpAndSettle();

      // Each of the 4 transactions should have a checkbox
      expect(find.byType(Checkbox), findsNWidgets(4));
    });

    testWidgets('tapping a checkbox selects that transaction', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SkribbleIcon && w.data == OpenBudgetIcons.checkAll,
        ),
      );
      await tester.pumpAndSettle();

      // Tap the first transaction card to toggle selection
      await tester.tap(find.text('Grocery Store'));
      await tester.pumpAndSettle();

      // Shows "1 selected" in app bar
      expect(find.textContaining('1'), findsWidgets);
    });
  });
}
