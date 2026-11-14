import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/main.dart';
import 'package:openbudget_app/src/features/agent_access/screens/agent_access_screen.dart';
import 'package:openbudget_app/src/features/assistant/screens/assistant_screen.dart';
import 'package:openbudget_app/src/features/tax/widgets/tax_question_field.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import 'test_data.dart';

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
  Finder get addTab => _destination(OpenBudgetIcons.add, OpenBudgetIcons.add);
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

  /// The app-bar edit action; hidden while the account is closed.
  Finder get editButton => find.byTooltip('Edit Account');
  Finder get reconcileButton => find.widgetWithText(FilledButton, 'Reconcile');

  Future<void> editViaAppBar() async {
    await tester.tap(editButton);
    await tester.pumpAndSettle();
  }

  Finder get reconcileSheet => find.byKey(const Key('account-reconcile-sheet'));
  Finder get reconcileDifference =>
      find.byKey(const Key('account-reconcile-difference'));

  Future<void> openReconcileSheet() async {
    await scrollAndTap(tester, reconcileButton);
  }
}

/// Page object for the account type picker inside add account.
class AccountTypePickerPage {
  AccountTypePickerPage(this.tester);

  final WidgetTester tester;

  Finder get addUnlinkedButton =>
      find.byKey(const Key('add-account-add-unlinked-button'));
  Finder get typeTile =>
      find.byKey(const Key('add-account-unlinked-type-tile'));

  /// The picker row for an account type key such as `loan` or `crypto`.
  Finder option(String key) =>
      find.byKey(ValueKey('add-account-type-option-$key'));

  /// Opens the unlinked-account form, then its type picker.
  Future<void> open() async {
    await scrollAndTap(tester, addUnlinkedButton);
    await scrollAndTap(tester, typeTile);
  }
}

/// Page object for the home screen's entity cards and combined net worth.
class MultiCurrencyHomePage {
  MultiCurrencyHomePage(this.tester);

  final WidgetTester tester;

  Finder get combinedNetWorth =>
      find.byKey(const Key('home-combined-net-worth'));
  Finder entityCard(String name) => find.text(name);

  /// The note naming the currencies the server could not convert.
  Finder missingCurrencies(String codes) => find.textContaining(codes);
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
  Finder get enableBooksTile => find.text('Enable double-entry books');
  Finder get booksTile => find.text('Books');
  Finder get settingsTile => find.text('Settings');
}

/// Page object for the Books screen with its three tabs.
class BooksTabPage {
  BooksTabPage(this.tester);

  final WidgetTester tester;

  Finder get journalsTab => find.text('Journals').first;
  Finder get accountsTab => find.text('Accounts').first;
  Finder get trialBalanceTab => find.text('Trial balance').first;
  Finder get newJournalButton => find.byKey(const Key('books-new-journal'));
  Finder get balancedChip => find.byKey(const Key('trial-balanced-chip'));
  Finder get asOfButton => find.byKey(const Key('trial-asof-button'));
  Finder get lockButton => find.byKey(const Key('books-lock-button'));

  Finder journalTile(String reference) => find.text(reference);

  Finder get lockBanner => find.byKey(const Key('books-lock-banner'));
  Finder get lockValue => find.byKey(const Key('books-lock-value'));
  Finder get lockDialog => find.byKey(const Key('books-lock-dialog'));
  Finder get lockSetButton => find.byKey(const Key('books-lock-set'));
  Finder get draftChip => find.text('Draft').first;

  /// Scrolls the tab strip into view first: at 800x600 the tabs sit just
  /// above the fold when the sheet opens.
  Future<void> openTrialBalance() => scrollAndTap(tester, trialBalanceTab);

  Future<void> openAccounts() => scrollAndTap(tester, accountsTab);

  Future<void> openJournals(WidgetTester tester) =>
      scrollAndTap(tester, journalsTab);
}

/// Page object for the journal editor.
class JournalEditorPage {
  JournalEditorPage(this.tester);

  final WidgetTester tester;

  Finder get title => find.text('New journal').first;
  Finder get editTitle => find.text('Edit draft').first;

