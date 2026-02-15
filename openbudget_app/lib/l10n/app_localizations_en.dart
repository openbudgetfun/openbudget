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
  String get loginCreateAccount => 'Create Account';

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
