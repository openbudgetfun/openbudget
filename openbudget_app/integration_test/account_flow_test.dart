import 'package:flutter/material.dart';
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

  testWidgets('accounts tab shows empty state for new budget', (tester) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);
    final accountsPage = AccountsTabPage(tester);

    await shell.tapAccountsTab();

    expect(accountsPage.emptyStateTitle, findsOneWidget);
    expect(accountsPage.emptyStateSubtitle, findsOneWidget);
    expect(accountsPage.addAccountButton, findsOneWidget);
  });

  testWidgets('tapping Add Account button navigates to add account screen', (
    tester,
  ) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);
    final accountsPage = AccountsTabPage(tester);

    await shell.tapAccountsTab();

    // Tap the "Add Account" button in the empty state
    await tester.tap(accountsPage.addAccountButton);
    await tester.pumpAndSettle();

    // Should navigate to Add Account screen
    expect(find.text('Add Account'), findsAtLeast(1));
    expect(find.byType(TextField), findsAtLeast(1));
  });

  testWidgets('tapping FAB navigates to add account screen', (tester) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);
    final accountsPage = AccountsTabPage(tester);

    await shell.tapAccountsTab();

    // FAB should be visible
    expect(accountsPage.fab, findsOneWidget);

    await tester.tap(accountsPage.fab);
    await tester.pumpAndSettle();

    // Should navigate to Add Account screen
    expect(find.text('Add Account'), findsAtLeast(1));
  });

  testWidgets('accounts tab has transfer action button', (tester) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);

    await shell.tapAccountsTab();

    // Transfer icon should be in the app bar
    expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
  });

  testWidgets('can return to plan tab from accounts tab', (tester) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);
    final planPage = PlanTabPage(tester);

    // Navigate to Accounts
    await shell.tapAccountsTab();
    expect(find.text('No Accounts Yet'), findsOneWidget);

    // Navigate back to Plan
    await shell.tapPlanTab();
    expect(planPage.emptyStateTitle, findsOneWidget);
  });
}
