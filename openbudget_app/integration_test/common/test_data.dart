import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// Test fixtures used across Patrol E2E tests. Everything is an [Entity]
/// with a base currency; accounts carry an [AccountKind] and their own
/// currency; every amount is in minor units (`*Minor`).
abstract final class TestData {
  // Auth
  static const validEmail = 'test@openbudget.app';
  static const validPassword = 'password123';

  // Entities
  static const entityName = 'My First Budget';
  static const gbpEntityId = '00000000-0000-0000-0000-000000000010';
  static const usdEntityId = '00000000-0000-0000-0000-000000000011';
  static const ownerId = '00000000-0000-0000-0000-000000000099';
  static const companyEntityName = 'Studio Ltd';
  static const companyEntityId = '00000000-0000-0000-0000-000000000012';

  /// The GBP entity every default flow runs against.
  static Entity gbpEntity({
    String id = gbpEntityId,
    String name = entityName,
    EntityKind kind = EntityKind.individual,
  }) => Entity(
    id: UuidValue.fromString(id),
    name: name,
    kind: kind,
    countryCode: 'GB',
    baseCurrencyCode: 'GBP',
    timeZone: 'Europe/London',
    fiscalYearEndMonth: 4,
    fiscalYearEndDay: 5,
    ownerId: UuidValue.fromString(ownerId),
    createdAt: DateTime.utc(2026),
  );

  /// A US entity, for flows that need a second base currency.
  static Entity usdEntity({String name = 'US Budget'}) =>
      gbpEntity(
        id: usdEntityId,
        name: name,
      ).copyWith(
        countryCode: 'US',
        baseCurrencyCode: 'USD',
        timeZone: 'America/New_York',
      );

  // Accounts
  static const checkingAccountName = 'Main Checking';
  static const savingsAccountName = 'Emergency Fund';
  static const creditCardAccountName = 'Visa Rewards';
  static const usdCheckingAccountName = 'USD Checking';

  /// A GBP checking account on budget.
  static Account checkingAccount({
    String id = '00000000-0000-0000-0000-000000000101',
    String entityId = gbpEntityId,
    String name = checkingAccountName,
    int balanceMinor = 250000,
    String currencyCode = 'GBP',
    AccountKind kind = AccountKind.checking,
    bool onBudget = true,
  }) => Account(
    id: UuidValue.fromString(id),
    name: name,
    kind: kind,
    balanceSource: AccountBalanceSource.transactions,
    balanceMinor: balanceMinor,
    currencyCode: currencyCode,
    entityId: UuidValue.fromString(entityId),
    onBudget: onBudget,
    sortOrder: 0,
  );

  /// A USD account inside the GBP entity — the foreign-currency fixture.
  static Account usdCheckingAccount({
    String id = '00000000-0000-0000-0000-000000000102',
    int balanceMinor = 100000,
    bool onBudget = true,
  }) => checkingAccount(
    id: id,
    name: usdCheckingAccountName,
    balanceMinor: balanceMinor,
    currencyCode: 'USD',
    onBudget: onBudget,
  );

  static Account savingsAccount({
    String id = '00000000-0000-0000-0000-000000000103',
    int balanceMinor = 100000,
  }) => checkingAccount(
    id: id,
    name: savingsAccountName,
    balanceMinor: balanceMinor,
    kind: AccountKind.savings,
  );

  static Account creditCardAccount({
    String id = '00000000-0000-0000-0000-000000000104',
    int balanceMinor = -50000,
  }) => checkingAccount(
    id: id,
    name: creditCardAccountName,
    balanceMinor: balanceMinor,
    kind: AccountKind.creditCard,
    onBudget: false,
  );

  // Transactions
  static const expenseDescription = 'Grocery Store';
  static const incomeDescription = 'Monthly Salary';
  static const transferDescription = 'To Savings';
  static const expenseAmountMinor = 5499;
  static const incomeAmountMinor = 350000;

  /// A foreign-currency expense on the USD account, seen from the GBP entity.
  static Transaction usdExpense({
    String id = '00000000-0000-0000-0000-000000000201',
    String accountId = '00000000-0000-0000-0000-000000000102',
    int amountMinor = -3000,
    DateTime? date,
  }) => Transaction(
    id: UuidValue.fromString(id),
    entityId: UuidValue.fromString(gbpEntityId),
    accountId: UuidValue.fromString(accountId),
    date: date ?? DateTime.utc(2026, 9, 3),
    amountMinor: amountMinor,
    baseAmountMinor: -2370,
    fxRate: '0.79',
    fxRateDate: DateTime.utc(2026, 9, 3),
    description: expenseDescription,
  );

  static TransactionView usdExpenseView() => TransactionView(
    transaction: usdExpense(),
    lines: [
      TransactionLine(
        id: UuidValue.fromString('00000000-0000-0000-0000-000000000202'),
        transactionId: UuidValue.fromString(
          '00000000-0000-0000-0000-000000000201',
        ),
        amountMinor: -3000,
        baseAmountMinor: -2370,
      ),
    ],
    accountCurrencyCode: 'USD',
    accountName: usdCheckingAccountName,
  );

