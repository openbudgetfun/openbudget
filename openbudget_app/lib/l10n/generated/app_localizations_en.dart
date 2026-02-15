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
}