  /// The text inputs live inside [ObTextField] wrappers, so the finders
  /// descend to the [EditableText] the tester can drive.
  Finder get referenceField => find.descendant(
    of: find.byKey(const Key('journal-reference-field')),
    matching: find.byType(EditableText),
  );
  Finder get narrationField => find.descendant(
    of: find.byKey(const Key('journal-narration-field')),
    matching: find.byType(EditableText),
  );
  Finder get addLineButton => find.byKey(const Key('journal-add-line'));
  Finder get balancedChip => find.byKey(const Key('journal-balanced-chip'));
  Finder get totalsCard => find.byKey(const Key('journal-totals'));
  Finder get saveDraftButton => find.byKey(const Key('journal-save-draft'));
  Finder get postButton => find.byKey(const Key('journal-post-button'));
  Finder get postDialog => find.byKey(const Key('journal-post-dialog'));
  Finder get postConfirmButton => find.byKey(const Key('journal-post-confirm'));
  Finder get linesLoading => find.byKey(const Key('journal-lines-loading'));

  Finder lineAccount(int index) =>
      find.byKey(Key('journal-line-account-$index'));
  Finder lineAmount(int index) => find.descendant(
    of: find.byKey(Key('journal-line-amount-$index')),
    matching: find.byType(EditableText),
  );
  Finder lineCredit(int index) => find.descendant(
    of: find.byKey(Key('journal-line-side-$index')),
    matching: find.text('Credit'),
  );

  /// The amount currently typed into line [index]'s field.
  String lineAmountValue(int index) =>
      tester.widget<EditableText>(lineAmount(index)).controller.text;

  /// The reference currently typed into the reference field.
  String referenceValue() =>
      tester.widget<EditableText>(referenceField).controller.text;

  Future<void> setReference(String text) async {
    await tester.enterText(referenceField, text);
    await tester.pumpAndSettle();
  }

  Future<void> setNarration(String text) async {
    await tester.enterText(narrationField, text);
    await tester.pumpAndSettle();
  }

  Future<void> selectAccount(int index, String label) async {
    await tester.ensureVisible(lineAccount(index));
    await tester.pumpAndSettle();
    await tester.tap(lineAccount(index));
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> markCredit(int index) async {
    await tester.ensureVisible(lineCredit(index));
    await tester.pumpAndSettle();
    await tester.tap(lineCredit(index));
    await tester.pumpAndSettle();
  }

  Future<void> setAmount(int index, String text) async {
    await tester.ensureVisible(lineAmount(index));
    await tester.pumpAndSettle();
    await tester.enterText(lineAmount(index), text);
    await tester.pumpAndSettle();
  }

  Future<void> scrollToTotals() => scrollIntoView(tester, totalsCard);

  /// Fills the two default lines as a balanced £50.00 entry.
  Future<void> fillBalanced() async {
    await selectAccount(0, TestData.bankAccountLabel);
    await setAmount(0, TestData.journalAmount);
    await selectAccount(1, TestData.salesAccountLabel);
    await markCredit(1);
    await setAmount(1, TestData.journalAmount);
  }
}

/// Page object for the read-only journal detail screen.
class JournalDetailPage {
  JournalDetailPage(this.tester);

  final WidgetTester tester;

  Finder get postedChip => find.text('Posted').first;
  Finder get reversedChip => find.text('Reversed').first;
  Finder get readOnlyNote => find.byKey(const Key('journal-readonly-note'));
  Finder get linesCard => find.byKey(const Key('journal-detail-lines'));
  Finder get editButton => find.byKey(const Key('journal-edit-button'));
  Finder get reverseButton => find.byKey(const Key('journal-reverse-button'));
  Finder get reverseDialog => find.byKey(const Key('journal-reverse-dialog'));
  Finder get reverseConfirmButton =>
      find.byKey(const Key('journal-reverse-confirm'));
  Finder get deleteButton => find.byKey(const Key('journal-delete-button'));

  Finder reference(String value) => find.text(value);
  Finder lineRow(int index) => find.byKey(Key('journal-detail-line-$index'));
  Finder totalsRow(int index) =>
      find.byKey(Key('journal-detail-totals-$index'));

