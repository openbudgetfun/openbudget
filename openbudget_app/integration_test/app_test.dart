import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

void main() {
  patrolTest('full app flow: login → create budget → view budget', ($) async {
    await initApp($);

    final loginPage = LoginPage($);
    final createBudgetPage = CreateBudgetPage($);
    final budgetDetailPage = BudgetDetailPage($);

    // Login screen is shown on launch
    expect(loginPage.emailField, findsOneWidget);

    // Sign in
    await loginPage.signIn(TestData.validEmail, TestData.validPassword);

    // Verify navigation to create budget screen
    await createBudgetPage.nameField.waitUntilVisible();
    expect(createBudgetPage.nameField, findsOneWidget);

    // Create a budget
    await createBudgetPage.createBudget(TestData.budgetName);

    // Verify navigation to budget detail screen
    await budgetDetailPage.emptyStateTitle.waitUntilVisible();
    expect(budgetDetailPage.emptyStateTitle, findsOneWidget);
    expect(budgetDetailPage.emptyStateSubtitle, findsOneWidget);
    expect(budgetDetailPage.addCategoryButton, findsOneWidget);
  });
}
