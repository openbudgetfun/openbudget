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
}
