import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol_finders/patrol_finders.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows login screen on launch', (tester) async {
    final $ = PatrolTester(tester: tester, config: PatrolTesterConfig());
    await initApp($);

    final loginPage = LoginPage($);

    expect(loginPage.emailField, findsOneWidget);
    expect(loginPage.passwordField, findsOneWidget);
    expect(loginPage.signInButton, findsOneWidget);
    expect($('Welcome to OpenBudget'), findsOneWidget);
  });

  testWidgets('login navigates to create budget screen', (tester) async {
    final $ = PatrolTester(tester: tester, config: PatrolTesterConfig());
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

  testWidgets('redirects unauthenticated user to login', (tester) async {
    final $ = PatrolTester(tester: tester, config: PatrolTesterConfig());
    await initApp($);

    // Verify login is shown (auth guard redirects unauthenticated users)
    expect($('Welcome to OpenBudget'), findsOneWidget);

    // Verify budget creation form is NOT accessible
    expect($(WiredCombo), findsNothing);
    expect($('Create Budget'), findsNothing);
  });
}
