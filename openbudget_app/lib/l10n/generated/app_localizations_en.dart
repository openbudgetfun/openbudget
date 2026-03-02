// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get accountAddButton => 'Add Account';

  @override
  String get accountAddTitle => 'Add Account';

  @override
  String get accountBalanceLabel => 'Starting Balance';

  @override
  String get accountCloseButton => 'Close Account';

  @override
  String get accountCloseConfirm =>
      'Close this account? It will be moved to Closed Accounts.';

  @override
  String get accountCloseSuccess => 'Account closed';

  @override
  String get accountClosed => 'Closed Accounts';

  @override
  String get accountCreateError =>
      'Could not create account. Please try again.';

  @override
  String get accountCreateSuccess => 'Account created';

  @override
  String get accountDeleteButton => 'Delete Permanently';

  @override
  String get accountDeleteConfirm =>
      'Permanently delete this account? This cannot be undone and all associated transactions will be lost.';

  @override
  String get accountDeleteError =>
      'Could not delete account. Please try again.';

  @override
  String get accountDeleteSuccess => 'Account deleted';

  @override
  String get accountDeleteTitle => 'Delete Account';

  @override
  String get accountBalanceCleared => 'Cleared';

  @override
  String get accountBalanceUncleared => 'Uncleared';

  @override
  String get accountDetailBalance => 'Working Balance';

  @override
  String get accountDetailSearchHint => 'Search transactions...';

  @override
  String get accountFilterAll => 'All';

  @override
  String get accountFilterUncleared => 'Uncleared';

  @override
  String get accountFilterCleared => 'Cleared';

  @override
  String get accountFilterReconciled => 'Reconciled';

  @override
  String get accountEditError => 'Could not update account. Please try again.';

  @override
  String get accountEditSuccess => 'Account updated';

  @override
  String get accountEditTitle => 'Edit Account';

  @override
  String get accountEmptySubtitle => 'Add your first account to track balances';

  @override
  String get accountEmptyTitle => 'No Accounts Yet';

  @override
  String get accountListTitle => 'Accounts';

  @override
  String get accountLoadError => 'Could not load accounts';

  @override
  String get accountNameLabel => 'Account Name';

  @override
  String get accountOffBudget => 'Tracking Accounts';

  @override
  String get accountOnBudget => 'Budget Accounts';

  @override
  String get accountOnBudgetHint => 'Include in budget calculations';

  @override
  String get accountOnBudgetLabel => 'On Budget';

  @override
  String get accountReopenButton => 'Reopen Account';

  @override
  String get accountReopenSuccess => 'Account reopened';

  @override
  String get accountRunningBalance => 'Running Balance';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeChecking => 'Checking';

  @override
  String get accountTypeCreditCard => 'Credit Card';

  @override
  String get accountTypeInvestment => 'Investment';

  @override
  String get accountTypeLabel => 'Account Type';

  @override
  String get accountTypeOther => 'Other';

  @override
  String get accountTypeSavings => 'Savings';

  @override
  String get accountNetWorth => 'Net Worth';

  @override
  String get accountTotalAssets => 'Assets';

  @override
  String get accountTotalLiabilities => 'Liabilities';

  @override
  String ageOfMoneyLabel(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Age of Money: $days days',
      one: 'Age of Money: 1 day',
    );
    return '$_temp0';
  }

  @override
  String get appTitle => 'OpenBudget';

  @override
  String get autoAssignAssigning => 'Assigning...';

  @override
  String get autoAssignButton => 'Auto-Assign';

  @override
  String get autoAssignDistributing => 'Distributing to underfunded envelopes';

  @override
  String autoAssignEnvelopeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count envelopes',
      one: '1 envelope',
    );
    return '$_temp0';
  }

  @override
  String get autoAssignError => 'Could not auto-assign. Please try again.';

  @override
  String get autoAssignNothingToAssign =>
      'All envelopes with goals are fully funded!';

  @override
  String autoAssignSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Auto-assigned to $count envelopes',
      one: 'Auto-assigned to 1 envelope',
    );
    return '$_temp0';
  }

  @override
  String get autoAssignTitle => 'Auto-Assign';

  @override
  String get bulkAssignEnvelope => 'Assign Envelope';

  @override
  String get bulkAssignError => 'Could not assign envelope. Please try again.';

  @override
  String bulkAssignSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions updated',
      one: '1 transaction updated',
    );
    return '$_temp0';
  }

  @override
  String get bulkSelectAll => 'Select All';

  @override
  String get bulkCancelSelection => 'Cancel';

  @override
  String get bulkDeselectAll => 'Deselect All';

  @override
  String get bulkSelectEnvelope => 'Select an envelope to assign';

  @override
  String bulkSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String bulkDeleteConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return 'Delete $_temp0? This cannot be undone.';
  }

  @override
  String get bulkDeleteError =>
      'Could not delete transactions. Please try again.';

  @override
  String bulkDeleteSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions deleted',
      one: '1 transaction deleted',
    );
    return '$_temp0';
  }

  @override
  String get bulkDeleteTitle => 'Delete Transactions';

  @override
  String get bulkFlagError => 'Could not set flags. Please try again.';

  @override
  String bulkFlagSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions flagged',
      one: '1 transaction flagged',
    );
    return '$_temp0';
  }

  @override
  String get bulkSetFlag => 'Set Flag';

  @override
  String get bulkClearFlag => 'Clear Flag';

  @override
  String get bulkClearError =>
      'Could not update transactions. Please try again.';

  @override
  String bulkClearSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions cleared',
      one: '1 transaction cleared',
    );
    return '$_temp0';
  }

  @override
  String get bulkMarkCleared => 'Mark Cleared';

  @override
  String get bulkMarkUncleared => 'Mark Uncleared';

  @override
  String get budgetAssignMoney => 'Assign Money';

  @override
  String get budgetAddCategory => 'Add Category';

  @override
  String get budgetAddEnvelope => 'Add Envelope';

  @override
  String get budgetCollapseExpand => 'Collapse/Expand';

  @override
  String get budgetInlineEditorDetails => 'Details';

  @override
  String get budgetAddExpense => 'Add Expense';

  @override
  String get budgetAddIncome => 'Add Income';

  @override
  String get budgetSpotlightAddPriorities => 'Add Priorities';

  @override
  String get budgetSpotlightAssigned => 'Assigned';

  @override
  String get budgetSpotlightAssign => 'Assign';

  @override
  String get budgetSpotlightEdit => 'Edit';

  @override
  String get budgetSpotlightReflect => 'Reflect';

  @override
  String get budgetSpotlightSpent => 'Spent';

  @override
  String get budgetSpotlightSummarySuffix => 'Summary';

  @override
  String get budgetSpotlightTopPriorities => 'Top Priorities';

  @override
  String get budgetSpotlightTopPrioritiesHint =>
      'Keep your focus categories front and center for this month.';

  @override
  String get budgetSpotlightTotalTargets => 'Total Targets';

  @override
  String get budgetSpotlightUnderfunded => 'Underfunded';

  @override
  String get budgetOnboardingAddAccountsTitle =>
      'Start working with real numbers';

  @override
  String get budgetOnboardingAddAccountsBody =>
      'Every dollar needs a real account balance. Add your account balances to see what you\'re working with.';

  @override
  String get budgetOnboardingAddAccountsCta => 'Add Accounts';

  @override
  String budgetOnboardingAssignMoneyTitle(String amount) {
    return 'Assign Your $amount';
  }

  @override
  String get budgetOnboardingAssignMoneyBody =>
      'This is money in your OpenBudget accounts. Give it a job before payday.';

  @override
  String get budgetOnboardingAssignMoneyPrompt =>
      'Start by asking yourself what this money needs to do before you get paid again.';

  @override
  String get budgetOnboardingAddAnotherAccount => 'Add Another Account';

  @override
  String get budgetOnboardingFinishTitle => 'Spend with confidence and clarity';

  @override
  String get budgetOnboardingFinishBody =>
      'Intentional spending reduces stress, regret, and second-guessing.';

  @override
  String get budgetOnboardingFinishCta => 'Finish Onboarding';

  @override
  String get budgetAllocationError => 'Could not update allocation';

  @override
  String get budgetAllocationUpdated => 'Allocation updated';

  @override
  String get budgetCategoryCreateError => 'Could not create category';

  @override
  String get budgetCategoryCreated => 'Category created';

  @override
  String get budgetCategoryNameLabel => 'Category Name';

  @override
  String get budgetCategoryTotal => 'Total';

  @override
  String get categoryDetailAmountToAssignThisMonth =>
      'Amount to Assign This Month';

  @override
  String get categoryDetailAssignedSoFar => 'Assigned So Far';

  @override
  String categoryDetailAssignMore(String amount) {
    return 'Assign $amount more to meet your target';
  }

  @override
  String get categoryDetailBalanceTitle => 'Balance';

  @override
  String get categoryDetailDeleteConfirm =>
      'Delete this category and its budget history?';

  @override
  String get categoryDetailDeleteEnvelope => 'Delete Category';

  @override
  String get categoryDetailEditEnvelope => 'Rename Category';

  @override
  String get categoryDetailHideEnvelope => 'Hide Category';

  @override
  String get categoryDetailNotesTitle => 'Notes';

  @override
  String get categoryDetailSnoozeGoal => 'Snooze for this month';

  @override
  String get categoryDetailTargetMet => 'You\'ve met your target!';

  @override
  String get categoryDetailTargetTitle => 'Target';

  @override
  String get categoryDetailToGo => 'To Go';

  @override
  String get categoryDetailUnhideEnvelope => 'Unhide Category';

  @override
  String get budgetColumnAvailable => 'Available';

  @override
  String get budgetColumnBudgeted => 'Budgeted';

  @override
  String get budgetColumnSpent => 'Spent';

  @override
  String get budgetCopyLastMonth => 'Copy Last Month';

  @override
  String get budgetCopyLastMonthConfirm =>
      'Copy all budget allocations from last month to the current month? This will overwrite any existing allocations.';

  @override
  String get budgetCopyLastMonthError =>
      'Could not copy previous month. Please try again.';

  @override
  String get budgetCopyLastMonthSuccess =>
      'Allocations copied from previous month';

  @override
  String get budgetDeleteButton => 'Delete';

  @override
  String budgetDeleteConfirm(String name) {
    return 'Delete \"$name\"? This will permanently remove the budget and all its data.';
  }

  @override
  String get budgetDeleteError => 'Could not delete budget. Please try again.';

  @override
  String get budgetDeleteSuccess => 'Budget deleted';

  @override
  String get budgetDeleteTitle => 'Delete Budget';

  @override
  String get budgetEditCategoryError =>
      'Could not rename category. Please try again.';

  @override
  String get budgetEditCategorySuccess => 'Category renamed';

  @override
  String get budgetEditCategoryTitle => 'Rename Category';

  @override
  String get budgetEmptySubtitle =>
      'Add your first envelope category to start budgeting';

  @override
  String get budgetEmptyTitle => 'No Categories Yet';

  @override
  String get budgetEnvelopeAmountLabel => 'Budgeted Amount';

  @override
  String get budgetEnvelopeCreateError => 'Could not create envelope';

  @override
  String get budgetEnvelopeCreated => 'Envelope created';

  @override
  String get budgetEnvelopeNameLabel => 'Envelope Name';

  @override
  String budgetHiddenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hidden',
      one: '1 hidden',
    );
    return '$_temp0';
  }

  @override
  String get budgetGoToToday => 'Back to Today';

  @override
  String get budgetMonthPickerTitle => 'Jump to Month';

  @override
  String get budgetHideCategory => 'Hide Category';

  @override
  String get budgetHideEnvelope => 'Hide Envelope';

  @override
  String get budgetHiddenLabel => 'Hidden';

  @override
  String get budgetLoadError => 'Could not load budget details';

  @override
  String get budgetMonthApril => 'April';

  @override
  String get budgetMonthAugust => 'August';

  @override
  String get budgetMonthDecember => 'December';

  @override
  String get budgetMonthFebruary => 'February';

  @override
  String get budgetMonthJanuary => 'January';

  @override
  String get budgetMonthJuly => 'July';

  @override
  String get budgetMonthJune => 'June';

  @override
  String get budgetMonthMarch => 'March';

  @override
  String get budgetMonthMay => 'May';

  @override
  String get budgetMonthNovember => 'November';

  @override
  String get budgetMonthOctober => 'October';

  @override
  String get budgetMonthSeptember => 'September';

  @override
  String budgetOverspentWarning(String amount) {
    return 'Overspent: $amount';
  }

  @override
  String get budgetReadyToAssign => 'Ready to Assign';

  @override
  String get budgetTotalIncome => 'Income';

  @override
  String get budgetTotalBudgeted => 'Budgeted';

  @override
  String get budgetTotalActivity => 'Activity';

  @override
  String get budgetReorderCategories => 'Reorder Categories';

  @override
  String get budgetReorderDone => 'Done';

  @override
  String get budgetReorderError => 'Could not reorder categories';

  @override
  String get budgetReorderHint => 'Drag to reorder categories';

  @override
  String get budgetReorderSuccess => 'Categories reordered';

  @override
  String get budgetShowHidden => 'Show Hidden';

  @override
  String get budgetSearchHint => 'Search envelopes...';

  @override
  String get budgetSearchNoResults => 'No matching envelopes';

  @override
  String budgetSearchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
    );
    return '$_temp0';
  }

  @override
  String get budgetUnhideCategory => 'Unhide Category';

  @override
  String get budgetUnhideEnvelope => 'Unhide Envelope';

  @override
  String get budgetViewAccounts => 'Accounts';

  @override
  String get categoryTrendsEmptySubtitle =>
      'Add categorized transactions to see spending trends by category';

  @override
  String get categoryTrendsEmptyTitle => 'No Category Data';

  @override
  String get categoryTrendsLoadError => 'Could not load category trends';

  @override
  String get categoryTrendsTitle => 'Category Trends';

  @override
  String get comparisonTitle => 'Budget Comparison';

  @override
  String get comparisonMonthRange => 'Month Range';

  @override
  String comparisonMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Last $count months',
      one: 'Last 1 month',
    );
    return '$_temp0';
  }

  @override
  String get comparisonLoadError => 'Could not load comparison data';

  @override
  String get comparisonEmptyTitle => 'No Budget Data';

  @override
  String get comparisonEmptySubtitle =>
      'Add categories and envelopes to compare months';

  @override
  String get comparisonCategoryLabel => 'Category';

  @override
  String get comparisonTotalLabel => 'Total Spending';

  @override
  String get createBudgetButton => 'Create';

  @override
  String get createBudgetCreating => 'Creating...';

  @override
  String get createBudgetCurrencyLabel => 'Primary Currency';

  @override
  String get createBudgetError => 'Could not create budget. Please try again.';

  @override
  String get createBudgetNameLabel => 'Budget Name';

  @override
  String get createBudgetSuccess => 'Budget created successfully';

  @override
  String get createBudgetTitle => 'Create Budget';

  @override
  String get createBudgetDefaultName => 'My Plan';

  @override
  String get createBudgetPersonalize => 'Personalize Your Plan';

  @override
  String get createBudgetPlanCurrency => 'Plan Currency';

  @override
  String get createBudgetWelcomeTitle => 'Welcome, new OpenBudgeter!';

  @override
  String get createBudgetWelcomeSubtitle =>
      'We\'ll show you how to give every dollar a job so you can spend without second-guessing.';

  @override
  String get createBudgetWelcomeBody =>
      'First, let\'s make sure your categories are in tip-top shape.';

  @override
  String get creditCardPaymentsTitle => 'Credit Card Payments';

  @override
  String get creditCardSpentThisMonth => 'Spent this month';

  @override
  String get deleteConfirmButton => 'Delete';

  @override
  String get deleteConfirmMessage => 'Are you sure you want to delete this?';

  @override
  String get deleteConfirmTitle => 'Delete';

  @override
  String get deleteError => 'Could not delete. Please try again.';

  @override
  String get deleteSuccess => 'Deleted successfully';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get dialogDone => 'Done';

  @override
  String get dialogSave => 'Save';

  @override
  String get dialogSaving => 'Saving...';

  @override
  String duplicateWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Possible duplicates: $count similar transactions found',
      one: 'Possible duplicate: 1 similar transaction found',
    );
    return '$_temp0';
  }

  @override
  String get editEnvelopeError => 'Could not update envelope';

  @override
  String get editEnvelopeSaved => 'Envelope updated';

  @override
  String get editEnvelopeTitle => 'Edit Envelope';

  @override
  String get envelopeActionEditEnvelope => 'Edit Envelope';

  @override
  String get envelopeActionMoveMoney => 'Move Money';

  @override
  String get envelopeActionSetGoal => 'Set Goal';

  @override
  String get envelopeActivityTitle => 'Activity';

  @override
  String get envelopeAssigned => 'Assigned';

  @override
  String get envelopeAvailable => 'Available';

  @override
  String envelopeCarryover(String amount) {
    return 'Carried over: $amount';
  }

  @override
  String get envelopeFromLastMonth => 'From Last Month';

  @override
  String get envelopeNoActivity => 'No transactions this month';

  @override
  String get envelopeNoteHint => 'Add a note for this envelope (optional)';

  @override
  String get envelopeNoteLabel => 'Note';

  @override
  String get envelopeReorderHint =>
      'Long press an envelope to reorder within category';

  @override
  String envelopeUnderfunded(String amount) {
    return '$amount needed';
  }

  @override
  String get goalAmountLabel => 'Target Amount';

  @override
  String get goalDateLabel => 'Target Date';

  @override
  String get goalDateSelect => 'Select a date';

  @override
  String get goalError => 'Could not save goal. Please try again.';

  @override
  String get goalRemove => 'Remove Goal';

  @override
  String get goalRemoved => 'Goal removed';

  @override
  String get goalSaved => 'Goal saved';

  @override
  String get goalSetGoal => 'Set Goal';

  @override
  String get goalSetTitle => 'Set Goal';

  @override
  String get goalTypeBalance => 'Balance';

  @override
  String get goalTypeByDate => 'By Date';

  @override
  String get goalTypeLabel => 'Goal Type';

  @override
  String get goalTypeMonthly => 'Monthly';

  @override
  String homeBudgetAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts',
      one: '1 account',
    );
    return '$_temp0';
  }

  @override
  String homeBudgetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count budgets',
      one: '1 budget',
    );
    return '$_temp0';
  }

  @override
  String homeBudgetOverspent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count overspent',
      one: '1 overspent',
    );
    return '$_temp0';
  }

  @override
  String homeBudgetReadyToAssign(String amount) {
    return '$amount to assign';
  }

  @override
  String get homeBudgetTotalBalance => 'Total Balance';

  @override
  String get homeCreateBudget => 'Create Your First Budget';

  @override
  String get homeLoadError => 'Could not load budgets';

  @override
  String get homeLogout => 'Sign Out';

  @override
  String get homeNetWorthLabel => 'Net Worth';

  @override
  String homeNetWorthAccounts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count accounts',
      one: '1 account',
    );
    return '$_temp0';
  }

  @override
  String get homeNoBudgets => 'No Budgets Yet';

  @override
  String get homeRetry => 'Retry';

  @override
  String importButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count Transactions',
      one: 'Import 1 Transaction',
    );
    return '$_temp0';
  }

  @override
  String get importCsvHint =>
      'Date,Description,Amount\n2026-01-15,Grocery Store,-45.50\n2026-01-16,Paycheck,2500.00';

  @override
  String get importCsvLabel => 'CSV Data';

  @override
  String get importError => 'Could not import transactions. Please try again.';

  @override
  String get importImporting => 'Importing...';

  @override
  String get importInstructions =>
      'Paste CSV data with columns for date, description, and amount. Headers are auto-detected.';

  @override
  String importMoreRows(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '...and $count more rows',
      one: '...and 1 more row',
    );
    return '$_temp0';
  }

  @override
  String get importPreview => 'Preview';

  @override
  String importPreviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions to import',
      one: '1 transaction to import',
    );
    return '$_temp0';
  }

  @override
  String importSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions imported',
      one: '1 transaction imported',
    );
    return '$_temp0';
  }

  @override
  String get importTitle => 'Import Transactions';

  @override
  String get loginButton => 'Log In';

  @override
  String get loginContinueWithApple => 'Continue with Apple';

  @override
  String get loginContinueWithGoogle => 'Continue with Google';

  @override
  String get loginCreateAccount => 'Create Account';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginForgotPassword => 'Forgot Password?';

  @override
  String get loginLoading => 'Signing In...';

  @override
  String get loginOrSeparator => 'or';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String loginProviderUnavailable(String provider) {
    return '$provider is not available yet.';
  }

  @override
  String get loginTitle => 'Welcome to OpenBudget';

  @override
  String get moveMoneyButton => 'Move';

  @override
  String get moveMoneyError => 'Could not move money. Please try again.';

  @override
  String get moveMoneyFrom => 'From Envelope';

  @override
  String get moveMoneySameError => 'Cannot move money to the same envelope';

  @override
  String get moveMoneySuccess => 'Money moved between envelopes';

  @override
  String get moveMoneyTitle => 'Move Money';

  @override
  String get moveMoneyTo => 'To Envelope';

  @override
  String get netWorthAssets => 'Assets';

  @override
  String get netWorthEmptySubtitle =>
      'Add accounts to see your net worth breakdown';

  @override
  String get netWorthEmptyTitle => 'No Accounts Yet';

  @override
  String get netWorthLiabilities => 'Liabilities';

  @override
  String get netWorthLoadError => 'Could not load net worth data';

  @override
  String get netWorthTitle => 'Net Worth';

  @override
  String get payeeAddButton => 'Add Payee';

  @override
  String get payeeAutoEnvelopeHint =>
      'Envelope auto-suggested from last transaction with this payee';

  @override
  String get payeeCreateError => 'Could not create payee. Please try again.';

  @override
  String get payeeCreateSuccess => 'Payee created';

  @override
  String get payeeEditError => 'Could not update payee. Please try again.';

  @override
  String get payeeEditSuccess => 'Payee updated';

  @override
  String get payeeEditTitle => 'Edit Payee';

  @override
  String get payeeEmptySubtitle => 'Add payees to track who you transact with';

  @override
  String get payeeEmptyTitle => 'No Payees Yet';

  @override
  String get payeeLabel => 'Payee';

  @override
  String get payeeListTitle => 'Payees';

  @override
  String get payeeLoadError => 'Could not load payees';

  @override
  String get payeeMergeButton => 'Merge';

  @override
  String get payeeMergeError => 'Could not merge payees. Please try again.';

  @override
  String get payeeMergeInto => 'Merge into';

  @override
  String get payeeMergeSuccess => 'Payees merged';

  @override
  String get payeeMergeTitle => 'Merge Payee';

  @override
  String get payeeNameLabel => 'Payee Name';

  @override
  String get payeeNone => 'No Payee';

  @override
  String get payeeSearchHint => 'Search payees...';

  @override
  String get payeeSearchNoResults => 'No matching payees';

  @override
  String payeeSearchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payees',
      one: '1 payee',
    );
    return '$_temp0';
  }

  @override
  String get quickBudgetAverageBudgeted => 'Average Budgeted';

  @override
  String get quickBudgetAverageSpent => 'Average Spent';

  @override
  String get quickBudgetError => 'Could not load budget suggestions';

  @override
  String get quickBudgetLastMonth => 'Budgeted Last Month';

  @override
  String get quickBudgetSpentLastMonth => 'Spent Last Month';

  @override
  String get quickBudgetTitle => 'Quick Budget';

  @override
  String get reconcileAdjustmentNote =>
      'An adjustment transaction will be created for the difference.';

  @override
  String get reconcileBalanceHint => 'Enter your current bank balance';

  @override
  String get reconcileBalanceLabel => 'Statement Balance';

  @override
  String get reconcileButton => 'Reconcile';

  @override
  String get reconcileClearedBalance => 'Cleared Balance';

  @override
  String get reconcileDifference => 'Difference';

  @override
  String get reconcileError => 'Could not reconcile account. Please try again.';

  @override
  String get reconcileMessage =>
      'Mark all cleared transactions as reconciled? This locks them from further editing.';

  @override
  String get recentMovesArrowLabel => 'to';

  @override
  String get recentMovesDetailTitle => 'Moves';

  @override
  String get recentMovesEmptySubtitle =>
      'Moves and assignments will appear here as you budget.';

  @override
  String get recentMovesEmptyTitle => 'No recent moves yet';

  @override
  String recentMovesNoEnvelopeHistory(String envelopeName) {
    return 'No move history for $envelopeName';
  }

  @override
  String get recentMovesNoEnvelopeHistoryHint =>
      'This envelope has not been part of a recorded move yet.';

  @override
  String get recentMovesReadyToAssign => 'Ready to Assign';

  @override
  String get recentMovesTabAll => 'All';

  @override
  String get recentMovesTabAssigned => 'Assigned';

  @override
  String get recentMovesTabMoved => 'Moved';

  @override
  String get recentMovesTitle => 'Recent Moves';

  @override
  String get recentMovesCoachTitle => 'Recent Moves';

  @override
  String get recentMovesCoachBody =>
      'OpenBudget keeps a 34-day history of assignments and money moves for each plan.';

  @override
  String get recentMovesCoachHint =>
      'Tap any blue category chip to view move details for that category.';

  @override
  String get recentMovesCoachGotIt => 'Got It!';

  @override
  String get recentMovesUnnamedEnvelope => 'Unnamed Envelope';

  @override
  String reconcileSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions reconciled',
      one: '1 transaction reconciled',
      zero: 'No transactions to reconcile',
    );
    return '$_temp0';
  }

  @override
  String reconcileSuccessWithAdjustment(int count, String adjustment) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions reconciled with $adjustment adjustment',
      one: '1 transaction reconciled with $adjustment adjustment',
      zero: 'Reconciled with $adjustment adjustment',
    );
    return '$_temp0';
  }

  @override
  String get reconcileTitle => 'Reconcile Account';

  @override
  String get recurringAddButton => 'Add Recurring';

  @override
  String get recurringAddTitle => 'Add Recurring Transaction';

  @override
  String recurringAutoPosted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scheduled transactions auto-posted',
      one: '1 scheduled transaction auto-posted',
    );
    return '$_temp0';
  }

  @override
  String get recurringCreateError =>
      'Could not create recurring transaction. Please try again.';

  @override
  String get recurringCreateSuccess => 'Recurring transaction created';

  @override
  String recurringDueBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count scheduled transactions are due',
      one: '1 scheduled transaction is due',
    );
    return '$_temp0';
  }

  @override
  String get recurringDueLabel => 'Due now';

  @override
  String get recurringEditError =>
      'Could not update recurring transaction. Please try again.';

  @override
  String get recurringEditSuccess => 'Recurring transaction updated';

  @override
  String get recurringEditTitle => 'Edit Recurring Transaction';

  @override
  String get recurringEmptySubtitle =>
      'Set up recurring transactions for bills, subscriptions, and regular income';

  @override
  String get recurringEmptyTitle => 'No Recurring Transactions';

  @override
  String get recurringFreqBiweekly => 'Biweekly';

  @override
  String get recurringFreqDaily => 'Daily';

  @override
  String get recurringFreqMonthly => 'Monthly';

  @override
  String get recurringFreqWeekly => 'Weekly';

  @override
  String get recurringFreqYearly => 'Yearly';

  @override
  String get recurringFrequencyLabel => 'Frequency';

  @override
  String get recurringListTitle => 'Recurring Transactions';

  @override
  String get recurringLoadError => 'Could not load recurring transactions';

  @override
  String get recurringNextDate => 'Next';

  @override
  String get recurringPostDue => 'Post Now';

  @override
  String get recurringPostError =>
      'Could not post scheduled transactions. Please try again.';

  @override
  String recurringPostSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions posted',
      one: '1 transaction posted',
    );
    return '$_temp0';
  }

  @override
  String recurringTotalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recurring transactions',
      one: '1 recurring transaction',
    );
    return '$_temp0';
  }

  @override
  String get recurringPosting => 'Posting...';

  @override
  String get recurringSkipButton => 'Skip';

  @override
  String get recurringSkipError =>
      'Could not skip occurrence. Please try again.';

  @override
  String get recurringSkipSuccess => 'Occurrence skipped';

  @override
  String get recurringStartDate => 'Start Date';

  @override
  String get scheduledCalendarTitle => 'Schedule Calendar';

  @override
  String get scheduledCalendarLoadError => 'Could not load calendar data';

  @override
  String get scheduledCalendarNoEvents =>
      'No scheduled transactions on this day';

  @override
  String get scheduledCalendarSelectDay =>
      'Tap a day to see scheduled transactions';

  @override
  String get scheduledCalendarMon => 'Mon';

  @override
  String get scheduledCalendarTue => 'Tue';

  @override
  String get scheduledCalendarWed => 'Wed';

  @override
  String get scheduledCalendarThu => 'Thu';

  @override
  String get scheduledCalendarFri => 'Fri';

  @override
  String get scheduledCalendarSat => 'Sat';

  @override
  String get scheduledCalendarSun => 'Sun';

  @override
  String get registerAlreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get registerCodeError =>
      'Invalid verification code. Please try again.';

  @override
  String get registerCodeLabel => 'Verification Code';

  @override
  String get registerCodeRequired => 'Please enter the verification code';

  @override
  String get registerConfirmPassword => 'Confirm Password';

  @override
  String get registerCreateAccount => 'Create Account';

  @override
  String get registerEmailError =>
      'Could not start registration. Please try again.';

  @override
  String get registerEmailRequired => 'Please enter your email address';

  @override
  String get registerPasswordMismatch => 'Passwords do not match';

  @override
  String get registerPasswordRequired => 'Please enter a password';

  @override
  String get registerSendCode => 'Send Verification Code';

  @override
  String get registerStepCode =>
      'Enter the verification code sent to your email';

  @override
  String get registerStepEmail => 'Enter your email to get started';

  @override
  String get registerStepPassword => 'Choose a password for your account';

  @override
  String get registerSubmitting => 'Please wait...';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerVerifyCode => 'Verify Code';

  @override
  String get reportsEmptySubtitle =>
      'Add transactions to see spending reports for this month';

  @override
  String get reportsEmptyTitle => 'No Data Yet';

  @override
  String get reportsExpenses => 'Expenses';

  @override
  String get reportsIncome => 'Income';

  @override
  String get reportsLoadError => 'Could not load report data';

  @override
  String get reportsNetIncome => 'Net Income';

  @override
  String get reportsSpendingByCategory => 'Spending by Category';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsTransactions => 'Transactions';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsAccountEmail => 'openbudget.user@email.com';

  @override
  String get settingsAccountSettings => 'Account Settings';

  @override
  String get settingsAccountSettingsHint =>
      'Update login credentials or account security';

  @override
  String get settingsAppIcon => 'App Icon';

  @override
  String get settingsAppIconHint =>
      'Applies instantly to OpenBudget in-app branding previews.';

  @override
  String get settingsAppIconPrimary => 'Primary';

  @override
  String get settingsAppIconV1 => 'Classic';

  @override
  String get settingsAppIconV2 => 'Compass';

  @override
  String get settingsAppIconV3 => 'Sprout';

  @override
  String get settingsAppIconV4 => 'Ledger';

  @override
  String get settingsAppIconV5 => 'Arrow';

  @override
  String get settingsAppSection => 'App';

  @override
  String get settingsBalanceStyle => 'Balance Style';

  @override
  String get settingsBalanceStyleAccessible => 'Differentiate Without Color';

  @override
  String get settingsBalanceStyleDefault => 'Default';

  @override
  String get settingsBudgetName => 'Budget Name';

  @override
  String get settingsBudgetSection => 'Budget';

  @override
  String get settingsCaliforniaPrivacyPolicy => 'California Privacy Policy';

  @override
  String settingsComingSoon(String featureName) {
    return '$featureName is coming soon.';
  }

  @override
  String get settingsCurrencyPlacement => 'Currency Placement';

  @override
  String get settingsCurrencyPlacementAfter => 'After Amount (123,456.78\$)';

  @override
  String get settingsCurrencyPlacementBefore => 'Before Amount (\$123,456.78)';

  @override
  String get settingsCurrencyUpdateError =>
      'Could not update plan currency. Please try again.';

  @override
  String settingsCurrencyUpdated(String currencyCode) {
    return 'Plan currency updated to $currencyCode';
  }

  @override
  String get settingsCurrency => 'Currency';

  @override
  String get settingsDataSection => 'Data';

  @override
  String get settingsCurrentPlan => 'Current Plan';

  @override
  String get settingsDateFormat => 'Date Format';

  @override
  String get settingsDateFormatDayMonthYear => '30/12/2025';

  @override
  String get settingsDateFormatMonthDayYear => '12/30/2025';

  @override
  String get settingsDateFormatYearMonthDay => '2025-12-30';

  @override
  String get settingsDeletePlan => 'Delete Plan';

  @override
  String get settingsDisplayOptions => 'Display Options';

  @override
  String get settingsDisplayOptionsHint =>
      'Display options are applied instantly across OpenBudget screens.';

  @override
  String get settingsDisplayCurrency => 'Display Currency';

  @override
  String get settingsDisplayCurrencyMatchDefault =>
      'Match Plan Currency (Default)';

  @override
  String get settingsDisplayCurrencyUpdateError =>
      'Could not update display currency. Please try again.';

  @override
  String settingsDisplayCurrencyUpdated(String currencyCode) {
    return 'Display currency updated to $currencyCode';
  }

  @override
  String get settingsDisplayCurrencyDefaultUpdated =>
      'Display currency now matches plan currency.';

  @override
  String get settingsExportData => 'Export Budget';

  @override
  String get settingsExportDataHint =>
      'Copy all budget data as JSON to clipboard';

  @override
  String get settingsExportError =>
      'Could not export budget data. Please try again.';

  @override
  String get settingsExportSuccess => 'Budget data copied to clipboard';

  @override
  String get settingsFreshStartButton => 'Create New Plan';

  @override
  String get settingsFreshStartHint =>
      'Create a new plan from scratch while keeping your existing plan intact.';

  @override
  String get settingsFreshStart => 'Make a Fresh Start';

  @override
  String get settingsLastSynced => 'App last synced: 2026-02-21T02:00:00Z';

  @override
  String get settingsLegal => 'Legal';

  @override
  String get settingsLoadError => 'Could not load settings';

  @override
  String get settingsLoggedInAs => 'Logged in as';

  @override
  String get settingsLogOut => 'Log Out';

  @override
  String get settingsLogoutConfirm => 'Are you sure you want to sign out?';

  @override
  String get settingsManageBankConnections => 'Manage Bank Connections';

  @override
  String get settingsMiscSection => 'Misc';

  @override
  String get settingsNavigationSection => 'Quick Access';

  @override
  String get settingsNewPlan => 'New Plan';

  @override
  String get settingsNumberFormat => 'Number Format';

  @override
  String get settingsNumberFormatEuropean => '123.456,78';

  @override
  String get settingsNumberFormatStandard => '123,456.78';

  @override
  String get settingsOpenPlan => 'Open Plan';

  @override
  String get settingsPlanSettings => 'Plan Settings';

  @override
  String get settingsPrivacySection => 'Privacy';

  @override
  String get settingsHideAmounts => 'Hide Amounts';

  @override
  String get settingsHideAmountsHint =>
      'Conceal balances and transaction amounts.';

  @override
  String get settingsHideProgressBars => 'Hide Progress Bars';

  @override
  String get settingsHideProgressBarsHint =>
      'Hide spending and funding progress visuals.';

  @override
  String get settingsRenameBudget => 'Rename Budget';

  @override
  String get settingsRenameError =>
      'Could not rename budget. Please try again.';

  @override
  String get settingsRenameSuccess => 'Budget renamed';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsSendDiagnostics => 'Send in Diagnostics';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsTogether => 'OpenBudget Together';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsVersion => 'App Version 1.0.0 (1)';

  @override
  String get settingsWriteAReview => 'Write a Review';

  @override
  String get settingsYourPrivacyChoices => 'Your Privacy Choices';

  @override
  String get spendingByPayeeBreakdown => 'Spending Breakdown';

  @override
  String get spendingByPayeeEmptySubtitle =>
      'Add expense transactions to see spending by payee';

  @override
  String get spendingByPayeeEmptyTitle => 'No Payee Data';

  @override
  String get spendingByPayeePayeeCount => 'Payees';

  @override
  String get spendingByPayeeTitle => 'Spending by Payee';

  @override
  String get spendingByPayeeTotalSpent => 'Total Spent';

  @override
  String spendingByPayeeTransactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions',
      one: '1 transaction',
    );
    return '$_temp0';
  }

  @override
  String get spendingTrendsAvgExpenses => 'Avg. Expenses';

  @override
  String get spendingTrendsAvgIncome => 'Avg. Income';

  @override
  String get spendingTrendsBreakdown => 'Monthly Breakdown';

  @override
  String get spendingTrendsEmptySubtitle =>
      'Add transactions to see spending trends over time';

  @override
  String get spendingTrendsEmptyTitle => 'No Spending Data';

  @override
  String get spendingTrendsLoadError => 'Could not load spending trends';

  @override
  String get spendingTrendsMonthly => 'Monthly Comparison';

  @override
  String get spendingTrendsTitle => 'Spending Trends';

  @override
  String get splitAddSplit => 'Add Split';

  @override
  String get splitAmountLabel => 'Amount';

  @override
  String splitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count splits',
      one: '1 split',
    );
    return '$_temp0';
  }

  @override
  String get splitEnvelopeLabel => 'Envelope';

  @override
  String get splitLabel => 'Split';

  @override
  String get splitMemoLabel => 'Memo (optional)';

  @override
  String get splitMinimumError => 'At least two splits are required';

  @override
  String get splitMismatchError => 'Split amounts must equal the total';

  @override
  String get splitRemainingLabel => 'Remaining to assign';

  @override
  String get splitRemoveSplit => 'Remove';

  @override
  String get splitSaveError =>
      'Could not save split transaction. Please try again.';

  @override
  String get splitSaveSuccess => 'Split transaction saved';

  @override
  String get splitTransactionTitle => 'Split Transaction';

  @override
  String get templateApplyButton => 'Apply';

  @override
  String get templateApplyError =>
      'Could not apply template. Please try again.';

  @override
  String get templateApplySuccess => 'Template applied to current month';

  @override
  String get templateDeleteError =>
      'Could not delete template. Please try again.';

  @override
  String get templateDeleteSuccess => 'Template deleted';

  @override
  String get templateEmptySubtitle =>
      'Save your current month allocations as a template to quickly set up future months.';

  @override
  String get templateEmptyTitle => 'No Templates';

  @override
  String get templateNameHint => 'e.g. Standard Month';

  @override
  String get templateNameLabel => 'Template Name';

  @override
  String get templateSaveButton => 'Save Current Month as Template';

  @override
  String get templateSaveError => 'Could not save template. Please try again.';

  @override
  String get templateSaveSuccess => 'Template saved';

  @override
  String get templateTitle => 'Budget Templates';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get themeTitle => 'Appearance';

  @override
  String get transactionAddExpense => 'Add Expense';

  @override
  String get transactionFlagTitle => 'Set Flag';

  @override
  String get transactionFlagRed => 'Red';

  @override
  String get transactionFlagOrange => 'Orange';

  @override
  String get transactionFlagYellow => 'Yellow';

  @override
  String get transactionFlagGreen => 'Green';

  @override
  String get transactionFlagBlue => 'Blue';

  @override
  String get transactionFlagPurple => 'Purple';

  @override
  String get transactionFlagClear => 'Clear Flag';

  @override
  String get transactionAddIncome => 'Add Income';

  @override
  String get transactionAmountLabel => 'Amount';

  @override
  String get transactionCleared => 'Cleared';

  @override
  String get transactionDateToday => 'Today';

  @override
  String get transactionDateYesterday => 'Yesterday';

  @override
  String get transactionDescriptionLabel => 'Description';

  @override
  String get transactionEditError =>
      'Could not update transaction. Please try again.';

  @override
  String get transactionEditSuccess => 'Transaction updated';

  @override
  String get transactionEditTitle => 'Edit Transaction';

  @override
  String get transactionEmpty => 'No transactions yet';

  @override
  String get transactionError =>
      'Could not save transaction. Please try again.';

  @override
  String get transactionExportCsv => 'Copy as CSV';

  @override
  String transactionExportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count transactions copied to clipboard',
      one: '1 transaction copied to clipboard',
    );
    return '$_temp0';
  }

  @override
  String get transactionFilterAll => 'All';

  @override
  String get transactionFilterCleared => 'Cleared';

  @override
  String get transactionFilterExpense => 'Expense';

  @override
  String get transactionFilterFlagged => 'Flagged';

  @override
  String get transactionFilterIncome => 'Income';

  @override
  String get transactionFilterReconciled => 'Reconciled';

  @override
  String get transactionFilterStatus => 'Status';

  @override
  String get transactionFilterUncleared => 'Uncleared';

  @override
  String get transactionListTitle => 'Transactions';

  @override
  String get transactionLoadError => 'Could not load transactions';

  @override
  String get transactionMemoHint => 'Add a note (optional)';

  @override
  String get transactionMemoLabel => 'Memo';

  @override
  String get transactionNoResults => 'No matching transactions';

  @override
  String get transactionReconciled => 'Reconciled';

  @override
  String transactionResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get transactionSave => 'Save Transaction';

  @override
  String get transactionDateRangeFilter => 'Date range';

  @override
  String get transactionDateRangeClear => 'Clear date filter';

  @override
  String get transactionSearchHint => 'Search description or memo...';

  @override
  String get transactionSubmitting => 'Saving...';

  @override
  String get transactionSuccess => 'Transaction saved';

  @override
  String get transactionUnassigned => 'Unassigned';

  @override
  String get transactionUncleared => 'Uncleared';

  @override
  String get transferButton => 'Transfer';

  @override
  String get transferDate => 'Transfer Date';

  @override
  String get transferDefaultDescription => 'Account Transfer';

  @override
  String get transferError => 'Could not complete transfer. Please try again.';

  @override
  String get transferFromAccount => 'From Account';

  @override
  String get transferNeedTwoAccounts =>
      'You need at least two accounts to make a transfer';

  @override
  String get transferSameAccountError => 'Cannot transfer to the same account';

  @override
  String get transferSuccess => 'Transfer completed';

  @override
  String get transferTitle => 'Transfer';

  @override
  String get transactionRulesTitle => 'Transaction Rules';

  @override
  String get transactionRulesEmptyTitle => 'No Rules Yet';

  @override
  String get transactionRulesEmptySubtitle =>
      'Create rules to auto-assign envelopes when you select a payee';

  @override
  String get transactionRulesLoadError => 'Could not load transaction rules';

  @override
  String get transactionRulesAddButton => 'Add Rule';

  @override
  String get transactionRulesPayeeLabel => 'When payee is';

  @override
  String get transactionRulesEnvelopeLabel => 'Assign to envelope';

  @override
  String get transactionRulesCreateError =>
      'Could not create rule. Please try again.';

  @override
  String get transactionRulesCreateSuccess => 'Rule created';

  @override
  String get transactionRulesDeleteError =>
      'Could not delete rule. Please try again.';

  @override
  String get transactionRulesDeleteSuccess => 'Rule deleted';

  @override
  String get transactionRulesToggleError =>
      'Could not update rule. Please try again.';

  @override
  String get transactionRulesEnabled => 'Enabled';

  @override
  String get transactionRulesDisabled => 'Disabled';

  @override
  String transactionRulesTotalCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count total',
      one: '1 total',
    );
    return '$_temp0';
  }

  @override
  String get transactionRulesAutoAssigned => 'Auto-assigned by rule';

  @override
  String get transferToAccount => 'To Account';

  @override
  String get undoAction => 'Undo';

  @override
  String get undoDeleteSuccess => 'Restored successfully';

  @override
  String get undoDeleteError => 'Could not restore. Please try again.';

  @override
  String get transactionSortTitle => 'Sort by';

  @override
  String get transactionSortDateDesc => 'Date (newest first)';

  @override
  String get transactionSortDateAsc => 'Date (oldest first)';

  @override
  String get transactionSortAmountDesc => 'Amount (highest first)';

  @override
  String get transactionSortAmountAsc => 'Amount (lowest first)';

  @override
  String get transactionSortDescription => 'Description (A-Z)';

  @override
  String get tabPlan => 'Plan';

  @override
  String get tabAccounts => 'Accounts';

  @override
  String get tabAdd => 'Add';

  @override
  String get tabReflect => 'Reflect';

  @override
  String get tabMore => 'More';

  @override
  String get addTransactionSheetTitle => 'Add Transaction';

  @override
  String get addTransactionIncome => 'Add Income';

  @override
  String get addTransactionExpense => 'Add Expense';

  @override
  String get addTransactionTransfer => 'Transfer';

  @override
  String get moreScreenTitle => 'More';

  @override
  String get moreRecurring => 'Recurring Transactions';

  @override
  String get morePayees => 'Payees';

  @override
  String get moreRules => 'Transaction Rules';

  @override
  String get moreImport => 'Import Transactions';

  @override
  String get moreSettings => 'Settings';

  @override
  String get accountSettingsUnavailableHint =>
      'Currently unavailable in this build.';

  @override
  String get accountSettingsReadOnlyNotice =>
      'Account settings are read-only in this build. Profile, login method, and security updates are unavailable.';

  @override
  String get accountSettingsProfile => 'Profile';

  @override
  String get accountSettingsFirstName => 'First Name';

  @override
  String get accountSettingsUnavailableFieldHint => 'Unavailable in this build';

  @override
  String get accountSettingsSaveUnavailable => 'Save (Unavailable)';

  @override
  String get accountSettingsLoginMethods => 'Login Methods';

  @override
  String get accountSettingsEmailPassword => 'Email & Password';

  @override
  String get accountSettingsChangeEmailPassword => 'Change Email & Password';

  @override
  String get accountSettingsSocialLoginUnavailable =>
      'Apple and Google login method changes are unavailable in this build.';

  @override
  String get accountSettingsTwoStepVerification => 'Two-Step Verification';

  @override
  String get accountSettingsTwoStepHint =>
      'Increase your OpenBudget login security by adding a second method of login.';

  @override
  String get accountSettingsSetUp => 'Set Up';

  @override
  String get accountSettingsDeleteSectionHint =>
      'Account deletion is currently unavailable in this build. Open this page to review status and availability.';

  @override
  String get accountSettingsDeleteUnavailableHint =>
      'No account data can be removed from this app yet.';

  @override
  String get settingsAccountsOverviewHint =>
      'View and organize every account in your budget.';

  @override
  String get settingsAddAccountHint =>
      'Add manual accounts, bank links, or wallets.';

  @override
  String get settingsManageBankConnectionsHint =>
      'Connect Plaid banks or add Solana wallets.';

  @override
  String get deleteAccountUnavailableNotice =>
      'Account deletion is currently unavailable in this build. No account or plan data can be removed from this screen.';

  @override
  String get deleteAccountUnavailableHint =>
      'Delete requests are disabled until backend account deletion is available.';

  @override
  String get deleteAccountUnavailableButton => 'Delete Account (Unavailable)';

  @override
  String get transactionCategoryLabel => 'Category';

  @override
  String get transactionAccountLabel => 'Account';

  @override
  String get transactionDateLabel => 'Date';

  @override
  String get addAccountConnectWallet => 'Connect Solana Wallet';

  @override
  String get addAccountUnlinkedTitle => 'Add Unlinked Account';

  @override
  String get addAccountSelectAccountType => 'Select Account Type';

  @override
  String get addAccountSuccessTitle => 'Account Added';

  @override
  String get addAccountSelectTypePlaceholder => 'Select account type...';

  @override
  String get addAccountLoadingInstitutions => 'Loading institutions...';

  @override
  String get addAccountConnectWalletButton => 'Connect Wallet';

  @override
  String get dialogNext => 'Next';

  @override
  String get loadingTitle => 'Loading...';

  @override
  String get loadingHint => 'This might take a few seconds.';

  @override
  String get addAccountPopularOptions => 'Popular Options';

  @override
  String get searchResults => 'Search Results';

  @override
  String get addAccountSearchForBank => 'Search for your bank';

  @override
  String get addAccountSearchByInstitutionName => 'Search by institution name';

  @override
  String get addAccountSearchHint =>
      'Search by institution name or web address (URL)';

  @override
  String get addAccountNoInstitutionsFound =>
      'No institutions found. Try another name or add an unlinked account.';

  @override
  String get orText => 'or';

  @override
  String get addAccountAddUnlinked => 'Add an Unlinked Account';

  @override
  String get addAccountWalletConnectionDescription =>
      'Connect a Solana wallet in read-only mode. OpenBudget imports native SPL balances and keeps fiat valuation synced.';

  @override
  String get addAccountWalletAddressLabel => 'Wallet Address';

  @override
  String get addAccountWalletAddressHint => 'Paste Solana wallet address';

  @override
  String get addAccountWalletLabelOptional => 'Wallet Label (optional)';

  @override
  String get addAccountWalletLabelHint => 'My Solana Wallet';

  @override
  String get addAccountWalletIncludeInBudgetTotals =>
      'Include in budget totals';

  @override
  String get addAccountWalletIntro =>
      'Add your Solana wallet to track transfers, swaps, and holdings in one place.';

  @override
  String get addAccountUnlinkedIntro =>
      'Bank connections are currently unavailable in this build, so let\'s set up an unlinked account.';

  @override
  String get addAccountNicknameQuestion => 'Give it a nickname';

  @override
  String get addAccountNicknameHint => 'Enter nickname';

  @override
  String get addAccountTypeQuestion => 'What type of account are you adding?';

  @override
  String get addAccountWalletAutoSyncHint =>
      'OpenBudget will auto-sync transactions and holdings after wallet setup. You can tag and categorize activity in account details.';

  @override
  String get addAccountWalletAddressQuestion =>
      'What is your Solana wallet address?';

  @override
  String get addAccountWalletAddressExample => 'e.g. 5xQf...w8bP';

  @override
  String get addAccountWalletPublicAddressOnly =>
      'Only public wallet addresses are supported.';

  @override
  String get addAccountBalanceQuestion =>
      'What is your current account balance?';

  @override
  String get addAccountBalanceExample => '5000';

  @override
  String get addAccountSectionCashAccounts => 'Cash Accounts';

  @override
  String get addAccountSectionCashAccountsHint =>
      'Cash accounts hold funds you already own and can spend immediately.';

  @override
  String get addAccountSectionCreditAccounts => 'Credit Accounts';

  @override
  String get addAccountSectionCreditAccountsHint =>
      'A credit account lets you spend borrowed money that you\'ll need to repay later, often with interest.';

  @override
  String get addAccountTypeLineOfCredit => 'Add Account Type Line Of Credit';

  @override
  String get addAccountSectionMortgagesAndLoans => 'Mortgages and Loans';

  @override
  String get addAccountSectionMortgagesAndLoansHint =>
      'Accounts that have an outstanding balance you\'re currently paying off, and aren\'t spending from.';

  @override
  String get addAccountTypeMortgage => 'Add Account Type Mortgage';

  @override
  String get addAccountTypeAutoLoan => 'Add Account Type Auto Loan';

  @override
  String get addAccountTypeStudentLoan => 'Add Account Type Student Loan';

  @override
  String get addAccountTypePersonalLoan => 'Add Account Type Personal Loan';

  @override
  String get addAccountTypeMedicalDebt => 'Add Account Type Medical Debt';

  @override
  String get addAccountTypeOtherDebt => 'Add Account Type Other Debt';

  @override
  String get addAccountSectionTrackingAccounts => 'Tracking Accounts';

  @override
  String get addAccountSectionTrackingAccountsHint =>
      'Accounts that hold money you don\'t plan to spend soon, such as investments or loans.';

  @override
  String get addAccountTypeAssetExample => 'Asset (e.g. Investment)';

  @override
  String get addAccountTypeLiability => 'Add Account Type Liability';

  @override
  String get addAccountSectionDigitalAssets => 'Digital Assets';

  @override
  String get addAccountSectionDigitalAssetsHint =>
      'Track a Solana wallet with automatic transaction history and asset valuations.';

  @override
  String get addAccountTypeSolanaWallet => 'Add Account Type Solana Wallet';

  @override
  String get accountEditNicknameLabel => 'Account Nickname';

  @override
  String get accountEditNicknameHint => 'Daily';

  @override
  String get accountEditNotesLabel => 'Account Notes';

  @override
  String get accountEditNotesHint => 'Enter a memo...';

  @override
  String get accountEditAdjustmentHint =>
      'An adjustment transaction will be created automatically if you change this amount.';

  @override
  String get accountEditBankConnection => 'Bank Connection';

  @override
  String get accountEditLinkAccountUnavailable =>
      'Link an Account (Unavailable)';

  @override
  String get accountEditLinkAccountUnavailableHint =>
      'Bank connections are currently unavailable in this build. Add or manage unlinked accounts instead.';

  @override
  String get accountListAllTransactions => 'All transactions';

  @override
  String get accountDetailBudgetAccount => 'Budget Account';

  @override
  String get accountDetailTrackingAccount => 'Tracking Account';

  @override
  String get accountDetailSelect => 'Select';

  @override
  String get accountDetailHideReconciled => 'Hide Reconciled';

  @override
  String get accountDetailLinkAccountUnavailable =>
      'Link Account (Unavailable)';

  @override
  String get accountDetailLoanOverview => 'Overview';

  @override
  String get accountDetailLoanActivity => 'Activity';

  @override
  String get accountDetailLoanBalance => 'Balance';

  @override
  String get accountDetailLoanPaid => 'Paid';

  @override
  String get accountDetailLoanTotalBorrowed => 'Total Borrowed';

  @override
  String get accountDetailLoanPayoffOverview => 'Loan Payoff Overview';

  @override
  String get accountDetailLoanOneMonth => 'Account Detail Loan One Month';

  @override
  String get accountDetailLoanMonthlyTarget => 'Monthly Target';

  @override
  String get accountDetailLoanDueEvery => 'Due Every';

  @override
  String get accountDetailLoanMonthly => 'Monthly';

  @override
  String get accountDetailLoanDebtFreeDate => 'Debt Free Date';

  @override
  String get accountDetailLoanCreateTarget => 'Create Target';

  @override
  String get accountDetailLoanEditTarget => 'Edit Target';

  @override
  String get accountDetailLoanDetails => 'Loan Details';

  @override
  String get accountDetailLoanInterestRate => 'Interest Rate';

  @override
  String get accountDetailLoanInterestRateValue => '3%';

  @override
  String get accountDetailLoanMonthlyMinimum => 'Monthly Minimum';

  @override
  String get accountDetailNotFound => 'Account not found.';

  @override
  String get accountDetailWalletLoadError => 'Failed to load wallet metadata.';

  @override
  String get accountDetailWalletNotAttached =>
      'No Solana wallet is attached to this account yet.';

  @override
  String get accountDetailWalletSyncFailed =>
      'Wallet sync failed. Check server logs.';

  @override
  String get accountDetailWalletSyncing => 'Syncing';

  @override
  String get accountDetailWalletSync => 'Sync';

  @override
  String get accountDetailWalletEstimatedValue => 'Estimated Value';

  @override
  String get accountDetailWalletAddressCopied => 'Wallet address copied.';

  @override
  String get accountDetailWalletCopy => 'Copy';

  @override
  String get accountDetailWalletFungibleAssets => 'Fungible Assets';

  @override
  String get accountDetailWalletNftAssets => 'NFT Assets';

  @override
  String get accountDetailWalletValuationCoverage => 'Valuation Coverage';

  @override
  String get accountDetailWalletUnpricedAssets => 'Unpriced Assets';

  @override
  String get accountDetailWalletUnrealizedPnl => 'Unrealized P&L';

  @override
  String get accountDetailWalletRealizedPnl => 'Realized P&L';

  @override
  String get accountDetailWalletTaggedTransactions => 'Tagged Transactions';

  @override
  String get accountDetailWalletLastActivity => 'Last Activity';

  @override
  String get accountDetailWalletNoActivity => 'No activity';

  @override
  String get accountDetailWalletTaxYearPnl => 'Tax Year P&L';

  @override
  String get accountDetailWalletEstimated => '(estimated)';

  @override
  String get accountDetailWalletTaxYearLoadError =>
      'Could not load tax-year summary.';

  @override
  String get accountDetailWalletNoDisposalsYet => 'No disposals yet';

  @override
  String get accountDetailWalletNoDisposalsHint =>
      'Tax-year summaries will appear after taxable disposal activity is detected.';

  @override
  String get accountDetailWalletHoldings => 'Holdings';

  @override
  String get accountDetailWalletHoldingsHint =>
      'Token balances with current valuation and detected programs.';

  @override
  String get accountDetailWalletHideDustAssets => 'Hide dust assets (< \$0.01)';

  @override
  String get accountDetailWalletHoldingsLoadError => 'Failed to load holdings.';

  @override
  String get accountDetailWalletNoHoldingsFound => 'No holdings found';

  @override
  String get accountDetailWalletNoHoldingsHint =>
      'Run a sync to fetch tokens and NFTs for this wallet.';

  @override
  String get accountDetailWalletOnlyDustAssets => 'Only dust assets found';

  @override
  String get accountDetailWalletOnlyDustAssetsHint =>
      'Turn off the dust filter to inspect very small-value token balances.';

  @override
  String get accountDetailWalletTransactionHistory => 'Transaction History';

  @override
  String get accountDetailWalletTransactionHistoryHint =>
      'Parsed activity with program context and editable labels.';

  @override
  String get accountDetailWalletTransactionSearchHint =>
      'Search description, category, tags, memo';

  @override
  String get accountDetailWalletNeedsCategory => 'Needs category';

  @override
  String get accountDetailWalletTransactionsLoadError =>
      'Failed to load transactions.';

  @override
  String get accountDetailWalletNoTransactionsYet => 'No transactions yet';

  @override
  String get accountDetailWalletNoTransactionsHint =>
      'Run a sync to import transaction history from the wallet.';

  @override
  String get accountDetailWalletNoTransactionsMatch =>
      'No transactions match filters';

  @override
  String get accountDetailWalletNoTransactionsMatchHint =>
      'Adjust search terms or disable the category filter.';

  @override
  String get accountDetailWalletEditMetadataTitle =>
      'Edit Transaction Metadata';

  @override
  String get accountDetailWalletTagsCommaSeparated => 'Tags (comma separated)';

  @override
  String get accountDetailWalletMetadataUpdated =>
      'Transaction metadata updated.';

  @override
  String get accountDetailWalletMetadataUpdateError =>
      'Could not update transaction metadata.';

  @override
  String get accountDetailWalletNft => 'NFT';

  @override
  String get accountDetailWalletStalePrice => 'Stale price';

  @override
  String get accountDetailWalletUnpriced => 'Unpriced';

  @override
  String get accountDetailWalletNoValuationSource => 'No valuation source';

  @override
  String get accountDetailWalletEditMetadataTooltip => 'Edit metadata';

  @override
  String get accountDetailLoanTarget => 'Loan Target';

  @override
  String get accountDetailLoanMonthlyPayment => 'Monthly payment';

  @override
  String get accountDetailReconcileMatchQuestion =>
      'Does this match your bank balance?';

  @override
  String get dialogYes => 'Yes';

  @override
  String get dialogNo => 'No';

  @override
  String get spendingByPayeeMonth => 'Month';

  @override
  String get spendingByPayeePreset => 'Preset';

  @override
  String get spendingByPayeePresetRange => 'Preset Range';

  @override
  String get editPlanCostToBeMe => 'Cost to Be Me';

  @override
  String get editPlanMonthlyTargets => 'Monthly Targets';

  @override
  String get editPlanMonthlyIncome => 'Monthly Income';

  @override
  String get editPlanCostPromptTitle => 'What does it cost to be you?';

  @override
  String get editPlanCostPromptSubtitle =>
      'Your targets add up to one simple number: everything you plan to spend and save each month.';

  @override
  String get editPlanNewGroup => 'New Group';

  @override
  String get editPlanReorder => 'Reorder';

  @override
  String get editPlanDetails => 'Details';

  @override
  String get editPlanCategoryGroupName => 'Category Group Name';

  @override
  String get editPlanHide => 'Hide';

  @override
  String get editPlanDelete => 'Delete';

  @override
  String get editPlanHideGroupDialogDescription =>
      'Hidden categories are moved to a group at the bottom of your plan.';

  @override
  String get editPlanHideGroupAndCategories => 'Hide Group and Categories';

  @override
  String get editPlanCategoryGroupHidden => 'Category group hidden.';

  @override
  String get editPlanHideGroupError => 'Unable to hide category group.';

  @override
  String get editPlanDeleteGroupError => 'Unable to delete category group.';

  @override
  String get editPlanMoveUp => 'Move up';

  @override
  String get editPlanMoveDown => 'Move down';

  @override
  String get editPlanAddEnvelope => 'Add envelope';

  @override
  String get editPlanGroupDetails => 'Group details';

  @override
  String get editPlanAddTarget => 'Add Target';

  @override
  String get planTitle => 'Plan';

  @override
  String get editPlanTitle => 'Edit Plan';

  @override
  String get budgetDetailCategories => 'Categories';

  @override
  String get budgetDetailSpotlight => 'Spotlight';

  @override
  String get budgetDetailCoverOverspendingTitle => 'Cover Overspending';

  @override
  String get budgetDetailAllOverspendingCovered =>
      'All overspending is covered.';

  @override
  String get budgetDetailCoverButton => 'Cover';

  @override
  String get budgetDetailCovering => 'Covering...';

  @override
  String get reviewTransactionsUpdateCategoryError =>
      'Could not update transaction category.';

  @override
  String get reviewTransactionsDeleteSelected => 'Delete selected';

  @override
  String get reviewTransactionsNoTransactions => 'No Transactions';

  @override
  String get reviewTransactionsSingleNewTransaction => '1 New Transaction';

  @override
  String get reviewTransactionsSubtitle =>
      'Approve or categorize new transactions';

  @override
  String get reviewTransactionsAllDoneTitle => 'You\'re All Done!';

  @override
  String get reviewTransactionsAllDoneSubtitle =>
      'Return to Accounts to see all of your transactions.';

  @override
  String get reviewTransactionsUncategorized => 'Uncategorized';

  @override
  String get reviewTransactionsSelectCategory => 'Select category';

  @override
  String get reviewTransactionsApprove => 'Approve';

  @override
  String get reviewTransactionsCategorize => 'Categorize';

  @override
  String get reviewTransactionsClear => 'Clear';

  @override
  String get moreTitle => 'More';

  @override
  String get setGoalCadenceWeekly => 'Weekly';

  @override
  String get setGoalCadenceMonthly => 'Monthly';

  @override
  String get setGoalCadenceYearly => 'Yearly';

  @override
  String get setGoalCadenceCustom => 'Custom';

  @override
  String get setGoalAmount => 'Amount';

  @override
  String get setGoalINeed => 'I need';

  @override
  String get setGoalBy => 'By';

  @override
  String get setGoalLastDayOfMonth => 'Last Day of the Month';

  @override
  String get setGoalNextMonthINeedTo => 'Next month I want to';

  @override
  String get setGoalIWantTo => 'I want to';

  @override
  String get setGoalDueOn => 'Due on';

  @override
  String get setGoalRepeats => 'Repeats';

  @override
  String get setGoalEvery => 'Every';

  @override
  String get setGoalMonth => 'Month';

  @override
  String get setGoalYear => 'Year';

  @override
  String get setGoalSaveTarget => 'Save Target';

  @override
  String settingsPlanCurrencyDetail(String currencyCode) {
    return 'Plan currency: $currencyCode';
  }

  @override
  String settingsDisplayCurrencyDetail(String currencyCode) {
    return 'Display currency: $currencyCode';
  }

  @override
  String settingsOwner(String ownerLabel) {
    return 'Owner: $ownerLabel';
  }

  @override
  String settingsUpdated(String lastUpdatedLabel) {
    return 'Updated: $lastUpdatedLabel';
  }

  @override
  String addAccountSuccessMessage(String accountTypeLabel) {
    return '$accountTypeLabel account added to OpenBudget.';
  }

  @override
  String accountDetailLoanPaidOff(String percent) {
    return '$percent%\\nPaid Off';
  }

  @override
  String accountDetailLoanPayoffEstimate(String duration) {
    return 'You\'ll pay off your loan in $duration if you pay the minimum every month.';
  }

  @override
  String accountDetailLoanManyMonths(int count) {
    return '$count months';
  }

  @override
  String accountDetailLoanInMonth(String month) {
    return 'In $month';
  }

  @override
  String accountDetailWalletSyncSummary(
    int transactions,
    int holdings,
    int coveredHoldings,
    String coveragePercentText,
    int unpricedHoldings,
    int coveredNfts,
    int nftCount,
    int unpricedNfts,
    Object holdingCount,
  ) {
    return 'Synced $transactions transactions and $holdings holdings. Coverage $coveredHoldings/$holdingCount$coveragePercentText, $unpricedHoldings unpriced. NFTs $coveredNfts/$nftCount, $unpricedNfts unpriced.';
  }

  @override
  String accountDetailWalletTxCount(int transactions) {
    return '$transactions tx';
  }

  @override
  String accountDetailWalletSuggestedCategory(String category) {
    return 'Suggested: $category';
  }

  @override
  String accountDetailWalletUnits(String units) {
    return '$units units';
  }

  @override
  String accountDetailWalletConfidence(String confidence) {
    return '$confidence confidence';
  }

  @override
  String accountDetailWalletBasis(String amount) {
    return 'Basis $amount';
  }

  @override
  String accountDetailWalletPnl(String value, String suffix) {
    return 'P&L $value$suffix';
  }

  @override
  String accountDetailWalletPricePerToken(String amount) {
    return '@ $amount';
  }

  @override
  String accountDetailWalletPnlValue(String value) {
    return 'P&L $value';
  }

  @override
  String accountDetailWalletTaxYear(int year) {
    return 'Tax $year';
  }

  @override
  String accountDetailReconcileMatchTitle(String balance) {
    return 'Your cleared balance in OpenBudget is $balance';
  }

  @override
  String spendingByPayeeLastMonths(int count) {
    return 'Last $count Months';
  }

  @override
  String editPlanEnvelopeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count envelopes',
      one: '1 envelope',
    );
    return '$_temp0';
  }

  @override
  String editPlanDeleteCategoryGroupConfirm(
    String groupName,
    String envelopeSummary,
    String allocated,
  ) {
    return 'Delete category group \"$groupName\"?\\n\\n$envelopeSummary\\n$allocated allocated';
  }

  @override
  String budgetDetailNeedsToCover(String amount) {
    return 'Needs $amount to get back to zero';
  }

  @override
  String budgetDetailCoverOverspent(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Categories',
      one: 'Category',
    );
    return 'Cover $count overspent $_temp0';
  }

  @override
  String reviewTransactionsSelectedTitle(int count) {
    return '$count Selected';
  }

  @override
  String reviewTransactionsNewTransactions(int count) {
    return '$count New Transactions';
  }

  @override
  String reviewTransactionsSelectedAmount(int count, String amount) {
    return '$count selected • $amount';
  }

  @override
  String setGoalSetAsideAnother(String amount) {
    return 'Set aside another $amount';
  }

  @override
  String routerPageNotFound(String error) {
    return 'Page not found: $error';
  }

  @override
  String get editPlanLoadError => 'Failed to load plan setup.';

  @override
  String get budgetDetailCoverOverspendingError =>
      'Could not cover overspending.';
}