  /// Scrolls the stored lines card into view; it sits below the fold on the
  /// 800x600 surface CI runs on.
  Future<void> scrollToLines() => scrollIntoView(tester, linesCard);
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
  Finder get price => find.text(r'$20');
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

/// Page object for the create entity screen and its pickers.
class CreateEntityPage {
  CreateEntityPage(this.tester);

  final WidgetTester tester;

  Finder get title => find.text('Create your books');
  Finder get nameField => find.byKey(const Key('create-entity-name-field'));
  Finder get kindPersonal => find.text('Personal');
  Finder get kindSoleTrader => find.text('Sole trader');
  Finder get kindCompany => find.text('Company');
  Finder get countryRow => find.text('United Kingdom');
  Finder get createButton => find.byKey(
    const Key('create-entity-create-button'),
  );

  Finder get countryField => find.byKey(const Key('create-entity-country-row'));
  Finder get currencyField =>
      find.byKey(const Key('create-entity-currency-row'));
  Finder get timeZoneField =>
      find.byKey(const Key('create-entity-time-zone-row'));
  Finder get taxYearField =>
      find.byKey(const Key('create-entity-tax-year-row'));

  /// The picker sheet that is open, if any.
  Finder get pickerSheet => find.byType(BottomSheet);

  /// The picker's search field.
  Finder get pickerSearch => find.descendant(
    of: pickerSheet,
    matching: find.byType(TextField),
  );

  /// The row for [label] in the open picker (not the form row behind it).
  Finder pickerRow(String label) => find.descendant(
    of: pickerSheet,
    matching: find.widgetWithText(InkWell, label),
  );

  /// What [field] currently shows: its value line, under the label.
  String valueOf(Finder field) => tester
      .widgetList<Text>(find.descendant(of: field, matching: find.byType(Text)))
      .map((text) => text.data)
      .whereType<String>()
      .last;

  /// Opens a form row's picker.
  Future<void> open(Finder field) async {
    await scrollAndTap(tester, field);
  }

  /// Types [query] into the open picker's search field.
  Future<void> search(String query) async {
    await tester.enterText(pickerSearch, query);
    await tester.pumpAndSettle();
  }

  /// Opens the country picker, searches for [query] and picks [name].
  Future<void> chooseCountry(String query, String name) async {
    await open(countryField);
    await search(query);
    await tester.tap(pickerRow(name));
    await tester.pumpAndSettle();
  }

  /// Opens the currency picker, searches for [query] and picks [name].
  Future<void> chooseCurrency(String query, String name) async {
    await open(currencyField);
    await search(query);
    await tester.tap(pickerRow(name));
    await tester.pumpAndSettle();
  }

  /// Fills the name and submits with the pre-selected defaults (a personal
  /// GB entity in GBP). [navigatesTo] is the first thing the flow waits for
  /// on the screen the create redirects to; the real add account screen
  /// shows "Add Accounts" in its app bar.
  Future<String> create({
    String name = 'My First Budget',
    Finder? navigatesTo,
  }) async {
    await tester.enterText(nameField, name);
    // Let the focused field finish scrolling its caret into view before the
    // button is scrolled, or the two scrolls fight and the tap lands below
    // the fold.
    await tester.pumpAndSettle();
    // The create button sits below the fold on the 800x600 surface.
    await scrollAndTap(tester, createButton);
    // Wait for the async create + the redirect into the next screen.
    await waitForFinder(tester, navigatesTo ?? find.text('Add Accounts'));
    await tester.pumpAndSettle();
    return name;
  }
}

/// Page object for the net worth screen.
class NetWorthPage {
  NetWorthPage(this.tester);

  final WidgetTester tester;

  Finder get title => find.text('Net Worth').first;
  Finder get headline => find.byKey(const Key('net-worth-headline'));
  Finder get currencyChip => find.byKey(
    const Key('net-worth-currency-chip'),
  );
  Finder get staleBadge => find.byKey(const Key('net-worth-stale-badge'));
  Finder get incompleteCard =>
      find.byKey(const Key('net-worth-incomplete-card'));
  Finder get trustLine => find.textContaining('Rates as of');
  Finder get tabByEntity => find.byKey(const Key('net-worth-tab-by-entity'));
  Finder get tabByCurrency =>
      find.byKey(const Key('net-worth-tab-by-currency'));
  Finder get tabByAccount => find.byKey(const Key('net-worth-tab-by-account'));

