// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'OpenBudget';

  @override
  String get loginTitle => 'Welcome to OpenBudget';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get loginLoading => 'Signing In...';

  @override
  String get loginCreateAccount => 'Create Account';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerStepEmail => 'Enter your email to get started';

  @override
  String get registerStepCode =>
      'Enter the verification code sent to your email';

  @override
  String get registerStepPassword => 'Choose a password for your account';

  @override
  String get registerSendCode => 'Send Verification Code';

  @override
  String get registerCodeLabel => 'Verification Code';

  @override
  String get registerVerifyCode => 'Verify Code';

  @override
  String get registerConfirmPassword => 'Confirm Password';

  @override
  String get registerCreateAccount => 'Create Account';

  @override
  String get registerSubmitting => 'Please wait...';

  @override
  String get registerAlreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get registerEmailRequired => 'Please enter your email address';

  @override
  String get registerEmailError =>
      'Could not start registration. Please try again.';

  @override
  String get registerCodeRequired => 'Please enter the verification code';

  @override
  String get registerCodeError =>
      'Invalid verification code. Please try again.';

  @override
  String get registerPasswordRequired => 'Please enter a password';

  @override
  String get registerPasswordMismatch => 'Passwords do not match';

  @override
  String get homeLogout => 'Sign Out';

  @override
  String get homeNoBudgets => 'No Budgets Yet';

  @override
  String get homeCreateBudget => 'Create Your First Budget';

  @override
  String get homeLoadError => 'Could not load budgets';

  @override
  String get homeRetry => 'Retry';

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
  String get createBudgetTitle => 'Create Budget';

  @override
  String get createBudgetNameLabel => 'Budget Name';

  @override
  String get createBudgetCurrencyLabel => 'Primary Currency';

  @override
  String get createBudgetButton => 'Create';

  @override
  String get budgetEmptyTitle => 'No Categories Yet';

  @override
  String get budgetEmptySubtitle =>
      'Add your first envelope category to start budgeting';

  @override
  String get budgetReadyToAssign => 'Ready to Assign';

  @override
  String get budgetColumnBudgeted => 'Budgeted';

  @override
  String get budgetColumnSpent => 'Spent';

  @override
  String get budgetColumnAvailable => 'Available';

  @override
  String get budgetAddCategory => 'Add Category';

  @override
  String get budgetAddEnvelope => 'Add Envelope';

  @override
  String get budgetAddIncome => 'Add Income';

  @override
  String get budgetAddExpense => 'Add Expense';

  @override
  String get budgetCategoryTotal => 'Total';

  @override
  String get budgetCategoryNameLabel => 'Category Name';

  @override
  String get budgetEnvelopeNameLabel => 'Envelope Name';

  @override
  String get budgetEnvelopeAmountLabel => 'Budgeted Amount';

  @override
  String get budgetLoadError => 'Could not load budget details';

  @override
  String get dialogSave => 'Save';

  @override
  String get dialogSaving => 'Saving...';

  @override
  String get dialogCancel => 'Cancel';

  @override
  String get transactionAddIncome => 'Add Income';

  @override
  String get transactionAddExpense => 'Add Expense';

  @override
  String get transactionDescriptionLabel => 'Description';

  @override
  String get transactionAmountLabel => 'Amount';

  @override
  String get transactionSave => 'Save Transaction';

  @override
  String get transactionSubmitting => 'Saving...';

  @override
  String get transactionUnassigned => 'Unassigned';

  @override
  String get transactionListTitle => 'Transactions';

  @override
  String get transactionLoadError => 'Could not load transactions';

  @override
  String get transactionEmpty => 'No transactions yet';

  @override
  String get createBudgetCreating => 'Creating...';

  @override
  String get createBudgetSuccess => 'Budget created successfully';

  @override
  String get createBudgetError => 'Could not create budget. Please try again.';

  @override
  String get budgetCategoryCreated => 'Category created';

  @override
  String get budgetEnvelopeCreated => 'Envelope created';

  @override
  String get budgetCategoryCreateError => 'Could not create category';

  @override
  String get budgetEnvelopeCreateError => 'Could not create envelope';

  @override
  String get transactionSuccess => 'Transaction saved';

  @override
  String get transactionError =>
      'Could not save transaction. Please try again.';

  @override
  String get deleteConfirmTitle => 'Delete';

  @override
  String get deleteConfirmMessage => 'Are you sure you want to delete this?';

  @override
  String get deleteConfirmButton => 'Delete';

  @override
  String get deleteSuccess => 'Deleted successfully';

  @override
  String get deleteError => 'Could not delete. Please try again.';

  @override
  String get editEnvelopeTitle => 'Edit Envelope';

  @override
  String get editEnvelopeSaved => 'Envelope updated';

  @override
  String get editEnvelopeError => 'Could not update envelope';

  @override
  String get accountListTitle => 'Accounts';

  @override
  String get accountLoadError => 'Could not load accounts';

  @override
  String get accountEmptyTitle => 'No Accounts Yet';

  @override
  String get accountEmptySubtitle => 'Add your first account to track balances';

  @override
  String get accountAddTitle => 'Add Account';

  @override
  String get accountAddButton => 'Add Account';

  @override
  String get accountNameLabel => 'Account Name';

  @override
  String get accountTypeLabel => 'Account Type';

  @override
  String get accountBalanceLabel => 'Starting Balance';

  @override
  String get accountOnBudgetLabel => 'On Budget';

  @override
  String get accountOnBudgetHint => 'Include in budget calculations';

  @override
  String get accountTypeChecking => 'Checking';

  @override
  String get accountTypeSavings => 'Savings';

  @override
  String get accountTypeCreditCard => 'Credit Card';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountTypeInvestment => 'Investment';

  @override
  String get accountTypeOther => 'Other';

  @override
  String get accountOnBudget => 'Budget Accounts';

  @override
  String get accountOffBudget => 'Tracking Accounts';

  @override
  String get accountClosed => 'Closed Accounts';

  @override
  String get accountCreateSuccess => 'Account created';

  @override
  String get accountCreateError =>
      'Could not create account. Please try again.';

  @override
  String get budgetViewAccounts => 'Accounts';

  @override
  String get transactionEditTitle => 'Edit Transaction';

  @override
  String get transactionEditSuccess => 'Transaction updated';

  @override
  String get transactionEditError =>
      'Could not update transaction. Please try again.';

  @override
  String get budgetMonthJanuary => 'January';

  @override
  String get budgetMonthFebruary => 'February';

  @override
  String get budgetMonthMarch => 'March';

  @override
  String get budgetMonthApril => 'April';

  @override
  String get budgetMonthMay => 'May';

  @override
  String get budgetMonthJune => 'June';

  @override
  String get budgetMonthJuly => 'July';

  @override
  String get budgetMonthAugust => 'August';

  @override
  String get budgetMonthSeptember => 'September';

  @override
  String get budgetMonthOctober => 'October';

  @override
  String get budgetMonthNovember => 'November';

  @override
  String get budgetMonthDecember => 'December';

  @override
  String get budgetAllocationUpdated => 'Allocation updated';

  @override
  String get budgetAllocationError => 'Could not update allocation';

  @override
  String get transactionSearchHint => 'Search transactions...';

  @override
  String get transactionFilterAll => 'All';

  @override
  String get transactionFilterIncome => 'Income';

  @override
  String get transactionFilterExpense => 'Expense';

  @override
  String get transactionNoResults => 'No matching transactions';

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
  String get payeeListTitle => 'Payees';

  @override
  String get payeeLoadError => 'Could not load payees';

  @override
  String get payeeEmptyTitle => 'No Payees Yet';

  @override
  String get payeeEmptySubtitle => 'Add payees to track who you transact with';

  @override
  String get payeeAddButton => 'Add Payee';

  @override
  String get payeeNameLabel => 'Payee Name';

  @override
  String get payeeCreateSuccess => 'Payee created';

  @override
  String get payeeCreateError => 'Could not create payee. Please try again.';

  @override
  String get payeeEditTitle => 'Edit Payee';

  @override
  String get payeeEditSuccess => 'Payee updated';

  @override
  String get payeeEditError => 'Could not update payee. Please try again.';

  @override
  String get goalSetTitle => 'Set Goal';

  @override
  String get goalTypeLabel => 'Goal Type';

  @override
  String get goalTypeBalance => 'Balance';

  @override
  String get goalTypeByDate => 'By Date';

  @override
  String get goalTypeMonthly => 'Monthly';

  @override
  String get goalAmountLabel => 'Target Amount';

  @override
  String get goalDateLabel => 'Target Date';

  @override
  String get goalDateSelect => 'Select a date';

  @override
  String get goalSaved => 'Goal saved';

  @override
  String get goalRemoved => 'Goal removed';

  @override
  String get goalRemove => 'Remove Goal';

  @override
  String get goalError => 'Could not save goal. Please try again.';

  @override
  String get goalSetGoal => 'Set Goal';

  @override
  String get transferTitle => 'Transfer';

  @override
  String get transferFromAccount => 'From Account';

  @override
  String get transferToAccount => 'To Account';

  @override
  String get transferDate => 'Transfer Date';

  @override
  String get transferButton => 'Transfer';

  @override
  String get transferDefaultDescription => 'Account Transfer';

  @override
  String get transferSuccess => 'Transfer completed';

  @override
  String get transferError => 'Could not complete transfer. Please try again.';

  @override
  String get transferSameAccountError => 'Cannot transfer to the same account';

  @override
  String get transferNeedTwoAccounts =>
      'You need at least two accounts to make a transfer';

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsLoadError => 'Could not load report data';

  @override
  String get reportsIncome => 'Income';

  @override
  String get reportsExpenses => 'Expenses';

  @override
  String get reportsNetIncome => 'Net Income';

  @override
  String get reportsTransactions => 'Transactions';

  @override
  String get reportsSpendingByCategory => 'Spending by Category';

  @override
  String get reportsEmptyTitle => 'No Data Yet';

  @override
  String get reportsEmptySubtitle =>
      'Add transactions to see spending reports for this month';

  @override
  String get moveMoneyTitle => 'Move Money';

  @override
  String get moveMoneyFrom => 'From Envelope';

  @override
  String get moveMoneyTo => 'To Envelope';

  @override
  String get moveMoneyButton => 'Move';

  @override
  String get moveMoneySuccess => 'Money moved between envelopes';

  @override
  String get moveMoneyError => 'Could not move money. Please try again.';

  @override
  String get moveMoneySameError => 'Cannot move money to the same envelope';

  @override
  String get creditCardPaymentsTitle => 'Credit Card Payments';

  @override
  String get creditCardSpentThisMonth => 'Spent this month';

  @override
  String get accountDetailBalance => 'Balance';

  @override
  String get transactionUncleared => 'Uncleared';

  @override
  String get transactionCleared => 'Cleared';

  @override
  String get transactionReconciled => 'Reconciled';

  @override
  String get reconcileTitle => 'Reconcile Account';

  @override
  String get reconcileMessage =>
      'Mark all cleared transactions as reconciled? This locks them from further editing.';

  @override
  String get reconcileButton => 'Reconcile';

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
  String get reconcileError => 'Could not reconcile account. Please try again.';

  @override
  String get recurringListTitle => 'Recurring Transactions';

  @override
  String get recurringLoadError => 'Could not load recurring transactions';

  @override
  String get recurringEmptyTitle => 'No Recurring Transactions';

  @override
  String get recurringEmptySubtitle =>
      'Set up recurring transactions for bills, subscriptions, and regular income';

  @override
  String get recurringAddButton => 'Add Recurring';

  @override
  String get recurringAddTitle => 'Add Recurring Transaction';

  @override
  String get recurringEditTitle => 'Edit Recurring Transaction';

  @override
  String get recurringFrequencyLabel => 'Frequency';

  @override
  String get recurringFreqDaily => 'Daily';

  @override
  String get recurringFreqWeekly => 'Weekly';

  @override
  String get recurringFreqBiweekly => 'Biweekly';

  @override
  String get recurringFreqMonthly => 'Monthly';

  @override
  String get recurringFreqYearly => 'Yearly';

  @override
  String get recurringStartDate => 'Start Date';

  @override
  String get recurringNextDate => 'Next';

  @override
  String get recurringCreateSuccess => 'Recurring transaction created';

  @override
  String get recurringCreateError =>
      'Could not create recurring transaction. Please try again.';

  @override
  String get recurringEditSuccess => 'Recurring transaction updated';

  @override
  String get recurringEditError =>
      'Could not update recurring transaction. Please try again.';

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
  String get quickBudgetTitle => 'Quick Budget';

  @override
  String get quickBudgetLastMonth => 'Budgeted Last Month';

  @override
  String get quickBudgetSpentLastMonth => 'Spent Last Month';

  @override
  String get quickBudgetAverageBudgeted => 'Average Budgeted';

  @override
  String get quickBudgetAverageSpent => 'Average Spent';

  @override
  String get quickBudgetError => 'Could not load budget suggestions';

  @override
  String get splitTransactionTitle => 'Split Transaction';

  @override
  String get splitAddSplit => 'Add Split';

  @override
  String get splitRemoveSplit => 'Remove';

  @override
  String get splitEnvelopeLabel => 'Envelope';

  @override
  String get splitAmountLabel => 'Amount';

  @override
  String get splitMemoLabel => 'Memo (optional)';

  @override
  String get splitRemainingLabel => 'Remaining to assign';

  @override
  String get splitMismatchError => 'Split amounts must equal the total';

  @override
  String get splitMinimumError => 'At least two splits are required';

  @override
  String get splitSaveSuccess => 'Split transaction saved';

  @override
  String get splitSaveError =>
      'Could not save split transaction. Please try again.';

  @override
  String get splitLabel => 'Split';

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
  String get payeeNone => 'No Payee';

  @override
  String get payeeLabel => 'Payee';

  @override
  String get payeeAutoEnvelopeHint =>
      'Envelope auto-suggested from last transaction with this payee';

  @override
  String get accountRunningBalance => 'Running Balance';

  @override
  String budgetOverspentWarning(String amount) {
    return 'Overspent: $amount';
  }

  @override
  String get importTitle => 'Import Transactions';

  @override
  String get importInstructions =>
      'Paste CSV data with columns for date, description, and amount. Headers are auto-detected.';

  @override
  String get importCsvLabel => 'CSV Data';

  @override
  String get importCsvHint =>
      'Date,Description,Amount\n2026-01-15,Grocery Store,-45.50\n2026-01-16,Paycheck,2500.00';

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
  String get importImporting => 'Importing...';

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
  String get importError => 'Could not import transactions. Please try again.';

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
  String get recurringPostDue => 'Post Now';

  @override
  String get recurringPosting => 'Posting...';

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
  String get recurringPostError =>
      'Could not post scheduled transactions. Please try again.';

  @override
  String get autoAssignTitle => 'Auto-Assign';

  @override
  String get autoAssignButton => 'Auto-Assign';

  @override
  String get autoAssignAssigning => 'Assigning...';

  @override
  String get autoAssignDistributing => 'Distributing to underfunded envelopes';

  @override
  String get autoAssignNothingToAssign =>
      'All envelopes with goals are fully funded!';

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
  String get autoAssignError => 'Could not auto-assign. Please try again.';

  @override
  String get envelopeActivityTitle => 'Activity';

  @override
  String get envelopeNoActivity => 'No transactions this month';

  @override
  String get netWorthTitle => 'Net Worth';

  @override
  String get netWorthAssets => 'Assets';

  @override
  String get netWorthLiabilities => 'Liabilities';

  @override
  String get netWorthLoadError => 'Could not load net worth data';

  @override
  String get netWorthEmptyTitle => 'No Accounts Yet';

  @override
  String get netWorthEmptySubtitle =>
      'Add accounts to see your net worth breakdown';

  @override
  String get spendingTrendsTitle => 'Spending Trends';

  @override
  String get spendingTrendsLoadError => 'Could not load spending trends';

  @override
  String get spendingTrendsEmptyTitle => 'No Spending Data';

  @override
  String get spendingTrendsEmptySubtitle =>
      'Add transactions to see spending trends over time';

  @override
  String get spendingTrendsAvgIncome => 'Avg. Income';

  @override
  String get spendingTrendsAvgExpenses => 'Avg. Expenses';

  @override
  String get spendingTrendsMonthly => 'Monthly Comparison';

  @override
  String get spendingTrendsBreakdown => 'Monthly Breakdown';

  @override
  String get budgetEditCategoryTitle => 'Rename Category';

  @override
  String get budgetEditCategorySuccess => 'Category renamed';

  @override
  String get budgetEditCategoryError =>
      'Could not rename category. Please try again.';

  @override
  String get budgetReorderCategories => 'Reorder Categories';

  @override
  String get budgetReorderDone => 'Done';

  @override
  String get budgetReorderHint => 'Drag to reorder categories';

  @override
  String get budgetReorderSuccess => 'Categories reordered';

  @override
  String get budgetReorderError => 'Could not reorder categories';
}
