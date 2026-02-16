import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows login screen on launch', (tester) async {
    await initApp(tester);

    final loginPage = LoginPage(tester);

    expect(loginPage.emailField, findsOneWidget);
    expect(loginPage.passwordField, findsOneWidget);
    expect(loginPage.signInButton, findsOneWidget);
    expect(find.text('Welcome to OpenBudget'), findsOneWidget);
  });

  testWidgets('login navigates to create budget screen', (tester) async {
    await initApp(tester);

    final loginPage = LoginPage(tester);

    await loginPage.signIn(TestData.validEmail, TestData.validPassword);

    expect(find.text('Create Budget'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });

  testWidgets('redirects unauthenticated user to login', (tester) async {
    await initApp(tester);

    // Verify login is shown (auth guard redirects unauthenticated users)
    expect(find.text('Welcome to OpenBudget'), findsOneWidget);

    // Verify budget creation form is NOT accessible
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(find.text('Create Budget'), findsNothing);
  });
}
