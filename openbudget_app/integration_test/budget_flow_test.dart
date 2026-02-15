import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('create budget screen renders form', (tester) async {
    await initApp(tester);

    final loginPage = LoginPage(tester);

    // Navigate past login
    await loginPage.signIn(TestData.validEmail, TestData.validPassword);

    // Verify form elements
    expect(find.byType(WiredInput), findsOneWidget);
    expect(find.byType(WiredCombo), findsOneWidget);
    expect(find.byType(WiredButton), findsOneWidget);
    expect(find.text('Create Budget'), findsOneWidget);
  });

  testWidgets('creating a budget navigates to budget detail', (tester) async {
    await initApp(tester);

    final loginPage = LoginPage(tester);
    final createBudgetPage = CreateBudgetPage(tester);
    final budgetDetailPage = BudgetDetailPage(tester);

    // Navigate past login
    await loginPage.signIn(TestData.validEmail, TestData.validPassword);

    // Create budget
    await createBudgetPage.createBudget(TestData.budgetName);

    // Verify navigation to budget detail
    expect(budgetDetailPage.budgetHeader, findsOneWidget);
    expect(find.text('Budget: mock-budget-1'), findsOneWidget);
  });

  testWidgets('budget detail shows empty state', (tester) async {
    await initApp(tester);

    final loginPage = LoginPage(tester);
    final createBudgetPage = CreateBudgetPage(tester);
    final budgetDetailPage = BudgetDetailPage(tester);

    // Navigate to budget detail via login → create budget
    await loginPage.signIn(TestData.validEmail, TestData.validPassword);
    await createBudgetPage.createBudget(TestData.budgetName);

    // Verify empty state
    expect(budgetDetailPage.emptyStateTitle, findsOneWidget);
    expect(budgetDetailPage.emptyStateSubtitle, findsOneWidget);
    expect(budgetDetailPage.addCategoryButton, findsOneWidget);
    expect(find.text('Add Category'), findsOneWidget);
  });
}