  /// "1 USD = 0.79 GBP · Nov 8" — the rate line behind a converted figure.
  Finder rateLine(String from, String to) => find.textContaining('1 $from = ');

  Finder currencyRow(String currencyCode) => find.text(currencyCode).first;

  /// Opens the currency picker sheet and picks [code].
  Future<void> switchReportingCurrency(String code) async {
    await scrollIntoView(tester, currencyChip);
    await tester.tap(currencyChip);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text(code).last,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text(code).last);
    await tester.pumpAndSettle();
  }

  Future<void> showByCurrency() => scrollAndTap(tester, tabByCurrency);

  Future<void> showByAccount() => scrollAndTap(tester, tabByAccount);

  // The Crypto section: the overprint bar, its rows and the chain / asset
  // toggle.
  Finder get cryptoSection => find.byKey(const Key('crypto-breakdown-section'));
  Finder get cryptoTotal => find.byKey(const Key('crypto-breakdown-total'));
  Finder get cryptoToggleByChain =>
      find.byKey(const Key('crypto-breakdown-toggle-by-chain'));
  Finder get cryptoToggleByAsset =>
      find.byKey(const Key('crypto-breakdown-toggle-by-asset'));

  /// The overprint bar for `byChain` or `byAsset`.
  Finder cryptoBar(String grouping) =>
      find.byKey(ValueKey('crypto-breakdown-bar-$grouping'));

  /// One row, by the key the server gave its slice (`ethereumMainnet`,
  /// `asset:USDC`, `other`).
  Finder cryptoRow(String key) =>
      find.byKey(ValueKey('crypto-breakdown-row-$key'));

  Future<void> showCryptoByChain() => scrollAndTap(tester, cryptoToggleByChain);

  Future<void> showCryptoByAsset() => scrollAndTap(tester, cryptoToggleByAsset);
}

/// Page object for the cross-currency transfer form.
class TransferPage {
  TransferPage(this.tester);

  final WidgetTester tester;

  Finder get title => find.text('Transfer').first;
  Finder get fromPicker => find.byKey(const Key('transfer-from-picker'));
  Finder get toPicker => find.byKey(const Key('transfer-to-picker'));
  Finder get sentField => find.byKey(const Key('transfer-sent-amount-field'));
  Finder get receivedField => find.byKey(
    const Key('transfer-received-amount-field'),
  );
  Finder get amountField => find.byKey(const Key('transfer-amount-field'));
  Finder get impliedRate => find.byKey(const Key('transfer-implied-rate'));
  Finder get useTodayRate => find.text("Use today's rate");
  Finder get submitButton => find.byKey(
    const Key('transfer-submit-button'),
  );

  /// Picks an account on either picker by its "Name (CUR)" item text.
  Future<void> pickAccount({required String from, String? to}) async {
    await tester.tap(fromPicker);
    await tester.pumpAndSettle();
    await tester.tap(find.text(from).last);
    await tester.pumpAndSettle();
    if (to != null) {
      await tester.tap(toPicker);
      await tester.pumpAndSettle();
      await tester.tap(find.text(to).last);
      await tester.pumpAndSettle();
    }
  }

  Future<void> enterSent(String text) async {
    await tester.enterText(sentField, text);
    await tester.pumpAndSettle();
  }

  Future<void> enterReceived(String text) async {
    await tester.enterText(receivedField, text);
    await tester.pumpAndSettle();
  }

  Future<void> submit() async {
    await scrollIntoView(tester, submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();
  }
}

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
  Finder get exportButton => find.byKey(const Key('tax-export-button'));
  Finder get exportError => find.byKey(const Key('tax-export-error'));
  Finder get upcoming => find.byKey(const Key('tax-upcoming'));
  Finder get upcomingToggle => find.byKey(const Key('tax-upcoming-toggle'));
  Finder get upcomingSourceLinks =>
      find.byKey(const Key('tax-deadline-source'));

  /// One upcoming date's card, by rule id and due day (`yyyymmdd`).
  Finder deadline(String id, String day) =>
      find.byKey(Key('tax-deadline-$id-$day'));

