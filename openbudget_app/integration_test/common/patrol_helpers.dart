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

/// Page object for the bottom tab navigation shell.
class BudgetShellPage {
  BudgetShellPage(this.tester);

  final WidgetTester tester;

  Finder get navigationBar => find.byType(NavigationBar);
  Finder get planTab => find.text('Plan');
  Finder get accountsTab => find.text('Accounts');
  Finder get addTab => find.text('Add');
  Finder get reflectTab => find.text('Reflect');
  Finder get moreTab => find.text('More');

  Future<void> tapPlanTab() async {
    await tester.tap(planTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapAccountsTab() async {
    await tester.tap(accountsTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapAddTab() async {
    await tester.tap(addTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapReflectTab() async {
    await tester.tap(reflectTab);
    await tester.pumpAndSettle();
  }

  Future<void> tapMoreTab() async {
    await tester.tap(moreTab);
    await tester.pumpAndSettle();
  }
}

/// Page object for the accounts tab.
class AccountsTabPage {
  AccountsTabPage(this.tester);

  final WidgetTester tester;

  Finder get title => find.text('Accounts').first;
  Finder get emptyStateTitle => find.text('No Accounts Yet');
  Finder get emptyStateSubtitle =>
      find.text('Add your first account to track balances');
  Finder get addAccountButton => find.text('Add Account');
  Finder get fab => find.byType(FloatingActionButton);
  Finder get netWorthLabel => find.text('Net Worth');
  Finder get transferButton => find.byIcon(Icons.swap_horiz_rounded);
}

/// Page object for the add transaction bottom sheet.
class AddTransactionSheetPage {
  AddTransactionSheetPage(this.tester);

  final WidgetTester tester;

  Finder get sheetTitle => find.text('Add Transaction');
  Finder get incomeOption => find.text('Add Income');
  Finder get expenseOption => find.text('Add Expense');
  Finder get transferOption => find.text('Transfer');
  Finder get incomeIcon => find.byIcon(Icons.arrow_downward_rounded);
  Finder get expenseIcon => find.byIcon(Icons.arrow_upward_rounded);
  Finder get transferIcon => find.byIcon(Icons.swap_horiz_rounded);

  Future<void> tapIncome() async {
    await tester.tap(incomeOption);
    await tester.pumpAndSettle();
  }

  Future<void> tapExpense() async {
    await tester.tap(expenseOption);
    await tester.pumpAndSettle();
  }

  Future<void> tapTransfer() async {
    await tester.tap(transferOption);
    await tester.pumpAndSettle();
  }
}

/// Page object for the Plan tab (budget detail view).
class PlanTabPage {
  PlanTabPage(this.tester);

  final WidgetTester tester;

  Finder get emptyStateTitle => find.text('No Categories Yet');
  Finder get emptyStateSubtitle =>
      find.text('Add your first envelope category to start budgeting');
  Finder get addCategoryButton => find.text('Add Category');
  Finder get readyToAssign => find.textContaining('Ready to Assign');
}

/// Page object for the More tab.
class MoreTabPage {
  MoreTabPage(this.tester);

  final WidgetTester tester;

  Finder get title => find.text('More').first;
  Finder get recurringTile => find.text('Recurring Transactions');
  Finder get payeesTile => find.text('Payees');
  Finder get rulesTile => find.text('Transaction Rules');
  Finder get importTile => find.text('Import Transactions');
  Finder get settingsTile => find.text('Settings');
}
