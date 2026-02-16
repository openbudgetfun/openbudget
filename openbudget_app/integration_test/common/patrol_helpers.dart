import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/main.dart';

/// Pumps the full OpenBudget app inside a [ProviderScope] and waits for it
/// to settle.
Future<void> initApp(WidgetTester tester) async {
  await tester.pumpWidget(const ProviderScope(child: OpenBudgetApp()));
  await tester.pumpAndSettle();
}

/// Page object for the login screen.
class LoginPage {
  LoginPage(this.tester);

  final WidgetTester tester;

  Finder get emailField => find.byType(TextField).at(0);
  Finder get passwordField => find.byType(TextField).at(1);
  Finder get signInButton => find.byType(FilledButton).first;

  Future<void> signIn(String email, String password) async {
    await tester.enterText(emailField, email);
    await tester.enterText(passwordField, password);
    await tester.tap(signInButton);
    // Wait for async login (500ms) + GoRouter redirect.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }
}

/// Page object for the create budget screen.
class CreateBudgetPage {
  CreateBudgetPage(this.tester);

  final WidgetTester tester;

  Finder get nameField => find.byType(TextField).first;
  Finder get currencyDropdown => find.byType(DropdownButtonFormField<String>);
  Finder get createButton => find.byType(FilledButton).first;

  Future<void> createBudget(String name) async {
    await tester.enterText(nameField, name);
    await tester.tap(createButton);
    // Wait for async create (300ms) + GoRouter navigation.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }
}

/// Page object for the budget detail screen.
class BudgetDetailPage {
  BudgetDetailPage(this.tester);

  final WidgetTester tester;

  Finder get budgetHeader => find.byType(Card).first;
  Finder get emptyStateTitle => find.text('No Categories Yet');
  Finder get emptyStateSubtitle =>
      find.text('Add your first envelope category to start budgeting');
  Finder get addCategoryButton => find.byType(OutlinedButton).first;
}