  /// Every upcoming date's card.
  Finder get deadlines => find.byWidgetPredicate(
    (widget) =>
        widget.key is ValueKey<String> &&
        (widget.key! as ValueKey<String>).value.startsWith('tax-deadline-') &&
        RegExp(r'-\d{8}$').hasMatch((widget.key! as ValueKey<String>).value),
  );

  /// Scrolls the Upcoming list into view.
  Future<void> showUpcoming() => scrollIntoView(tester, upcoming);

  /// Makes the export link and opens it, scrolling to the button first.
  Future<void> export() async {
    await scrollIntoView(tester, exportButton);
    await tester.tap(exportButton);
    await tester.pumpAndSettle();
  }
}

/// Page object for the tax overview of a country with no tax pack.
class UniversalTaxPage {
  UniversalTaxPage(this.tester);

  final WidgetTester tester;

  Finder get introTitle => find.text(TaxExportData.kenyaIntroTitle);
  Finder get yearLabel => find.byKey(const Key('tax-year-label'));
  Finder get summaryHero => find.byKey(const Key('tax-summary-hero'));
  Finder get ratesTitle => find.text(TaxExportData.vatRatesTitle);
  Finder get standardRate => find.text(TaxExportData.kenyaStandardRate);
  Finder get secondaryBadge =>
      find.byKey(const Key('tax-secondary-source-badge'));
  Finder get authorityLink => find.byKey(const Key('tax-authority-link'));
  Finder get exportButton => find.byKey(const Key('tax-export-button'));
  Finder get exportError => find.byKey(const Key('tax-export-error'));

  /// Makes the export link and opens it, scrolling to the button first.
  Future<void> export() async {
    await scrollIntoView(tester, exportButton);
    await tester.tap(exportButton);
    await tester.pumpAndSettle();
  }

  /// Opens the tax authority's website, scrolling to the link first.
  Future<void> openAuthority() async {
    await scrollIntoView(tester, authorityLink);
    await tester.tap(authorityLink);
    await tester.pumpAndSettle();
  }
}

/// Page object for the tax profile form.
class TaxProfilePage {
  TaxProfilePage(this.tester);

  final WidgetTester tester;

  Finder get title => find.text('Tax profile').first;

  /// A question's field is found by the question's key, not its wording,
  /// so the same page object serves every country's questions.
  Finder question(String key) => find.byKey(taxQuestionFieldKey(key));

  /// The jurisdiction comes from the entity now; the kind dropdown is the
  /// only entity-level control left on the form.
  Finder get entityField => question('entityKind');
  Finder get scottishTaxpayerToggle => question('scottishTaxpayer');
  Finder get taxResidentToggle => question('taxResident');
  Finder get studentLoanField => question('studentLoanPlan');
  Finder get annualRentField => question('annualRentMinor');
  Finder get saveButton => find.text('Save profile');

