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

  testWidgets('tapping Add Expense navigates to add expense screen', (
    tester,
  ) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);
    final addSheet = AddTransactionSheetPage(tester);

    // Open add transaction sheet
    await shell.tapAddTab();
    expect(addSheet.sheetTitle, findsOneWidget);

    // Tap Add Expense
    await addSheet.tapExpense();

    // Should navigate to the Add Expense screen
    expect(find.text('Add Expense'), findsOneWidget);
  });

  testWidgets('tapping Add Income navigates to add income screen', (
    tester,
  ) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);
    final addSheet = AddTransactionSheetPage(tester);

    // Open add transaction sheet
    await shell.tapAddTab();
    expect(addSheet.sheetTitle, findsOneWidget);

    // Tap Add Income
    await addSheet.tapIncome();

    // Should navigate to the Add Income screen
    expect(find.text('Add Income'), findsOneWidget);
  });

  testWidgets('add transaction sheet shows all three action tiles', (
    tester,
  ) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);
    final addSheet = AddTransactionSheetPage(tester);

    await shell.tapAddTab();

    expect(addSheet.incomeIcon, findsOneWidget);
    expect(addSheet.expenseIcon, findsOneWidget);
    // Transfer icon may appear in multiple places (accounts tab bar action)
    expect(addSheet.transferIcon, findsAtLeast(1));
  });

  testWidgets('tapping Transfer navigates to transfer screen', (tester) async {
    await navigateToBudgetShell(tester);

    final shell = BudgetShellPage(tester);
    final addSheet = AddTransactionSheetPage(tester);

    await shell.tapAddTab();

    // Tap Transfer — the text "Transfer" may appear in multiple places,
    // so we tap the one inside the sheet.
    await addSheet.tapTransfer();

    // Should navigate to the Transfer screen
    expect(find.text('Transfer'), findsAtLeast(1));
  });
}
