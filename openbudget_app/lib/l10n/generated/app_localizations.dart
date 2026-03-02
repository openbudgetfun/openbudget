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

  /// No description provided for @settingsAppIconPrimary.
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get settingsAppIconPrimary;

  /// No description provided for @settingsAppIconV1.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get settingsAppIconV1;

  /// No description provided for @settingsAppIconV2.
  ///
  /// In en, this message translates to:
  /// **'Compass'**
  String get settingsAppIconV2;

  /// No description provided for @settingsAppIconV3.
  ///
  /// In en, this message translates to:
  /// **'Sprout'**
  String get settingsAppIconV3;

  /// No description provided for @settingsAppIconV4.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get settingsAppIconV4;

  /// No description provided for @settingsAppIconV5.
  ///
  /// In en, this message translates to:
  /// **'Arrow'**
  String get settingsAppIconV5;

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
  /// **'App Version 1.0.0 (1)'**
  String get settingsVersion;

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
  /// **'Transfer completed'**
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
  /// **'Add Account Type Line Of Credit'**
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
  /// **'Add Account Type Mortgage'**
  String get addAccountTypeMortgage;

  /// No description provided for @addAccountTypeAutoLoan.
  ///
  /// In en, this message translates to:
  /// **'Add Account Type Auto Loan'**
  String get addAccountTypeAutoLoan;

  /// No description provided for @addAccountTypeStudentLoan.
  ///
  /// In en, this message translates to:
  /// **'Add Account Type Student Loan'**
  String get addAccountTypeStudentLoan;

  /// No description provided for @addAccountTypePersonalLoan.
  ///
  /// In en, this message translates to:
  /// **'Add Account Type Personal Loan'**
  String get addAccountTypePersonalLoan;

  /// No description provided for @addAccountTypeMedicalDebt.
  ///
  /// In en, this message translates to:
  /// **'Add Account Type Medical Debt'**
  String get addAccountTypeMedicalDebt;

  /// No description provided for @addAccountTypeOtherDebt.
  ///
  /// In en, this message translates to:
  /// **'Add Account Type Other Debt'**
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
  /// **'Add Account Type Liability'**
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
  /// **'Add Account Type Solana Wallet'**
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
  String accountDetailLoanInMonth(String month);

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
