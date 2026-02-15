import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol_finders/patrol_finders.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('create budget screen renders form', (tester) async {
    final $ = PatrolTester(tester: tester, config: PatrolTesterConfig());
    await initApp($);

    final loginPage = LoginPage($);
    final createBudgetPage = CreateBudgetPage($);

    // Navigate past login
    await loginPage.signIn(TestData.validEmail, TestData.validPassword);
    await createBudgetPage.nameField.waitUntilVisible();

    // Verify form elements
    expect(createBudgetPage.nameField, findsOneWidget);
    expect($(WiredCombo), findsOneWidget);
    expect($(WiredButton), findsOneWidget);
    expect($('Create Budget'), findsOneWidget);
  });

  testWidgets('creating a budget navigates to budget detail', (tester) async {
    final $ = PatrolTester(tester: tester, config: PatrolTesterConfig());
    await initApp($);

    final loginPage = LoginPage($);
    final createBudgetPage = CreateBudgetPage($);
    final budgetDetailPage = BudgetDetailPage($);

    // Navigate past login
    await loginPage.signIn(TestData.validEmail, TestData.validPassword);
    await createBudgetPage.nameField.waitUntilVisible();

    // Create budget
    await createBudgetPage.createBudget(TestData.budgetName);

    // Verify navigation to budget detail
    await budgetDetailPage.emptyStateTitle.waitUntilVisible();
    expect(budgetDetailPage.budgetHeader, findsOneWidget);
    expect($('Budget: mock-budget-1'), findsOneWidget);
  });

  testWidgets('budget detail shows empty state', (tester) async {
    final $ = PatrolTester(tester: tester, config: PatrolTesterConfig());
    await initApp($);

    final loginPage = LoginPage($);
    final createBudgetPage = CreateBudgetPage($);
    final budgetDetailPage = BudgetDetailPage($);

    // Navigate to budget detail via login → create budget
    await loginPage.signIn(TestData.validEmail, TestData.validPassword);
    await createBudgetPage.nameField.waitUntilVisible();
    await createBudgetPage.createBudget(TestData.budgetName);

    // Verify empty state
    await budgetDetailPage.emptyStateTitle.waitUntilVisible();
    expect(budgetDetailPage.emptyStateTitle, findsOneWidget);
    expect(budgetDetailPage.emptyStateSubtitle, findsOneWidget);
    expect(budgetDetailPage.addCategoryButton, findsOneWidget);
    expect($('Add Category'), findsOneWidget);
  });
}
