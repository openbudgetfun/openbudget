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

  /// No description provided for @createBudgetCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get createBudgetCreating;

  /// No description provided for @createBudgetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Budget created successfully'**
  String get createBudgetSuccess;

  /// No description provided for @createBudgetError.
  ///
  /// In en, this message translates to:
  /// **'Could not create budget. Please try again.'**
  String get createBudgetError;

  /// No description provided for @budgetCategoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category created'**
  String get budgetCategoryCreated;

  /// No description provided for @budgetEnvelopeCreated.
  ///
  /// In en, this message translates to:
  /// **'Envelope created'**
  String get budgetEnvelopeCreated;

  /// No description provided for @budgetCategoryCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create category'**
  String get budgetCategoryCreateError;

  /// No description provided for @budgetEnvelopeCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create envelope'**
  String get budgetEnvelopeCreateError;

  /// No description provided for @transactionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved'**
  String get transactionSuccess;

  /// No description provided for @transactionError.
  ///
  /// In en, this message translates to:
  /// **'Could not save transaction. Please try again.'**
  String get transactionError;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get deleteConfirmMessage;

  /// No description provided for @deleteConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteConfirmButton;

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deleteSuccess;

  /// No description provided for @deleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete. Please try again.'**
  String get deleteError;

  /// No description provided for @editEnvelopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Envelope'**
  String get editEnvelopeTitle;

  /// No description provided for @editEnvelopeSaved.
  ///
  /// In en, this message translates to:
  /// **'Envelope updated'**
  String get editEnvelopeSaved;

  /// No description provided for @editEnvelopeError.
  ///
  /// In en, this message translates to:
  /// **'Could not update envelope'**
  String get editEnvelopeError;

  /// No description provided for @accountListTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountListTitle;

  /// No description provided for @accountLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load accounts'**
  String get accountLoadError;

  /// No description provided for @accountEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Accounts Yet'**
  String get accountEmptyTitle;

  /// No description provided for @accountEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first account to track balances'**
  String get accountEmptySubtitle;

  /// No description provided for @accountAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get accountAddTitle;

  /// No description provided for @accountAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get accountAddButton;

  /// No description provided for @accountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountNameLabel;

  /// No description provided for @accountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountTypeLabel;

  /// No description provided for @accountBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting Balance'**
  String get accountBalanceLabel;

  /// No description provided for @accountOnBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'On Budget'**
  String get accountOnBudgetLabel;

  /// No description provided for @accountOnBudgetHint.
  ///
  /// In en, this message translates to:
  /// **'Include in budget calculations'**
  String get accountOnBudgetHint;

  /// No description provided for @accountTypeChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get accountTypeChecking;

  /// No description provided for @accountTypeSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get accountTypeSavings;

  /// No description provided for @accountTypeCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get accountTypeCreditCard;

  /// No description provided for @accountTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCash;

  /// No description provided for @accountTypeInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get accountTypeInvestment;

  /// No description provided for @accountTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get accountTypeOther;

  /// No description provided for @accountOnBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget Accounts'**
  String get accountOnBudget;

  /// No description provided for @accountOffBudget.
  ///
  /// In en, this message translates to:
  /// **'Tracking Accounts'**
  String get accountOffBudget;

  /// No description provided for @accountClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed Accounts'**
  String get accountClosed;

  /// No description provided for @accountCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get accountCreateSuccess;

  /// No description provided for @accountCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create account. Please try again.'**
  String get accountCreateError;

  /// No description provided for @budgetViewAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get budgetViewAccounts;

  /// No description provided for @transactionEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get transactionEditTitle;

  /// No description provided for @transactionEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated'**
  String get transactionEditSuccess;

  /// No description provided for @transactionEditError.
  ///
  /// In en, this message translates to:
  /// **'Could not update transaction. Please try again.'**
  String get transactionEditError;

  /// No description provided for @budgetMonthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get budgetMonthJanuary;

  /// No description provided for @budgetMonthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get budgetMonthFebruary;

  /// No description provided for @budgetMonthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get budgetMonthMarch;

  /// No description provided for @budgetMonthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get budgetMonthApril;

  /// No description provided for @budgetMonthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get budgetMonthMay;

  /// No description provided for @budgetMonthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get budgetMonthJune;

  /// No description provided for @budgetMonthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get budgetMonthJuly;

  /// No description provided for @budgetMonthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get budgetMonthAugust;

  /// No description provided for @budgetMonthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get budgetMonthSeptember;

  /// No description provided for @budgetMonthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get budgetMonthOctober;

  /// No description provided for @budgetMonthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get budgetMonthNovember;

  /// No description provided for @budgetMonthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get budgetMonthDecember;

  /// No description provided for @budgetAllocationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Allocation updated'**
  String get budgetAllocationUpdated;

  /// No description provided for @budgetAllocationError.
  ///
  /// In en, this message translates to:
  /// **'Could not update allocation'**
  String get budgetAllocationError;

  /// No description provided for @transactionSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get transactionSearchHint;

  /// No description provided for @transactionFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get transactionFilterAll;

  /// No description provided for @transactionFilterIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transactionFilterIncome;

  /// No description provided for @transactionFilterExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get transactionFilterExpense;

  /// No description provided for @transactionNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching transactions'**
  String get transactionNoResults;

  /// No description provided for @transactionResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String transactionResultCount(int count);

  /// No description provided for @payeeListTitle.
  ///
  /// In en, this message translates to:
  /// **'Payees'**
  String get payeeListTitle;

  /// No description provided for @payeeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load payees'**
  String get payeeLoadError;

  /// No description provided for @payeeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Payees Yet'**
  String get payeeEmptyTitle;

  /// No description provided for @payeeEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add payees to track who you transact with'**
  String get payeeEmptySubtitle;

  /// No description provided for @payeeAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Payee'**
  String get payeeAddButton;

  /// No description provided for @payeeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Payee Name'**
  String get payeeNameLabel;

  /// No description provided for @payeeCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payee created'**
  String get payeeCreateSuccess;

  /// No description provided for @payeeCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create payee. Please try again.'**
  String get payeeCreateError;

  /// No description provided for @payeeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Payee'**
  String get payeeEditTitle;

  /// No description provided for @payeeEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payee updated'**
  String get payeeEditSuccess;

  /// No description provided for @payeeEditError.
  ///
  /// In en, this message translates to:
  /// **'Could not update payee. Please try again.'**
  String get payeeEditError;

  /// No description provided for @goalSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Goal'**
  String get goalSetTitle;

  /// No description provided for @goalTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal Type'**
  String get goalTypeLabel;

  /// No description provided for @goalTypeBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get goalTypeBalance;

  /// No description provided for @goalTypeByDate.
  ///
  /// In en, this message translates to:
  /// **'By Date'**
  String get goalTypeByDate;

  /// No description provided for @goalTypeMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get goalTypeMonthly;

  /// No description provided for @goalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Amount'**
  String get goalAmountLabel;

  /// No description provided for @goalDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Date'**
  String get goalDateLabel;

  /// No description provided for @goalDateSelect.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get goalDateSelect;

  /// No description provided for @goalSaved.
  ///
  /// In en, this message translates to:
  /// **'Goal saved'**
  String get goalSaved;

  /// No description provided for @goalRemoved.
  ///
  /// In en, this message translates to:
  /// **'Goal removed'**
  String get goalRemoved;

  /// No description provided for @goalRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove Goal'**
  String get goalRemove;

  /// No description provided for @goalError.
  ///
  /// In en, this message translates to:
  /// **'Could not save goal. Please try again.'**
  String get goalError;

  /// No description provided for @goalSetGoal.
  ///
  /// In en, this message translates to:
  /// **'Set Goal'**
  String get goalSetGoal;

  /// No description provided for @transferTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferTitle;

  /// No description provided for @transferFromAccount.
  ///
  /// In en, this message translates to:
  /// **'From Account'**
  String get transferFromAccount;

  /// No description provided for @transferToAccount.
  ///
  /// In en, this message translates to:
  /// **'To Account'**
  String get transferToAccount;

  /// No description provided for @transferDate.
  ///
  /// In en, this message translates to:
  /// **'Transfer Date'**
  String get transferDate;

  /// No description provided for @transferButton.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferButton;

  /// No description provided for @transferDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'Account Transfer'**
  String get transferDefaultDescription;

  /// No description provided for @transferSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transfer completed'**
  String get transferSuccess;

  /// No description provided for @transferError.
  ///
  /// In en, this message translates to:
  /// **'Could not complete transfer. Please try again.'**
  String get transferError;

  /// No description provided for @transferSameAccountError.
  ///
  /// In en, this message translates to:
  /// **'Cannot transfer to the same account'**
  String get transferSameAccountError;

  /// No description provided for @transferNeedTwoAccounts.
  ///
  /// In en, this message translates to:
  /// **'You need at least two accounts to make a transfer'**
  String get transferNeedTwoAccounts;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @reportsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load report data'**
  String get reportsLoadError;

  /// No description provided for @reportsIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get reportsIncome;

  /// No description provided for @reportsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get reportsExpenses;

  /// No description provided for @reportsNetIncome.
  ///
  /// In en, this message translates to:
  /// **'Net Income'**
  String get reportsNetIncome;

  /// No description provided for @reportsTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get reportsTransactions;

  /// No description provided for @reportsSpendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get reportsSpendingByCategory;

  /// No description provided for @reportsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Data Yet'**
  String get reportsEmptyTitle;

  /// No description provided for @reportsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add transactions to see spending reports for this month'**
  String get reportsEmptySubtitle;

  /// No description provided for @moveMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Move Money'**
  String get moveMoneyTitle;

  /// No description provided for @moveMoneyFrom.
  ///
  /// In en, this message translates to:
  /// **'From Envelope'**
  String get moveMoneyFrom;

  /// No description provided for @moveMoneyTo.
  ///
  /// In en, this message translates to:
  /// **'To Envelope'**
  String get moveMoneyTo;

  /// No description provided for @moveMoneyButton.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get moveMoneyButton;

  /// No description provided for @moveMoneySuccess.
  ///
  /// In en, this message translates to:
  /// **'Money moved between envelopes'**
  String get moveMoneySuccess;

  /// No description provided for @moveMoneyError.
  ///
  /// In en, this message translates to:
  /// **'Could not move money. Please try again.'**
  String get moveMoneyError;

  /// No description provided for @moveMoneySameError.
  ///
  /// In en, this message translates to:
  /// **'Cannot move money to the same envelope'**
  String get moveMoneySameError;

  /// No description provided for @creditCardPaymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credit Card Payments'**
  String get creditCardPaymentsTitle;

  /// No description provided for @creditCardSpentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Spent this month'**
  String get creditCardSpentThisMonth;

  /// No description provided for @accountDetailBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get accountDetailBalance;

  /// No description provided for @transactionUncleared.
  ///
  /// In en, this message translates to:
  /// **'Uncleared'**
  String get transactionUncleared;

  /// No description provided for @transactionCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get transactionCleared;

  /// No description provided for @transactionReconciled.
  ///
  /// In en, this message translates to:
  /// **'Reconciled'**
  String get transactionReconciled;

  /// No description provided for @reconcileTitle.
  ///
  /// In en, this message translates to:
  /// **'Reconcile Account'**
  String get reconcileTitle;

  /// No description provided for @reconcileMessage.
  ///
  /// In en, this message translates to:
  /// **'Mark all cleared transactions as reconciled? This locks them from further editing.'**
  String get reconcileMessage;

  /// No description provided for @reconcileButton.
  ///
  /// In en, this message translates to:
  /// **'Reconcile'**
  String get reconcileButton;

  /// No description provided for @reconcileSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No transactions to reconcile} =1{1 transaction reconciled} other{{count} transactions reconciled}}'**
  String reconcileSuccess(int count);

  /// No description provided for @reconcileError.
  ///
  /// In en, this message translates to:
  /// **'Could not reconcile account. Please try again.'**
  String get reconcileError;

  /// No description provided for @recurringListTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring Transactions'**
  String get recurringListTitle;

  /// No description provided for @recurringLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load recurring transactions'**
  String get recurringLoadError;

  /// No description provided for @recurringEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Recurring Transactions'**
  String get recurringEmptyTitle;

  /// No description provided for @recurringEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up recurring transactions for bills, subscriptions, and regular income'**
  String get recurringEmptySubtitle;

  /// No description provided for @recurringAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Recurring'**
  String get recurringAddButton;

  /// No description provided for @recurringAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Recurring Transaction'**
  String get recurringAddTitle;

  /// No description provided for @recurringEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Recurring Transaction'**
  String get recurringEditTitle;

  /// No description provided for @recurringFrequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get recurringFrequencyLabel;

  /// No description provided for @recurringFreqDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recurringFreqDaily;

  /// No description provided for @recurringFreqWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurringFreqWeekly;

  /// No description provided for @recurringFreqBiweekly.
  ///
  /// In en, this message translates to:
  /// **'Biweekly'**
  String get recurringFreqBiweekly;

  /// No description provided for @recurringFreqMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recurringFreqMonthly;

  /// No description provided for @recurringFreqYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get recurringFreqYearly;

  /// No description provided for @recurringStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get recurringStartDate;

  /// No description provided for @recurringNextDate.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get recurringNextDate;

  /// No description provided for @recurringCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recurring transaction created'**
  String get recurringCreateSuccess;

  /// No description provided for @recurringCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create recurring transaction. Please try again.'**
  String get recurringCreateError;

  /// No description provided for @recurringEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recurring transaction updated'**
  String get recurringEditSuccess;

  /// No description provided for @recurringEditError.
  ///
  /// In en, this message translates to:
  /// **'Could not update recurring transaction. Please try again.'**
  String get recurringEditError;

  /// No description provided for @ageOfMoneyLabel.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Age of Money: 1 day} other{Age of Money: {days} days}}'**
  String ageOfMoneyLabel(int days);

  /// No description provided for @quickBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Budget'**
  String get quickBudgetTitle;

  /// No description provided for @quickBudgetLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Budgeted Last Month'**
  String get quickBudgetLastMonth;

  /// No description provided for @quickBudgetSpentLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Spent Last Month'**
  String get quickBudgetSpentLastMonth;

  /// No description provided for @quickBudgetAverageBudgeted.
  ///
  /// In en, this message translates to:
  /// **'Average Budgeted'**
  String get quickBudgetAverageBudgeted;

  /// No description provided for @quickBudgetAverageSpent.
  ///
  /// In en, this message translates to:
  /// **'Average Spent'**
  String get quickBudgetAverageSpent;

  /// No description provided for @quickBudgetError.
  ///
  /// In en, this message translates to:
  /// **'Could not load budget suggestions'**
  String get quickBudgetError;

  /// No description provided for @splitTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Split Transaction'**
  String get splitTransactionTitle;

  /// No description provided for @splitAddSplit.
  ///
  /// In en, this message translates to:
  /// **'Add Split'**
  String get splitAddSplit;

  /// No description provided for @splitRemoveSplit.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get splitRemoveSplit;

  /// No description provided for @splitEnvelopeLabel.
  ///
  /// In en, this message translates to:
  /// **'Envelope'**
  String get splitEnvelopeLabel;

  /// No description provided for @splitAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get splitAmountLabel;

  /// No description provided for @splitMemoLabel.
  ///
  /// In en, this message translates to:
  /// **'Memo (optional)'**
  String get splitMemoLabel;

  /// No description provided for @splitRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining to assign'**
  String get splitRemainingLabel;

  /// No description provided for @splitMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Split amounts must equal the total'**
  String get splitMismatchError;

  /// No description provided for @splitMinimumError.
  ///
  /// In en, this message translates to:
  /// **'At least two splits are required'**
  String get splitMinimumError;

  /// No description provided for @splitSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Split transaction saved'**
  String get splitSaveSuccess;

  /// No description provided for @splitSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save split transaction. Please try again.'**
  String get splitSaveError;

  /// No description provided for @splitLabel.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get splitLabel;

  /// No description provided for @splitCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 split} other{{count} splits}}'**
  String splitCount(int count);

  /// No description provided for @payeeNone.
  ///
  /// In en, this message translates to:
  /// **'No Payee'**
  String get payeeNone;

  /// No description provided for @payeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Payee'**
  String get payeeLabel;

  /// No description provided for @payeeAutoEnvelopeHint.
  ///
  /// In en, this message translates to:
  /// **'Envelope auto-suggested from last transaction with this payee'**
  String get payeeAutoEnvelopeHint;

  /// No description provided for @accountRunningBalance.
  ///
  /// In en, this message translates to:
  /// **'Running Balance'**
  String get accountRunningBalance;

  /// No description provided for @budgetOverspentWarning.
  ///
  /// In en, this message translates to:
  /// **'Overspent: {amount}'**
  String budgetOverspentWarning(String amount);

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Transactions'**
  String get importTitle;

  /// No description provided for @importInstructions.
  ///
  /// In en, this message translates to:
  /// **'Paste CSV data with columns for date, description, and amount. Headers are auto-detected.'**
  String get importInstructions;

  /// No description provided for @importCsvLabel.
  ///
  /// In en, this message translates to:
  /// **'CSV Data'**
  String get importCsvLabel;

  /// No description provided for @importCsvHint.
  ///
  /// In en, this message translates to:
  /// **'Date,Description,Amount\n2026-01-15,Grocery Store,-45.50\n2026-01-16,Paycheck,2500.00'**
  String get importCsvHint;

  /// No description provided for @importPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get importPreview;

  /// No description provided for @importPreviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction to import} other{{count} transactions to import}}'**
  String importPreviewCount(int count);

  /// No description provided for @importButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import 1 Transaction} other{Import {count} Transactions}}'**
  String importButton(int count);

  /// No description provided for @importImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importImporting;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction imported} other{{count} transactions imported}}'**
  String importSuccess(int count);

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Could not import transactions. Please try again.'**
  String get importError;

  /// No description provided for @importMoreRows.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{...and 1 more row} other{...and {count} more rows}}'**
  String importMoreRows(int count);

  /// No description provided for @recurringDueBanner.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 scheduled transaction is due} other{{count} scheduled transactions are due}}'**
  String recurringDueBanner(int count);

  /// No description provided for @recurringPostDue.
  ///
  /// In en, this message translates to:
  /// **'Post Now'**
  String get recurringPostDue;

  /// No description provided for @recurringPosting.
  ///
  /// In en, this message translates to:
  /// **'Posting...'**
  String get recurringPosting;

  /// No description provided for @recurringPostSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction posted} other{{count} transactions posted}}'**
  String recurringPostSuccess(int count);

  /// No description provided for @recurringPostError.
  ///
  /// In en, this message translates to:
  /// **'Could not post scheduled transactions. Please try again.'**
  String get recurringPostError;

  /// No description provided for @autoAssignTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-Assign'**
  String get autoAssignTitle;

  /// No description provided for @autoAssignButton.
  ///
  /// In en, this message translates to:
  /// **'Auto-Assign'**
  String get autoAssignButton;

  /// No description provided for @autoAssignAssigning.
  ///
  /// In en, this message translates to:
  /// **'Assigning...'**
  String get autoAssignAssigning;

  /// No description provided for @autoAssignDistributing.
  ///
  /// In en, this message translates to:
  /// **'Distributing to underfunded envelopes'**
  String get autoAssignDistributing;

  /// No description provided for @autoAssignNothingToAssign.
  ///
  /// In en, this message translates to:
  /// **'All envelopes with goals are fully funded!'**
  String get autoAssignNothingToAssign;

  /// No description provided for @autoAssignEnvelopeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 envelope} other{{count} envelopes}}'**
  String autoAssignEnvelopeCount(int count);

  /// No description provided for @autoAssignSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Auto-assigned to 1 envelope} other{Auto-assigned to {count} envelopes}}'**
  String autoAssignSuccess(int count);

  /// No description provided for @autoAssignError.
  ///
  /// In en, this message translates to:
  /// **'Could not auto-assign. Please try again.'**
  String get autoAssignError;

  /// No description provided for @envelopeActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get envelopeActivityTitle;

  /// No description provided for @envelopeNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No transactions this month'**
  String get envelopeNoActivity;

  /// No description provided for @netWorthTitle.
  ///
  /// In en, this message translates to:
  /// **'Net Worth'**
  String get netWorthTitle;

  /// No description provided for @netWorthAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get netWorthAssets;

  /// No description provided for @netWorthLiabilities.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get netWorthLiabilities;

  /// No description provided for @netWorthLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load net worth data'**
  String get netWorthLoadError;

  /// No description provided for @netWorthEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Accounts Yet'**
  String get netWorthEmptyTitle;

  /// No description provided for @netWorthEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add accounts to see your net worth breakdown'**
  String get netWorthEmptySubtitle;

  /// No description provided for @spendingTrendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending Trends'**
  String get spendingTrendsTitle;

  /// No description provided for @spendingTrendsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load spending trends'**
  String get spendingTrendsLoadError;

  /// No description provided for @spendingTrendsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Spending Data'**
  String get spendingTrendsEmptyTitle;

  /// No description provided for @spendingTrendsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add transactions to see spending trends over time'**
  String get spendingTrendsEmptySubtitle;

  /// No description provided for @spendingTrendsAvgIncome.
  ///
  /// In en, this message translates to:
  /// **'Avg. Income'**
  String get spendingTrendsAvgIncome;

  /// No description provided for @spendingTrendsAvgExpenses.
  ///
  /// In en, this message translates to:
  /// **'Avg. Expenses'**
  String get spendingTrendsAvgExpenses;

  /// No description provided for @spendingTrendsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly Comparison'**
  String get spendingTrendsMonthly;

  /// No description provided for @spendingTrendsBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Monthly Breakdown'**
  String get spendingTrendsBreakdown;

  /// No description provided for @budgetEditCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Category'**
  String get budgetEditCategoryTitle;

  /// No description provided for @budgetEditCategorySuccess.
  ///
  /// In en, this message translates to:
  /// **'Category renamed'**
  String get budgetEditCategorySuccess;

  /// No description provided for @budgetEditCategoryError.
  ///
  /// In en, this message translates to:
  /// **'Could not rename category. Please try again.'**
  String get budgetEditCategoryError;

  /// No description provided for @budgetReorderCategories.
  ///
  /// In en, this message translates to:
  /// **'Reorder Categories'**
  String get budgetReorderCategories;

  /// No description provided for @budgetReorderDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get budgetReorderDone;

  /// No description provided for @budgetReorderHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder categories'**
  String get budgetReorderHint;

  /// No description provided for @budgetReorderSuccess.
  ///
  /// In en, this message translates to:
  /// **'Categories reordered'**
  String get budgetReorderSuccess;

  /// No description provided for @budgetReorderError.
  ///
  /// In en, this message translates to:
  /// **'Could not reorder categories'**
  String get budgetReorderError;

  /// No description provided for @transactionMemoLabel.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get transactionMemoLabel;

  /// No description provided for @transactionMemoHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get transactionMemoHint;

  /// No description provided for @accountEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get accountEditTitle;

  /// No description provided for @accountEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account updated'**
  String get accountEditSuccess;

  /// No description provided for @accountEditError.
  ///
  /// In en, this message translates to:
  /// **'Could not update account. Please try again.'**
  String get accountEditError;

  /// No description provided for @accountCloseButton.
  ///
  /// In en, this message translates to:
  /// **'Close Account'**
  String get accountCloseButton;

  /// No description provided for @accountCloseConfirm.
  ///
  /// In en, this message translates to:
  /// **'Close this account? It will be moved to Closed Accounts.'**
  String get accountCloseConfirm;

  /// No description provided for @accountCloseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account closed'**
  String get accountCloseSuccess;

  /// No description provided for @accountReopenButton.
  ///
  /// In en, this message translates to:
  /// **'Reopen Account'**
  String get accountReopenButton;

  /// No description provided for @accountReopenSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account reopened'**
  String get accountReopenSuccess;

  /// No description provided for @budgetDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get budgetDeleteTitle;

  /// No description provided for @budgetDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This will permanently remove the budget and all its data.'**
  String budgetDeleteConfirm(String name);

  /// No description provided for @budgetDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get budgetDeleteButton;

  /// No description provided for @budgetDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted'**
  String get budgetDeleteSuccess;

  /// No description provided for @budgetDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete budget. Please try again.'**
  String get budgetDeleteError;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load settings'**
  String get settingsLoadError;

  /// No description provided for @settingsBudgetSection.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get settingsBudgetSection;

  /// No description provided for @settingsBudgetName.
  ///
  /// In en, this message translates to:
  /// **'Budget Name'**
  String get settingsBudgetName;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsNavigationSection.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get settingsNavigationSection;

  /// No description provided for @settingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// No description provided for @settingsRenameBudget.
  ///
  /// In en, this message translates to:
  /// **'Rename Budget'**
  String get settingsRenameBudget;

  /// No description provided for @settingsRenameSuccess.
  ///
  /// In en, this message translates to:
  /// **'Budget renamed'**
  String get settingsRenameSuccess;

  /// No description provided for @settingsRenameError.
  ///
  /// In en, this message translates to:
  /// **'Could not rename budget. Please try again.'**
  String get settingsRenameError;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'OpenBudget v1.0.0'**
  String get settingsVersion;

  /// No description provided for @homeBudgetAccounts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account} other{{count} accounts}}'**
  String homeBudgetAccounts(int count);

  /// No description provided for @homeBudgetTotalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get homeBudgetTotalBalance;

  /// No description provided for @payeeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search payees...'**
  String get payeeSearchHint;

  /// No description provided for @payeeSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching payees'**
  String get payeeSearchNoResults;

  /// No description provided for @payeeSearchResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 payee} other{{count} payees}}'**
  String payeeSearchResultCount(int count);

  /// No description provided for @transactionExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Copy as CSV'**
  String get transactionExportCsv;

  /// No description provided for @transactionExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction copied to clipboard} other{{count} transactions copied to clipboard}}'**
  String transactionExportSuccess(int count);
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
