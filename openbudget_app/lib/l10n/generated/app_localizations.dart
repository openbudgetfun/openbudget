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

  /// No description provided for @accountAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get accountAddButton;

  /// No description provided for @accountAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get accountAddTitle;

  /// No description provided for @accountBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting Balance'**
  String get accountBalanceLabel;

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

  /// No description provided for @accountClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed Accounts'**
  String get accountClosed;

  /// No description provided for @accountCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create account. Please try again.'**
  String get accountCreateError;

  /// No description provided for @accountCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created'**
  String get accountCreateSuccess;

  /// No description provided for @accountDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get accountDeleteButton;

  /// No description provided for @accountDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete this account? This cannot be undone and all associated transactions will be lost.'**
  String get accountDeleteConfirm;

  /// No description provided for @accountDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete account. Please try again.'**
  String get accountDeleteError;

  /// No description provided for @accountDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get accountDeleteSuccess;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get accountDeleteTitle;

  /// No description provided for @accountBalanceCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get accountBalanceCleared;

  /// No description provided for @accountBalanceUncleared.
  ///
  /// In en, this message translates to:
  /// **'Uncleared'**
  String get accountBalanceUncleared;

  /// No description provided for @accountDetailBalance.
  ///
  /// In en, this message translates to:
  /// **'Working Balance'**
  String get accountDetailBalance;

  /// No description provided for @accountDetailSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get accountDetailSearchHint;

  /// No description provided for @accountFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get accountFilterAll;

  /// No description provided for @accountFilterUncleared.
  ///
  /// In en, this message translates to:
  /// **'Uncleared'**
  String get accountFilterUncleared;

  /// No description provided for @accountFilterCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get accountFilterCleared;

  /// No description provided for @accountFilterReconciled.
  ///
  /// In en, this message translates to:
  /// **'Reconciled'**
  String get accountFilterReconciled;

  /// No description provided for @accountEditError.
  ///
  /// In en, this message translates to:
  /// **'Could not update account. Please try again.'**
  String get accountEditError;

  /// No description provided for @accountEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account updated'**
  String get accountEditSuccess;

  /// No description provided for @accountEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get accountEditTitle;

  /// No description provided for @accountEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first account to track balances'**
  String get accountEmptySubtitle;

  /// No description provided for @accountEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Accounts Yet'**
  String get accountEmptyTitle;

  /// No description provided for @accountListTitle.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accountListTitle;

  /// No description provided for @accountListNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get accountListNotificationsTitle;

  /// No description provided for @accountListNotificationsMessage.
  ///
  /// In en, this message translates to:
  /// **'OpenBudget will notify you when you have new transactions or overspending.'**
  String get accountListNotificationsMessage;

  /// No description provided for @accountLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load accounts'**
  String get accountLoadError;

  /// No description provided for @accountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Name'**
  String get accountNameLabel;

  /// No description provided for @accountOffBudget.
  ///
  /// In en, this message translates to:
  /// **'Tracking Accounts'**
  String get accountOffBudget;

  /// No description provided for @accountOnBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget Accounts'**
  String get accountOnBudget;

  /// No description provided for @accountOnBudgetHint.
  ///
  /// In en, this message translates to:
  /// **'Include in budget calculations'**
  String get accountOnBudgetHint;

  /// No description provided for @accountOnBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'On Budget'**
  String get accountOnBudgetLabel;

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

  /// No description provided for @accountRunningBalance.
  ///
  /// In en, this message translates to:
  /// **'Running Balance'**
  String get accountRunningBalance;

  /// No description provided for @accountTypeCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCash;

  /// No description provided for @accountTypeChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking'**
  String get accountTypeChecking;

  /// No description provided for @accountTypeCreditCard.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get accountTypeCreditCard;

  /// No description provided for @accountTypeCryptoWallet.
  ///
  /// In en, this message translates to:
  /// **'Solana Wallet'**
  String get accountTypeCryptoWallet;

  /// No description provided for @accountTypeInvestment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get accountTypeInvestment;

  /// No description provided for @accountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountTypeLabel;

  /// No description provided for @accountTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get accountTypeOther;

  /// No description provided for @accountTypeSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get accountTypeSavings;

  /// No description provided for @accountNetWorth.
  ///
  /// In en, this message translates to:
  /// **'Net Worth'**
  String get accountNetWorth;

  /// No description provided for @accountTotalAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get accountTotalAssets;

  /// No description provided for @accountTotalLiabilities.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get accountTotalLiabilities;

  /// No description provided for @ageOfMoneyLabel.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Age of Money: 1 day} other{Age of Money: {days} days}}'**
  String ageOfMoneyLabel(int days);

  /// No description provided for @amountInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount with at most {decimals} decimal places'**
  String amountInvalidFormat(int decimals);

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'OpenBudget'**
  String get appTitle;

  /// No description provided for @autoAssignAssigning.
  ///
  /// In en, this message translates to:
  /// **'Assigning...'**
  String get autoAssignAssigning;

  /// No description provided for @autoAssignButton.
  ///
  /// In en, this message translates to:
  /// **'Auto-Assign'**
  String get autoAssignButton;

  /// No description provided for @autoAssignDistributing.
  ///
  /// In en, this message translates to:
  /// **'Distributing to underfunded envelopes'**
  String get autoAssignDistributing;

  /// No description provided for @autoAssignEnvelopeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 envelope} other{{count} envelopes}}'**
  String autoAssignEnvelopeCount(int count);

  /// No description provided for @autoAssignError.
  ///
  /// In en, this message translates to:
  /// **'Could not auto-assign. Please try again.'**
  String get autoAssignError;

  /// No description provided for @autoAssignNothingToAssign.
  ///
  /// In en, this message translates to:
  /// **'All envelopes with goals are fully funded!'**
  String get autoAssignNothingToAssign;

  /// No description provided for @autoAssignSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Auto-assigned to 1 envelope} other{Auto-assigned to {count} envelopes}}'**
  String autoAssignSuccess(int count);

  /// No description provided for @autoAssignTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-Assign'**
  String get autoAssignTitle;

  /// No description provided for @bulkAssignEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Assign Envelope'**
  String get bulkAssignEnvelope;

  /// No description provided for @bulkAssignError.
  ///
  /// In en, this message translates to:
  /// **'Could not assign envelope. Please try again.'**
  String get bulkAssignError;

  /// No description provided for @bulkAssignSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction updated} other{{count} transactions updated}}'**
  String bulkAssignSuccess(int count);

  /// No description provided for @bulkSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get bulkSelectAll;

  /// No description provided for @bulkCancelSelection.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get bulkCancelSelection;

  /// No description provided for @bulkDeselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get bulkDeselectAll;

  /// No description provided for @bulkSelectEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Select an envelope to assign'**
  String get bulkSelectEnvelope;

  /// No description provided for @bulkSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected} other{{count} selected}}'**
  String bulkSelectedCount(int count);

  /// No description provided for @bulkDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {count, plural, =1{1 transaction} other{{count} transactions}}? This cannot be undone.'**
  String bulkDeleteConfirm(int count);

  /// No description provided for @bulkDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete transactions. Please try again.'**
  String get bulkDeleteError;

  /// No description provided for @bulkDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction deleted} other{{count} transactions deleted}}'**
  String bulkDeleteSuccess(int count);

  /// No description provided for @bulkDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Transactions'**
  String get bulkDeleteTitle;

  /// No description provided for @bulkFlagError.
  ///
  /// In en, this message translates to:
  /// **'Could not set flags. Please try again.'**
  String get bulkFlagError;

  /// No description provided for @bulkFlagSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction flagged} other{{count} transactions flagged}}'**
  String bulkFlagSuccess(int count);

  /// No description provided for @bulkSetFlag.
  ///
  /// In en, this message translates to:
  /// **'Set Flag'**
  String get bulkSetFlag;

  /// No description provided for @bulkClearFlag.
  ///
  /// In en, this message translates to:
  /// **'Clear Flag'**
  String get bulkClearFlag;

  /// No description provided for @bulkClearError.
  ///
  /// In en, this message translates to:
  /// **'Could not update transactions. Please try again.'**
  String get bulkClearError;

  /// No description provided for @bulkClearSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction cleared} other{{count} transactions cleared}}'**
  String bulkClearSuccess(int count);

  /// No description provided for @bulkMarkCleared.
  ///
  /// In en, this message translates to:
  /// **'Mark Cleared'**
  String get bulkMarkCleared;

  /// No description provided for @bulkMarkUncleared.
  ///
  /// In en, this message translates to:
  /// **'Mark Uncleared'**
  String get bulkMarkUncleared;

  /// No description provided for @budgetAssignMoney.
  ///
  /// In en, this message translates to:
  /// **'Assign Money'**
  String get budgetAssignMoney;

  /// No description provided for @budgetAgeOfMoneyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Not enough history yet'**
  String get budgetAgeOfMoneyEmpty;

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

  /// No description provided for @budgetCollapseExpand.
  ///
  /// In en, this message translates to:
  /// **'Collapse/Expand'**
  String get budgetCollapseExpand;

  /// No description provided for @budgetInlineEditorDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get budgetInlineEditorDetails;

  /// No description provided for @budgetAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get budgetAddExpense;

  /// No description provided for @budgetAddIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get budgetAddIncome;

  /// No description provided for @budgetSpotlightAddPriorities.
  ///
  /// In en, this message translates to:
  /// **'Add Priorities'**
  String get budgetSpotlightAddPriorities;

  /// No description provided for @budgetSpotlightAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get budgetSpotlightAssigned;

  /// No description provided for @budgetSpotlightAssign.
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get budgetSpotlightAssign;

  /// No description provided for @budgetSpotlightEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get budgetSpotlightEdit;

  /// No description provided for @budgetSpotlightReflect.
  ///
  /// In en, this message translates to:
  /// **'Reflect'**
  String get budgetSpotlightReflect;

  /// No description provided for @budgetSpotlightSpent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get budgetSpotlightSpent;

  /// No description provided for @budgetSpotlightSummarySuffix.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get budgetSpotlightSummarySuffix;

  /// No description provided for @budgetSpotlightTopPriorities.
  ///
  /// In en, this message translates to:
  /// **'Top Priorities'**
  String get budgetSpotlightTopPriorities;

  /// No description provided for @budgetSpotlightTopPrioritiesHint.
  ///
  /// In en, this message translates to:
  /// **'Keep your focus categories front and center for this month.'**
  String get budgetSpotlightTopPrioritiesHint;

  /// No description provided for @budgetSpotlightTotalTargets.
  ///
  /// In en, this message translates to:
  /// **'Total Targets'**
  String get budgetSpotlightTotalTargets;

  /// No description provided for @budgetSpotlightUnderfunded.
  ///
  /// In en, this message translates to:
  /// **'Underfunded'**
  String get budgetSpotlightUnderfunded;

  /// No description provided for @budgetOnboardingAddAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Start working with real numbers'**
  String get budgetOnboardingAddAccountsTitle;

  /// No description provided for @budgetOnboardingAddAccountsBody.
  ///
  /// In en, this message translates to:
  /// **'Every dollar needs a real account balance. Add your account balances to see what you\'re working with.'**
  String get budgetOnboardingAddAccountsBody;

  /// No description provided for @budgetOnboardingAddAccountsCta.
  ///
  /// In en, this message translates to:
  /// **'Add Accounts'**
  String get budgetOnboardingAddAccountsCta;

  /// No description provided for @budgetOnboardingAssignMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Assign Your {amount}'**
  String budgetOnboardingAssignMoneyTitle(String amount);

  /// No description provided for @budgetOnboardingAssignMoneyBody.
  ///
  /// In en, this message translates to:
  /// **'This is money in your OpenBudget accounts. Give it a job before payday.'**
  String get budgetOnboardingAssignMoneyBody;

  /// No description provided for @budgetOnboardingAssignMoneyPrompt.
  ///
  /// In en, this message translates to:
  /// **'Start by asking yourself what this money needs to do before you get paid again.'**
  String get budgetOnboardingAssignMoneyPrompt;

  /// No description provided for @budgetOnboardingAddAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Another Account'**
  String get budgetOnboardingAddAnotherAccount;

  /// No description provided for @budgetOnboardingFinishTitle.
  ///
  /// In en, this message translates to:
  /// **'Spend with confidence and clarity'**
  String get budgetOnboardingFinishTitle;

  /// No description provided for @budgetOnboardingFinishBody.
  ///
  /// In en, this message translates to:
  /// **'Intentional spending reduces stress, regret, and second-guessing.'**
  String get budgetOnboardingFinishBody;

  /// No description provided for @budgetOnboardingFinishCta.
  ///
  /// In en, this message translates to:
  /// **'Finish Onboarding'**
  String get budgetOnboardingFinishCta;

  /// No description provided for @budgetAllocationError.
  ///
  /// In en, this message translates to:
  /// **'Could not update allocation'**
  String get budgetAllocationError;

  /// No description provided for @budgetAllocationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Allocation updated'**
  String get budgetAllocationUpdated;

  /// No description provided for @budgetCategoryCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create category'**
  String get budgetCategoryCreateError;

  /// No description provided for @budgetCategoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category created'**
  String get budgetCategoryCreated;

  /// No description provided for @budgetCategoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get budgetCategoryNameLabel;

  /// No description provided for @budgetCategoryTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get budgetCategoryTotal;

  /// No description provided for @categoryDetailAmountToAssignThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Amount to Assign This Month'**
  String get categoryDetailAmountToAssignThisMonth;

  /// No description provided for @categoryDetailAssignedSoFar.
  ///
  /// In en, this message translates to:
  /// **'Assigned So Far'**
  String get categoryDetailAssignedSoFar;

  /// No description provided for @categoryDetailAssignMore.
  ///
  /// In en, this message translates to:
  /// **'Assign {amount} more to meet your target'**
  String categoryDetailAssignMore(String amount);

  /// No description provided for @categoryDetailBalanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get categoryDetailBalanceTitle;

  /// No description provided for @categoryDetailDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this category and its budget history?'**
  String get categoryDetailDeleteConfirm;

  /// No description provided for @categoryDetailDeleteEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get categoryDetailDeleteEnvelope;

  /// No description provided for @categoryDetailEditEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Rename Category'**
  String get categoryDetailEditEnvelope;

  /// No description provided for @categoryDetailHideEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Hide Category'**
  String get categoryDetailHideEnvelope;

  /// No description provided for @categoryDetailNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get categoryDetailNotesTitle;

  /// No description provided for @categoryDetailSnoozeGoal.
  ///
  /// In en, this message translates to:
  /// **'Snooze for this month'**
  String get categoryDetailSnoozeGoal;

  /// No description provided for @categoryDetailTargetMet.
  ///
  /// In en, this message translates to:
  /// **'You\'ve met your target!'**
  String get categoryDetailTargetMet;

  /// No description provided for @categoryDetailTargetTitle.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get categoryDetailTargetTitle;

  /// No description provided for @categoryDetailToGo.
  ///
  /// In en, this message translates to:
  /// **'To Go'**
  String get categoryDetailToGo;

  /// No description provided for @categoryDetailUnhideEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Unhide Category'**
  String get categoryDetailUnhideEnvelope;

  /// No description provided for @budgetColumnAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get budgetColumnAvailable;

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

  /// No description provided for @budgetCopyLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Copy Last Month'**
  String get budgetCopyLastMonth;

  /// No description provided for @budgetCopyLastMonthConfirm.
  ///
  /// In en, this message translates to:
  /// **'Copy all budget allocations from last month to the current month? This will overwrite any existing allocations.'**
  String get budgetCopyLastMonthConfirm;

  /// No description provided for @budgetCopyLastMonthError.
  ///
  /// In en, this message translates to:
  /// **'Could not copy previous month. Please try again.'**
  String get budgetCopyLastMonthError;

  /// No description provided for @budgetCopyLastMonthSuccess.
  ///
  /// In en, this message translates to:
  /// **'Allocations copied from previous month'**
  String get budgetCopyLastMonthSuccess;

  /// No description provided for @budgetDeleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get budgetDeleteButton;

  /// No description provided for @budgetDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This will permanently remove the budget and all its data.'**
  String budgetDeleteConfirm(String name);

  /// No description provided for @budgetDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete budget. Please try again.'**
  String get budgetDeleteError;

  /// No description provided for @budgetDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted'**
  String get budgetDeleteSuccess;

  /// No description provided for @budgetDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Budget'**
  String get budgetDeleteTitle;

  /// No description provided for @budgetEditCategoryError.
  ///
  /// In en, this message translates to:
  /// **'Could not rename category. Please try again.'**
  String get budgetEditCategoryError;

  /// No description provided for @budgetEditCategorySuccess.
  ///
  /// In en, this message translates to:
  /// **'Category renamed'**
  String get budgetEditCategorySuccess;

  /// No description provided for @budgetEditCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Category'**
  String get budgetEditCategoryTitle;

  /// No description provided for @budgetEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first envelope category to start budgeting'**
  String get budgetEmptySubtitle;

  /// No description provided for @budgetEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Categories Yet'**
  String get budgetEmptyTitle;

  /// No description provided for @budgetEnvelopeAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Budgeted Amount'**
  String get budgetEnvelopeAmountLabel;

  /// No description provided for @budgetEnvelopeCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create envelope'**
  String get budgetEnvelopeCreateError;

  /// No description provided for @budgetEnvelopeCreated.
  ///
  /// In en, this message translates to:
  /// **'Envelope created'**
  String get budgetEnvelopeCreated;

  /// No description provided for @budgetEnvelopeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Envelope Name'**
  String get budgetEnvelopeNameLabel;

  /// No description provided for @budgetHiddenCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hidden} other{{count} hidden}}'**
  String budgetHiddenCount(int count);

  /// No description provided for @budgetGoToToday.
  ///
  /// In en, this message translates to:
  /// **'Back to Today'**
  String get budgetGoToToday;

  /// No description provided for @budgetMonthPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Jump to Month'**
  String get budgetMonthPickerTitle;

  /// No description provided for @budgetHideCategory.
  ///
  /// In en, this message translates to:
  /// **'Hide Category'**
  String get budgetHideCategory;

  /// No description provided for @budgetHideEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Hide Envelope'**
  String get budgetHideEnvelope;

  /// No description provided for @budgetHiddenLabel.
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get budgetHiddenLabel;

  /// No description provided for @budgetLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load budget details'**
  String get budgetLoadError;

  /// No description provided for @budgetMonthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get budgetMonthApril;

  /// No description provided for @budgetMonthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get budgetMonthAugust;

  /// No description provided for @budgetMonthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get budgetMonthDecember;

  /// No description provided for @budgetMonthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get budgetMonthFebruary;

  /// No description provided for @budgetMonthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get budgetMonthJanuary;

  /// No description provided for @budgetMonthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get budgetMonthJuly;

  /// No description provided for @budgetMonthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get budgetMonthJune;

  /// No description provided for @budgetMonthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get budgetMonthMarch;

  /// No description provided for @budgetMonthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get budgetMonthMay;

  /// No description provided for @budgetMonthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get budgetMonthNovember;

  /// No description provided for @budgetMonthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get budgetMonthOctober;

  /// No description provided for @budgetMonthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get budgetMonthSeptember;

  /// No description provided for @budgetOverspentWarning.
  ///
  /// In en, this message translates to:
  /// **'Overspent: {amount}'**
  String budgetOverspentWarning(String amount);

  /// No description provided for @budgetReadyToAssign.
  ///
  /// In en, this message translates to:
  /// **'Ready to Assign'**
  String get budgetReadyToAssign;

  /// No description provided for @budgetTotalIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get budgetTotalIncome;

  /// No description provided for @budgetTotalBudgeted.
  ///
  /// In en, this message translates to:
  /// **'Budgeted'**
  String get budgetTotalBudgeted;

  /// No description provided for @budgetTotalActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get budgetTotalActivity;

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

  /// No description provided for @budgetReorderError.
  ///
  /// In en, this message translates to:
  /// **'Could not reorder categories'**
  String get budgetReorderError;

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

  /// No description provided for @budgetShowHidden.
  ///
  /// In en, this message translates to:
  /// **'Show Hidden'**
  String get budgetShowHidden;

  /// No description provided for @budgetSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search envelopes...'**
  String get budgetSearchHint;

  /// No description provided for @budgetSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching envelopes'**
  String get budgetSearchNoResults;

  /// No description provided for @budgetSearchResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 match} other{{count} matches}}'**
  String budgetSearchResultCount(int count);

  /// No description provided for @budgetUnhideCategory.
  ///
  /// In en, this message translates to:
  /// **'Unhide Category'**
  String get budgetUnhideCategory;

  /// No description provided for @budgetUnhideEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Unhide Envelope'**
  String get budgetUnhideEnvelope;

  /// No description provided for @budgetViewAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get budgetViewAccounts;

  /// No description provided for @categoryTrendsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add categorized transactions to see spending trends by category'**
  String get categoryTrendsEmptySubtitle;

  /// No description provided for @categoryTrendsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Category Data'**
  String get categoryTrendsEmptyTitle;

  /// No description provided for @categoryTrendsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load category trends'**
  String get categoryTrendsLoadError;

  /// No description provided for @categoryTrendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Category Trends'**
  String get categoryTrendsTitle;

  /// No description provided for @comparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget Comparison'**
  String get comparisonTitle;

  /// No description provided for @comparisonMonthRange.
  ///
  /// In en, this message translates to:
  /// **'Month Range'**
  String get comparisonMonthRange;

  /// No description provided for @comparisonMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Last 1 month} other{Last {count} months}}'**
  String comparisonMonths(int count);

  /// No description provided for @comparisonLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load comparison data'**
  String get comparisonLoadError;

  /// No description provided for @comparisonEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Budget Data'**
  String get comparisonEmptyTitle;

  /// No description provided for @comparisonEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add categories and envelopes to compare months'**
  String get comparisonEmptySubtitle;

  /// No description provided for @comparisonCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get comparisonCategoryLabel;

  /// No description provided for @comparisonTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Spending'**
  String get comparisonTotalLabel;

  /// No description provided for @createBudgetButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createBudgetButton;

  /// No description provided for @createBudgetCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating...'**
  String get createBudgetCreating;

  /// No description provided for @createBudgetCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Primary Currency'**
  String get createBudgetCurrencyLabel;

  /// No description provided for @createBudgetError.
  ///
  /// In en, this message translates to:
  /// **'Could not create budget. Please try again.'**
  String get createBudgetError;

  /// No description provided for @createBudgetNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Budget Name'**
  String get createBudgetNameLabel;

  /// No description provided for @createBudgetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Budget created successfully'**
  String get createBudgetSuccess;

  /// No description provided for @createBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudgetTitle;

  /// No description provided for @createBudgetDefaultName.
  ///
  /// In en, this message translates to:
  /// **'My Plan'**
  String get createBudgetDefaultName;

  /// No description provided for @createBudgetPersonalize.
  ///
  /// In en, this message translates to:
  /// **'Personalize Your Plan'**
  String get createBudgetPersonalize;

  /// No description provided for @createBudgetPlanCurrency.
  ///
  /// In en, this message translates to:
  /// **'Plan Currency'**
  String get createBudgetPlanCurrency;

  /// No description provided for @createBudgetWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome, new OpenBudgeter!'**
  String get createBudgetWelcomeTitle;

  /// No description provided for @createBudgetWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll show you how to give every dollar a job so you can spend without second-guessing.'**
  String get createBudgetWelcomeSubtitle;

  /// No description provided for @createBudgetWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'First, let\'s make sure your categories are in tip-top shape.'**
  String get createBudgetWelcomeBody;

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

  /// No description provided for @deleteConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteConfirmButton;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get deleteConfirmMessage;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete. Please try again.'**
  String get deleteError;

  /// No description provided for @deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get deleteSuccess;

  /// No description provided for @dialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialogCancel;

  /// No description provided for @dialogDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get dialogDone;

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

  /// No description provided for @duplicateWarning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Possible duplicate: 1 similar transaction found} other{Possible duplicates: {count} similar transactions found}}'**
  String duplicateWarning(int count);

  /// No description provided for @editEnvelopeError.
  ///
  /// In en, this message translates to:
  /// **'Could not update envelope'**
  String get editEnvelopeError;

  /// No description provided for @editEnvelopeSaved.
  ///
  /// In en, this message translates to:
  /// **'Envelope updated'**
  String get editEnvelopeSaved;

  /// No description provided for @editEnvelopeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Envelope'**
  String get editEnvelopeTitle;

  /// No description provided for @envelopeActionEditEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Edit Envelope'**
  String get envelopeActionEditEnvelope;

  /// No description provided for @envelopeActionMoveMoney.
  ///
  /// In en, this message translates to:
  /// **'Move Money'**
  String get envelopeActionMoveMoney;

  /// No description provided for @envelopeActionSetGoal.
  ///
  /// In en, this message translates to:
  /// **'Set Goal'**
  String get envelopeActionSetGoal;

  /// No description provided for @envelopeActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get envelopeActivityTitle;

  /// No description provided for @envelopeAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get envelopeAssigned;

  /// No description provided for @envelopeAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get envelopeAvailable;

  /// No description provided for @envelopeCarryover.
  ///
  /// In en, this message translates to:
  /// **'Carried over: {amount}'**
  String envelopeCarryover(String amount);

  /// No description provided for @envelopeFromLastMonth.
  ///
  /// In en, this message translates to:
  /// **'From Last Month'**
  String get envelopeFromLastMonth;

  /// No description provided for @envelopeNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No transactions this month'**
  String get envelopeNoActivity;

  /// No description provided for @envelopeNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note for this envelope (optional)'**
  String get envelopeNoteHint;

  /// No description provided for @envelopeNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get envelopeNoteLabel;

  /// No description provided for @envelopeReorderHint.
  ///
  /// In en, this message translates to:
  /// **'Long press an envelope to reorder within category'**
  String get envelopeReorderHint;

  /// No description provided for @envelopeUnderfunded.
  ///
  /// In en, this message translates to:
  /// **'{amount} needed'**
  String envelopeUnderfunded(String amount);

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

  /// No description provided for @goalError.
  ///
  /// In en, this message translates to:
  /// **'Could not save goal. Please try again.'**
  String get goalError;

  /// No description provided for @goalRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove Goal'**
  String get goalRemove;

  /// No description provided for @goalRemoved.
  ///
  /// In en, this message translates to:
  /// **'Goal removed'**
  String get goalRemoved;

  /// No description provided for @goalSaved.
  ///
  /// In en, this message translates to:
  /// **'Goal saved'**
  String get goalSaved;

  /// No description provided for @goalSetGoal.
  ///
  /// In en, this message translates to:
  /// **'Set Goal'**
  String get goalSetGoal;

  /// No description provided for @goalSetTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Goal'**
  String get goalSetTitle;

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

  /// No description provided for @goalTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal Type'**
  String get goalTypeLabel;

  /// No description provided for @goalTypeMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get goalTypeMonthly;

  /// No description provided for @homeBudgetAccounts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account} other{{count} accounts}}'**
  String homeBudgetAccounts(int count);

  /// No description provided for @homeBudgetCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 budget} other{{count} budgets}}'**
  String homeBudgetCount(int count);

  /// No description provided for @homeBudgetOverspent.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 overspent} other{{count} overspent}}'**
  String homeBudgetOverspent(int count);

  /// No description provided for @homeBudgetReadyToAssign.
  ///
  /// In en, this message translates to:
  /// **'{amount} to assign'**
  String homeBudgetReadyToAssign(String amount);

  /// No description provided for @homeBudgetTotalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get homeBudgetTotalBalance;

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

  /// No description provided for @homeLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get homeLogout;

  /// No description provided for @homeNetWorthLabel.
  ///
  /// In en, this message translates to:
  /// **'Net Worth'**
  String get homeNetWorthLabel;

  /// No description provided for @homeNetWorthAccounts.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account} other{{count} accounts}}'**
  String homeNetWorthAccounts(int count);

  /// No description provided for @homeNoBudgets.
  ///
  /// In en, this message translates to:
  /// **'No Budgets Yet'**
  String get homeNoBudgets;

  /// No description provided for @homeRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get homeRetry;

  /// No description provided for @importButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import 1 Transaction} other{Import {count} Transactions}}'**
  String importButton(int count);

  /// No description provided for @importCsvHint.
  ///
  /// In en, this message translates to:
  /// **'Date,Description,Amount\n2026-01-15,Grocery Store,-45.50\n2026-01-16,Paycheck,2500.00'**
  String get importCsvHint;

  /// No description provided for @importCsvLabel.
  ///
  /// In en, this message translates to:
  /// **'CSV Data'**
  String get importCsvLabel;

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Could not import transactions. Please try again.'**
  String get importError;

  /// No description provided for @importImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing...'**
  String get importImporting;

  /// No description provided for @importInstructions.
  ///
  /// In en, this message translates to:
  /// **'Paste CSV data with columns for date, description, and amount. Headers are auto-detected.'**
  String get importInstructions;

  /// No description provided for @importMoreRows.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{...and 1 more row} other{...and {count} more rows}}'**
  String importMoreRows(int count);

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

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction imported} other{{count} transactions imported}}'**
  String importSuccess(int count);

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Transactions'**
  String get importTitle;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @loginContinueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get loginContinueWithApple;

  /// No description provided for @loginContinueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get loginContinueWithGoogle;

  /// No description provided for @loginCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get loginCreateAccount;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// No description provided for @loginLoading.
  ///
  /// In en, this message translates to:
  /// **'Signing In...'**
  String get loginLoading;

  /// No description provided for @loginOrSeparator.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get loginOrSeparator;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginProviderUnavailable.
  ///
  /// In en, this message translates to:
  /// **'{provider} is not available yet.'**
  String loginProviderUnavailable(String provider);

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to OpenBudget'**
  String get loginTitle;

  /// No description provided for @moveMoneyButton.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get moveMoneyButton;

  /// No description provided for @moveMoneyError.
  ///
  /// In en, this message translates to:
  /// **'Could not move money. Please try again.'**
  String get moveMoneyError;

  /// No description provided for @moveMoneyFrom.
  ///
  /// In en, this message translates to:
  /// **'From Envelope'**
  String get moveMoneyFrom;

  /// No description provided for @moveMoneySameError.
  ///
  /// In en, this message translates to:
  /// **'Cannot move money to the same envelope'**
  String get moveMoneySameError;

  /// No description provided for @moveMoneySuccess.
  ///
  /// In en, this message translates to:
  /// **'Money moved between envelopes'**
  String get moveMoneySuccess;

  /// No description provided for @moveMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Move Money'**
  String get moveMoneyTitle;

  /// No description provided for @moveMoneyTo.
  ///
  /// In en, this message translates to:
  /// **'To Envelope'**
  String get moveMoneyTo;

  /// No description provided for @netWorthAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get netWorthAssets;

  /// No description provided for @netWorthEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add accounts to see your net worth breakdown'**
  String get netWorthEmptySubtitle;

  /// No description provided for @netWorthEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Accounts Yet'**
  String get netWorthEmptyTitle;

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

  /// No description provided for @netWorthTitle.
  ///
  /// In en, this message translates to:
  /// **'Net Worth'**
  String get netWorthTitle;

  /// No description provided for @payeeAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Payee'**
  String get payeeAddButton;

  /// No description provided for @payeeAutoEnvelopeHint.
  ///
  /// In en, this message translates to:
  /// **'Envelope auto-suggested from last transaction with this payee'**
  String get payeeAutoEnvelopeHint;

  /// No description provided for @payeeCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create payee. Please try again.'**
  String get payeeCreateError;

  /// No description provided for @payeeCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payee created'**
  String get payeeCreateSuccess;

  /// No description provided for @payeeEditError.
  ///
  /// In en, this message translates to:
  /// **'Could not update payee. Please try again.'**
  String get payeeEditError;

  /// No description provided for @payeeEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payee updated'**
  String get payeeEditSuccess;

  /// No description provided for @payeeEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Payee'**
  String get payeeEditTitle;

  /// No description provided for @payeeEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add payees to track who you transact with'**
  String get payeeEmptySubtitle;

  /// No description provided for @payeeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Payees Yet'**
  String get payeeEmptyTitle;

  /// No description provided for @payeeLabel.
  ///
  /// In en, this message translates to:
  /// **'Payee'**
  String get payeeLabel;

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

  /// No description provided for @payeeMergeButton.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get payeeMergeButton;

  /// No description provided for @payeeMergeError.
  ///
  /// In en, this message translates to:
  /// **'Could not merge payees. Please try again.'**
  String get payeeMergeError;

  /// No description provided for @payeeMergeInto.
  ///
  /// In en, this message translates to:
  /// **'Merge into'**
  String get payeeMergeInto;

  /// No description provided for @payeeMergeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payees merged'**
  String get payeeMergeSuccess;

  /// No description provided for @payeeMergeTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge Payee'**
  String get payeeMergeTitle;

  /// No description provided for @payeeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Payee Name'**
  String get payeeNameLabel;

  /// No description provided for @payeeNone.
  ///
  /// In en, this message translates to:
  /// **'No Payee'**
  String get payeeNone;

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

  /// No description provided for @quickBudgetTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Budget'**
  String get quickBudgetTitle;

  /// No description provided for @reconcileAdjustmentNote.
  ///
  /// In en, this message translates to:
  /// **'An adjustment transaction will be created for the difference.'**
  String get reconcileAdjustmentNote;

  /// No description provided for @reconcileBalanceHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your current bank balance'**
  String get reconcileBalanceHint;

  /// No description provided for @reconcileBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Statement Balance'**
  String get reconcileBalanceLabel;

  /// No description provided for @reconcileButton.
  ///
  /// In en, this message translates to:
  /// **'Reconcile'**
  String get reconcileButton;

  /// No description provided for @reconcileClearedBalance.
  ///
  /// In en, this message translates to:
  /// **'Cleared Balance'**
  String get reconcileClearedBalance;

  /// No description provided for @reconcileDifference.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get reconcileDifference;

  /// No description provided for @reconcileError.
  ///
  /// In en, this message translates to:
  /// **'Could not reconcile account. Please try again.'**
  String get reconcileError;

  /// No description provided for @reconcileMessage.
  ///
  /// In en, this message translates to:
  /// **'Mark all cleared transactions as reconciled? This locks them from further editing.'**
  String get reconcileMessage;

  /// No description provided for @recentMovesArrowLabel.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get recentMovesArrowLabel;

  /// No description provided for @recentMovesDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Moves'**
  String get recentMovesDetailTitle;

  /// No description provided for @recentMovesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Moves and assignments will appear here as you budget.'**
  String get recentMovesEmptySubtitle;

  /// No description provided for @recentMovesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No recent moves yet'**
  String get recentMovesEmptyTitle;

  /// No description provided for @recentMovesNoEnvelopeHistory.
  ///
  /// In en, this message translates to:
  /// **'No move history for {envelopeName}'**
  String recentMovesNoEnvelopeHistory(String envelopeName);

  /// No description provided for @recentMovesNoEnvelopeHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'This envelope has not been part of a recorded move yet.'**
  String get recentMovesNoEnvelopeHistoryHint;

  /// No description provided for @recentMovesReadyToAssign.
  ///
  /// In en, this message translates to:
  /// **'Ready to Assign'**
  String get recentMovesReadyToAssign;

  /// No description provided for @recentMovesTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get recentMovesTabAll;

  /// No description provided for @recentMovesTabAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get recentMovesTabAssigned;

  /// No description provided for @recentMovesTabMoved.
  ///
  /// In en, this message translates to:
  /// **'Moved'**
  String get recentMovesTabMoved;

  /// No description provided for @recentMovesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Moves'**
  String get recentMovesTitle;

  /// No description provided for @recentMovesCoachTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Moves'**
  String get recentMovesCoachTitle;

  /// No description provided for @recentMovesCoachBody.
  ///
  /// In en, this message translates to:
  /// **'OpenBudget keeps a 34-day history of assignments and money moves for each plan.'**
  String get recentMovesCoachBody;

  /// No description provided for @recentMovesCoachHint.
  ///
  /// In en, this message translates to:
  /// **'Tap any blue category chip to view move details for that category.'**
  String get recentMovesCoachHint;

  /// No description provided for @recentMovesCoachGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got It!'**
  String get recentMovesCoachGotIt;

  /// No description provided for @recentMovesUnnamedEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Envelope'**
  String get recentMovesUnnamedEnvelope;

  /// No description provided for @reconcileSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No transactions to reconcile} =1{1 transaction reconciled} other{{count} transactions reconciled}}'**
  String reconcileSuccess(int count);

  /// No description provided for @reconcileSuccessWithAdjustment.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Reconciled with {adjustment} adjustment} =1{1 transaction reconciled with {adjustment} adjustment} other{{count} transactions reconciled with {adjustment} adjustment}}'**
  String reconcileSuccessWithAdjustment(int count, String adjustment);

  /// No description provided for @reconcileTitle.
  ///
  /// In en, this message translates to:
  /// **'Reconcile Account'**
  String get reconcileTitle;

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

  /// No description provided for @recurringAutoPosted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 scheduled transaction auto-posted} other{{count} scheduled transactions auto-posted}}'**
  String recurringAutoPosted(int count);

  /// No description provided for @recurringCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create recurring transaction. Please try again.'**
  String get recurringCreateError;

  /// No description provided for @recurringCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recurring transaction created'**
  String get recurringCreateSuccess;

  /// No description provided for @recurringDueBanner.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 scheduled transaction is due} other{{count} scheduled transactions are due}}'**
  String recurringDueBanner(int count);

  /// No description provided for @recurringDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get recurringDueLabel;

  /// No description provided for @recurringEditError.
  ///
  /// In en, this message translates to:
  /// **'Could not update recurring transaction. Please try again.'**
  String get recurringEditError;

  /// No description provided for @recurringEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Recurring transaction updated'**
  String get recurringEditSuccess;

  /// No description provided for @recurringEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Recurring Transaction'**
  String get recurringEditTitle;

  /// No description provided for @recurringEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set up recurring transactions for bills, subscriptions, and regular income'**
  String get recurringEmptySubtitle;

  /// No description provided for @recurringEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Recurring Transactions'**
  String get recurringEmptyTitle;

  /// No description provided for @recurringFreqBiweekly.
  ///
  /// In en, this message translates to:
  /// **'Biweekly'**
  String get recurringFreqBiweekly;

  /// No description provided for @recurringFreqDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get recurringFreqDaily;

  /// No description provided for @recurringFreqMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recurringFreqMonthly;

  /// No description provided for @recurringFreqWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurringFreqWeekly;

  /// No description provided for @recurringFreqYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get recurringFreqYearly;

  /// No description provided for @recurringFrequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get recurringFrequencyLabel;

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

  /// No description provided for @recurringNextDate.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get recurringNextDate;

  /// No description provided for @recurringPostDue.
  ///
  /// In en, this message translates to:
  /// **'Post Now'**
  String get recurringPostDue;

  /// No description provided for @recurringPostError.
  ///
  /// In en, this message translates to:
  /// **'Could not post scheduled transactions. Please try again.'**
  String get recurringPostError;

  /// No description provided for @recurringPostSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction posted} other{{count} transactions posted}}'**
  String recurringPostSuccess(int count);

  /// No description provided for @recurringTotalCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 recurring transaction} other{{count} recurring transactions}}'**
  String recurringTotalCount(int count);

  /// No description provided for @recurringPosting.
  ///
  /// In en, this message translates to:
  /// **'Posting...'**
  String get recurringPosting;

  /// No description provided for @recurringSkipButton.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get recurringSkipButton;

  /// No description provided for @recurringSkipError.
  ///
  /// In en, this message translates to:
  /// **'Could not skip occurrence. Please try again.'**
  String get recurringSkipError;

  /// No description provided for @recurringSkipSuccess.
  ///
  /// In en, this message translates to:
  /// **'Occurrence skipped'**
  String get recurringSkipSuccess;

  /// No description provided for @recurringStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get recurringStartDate;

  /// No description provided for @scheduledCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Calendar'**
  String get scheduledCalendarTitle;

  /// No description provided for @scheduledCalendarLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load calendar data'**
  String get scheduledCalendarLoadError;

  /// No description provided for @scheduledCalendarNoEvents.
  ///
  /// In en, this message translates to:
  /// **'No scheduled transactions on this day'**
  String get scheduledCalendarNoEvents;

  /// No description provided for @scheduledCalendarSelectDay.
  ///
  /// In en, this message translates to:
  /// **'Tap a day to see scheduled transactions'**
  String get scheduledCalendarSelectDay;

  /// No description provided for @scheduledCalendarMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get scheduledCalendarMon;

  /// No description provided for @scheduledCalendarTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get scheduledCalendarTue;

  /// No description provided for @scheduledCalendarWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get scheduledCalendarWed;

  /// No description provided for @scheduledCalendarThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get scheduledCalendarThu;

  /// No description provided for @scheduledCalendarFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get scheduledCalendarFri;

  /// No description provided for @scheduledCalendarSat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get scheduledCalendarSat;

  /// No description provided for @scheduledCalendarSun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get scheduledCalendarSun;

  /// No description provided for @registerAlreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get registerAlreadyHaveAccount;

  /// No description provided for @registerCodeError.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code. Please try again.'**
  String get registerCodeError;

  /// No description provided for @registerCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Verification Code'**
  String get registerCodeLabel;

  /// No description provided for @registerCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the verification code'**
  String get registerCodeRequired;

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

  /// No description provided for @registerEmailError.
  ///
  /// In en, this message translates to:
  /// **'Could not start registration. Please try again.'**
  String get registerEmailError;

  /// No description provided for @registerEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get registerEmailRequired;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registerPasswordMismatch;

  /// No description provided for @registerPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get registerPasswordRequired;

  /// No description provided for @registerSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get registerSendCode;

  /// No description provided for @registerStepCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to your email'**
  String get registerStepCode;

  /// No description provided for @registerStepEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to get started'**
  String get registerStepEmail;

  /// No description provided for @registerStepPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a password for your account'**
  String get registerStepPassword;

  /// No description provided for @registerSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get registerSubmitting;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerVerifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify Code'**
  String get registerVerifyCode;

  /// No description provided for @reportsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add transactions to see spending reports for this month'**
  String get reportsEmptySubtitle;

  /// No description provided for @reportsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Data Yet'**
  String get reportsEmptyTitle;

  /// No description provided for @reportsExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get reportsExpenses;

  /// No description provided for @reportsIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get reportsIncome;

  /// No description provided for @reportsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load report data'**
  String get reportsLoadError;

  /// No description provided for @reportsNetIncome.
  ///
  /// In en, this message translates to:
  /// **'Net Income'**
  String get reportsNetIncome;

  /// No description provided for @reportsSpendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get reportsSpendingByCategory;

  /// No description provided for @reportsUncategorised.
  ///
  /// In en, this message translates to:
  /// **'Uncategorised'**
  String get reportsUncategorised;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @reportsTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get reportsTransactions;

  /// No description provided for @settingsAccountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// No description provided for @settingsAccountEmail.
  ///
  /// In en, this message translates to:
  /// **'openbudget.user@email.com'**
  String get settingsAccountEmail;

  /// No description provided for @settingsAccountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get settingsAccountSettings;

  /// No description provided for @settingsAccountSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Update login credentials or account security'**
  String get settingsAccountSettingsHint;

  /// No description provided for @settingsAppIcon.
  ///
  /// In en, this message translates to:
  /// **'App Icon'**
  String get settingsAppIcon;

  /// No description provided for @settingsAppIconHint.
  ///
  /// In en, this message translates to:
  /// **'Applies instantly to OpenBudget in-app branding previews.'**
  String get settingsAppIconHint;

  /// No description provided for @settingsAppIconInk.
  ///
  /// In en, this message translates to:
  /// **'Ink'**
  String get settingsAppIconInk;

  /// No description provided for @settingsAppIconNight.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get settingsAppIconNight;

  /// No description provided for @settingsAppIconPrimary.
  ///
  /// In en, this message translates to:
  /// **'Paper'**
  String get settingsAppIconPrimary;

  /// No description provided for @settingsAppSection.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get settingsAppSection;

  /// No description provided for @settingsBalanceStyle.
  ///
  /// In en, this message translates to:
  /// **'Balance Style'**
  String get settingsBalanceStyle;

  /// No description provided for @settingsBalanceStyleAccessible.
  ///
  /// In en, this message translates to:
  /// **'Differentiate Without Color'**
  String get settingsBalanceStyleAccessible;

  /// No description provided for @settingsBalanceStyleDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settingsBalanceStyleDefault;

  /// No description provided for @settingsBudgetName.
  ///
  /// In en, this message translates to:
  /// **'Budget Name'**
  String get settingsBudgetName;

  /// No description provided for @settingsBudgetSection.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get settingsBudgetSection;

  /// No description provided for @settingsCaliforniaPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'California Privacy Policy'**
  String get settingsCaliforniaPrivacyPolicy;

  /// No description provided for @settingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'{featureName} is coming soon.'**
  String settingsComingSoon(String featureName);

  /// No description provided for @settingsCurrencyPlacement.
  ///
  /// In en, this message translates to:
  /// **'Currency Placement'**
  String get settingsCurrencyPlacement;

  /// No description provided for @settingsCurrencyPlacementAfter.
  ///
  /// In en, this message translates to:
  /// **'After Amount (123,456.78\$)'**
  String get settingsCurrencyPlacementAfter;

  /// No description provided for @settingsCurrencyPlacementBefore.
  ///
  /// In en, this message translates to:
  /// **'Before Amount (\$123,456.78)'**
  String get settingsCurrencyPlacementBefore;

  /// No description provided for @settingsCurrencyUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update plan currency. Please try again.'**
  String get settingsCurrencyUpdateError;

  /// No description provided for @settingsCurrencyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Plan currency updated to {currencyCode}'**
  String settingsCurrencyUpdated(String currencyCode);

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get settingsCurrency;

  /// No description provided for @settingsDataSection.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get settingsDataSection;

  /// No description provided for @settingsCurrentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get settingsCurrentPlan;

  /// No description provided for @settingsDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date Format'**
  String get settingsDateFormat;

  /// No description provided for @settingsDateFormatDayMonthYear.
  ///
  /// In en, this message translates to:
  /// **'30/12/2025'**
  String get settingsDateFormatDayMonthYear;

  /// No description provided for @settingsDateFormatMonthDayYear.
  ///
  /// In en, this message translates to:
  /// **'12/30/2025'**
  String get settingsDateFormatMonthDayYear;

  /// No description provided for @settingsDateFormatYearMonthDay.
  ///
  /// In en, this message translates to:
  /// **'2025-12-30'**
  String get settingsDateFormatYearMonthDay;

  /// No description provided for @settingsDeletePlan.
  ///
  /// In en, this message translates to:
  /// **'Delete Plan'**
  String get settingsDeletePlan;

  /// No description provided for @settingsDisplayOptions.
  ///
  /// In en, this message translates to:
  /// **'Display Options'**
  String get settingsDisplayOptions;

  /// No description provided for @settingsDisplayOptionsHint.
  ///
  /// In en, this message translates to:
  /// **'Display options are applied instantly across OpenBudget screens.'**
  String get settingsDisplayOptionsHint;

  /// No description provided for @settingsDisplayCurrency.
  ///
  /// In en, this message translates to:
  /// **'Display Currency'**
  String get settingsDisplayCurrency;

  /// No description provided for @settingsDisplayCurrencyMatchDefault.
  ///
  /// In en, this message translates to:
  /// **'Match Plan Currency (Default)'**
  String get settingsDisplayCurrencyMatchDefault;

  /// No description provided for @settingsDisplayCurrencyUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update display currency. Please try again.'**
  String get settingsDisplayCurrencyUpdateError;

  /// No description provided for @settingsDisplayCurrencyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Display currency updated to {currencyCode}'**
  String settingsDisplayCurrencyUpdated(String currencyCode);

  /// No description provided for @settingsDisplayCurrencyDefaultUpdated.
  ///
  /// In en, this message translates to:
  /// **'Display currency now matches plan currency.'**
  String get settingsDisplayCurrencyDefaultUpdated;

  /// No description provided for @settingsExportData.
  ///
  /// In en, this message translates to:
  /// **'Export Budget'**
  String get settingsExportData;

  /// No description provided for @settingsExportDataHint.
  ///
  /// In en, this message translates to:
  /// **'Copy all budget data as JSON to clipboard'**
  String get settingsExportDataHint;

  /// No description provided for @settingsExportError.
  ///
  /// In en, this message translates to:
  /// **'Could not export budget data. Please try again.'**
  String get settingsExportError;

  /// No description provided for @settingsExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Budget data copied to clipboard'**
  String get settingsExportSuccess;

  /// No description provided for @settingsFreshStartButton.
  ///
  /// In en, this message translates to:
  /// **'Create New Plan'**
  String get settingsFreshStartButton;

  /// No description provided for @settingsFreshStartHint.
  ///
  /// In en, this message translates to:
  /// **'Create a new plan from scratch while keeping your existing plan intact.'**
  String get settingsFreshStartHint;

  /// No description provided for @settingsFreshStart.
  ///
  /// In en, this message translates to:
  /// **'Make a Fresh Start'**
  String get settingsFreshStart;

  /// No description provided for @settingsLastSynced.
  ///
  /// In en, this message translates to:
  /// **'App last synced: 2026-02-21T02:00:00Z'**
  String get settingsLastSynced;

  /// No description provided for @settingsLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settingsLegal;

  /// No description provided for @settingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load settings'**
  String get settingsLoadError;

  /// No description provided for @settingsLoggedInAs.
  ///
  /// In en, this message translates to:
  /// **'Logged in as'**
  String get settingsLoggedInAs;

  /// No description provided for @settingsLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get settingsLogOut;

  /// No description provided for @settingsLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get settingsLogoutConfirm;

  /// No description provided for @settingsManageBankConnections.
  ///
  /// In en, this message translates to:
  /// **'Manage Bank Connections'**
  String get settingsManageBankConnections;

  /// No description provided for @settingsMiscSection.
  ///
  /// In en, this message translates to:
  /// **'Misc'**
  String get settingsMiscSection;

  /// No description provided for @settingsNavigationSection.
  ///
  /// In en, this message translates to:
  /// **'Quick Access'**
  String get settingsNavigationSection;

  /// No description provided for @settingsNewPlan.
  ///
  /// In en, this message translates to:
  /// **'New Plan'**
  String get settingsNewPlan;

  /// No description provided for @settingsNumberFormat.
  ///
  /// In en, this message translates to:
  /// **'Number Format'**
  String get settingsNumberFormat;

  /// No description provided for @settingsNumberFormatEuropean.
  ///
  /// In en, this message translates to:
  /// **'123.456,78'**
  String get settingsNumberFormatEuropean;

  /// No description provided for @settingsNumberFormatStandard.
  ///
  /// In en, this message translates to:
  /// **'123,456.78'**
  String get settingsNumberFormatStandard;

  /// No description provided for @settingsOpenPlan.
  ///
  /// In en, this message translates to:
  /// **'Open Plan'**
  String get settingsOpenPlan;

  /// No description provided for @settingsPlanSettings.
  ///
  /// In en, this message translates to:
  /// **'Plan Settings'**
  String get settingsPlanSettings;

  /// No description provided for @settingsPrivacySection.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacySection;

  /// No description provided for @settingsHideAmounts.
  ///
  /// In en, this message translates to:
  /// **'Hide Amounts'**
  String get settingsHideAmounts;

  /// No description provided for @settingsHideAmountsHint.
  ///
  /// In en, this message translates to:
  /// **'Conceal balances and transaction amounts.'**
  String get settingsHideAmountsHint;

  /// No description provided for @settingsHideProgressBars.
  ///
  /// In en, this message translates to:
  /// **'Hide Progress Bars'**
  String get settingsHideProgressBars;

  /// No description provided for @settingsHideProgressBarsHint.
  ///
  /// In en, this message translates to:
  /// **'Hide spending and funding progress visuals.'**
  String get settingsHideProgressBarsHint;

  /// No description provided for @settingsRenameBudget.
  ///
  /// In en, this message translates to:
  /// **'Rename Budget'**
  String get settingsRenameBudget;

  /// No description provided for @settingsRenameError.
  ///
  /// In en, this message translates to:
  /// **'Could not rename budget. Please try again.'**
  String get settingsRenameError;

  /// No description provided for @settingsRenameSuccess.
  ///
  /// In en, this message translates to:
  /// **'Budget renamed'**
  String get settingsRenameSuccess;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsSendDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Send in Diagnostics'**
  String get settingsSendDiagnostics;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsTogether.
  ///
  /// In en, this message translates to:
  /// **'OpenBudget Together'**
  String get settingsTogether;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version {version}'**
  String settingsVersion(String version);

  /// No description provided for @settingsWriteAReview.
  ///
  /// In en, this message translates to:
  /// **'Write a Review'**
  String get settingsWriteAReview;

  /// No description provided for @settingsYourPrivacyChoices.
  ///
  /// In en, this message translates to:
  /// **'Your Privacy Choices'**
  String get settingsYourPrivacyChoices;

  /// No description provided for @spendingByPayeeBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Spending Breakdown'**
  String get spendingByPayeeBreakdown;

  /// No description provided for @spendingByPayeeEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add expense transactions to see spending by payee'**
  String get spendingByPayeeEmptySubtitle;

  /// No description provided for @spendingByPayeeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Payee Data'**
  String get spendingByPayeeEmptyTitle;

  /// No description provided for @spendingByPayeePayeeCount.
  ///
  /// In en, this message translates to:
  /// **'Payees'**
  String get spendingByPayeePayeeCount;

  /// No description provided for @spendingByPayeeTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending by Payee'**
  String get spendingByPayeeTitle;

  /// No description provided for @spendingByPayeeTotalSpent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get spendingByPayeeTotalSpent;

  /// No description provided for @spendingByPayeeTransactionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 transaction} other{{count} transactions}}'**
  String spendingByPayeeTransactionCount(int count);

  /// No description provided for @spendingTrendsAvgExpenses.
  ///
  /// In en, this message translates to:
  /// **'Avg. Expenses'**
  String get spendingTrendsAvgExpenses;

  /// No description provided for @spendingTrendsAvgIncome.
  ///
  /// In en, this message translates to:
  /// **'Avg. Income'**
  String get spendingTrendsAvgIncome;

  /// No description provided for @spendingTrendsBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Monthly Breakdown'**
  String get spendingTrendsBreakdown;

  /// No description provided for @spendingTrendsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add transactions to see spending trends over time'**
  String get spendingTrendsEmptySubtitle;

  /// No description provided for @spendingTrendsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Spending Data'**
  String get spendingTrendsEmptyTitle;

  /// No description provided for @spendingTrendsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load spending trends'**
  String get spendingTrendsLoadError;

  /// No description provided for @spendingTrendsMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly Comparison'**
  String get spendingTrendsMonthly;

  /// No description provided for @spendingTrendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending Trends'**
  String get spendingTrendsTitle;

  /// No description provided for @splitAddSplit.
  ///
  /// In en, this message translates to:
  /// **'Add Split'**
  String get splitAddSplit;

  /// No description provided for @splitAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get splitAmountLabel;

  /// No description provided for @splitCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 split} other{{count} splits}}'**
  String splitCount(int count);

  /// No description provided for @splitEnvelopeLabel.
  ///
  /// In en, this message translates to:
  /// **'Envelope'**
  String get splitEnvelopeLabel;

  /// No description provided for @splitLabel.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get splitLabel;

  /// No description provided for @splitMemoLabel.
  ///
  /// In en, this message translates to:
  /// **'Memo (optional)'**
  String get splitMemoLabel;

  /// No description provided for @splitMinimumError.
  ///
  /// In en, this message translates to:
  /// **'At least two splits are required'**
  String get splitMinimumError;

  /// No description provided for @splitMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Split amounts must equal the total'**
  String get splitMismatchError;

  /// No description provided for @splitRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Remaining to assign'**
  String get splitRemainingLabel;

  /// No description provided for @splitRemoveSplit.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get splitRemoveSplit;

  /// No description provided for @splitSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save split transaction. Please try again.'**
  String get splitSaveError;

  /// No description provided for @splitSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Split transaction saved'**
  String get splitSaveSuccess;

  /// No description provided for @splitTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Split Transaction'**
  String get splitTransactionTitle;

  /// No description provided for @templateApplyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get templateApplyButton;

  /// No description provided for @templateApplyError.
  ///
  /// In en, this message translates to:
  /// **'Could not apply template. Please try again.'**
  String get templateApplyError;

  /// No description provided for @templateApplySuccess.
  ///
  /// In en, this message translates to:
  /// **'Template applied to current month'**
  String get templateApplySuccess;

  /// No description provided for @templateDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete template. Please try again.'**
  String get templateDeleteError;

  /// No description provided for @templateDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Template deleted'**
  String get templateDeleteSuccess;

  /// No description provided for @templateEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your current month allocations as a template to quickly set up future months.'**
  String get templateEmptySubtitle;

  /// No description provided for @templateEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Templates'**
  String get templateEmptyTitle;

  /// No description provided for @templateNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Standard Month'**
  String get templateNameHint;

  /// No description provided for @templateNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Template Name'**
  String get templateNameLabel;

  /// No description provided for @templateSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Current Month as Template'**
  String get templateSaveButton;

  /// No description provided for @templateSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save template. Please try again.'**
  String get templateSaveError;

  /// No description provided for @templateSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Template saved'**
  String get templateSaveSuccess;

  /// No description provided for @templateTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget Templates'**
  String get templateTitle;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get themeTitle;

  /// No description provided for @transactionAddExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get transactionAddExpense;

  /// No description provided for @transactionFlagTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Flag'**
  String get transactionFlagTitle;

  /// No description provided for @transactionFlagRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get transactionFlagRed;

  /// No description provided for @transactionFlagOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get transactionFlagOrange;

  /// No description provided for @transactionFlagYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get transactionFlagYellow;

  /// No description provided for @transactionFlagGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get transactionFlagGreen;

  /// No description provided for @transactionFlagBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get transactionFlagBlue;

  /// No description provided for @transactionFlagPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get transactionFlagPurple;

  /// No description provided for @transactionFlagClear.
  ///
  /// In en, this message translates to:
  /// **'Clear Flag'**
  String get transactionFlagClear;

  /// No description provided for @transactionAddIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get transactionAddIncome;

  /// No description provided for @transactionAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transactionAmountLabel;

  /// No description provided for @transactionCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get transactionCleared;

  /// No description provided for @transactionDateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get transactionDateToday;

  /// No description provided for @transactionDateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get transactionDateYesterday;

  /// No description provided for @transactionDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get transactionDescriptionLabel;

  /// No description provided for @transactionEditError.
  ///
  /// In en, this message translates to:
  /// **'Could not update transaction. Please try again.'**
  String get transactionEditError;

  /// No description provided for @transactionEditSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated'**
  String get transactionEditSuccess;

  /// No description provided for @transactionEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get transactionEditTitle;

  /// No description provided for @transactionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get transactionEmpty;

  /// No description provided for @transactionError.
  ///
  /// In en, this message translates to:
  /// **'Could not save transaction. Please try again.'**
  String get transactionError;

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

  /// No description provided for @transactionFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get transactionFilterAll;

  /// No description provided for @transactionFilterCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared'**
  String get transactionFilterCleared;

  /// No description provided for @transactionFilterExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get transactionFilterExpense;

  /// No description provided for @transactionFilterFlagged.
  ///
  /// In en, this message translates to:
  /// **'Flagged'**
  String get transactionFilterFlagged;

  /// No description provided for @transactionFilterIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transactionFilterIncome;

  /// No description provided for @transactionFilterReconciled.
  ///
  /// In en, this message translates to:
  /// **'Reconciled'**
  String get transactionFilterReconciled;

  /// No description provided for @transactionFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get transactionFilterStatus;

  /// No description provided for @transactionFilterUncleared.
  ///
  /// In en, this message translates to:
  /// **'Uncleared'**
  String get transactionFilterUncleared;

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

  /// No description provided for @transactionMemoHint.
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get transactionMemoHint;

  /// No description provided for @transactionMemoLabel.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get transactionMemoLabel;

  /// No description provided for @transactionNoResults.
  ///
  /// In en, this message translates to:
  /// **'No matching transactions'**
  String get transactionNoResults;

  /// No description provided for @transactionReconciled.
  ///
  /// In en, this message translates to:
  /// **'Reconciled'**
  String get transactionReconciled;

  /// No description provided for @transactionResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String transactionResultCount(int count);

  /// No description provided for @transactionSave.
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get transactionSave;

  /// No description provided for @transactionDateRangeFilter.
  ///
  /// In en, this message translates to:
  /// **'Date range'**
  String get transactionDateRangeFilter;

  /// No description provided for @transactionDateRangeClear.
  ///
  /// In en, this message translates to:
  /// **'Clear date filter'**
  String get transactionDateRangeClear;

  /// No description provided for @transactionSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search description or memo...'**
  String get transactionSearchHint;

  /// No description provided for @transactionSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get transactionSubmitting;

  /// No description provided for @transactionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction saved'**
  String get transactionSuccess;

  /// No description provided for @transactionUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get transactionUnassigned;

  /// No description provided for @transactionUncleared.
  ///
  /// In en, this message translates to:
  /// **'Uncleared'**
  String get transactionUncleared;

  /// No description provided for @transferButton.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferButton;

  /// No description provided for @transferDate.
  ///
  /// In en, this message translates to:
  /// **'Transfer Date'**
  String get transferDate;

  /// No description provided for @transferDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'Account Transfer'**
  String get transferDefaultDescription;

  /// No description provided for @transferError.
  ///
  /// In en, this message translates to:
  /// **'Could not complete transfer. Please try again.'**
  String get transferError;

  /// No description provided for @transferFromAccount.
  ///
  /// In en, this message translates to:
  /// **'From Account'**
  String get transferFromAccount;

  /// No description provided for @transferNeedTwoAccounts.
  ///
  /// In en, this message translates to:
  /// **'You need at least two accounts to make a transfer'**
  String get transferNeedTwoAccounts;

  /// No description provided for @transferSameAccountError.
  ///
  /// In en, this message translates to:
  /// **'Cannot transfer to the same account'**
  String get transferSameAccountError;

  /// No description provided for @transferSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transfer saved'**
  String get transferSuccess;

  /// No description provided for @transferTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferTitle;

  /// No description provided for @transactionRulesTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Rules'**
  String get transactionRulesTitle;

  /// No description provided for @transactionRulesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Rules Yet'**
  String get transactionRulesEmptyTitle;

  /// No description provided for @transactionRulesEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create rules to auto-assign envelopes when you select a payee'**
  String get transactionRulesEmptySubtitle;

  /// No description provided for @transactionRulesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load transaction rules'**
  String get transactionRulesLoadError;

  /// No description provided for @transactionRulesAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add Rule'**
  String get transactionRulesAddButton;

  /// No description provided for @transactionRulesPayeeLabel.
  ///
  /// In en, this message translates to:
  /// **'When payee is'**
  String get transactionRulesPayeeLabel;

  /// No description provided for @transactionRulesEnvelopeLabel.
  ///
  /// In en, this message translates to:
  /// **'Assign to envelope'**
  String get transactionRulesEnvelopeLabel;

  /// No description provided for @transactionRulesCreateError.
  ///
  /// In en, this message translates to:
  /// **'Could not create rule. Please try again.'**
  String get transactionRulesCreateError;

  /// No description provided for @transactionRulesCreateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Rule created'**
  String get transactionRulesCreateSuccess;

  /// No description provided for @transactionRulesDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete rule. Please try again.'**
  String get transactionRulesDeleteError;

  /// No description provided for @transactionRulesDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Rule deleted'**
  String get transactionRulesDeleteSuccess;

  /// No description provided for @transactionRulesToggleError.
  ///
  /// In en, this message translates to:
  /// **'Could not update rule. Please try again.'**
  String get transactionRulesToggleError;

  /// No description provided for @transactionRulesEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get transactionRulesEnabled;

  /// No description provided for @transactionRulesDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get transactionRulesDisabled;

  /// No description provided for @transactionRulesTotalCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 total} other{{count} total}}'**
  String transactionRulesTotalCount(int count);

  /// No description provided for @transactionRulesAutoAssigned.
  ///
  /// In en, this message translates to:
  /// **'Auto-assigned by rule'**
  String get transactionRulesAutoAssigned;

  /// No description provided for @transferToAccount.
  ///
  /// In en, this message translates to:
  /// **'To Account'**
  String get transferToAccount;

  /// No description provided for @undoAction.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoAction;

  /// No description provided for @undoDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restored successfully'**
  String get undoDeleteSuccess;

  /// No description provided for @undoDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not restore. Please try again.'**
  String get undoDeleteError;

  /// No description provided for @transactionSortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get transactionSortTitle;

  /// No description provided for @transactionSortDateDesc.
  ///
  /// In en, this message translates to:
  /// **'Date (newest first)'**
  String get transactionSortDateDesc;

  /// No description provided for @transactionSortDateAsc.
  ///
  /// In en, this message translates to:
  /// **'Date (oldest first)'**
  String get transactionSortDateAsc;

  /// No description provided for @transactionSortAmountDesc.
  ///
  /// In en, this message translates to:
  /// **'Amount (highest first)'**
  String get transactionSortAmountDesc;

  /// No description provided for @transactionSortAmountAsc.
  ///
  /// In en, this message translates to:
  /// **'Amount (lowest first)'**
  String get transactionSortAmountAsc;

  /// No description provided for @transactionSortDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (A-Z)'**
  String get transactionSortDescription;

  /// No description provided for @tabPlan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get tabPlan;

  /// No description provided for @tabAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get tabAccounts;

  /// No description provided for @tabAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get tabAdd;

  /// No description provided for @tabReflect.
  ///
  /// In en, this message translates to:
  /// **'Reflect'**
  String get tabReflect;

  /// No description provided for @tabMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// No description provided for @addTransactionSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransactionSheetTitle;

  /// No description provided for @addTransactionIncome.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addTransactionIncome;

  /// No description provided for @addTransactionExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addTransactionExpense;

  /// No description provided for @addTransactionTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get addTransactionTransfer;

  /// No description provided for @moreScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreScreenTitle;

  /// No description provided for @moreRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring Transactions'**
  String get moreRecurring;

  /// No description provided for @morePayees.
  ///
  /// In en, this message translates to:
  /// **'Payees'**
  String get morePayees;

  /// No description provided for @moreRules.
  ///
  /// In en, this message translates to:
  /// **'Transaction Rules'**
  String get moreRules;

  /// No description provided for @moreImport.
  ///
  /// In en, this message translates to:
  /// **'Import Transactions'**
  String get moreImport;

  /// No description provided for @moreSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get moreSettings;

  /// No description provided for @accountSettingsUnavailableHint.
  ///
  /// In en, this message translates to:
  /// **'Currently unavailable in this build.'**
  String get accountSettingsUnavailableHint;

  /// No description provided for @accountSettingsReadOnlyNotice.
  ///
  /// In en, this message translates to:
  /// **'Account settings are read-only in this build. Profile, login method, and security updates are unavailable.'**
  String get accountSettingsReadOnlyNotice;

  /// No description provided for @accountSettingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get accountSettingsProfile;

  /// No description provided for @accountSettingsFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get accountSettingsFirstName;

  /// No description provided for @accountSettingsUnavailableFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Unavailable in this build'**
  String get accountSettingsUnavailableFieldHint;

  /// No description provided for @accountSettingsSaveUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Save (Unavailable)'**
  String get accountSettingsSaveUnavailable;

  /// No description provided for @accountSettingsLoginMethods.
  ///
  /// In en, this message translates to:
  /// **'Login Methods'**
  String get accountSettingsLoginMethods;

  /// No description provided for @accountSettingsEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Email & Password'**
  String get accountSettingsEmailPassword;

  /// No description provided for @accountSettingsChangeEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Change Email & Password'**
  String get accountSettingsChangeEmailPassword;

  /// No description provided for @accountSettingsSocialLoginUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Apple and Google login method changes are unavailable in this build.'**
  String get accountSettingsSocialLoginUnavailable;

  /// No description provided for @accountSettingsTwoStepVerification.
  ///
  /// In en, this message translates to:
  /// **'Two-Step Verification'**
  String get accountSettingsTwoStepVerification;

  /// No description provided for @accountSettingsTwoStepHint.
  ///
  /// In en, this message translates to:
  /// **'Increase your OpenBudget login security by adding a second method of login.'**
  String get accountSettingsTwoStepHint;

  /// No description provided for @accountSettingsSetUp.
  ///
  /// In en, this message translates to:
  /// **'Set Up'**
  String get accountSettingsSetUp;

  /// No description provided for @accountSettingsDeleteSectionHint.
  ///
  /// In en, this message translates to:
  /// **'Account deletion is currently unavailable in this build. Open this page to review status and availability.'**
  String get accountSettingsDeleteSectionHint;

  /// No description provided for @accountSettingsDeleteUnavailableHint.
  ///
  /// In en, this message translates to:
  /// **'No account data can be removed from this app yet.'**
  String get accountSettingsDeleteUnavailableHint;

  /// No description provided for @settingsAccountsOverviewHint.
  ///
  /// In en, this message translates to:
  /// **'View and organize every account in your budget.'**
  String get settingsAccountsOverviewHint;

  /// No description provided for @settingsAddAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Add manual accounts, bank links, or wallets.'**
  String get settingsAddAccountHint;

  /// No description provided for @settingsManageBankConnectionsHint.
  ///
  /// In en, this message translates to:
  /// **'Connect Plaid banks or add Solana wallets.'**
  String get settingsManageBankConnectionsHint;

  /// No description provided for @deleteAccountUnavailableNotice.
  ///
  /// In en, this message translates to:
  /// **'Account deletion is currently unavailable in this build. No account or plan data can be removed from this screen.'**
  String get deleteAccountUnavailableNotice;

  /// No description provided for @deleteAccountUnavailableHint.
  ///
  /// In en, this message translates to:
  /// **'Delete requests are disabled until backend account deletion is available.'**
  String get deleteAccountUnavailableHint;

  /// No description provided for @deleteAccountUnavailableButton.
  ///
  /// In en, this message translates to:
  /// **'Delete Account (Unavailable)'**
  String get deleteAccountUnavailableButton;

  /// No description provided for @transactionCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get transactionCategoryLabel;

  /// No description provided for @transactionAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get transactionAccountLabel;

  /// No description provided for @transactionDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get transactionDateLabel;

  /// No description provided for @addAccountConnectWallet.
  ///
  /// In en, this message translates to:
  /// **'Connect Solana Wallet'**
  String get addAccountConnectWallet;

  /// No description provided for @addAccountUnlinkedTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Unlinked Account'**
  String get addAccountUnlinkedTitle;

  /// No description provided for @addAccountSelectAccountType.
  ///
  /// In en, this message translates to:
  /// **'Select Account Type'**
  String get addAccountSelectAccountType;

  /// No description provided for @addAccountSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Added'**
  String get addAccountSuccessTitle;

  /// No description provided for @addAccountSuccessHeadline.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get addAccountSuccessHeadline;

  /// No description provided for @addAccountSuccessAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Add Another'**
  String get addAccountSuccessAddAnother;

  /// No description provided for @addAccountSelectTypePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Select account type...'**
  String get addAccountSelectTypePlaceholder;

  /// No description provided for @addAccountLoadingInstitutions.
  ///
  /// In en, this message translates to:
  /// **'Loading institutions...'**
  String get addAccountLoadingInstitutions;

  /// No description provided for @addAccountConnectWalletButton.
  ///
  /// In en, this message translates to:
  /// **'Connect Wallet'**
  String get addAccountConnectWalletButton;

  /// No description provided for @dialogNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get dialogNext;

  /// No description provided for @loadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingTitle;

  /// No description provided for @loadingHint.
  ///
  /// In en, this message translates to:
  /// **'This might take a few seconds.'**
  String get loadingHint;

  /// No description provided for @addAccountPopularOptions.
  ///
  /// In en, this message translates to:
  /// **'Popular Options'**
  String get addAccountPopularOptions;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search Results'**
  String get searchResults;

  /// No description provided for @addAccountSearchForBank.
  ///
  /// In en, this message translates to:
  /// **'Search for your bank'**
  String get addAccountSearchForBank;

  /// No description provided for @addAccountSearchByInstitutionName.
  ///
  /// In en, this message translates to:
  /// **'Search by institution name'**
  String get addAccountSearchByInstitutionName;

  /// No description provided for @addAccountSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by institution name or web address (URL)'**
  String get addAccountSearchHint;

  /// No description provided for @addAccountNoInstitutionsFound.
  ///
  /// In en, this message translates to:
  /// **'No institutions found. Try another name or add an unlinked account.'**
  String get addAccountNoInstitutionsFound;

  /// No description provided for @orText.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orText;

  /// No description provided for @addAccountAddUnlinked.
  ///
  /// In en, this message translates to:
  /// **'Add an Unlinked Account'**
  String get addAccountAddUnlinked;

  /// No description provided for @addAccountWalletConnectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect a Solana wallet in read-only mode. OpenBudget imports native SPL balances and keeps fiat valuation synced.'**
  String get addAccountWalletConnectionDescription;

  /// No description provided for @addAccountWalletAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Wallet Address'**
  String get addAccountWalletAddressLabel;

  /// No description provided for @addAccountWalletAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Paste Solana wallet address'**
  String get addAccountWalletAddressHint;

  /// No description provided for @addAccountWalletLabelOptional.
  ///
  /// In en, this message translates to:
  /// **'Wallet Label (optional)'**
  String get addAccountWalletLabelOptional;

  /// No description provided for @addAccountWalletLabelHint.
  ///
  /// In en, this message translates to:
  /// **'My Solana Wallet'**
  String get addAccountWalletLabelHint;

  /// No description provided for @addAccountWalletIncludeInBudgetTotals.
  ///
  /// In en, this message translates to:
  /// **'Include in budget totals'**
  String get addAccountWalletIncludeInBudgetTotals;

  /// No description provided for @addAccountWalletIntro.
  ///
  /// In en, this message translates to:
  /// **'Add your Solana wallet to track transfers, swaps, and holdings in one place.'**
  String get addAccountWalletIntro;

  /// No description provided for @addAccountUnlinkedIntro.
  ///
  /// In en, this message translates to:
  /// **'Bank connections are currently unavailable in this build, so let\'s set up an unlinked account.'**
  String get addAccountUnlinkedIntro;

  /// No description provided for @addAccountNicknameQuestion.
  ///
  /// In en, this message translates to:
  /// **'Give it a nickname'**
  String get addAccountNicknameQuestion;

  /// No description provided for @addAccountNicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter nickname'**
  String get addAccountNicknameHint;

  /// No description provided for @addAccountTypeQuestion.
  ///
  /// In en, this message translates to:
  /// **'What type of account are you adding?'**
  String get addAccountTypeQuestion;

  /// No description provided for @addAccountWalletAutoSyncHint.
  ///
  /// In en, this message translates to:
  /// **'OpenBudget will auto-sync transactions and holdings after wallet setup. You can tag and categorize activity in account details.'**
  String get addAccountWalletAutoSyncHint;

  /// No description provided for @addAccountWalletAddressQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is your Solana wallet address?'**
  String get addAccountWalletAddressQuestion;

  /// No description provided for @addAccountWalletAddressExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5xQf...w8bP'**
  String get addAccountWalletAddressExample;

  /// No description provided for @addAccountWalletPublicAddressOnly.
  ///
  /// In en, this message translates to:
  /// **'Only public wallet addresses are supported.'**
  String get addAccountWalletPublicAddressOnly;

  /// No description provided for @addAccountBalanceQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is your current account balance?'**
  String get addAccountBalanceQuestion;

  /// No description provided for @addAccountBalanceExample.
  ///
  /// In en, this message translates to:
  /// **'5000'**
  String get addAccountBalanceExample;

  /// No description provided for @addAccountSectionCashAccounts.
  ///
  /// In en, this message translates to:
  /// **'Cash Accounts'**
  String get addAccountSectionCashAccounts;

  /// No description provided for @addAccountSectionCashAccountsHint.
  ///
  /// In en, this message translates to:
  /// **'Cash accounts hold funds you already own and can spend immediately.'**
  String get addAccountSectionCashAccountsHint;

  /// No description provided for @addAccountSectionCreditAccounts.
  ///
  /// In en, this message translates to:
  /// **'Credit Accounts'**
  String get addAccountSectionCreditAccounts;

  /// No description provided for @addAccountSectionCreditAccountsHint.
  ///
  /// In en, this message translates to:
  /// **'A credit account lets you spend borrowed money that you\'ll need to repay later, often with interest.'**
  String get addAccountSectionCreditAccountsHint;

  /// No description provided for @addAccountTypeLineOfCredit.
  ///
  /// In en, this message translates to:
  /// **'Line of Credit'**
  String get addAccountTypeLineOfCredit;

  /// No description provided for @addAccountSectionMortgagesAndLoans.
  ///
  /// In en, this message translates to:
  /// **'Mortgages and Loans'**
  String get addAccountSectionMortgagesAndLoans;

  /// No description provided for @addAccountSectionMortgagesAndLoansHint.
  ///
  /// In en, this message translates to:
  /// **'Accounts that have an outstanding balance you\'re currently paying off, and aren\'t spending from.'**
  String get addAccountSectionMortgagesAndLoansHint;

  /// No description provided for @addAccountTypeMortgage.
  ///
  /// In en, this message translates to:
  /// **'Mortgage'**
  String get addAccountTypeMortgage;

  /// No description provided for @addAccountTypeAutoLoan.
  ///
  /// In en, this message translates to:
  /// **'Auto Loan'**
  String get addAccountTypeAutoLoan;

  /// No description provided for @addAccountTypeStudentLoan.
  ///
  /// In en, this message translates to:
  /// **'Student Loan'**
  String get addAccountTypeStudentLoan;

  /// No description provided for @addAccountTypePersonalLoan.
  ///
  /// In en, this message translates to:
  /// **'Personal Loan'**
  String get addAccountTypePersonalLoan;

  /// No description provided for @addAccountTypeMedicalDebt.
  ///
  /// In en, this message translates to:
  /// **'Medical Debt'**
  String get addAccountTypeMedicalDebt;

  /// No description provided for @addAccountTypeOtherDebt.
  ///
  /// In en, this message translates to:
  /// **'Other Debt'**
  String get addAccountTypeOtherDebt;

  /// No description provided for @addAccountSectionTrackingAccounts.
  ///
  /// In en, this message translates to:
  /// **'Tracking Accounts'**
  String get addAccountSectionTrackingAccounts;

  /// No description provided for @addAccountSectionTrackingAccountsHint.
  ///
  /// In en, this message translates to:
  /// **'Accounts that hold money you don\'t plan to spend soon, such as investments or loans.'**
  String get addAccountSectionTrackingAccountsHint;

  /// No description provided for @addAccountTypeAssetExample.
  ///
  /// In en, this message translates to:
  /// **'Asset (e.g. Investment)'**
  String get addAccountTypeAssetExample;

  /// No description provided for @addAccountTypeLiability.
  ///
  /// In en, this message translates to:
  /// **'Liability'**
  String get addAccountTypeLiability;

  /// No description provided for @addAccountSectionDigitalAssets.
  ///
  /// In en, this message translates to:
  /// **'Digital Assets'**
  String get addAccountSectionDigitalAssets;

  /// No description provided for @addAccountSectionDigitalAssetsHint.
  ///
  /// In en, this message translates to:
  /// **'Track a Solana wallet with automatic transaction history and asset valuations.'**
  String get addAccountSectionDigitalAssetsHint;

  /// No description provided for @addAccountTypeSolanaWallet.
  ///
  /// In en, this message translates to:
  /// **'Solana Wallet'**
  String get addAccountTypeSolanaWallet;

  /// No description provided for @accountEditNicknameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Nickname'**
  String get accountEditNicknameLabel;

  /// No description provided for @accountEditNicknameHint.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get accountEditNicknameHint;

  /// No description provided for @accountEditNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Notes'**
  String get accountEditNotesLabel;

  /// No description provided for @accountEditNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Enter a memo...'**
  String get accountEditNotesHint;

  /// No description provided for @accountEditAdjustmentHint.
  ///
  /// In en, this message translates to:
  /// **'An adjustment transaction will be created automatically if you change this amount.'**
  String get accountEditAdjustmentHint;

  /// No description provided for @accountEditBankConnection.
  ///
  /// In en, this message translates to:
  /// **'Bank Connection'**
  String get accountEditBankConnection;

  /// No description provided for @accountEditLinkAccountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Link an Account (Unavailable)'**
  String get accountEditLinkAccountUnavailable;

  /// No description provided for @accountEditLinkAccountUnavailableHint.
  ///
  /// In en, this message translates to:
  /// **'Bank connections are currently unavailable in this build. Add or manage unlinked accounts instead.'**
  String get accountEditLinkAccountUnavailableHint;

  /// No description provided for @accountListAllTransactions.
  ///
  /// In en, this message translates to:
  /// **'All transactions'**
  String get accountListAllTransactions;

  /// No description provided for @accountDetailBudgetAccount.
  ///
  /// In en, this message translates to:
  /// **'Budget Account'**
  String get accountDetailBudgetAccount;

  /// No description provided for @accountDetailTrackingAccount.
  ///
  /// In en, this message translates to:
  /// **'Tracking Account'**
  String get accountDetailTrackingAccount;

  /// No description provided for @accountDetailSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get accountDetailSelect;

  /// No description provided for @accountDetailHideReconciled.
  ///
  /// In en, this message translates to:
  /// **'Hide Reconciled'**
  String get accountDetailHideReconciled;

  /// No description provided for @accountDetailLinkAccountUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Link Account (Unavailable)'**
  String get accountDetailLinkAccountUnavailable;

  /// No description provided for @accountDetailLoanOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get accountDetailLoanOverview;

  /// No description provided for @accountDetailLoanActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get accountDetailLoanActivity;

  /// No description provided for @accountDetailLoanBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get accountDetailLoanBalance;

  /// No description provided for @accountDetailLoanPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get accountDetailLoanPaid;

  /// No description provided for @accountDetailLoanTotalBorrowed.
  ///
  /// In en, this message translates to:
  /// **'Total Borrowed'**
  String get accountDetailLoanTotalBorrowed;

  /// No description provided for @accountDetailLoanPayoffOverview.
  ///
  /// In en, this message translates to:
  /// **'Loan Payoff Overview'**
  String get accountDetailLoanPayoffOverview;

  /// No description provided for @accountDetailLoanOneMonth.
  ///
  /// In en, this message translates to:
  /// **'Account Detail Loan One Month'**
  String get accountDetailLoanOneMonth;

  /// No description provided for @accountDetailLoanMonthlyTarget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Target'**
  String get accountDetailLoanMonthlyTarget;

  /// No description provided for @accountDetailLoanDueEvery.
  ///
  /// In en, this message translates to:
  /// **'Due Every'**
  String get accountDetailLoanDueEvery;

  /// No description provided for @accountDetailLoanMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get accountDetailLoanMonthly;

  /// No description provided for @accountDetailLoanDebtFreeDate.
  ///
  /// In en, this message translates to:
  /// **'Debt Free Date'**
  String get accountDetailLoanDebtFreeDate;

  /// No description provided for @accountDetailLoanCreateTarget.
  ///
  /// In en, this message translates to:
  /// **'Create Target'**
  String get accountDetailLoanCreateTarget;

  /// No description provided for @accountDetailLoanEditTarget.
  ///
  /// In en, this message translates to:
  /// **'Edit Target'**
  String get accountDetailLoanEditTarget;

  /// No description provided for @accountDetailLoanDetails.
  ///
  /// In en, this message translates to:
  /// **'Loan Details'**
  String get accountDetailLoanDetails;

  /// No description provided for @accountDetailLoanInterestRate.
  ///
  /// In en, this message translates to:
  /// **'Interest Rate'**
  String get accountDetailLoanInterestRate;

  /// No description provided for @accountDetailLoanInterestRateValue.
  ///
  /// In en, this message translates to:
  /// **'3%'**
  String get accountDetailLoanInterestRateValue;

  /// No description provided for @accountDetailLoanMonthlyMinimum.
  ///
  /// In en, this message translates to:
  /// **'Monthly Minimum'**
  String get accountDetailLoanMonthlyMinimum;

  /// No description provided for @accountDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Account not found.'**
  String get accountDetailNotFound;

  /// No description provided for @accountDetailWalletLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load wallet metadata.'**
  String get accountDetailWalletLoadError;

  /// No description provided for @accountDetailWalletNotAttached.
  ///
  /// In en, this message translates to:
  /// **'No Solana wallet is attached to this account yet.'**
  String get accountDetailWalletNotAttached;

  /// No description provided for @accountDetailWalletSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Wallet sync failed. Check server logs.'**
  String get accountDetailWalletSyncFailed;

  /// No description provided for @accountDetailWalletSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get accountDetailWalletSyncing;

  /// No description provided for @accountDetailWalletSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get accountDetailWalletSync;

  /// No description provided for @accountDetailWalletEstimatedValue.
  ///
  /// In en, this message translates to:
  /// **'Estimated Value'**
  String get accountDetailWalletEstimatedValue;

  /// No description provided for @accountDetailWalletAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Wallet address copied.'**
  String get accountDetailWalletAddressCopied;

  /// No description provided for @accountDetailWalletCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get accountDetailWalletCopy;

  /// No description provided for @accountDetailWalletFungibleAssets.
  ///
  /// In en, this message translates to:
  /// **'Fungible Assets'**
  String get accountDetailWalletFungibleAssets;

  /// No description provided for @accountDetailWalletNftAssets.
  ///
  /// In en, this message translates to:
  /// **'NFT Assets'**
  String get accountDetailWalletNftAssets;

  /// No description provided for @accountDetailWalletValuationCoverage.
  ///
  /// In en, this message translates to:
  /// **'Valuation Coverage'**
  String get accountDetailWalletValuationCoverage;

  /// No description provided for @accountDetailWalletUnpricedAssets.
  ///
  /// In en, this message translates to:
  /// **'Unpriced Assets'**
  String get accountDetailWalletUnpricedAssets;

  /// No description provided for @accountDetailWalletUnrealizedPnl.
  ///
  /// In en, this message translates to:
  /// **'Unrealized P&L'**
  String get accountDetailWalletUnrealizedPnl;

  /// No description provided for @accountDetailWalletRealizedPnl.
  ///
  /// In en, this message translates to:
  /// **'Realized P&L'**
  String get accountDetailWalletRealizedPnl;

  /// No description provided for @accountDetailWalletTaggedTransactions.
  ///
  /// In en, this message translates to:
  /// **'Tagged Transactions'**
  String get accountDetailWalletTaggedTransactions;

  /// No description provided for @accountDetailWalletLastActivity.
  ///
  /// In en, this message translates to:
  /// **'Last Activity'**
  String get accountDetailWalletLastActivity;

  /// No description provided for @accountDetailWalletNoActivity.
  ///
  /// In en, this message translates to:
  /// **'No activity'**
  String get accountDetailWalletNoActivity;

  /// No description provided for @accountDetailWalletTaxYearPnl.
  ///
  /// In en, this message translates to:
  /// **'Tax Year P&L'**
  String get accountDetailWalletTaxYearPnl;

  /// No description provided for @accountDetailWalletEstimated.
  ///
  /// In en, this message translates to:
  /// **'(estimated)'**
  String get accountDetailWalletEstimated;

  /// No description provided for @accountDetailWalletTaxYearLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load tax-year summary.'**
  String get accountDetailWalletTaxYearLoadError;

  /// No description provided for @accountDetailWalletNoDisposalsYet.
  ///
  /// In en, this message translates to:
  /// **'No disposals yet'**
  String get accountDetailWalletNoDisposalsYet;

  /// No description provided for @accountDetailWalletNoDisposalsHint.
  ///
  /// In en, this message translates to:
  /// **'Tax-year summaries will appear after taxable disposal activity is detected.'**
  String get accountDetailWalletNoDisposalsHint;

  /// No description provided for @accountDetailWalletHoldings.
  ///
  /// In en, this message translates to:
  /// **'Holdings'**
  String get accountDetailWalletHoldings;

  /// No description provided for @accountDetailWalletHoldingsHint.
  ///
  /// In en, this message translates to:
  /// **'Token balances with current valuation and detected programs.'**
  String get accountDetailWalletHoldingsHint;

  /// No description provided for @accountDetailWalletHideDustAssets.
  ///
  /// In en, this message translates to:
  /// **'Hide dust assets (< \$0.01)'**
  String get accountDetailWalletHideDustAssets;

  /// No description provided for @accountDetailWalletHoldingsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load holdings.'**
  String get accountDetailWalletHoldingsLoadError;

  /// No description provided for @accountDetailWalletNoHoldingsFound.
  ///
  /// In en, this message translates to:
  /// **'No holdings found'**
  String get accountDetailWalletNoHoldingsFound;

  /// No description provided for @accountDetailWalletNoHoldingsHint.
  ///
  /// In en, this message translates to:
  /// **'Run a sync to fetch tokens and NFTs for this wallet.'**
  String get accountDetailWalletNoHoldingsHint;

  /// No description provided for @accountDetailWalletOnlyDustAssets.
  ///
  /// In en, this message translates to:
  /// **'Only dust assets found'**
  String get accountDetailWalletOnlyDustAssets;

  /// No description provided for @accountDetailWalletOnlyDustAssetsHint.
  ///
  /// In en, this message translates to:
  /// **'Turn off the dust filter to inspect very small-value token balances.'**
  String get accountDetailWalletOnlyDustAssetsHint;

  /// No description provided for @accountDetailWalletTransactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get accountDetailWalletTransactionHistory;

  /// No description provided for @accountDetailWalletTransactionHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Parsed activity with program context and editable labels.'**
  String get accountDetailWalletTransactionHistoryHint;

  /// No description provided for @accountDetailWalletTransactionSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search description, category, tags, memo'**
  String get accountDetailWalletTransactionSearchHint;

  /// No description provided for @accountDetailWalletNeedsCategory.
  ///
  /// In en, this message translates to:
  /// **'Needs category'**
  String get accountDetailWalletNeedsCategory;

  /// No description provided for @accountDetailWalletTransactionsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load transactions.'**
  String get accountDetailWalletTransactionsLoadError;

  /// No description provided for @accountDetailWalletNoTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get accountDetailWalletNoTransactionsYet;

  /// No description provided for @accountDetailWalletNoTransactionsHint.
  ///
  /// In en, this message translates to:
  /// **'Run a sync to import transaction history from the wallet.'**
  String get accountDetailWalletNoTransactionsHint;

  /// No description provided for @accountDetailWalletNoTransactionsMatch.
  ///
  /// In en, this message translates to:
  /// **'No transactions match filters'**
  String get accountDetailWalletNoTransactionsMatch;

  /// No description provided for @accountDetailWalletNoTransactionsMatchHint.
  ///
  /// In en, this message translates to:
  /// **'Adjust search terms or disable the category filter.'**
  String get accountDetailWalletNoTransactionsMatchHint;

  /// No description provided for @accountDetailWalletEditMetadataTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction Metadata'**
  String get accountDetailWalletEditMetadataTitle;

  /// No description provided for @accountDetailWalletTagsCommaSeparated.
  ///
  /// In en, this message translates to:
  /// **'Tags (comma separated)'**
  String get accountDetailWalletTagsCommaSeparated;

  /// No description provided for @accountDetailWalletMetadataUpdated.
  ///
  /// In en, this message translates to:
  /// **'Transaction metadata updated.'**
  String get accountDetailWalletMetadataUpdated;

  /// No description provided for @accountDetailWalletMetadataUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update transaction metadata.'**
  String get accountDetailWalletMetadataUpdateError;

  /// No description provided for @accountDetailWalletNft.
  ///
  /// In en, this message translates to:
  /// **'NFT'**
  String get accountDetailWalletNft;

  /// No description provided for @accountDetailWalletStalePrice.
  ///
  /// In en, this message translates to:
  /// **'Stale price'**
  String get accountDetailWalletStalePrice;

  /// No description provided for @accountDetailWalletUnpriced.
  ///
  /// In en, this message translates to:
  /// **'Unpriced'**
  String get accountDetailWalletUnpriced;

  /// No description provided for @accountDetailWalletNoValuationSource.
  ///
  /// In en, this message translates to:
  /// **'No valuation source'**
  String get accountDetailWalletNoValuationSource;

  /// No description provided for @accountDetailWalletEditMetadataTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit metadata'**
  String get accountDetailWalletEditMetadataTooltip;

  /// No description provided for @accountDetailLoanTarget.
  ///
  /// In en, this message translates to:
  /// **'Loan Target'**
  String get accountDetailLoanTarget;

  /// No description provided for @accountDetailLoanMonthlyPayment.
  ///
  /// In en, this message translates to:
  /// **'Monthly payment'**
  String get accountDetailLoanMonthlyPayment;

  /// No description provided for @accountDetailReconcileMatchQuestion.
  ///
  /// In en, this message translates to:
  /// **'Does this match your bank balance?'**
  String get accountDetailReconcileMatchQuestion;

  /// No description provided for @dialogYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get dialogYes;

  /// No description provided for @dialogNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get dialogNo;

  /// No description provided for @spendingByPayeeMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get spendingByPayeeMonth;

  /// No description provided for @spendingByPayeePreset.
  ///
  /// In en, this message translates to:
  /// **'Preset'**
  String get spendingByPayeePreset;

  /// No description provided for @spendingByPayeePresetRange.
  ///
  /// In en, this message translates to:
  /// **'Preset Range'**
  String get spendingByPayeePresetRange;

  /// No description provided for @editPlanCostToBeMe.
  ///
  /// In en, this message translates to:
  /// **'Cost to Be Me'**
  String get editPlanCostToBeMe;

  /// No description provided for @editPlanMonthlyTargets.
  ///
  /// In en, this message translates to:
  /// **'Monthly Targets'**
  String get editPlanMonthlyTargets;

  /// No description provided for @editPlanMonthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Monthly Income'**
  String get editPlanMonthlyIncome;

  /// No description provided for @editPlanCostPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'What does it cost to be you?'**
  String get editPlanCostPromptTitle;

  /// No description provided for @editPlanCostPromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your targets add up to one simple number: everything you plan to spend and save each month.'**
  String get editPlanCostPromptSubtitle;

  /// No description provided for @editPlanNewGroup.
  ///
  /// In en, this message translates to:
  /// **'New Group'**
  String get editPlanNewGroup;

  /// No description provided for @editPlanReorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get editPlanReorder;

  /// No description provided for @editPlanDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get editPlanDetails;

  /// No description provided for @editPlanCategoryGroupName.
  ///
  /// In en, this message translates to:
  /// **'Category Group Name'**
  String get editPlanCategoryGroupName;

  /// No description provided for @editPlanHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get editPlanHide;

  /// No description provided for @editPlanDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get editPlanDelete;

  /// No description provided for @editPlanHideGroupDialogDescription.
  ///
  /// In en, this message translates to:
  /// **'Hidden categories are moved to a group at the bottom of your plan.'**
  String get editPlanHideGroupDialogDescription;

  /// No description provided for @editPlanHideGroupAndCategories.
  ///
  /// In en, this message translates to:
  /// **'Hide Group and Categories'**
  String get editPlanHideGroupAndCategories;

  /// No description provided for @editPlanCategoryGroupHidden.
  ///
  /// In en, this message translates to:
  /// **'Category group hidden.'**
  String get editPlanCategoryGroupHidden;

  /// No description provided for @editPlanHideGroupError.
  ///
  /// In en, this message translates to:
  /// **'Unable to hide category group.'**
  String get editPlanHideGroupError;

  /// No description provided for @editPlanDeleteGroupError.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete category group.'**
  String get editPlanDeleteGroupError;

  /// No description provided for @editPlanMoveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get editPlanMoveUp;

  /// No description provided for @editPlanMoveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get editPlanMoveDown;

  /// No description provided for @editPlanAddEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Add envelope'**
  String get editPlanAddEnvelope;

  /// No description provided for @editPlanGroupDetails.
  ///
  /// In en, this message translates to:
  /// **'Group details'**
  String get editPlanGroupDetails;

  /// No description provided for @editPlanAddTarget.
  ///
  /// In en, this message translates to:
  /// **'Add Target'**
  String get editPlanAddTarget;

  /// No description provided for @planTitle.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get planTitle;

  /// No description provided for @editPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Plan'**
  String get editPlanTitle;

  /// No description provided for @budgetDetailCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get budgetDetailCategories;

  /// No description provided for @budgetDetailSpotlight.
  ///
  /// In en, this message translates to:
  /// **'Spotlight'**
  String get budgetDetailSpotlight;

  /// No description provided for @budgetDetailCoverOverspendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Cover Overspending'**
  String get budgetDetailCoverOverspendingTitle;

  /// No description provided for @budgetDetailAllOverspendingCovered.
  ///
  /// In en, this message translates to:
  /// **'All overspending is covered.'**
  String get budgetDetailAllOverspendingCovered;

  /// No description provided for @budgetDetailCoverButton.
  ///
  /// In en, this message translates to:
  /// **'Cover'**
  String get budgetDetailCoverButton;

  /// No description provided for @budgetDetailCovering.
  ///
  /// In en, this message translates to:
  /// **'Covering...'**
  String get budgetDetailCovering;

  /// No description provided for @reviewTransactionsUpdateCategoryError.
  ///
  /// In en, this message translates to:
  /// **'Could not update transaction category.'**
  String get reviewTransactionsUpdateCategoryError;

  /// No description provided for @reviewTransactionsDeleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete selected'**
  String get reviewTransactionsDeleteSelected;

  /// No description provided for @reviewTransactionsNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No Transactions'**
  String get reviewTransactionsNoTransactions;

  /// No description provided for @reviewTransactionsSingleNewTransaction.
  ///
  /// In en, this message translates to:
  /// **'1 New Transaction'**
  String get reviewTransactionsSingleNewTransaction;

  /// No description provided for @reviewTransactionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Approve or categorize new transactions'**
  String get reviewTransactionsSubtitle;

  /// No description provided for @reviewTransactionsAllDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re All Done!'**
  String get reviewTransactionsAllDoneTitle;

  /// No description provided for @reviewTransactionsAllDoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Return to Accounts to see all of your transactions.'**
  String get reviewTransactionsAllDoneSubtitle;

  /// No description provided for @reviewTransactionsUncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get reviewTransactionsUncategorized;

  /// No description provided for @reviewTransactionsSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get reviewTransactionsSelectCategory;

  /// No description provided for @reviewTransactionsApprove.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get reviewTransactionsApprove;

  /// No description provided for @reviewTransactionsCategorize.
  ///
  /// In en, this message translates to:
  /// **'Categorize'**
  String get reviewTransactionsCategorize;

  /// No description provided for @reviewTransactionsClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get reviewTransactionsClear;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @setGoalCadenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get setGoalCadenceWeekly;

  /// No description provided for @setGoalCadenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get setGoalCadenceMonthly;

  /// No description provided for @setGoalCadenceYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get setGoalCadenceYearly;

  /// No description provided for @setGoalCadenceCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get setGoalCadenceCustom;

  /// No description provided for @setGoalAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get setGoalAmount;

  /// No description provided for @setGoalINeed.
  ///
  /// In en, this message translates to:
  /// **'I need'**
  String get setGoalINeed;

  /// No description provided for @setGoalBy.
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get setGoalBy;

  /// No description provided for @setGoalLastDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Day of the Month'**
  String get setGoalLastDayOfMonth;

  /// No description provided for @setGoalNextMonthINeedTo.
  ///
  /// In en, this message translates to:
  /// **'Next month I want to'**
  String get setGoalNextMonthINeedTo;

  /// No description provided for @setGoalIWantTo.
  ///
  /// In en, this message translates to:
  /// **'I want to'**
  String get setGoalIWantTo;

  /// No description provided for @setGoalDueOn.
  ///
  /// In en, this message translates to:
  /// **'Due on'**
  String get setGoalDueOn;

  /// No description provided for @setGoalRepeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get setGoalRepeats;

  /// No description provided for @setGoalEvery.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get setGoalEvery;

  /// No description provided for @setGoalMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get setGoalMonth;

  /// No description provided for @setGoalYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get setGoalYear;

  /// No description provided for @setGoalSaveTarget.
  ///
  /// In en, this message translates to:
  /// **'Save Target'**
  String get setGoalSaveTarget;

  /// No description provided for @settingsPlanCurrencyDetail.
  ///
  /// In en, this message translates to:
  /// **'Plan currency: {currencyCode}'**
  String settingsPlanCurrencyDetail(String currencyCode);

  /// No description provided for @settingsDisplayCurrencyDetail.
  ///
  /// In en, this message translates to:
  /// **'Display currency: {currencyCode}'**
  String settingsDisplayCurrencyDetail(String currencyCode);

  /// No description provided for @settingsOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner: {ownerLabel}'**
  String settingsOwner(String ownerLabel);

  /// No description provided for @settingsUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated: {lastUpdatedLabel}'**
  String settingsUpdated(String lastUpdatedLabel);

  /// No description provided for @addAccountSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'{accountTypeLabel} account added to OpenBudget.'**
  String addAccountSuccessMessage(String accountTypeLabel);

  /// No description provided for @accountDetailLoanPaidOff.
  ///
  /// In en, this message translates to:
  /// **'{percent}%\\nPaid Off'**
  String accountDetailLoanPaidOff(String percent);

  /// No description provided for @accountDetailLoanPayoffEstimate.
  ///
  /// In en, this message translates to:
  /// **'You\'ll pay off your loan in {duration} if you pay the minimum every month.'**
  String accountDetailLoanPayoffEstimate(String duration);

  /// No description provided for @accountDetailLoanManyMonths.
  ///
  /// In en, this message translates to:
  /// **'{count} months'**
  String accountDetailLoanManyMonths(int count);

  /// No description provided for @accountDetailLoanInMonth.
  ///
  /// In en, this message translates to:
  /// **'In {month}'**
  String accountDetailLoanInMonth(int month);

  /// No description provided for @accountDetailWalletSyncSummary.
  ///
  /// In en, this message translates to:
  /// **'Synced {transactions} transactions and {holdings} holdings. Coverage {coveredHoldings}/{holdingCount}{coveragePercentText}, {unpricedHoldings} unpriced. NFTs {coveredNfts}/{nftCount}, {unpricedNfts} unpriced.'**
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
  );

  /// No description provided for @accountDetailWalletTxCount.
  ///
  /// In en, this message translates to:
  /// **'{transactions} tx'**
  String accountDetailWalletTxCount(int transactions);

  /// No description provided for @accountDetailWalletSuggestedCategory.
  ///
  /// In en, this message translates to:
  /// **'Suggested: {category}'**
  String accountDetailWalletSuggestedCategory(String category);

  /// No description provided for @accountDetailWalletUnits.
  ///
  /// In en, this message translates to:
  /// **'{units} units'**
  String accountDetailWalletUnits(String units);

  /// No description provided for @accountDetailWalletConfidence.
  ///
  /// In en, this message translates to:
  /// **'{confidence} confidence'**
  String accountDetailWalletConfidence(String confidence);

  /// No description provided for @accountDetailWalletBasis.
  ///
  /// In en, this message translates to:
  /// **'Basis {amount}'**
  String accountDetailWalletBasis(String amount);

  /// No description provided for @accountDetailWalletPnl.
  ///
  /// In en, this message translates to:
  /// **'P&L {value}{suffix}'**
  String accountDetailWalletPnl(String value, String suffix);

  /// No description provided for @accountDetailWalletPricePerToken.
  ///
  /// In en, this message translates to:
  /// **'@ {amount}'**
  String accountDetailWalletPricePerToken(String amount);

  /// No description provided for @accountDetailWalletPnlValue.
  ///
  /// In en, this message translates to:
  /// **'P&L {value}'**
  String accountDetailWalletPnlValue(String value);

  /// No description provided for @accountDetailWalletTaxYear.
  ///
  /// In en, this message translates to:
  /// **'Tax {year}'**
  String accountDetailWalletTaxYear(int year);

  /// No description provided for @accountDetailReconcileMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Your cleared balance in OpenBudget is {balance}'**
  String accountDetailReconcileMatchTitle(String balance);

  /// No description provided for @spendingByPayeeLastMonths.
  ///
  /// In en, this message translates to:
  /// **'Last {count} Months'**
  String spendingByPayeeLastMonths(int count);

  /// No description provided for @editPlanEnvelopeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 envelope} other{{count} envelopes}}'**
  String editPlanEnvelopeCount(int count);

  /// No description provided for @editPlanDeleteCategoryGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete category group \"{groupName}\"?\\n\\n{envelopeSummary}\\n{allocated} allocated'**
  String editPlanDeleteCategoryGroupConfirm(
    String groupName,
    String envelopeSummary,
    String allocated,
  );

  /// No description provided for @budgetDetailNeedsToCover.
  ///
  /// In en, this message translates to:
  /// **'Needs {amount} to get back to zero'**
  String budgetDetailNeedsToCover(String amount);

  /// No description provided for @budgetDetailCoverOverspent.
  ///
  /// In en, this message translates to:
  /// **'Cover {count} overspent {count, plural, =1{Category} other{Categories}}'**
  String budgetDetailCoverOverspent(int count);

  /// No description provided for @reviewTransactionsSelectedTitle.
  ///
  /// In en, this message translates to:
  /// **'{count} Selected'**
  String reviewTransactionsSelectedTitle(int count);

  /// No description provided for @reviewTransactionsNewTransactions.
  ///
  /// In en, this message translates to:
  /// **'{count} New Transactions'**
  String reviewTransactionsNewTransactions(int count);

  /// No description provided for @reviewTransactionsSelectedAmount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected • {amount}'**
  String reviewTransactionsSelectedAmount(int count, String amount);

  /// No description provided for @setGoalSetAsideAnother.
  ///
  /// In en, this message translates to:
  /// **'Set aside another {amount}'**
  String setGoalSetAsideAnother(String amount);

  /// No description provided for @routerPageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Page not found: {error}'**
  String routerPageNotFound(String error);

  /// No description provided for @editPlanLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load plan setup.'**
  String get editPlanLoadError;

  /// No description provided for @budgetDetailCoverOverspendingError.
  ///
  /// In en, this message translates to:
  /// **'Could not cover overspending.'**
  String get budgetDetailCoverOverspendingError;

  /// No description provided for @accountsMoreActions.
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get accountsMoreActions;

  /// No description provided for @accountsDismissNotification.
  ///
  /// In en, this message translates to:
  /// **'Dismiss notification'**
  String get accountsDismissNotification;

  /// No description provided for @accountsClosedBadge.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get accountsClosedBadge;

  /// No description provided for @accountsSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get accountsSynced;

  /// No description provided for @accountsNeedsAttention.
  ///
  /// In en, this message translates to:
  /// **'Needs attention'**
  String get accountsNeedsAttention;

  /// No description provided for @accountsBackAction.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get accountsBackAction;

  /// No description provided for @accountsCloseAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get accountsCloseAction;

  /// No description provided for @accountsShowUnclearedTransactions.
  ///
  /// In en, this message translates to:
  /// **'Show {count} uncleared transactions'**
  String accountsShowUnclearedTransactions(int count);

  /// No description provided for @accountsNoLoanActivity.
  ///
  /// In en, this message translates to:
  /// **'No loan activity yet'**
  String get accountsNoLoanActivity;

  /// No description provided for @accountsLoanPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get accountsLoanPayments;

  /// No description provided for @accountsLoanOtherActivity.
  ///
  /// In en, this message translates to:
  /// **'Other Activity'**
  String get accountsLoanOtherActivity;

  /// No description provided for @accountsUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get accountsUnknown;

  /// No description provided for @accountsNoHoldings.
  ///
  /// In en, this message translates to:
  /// **'No holdings'**
  String get accountsNoHoldings;

  /// No description provided for @accountsTaxYear.
  ///
  /// In en, this message translates to:
  /// **'Tax {year}'**
  String accountsTaxYear(int year);

  /// No description provided for @accountsTaxableTransactions.
  ///
  /// In en, this message translates to:
  /// **'{count} taxable tx'**
  String accountsTaxableTransactions(int count);

  /// No description provided for @accountsProceeds.
  ///
  /// In en, this message translates to:
  /// **'Proceeds {amount}'**
  String accountsProceeds(String amount);

  /// No description provided for @accountsBasis.
  ///
  /// In en, this message translates to:
  /// **'Basis {amount}'**
  String accountsBasis(String amount);

  /// No description provided for @accountsUnknownProgram.
  ///
  /// In en, this message translates to:
  /// **'Unknown program'**
  String get accountsUnknownProgram;

  /// No description provided for @accountsSuggestedSwaps.
  ///
  /// In en, this message translates to:
  /// **'Swaps'**
  String get accountsSuggestedSwaps;

  /// No description provided for @accountsSuggestedStaking.
  ///
  /// In en, this message translates to:
  /// **'Staking'**
  String get accountsSuggestedStaking;

  /// No description provided for @accountsSuggestedNft.
  ///
  /// In en, this message translates to:
  /// **'NFT'**
  String get accountsSuggestedNft;

  /// No description provided for @accountsSuggestedLending.
  ///
  /// In en, this message translates to:
  /// **'Lending'**
  String get accountsSuggestedLending;

  /// No description provided for @accountsSuggestedIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get accountsSuggestedIncome;

  /// No description provided for @accountsSuggestedTransfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get accountsSuggestedTransfers;

  /// No description provided for @accountsLinkUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Bank connections are currently unavailable in this build. Use unlinked accounts instead.'**
  String get accountsLinkUnavailableMessage;

  /// No description provided for @accountsToggleBalanceSign.
  ///
  /// In en, this message translates to:
  /// **'Toggle positive or negative balance'**
  String get accountsToggleBalanceSign;

  /// No description provided for @accountsLinkedMobileOnly.
  ///
  /// In en, this message translates to:
  /// **'Linked connections are only available on iOS/Android right now. Add an unlinked account instead.'**
  String get accountsLinkedMobileOnly;

  /// No description provided for @accountsLinkedNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Linked connections for \"{institution}\" were not completed. Add an unlinked account instead.'**
  String accountsLinkedNotCompleted(String institution);

  /// No description provided for @accountsLinkedNothingImported.
  ///
  /// In en, this message translates to:
  /// **'No accounts were imported from this connection. Add an unlinked account instead.'**
  String get accountsLinkedNothingImported;

  /// No description provided for @accountsLinkedUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Linked connections for \"{institution}\" are currently unavailable. Add an unlinked account instead.'**
  String accountsLinkedUnavailable(String institution);

  /// No description provided for @accountsAddExistingError.
  ///
  /// In en, this message translates to:
  /// **'Unable to add this account to the current budget.'**
  String get accountsAddExistingError;

  /// No description provided for @accountsMyAccounts.
  ///
  /// In en, this message translates to:
  /// **'My accounts'**
  String get accountsMyAccounts;

  /// No description provided for @accountsAddExistingAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Add this existing account to this budget'**
  String get accountsAddExistingAccountHint;

  /// No description provided for @accountsInstitutionLabel.
  ///
  /// In en, this message translates to:
  /// **'Institution: {institution}'**
  String accountsInstitutionLabel(String institution);

  /// No description provided for @authLoginHeadline.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get authLoginHeadline;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continue building better money habits.'**
  String get authLoginSubtitle;

  /// No description provided for @authShowPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get authShowPassword;

  /// No description provided for @authHidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get authHidePassword;

  /// No description provided for @authStepProgress.
  ///
  /// In en, this message translates to:
  /// **'Step {step} of {total}'**
  String authStepProgress(int step, int total);

  /// No description provided for @homeLoadingBudgets.
  ///
  /// In en, this message translates to:
  /// **'Loading budgets'**
  String get homeLoadingBudgets;

  /// No description provided for @homeNoBudgetsHint.
  ///
  /// In en, this message translates to:
  /// **'Start a plan for this month and give every dollar a job.'**
  String get homeNoBudgetsHint;

  /// No description provided for @settingsLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {label}'**
  String settingsLastUpdated(String label);

  /// No description provided for @settingsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading settings'**
  String get settingsLoading;

  /// No description provided for @budgetStatusOverspent.
  ///
  /// In en, this message translates to:
  /// **'Overspent'**
  String get budgetStatusOverspent;

  /// No description provided for @budgetStatusFunded.
  ///
  /// In en, this message translates to:
  /// **'Funded'**
  String get budgetStatusFunded;

  /// No description provided for @budgetStatusUnderfunded.
  ///
  /// In en, this message translates to:
  /// **'Underfunded'**
  String get budgetStatusUnderfunded;

  /// No description provided for @budgetEnvelopeProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% funded'**
  String budgetEnvelopeProgress(int percent);

  /// No description provided for @budgetEnvelopeCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 envelope} other{{count} envelopes}}'**
  String budgetEnvelopeCount(int count);

  /// No description provided for @budgetReviewTransactions.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Review 1 transaction} other{Review {count} transactions}}'**
  String budgetReviewTransactions(int count);

  /// No description provided for @budgetCoverOverspentCategories.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Cover 1 overspent category} other{Cover {count} overspent categories}}'**
  String budgetCoverOverspentCategories(int count);

  /// No description provided for @budgetCategoryAllocated.
  ///
  /// In en, this message translates to:
  /// **'{amount} allocated'**
  String budgetCategoryAllocated(String amount);

  /// No description provided for @budgetGoalTarget.
  ///
  /// In en, this message translates to:
  /// **'Target: {amount}'**
  String budgetGoalTarget(String amount);

  /// No description provided for @budgetGoalMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly: {amount}'**
  String budgetGoalMonthly(String amount);

  /// No description provided for @budgetGoalTargetBy.
  ///
  /// In en, this message translates to:
  /// **'Target: {amount} by {date}'**
  String budgetGoalTargetBy(String amount, String date);

  /// No description provided for @budgetBackspaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Delete digit'**
  String get budgetBackspaceLabel;

  /// No description provided for @budgetDayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String budgetDayOfMonth(int day);

  /// No description provided for @transactionsLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading transactions'**
  String get transactionsLoading;

  /// No description provided for @payeesLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading payees'**
  String get payeesLoading;

  /// No description provided for @rulesLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading rules'**
  String get rulesLoading;

  /// No description provided for @transactionsBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get transactionsBack;

  /// No description provided for @transactionsSearchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get transactionsSearchClear;

  /// No description provided for @transactionsUnknownPayee.
  ///
  /// In en, this message translates to:
  /// **'Unknown payee'**
  String get transactionsUnknownPayee;

  /// No description provided for @transactionsUnknownEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Unknown envelope'**
  String get transactionsUnknownEnvelope;

  /// No description provided for @reportsAgeOfMoneyHint.
  ///
  /// In en, this message translates to:
  /// **'How long your money lasts after it arrives'**
  String get reportsAgeOfMoneyHint;

  /// No description provided for @reportsAgeOfMoneyTitle.
  ///
  /// In en, this message translates to:
  /// **'Age of Money'**
  String get reportsAgeOfMoneyTitle;

  /// No description provided for @reportsDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String reportsDays(int count);

  /// No description provided for @reportsLoading.
  ///
  /// In en, this message translates to:
  /// **'Adding up the month…'**
  String get reportsLoading;

  /// No description provided for @reportsNetWorthCurrent.
  ///
  /// In en, this message translates to:
  /// **'Right now'**
  String get reportsNetWorthCurrent;

  /// No description provided for @reportsNetWorthExplainerBody.
  ///
  /// In en, this message translates to:
  /// **'Net worth adds up every active account in this plan: what you own minus what you owe. Think of it as a snapshot of today, not a score.'**
  String get reportsNetWorthExplainerBody;

  /// No description provided for @reportsNetWorthExplainerTitle.
  ///
  /// In en, this message translates to:
  /// **'What net worth counts'**
  String get reportsNetWorthExplainerTitle;

  /// No description provided for @reportsNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get reportsNextMonth;

  /// No description provided for @reportsOtherCategories.
  ///
  /// In en, this message translates to:
  /// **'Other categories'**
  String get reportsOtherCategories;

  /// No description provided for @reportsPositiveInflowTotal.
  ///
  /// In en, this message translates to:
  /// **'Income this period'**
  String get reportsPositiveInflowTotal;

  /// No description provided for @reportsPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get reportsPreviousMonth;

  /// No description provided for @recurringCalendarDayCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 scheduled item} other{{count} scheduled items}}'**
  String recurringCalendarDayCount(int count);

  /// No description provided for @recurringActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get recurringActiveLabel;

  /// No description provided for @recurringLoading.
  ///
  /// In en, this message translates to:
  /// **'Fetching the schedule…'**
  String get recurringLoading;

  /// No description provided for @recurringNextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get recurringNextMonth;

  /// No description provided for @recurringPausedLabel.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get recurringPausedLabel;

  /// No description provided for @recurringPostedLabel.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get recurringPostedLabel;

  /// No description provided for @recurringPreviousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get recurringPreviousMonth;

  /// No description provided for @recurringSavingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get recurringSavingLabel;

  /// No description provided for @recurringScheduledLabel.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get recurringScheduledLabel;

  /// No description provided for @recurringSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Scheduled totals'**
  String get recurringSummaryTitle;

  /// No description provided for @reportsChartEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add a few transactions and this drawing fills in.'**
  String get reportsChartEmptyMessage;

  /// No description provided for @reportsChartEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to chart yet'**
  String get reportsChartEmptyTitle;

  /// No description provided for @reportsChartSeriesEntry.
  ///
  /// In en, this message translates to:
  /// **'{label}: {amount}'**
  String reportsChartSeriesEntry(String label, String amount);

  /// No description provided for @reportsChartSummary.
  ///
  /// In en, this message translates to:
  /// **'{title}. {entries}'**
  String reportsChartSummary(String title, String entries);

  /// No description provided for @moreTaxes.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get moreTaxes;

  /// No description provided for @taxOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Taxes'**
  String get taxOverviewTitle;

  /// No description provided for @taxOverviewLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your tax report'**
  String get taxOverviewLoading;

  /// No description provided for @taxOverviewLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your tax report.'**
  String get taxOverviewLoadError;

  /// No description provided for @taxProfileLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your tax profile.'**
  String get taxProfileLoadError;

  /// No description provided for @taxSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up taxes'**
  String get taxSetupTitle;

  /// No description provided for @taxSetupMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose your country and how you file, then tag envelopes and transactions so OpenBudget can work out your tax position.'**
  String get taxSetupMessage;

  /// No description provided for @taxSetupAction.
  ///
  /// In en, this message translates to:
  /// **'Set up taxes'**
  String get taxSetupAction;

  /// No description provided for @taxRulesUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'No rates for this year'**
  String get taxRulesUnavailableTitle;

  /// No description provided for @taxRulesUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'OpenBudget doesn\'t have the tax rates for this year yet. Try another year.'**
  String get taxRulesUnavailableMessage;

  /// No description provided for @taxYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax year {year}'**
  String taxYearLabel(int year);

  /// No description provided for @taxPreviousYear.
  ///
  /// In en, this message translates to:
  /// **'Previous tax year'**
  String get taxPreviousYear;

  /// No description provided for @taxNextYear.
  ///
  /// In en, this message translates to:
  /// **'Next tax year'**
  String get taxNextYear;

  /// No description provided for @taxBalanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance due'**
  String get taxBalanceDue;

  /// No description provided for @taxRefundDue.
  ///
  /// In en, this message translates to:
  /// **'Refund due'**
  String get taxRefundDue;

  /// No description provided for @taxNothingToPay.
  ///
  /// In en, this message translates to:
  /// **'Nothing to pay'**
  String get taxNothingToPay;

  /// No description provided for @taxTotalLiability.
  ///
  /// In en, this message translates to:
  /// **'Total tax'**
  String get taxTotalLiability;

  /// No description provided for @taxAlreadyPaid.
  ///
  /// In en, this message translates to:
  /// **'Already paid'**
  String get taxAlreadyPaid;

  /// No description provided for @taxUncategorizedCount.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized: {count}'**
  String taxUncategorizedCount(int count);

  /// No description provided for @taxUncategorizedHint.
  ///
  /// In en, this message translates to:
  /// **'Tag these transactions to include them in your report.'**
  String get taxUncategorizedHint;

  /// No description provided for @taxConvertedEntries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry converted at its transaction date rate} other{{count} entries converted at their transaction date rates}}'**
  String taxConvertedEntries(int count);

  /// No description provided for @taxLiabilitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Tax due'**
  String get taxLiabilitiesTitle;

  /// No description provided for @taxLiabilitiesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No tax is due for this year.'**
  String get taxLiabilitiesEmpty;

  /// No description provided for @taxBandsShow.
  ///
  /// In en, this message translates to:
  /// **'Show how this was worked out'**
  String get taxBandsShow;

  /// No description provided for @taxBandsHide.
  ///
  /// In en, this message translates to:
  /// **'Hide how this was worked out'**
  String get taxBandsHide;

  /// No description provided for @taxBandRate.
  ///
  /// In en, this message translates to:
  /// **'{rate}%'**
  String taxBandRate(String rate);

  /// No description provided for @taxBandBaseColumn.
  ///
  /// In en, this message translates to:
  /// **'Taxable'**
  String get taxBandBaseColumn;

  /// No description provided for @taxBandTaxColumn.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get taxBandTaxColumn;

  /// No description provided for @taxReportLinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Report lines'**
  String get taxReportLinesTitle;

  /// No description provided for @taxReportLinesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categorised lines yet. Tag envelopes or transactions to fill this in.'**
  String get taxReportLinesEmpty;

  /// No description provided for @taxEntryCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No entries} =1{1 entry} other{{count} entries}}'**
  String taxEntryCount(int count);

  /// No description provided for @taxOpportunitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Ways to pay less'**
  String get taxOpportunitiesTitle;

  /// No description provided for @taxOpportunitySaving.
  ///
  /// In en, this message translates to:
  /// **'Estimated saving {amount}'**
  String taxOpportunitySaving(String amount);

  /// No description provided for @taxOpportunityDeadline.
  ///
  /// In en, this message translates to:
  /// **'Act by {date}'**
  String taxOpportunityDeadline(String date);

  /// No description provided for @taxOpportunitySource.
  ///
  /// In en, this message translates to:
  /// **'Guidance'**
  String get taxOpportunitySource;

  /// No description provided for @taxHowWorkedOutTitle.
  ///
  /// In en, this message translates to:
  /// **'How this was worked out'**
  String get taxHowWorkedOutTitle;

  /// No description provided for @taxRulesVerifiedOn.
  ///
  /// In en, this message translates to:
  /// **'Rates checked on {date}'**
  String taxRulesVerifiedOn(String date);

  /// No description provided for @taxAssumptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assumptions'**
  String get taxAssumptionsTitle;

  /// No description provided for @taxSourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get taxSourcesTitle;

  /// No description provided for @taxDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Guidance only, not tax advice. Check figures with a qualified adviser before filing.'**
  String get taxDisclaimer;

  /// Banner on the tax overview when the country pack is still in preview.
  ///
  /// In en, this message translates to:
  /// **'Preview: these figures have not yet been checked by a tax professional.'**
  String get taxPreviewBanner;

  /// No description provided for @taxProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Tax profile'**
  String get taxProfileTitle;

  /// No description provided for @taxProfileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your tax profile'**
  String get taxProfileLoading;

  /// No description provided for @taxProfileSave.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get taxProfileSave;

  /// No description provided for @taxProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Tax profile saved'**
  String get taxProfileSaved;

  /// No description provided for @taxProfileSaveError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save your tax profile.'**
  String get taxProfileSaveError;

  /// No description provided for @taxProfileSummary.
  ///
  /// In en, this message translates to:
  /// **'{jurisdiction} · {entity}'**
  String taxProfileSummary(String jurisdiction, String entity);

  /// No description provided for @taxCountryLabel.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get taxCountryLabel;

  /// No description provided for @taxEntityKindLabel.
  ///
  /// In en, this message translates to:
  /// **'Entity kind'**
  String get taxEntityKindLabel;

  /// No description provided for @taxEntityIndividual.
  ///
  /// In en, this message translates to:
  /// **'Individual'**
  String get taxEntityIndividual;

  /// No description provided for @taxEntitySoleTrader.
  ///
  /// In en, this message translates to:
  /// **'Sole trader'**
  String get taxEntitySoleTrader;

  /// No description provided for @taxEntityCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get taxEntityCompany;

  /// No description provided for @taxJurisdictionGb.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get taxJurisdictionGb;

  /// No description provided for @taxJurisdictionUs.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get taxJurisdictionUs;

  /// No description provided for @taxJurisdictionNg.
  ///
  /// In en, this message translates to:
  /// **'Nigeria'**
  String get taxJurisdictionNg;

  /// No description provided for @taxJurisdictionDe.
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get taxJurisdictionDe;

  /// No description provided for @taxSalesTaxRegistered.
  ///
  /// In en, this message translates to:
  /// **'Registered for sales tax or VAT'**
  String get taxSalesTaxRegistered;

  /// No description provided for @taxSalesTaxRegisteredHint.
  ///
  /// In en, this message translates to:
  /// **'Turn this on if you charge and reclaim sales tax on these books.'**
  String get taxSalesTaxRegisteredHint;

  /// No description provided for @taxGbScottishTaxpayer.
  ///
  /// In en, this message translates to:
  /// **'Scottish taxpayer'**
  String get taxGbScottishTaxpayer;

  /// No description provided for @taxGbScottishTaxpayerHint.
  ///
  /// In en, this message translates to:
  /// **'Use Scottish income tax rates.'**
  String get taxGbScottishTaxpayerHint;

  /// No description provided for @taxGbStudentLoanPlan.
  ///
  /// In en, this message translates to:
  /// **'Student loan plan'**
  String get taxGbStudentLoanPlan;

  /// No description provided for @taxGbStudentLoanNone.
  ///
  /// In en, this message translates to:
  /// **'No student loan'**
  String get taxGbStudentLoanNone;

  /// No description provided for @taxGbStudentLoanPlan1.
  ///
  /// In en, this message translates to:
  /// **'Plan 1'**
  String get taxGbStudentLoanPlan1;

  /// No description provided for @taxGbStudentLoanPlan2.
  ///
  /// In en, this message translates to:
  /// **'Plan 2'**
  String get taxGbStudentLoanPlan2;

  /// No description provided for @taxGbStudentLoanPlan4.
  ///
  /// In en, this message translates to:
  /// **'Plan 4'**
  String get taxGbStudentLoanPlan4;

  /// No description provided for @taxGbStudentLoanPlan5.
  ///
  /// In en, this message translates to:
  /// **'Plan 5'**
  String get taxGbStudentLoanPlan5;

  /// No description provided for @taxGbStudentLoanPostgraduate.
  ///
  /// In en, this message translates to:
  /// **'Postgraduate loan'**
  String get taxGbStudentLoanPostgraduate;

  /// No description provided for @taxGbPostgraduateLoanHint.
  ///
  /// In en, this message translates to:
  /// **'Repay 6% of income above £21,000 on top of any undergraduate plan.'**
  String get taxGbPostgraduateLoanHint;

  /// No description provided for @taxGbAccountingPeriodEnd.
  ///
  /// In en, this message translates to:
  /// **'Accounting period end'**
  String get taxGbAccountingPeriodEnd;

  /// No description provided for @taxGbAccountingPeriodEndHint.
  ///
  /// In en, this message translates to:
  /// **'The company\'s year end. Corporation Tax runs on these periods, not the tax year.'**
  String get taxGbAccountingPeriodEndHint;

  /// No description provided for @taxGbAccountingPeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get taxGbAccountingPeriodMonth;

  /// No description provided for @taxGbAccountingPeriodDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get taxGbAccountingPeriodDay;

  /// No description provided for @taxGbAssociatedCompanies.
  ///
  /// In en, this message translates to:
  /// **'Associated companies'**
  String get taxGbAssociatedCompanies;

  /// No description provided for @taxGbAssociatedCompaniesHint.
  ///
  /// In en, this message translates to:
  /// **'Other companies under common control. Each one divides the £50,000 and £250,000 limits.'**
  String get taxGbAssociatedCompaniesHint;

  /// No description provided for @taxGbAssociatedCompaniesError.
  ///
  /// In en, this message translates to:
  /// **'Enter the number of associated companies as a whole number, such as 0.'**
  String get taxGbAssociatedCompaniesError;

  /// No description provided for @taxUsFilingStatus.
  ///
  /// In en, this message translates to:
  /// **'Filing status'**
  String get taxUsFilingStatus;

  /// No description provided for @taxUsFilingSingle.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get taxUsFilingSingle;

  /// No description provided for @taxUsFilingMarriedJointly.
  ///
  /// In en, this message translates to:
  /// **'Married filing jointly'**
  String get taxUsFilingMarriedJointly;

  /// No description provided for @taxUsFilingMarriedSeparately.
  ///
  /// In en, this message translates to:
  /// **'Married filing separately'**
  String get taxUsFilingMarriedSeparately;

  /// No description provided for @taxUsFilingHeadOfHousehold.
  ///
  /// In en, this message translates to:
  /// **'Head of household'**
  String get taxUsFilingHeadOfHousehold;

  /// No description provided for @taxUsFilingQualifyingSurvivingSpouse.
  ///
  /// In en, this message translates to:
  /// **'Qualifying surviving spouse'**
  String get taxUsFilingQualifyingSurvivingSpouse;

  /// No description provided for @taxUsForeignEarnedIncomeExclusion.
  ///
  /// In en, this message translates to:
  /// **'Foreign earned income exclusion'**
  String get taxUsForeignEarnedIncomeExclusion;

  /// No description provided for @taxUsForeignEarnedIncomeExclusionHint.
  ///
  /// In en, this message translates to:
  /// **'The amount you excluded on Form 2555 this year. It is added back when the investment income and deduction phase-outs check your income.'**
  String get taxUsForeignEarnedIncomeExclusionHint;

  /// No description provided for @taxUsDependentsUnder17.
  ///
  /// In en, this message translates to:
  /// **'Dependents under 17'**
  String get taxUsDependentsUnder17;

  /// No description provided for @taxUsDependents17OrOlder.
  ///
  /// In en, this message translates to:
  /// **'Dependents 17 or older'**
  String get taxUsDependents17OrOlder;

  /// No description provided for @taxUsDependentsCountHint.
  ///
  /// In en, this message translates to:
  /// **'The number of people you claim as dependents.'**
  String get taxUsDependentsCountHint;

  /// No description provided for @taxUsDependentsSsn.
  ///
  /// In en, this message translates to:
  /// **'All dependents have an SSN'**
  String get taxUsDependentsSsn;

  /// No description provided for @taxUsDependentsSsnHint.
  ///
  /// In en, this message translates to:
  /// **'Only dependents with an SSN valid for employment earn a credit.'**
  String get taxUsDependentsSsnHint;

  /// No description provided for @taxUsTaxpayer65OrOlder.
  ///
  /// In en, this message translates to:
  /// **'You are 65 or older'**
  String get taxUsTaxpayer65OrOlder;

  /// No description provided for @taxUsSpouse65OrOlder.
  ///
  /// In en, this message translates to:
  /// **'Your spouse is 65 or older'**
  String get taxUsSpouse65OrOlder;

  /// No description provided for @taxUsTaxpayerHasSsn.
  ///
  /// In en, this message translates to:
  /// **'You have an SSN'**
  String get taxUsTaxpayerHasSsn;

  /// No description provided for @taxUsSpouseHasSsn.
  ///
  /// In en, this message translates to:
  /// **'Your spouse has an SSN'**
  String get taxUsSpouseHasSsn;

  /// No description provided for @taxUsSsnHint.
  ///
  /// In en, this message translates to:
  /// **'Required for the tips, overtime, and senior deductions.'**
  String get taxUsSsnHint;

  /// No description provided for @taxUsHomeOfficeMethod.
  ///
  /// In en, this message translates to:
  /// **'Home office method'**
  String get taxUsHomeOfficeMethod;

  /// No description provided for @taxUsHomeOfficeSimplified.
  ///
  /// In en, this message translates to:
  /// **'Simplified (\$5 per square foot)'**
  String get taxUsHomeOfficeSimplified;

  /// No description provided for @taxUsHomeOfficeRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular (Form 8829)'**
  String get taxUsHomeOfficeRegular;

  /// No description provided for @taxUsSpecifiedServiceTrade.
  ///
  /// In en, this message translates to:
  /// **'Specified service business'**
  String get taxUsSpecifiedServiceTrade;

  /// No description provided for @taxUsSpecifiedServiceTradeHint.
  ///
  /// In en, this message translates to:
  /// **'Consulting, law, health and similar businesses phase out of the qualified business income deduction.'**
  String get taxUsSpecifiedServiceTradeHint;

  /// No description provided for @taxNgAnnualRent.
  ///
  /// In en, this message translates to:
  /// **'Annual rent paid'**
  String get taxNgAnnualRent;

  /// No description provided for @taxNgAnnualRentHint.
  ///
  /// In en, this message translates to:
  /// **'Used for rent relief under the Nigeria Tax Act.'**
  String get taxNgAnnualRentHint;

  /// No description provided for @taxNgAnnualRentError.
  ///
  /// In en, this message translates to:
  /// **'Enter the annual rent as a number, such as 1200000.'**
  String get taxNgAnnualRentError;

  /// No description provided for @taxNgSmallCompanyCeiling.
  ///
  /// In en, this message translates to:
  /// **'Small company turnover ceiling'**
  String get taxNgSmallCompanyCeiling;

  /// No description provided for @taxNgSmallCompanyCeilingHint.
  ///
  /// In en, this message translates to:
  /// **'The two Nigerian Acts disagree: the Nigeria Tax Act gazette says N50,000,000 and the Administration Act says N100,000,000. Pick the figure that should decide your company\'s small company status.'**
  String get taxNgSmallCompanyCeilingHint;

  /// No description provided for @taxNgSmallCompanyCeilingGazette.
  ///
  /// In en, this message translates to:
  /// **'N50,000,000 (Nigeria Tax Act gazette)'**
  String get taxNgSmallCompanyCeilingGazette;

  /// No description provided for @taxNgSmallCompanyCeilingIntended.
  ///
  /// In en, this message translates to:
  /// **'N100,000,000 (Administration Act)'**
  String get taxNgSmallCompanyCeilingIntended;

  /// No description provided for @taxNgMneGroupMember.
  ///
  /// In en, this message translates to:
  /// **'Member of a multinational group'**
  String get taxNgMneGroupMember;

  /// No description provided for @taxNgMneGroupMemberHint.
  ///
  /// In en, this message translates to:
  /// **'Multinational group members may owe the 15% minimum effective tax rate whatever their turnover.'**
  String get taxNgMneGroupMemberHint;

  /// No description provided for @taxDeJointAssessment.
  ///
  /// In en, this message translates to:
  /// **'Joint assessment'**
  String get taxDeJointAssessment;

  /// No description provided for @taxDeJointAssessmentHint.
  ///
  /// In en, this message translates to:
  /// **'Spouses assessed together with income splitting.'**
  String get taxDeJointAssessmentHint;

  /// No description provided for @taxDeSpouseEmployed.
  ///
  /// In en, this message translates to:
  /// **'Spouse also earns wages'**
  String get taxDeSpouseEmployed;

  /// No description provided for @taxDeSpouseEmployedHint.
  ///
  /// In en, this message translates to:
  /// **'Each employed spouse claims their own worker\'s flat-rate allowance and files their own Anlage N.'**
  String get taxDeSpouseEmployedHint;

  /// No description provided for @taxDeChurchTax.
  ///
  /// In en, this message translates to:
  /// **'Church tax'**
  String get taxDeChurchTax;

  /// No description provided for @taxDeChurchTaxHint.
  ///
  /// In en, this message translates to:
  /// **'Kirchensteuer on top of income tax.'**
  String get taxDeChurchTaxHint;

  /// No description provided for @taxDeChurchState.
  ///
  /// In en, this message translates to:
  /// **'State (Land) of the church tax'**
  String get taxDeChurchState;

  /// No description provided for @taxDeChurchStateHint.
  ///
  /// In en, this message translates to:
  /// **'Sets the rate: 8% in Bavaria and Baden-Württemberg, 9% elsewhere. Leave it out to assume 9%.'**
  String get taxDeChurchStateHint;

  /// No description provided for @taxDeChurchStateNone.
  ///
  /// In en, this message translates to:
  /// **'Not specified (assume 9%)'**
  String get taxDeChurchStateNone;

  /// No description provided for @taxDeChildren.
  ///
  /// In en, this message translates to:
  /// **'Children (Kindergeld)'**
  String get taxDeChildren;

  /// No description provided for @taxDeChildrenHint.
  ///
  /// In en, this message translates to:
  /// **'Children you receive Kindergeld for; a full twelve months per child is assumed.'**
  String get taxDeChildrenHint;

  /// No description provided for @taxDeEinkunftsArt.
  ///
  /// In en, this message translates to:
  /// **'Type of self-employment'**
  String get taxDeEinkunftsArt;

  /// No description provided for @taxDeEinkunftsArtHint.
  ///
  /// In en, this message translates to:
  /// **'Freiberufler owe no trade tax and file Anlage S; Gewerbetreibende owe Gewerbesteuer and file Anlage G.'**
  String get taxDeEinkunftsArtHint;

  /// No description provided for @taxDeEinkunftsArtFreiberuflich.
  ///
  /// In en, this message translates to:
  /// **'Freiberufler (liberal profession)'**
  String get taxDeEinkunftsArtFreiberuflich;

  /// No description provided for @taxDeEinkunftsArtGewerblich.
  ///
  /// In en, this message translates to:
  /// **'Gewerbetreibender (trade)'**
  String get taxDeEinkunftsArtGewerblich;

  /// No description provided for @taxDeStatutoryPension.
  ///
  /// In en, this message translates to:
  /// **'Statutory pension contributions'**
  String get taxDeStatutoryPension;

  /// No description provided for @taxDeStatutoryPensionHint.
  ///
  /// In en, this message translates to:
  /// **'Employee and employer share per year; they reduce the Rürup (Basisrente) deduction.'**
  String get taxDeStatutoryPensionHint;

  /// No description provided for @taxDePriorTurnover.
  ///
  /// In en, this message translates to:
  /// **'Previous year\'s turnover'**
  String get taxDePriorTurnover;

  /// No description provided for @taxDePriorTurnoverHint.
  ///
  /// In en, this message translates to:
  /// **'Total turnover of last year; it decides the Kleinunternehmer test (at most €25,000 prior year, €100,000 this year).'**
  String get taxDePriorTurnoverHint;

  /// No description provided for @taxDeCommuteKm.
  ///
  /// In en, this message translates to:
  /// **'Commute: one-way distance (km)'**
  String get taxDeCommuteKm;

  /// No description provided for @taxDeCommuteKmHint.
  ///
  /// In en, this message translates to:
  /// **'Full kilometres to your first workplace, shortest route (Anlage N).'**
  String get taxDeCommuteKmHint;

  /// No description provided for @taxDeCommuteDays.
  ///
  /// In en, this message translates to:
  /// **'Commute: days travelled'**
  String get taxDeCommuteDays;

  /// No description provided for @taxDeCommuteDaysHint.
  ///
  /// In en, this message translates to:
  /// **'Days you actually visited the workplace; illness, holiday and home-office days do not count.'**
  String get taxDeCommuteDaysHint;

  /// No description provided for @taxDeNumberError.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number of 0 or more.'**
  String get taxDeNumberError;

  /// No description provided for @taxDeAmountError.
  ///
  /// In en, this message translates to:
  /// **'Enter the amount as a number, such as 4800.'**
  String get taxDeAmountError;

  /// No description provided for @taxDeBundeslandBw.
  ///
  /// In en, this message translates to:
  /// **'Baden-Württemberg'**
  String get taxDeBundeslandBw;

  /// No description provided for @taxDeBundeslandBy.
  ///
  /// In en, this message translates to:
  /// **'Bavaria'**
  String get taxDeBundeslandBy;

  /// No description provided for @taxDeBundeslandBe.
  ///
  /// In en, this message translates to:
  /// **'Berlin'**
  String get taxDeBundeslandBe;

  /// No description provided for @taxDeBundeslandBb.
  ///
  /// In en, this message translates to:
  /// **'Brandenburg'**
  String get taxDeBundeslandBb;

  /// No description provided for @taxDeBundeslandHb.
  ///
  /// In en, this message translates to:
  /// **'Bremen'**
  String get taxDeBundeslandHb;

  /// No description provided for @taxDeBundeslandHh.
  ///
  /// In en, this message translates to:
  /// **'Hamburg'**
  String get taxDeBundeslandHh;

  /// No description provided for @taxDeBundeslandHe.
  ///
  /// In en, this message translates to:
  /// **'Hesse'**
  String get taxDeBundeslandHe;

  /// No description provided for @taxDeBundeslandMv.
  ///
  /// In en, this message translates to:
  /// **'Mecklenburg-Vorpommern'**
  String get taxDeBundeslandMv;

  /// No description provided for @taxDeBundeslandNi.
  ///
  /// In en, this message translates to:
  /// **'Lower Saxony'**
  String get taxDeBundeslandNi;

  /// No description provided for @taxDeBundeslandNw.
  ///
  /// In en, this message translates to:
  /// **'North Rhine-Westphalia'**
  String get taxDeBundeslandNw;

  /// No description provided for @taxDeBundeslandRp.
  ///
  /// In en, this message translates to:
  /// **'Rhineland-Palatinate'**
  String get taxDeBundeslandRp;

  /// No description provided for @taxDeBundeslandSl.
  ///
  /// In en, this message translates to:
  /// **'Saarland'**
  String get taxDeBundeslandSl;

  /// No description provided for @taxDeBundeslandSn.
  ///
  /// In en, this message translates to:
  /// **'Saxony'**
  String get taxDeBundeslandSn;

  /// No description provided for @taxDeBundeslandSt.
  ///
  /// In en, this message translates to:
  /// **'Saxony-Anhalt'**
  String get taxDeBundeslandSt;

  /// No description provided for @taxDeBundeslandSh.
  ///
  /// In en, this message translates to:
  /// **'Schleswig-Holstein'**
  String get taxDeBundeslandSh;

  /// No description provided for @taxDeBundeslandTh.
  ///
  /// In en, this message translates to:
  /// **'Thuringia'**
  String get taxDeBundeslandTh;

  /// No description provided for @taxDeSmallBusinessExemption.
  ///
  /// In en, this message translates to:
  /// **'Small business VAT exemption'**
  String get taxDeSmallBusinessExemption;

  /// No description provided for @taxDeSmallBusinessExemptionHint.
  ///
  /// In en, this message translates to:
  /// **'Kleinunternehmerregelung: no VAT charged or reclaimed.'**
  String get taxDeSmallBusinessExemptionHint;

  /// No description provided for @taxLinkedBudget.
  ///
  /// In en, this message translates to:
  /// **'Linked personal budget'**
  String get taxLinkedBudget;

  /// No description provided for @taxLinkedBudgetHint.
  ///
  /// In en, this message translates to:
  /// **'The personal budget this business feeds.'**
  String get taxLinkedBudgetHint;

  /// No description provided for @taxLinkedBudgetNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get taxLinkedBudgetNone;

  /// No description provided for @taxLinkedBudgetError.
  ///
  /// In en, this message translates to:
  /// **'Choose a different budget to link.'**
  String get taxLinkedBudgetError;

  /// No description provided for @taxCategorySheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Tax category'**
  String get taxCategorySheetTitle;

  /// No description provided for @taxCategorySheetSearch.
  ///
  /// In en, this message translates to:
  /// **'Search categories'**
  String get taxCategorySheetSearch;

  /// No description provided for @taxCategoryNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get taxCategoryNone;

  /// No description provided for @taxCategoryNoneHint.
  ///
  /// In en, this message translates to:
  /// **'Leave this out of the tax report.'**
  String get taxCategoryNoneHint;

  /// No description provided for @taxCategoryKindIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get taxCategoryKindIncome;

  /// No description provided for @taxCategoryKindExpense.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get taxCategoryKindExpense;

  /// No description provided for @taxCategoryKindDisposalProceeds.
  ///
  /// In en, this message translates to:
  /// **'Disposal proceeds'**
  String get taxCategoryKindDisposalProceeds;

  /// No description provided for @taxCategoryKindDisposalCost.
  ///
  /// In en, this message translates to:
  /// **'Acquisition costs'**
  String get taxCategoryKindDisposalCost;

  /// No description provided for @taxCategoryKindRelief.
  ///
  /// In en, this message translates to:
  /// **'Reliefs'**
  String get taxCategoryKindRelief;

  /// No description provided for @taxCategoryKindTaxPaid.
  ///
  /// In en, this message translates to:
  /// **'Tax already paid'**
  String get taxCategoryKindTaxPaid;

  /// No description provided for @taxCategoryKindSalesTaxCollected.
  ///
  /// In en, this message translates to:
  /// **'Sales tax collected'**
  String get taxCategoryKindSalesTaxCollected;

  /// No description provided for @taxCategoryKindSalesTaxPaid.
  ///
  /// In en, this message translates to:
  /// **'Sales tax paid'**
  String get taxCategoryKindSalesTaxPaid;

  /// No description provided for @taxCategoryKindOutOfScope.
  ///
  /// In en, this message translates to:
  /// **'Outside tax'**
  String get taxCategoryKindOutOfScope;

  /// No description provided for @taxCategorySearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories match \"{query}\".'**
  String taxCategorySearchEmpty(String query);

  /// No description provided for @taxCategorySheetSave.
  ///
  /// In en, this message translates to:
  /// **'Save category'**
  String get taxCategorySheetSave;

  /// No description provided for @taxCategorySheetSaved.
  ///
  /// In en, this message translates to:
  /// **'Tax category updated.'**
  String get taxCategorySheetSaved;

  /// No description provided for @taxCategorySheetError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t update the tax category.'**
  String get taxCategorySheetError;

  /// No description provided for @taxCategorySheetEmpty.
  ///
  /// In en, this message translates to:
  /// **'Set up a tax profile first to choose a category.'**
  String get taxCategorySheetEmpty;

  /// No description provided for @taxCategorySheetSetupAction.
  ///
  /// In en, this message translates to:
  /// **'Set up taxes'**
  String get taxCategorySheetSetupAction;

  /// No description provided for @taxCategorySheetLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading tax categories'**
  String get taxCategorySheetLoading;

  /// No description provided for @taxCategorySheetLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load tax categories.'**
  String get taxCategorySheetLoadError;

  /// No description provided for @taxCategoryRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Tax category'**
  String get taxCategoryRowLabel;

  /// No description provided for @taxCategoryNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get taxCategoryNotSet;

  /// No description provided for @taxCategoryTagged.
  ///
  /// In en, this message translates to:
  /// **'Tagged'**
  String get taxCategoryTagged;

  /// No description provided for @taxTransactionBusinessUse.
  ///
  /// In en, this message translates to:
  /// **'Business use'**
  String get taxTransactionBusinessUse;

  /// No description provided for @taxTransactionBusinessUseValue.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String taxTransactionBusinessUseValue(int percent);

  /// No description provided for @taxTransactionSalesTax.
  ///
  /// In en, this message translates to:
  /// **'Sales tax included'**
  String get taxTransactionSalesTax;

  /// No description provided for @taxTransactionSalesTaxHint.
  ///
  /// In en, this message translates to:
  /// **'The tax already inside the transaction amount.'**
  String get taxTransactionSalesTaxHint;

  /// No description provided for @taxTransactionSalesTaxError.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount no larger than the transaction.'**
  String get taxTransactionSalesTaxError;

  /// No description provided for @taxCategoryLoadRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get taxCategoryLoadRetry;

  /// No description provided for @assistantApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get assistantApply;

  /// No description provided for @assistantComposerHint.
  ///
  /// In en, this message translates to:
  /// **'Ask about this plan…'**
  String get assistantComposerHint;

  /// No description provided for @assistantConversationDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get assistantConversationDelete;

  /// No description provided for @assistantConversationDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the conversation.'**
  String get assistantConversationDeleteError;

  /// No description provided for @assistantConversationDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'The chat and its messages are removed. Proposals it made stay in your plan.'**
  String get assistantConversationDeleteMessage;

  /// No description provided for @assistantConversationDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this conversation?'**
  String get assistantConversationDeleteTitle;

  /// No description provided for @assistantConversationDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted'**
  String get assistantConversationDeletedToast;

  /// No description provided for @assistantConversationListEmpty.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet. Your first question starts one.'**
  String get assistantConversationListEmpty;

  /// No description provided for @assistantConversations.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get assistantConversations;

  /// No description provided for @assistantConversationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load conversations.'**
  String get assistantConversationsLoadError;

  /// No description provided for @assistantDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Guidance only, not financial or tax advice.'**
  String get assistantDisclaimer;

  /// No description provided for @assistantDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get assistantDismiss;

  /// No description provided for @assistantEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'I can read your budget, explain what changed, and suggest moves for you to approve. I never change anything on my own.'**
  String get assistantEmptyMessage;

  /// No description provided for @assistantEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask about this plan'**
  String get assistantEmptyTitle;

  /// No description provided for @assistantErrorAllowanceMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used this month\'s included assistant usage. It resets with your next billing period, or you can connect your own provider and keep going now.'**
  String get assistantErrorAllowanceMessage;

  /// No description provided for @assistantErrorAllowanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Included usage is spent'**
  String get assistantErrorAllowanceTitle;

  /// No description provided for @assistantErrorEntitlementMessage.
  ///
  /// In en, this message translates to:
  /// **'The included assistant is part of OpenBudget Plus. Subscribe to keep chatting, or connect your own OpenAI-compatible provider.'**
  String get assistantErrorEntitlementMessage;

  /// No description provided for @assistantErrorEntitlementTitle.
  ///
  /// In en, this message translates to:
  /// **'OpenBudget Plus is needed'**
  String get assistantErrorEntitlementTitle;

  /// No description provided for @assistantErrorGetPlus.
  ///
  /// In en, this message translates to:
  /// **'Get OpenBudget Plus'**
  String get assistantErrorGetPlus;

  /// No description provided for @assistantErrorNetworkMessage.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get assistantErrorNetworkMessage;

  /// No description provided for @assistantErrorNetworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the assistant'**
  String get assistantErrorNetworkTitle;

  /// No description provided for @assistantErrorProviderMessage.
  ///
  /// In en, this message translates to:
  /// **'The built-in provider isn\'t available. Try again, or connect your own OpenAI-compatible provider.'**
  String get assistantErrorProviderMessage;

  /// No description provided for @assistantErrorProviderTitle.
  ///
  /// In en, this message translates to:
  /// **'The assistant has no provider right now'**
  String get assistantErrorProviderTitle;

  /// No description provided for @assistantErrorTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get assistantErrorTryAgain;

  /// No description provided for @assistantErrorUnknownMessage.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong while answering. Try again.'**
  String get assistantErrorUnknownMessage;

  /// No description provided for @assistantErrorUnknownTitle.
  ///
  /// In en, this message translates to:
  /// **'The assistant couldn\'t finish'**
  String get assistantErrorUnknownTitle;

  /// No description provided for @assistantErrorUseOwnProvider.
  ///
  /// In en, this message translates to:
  /// **'Use your own provider'**
  String get assistantErrorUseOwnProvider;

  /// No description provided for @assistantErrorValidationTitle.
  ///
  /// In en, this message translates to:
  /// **'That request wasn\'t valid'**
  String get assistantErrorValidationTitle;

  /// No description provided for @assistantLoadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Opening the conversation…'**
  String get assistantLoadingHistory;

  /// No description provided for @assistantNewConversation.
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get assistantNewConversation;

  /// No description provided for @assistantOpenProposals.
  ///
  /// In en, this message translates to:
  /// **'Review proposals'**
  String get assistantOpenProposals;

  /// No description provided for @assistantOwnProviderUsage.
  ///
  /// In en, this message translates to:
  /// **'Using your own provider'**
  String get assistantOwnProviderUsage;

  /// No description provided for @assistantOwnProviderUsageHint.
  ///
  /// In en, this message translates to:
  /// **'Calls go to your provider and never count against the included usage.'**
  String get assistantOwnProviderUsageHint;

  /// No description provided for @assistantPendingProposals.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 proposal waiting} other{{count} proposals waiting}}'**
  String assistantPendingProposals(int count);

  /// No description provided for @assistantProposalActionError.
  ///
  /// In en, this message translates to:
  /// **'Could not update that proposal. Try again.'**
  String get assistantProposalActionError;

  /// No description provided for @assistantProposalApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied'**
  String get assistantProposalApplied;

  /// No description provided for @assistantProposalAppliedToast.
  ///
  /// In en, this message translates to:
  /// **'Proposal applied'**
  String get assistantProposalAppliedToast;

  /// No description provided for @assistantProposalDismissed.
  ///
  /// In en, this message translates to:
  /// **'Dismissed'**
  String get assistantProposalDismissed;

  /// No description provided for @assistantProposalDismissedToast.
  ///
  /// In en, this message translates to:
  /// **'Proposal dismissed'**
  String get assistantProposalDismissedToast;

  /// No description provided for @assistantProposalEnvelopeTax.
  ///
  /// In en, this message translates to:
  /// **'Envelope tax category'**
  String get assistantProposalEnvelopeTax;

  /// No description provided for @assistantProposalMoveMoney.
  ///
  /// In en, this message translates to:
  /// **'Move money'**
  String get assistantProposalMoveMoney;

  /// No description provided for @assistantProposalPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your call'**
  String get assistantProposalPendingLabel;

  /// No description provided for @assistantProposalTransactionTax.
  ///
  /// In en, this message translates to:
  /// **'Transaction tax category'**
  String get assistantProposalTransactionTax;

  /// No description provided for @assistantProposalsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'When the assistant suggests a move, it waits here for you to apply or dismiss it.'**
  String get assistantProposalsEmptyMessage;

  /// No description provided for @assistantProposalsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing waiting'**
  String get assistantProposalsEmptyTitle;

  /// No description provided for @assistantProposalsHistorySection.
  ///
  /// In en, this message translates to:
  /// **'Past proposals'**
  String get assistantProposalsHistorySection;

  /// No description provided for @assistantProposalsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load proposals.'**
  String get assistantProposalsLoadError;

  /// No description provided for @assistantProposalsLoading.
  ///
  /// In en, this message translates to:
  /// **'Gathering proposals…'**
  String get assistantProposalsLoading;

  /// No description provided for @assistantProposalsPendingSection.
  ///
  /// In en, this message translates to:
  /// **'Waiting for you'**
  String get assistantProposalsPendingSection;

  /// No description provided for @assistantProposalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant proposals'**
  String get assistantProposalsTitle;

  /// No description provided for @assistantProviderApiKey.
  ///
  /// In en, this message translates to:
  /// **'API key'**
  String get assistantProviderApiKey;

  /// No description provided for @assistantProviderApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'sk-…'**
  String get assistantProviderApiKeyHint;

  /// No description provided for @assistantProviderBaseUrl.
  ///
  /// In en, this message translates to:
  /// **'Base URL'**
  String get assistantProviderBaseUrl;

  /// No description provided for @assistantProviderBaseUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://api.example.com/v1'**
  String get assistantProviderBaseUrlHint;

  /// No description provided for @assistantProviderEnterKeyAgain.
  ///
  /// In en, this message translates to:
  /// **'Saved keys are never shown. Enter the key again to save changes.'**
  String get assistantProviderEnterKeyAgain;

  /// No description provided for @assistantProviderIntro.
  ///
  /// In en, this message translates to:
  /// **'Connect an OpenAI-compatible provider to talk to the assistant with your own key.'**
  String get assistantProviderIntro;

  /// No description provided for @assistantProviderKeyRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the API key.'**
  String get assistantProviderKeyRequired;

  /// No description provided for @assistantProviderKeyStored.
  ///
  /// In en, this message translates to:
  /// **'••••{hint}'**
  String assistantProviderKeyStored(String hint);

  /// No description provided for @assistantProviderLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your provider settings.'**
  String get assistantProviderLoadError;

  /// No description provided for @assistantProviderLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading provider settings…'**
  String get assistantProviderLoading;

  /// No description provided for @assistantProviderModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get assistantProviderModel;

  /// No description provided for @assistantProviderModelHint.
  ///
  /// In en, this message translates to:
  /// **'model-name'**
  String get assistantProviderModelHint;

  /// No description provided for @assistantProviderModelRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the model name.'**
  String get assistantProviderModelRequired;

  /// No description provided for @assistantProviderPrivacy.
  ///
  /// In en, this message translates to:
  /// **'The key is stored encrypted on our servers and is only used to call the provider you name here.'**
  String get assistantProviderPrivacy;

  /// No description provided for @assistantProviderRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove provider'**
  String get assistantProviderRemove;

  /// No description provided for @assistantProviderRemovedToast.
  ///
  /// In en, this message translates to:
  /// **'Provider removed'**
  String get assistantProviderRemovedToast;

  /// No description provided for @assistantProviderRemoveError.
  ///
  /// In en, this message translates to:
  /// **'Could not remove the provider.'**
  String get assistantProviderRemoveError;

  /// No description provided for @assistantProviderRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'The assistant will go back to the included provider, which needs OpenBudget Plus.'**
  String get assistantProviderRemoveMessage;

  /// No description provided for @assistantProviderRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this provider?'**
  String get assistantProviderRemoveTitle;

  /// No description provided for @assistantProviderReplace.
  ///
  /// In en, this message translates to:
  /// **'Use a different provider'**
  String get assistantProviderReplace;

  /// No description provided for @assistantProviderSave.
  ///
  /// In en, this message translates to:
  /// **'Save provider'**
  String get assistantProviderSave;

  /// No description provided for @assistantProviderSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Your provider is connected'**
  String get assistantProviderSavedTitle;

  /// No description provided for @assistantProviderSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Provider saved'**
  String get assistantProviderSavedToast;

  /// No description provided for @assistantProviderSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save the provider.'**
  String get assistantProviderSaveError;

  /// No description provided for @assistantProviderSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Use your own OpenAI-compatible provider'**
  String get assistantProviderSettingsHint;

  /// No description provided for @assistantProviderSettingsRow.
  ///
  /// In en, this message translates to:
  /// **'Assistant provider'**
  String get assistantProviderSettingsRow;

  /// No description provided for @assistantProviderTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant provider'**
  String get assistantProviderTitle;

  /// No description provided for @assistantProviderUrlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Use a full HTTPS URL that points at the provider.'**
  String get assistantProviderUrlInvalid;

  /// No description provided for @assistantProviderUrlRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the provider\'s HTTPS base URL.'**
  String get assistantProviderUrlRequired;

  /// No description provided for @assistantRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get assistantRetry;

  /// No description provided for @assistantSend.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get assistantSend;

  /// No description provided for @assistantSuggestionCuts.
  ///
  /// In en, this message translates to:
  /// **'Where can I cut spending?'**
  String get assistantSuggestionCuts;

  /// No description provided for @assistantSuggestionGoals.
  ///
  /// In en, this message translates to:
  /// **'Am I on track for my goals?'**
  String get assistantSuggestionGoals;

  /// No description provided for @assistantSuggestionTax.
  ///
  /// In en, this message translates to:
  /// **'How much tax will I owe this year?'**
  String get assistantSuggestionTax;

  /// No description provided for @assistantTitle.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get assistantTitle;

  /// No description provided for @assistantToolGetTaxReport.
  ///
  /// In en, this message translates to:
  /// **'Looked at your tax report'**
  String get assistantToolGetTaxReport;

  /// No description provided for @assistantToolListBudgets.
  ///
  /// In en, this message translates to:
  /// **'Looked at your plan'**
  String get assistantToolListBudgets;

  /// No description provided for @assistantToolListEnvelopes.
  ///
  /// In en, this message translates to:
  /// **'Looked at your envelopes'**
  String get assistantToolListEnvelopes;

  /// No description provided for @assistantToolListTaxCategories.
  ///
  /// In en, this message translates to:
  /// **'Looked at tax categories'**
  String get assistantToolListTaxCategories;

  /// No description provided for @assistantToolProposeEnvelopeTax.
  ///
  /// In en, this message translates to:
  /// **'Drafted an envelope tax change'**
  String get assistantToolProposeEnvelopeTax;

  /// No description provided for @assistantToolProposeMoveMoney.
  ///
  /// In en, this message translates to:
  /// **'Drafted a money move'**
  String get assistantToolProposeMoveMoney;

  /// No description provided for @assistantToolProposeTransactionTax.
  ///
  /// In en, this message translates to:
  /// **'Drafted a tax category change'**
  String get assistantToolProposeTransactionTax;

  /// No description provided for @assistantToolSearchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Searched your transactions'**
  String get assistantToolSearchTransactions;

  /// No description provided for @assistantToolUnknown.
  ///
  /// In en, this message translates to:
  /// **'Looked something up'**
  String get assistantToolUnknown;

  /// No description provided for @assistantTyping.
  ///
  /// In en, this message translates to:
  /// **'The assistant is thinking…'**
  String get assistantTyping;

  /// No description provided for @assistantUntitledConversation.
  ///
  /// In en, this message translates to:
  /// **'Untitled conversation'**
  String get assistantUntitledConversation;

  /// No description provided for @assistantUsageLoading.
  ///
  /// In en, this message translates to:
  /// **'Checking this month\'s usage…'**
  String get assistantUsageLoading;

  /// No description provided for @assistantUsageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Usage isn\'t available right now.'**
  String get assistantUsageUnavailable;

  /// No description provided for @assistantUsageZen.
  ///
  /// In en, this message translates to:
  /// **'{used} of {allowance} used this month'**
  String assistantUsageZen(String used, String allowance);

  /// No description provided for @plusTitle.
  ///
  /// In en, this message translates to:
  /// **'OpenBudget Plus'**
  String get plusTitle;

  /// No description provided for @plusNavSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tax reports, the assistant and more'**
  String get plusNavSubtitle;

  /// No description provided for @plusHeroHeadline.
  ///
  /// In en, this message translates to:
  /// **'Get more from every envelope'**
  String get plusHeroHeadline;

  /// No description provided for @plusHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Tax reports, a built-in assistant that knows your budget, and room to bring your own agent.'**
  String get plusHeroBody;

  /// No description provided for @plusPriceAmount.
  ///
  /// In en, this message translates to:
  /// **'\$20'**
  String get plusPriceAmount;

  /// No description provided for @plusPricePeriod.
  ///
  /// In en, this message translates to:
  /// **'a month'**
  String get plusPricePeriod;

  /// No description provided for @plusPriceNote.
  ///
  /// In en, this message translates to:
  /// **'Cancel whenever you like.'**
  String get plusPriceNote;

  /// No description provided for @plusIncludedUsage.
  ///
  /// In en, this message translates to:
  /// **'\$5 of assistant usage included every month'**
  String get plusIncludedUsage;

  /// No description provided for @plusBenefitsTitle.
  ///
  /// In en, this message translates to:
  /// **'What you get'**
  String get plusBenefitsTitle;

  /// No description provided for @plusBenefitTaxTitle.
  ///
  /// In en, this message translates to:
  /// **'Tax reports'**
  String get plusBenefitTaxTitle;

  /// No description provided for @plusBenefitTaxBody.
  ///
  /// In en, this message translates to:
  /// **'UK, US, Nigeria and Germany, built from your own transactions.'**
  String get plusBenefitTaxBody;

  /// No description provided for @plusBenefitAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'The assistant'**
  String get plusBenefitAssistantTitle;

  /// No description provided for @plusBenefitAssistantBody.
  ///
  /// In en, this message translates to:
  /// **'Ask questions about your money, with \$5 of usage included each month.'**
  String get plusBenefitAssistantBody;

  /// No description provided for @plusBenefitAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Bring your own agent'**
  String get plusBenefitAgentTitle;

  /// No description provided for @plusBenefitAgentBody.
  ///
  /// In en, this message translates to:
  /// **'Connect an OpenAI-compatible provider and use your own key.'**
  String get plusBenefitAgentBody;

  /// No description provided for @plusChooseRail.
  ///
  /// In en, this message translates to:
  /// **'Choose how to pay'**
  String get plusChooseRail;

  /// No description provided for @plusStripeButton.
  ///
  /// In en, this message translates to:
  /// **'Pay with card'**
  String get plusStripeButton;

  /// No description provided for @plusStripeNote.
  ///
  /// In en, this message translates to:
  /// **'Secure checkout opens in your browser.'**
  String get plusStripeNote;

  /// No description provided for @plusSolanaButton.
  ///
  /// In en, this message translates to:
  /// **'Pay with USDC'**
  String get plusSolanaButton;

  /// No description provided for @plusSolanaNote.
  ///
  /// In en, this message translates to:
  /// **'Subscribe from a Solana wallet on this device.'**
  String get plusSolanaNote;

  /// No description provided for @plusStoreAppleButton.
  ///
  /// In en, this message translates to:
  /// **'Subscribe in the App Store'**
  String get plusStoreAppleButton;

  /// No description provided for @plusStoreGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Subscribe on Google Play'**
  String get plusStoreGoogleButton;

  /// No description provided for @plusStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Store purchases are unavailable in this build.'**
  String get plusStoreUnavailable;

  /// No description provided for @plusStoreHint.
  ///
  /// In en, this message translates to:
  /// **'Billed through your store account. Cancel any time in your store settings.'**
  String get plusStoreHint;

  /// No description provided for @plusRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get plusRestorePurchases;

  /// No description provided for @plusRestoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored.'**
  String get plusRestoreSuccess;

  /// No description provided for @plusPurchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchase complete. Your plan will update in a moment.'**
  String get plusPurchaseSuccess;

  /// No description provided for @plusRefreshButton.
  ///
  /// In en, this message translates to:
  /// **'I\'ve paid, refresh'**
  String get plusRefreshButton;

  /// No description provided for @plusRefreshNote.
  ///
  /// In en, this message translates to:
  /// **'After checkout, come back and check your plan.'**
  String get plusRefreshNote;

  /// No description provided for @plusPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Your OpenBudget Plus plan'**
  String get plusPlanTitle;

  /// No description provided for @plusSource.
  ///
  /// In en, this message translates to:
  /// **'Paid with {source}'**
  String plusSource(String source);

  /// No description provided for @plusSourceStripe.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get plusSourceStripe;

  /// No description provided for @plusSourceAppStore.
  ///
  /// In en, this message translates to:
  /// **'App Store'**
  String get plusSourceAppStore;

  /// No description provided for @plusSourcePlayStore.
  ///
  /// In en, this message translates to:
  /// **'Google Play'**
  String get plusSourcePlayStore;

  /// No description provided for @plusSourceSolana.
  ///
  /// In en, this message translates to:
  /// **'Solana'**
  String get plusSourceSolana;

  /// No description provided for @plusStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get plusStatusActive;

  /// No description provided for @plusStatusPastDue.
  ///
  /// In en, this message translates to:
  /// **'Past due'**
  String get plusStatusPastDue;

  /// No description provided for @plusStatusCanceled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get plusStatusCanceled;

  /// No description provided for @plusStatusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get plusStatusExpired;

  /// No description provided for @plusRenewsOn.
  ///
  /// In en, this message translates to:
  /// **'Renews on {date}'**
  String plusRenewsOn(String date);

  /// No description provided for @plusEndsOn.
  ///
  /// In en, this message translates to:
  /// **'Ends on {date}'**
  String plusEndsOn(String date);

  /// No description provided for @plusEndedOn.
  ///
  /// In en, this message translates to:
  /// **'Ended on {date}'**
  String plusEndedOn(String date);

  /// No description provided for @plusManage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get plusManage;

  /// No description provided for @plusManageSolanaBody.
  ///
  /// In en, this message translates to:
  /// **'Cancel from the wallet that approved this subscription. OpenBudget stops charging when the on-chain subscription ends.'**
  String get plusManageSolanaBody;

  /// No description provided for @plusLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your plan…'**
  String get plusLoading;

  /// No description provided for @plusLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your plan'**
  String get plusLoadError;

  /// No description provided for @plusLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection, then try again.'**
  String get plusLoadErrorBody;

  /// No description provided for @plusRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get plusRetry;

  /// No description provided for @plusCheckoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment received. Checking your plan…'**
  String get plusCheckoutSuccess;

  /// No description provided for @plusCheckoutCancelled.
  ///
  /// In en, this message translates to:
  /// **'Checkout cancelled. Nothing was charged.'**
  String get plusCheckoutCancelled;

  /// No description provided for @plusFailureCancelled.
  ///
  /// In en, this message translates to:
  /// **'Nothing was charged.'**
  String get plusFailureCancelled;

  /// No description provided for @plusFailureRejected.
  ///
  /// In en, this message translates to:
  /// **'The wallet request was cancelled.'**
  String get plusFailureRejected;

  /// No description provided for @plusFailureUnavailable.
  ///
  /// In en, this message translates to:
  /// **'That payment method is not available right now.'**
  String get plusFailureUnavailable;

  /// No description provided for @plusFailureFailed.
  ///
  /// In en, this message translates to:
  /// **'That did not work. Try again.'**
  String get plusFailureFailed;

  /// No description provided for @plusPriceCurrencyNote.
  ///
  /// In en, this message translates to:
  /// **'OpenBudget Plus is billed in US dollars.'**
  String get plusPriceCurrencyNote;

  /// No description provided for @agentAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Agent access'**
  String get agentAccessTitle;

  /// No description provided for @agentAccessSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Claude Code or another MCP client'**
  String get agentAccessSettingsSubtitle;

  /// No description provided for @agentAccessIntro.
  ///
  /// In en, this message translates to:
  /// **'Personal access tokens let external agents such as Claude Code and Codex read your budgets and tax reports over MCP.'**
  String get agentAccessIntro;

  /// No description provided for @agentAccessTokenName.
  ///
  /// In en, this message translates to:
  /// **'Token name'**
  String get agentAccessTokenName;

  /// No description provided for @agentAccessTokenNameHint.
  ///
  /// In en, this message translates to:
  /// **'Claude Code'**
  String get agentAccessTokenNameHint;

  /// No description provided for @agentAccessNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for this token.'**
  String get agentAccessNameRequired;

  /// No description provided for @agentAccessCanPropose.
  ///
  /// In en, this message translates to:
  /// **'Can propose changes'**
  String get agentAccessCanPropose;

  /// No description provided for @agentAccessCanProposeHint.
  ///
  /// In en, this message translates to:
  /// **'The agent can suggest budget and tax changes. You still apply or dismiss them in OpenBudget.'**
  String get agentAccessCanProposeHint;

  /// No description provided for @agentAccessCreate.
  ///
  /// In en, this message translates to:
  /// **'Create token'**
  String get agentAccessCreate;

  /// No description provided for @agentAccessCreating.
  ///
  /// In en, this message translates to:
  /// **'Creating token…'**
  String get agentAccessCreating;

  /// No description provided for @agentAccessTokensSection.
  ///
  /// In en, this message translates to:
  /// **'Your tokens'**
  String get agentAccessTokensSection;

  /// No description provided for @agentAccessEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No agent tokens yet'**
  String get agentAccessEmptyTitle;

  /// No description provided for @agentAccessEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Create a token above, then point your MCP client at the server.'**
  String get agentAccessEmptyBody;

  /// No description provided for @agentAccessTokenPrefix.
  ///
  /// In en, this message translates to:
  /// **'{prefix}…'**
  String agentAccessTokenPrefix(String prefix);

  /// No description provided for @agentAccessCreated.
  ///
  /// In en, this message translates to:
  /// **'Created {date}'**
  String agentAccessCreated(String date);

  /// No description provided for @agentAccessLastUsed.
  ///
  /// In en, this message translates to:
  /// **'Last used {date}'**
  String agentAccessLastUsed(String date);

  /// No description provided for @agentAccessNeverUsed.
  ///
  /// In en, this message translates to:
  /// **'Never used'**
  String get agentAccessNeverUsed;

  /// No description provided for @agentAccessRevoked.
  ///
  /// In en, this message translates to:
  /// **'Revoked'**
  String get agentAccessRevoked;

  /// No description provided for @agentAccessRevoke.
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get agentAccessRevoke;

  /// No description provided for @agentAccessRevoking.
  ///
  /// In en, this message translates to:
  /// **'Revoking…'**
  String get agentAccessRevoking;

  /// No description provided for @agentAccessRevokeTitle.
  ///
  /// In en, this message translates to:
  /// **'Revoke this token?'**
  String get agentAccessRevokeTitle;

  /// No description provided for @agentAccessRevokeMessage.
  ///
  /// In en, this message translates to:
  /// **'Any agent using this token stops working immediately. This cannot be undone.'**
  String get agentAccessRevokeMessage;

  /// No description provided for @agentAccessRevokeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Revoke token'**
  String get agentAccessRevokeConfirm;

  /// No description provided for @agentAccessRevokedToast.
  ///
  /// In en, this message translates to:
  /// **'Token revoked.'**
  String get agentAccessRevokedToast;

  /// No description provided for @agentAccessTokenDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Your new token'**
  String get agentAccessTokenDialogTitle;

  /// No description provided for @agentAccessTokenDialogWarning.
  ///
  /// In en, this message translates to:
  /// **'Copy this token now. It is shown once and cannot be recovered; the server stores only its hash.'**
  String get agentAccessTokenDialogWarning;

  /// No description provided for @agentAccessCopyToken.
  ///
  /// In en, this message translates to:
  /// **'Copy token'**
  String get agentAccessCopyToken;

  /// No description provided for @agentAccessCopiedToast.
  ///
  /// In en, this message translates to:
  /// **'Token copied to clipboard.'**
  String get agentAccessCopiedToast;

  /// No description provided for @agentAccessFailure.
  ///
  /// In en, this message translates to:
  /// **'That did not work. Try again.'**
  String get agentAccessFailure;

  /// No description provided for @agentAccessLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your agent tokens…'**
  String get agentAccessLoading;

  /// No description provided for @agentAccessLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your agent tokens'**
  String get agentAccessLoadError;

  /// No description provided for @agentAccessLoadErrorBody.
  ///
  /// In en, this message translates to:
  /// **'Check your connection, then try again.'**
  String get agentAccessLoadErrorBody;

  /// No description provided for @agentAccessRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get agentAccessRetry;

  /// No description provided for @agentAccessSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect a client'**
  String get agentAccessSetupTitle;

  /// No description provided for @agentAccessSetupBody.
  ///
  /// In en, this message translates to:
  /// **'Point your MCP client at the server\'s /mcp route and send the token as a Bearer token. Agents never change your money directly: they propose changes, and you apply or dismiss them in OpenBudget.'**
  String get agentAccessSetupBody;

  /// No description provided for @agentAccessSetupExample.
  ///
  /// In en, this message translates to:
  /// **'Authorization: Bearer obk_…'**
  String get agentAccessSetupExample;

  /// No description provided for @whatsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get whatsNewTitle;

  /// No description provided for @whatsNewVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String whatsNewVersion(String version);

  /// No description provided for @whatsNewGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get whatsNewGotIt;

  /// No description provided for @whatsNewSettingHint.
  ///
  /// In en, this message translates to:
  /// **'See what changed in this update'**
  String get whatsNewSettingHint;

  /// No description provided for @whatsNewEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing new to read'**
  String get whatsNewEmptyTitle;

  /// No description provided for @whatsNewEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'This version does not have release notes. You\'re all caught up.'**
  String get whatsNewEmptyMessage;

  /// No description provided for @whatsNewErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t read these notes'**
  String get whatsNewErrorTitle;

  /// No description provided for @whatsNewErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'The release notes for this version aren\'t in a format OpenBudget can show.'**
  String get whatsNewErrorMessage;

  /// No description provided for @booksEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get booksEntryTitle;

  /// No description provided for @booksEntryEnableTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable double-entry books'**
  String get booksEntryEnableTitle;

  /// No description provided for @booksEnableDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable double-entry books?'**
  String get booksEnableDialogTitle;

  /// No description provided for @booksEnableDialogBody.
  ///
  /// In en, this message translates to:
  /// **'Books add double-entry accounting to {budget}: a chart of accounts, journals and a trial balance. Envelopes keep working as they do today. The switch is one-way — once books are on for this budget, they cannot be turned back off.'**
  String booksEnableDialogBody(String budget);

  /// No description provided for @booksEnableDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Enable books'**
  String get booksEnableDialogConfirm;

  /// No description provided for @booksEnabledToast.
  ///
  /// In en, this message translates to:
  /// **'Double-entry books are on'**
  String get booksEnabledToast;

  /// No description provided for @booksEnableError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t enable books. Try again.'**
  String get booksEnableError;

  /// No description provided for @booksTitle.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get booksTitle;

  /// No description provided for @booksTabJournals.
  ///
  /// In en, this message translates to:
  /// **'Journals'**
  String get booksTabJournals;

  /// No description provided for @booksTabAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get booksTabAccounts;

  /// No description provided for @booksTabTrialBalance.
  ///
  /// In en, this message translates to:
  /// **'Trial balance'**
  String get booksTabTrialBalance;

  /// No description provided for @booksLockDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Lock date'**
  String get booksLockDateLabel;

  /// No description provided for @booksLockDateNone.
  ///
  /// In en, this message translates to:
  /// **'No lock date set'**
  String get booksLockDateNone;

  /// No description provided for @booksLockDateAction.
  ///
  /// In en, this message translates to:
  /// **'Set lock date'**
  String get booksLockDateAction;

  /// No description provided for @booksLockDateHint.
  ///
  /// In en, this message translates to:
  /// **'Posting and reversing on or before this date is blocked.'**
  String get booksLockDateHint;

  /// No description provided for @booksLockDateSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Books locked through {date}'**
  String booksLockDateSavedToast(String date);

  /// No description provided for @booksLockDateError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t set the lock date. Try again.'**
  String get booksLockDateError;

  /// No description provided for @booksJournalsLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your journals.'**
  String get booksJournalsLoadError;

  /// No description provided for @booksAccountsLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your chart of accounts.'**
  String get booksAccountsLoadError;

  /// No description provided for @booksTrialBalanceLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load the trial balance.'**
  String get booksTrialBalanceLoadError;

  /// No description provided for @booksNewJournalTooltip.
  ///
  /// In en, this message translates to:
  /// **'New journal'**
  String get booksNewJournalTooltip;

  /// No description provided for @booksJournalEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No journals yet'**
  String get booksJournalEmptyTitle;

  /// No description provided for @booksJournalEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Post your first journal to start the books.'**
  String get booksJournalEmptyMessage;

  /// No description provided for @booksJournalEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'New journal'**
  String get booksJournalEmptyAction;

  /// No description provided for @booksAccountsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get booksAccountsEmptyTitle;

  /// No description provided for @booksAccountsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your chart of accounts is seeded when books are enabled.'**
  String get booksAccountsEmptyMessage;

  /// No description provided for @ledgerStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get ledgerStatusDraft;

  /// No description provided for @ledgerStatusPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get ledgerStatusPosted;

  /// No description provided for @ledgerStatusReversed.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get ledgerStatusReversed;

  /// No description provided for @ledgerAccountTypeAsset.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get ledgerAccountTypeAsset;

  /// No description provided for @ledgerAccountTypeLiability.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get ledgerAccountTypeLiability;

  /// No description provided for @ledgerAccountTypeEquity.
  ///
  /// In en, this message translates to:
  /// **'Equity'**
  String get ledgerAccountTypeEquity;

  /// No description provided for @ledgerAccountTypeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get ledgerAccountTypeIncome;

  /// No description provided for @ledgerAccountTypeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get ledgerAccountTypeExpense;

  /// No description provided for @ledgerAccountArchived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get ledgerAccountArchived;

  /// No description provided for @ledgerTrialBalanceBalanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get ledgerTrialBalanceBalanced;

  /// No description provided for @ledgerTrialBalanceUnbalanced.
  ///
  /// In en, this message translates to:
  /// **'Out of balance by {difference}'**
  String ledgerTrialBalanceUnbalanced(String difference);

  /// No description provided for @ledgerTrialBalanceEmpty.
  ///
  /// In en, this message translates to:
  /// **'No posted movement through this date yet.'**
  String get ledgerTrialBalanceEmpty;

  /// No description provided for @ledgerColumnDebit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get ledgerColumnDebit;

  /// No description provided for @ledgerColumnCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get ledgerColumnCredit;

  /// No description provided for @ledgerTotalsLabel.
  ///
  /// In en, this message translates to:
  /// **'Totals'**
  String get ledgerTotalsLabel;

  /// No description provided for @ledgerTrialBalanceAsOfLabel.
  ///
  /// In en, this message translates to:
  /// **'As of'**
  String get ledgerTrialBalanceAsOfLabel;

  /// No description provided for @ledgerRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get ledgerRetry;

  /// No description provided for @journalNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New journal'**
  String get journalNewTitle;

  /// No description provided for @journalDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalDetailTitle;

  /// No description provided for @journalDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get journalDateLabel;

  /// No description provided for @journalReferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get journalReferenceLabel;

  /// No description provided for @journalNarrationLabel.
  ///
  /// In en, this message translates to:
  /// **'Narration'**
  String get journalNarrationLabel;

  /// No description provided for @journalLineAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get journalLineAccountLabel;

  /// No description provided for @journalLinePickAccount.
  ///
  /// In en, this message translates to:
  /// **'Choose an account'**
  String get journalLinePickAccount;

  /// No description provided for @journalLineSideDebit.
  ///
  /// In en, this message translates to:
  /// **'Debit'**
  String get journalLineSideDebit;

  /// No description provided for @journalLineSideCredit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get journalLineSideCredit;

  /// No description provided for @journalLineAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get journalLineAmountLabel;

  /// No description provided for @journalAddLine.
  ///
  /// In en, this message translates to:
  /// **'Add line'**
  String get journalAddLine;

  /// No description provided for @journalRemoveLineTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove line'**
  String get journalRemoveLineTooltip;

  /// No description provided for @journalDebitsLabel.
  ///
  /// In en, this message translates to:
  /// **'Debits'**
  String get journalDebitsLabel;

  /// No description provided for @journalCreditsLabel.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get journalCreditsLabel;

  /// No description provided for @journalDifferenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get journalDifferenceLabel;

  /// No description provided for @journalBalancedLabel.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get journalBalancedLabel;

  /// No description provided for @journalUnbalancedLabel.
  ///
  /// In en, this message translates to:
  /// **'Out of balance by {difference}'**
  String journalUnbalancedLabel(String difference);

  /// No description provided for @journalIssueAtLeastTwoLines.
  ///
  /// In en, this message translates to:
  /// **'A journal needs at least two lines.'**
  String get journalIssueAtLeastTwoLines;

  /// No description provided for @journalIssueLineOneSideRequired.
  ///
  /// In en, this message translates to:
  /// **'Line {index} needs a positive amount on one side.'**
  String journalIssueLineOneSideRequired(int index);

  /// No description provided for @journalIssueUnbalancedFunctional.
  ///
  /// In en, this message translates to:
  /// **'Debits and credits do not match yet.'**
  String get journalIssueUnbalancedFunctional;

  /// No description provided for @journalIssueFallback.
  ///
  /// In en, this message translates to:
  /// **'This journal is not ready to save.'**
  String get journalIssueFallback;

  /// No description provided for @journalAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get journalAmountInvalid;

  /// No description provided for @journalSaveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get journalSaveDraft;

  /// No description provided for @journalDraftSavedToast.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get journalDraftSavedToast;

  /// No description provided for @journalPost.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get journalPost;

  /// No description provided for @journalPostConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Post this journal?'**
  String get journalPostConfirmTitle;

  /// No description provided for @journalPostConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Posting makes the journal permanent: posted journals cannot be edited or deleted. Mistakes are fixed by posting a reversal.'**
  String get journalPostConfirmBody;

  /// No description provided for @journalPostConfirmAction.
  ///
  /// In en, this message translates to:
  /// **'Post journal'**
  String get journalPostConfirmAction;

  /// No description provided for @journalPostedToast.
  ///
  /// In en, this message translates to:
  /// **'Journal posted'**
  String get journalPostedToast;

  /// No description provided for @journalPostError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t post this journal. Try again.'**
  String get journalPostError;

  /// No description provided for @journalSaveError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t save this draft. Try again.'**
  String get journalSaveError;

  /// No description provided for @journalDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this draft?'**
  String get journalDeleteTitle;

  /// No description provided for @journalDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The draft and its lines will be removed. This cannot be undone.'**
  String get journalDeleteBody;

  /// No description provided for @journalDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete draft'**
  String get journalDeleteAction;

  /// No description provided for @journalDeletedToast.
  ///
  /// In en, this message translates to:
  /// **'Draft deleted'**
  String get journalDeletedToast;

  /// No description provided for @journalDeleteError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t delete this draft. Try again.'**
  String get journalDeleteError;

  /// No description provided for @journalReadOnlyBanner.
  ///
  /// In en, this message translates to:
  /// **'Posted journals cannot be edited. Fix mistakes with a reversal.'**
  String get journalReadOnlyBanner;

  /// No description provided for @journalReverse.
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get journalReverse;

  /// No description provided for @journalReverseConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reverse this journal?'**
  String get journalReverseConfirmTitle;

  /// No description provided for @journalReverseConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'A mirror journal will undo this one on the date you choose. The original stays in the books, marked reversed.'**
  String get journalReverseConfirmBody;

  /// No description provided for @journalReverseDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Reversal date'**
  String get journalReverseDateLabel;

  /// No description provided for @journalReverseAction.
  ///
  /// In en, this message translates to:
  /// **'Reverse journal'**
  String get journalReverseAction;

  /// No description provided for @journalReversedToast.
  ///
  /// In en, this message translates to:
  /// **'Journal reversed'**
  String get journalReversedToast;

  /// No description provided for @journalReverseError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t reverse this journal. Try again.'**
  String get journalReverseError;

  /// No description provided for @journalReversalOfLabel.
  ///
  /// In en, this message translates to:
  /// **'Reversal of {reference}'**
  String journalReversalOfLabel(String reference);

  /// No description provided for @journalPostedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Posted {date}'**
  String journalPostedAtLabel(String date);

  /// No description provided for @journalEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit draft'**
  String get journalEditTitle;

  /// No description provided for @journalEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit draft'**
  String get journalEditAction;

  /// No description provided for @journalLinesHeader.
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get journalLinesHeader;

  /// No description provided for @journalLinesLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load this journal\'s lines. Try again.'**
  String get journalLinesLoadError;

  /// No description provided for @createEntityTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your books'**
  String get createEntityTitle;

  /// No description provided for @createEntityKindLabel.
  ///
  /// In en, this message translates to:
  /// **'What are these books for?'**
  String get createEntityKindLabel;

  /// No description provided for @entityKindPersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get entityKindPersonal;

  /// No description provided for @entityKindSoleTrader.
  ///
  /// In en, this message translates to:
  /// **'Sole trader'**
  String get entityKindSoleTrader;

  /// No description provided for @entityKindCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get entityKindCompany;

  /// No description provided for @createEntityCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get createEntityCountry;

  /// No description provided for @createEntityTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Time zone'**
  String get createEntityTimeZone;

  /// No description provided for @createEntityFiscalYearEnd.
  ///
  /// In en, this message translates to:
  /// **'Financial year ends'**
  String get createEntityFiscalYearEnd;

  /// No description provided for @createEntityFiscalYearValue.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of month {month}'**
  String createEntityFiscalYearValue(int day, int month);

  /// No description provided for @createEntityTaxYear.
  ///
  /// In en, this message translates to:
  /// **'Tax year'**
  String get createEntityTaxYear;

  /// A tax year as two dates, such as '6 Apr to 5 Apr'.
  ///
  /// In en, this message translates to:
  /// **'{start} to {end}'**
  String createEntityTaxYearValue(String start, String end);

  /// No description provided for @createEntityPickCountry.
  ///
  /// In en, this message translates to:
  /// **'Choose a country'**
  String get createEntityPickCountry;

  /// No description provided for @createEntityPickCurrency.
  ///
  /// In en, this message translates to:
  /// **'Choose a currency'**
  String get createEntityPickCurrency;

  /// No description provided for @createEntityPickTimeZone.
  ///
  /// In en, this message translates to:
  /// **'Choose a time zone'**
  String get createEntityPickTimeZone;

  /// No description provided for @createEntitySearchCountries.
  ///
  /// In en, this message translates to:
  /// **'Search countries or codes'**
  String get createEntitySearchCountries;

  /// No description provided for @createEntitySearchCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Search currencies or codes'**
  String get createEntitySearchCurrencies;

  /// No description provided for @createEntitySearchTimeZones.
  ///
  /// In en, this message translates to:
  /// **'Search time zones'**
  String get createEntitySearchTimeZones;

  /// No description provided for @createEntityClearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get createEntityClearSearch;

  /// No description provided for @createEntityPickerSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get createEntityPickerSelected;

  /// No description provided for @createEntityResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String createEntityResultCount(int count);

  /// No description provided for @createEntityNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches “{query}”'**
  String createEntityNoMatch(String query);

  /// No description provided for @createEntitySectionTaxRules.
  ///
  /// In en, this message translates to:
  /// **'With tax rules built in'**
  String get createEntitySectionTaxRules;

  /// No description provided for @createEntitySectionAllCountries.
  ///
  /// In en, this message translates to:
  /// **'All countries'**
  String get createEntitySectionAllCountries;

  /// No description provided for @createEntitySectionCountryCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Used in {country}'**
  String createEntitySectionCountryCurrencies(String country);

  /// No description provided for @createEntitySectionAllCurrencies.
  ///
  /// In en, this message translates to:
  /// **'All currencies'**
  String get createEntitySectionAllCurrencies;

  /// No description provided for @entityDeleteNameField.
  ///
  /// In en, this message translates to:
  /// **'Type the entity\'s name to confirm'**
  String get entityDeleteNameField;

  /// No description provided for @homeBudgetNetWorthShort.
  ///
  /// In en, this message translates to:
  /// **'Net worth {amount}'**
  String homeBudgetNetWorthShort(String amount);

  /// No description provided for @homeBudgetUncategorised.
  ///
  /// In en, this message translates to:
  /// **'{count} uncategorised'**
  String homeBudgetUncategorised(int count);

  /// No description provided for @homeBudgetDueRecurring.
  ///
  /// In en, this message translates to:
  /// **'{count} recurring due'**
  String homeBudgetDueRecurring(int count);

  /// No description provided for @homeBudgetPendingProposals.
  ///
  /// In en, this message translates to:
  /// **'{count} proposals'**
  String homeBudgetPendingProposals(int count);

  /// No description provided for @netWorthAssetsLabel.
  ///
  /// In en, this message translates to:
  /// **'Assets {amount}'**
  String netWorthAssetsLabel(String amount);

  /// No description provided for @netWorthLiabilitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'Liabilities {amount}'**
  String netWorthLiabilitiesLabel(String amount);

  /// No description provided for @netWorthMissingCurrencies.
  ///
  /// In en, this message translates to:
  /// **'Not included: no rate for {currencies}'**
  String netWorthMissingCurrencies(String currencies);

  /// No description provided for @netWorthRatesFrom.
  ///
  /// In en, this message translates to:
  /// **'Rates as of {date}'**
  String netWorthRatesFrom(String date);

  /// No description provided for @netWorthIncompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Some accounts are not included'**
  String get netWorthIncompleteTitle;

  /// No description provided for @netWorthIncompleteLine.
  ///
  /// In en, this message translates to:
  /// **'Not included: {count, plural, =1{1 account} other{{count} accounts}} in {currency} (no rate)'**
  String netWorthIncompleteLine(int count, String currency);

  /// No description provided for @netWorthTabByEntity.
  ///
  /// In en, this message translates to:
  /// **'By entity'**
  String get netWorthTabByEntity;

  /// No description provided for @netWorthTabByCurrency.
  ///
  /// In en, this message translates to:
  /// **'By currency'**
  String get netWorthTabByCurrency;

  /// No description provided for @netWorthTabByAccount.
  ///
  /// In en, this message translates to:
  /// **'By account'**
  String get netWorthTabByAccount;

  /// No description provided for @netWorthValuedOn.
  ///
  /// In en, this message translates to:
  /// **'Valued {date}'**
  String netWorthValuedOn(String date);

  /// No description provided for @netWorthRateLine.
  ///
  /// In en, this message translates to:
  /// **'1 {native} = {rate} {reporting}'**
  String netWorthRateLine(String native, String rate, String reporting);

  /// No description provided for @netWorthIncompletePoint.
  ///
  /// In en, this message translates to:
  /// **'Point based on incomplete data'**
  String get netWorthIncompletePoint;

  /// No description provided for @netWorthHistory3M.
  ///
  /// In en, this message translates to:
  /// **'3M'**
  String get netWorthHistory3M;

  /// No description provided for @netWorthHistory1Y.
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get netWorthHistory1Y;

  /// No description provided for @netWorthHistoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get netWorthHistoryAll;

  /// No description provided for @netWorthAccountsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 account} other{{count} accounts}}'**
  String netWorthAccountsCount(int count);

  /// No description provided for @entityCountInNetWorth.
  ///
  /// In en, this message translates to:
  /// **'Count in my net worth'**
  String get entityCountInNetWorth;

  /// No description provided for @entityCountInNetWorthHint.
  ///
  /// In en, this message translates to:
  /// **'Include this entity\'s accounts in your combined net worth.'**
  String get entityCountInNetWorthHint;

  /// No description provided for @settingsReportingCurrency.
  ///
  /// In en, this message translates to:
  /// **'Reporting currency'**
  String get settingsReportingCurrency;

  /// No description provided for @addAccountCurrencyQuestion.
  ///
  /// In en, this message translates to:
  /// **'What currency is this account in?'**
  String get addAccountCurrencyQuestion;

  /// No description provided for @addAccountSelectCurrencyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Pick a currency'**
  String get addAccountSelectCurrencyPlaceholder;

  /// No description provided for @addAccountOnBudgetQuestion.
  ///
  /// In en, this message translates to:
  /// **'Budget this account together with the plan'**
  String get addAccountOnBudgetQuestion;

  /// No description provided for @addAccountOnBudgetHint.
  ///
  /// In en, this message translates to:
  /// **'On-budget accounts feed Ready to Assign.'**
  String get addAccountOnBudgetHint;

  /// No description provided for @addAccountTrackByQuestion.
  ///
  /// In en, this message translates to:
  /// **'How should this account be tracked?'**
  String get addAccountTrackByQuestion;

  /// No description provided for @addAccountTrackByTransactions.
  ///
  /// In en, this message translates to:
  /// **'By transactions'**
  String get addAccountTrackByTransactions;

  /// No description provided for @addAccountTrackByValue.
  ///
  /// In en, this message translates to:
  /// **'By value'**
  String get addAccountTrackByValue;

  /// No description provided for @addAccountOpeningToday.
  ///
  /// In en, this message translates to:
  /// **'Opening balance is from today'**
  String get addAccountOpeningToday;

  /// No description provided for @addAccountTypeProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get addAccountTypeProperty;

  /// No description provided for @addAccountTypeVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get addAccountTypeVehicle;

  /// No description provided for @addAccountTypeOtherAsset.
  ///
  /// In en, this message translates to:
  /// **'Other asset'**
  String get addAccountTypeOtherAsset;

  /// No description provided for @accountGroupAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get accountGroupAssets;

  /// No description provided for @accountGroupLiabilities.
  ///
  /// In en, this message translates to:
  /// **'Liabilities'**
  String get accountGroupLiabilities;

  /// No description provided for @accountBaseEquivalent.
  ///
  /// In en, this message translates to:
  /// **'≈ {amount} in base currency'**
  String accountBaseEquivalent(String amount);

  /// No description provided for @accountsConnectionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Bank connections'**
  String get accountsConnectionsTitle;

  /// No description provided for @accountsConnectionPending.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get accountsConnectionPending;

  /// No description provided for @accountsConnectionSynced.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get accountsConnectionSynced;

  /// No description provided for @accountsConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get accountsConnectionFailed;

  /// No description provided for @accountsConnectionRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get accountsConnectionRemove;

  /// No description provided for @accountsConnectionRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this connection?'**
  String get accountsConnectionRemoveTitle;

  /// No description provided for @accountsConnectionRemoveMessage.
  ///
  /// In en, this message translates to:
  /// **'The bank link is removed. Accounts keep their history.'**
  String get accountsConnectionRemoveMessage;

  /// No description provided for @transactionTransferPeer.
  ///
  /// In en, this message translates to:
  /// **'to {accountName}'**
  String transactionTransferPeer(String accountName);

  /// No description provided for @transactionBaseAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} in base currency'**
  String transactionBaseAmount(String amount);

  /// No description provided for @accountDetailReconcile.
  ///
  /// In en, this message translates to:
  /// **'Reconcile'**
  String get accountDetailReconcile;

  /// No description provided for @accountDetailReportedBalance.
  ///
  /// In en, this message translates to:
  /// **'Bank says {amount}'**
  String accountDetailReportedBalance(String amount);

  /// No description provided for @accountDetailClearedLabel.
  ///
  /// In en, this message translates to:
  /// **'Cleared {amount}'**
  String accountDetailClearedLabel(String amount);

  /// No description provided for @accountDetailUnclearedLabel.
  ///
  /// In en, this message translates to:
  /// **'Uncleared {amount}'**
  String accountDetailUnclearedLabel(String amount);

  /// No description provided for @accountDetailValuationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Value history'**
  String get accountDetailValuationsTitle;

  /// No description provided for @accountDetailUpdateValue.
  ///
  /// In en, this message translates to:
  /// **'Update value'**
  String get accountDetailUpdateValue;

  /// No description provided for @accountDetailValuedOn.
  ///
  /// In en, this message translates to:
  /// **'Valued {date}'**
  String accountDetailValuedOn(String date);

  /// No description provided for @accountDetailHoldingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Holdings'**
  String get accountDetailHoldingsTitle;

  /// No description provided for @accountHoldingsValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Value {amount}'**
  String accountHoldingsValueLabel(String amount);

  /// No description provided for @accountHoldingsCostLabel.
  ///
  /// In en, this message translates to:
  /// **'Cost {amount}'**
  String accountHoldingsCostLabel(String amount);

  /// No description provided for @accountHoldingsPnlLabel.
  ///
  /// In en, this message translates to:
  /// **'P&L {amount}'**
  String accountHoldingsPnlLabel(String amount);

  /// No description provided for @accountHoldingsQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity {quantity}'**
  String accountHoldingsQuantityLabel(String quantity);

  /// No description provided for @accountReconcileTitle.
  ///
  /// In en, this message translates to:
  /// **'Reconcile {accountName}'**
  String accountReconcileTitle(String accountName);

  /// No description provided for @accountReconcileStatementField.
  ///
  /// In en, this message translates to:
  /// **'Statement balance'**
  String get accountReconcileStatementField;

  /// No description provided for @accountReconcileDifference.
  ///
  /// In en, this message translates to:
  /// **'Difference {amount}'**
  String accountReconcileDifference(String amount);

  /// No description provided for @accountReconcileCreateAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Post the difference as an adjustment'**
  String get accountReconcileCreateAdjustment;

  /// No description provided for @accountReconcileSubmit.
  ///
  /// In en, this message translates to:
  /// **'Reconcile'**
  String get accountReconcileSubmit;

  /// No description provided for @accountReconcileSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions reconciled'**
  String accountReconcileSuccess(int count);

  /// No description provided for @accountReconcileNoDifference.
  ///
  /// In en, this message translates to:
  /// **'Already balanced — nothing to do'**
  String get accountReconcileNoDifference;

  /// No description provided for @accountValuationValueField.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get accountValuationValueField;

  /// No description provided for @accountValuationDateField.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get accountValuationDateField;

  /// No description provided for @accountValuationSaved.
  ///
  /// In en, this message translates to:
  /// **'Value saved'**
  String get accountValuationSaved;

  /// No description provided for @accountDetailTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get accountDetailTransactionsTitle;

  /// No description provided for @transactionLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get transactionLoadMore;

  /// No description provided for @accountReconcileFailed.
  ///
  /// In en, this message translates to:
  /// **'Reconcile failed — check the statement balance'**
  String get accountReconcileFailed;

  /// No description provided for @fxRateLoading.
  ///
  /// In en, this message translates to:
  /// **'Fetching rate…'**
  String get fxRateLoading;

  /// No description provided for @fxRateSetRate.
  ///
  /// In en, this message translates to:
  /// **'Set rate'**
  String get fxRateSetRate;

  /// No description provided for @fxRateSetRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Use your own rate'**
  String get fxRateSetRateTitle;

  /// No description provided for @fxRateRateField.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate'**
  String get fxRateRateField;

  /// No description provided for @fxRateInvalidRate.
  ///
  /// In en, this message translates to:
  /// **'Enter a positive rate, e.g. 0.79'**
  String get fxRateInvalidRate;

  /// No description provided for @fxRateUseThisRate.
  ///
  /// In en, this message translates to:
  /// **'Use this rate'**
  String get fxRateUseThisRate;

  /// No description provided for @fxRateStale.
  ///
  /// In en, this message translates to:
  /// **'Stale'**
  String get fxRateStale;

  /// No description provided for @fxRateApproximate.
  ///
  /// In en, this message translates to:
  /// **'≈ {amount}'**
  String fxRateApproximate(String amount);

  /// No description provided for @fxRateUnavailableTitle.
  ///
  /// In en, this message translates to:
  /// **'No exchange rate'**
  String get fxRateUnavailableTitle;

  /// No description provided for @linesEditorSplit.
  ///
  /// In en, this message translates to:
  /// **'Split into lines'**
  String get linesEditorSplit;

  /// No description provided for @linesEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Lines'**
  String get linesEditorTitle;

  /// No description provided for @linesEditorLineLabel.
  ///
  /// In en, this message translates to:
  /// **'Line {index}'**
  String linesEditorLineLabel(int index);

  /// No description provided for @linesEditorLineAmount.
  ///
  /// In en, this message translates to:
  /// **'Line {index} amount'**
  String linesEditorLineAmount(int index);

  /// No description provided for @linesEditorAddLine.
  ///
  /// In en, this message translates to:
  /// **'Add a line'**
  String get linesEditorAddLine;

  /// No description provided for @linesEditorRemaining.
  ///
  /// In en, this message translates to:
  /// **'{amount} left to allocate'**
  String linesEditorRemaining(String amount);

  /// A transaction's calendar date, written the way the reader's locale writes dates.
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String transactionDateFullLabel(DateTime date);

  /// No description provided for @importTargetAccount.
  ///
  /// In en, this message translates to:
  /// **'Import into account'**
  String get importTargetAccount;

  /// No description provided for @transferFrom.
  ///
  /// In en, this message translates to:
  /// **'From account'**
  String get transferFrom;

  /// No description provided for @transferTo.
  ///
  /// In en, this message translates to:
  /// **'To account'**
  String get transferTo;

  /// No description provided for @transferAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transferAmountLabel;

  /// No description provided for @transferSentLabel.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get transferSentLabel;

  /// No description provided for @transferReceivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get transferReceivedLabel;

  /// No description provided for @transferUseTodayRate.
  ///
  /// In en, this message translates to:
  /// **'Use today\'s rate'**
  String get transferUseTodayRate;

  /// No description provided for @transferEnvelopeLeavesPlan.
  ///
  /// In en, this message translates to:
  /// **'Envelope (money leaves the plan)'**
  String get transferEnvelopeLeavesPlan;

  /// No description provided for @transferCrossEntityHint.
  ///
  /// In en, this message translates to:
  /// **'Transfers between your entities convert into each entity\'s base currency. Money never appears or disappears.'**
  String get transferCrossEntityHint;

  /// No description provided for @budgetBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Budget breakdown'**
  String get budgetBreakdownTitle;

  /// No description provided for @budgetBreakdownHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the amount to see where it comes from'**
  String get budgetBreakdownHint;

  /// No description provided for @budgetBreakdownFxDifference.
  ///
  /// In en, this message translates to:
  /// **'Exchange-rate difference'**
  String get budgetBreakdownFxDifference;

  /// No description provided for @budgetBreakdownOverspentLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Overspent last month'**
  String get budgetBreakdownOverspentLastMonth;

  /// No description provided for @budgetBreakdownAssignedInFuture.
  ///
  /// In en, this message translates to:
  /// **'Assigned in future months'**
  String get budgetBreakdownAssignedInFuture;

  /// No description provided for @budgetBreakdownAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available in envelopes'**
  String get budgetBreakdownAvailable;

  /// No description provided for @budgetBreakdownUncategorised.
  ///
  /// In en, this message translates to:
  /// **'Uncategorised transactions'**
  String get budgetBreakdownUncategorised;

  /// No description provided for @reviewTransactionsSelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String reviewTransactionsSelectedCount(int count);

  /// No description provided for @transactionKindTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transactionKindTransfer;

  /// No description provided for @transactionBaseEquivalent.
  ///
  /// In en, this message translates to:
  /// **'≈ {amount} in base currency'**
  String transactionBaseEquivalent(String amount);

  /// No description provided for @loadMoreButton.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMoreButton;

  /// No description provided for @creditCardOwes.
  ///
  /// In en, this message translates to:
  /// **'Owes {amount}'**
  String creditCardOwes(String amount);

  /// No description provided for @setGoalSetAsideMonthlyLabel.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get setGoalSetAsideMonthlyLabel;

  /// No description provided for @setGoalTargetBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Target balance'**
  String get setGoalTargetBalanceLabel;

  /// No description provided for @setGoalTargetByDateLabel.
  ///
  /// In en, this message translates to:
  /// **'By the date'**
  String get setGoalTargetByDateLabel;

  /// No description provided for @setGoalHaveAmount.
  ///
  /// In en, this message translates to:
  /// **'To have {amount}'**
  String setGoalHaveAmount(String amount);

  /// No description provided for @envelopeDeleteMoveHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Move its history to which envelope?'**
  String get envelopeDeleteMoveHistoryTitle;

  /// No description provided for @netWorthHeadlineEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Combined net worth'**
  String get netWorthHeadlineEyebrow;

  /// No description provided for @netWorthHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get netWorthHistoryTitle;

  /// No description provided for @netWorthIncompleteLegend.
  ///
  /// In en, this message translates to:
  /// **'Dashed where a currency has no rate'**
  String get netWorthIncompleteLegend;

  /// No description provided for @netWorthNoRate.
  ///
  /// In en, this message translates to:
  /// **'No {currency} rate · not counted'**
  String netWorthNoRate(String currency);

  /// No description provided for @netWorthEntityIncomplete.
  ///
  /// In en, this message translates to:
  /// **'Leaves out unconverted accounts'**
  String get netWorthEntityIncomplete;

  /// No description provided for @netWorthRateDated.
  ///
  /// In en, this message translates to:
  /// **'{rateLine} · {date}'**
  String netWorthRateDated(String rateLine, String date);

  /// No description provided for @fxRateSourceMarket.
  ///
  /// In en, this message translates to:
  /// **'market rate'**
  String get fxRateSourceMarket;

  /// No description provided for @fxRateSourceImplied.
  ///
  /// In en, this message translates to:
  /// **'implied rate'**
  String get fxRateSourceImplied;

  /// No description provided for @fxRateSourceManual.
  ///
  /// In en, this message translates to:
  /// **'your rate'**
  String get fxRateSourceManual;

  /// No description provided for @fxRateSourceIdentity.
  ///
  /// In en, this message translates to:
  /// **'same currency'**
  String get fxRateSourceIdentity;

  /// No description provided for @fxRateConvertsTo.
  ///
  /// In en, this message translates to:
  /// **'Converts to about {amount}'**
  String fxRateConvertsTo(String amount);

  /// No description provided for @accountDetailBalanceEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get accountDetailBalanceEyebrow;

  /// No description provided for @accountDetailValueEyebrow.
  ///
  /// In en, this message translates to:
  /// **'Current value'**
  String get accountDetailValueEyebrow;

  /// No description provided for @accountReconcileClearedNow.
  ///
  /// In en, this message translates to:
  /// **'Cleared in OpenBudget'**
  String get accountReconcileClearedNow;

  /// No description provided for @accountReconcileMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches your statement'**
  String get accountReconcileMatches;

  /// No description provided for @accountValuationChange.
  ///
  /// In en, this message translates to:
  /// **'{amount} since the last valuation'**
  String accountValuationChange(String amount);

  /// No description provided for @accountHoldingsUnpriced.
  ///
  /// In en, this message translates to:
  /// **'No price yet'**
  String get accountHoldingsUnpriced;

  /// A transaction row's second line: the payee or other detail, then the date.
  ///
  /// In en, this message translates to:
  /// **'{detail} · {date}'**
  String transactionDetailAndDate(String detail, String date);

  /// After the change in net worth over the chart's range.
  ///
  /// In en, this message translates to:
  /// **'since {date}'**
  String netWorthChangeSince(String date);

  /// Under a foreign account's balance when no rate converts it into the base currency.
  ///
  /// In en, this message translates to:
  /// **'No {currency} rate'**
  String accountNoRateShort(String currency);
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
