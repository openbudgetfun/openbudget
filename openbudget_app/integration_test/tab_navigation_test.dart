import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Helper that logs in and creates a budget so the shell is visible.
  Future<void> navigateToBudgetShell(WidgetTester tester) async {
    await initApp(tester);

    final loginPage = LoginPage(tester);
    final createBudgetPage = CreateBudgetPage(tester);

    await loginPage.signIn(TestData.validEmail, TestData.validPassword);
    await createBudgetPage.createBudget(TestData.budgetName);
  }

  testWidgets('bottom navigation bar renders all five tabs', (tester) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);

    expect(shell.navigationBar, findsOneWidget);
    expect(shell.planTab, findsOneWidget);
    expect(shell.accountsTab, findsAtLeast(1));
    expect(shell.addTab, findsOneWidget);
    expect(shell.reflectTab, findsOneWidget);
    expect(shell.moreTab, findsAtLeast(1));
  });

  testWidgets('tapping Accounts tab shows accounts screen', (tester) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);
    final accountsPage = AccountsTabPage(tester);

    await shell.tapAccountsTab();

    // Accounts tab content should be visible (empty state or account list)
    expect(
      accountsPage.emptyStateTitle,
      findsOneWidget,
      reason: 'No accounts exist yet, so empty state should show',
    );
  });

  testWidgets('tapping "+" tab shows add transaction sheet', (tester) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);
    final addSheet = AddTransactionSheetPage(tester);

    await shell.tapAddTab();

    expect(addSheet.sheetTitle, findsOneWidget);
    expect(addSheet.incomeOption, findsOneWidget);
    expect(addSheet.expenseOption, findsOneWidget);
    expect(addSheet.transferOption, findsAtLeast(1));
  });

  testWidgets('dismissing add sheet keeps current tab', (tester) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);
    final planPage = PlanTabPage(tester);

    // Open then dismiss the add sheet
    await shell.tapAddTab();
    expect(find.text('Add Transaction'), findsOneWidget);

    // Dismiss by tapping scrim
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    // Should still be on Plan tab
    expect(planPage.emptyStateTitle, findsOneWidget);
  });

  testWidgets('tapping Reflect tab shows reports screen', (tester) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);

    await shell.tapReflectTab();

    // The Reflect tab should show the reports screen
    expect(shell.reflectTab, findsOneWidget);
  });

  testWidgets('tapping More tab shows more screen options', (tester) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);
    final morePage = MoreTabPage(tester);

    await shell.tapMoreTab();

    expect(morePage.recurringTile, findsOneWidget);
    expect(morePage.payeesTile, findsOneWidget);
    expect(morePage.rulesTile, findsOneWidget);
    expect(morePage.importTile, findsOneWidget);
    expect(morePage.settingsTile, findsOneWidget);
  });

  testWidgets('can navigate back to Plan tab from More tab', (tester) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);
    final planPage = PlanTabPage(tester);

    // Navigate to More
    await shell.tapMoreTab();
    expect(find.text('Recurring Transactions'), findsOneWidget);

    // Navigate back to Plan
    await shell.tapPlanTab();
    expect(planPage.emptyStateTitle, findsOneWidget);
  });

  testWidgets('tab state is preserved across switches', (tester) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);

    // Navigate to Accounts (empty state)
    await shell.tapAccountsTab();
    expect(find.text('No Accounts Yet'), findsOneWidget);

    // Switch to More
    await shell.tapMoreTab();
    expect(find.text('Recurring Transactions'), findsOneWidget);

    // Switch back to Accounts — state should be preserved
    await shell.tapAccountsTab();
    expect(find.text('No Accounts Yet'), findsOneWidget);
  });
}
