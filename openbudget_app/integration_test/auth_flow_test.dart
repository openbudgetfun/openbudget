import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

void main() {
  patrolTest('shows login screen on launch', ($) async {
    await initApp($);

    final loginPage = LoginPage($);

    expect(loginPage.emailField, findsOneWidget);
    expect(loginPage.passwordField, findsOneWidget);
    expect(loginPage.signInButton, findsOneWidget);
    expect($('Welcome to OpenBudget'), findsOneWidget);
  });

  patrolTest('login navigates to create budget screen', ($) async {
    await initApp($);

    final loginPage = LoginPage($);
    final createBudgetPage = CreateBudgetPage($);

    await loginPage.signIn(TestData.validEmail, TestData.validPassword);

    await createBudgetPage.nameField.waitUntilVisible();
    expect(createBudgetPage.nameField, findsOneWidget);
    expect(createBudgetPage.currencyCombo, findsOneWidget);
    expect(createBudgetPage.createButton, findsOneWidget);
    expect($('Create Budget'), findsOneWidget);
  });

  patrolTest('redirects unauthenticated user to login', ($) async {
    await initApp($);

    // Verify login is shown (auth guard redirects unauthenticated users)
    expect($('Welcome to OpenBudget'), findsOneWidget);

    // Verify budget creation form is NOT accessible
    expect($(WiredCombo), findsNothing);
    expect($('Create Budget'), findsNothing);
  });
}
