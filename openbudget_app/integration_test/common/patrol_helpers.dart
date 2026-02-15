import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/main.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

/// Pumps the full OpenBudget app inside a [ProviderScope].
Future<void> initApp(PatrolIntegrationTester $) async {
  await $.pumpWidgetAndSettle(const ProviderScope(child: OpenBudgetApp()));
}

/// Page object for the login screen.
class LoginPage {
  LoginPage(this.$);

  final PatrolIntegrationTester $;

  PatrolFinder get emailField => $(WiredInput).at(0);
  PatrolFinder get passwordField => $(WiredInput).at(1);
  PatrolFinder get signInButton => $(WiredButton).first;

  Future<void> signIn(String email, String password) async {
    await emailField.enterText(email);
    await passwordField.enterText(password);
    await signInButton.tap();
  }
}

/// Page object for the create budget screen.
class CreateBudgetPage {
  CreateBudgetPage(this.$);

  final PatrolIntegrationTester $;

  PatrolFinder get nameField => $(WiredInput).first;
  PatrolFinder get currencyCombo => $(WiredCombo);
  PatrolFinder get createButton => $(WiredButton).first;

  Future<void> createBudget(String name) async {
    await nameField.enterText(name);
    await createButton.tap();
  }
}

/// Page object for the budget detail screen.
class BudgetDetailPage {
  BudgetDetailPage(this.$);

  final PatrolIntegrationTester $;

  PatrolFinder get budgetHeader => $(WiredCard).first;
  PatrolFinder get emptyStateTitle => $('No Categories Yet');
  PatrolFinder get emptyStateSubtitle =>
      $('Add your first envelope category to start budgeting');
  PatrolFinder get addCategoryButton => $(WiredButton).first;
}
