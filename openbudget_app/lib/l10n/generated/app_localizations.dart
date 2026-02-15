import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OpenBudget'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to OpenBudget'**
  String get loginTitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @loginLoading.
  ///
  /// In en, this message translates to:
  /// **'Signing In...'**
  String get loginLoading;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get loginCreateAccount;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerStepEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to get started'**
  String get registerStepEmail;

  /// No description provided for @registerStepCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to your email'**
  String get registerStepCode;

  /// No description provided for @registerStepPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a password for your account'**
  String get registerStepPassword;

  /// No description provided for @registerSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get registerSendCode;

  /// No description provided for @registerCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get registerCodeLabel;

  /// No description provided for @registerVerifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get registerVerifyCode;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get registerConfirmPassword;

  /// No description provided for @registerCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerCreateAccount;

  /// No description provided for @registerSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get registerSubmitting;

  /// No description provided for @registerAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get registerAlreadyHaveAccount;

  /// No description provided for @registerEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get registerEmailRequired;

  /// No description provided for @registerEmailError.
  ///
  /// In en, this message translates to:
  /// **'Could not start registration. Please try again.'**
  String get registerEmailError;

  /// No description provided for @registerCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code'**
  String get registerCodeRequired;

  /// No description provided for @registerCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code. Please try again.'**
  String get registerCodeError;

  /// No description provided for @registerPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get registerPasswordRequired;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registerPasswordMismatch;

  /// No description provided for @homeLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get homeLogout;

  /// No description provided for @homeNoBudgets.
  ///
  /// In en, this message translates to:
  /// **'No Budgets Yet'**
  String get homeNoBudgets;

  /// No description provided for @homeCreateBudget.
  ///
  /// In en, this message translates to:
  /// **'Create Your First Budget'**
  String get homeCreateBudget;

  /// No description provided for @homeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load budgets'**
  String get homeLoadError;

  /// No description provided for @homeRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get homeRetry;

  /// No description provided for @homeBudgetCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 budget} other{{count} budgets}}'**
  String homeBudgetCount(int count);

  /// No description provided for @createBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudgetTitle;

  /// No description provided for @createBudgetNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget Name'**
  String get createBudgetNameLabel;

  /// No description provided for @createBudgetCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Primary Currency'**
  String get createBudgetCurrencyLabel;

  /// No description provided for @createBudgetButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createBudgetButton;

  /// No description provided for @budgetEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Categories Yet'**
  String get budgetEmptyTitle;

  /// No description provided for @budgetEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first envelope category to start budgeting'**
  String get budgetEmptySubtitle;

  /// No description provided for @budgetReadyToAssign.
  ///
  /// In en, this message translates to:
  /// **'Ready to Assign'**
  String get budgetReadyToAssign;

  /// No description provided for @budgetColumnBudgeted.
  ///
  /// In en, this message translates to:
  /// **'Budgeted'**
  String get budgetColumnBudgeted;

  /// No description provided for @budgetColumnSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get budgetColumnSpent;

  /// No description provided for @budgetColumnAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get budgetColumnAvailable;

  /// No description provided for @budgetAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get budgetAddCategory;

  /// No description provided for @budgetAddEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Add Envelope'**
  String get budgetAddEnvelope;

  /// No description provided for @budgetAddIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get budgetAddIncome;

  /// No description provided for @budgetAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get budgetAddExpense;

  /// No description provided for @budgetCategoryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get budgetCategoryTotal;

  /// No description provided for @budgetCategoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get budgetCategoryNameLabel;

  /// No description provided for @budgetEnvelopeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Envelope Name'**
  String get budgetEnvelopeNameLabel;

  /// No description provided for @budgetEnvelopeAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Budgeted Amount'**
  String get budgetEnvelopeAmountLabel;

  /// No description provided for @budgetLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load budget details'**
  String get budgetLoadError;

  /// No description provided for @dialogSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dialogSave;

  /// No description provided for @dialogSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get dialogSaving;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @transactionAddIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get transactionAddIncome;

  /// No description provided for @transactionAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get transactionAddExpense;

  /// No description provided for @transactionDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get transactionDescriptionLabel;

  /// No description provided for @transactionAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transactionAmountLabel;

  /// No description provided for @transactionSave.
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get transactionSave;

  /// No description provided for @transactionSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get transactionSubmitting;

  /// No description provided for @transactionUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get transactionUnassigned;

  /// No description provided for @transactionListTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionListTitle;

  /// No description provided for @transactionLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load transactions'**
  String get transactionLoadError;

  /// No description provided for @transactionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get transactionEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
