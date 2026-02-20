// Serverpod's UuidValue.fromString is marked experimental.
// ignore_for_file: experimental_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
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
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const budgetId = 'test-budget-1';

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
    required int amountCents,
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
    amountCents: amountCents,
    currencyCode: currencyCode,
    budgetId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
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
      amountCents: -5000,
      date: DateTime(2026, 2, 15),
    ),
    makeTx(
      id: '00000000-0000-0000-0000-000000000011',
      description: 'Monthly Salary',
      amountCents: 300000,
      date: DateTime(2026, 2, 15),
    ),
    makeTx(
      id: '00000000-0000-0000-0000-000000000012',
      description: 'Coffee Shop',
      amountCents: -450,
      date: DateTime(2026, 2, 14),
      cleared: true,
    ),
    makeTx(
      id: '00000000-0000-0000-0000-000000000013',
      description: 'Gas Station',
      amountCents: -3500,
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
  }) {
    return ProviderScope(
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
                totalIncomeCents: 0,
                totalBudgetedCents: 0,
                readyToAssignCents: 0,
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
        home: const TransactionListScreen(budgetId: budgetId),
      ),
    );
  }

  group('TransactionListScreen', () {
    testWidgets('renders loading state initially', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const TransactionListScreen(budgetId: budgetId),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
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
          amountCents: -5000,
          date: DateTime(2026, 2, 15),
        ),
        makeTx(
          id: '00000000-0000-0000-0000-000000000022',
          description: 'EUR Income',
          amountCents: 123456,
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

      expect(find.byIcon(Icons.search), findsOneWidget);
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

      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
    });

    testWidgets('shows app bar actions when transactions exist', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Sort button
      expect(find.byIcon(Icons.sort_rounded), findsOneWidget);
      // Selection mode button
      expect(find.byIcon(Icons.checklist_rounded), findsOneWidget);
      // CSV export button
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
    });

    testWidgets('hides app bar actions when transactions empty', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(transactions: []));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.sort_rounded), findsNothing);
      expect(find.byIcon(Icons.checklist_rounded), findsNothing);
      expect(find.byIcon(Icons.copy_rounded), findsNothing);
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
      await tester.tap(find.byIcon(Icons.clear).first);
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

    testWidgets('tapping selection mode button enters selection mode', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.checklist_rounded));
      await tester.pumpAndSettle();

      // Selection mode shows close button and select/deselect all
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.select_all_rounded), findsOneWidget);
      expect(find.byIcon(Icons.deselect_rounded), findsOneWidget);
      // Normal app bar should be gone
      expect(find.byIcon(Icons.sort_rounded), findsNothing);
    });

    testWidgets('close button exits selection mode', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.tap(find.byIcon(Icons.checklist_rounded));
      await tester.pumpAndSettle();

      // Exit selection mode
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Back to normal app bar
      expect(find.byIcon(Icons.sort_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('select all selects all transactions', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.tap(find.byIcon(Icons.checklist_rounded));
      await tester.pumpAndSettle();

      // Select all
      await tester.tap(find.byIcon(Icons.select_all_rounded));
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
      await tester.tap(find.byIcon(Icons.checklist_rounded));
      await tester.pumpAndSettle();

      // Select all then deselect all
      await tester.tap(find.byIcon(Icons.select_all_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.deselect_rounded));
      await tester.pumpAndSettle();

      // Bottom bar should not be visible (no items selected)
      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
    });

    testWidgets('bottom action bar appears when transactions are selected', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.tap(find.byIcon(Icons.checklist_rounded));
      await tester.pumpAndSettle();

      // Select all
      await tester.tap(find.byIcon(Icons.select_all_rounded));
      await tester.pumpAndSettle();

      // Bottom bar should show action buttons
      expect(find.text('Assign Envelope'), findsOneWidget);
      expect(find.byIcon(Icons.flag_rounded), findsWidgets);
      expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('tapping delete shows confirmation dialog', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter selection mode and select all
      await tester.tap(find.byIcon(Icons.checklist_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.select_all_rounded));
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
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
      await tester.tap(find.byIcon(Icons.checklist_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.select_all_rounded));
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete_outline_rounded));
      await tester.pumpAndSettle();

      // Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog dismissed, still in selection mode
      expect(find.text('Delete Transactions'), findsNothing);
      expect(find.byIcon(Icons.close), findsOneWidget);
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

      await tester.tap(find.byIcon(Icons.sort_rounded));
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

      expect(find.byIcon(Icons.receipt_long_rounded), findsOneWidget);
    });

    testWidgets('shows checkbox on each transaction in selection mode', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.tap(find.byIcon(Icons.checklist_rounded));
      await tester.pumpAndSettle();

      // Each of the 4 transactions should have a checkbox
      expect(find.byType(Checkbox), findsNWidgets(4));
    });

    testWidgets('tapping a checkbox selects that transaction', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Enter selection mode
      await tester.tap(find.byIcon(Icons.checklist_rounded));
      await tester.pumpAndSettle();

      // Tap the first transaction card to toggle selection
      await tester.tap(find.text('Grocery Store'));
      await tester.pumpAndSettle();

      // Shows "1 selected" in app bar
      expect(find.textContaining('1'), findsWidgets);
    });
  });
}