  /// Scrolls [field] into view and taps it, for a switch or a dropdown.
  Future<void> tapQuestion(Finder field) async {
    await tester.scrollUntilVisible(
      field,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(field);
    await tester.pumpAndSettle();
  }

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

/// Page object for the expense form's FX affordances: the live rate line
/// under the amount field and the manual-rate sheet it opens.
class ExpenseFxPage {
  ExpenseFxPage(this.tester);

  final WidgetTester tester;

  Finder get fxLine => find.byKey(const Key('expense-fx-line'));
  Finder get amountField => find.byKey(const Key('expense-amount-field'));
  Finder get splitButton => find.byKey(const Key('expense-split-button'));
  Finder get linesEditor => find.byKey(const Key('expense-lines-editor'));
  Finder get setRateButton => find.text('Set rate').first;
  Finder get manualRateSheet => find.text('Use your own rate').first;
  Finder get manualRateField => find.byKey(const Key('manual-rate-field'));
  Finder get manualRateUseButton => find.byKey(
    const Key('manual-rate-use-button'),
  );

  /// Opens the manual-rate sheet and enters [rate].
  Future<void> setManualRate(String rate) async {
    await tester.tap(setRateButton);
    await tester.pumpAndSettle();
    await tester.enterText(manualRateField, rate);
    await tester.pumpAndSettle();
    await tester.tap(manualRateUseButton);
    await tester.pumpAndSettle();
  }
}

/// Page object for the add-a-wallet step of the add account flow.
class AddWalletPage {
  AddWalletPage(this.tester);

  final WidgetTester tester;

  /// The bank search step's "Add a crypto wallet" button.
  Finder get entryButton =>
      find.widgetWithText(FilledButton, 'Add a crypto wallet');
  Finder get addressField => find.byKey(const Key('add-wallet-address-field'));
  Finder get addButton => find.byKey(const Key('add-wallet-submit'));
  Finder get detectedStamp =>
      find.byKey(const Key('add-wallet-detected-stamp'));
  Finder get doneButton => find.byKey(const Key('add-wallet-done'));
  Finder get addAnotherButton =>
      find.byKey(const Key('add-wallet-add-another'));

  /// The postmark that lands when the wallet is in.
  Finder get postmark => find.byType(ObPostmark);

  /// The stamp for [network] (a `WalletNetwork` name, such as `baseMainnet`)
  /// in the EVM picker.
  Finder networkStamp(String network) =>
      find.byKey(ValueKey('add-wallet-network-$network'));

  Finder get pickerTitle => find.text('Where should OpenBudget look?');
  Finder get refusalTitle => find.text("That's a private key");
  Finder get unreadableTitle => find.text("Couldn't read your wallet");

  /// Opens the wallet step from the bank search step.
  Future<void> open() => scrollAndTap(tester, entryButton);

  /// Pastes [text] into the field, as a person pasting from their wallet.
  Future<void> paste(String text) async {
    await tester.enterText(addressField, text);
    await tester.pumpAndSettle();
  }

  /// What the field holds right now.
  String get fieldText =>
      tester.widget<TextField>(addressField).controller?.text ?? '';

  /// Whether the Add wallet button can be tapped.
  bool get canAdd => tester.widget<FilledButton>(addButton).onPressed != null;

  Future<void> toggleNetwork(String network) async {
    await tester.ensureVisible(networkStamp(network));
    await tester.tap(networkStamp(network));
    await tester.pumpAndSettle();
  }

  Future<void> tapAdd() async {
    await tester.tap(addButton);
    await tester.pump();
  }
}

/// Page object for a wallet account's settings sheet on account detail.
class WalletSettingsPage {
  WalletSettingsPage(this.tester);

  final WidgetTester tester;

  Finder get openButton => find.byKey(const Key('wallet-settings-button'));
  Finder get nameField => find.byKey(const Key('wallet-settings-name-field'));
  Finder get saveNameButton =>
      find.byKey(const Key('wallet-settings-name-save'));
  Finder get saveChainsButton =>
      find.byKey(const Key('wallet-settings-save-networks'));
  Finder get lookAheadButton =>
      find.byKey(const Key('wallet-settings-look-ahead'));
  Finder get removeConfirmButton =>
      find.byKey(const Key('wallet-settings-remove-confirm'));
  Finder get removeCancelButton =>
      find.byKey(const Key('wallet-settings-remove-cancel'));
  Finder get disconnectButton =>
      find.byKey(const Key('wallet-settings-disconnect'));

  /// The stamp for [network] (a `WalletNetwork` name, such as `baseMainnet`)
  /// in the chain editor.
  Finder networkStamp(String network) =>
      find.byKey(ValueKey('wallet-settings-network-$network'));

  Future<void> open() => scrollAndTap(tester, openButton);

  /// Closes the sheet, as the system back gesture does.
  Future<void> close() async {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }

  /// Scrolls account detail to the holdings, one section per chain.
  Future<void> showHoldings() => scrollIntoView(tester, find.text('Holdings'));

  Future<void> rename(String name) async {
    await tester.enterText(nameField, name);
    await tester.pumpAndSettle();
    await scrollAndTap(tester, saveNameButton);
  }

  Future<void> toggleNetwork(String network) =>
      scrollAndTap(tester, networkStamp(network));

  Future<void> saveChains() => scrollAndTap(tester, saveChainsButton);

  Future<void> confirmRemoval() => scrollAndTap(tester, removeConfirmButton);

  Future<void> lookForOtherChains() => scrollAndTap(tester, lookAheadButton);
}