  // Net worth (flow 1: GBP entity with a USD account)
  static const gbpNetWorthMinor = 250000;
  static const usdNativeMinor = 100000;
  static const usdConvertedMinor = 79000;
  static const usdToGbpRate = '0.79';
  static const int gbpNetWorthWithUsdMinor =
      gbpNetWorthMinor + usdConvertedMinor;

  /// Net worth for the GBP entity plus a converted USD account.
  static NetWorthView gbpNetWorthWithUsd({
    bool hasStaleRates = false,
  }) => NetWorthView(
    currencyCode: 'GBP',
    asOf: DateTime.utc(2026, 11, 8),
    assetsMinor: gbpNetWorthWithUsdMinor,
    liabilitiesMinor: 0,
    netWorthMinor: gbpNetWorthWithUsdMinor,
    isComplete: true,
    missingCurrencyCodes: const [],
    hasStaleRates: hasStaleRates,
    currencies: [
      NetWorthCurrencyRow(
        currencyCode: 'GBP',
        nativeMinor: gbpNetWorthMinor,
        convertedMinor: gbpNetWorthMinor,
        fxRate: '1',
        fxRateDate: DateTime.utc(2026, 11, 8),
        isStale: false,
        accountCount: 1,
      ),
      NetWorthCurrencyRow(
        currencyCode: 'USD',
        nativeMinor: usdNativeMinor,
        convertedMinor: usdConvertedMinor,
        fxRate: usdToGbpRate,
        fxRateDate: DateTime.utc(2026, 11, 8),
        isStale: hasStaleRates,
        accountCount: 1,
      ),
    ],
    entities: [
      NetWorthEntityRow(
        entityId: UuidValue.fromString(gbpEntityId),
        name: entityName,
        kind: EntityKind.individual,
        assetsMinor: gbpNetWorthWithUsdMinor,
        liabilitiesMinor: 0,
        netWorthMinor: gbpNetWorthWithUsdMinor,
        isComplete: true,
      ),
    ],
    accounts: [
      NetWorthAccountRow(
        accountId: UuidValue.fromString('00000000-0000-0000-0000-000000000101'),
        entityId: UuidValue.fromString(gbpEntityId),
        name: checkingAccountName,
        kind: AccountKind.checking,
        currencyCode: 'GBP',
        balanceMinor: gbpNetWorthMinor,
        convertedMinor: gbpNetWorthMinor,
        isLiability: false,
      ),
      NetWorthAccountRow(
        accountId: UuidValue.fromString('00000000-0000-0000-0000-000000000102'),
        entityId: UuidValue.fromString(gbpEntityId),
        name: usdCheckingAccountName,
        kind: AccountKind.checking,
        currencyCode: 'USD',
        balanceMinor: usdNativeMinor,
        convertedMinor: usdConvertedMinor,
        isLiability: false,
      ),
    ],
  );

  // Transfer (flow 2: GBP -> USD cross-currency)
  static const transferSentMinor = 10000;
  static const transferReceivedMinor = 7900;

  // Tax
  static const taxProfileTitle = 'Tax profile';
  static const taxSetupTitle = 'Set up taxes';
  static const taxBalanceDue = 'Balance due';
  static const taxDisclaimer =
      'Guidance only, not tax advice. Check figures with a qualified adviser '
      'before filing.';
  static const taxYearLabel = 'Tax year 2026/27';

  // Books (double-entry ledger)
  static const booksEnableTitle = 'Enable double-entry books';
  static const booksEnableConfirm = 'Enable books';
  static const booksEnabledToast = 'Double-entry books are on';
  static const journalReference = 'JB-2026-0099';
  static const draftJournalReference = 'JB-2026-0100';
  static const journalNarration = 'Client invoice';
  static const journalAmount = '50.00';
  static const bankAccountLabel = '1000 Bank';
  static const salesAccountLabel = '4000 Sales';
  static const balancedLabel = 'Balanced';
  static const postedLabel = 'Posted';
  static const reversedLabel = 'Reversed';
  static const trialBalanceTab = 'Trial balance';
  static const bankAccountRow = 'Bank';
  static const salesAccountRow = 'Sales';

  // Assistant
  static const assistantEntityId = '00000000-0000-0000-0000-000000000f01';
  static const assistantUserId = '00000000-0000-0000-0000-000000000f02';
  static const assistantConversationId = '00000000-0000-0000-0000-000000000f03';
  static const assistantProposalId = '00000000-0000-0000-0000-000000000f04';
  static const assistantSuggestion = 'Where can I cut spending?';
  static const assistantReply = r'You could free up $50 by trimming dining.';
  static const assistantProposalSummary =
      r'Move $50 from Dining Out to Groceries.';
  static const assistantToolLabel = 'Looked at your tax report';

  // Agent access
  static const agentAccessTokenId = '00000000-0000-0000-0000-000000000f06';
  static const agentAccessTokenName = 'Claude Code';
  static const agentAccessToken = 'obk_patrol_secret_token';
}
