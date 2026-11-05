import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/main.dart';
import 'package:openbudget_app/src/features/agent_access/screens/agent_access_screen.dart';
import 'package:openbudget_app/src/features/assistant/screens/assistant_screen.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

Finder _skribbleIcon(WiredSvgIconData data) => find.byWidgetPredicate(
  (widget) => widget is SkribbleIcon && widget.data == data,
);

Future<void> waitForFinder(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  const step = Duration(milliseconds: 200);
  var elapsed = Duration.zero;
  while (elapsed < timeout) {
    await tester.pump(step);
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    elapsed += step;
  }
  throw StateError('Timed out waiting for finder: $finder');
}

/// Brings [finder] into the visible viewport, scrolling when necessary.
///
/// The Skribble layout is taller than the previous one, so primary actions can
/// start below the 800x600 surface CI runs Patrol on. Page objects scroll those
/// controls into view instead of enlarging the surface, which keeps the small
/// screen constraint part of the test.
Future<void> scrollIntoView(
  WidgetTester tester,
  Finder finder, {
  Finder? scrollable,
  double delta = 240,
  int maxScrolls = 20,
}) async {
  if (finder.evaluate().isNotEmpty) {
    await tester.ensureVisible(finder.first);
    await tester.pumpAndSettle();
    return;
  }

  // The control has not been built yet because it sits past the lazy list's
  // cache extent, so drag the list until it appears. Only vertical scrollables
  // are considered so a text field's horizontal scrollable is never dragged by
  // accident. Scrolling runs forward first, then back, to cover controls that
  // live above the current offset.
  final view =
      scrollable ??
      find
          .byWidgetPredicate(
            (widget) =>
                widget is Scrollable &&
                widget.axisDirection == AxisDirection.down,
          )
          .first;

  for (final direction in const [-1.0, 1.0]) {
    for (var scroll = 0; scroll < maxScrolls; scroll++) {
      if (finder.evaluate().isNotEmpty) break;
      await tester.drag(
        view,
        Offset(0, direction * delta),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
    }
    if (finder.evaluate().isNotEmpty) break;
  }

  if (finder.evaluate().isEmpty) {
    throw StateError('Could not scroll $finder into view.');
  }

  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
}

/// Brings [finder] into view and taps it.
Future<void> scrollAndTap(
  WidgetTester tester,
  Finder finder, {
  Finder? scrollable,
  double delta = 240,
}) async {
  await scrollIntoView(tester, finder, scrollable: scrollable, delta: delta);
  await tester.tap(finder.first);
  await tester.pumpAndSettle();
}

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
    // Wait for async create + GoRouter navigation into the budget shell.
    await waitForFinder(tester, find.byType(NavigationBar));
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
  Finder get planTab =>
      _destination(OpenBudgetIcons.envelopeOpen, OpenBudgetIcons.envelope);
  Finder get accountsTab =>
      _destination(OpenBudgetIcons.bank, OpenBudgetIcons.wallet);
  Finder get addTab =>
      _destination(OpenBudgetIcons.addCircle, OpenBudgetIcons.addCircle);
  Finder get reflectTab =>
      _destination(OpenBudgetIcons.pieChart, OpenBudgetIcons.barChart);
  Finder get moreTab =>
      _destination(OpenBudgetIcons.more, OpenBudgetIcons.more);

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

  Finder _destination(
    WiredSvgIconData selectedIcon,
    WiredSvgIconData unselectedIcon,
  ) {
    final selected = find.descendant(
      of: navigationBar,
      matching: _iconFinder(selectedIcon),
    );
    if (selected.evaluate().isNotEmpty) {
      return selected.first;
    }
    final unselected = find.descendant(
      of: navigationBar,
      matching: _iconFinder(unselectedIcon),
    );
    if (unselected.evaluate().isNotEmpty) {
      return unselected.first;
    }
    return find
        .descendant(
          of: navigationBar,
          matching: find.byType(NavigationDestination),
        )
        .first;
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
  Finder get transferButton => _skribbleIcon(OpenBudgetIcons.transfer);

  Finder accountTile(String name) => find.text(name);

  /// Scrolls the mixed-currency account list until [name] is visible.
  ///
  /// The restyled net worth card grows with each currency, which can push later
  /// account tiles below the fold.
  Future<void> scrollToAccount(String name) =>
      scrollIntoView(tester, accountTile(name));
}

/// Page object for the account detail screen.
class AccountDetailPage {
  AccountDetailPage(this.tester);

  final WidgetTester tester;

  Finder get moreButton => _skribbleIcon(OpenBudgetIcons.more);
  Finder get editAccountMenuItem => find.text('Edit Account');

  Future<void> openOverflowMenu() async {
    await tester.tap(moreButton);
    await tester.pumpAndSettle();
  }

  Future<void> openEditAccount() async {
    await openOverflowMenu();
    await tester.tap(editAccountMenuItem);
    await tester.pumpAndSettle();
  }
}

/// Page object for the full-screen edit account form.
class EditAccountFormPage {
  EditAccountFormPage(this.tester);

  final WidgetTester tester;

  Finder get closeAccountButton => find.text('Close Account');

  /// Scrolls the form until the close action is built and visible.
  ///
  /// The restyle added enough sections above it that the button starts past the
  /// lazy list's cache extent at 800x600.
  Future<void> scrollToCloseAccount() =>
      scrollIntoView(tester, closeAccountButton);
}

/// Page object for the add transaction bottom sheet.
class AddTransactionSheetPage {
  AddTransactionSheetPage(this.tester);

  final WidgetTester tester;

  Finder get sheetTitle => find.text('Add Transaction');
  Finder get incomeOption => find.text('Add Income');
  Finder get expenseOption => find.text('Add Expense');
  Finder get transferOption => find.text('Transfer');
  Finder get incomeIcon => _iconFinder(OpenBudgetIcons.inflow);
  Finder get expenseIcon => _iconFinder(OpenBudgetIcons.outflow);
  Finder get transferIcon => _iconFinder(OpenBudgetIcons.transfer);

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
  Finder get finishOnboardingButton => find.text('Finish Onboarding');
  Finder get reviewTransactionsBanner => find.text('Review 1 transaction');
  Finder get categoriesToggle => find.text('Categories');
  Finder get spotlightToggle => find.text('Spotlight');

  /// Dismisses the onboarding card, scrolling it into view first.
  Future<void> finishOnboarding() =>
      scrollAndTap(tester, finishOnboardingButton);

  Future<void> openReviewTransactions() =>
      scrollAndTap(tester, reviewTransactionsBanner);

  Future<void> showCategories() => scrollAndTap(tester, categoriesToggle);

  Future<void> showSpotlight() => scrollAndTap(tester, spotlightToggle);
}

/// Page object for the edit plan screen.
class EditPlanPage {
  EditPlanPage(this.tester);

  final WidgetTester tester;

  Finder get addTargetButtons => find.text('Add Target');
  Finder get saveTargetButton => find.text('Save Target');

  Finder groupDetailsMenu(String categoryId) =>
      find.byKey(Key('edit-plan-group-menu-${categoryId.toLowerCase()}'));

  /// Opens the first envelope target dialog, scrolling the envelope rows into
  /// view because they now start below the fold at 800x600.
  Future<void> openFirstAddTarget() => scrollAndTap(tester, addTargetButtons);

  /// Opens the category group's details sheet, which can also sit below the
  /// fold once the target rows are expanded.
  Future<void> openGroupDetails(String categoryId) =>
      scrollAndTap(tester, groupDetailsMenu(categoryId));
}

/// Page object for the More tab.
class MoreTabPage {
  MoreTabPage(this.tester);

  final WidgetTester tester;

  Finder get title => find.text('More').first;
  Finder get assistantTile => find.text('Assistant');
  Finder get recurringTile => find.text('Recurring Transactions');
  Finder get payeesTile => find.text('Payees');
  Finder get rulesTile => find.text('Transaction Rules');
  Finder get importTile => find.text('Import Transactions');
  Finder get taxesTile => find.text('Taxes');
  Finder get settingsTile => find.text('Settings');
}

/// Page object for the category detail screen.
class CategoryDetailPage {
  CategoryDetailPage(this.tester);

  final WidgetTester tester;

  Finder get renameCategoryButton => find.text('Rename Category');

  /// Scrolls the detail list until the rename action is built and visible.
  ///
  /// The restyled detail screen is taller than the 800x600 surface CI runs on,
  /// so the action starts past the lazy list's cache extent.
  Future<void> scrollToRenameCategory() =>
      scrollIntoView(tester, renameCategoryButton);
}

/// Page object for the financial assistant.
class AssistantPage {
  AssistantPage(this.tester);

  final WidgetTester tester;

  Finder get title => find.text('Assistant').first;
  Finder get emptyTitle => find.text('Ask about this plan');
  Finder get suggestionTax => find.text('How much tax will I owe this year?');
  Finder get suggestionCuts => find.text('Where can I cut spending?');
  Finder get suggestionGoals => find.text('Am I on track for my goals?');
  Finder get composerField => find.byKey(AssistantScreen.composerFieldKey);
  Finder get sendButton => find.byKey(AssistantScreen.sendButtonKey);
  Finder get typingIndicator => find.text('The assistant is thinking…');
  Finder get applyButton => find.text('Apply').first;
  Finder get dismissButton => find.text('Dismiss').first;
  Finder get appliedChip => find.text('Applied');
  Finder get dismissedChip => find.text('Dismissed');
  Finder get disclaimer =>
      find.text('Guidance only, not financial or tax advice.');

  Finder toolChip(String label) => find.text(label);
  Finder proposalSummary(String summary) => find.text(summary);

  Future<void> sendSuggestion(String prompt) async {
    await tester.tap(find.text(prompt));
    await tester.pumpAndSettle();
  }

  Future<void> applyFirstProposal() async {
    await tester.tap(applyButton);
    await tester.pumpAndSettle();
  }

  Future<void> dismissFirstProposal() async {
    await tester.tap(dismissButton);
    await tester.pumpAndSettle();
  }
}

/// Page object for OpenBudget Plus.
class PlusPage {
  PlusPage(this.tester);

  final WidgetTester tester;

  Finder get settingsRow => find.text('OpenBudget Plus');
  Finder get title => find.text('OpenBudget Plus').first;
  Finder get price => find.text(r'$10');
  Finder get planTitle => find.text('Your OpenBudget Plus plan');
  Finder get activeChip => find.text('Active');
  Finder get storeButton => find.text('Subscribe in the App Store');
  Finder get stripeButton => find.text('Pay with card');
  Finder get solanaButton => find.text('Pay with USDC');
  Finder get manageButton => find.text('Manage');
  Finder get refreshButton => find.text("I've paid, refresh");

  Future<void> openFromSettings() async {
    await tester.tap(settingsRow);
    await tester.pumpAndSettle();
  }
}

/// Page object for Agent access personal access tokens.
class AgentAccessPage {
  AgentAccessPage(this.tester);

  final WidgetTester tester;

  Finder get settingsRow => find.text('Agent access');
  Finder get title => find.text('Agent access').first;
  Finder get emptyTitle => find.text('No agent tokens yet');
  Finder get nameField => find.byKey(AgentAccessScreen.nameFieldKey);
  Finder get canProposeSwitch =>
      find.byKey(AgentAccessScreen.canProposeSwitchKey);
  Finder get createButton => find.byKey(AgentAccessScreen.createButtonKey);
  Finder get tokenDialog => find.byKey(AgentAccessScreen.tokenDialogKey);
  Finder get copyButton => find.byKey(AgentAccessScreen.copyButtonKey);
  Finder get revokeButton => find.text('Revoke').first;
  Finder get revokeConfirmButton => find.text('Revoke token');
  Finder get revokedChip => find.text('Revoked');

  Future<void> openFromSettings() async {
    await tester.tap(settingsRow);
    await tester.pumpAndSettle();
  }

  Future<void> createToken(String name) async {
    await tester.scrollUntilVisible(
      nameField,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(nameField, name);
    await tester.scrollUntilVisible(
      createButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(createButton);
    await tester.pumpAndSettle();
  }

  Future<void> copyToken() async {
    await tester.tap(copyButton);
    await tester.pumpAndSettle();
    // Let the confirmation toast clear before the next action.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  Future<void> revokeFirstToken() async {
    await tester.scrollUntilVisible(
      revokeButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(revokeButton);
    await tester.pumpAndSettle();
    await tester.tap(revokeConfirmButton);
    await tester.pumpAndSettle();
  }
}

/// Matches a hand-drawn [SkribbleIcon] by its catalog artwork.
Finder _iconFinder(WiredSvgIconData data) => find.byWidgetPredicate(
  (widget) => widget is SkribbleIcon && widget.data == data,
);

/// Page object for the tax overview.
class TaxOverviewPage {
  TaxOverviewPage(this.tester);

  final WidgetTester tester;

  Finder get title => find.text('Taxes').first;
  Finder get emptyTitle => find.text('Set up taxes').first;
  Finder get setupButton => find.text('Set up taxes').last;
  Finder get yearLabel => find.byKey(const Key('tax-year-label'));
  Finder get balanceDue => find.text('Balance due');
  Finder get refundDue => find.text('Refund due');
  Finder get disclaimer => find.text(
    'Guidance only, not tax advice. Check figures with a qualified adviser '
    'before filing.',
  );
}

/// Page object for the tax profile form.
class TaxProfilePage {
  TaxProfilePage(this.tester);

  final WidgetTester tester;

  Finder get title => find.text('Tax profile').first;
  Finder get countryField =>
      find.byType(DropdownButtonFormField<TaxJurisdiction>);
  Finder get entityField => find.byType(DropdownButtonFormField<TaxEntityKind>);
  Finder get scottishTaxpayerToggle => find.text('Scottish taxpayer');
  Finder get studentLoanField => find.byType(DropdownButtonFormField<String>);
  Finder get annualRentField => find.byType(TextField).first;
  Finder get saveButton => find.text('Save profile');

  Future<void> save() async {
    await tester.scrollUntilVisible(
      saveButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
  }
}
