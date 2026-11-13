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
  static const taxYearLabel = 'Tax year 2026';

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

/// The multi-currency fixture the screen tour runs on: a GBP household with
/// GBP, USD and NGN accounts, a valued property, a Solana wallet and a
/// credit card, plus a GBP company. USD rates are stale and NGN has no rate
/// at all, so the net worth screens show the Stale badge and the
/// incomplete-currency card.
abstract final class MultiCurrencyData {
  static const householdName = 'Household';
  static const String householdId = TestData.gbpEntityId;
  static const String studioId = TestData.companyEntityId;

  static const mainCheckingId = '00000000-0000-0000-0000-000000000101';
  static const usdCheckingId = '00000000-0000-0000-0000-000000000102';
  static const nairaSavingsId = '00000000-0000-0000-0000-000000000105';
  static const visaId = '00000000-0000-0000-0000-000000000104';
  static const flatId = '00000000-0000-0000-0000-000000000106';
  static const walletAccountId = '00000000-0000-0000-0000-000000000107';
  static const studioCurrentId = '00000000-0000-0000-0000-000000000108';
  static const walletId = '00000000-0000-0000-0000-000000000701';

  static const nairaSavingsName = 'Lagos Savings';
  static const flatName = 'Flat in Leeds';
  static const walletAccountName = 'Phantom Wallet';
  static const studioCurrentName = 'Studio Current';

  static final DateTime asOf = DateTime.utc(2026, 11, 8);
  static final DateTime staleRateDate = DateTime.utc(2026, 11);

  static Entity household() => TestData.gbpEntity(name: householdName);

  static Entity studio() => TestData.gbpEntity(
    id: studioId,
    name: TestData.companyEntityName,
    kind: EntityKind.company,
  );

  static Account mainChecking() => TestData.checkingAccount();

  static Account usdChecking() => TestData.usdCheckingAccount();

  static Account nairaSavings() => TestData.checkingAccount(
    id: nairaSavingsId,
    name: nairaSavingsName,
    balanceMinor: 45000000,
    currencyCode: 'NGN',
    kind: AccountKind.savings,
    onBudget: false,
  );

  static Account visa() => TestData.creditCardAccount();

  static Account flat() => TestData.checkingAccount(
    id: flatId,
    name: flatName,
    balanceMinor: 31000000,
    kind: AccountKind.property,
    onBudget: false,
  ).copyWith(balanceSource: AccountBalanceSource.valuations);

  static Account walletAccount() => TestData.checkingAccount(
    id: walletAccountId,
    name: walletAccountName,
    balanceMinor: 184050,
    currencyCode: 'USD',
    kind: AccountKind.crypto,
    onBudget: false,
  );

  /// The household's accounts in the order the server lists them.
  static List<Account> householdAccounts() => [
    mainChecking(),
    usdChecking(),
    nairaSavings(),
    flat(),
    walletAccount(),
    visa(),
  ];

  static AccountBalancesView usdBalances() => AccountBalancesView(
    accountId: UuidValue.fromString(usdCheckingId),
    currencyCode: 'USD',
    balanceMinor: 100000,
    clearedMinor: 103000,
    unclearedMinor: -3000,
    reportedBalanceMinor: 103000,
    reportedBalanceAt: DateTime.utc(2026, 11, 7),
  );

  static List<TransactionView> usdTransactions() => [
    _usdView(
      id: '00000000-0000-0000-0000-000000000211',
      description: 'Figma subscription',
      payee: 'Figma',
      amountMinor: -3000,
      baseAmountMinor: -2370,
      date: DateTime.utc(2026, 11, 6),
      status: TransactionStatus.uncleared,
    ),
    _usdView(
      id: '00000000-0000-0000-0000-000000000212',
      description: 'Client invoice #42',
      payee: 'Northwind Inc.',
      amountMinor: 120000,
      baseAmountMinor: 94800,
      date: DateTime.utc(2026, 11, 3),
      status: TransactionStatus.cleared,
    ),
    _usdView(
      id: '00000000-0000-0000-0000-000000000213',
      description: 'Coffee in Brooklyn',
      payee: 'Devoción',
      amountMinor: -650,
      baseAmountMinor: -514,
      date: DateTime.utc(2026, 9, 3),
      status: TransactionStatus.reconciled,
    ),
  ];

  static TransactionView _usdView({
    required String id,
    required String description,
    required String payee,
    required int amountMinor,
    required int baseAmountMinor,
    required DateTime date,
    required TransactionStatus status,
  }) => TransactionView(
    transaction: Transaction(
      id: UuidValue.fromString(id),
      entityId: UuidValue.fromString(householdId),
      accountId: UuidValue.fromString(usdCheckingId),
      date: date,
      amountMinor: amountMinor,
      baseAmountMinor: baseAmountMinor,
      fxRate: TestData.usdToGbpRate,
      fxRateDate: date,
      description: description,
      status: status,
    ),
    lines: const [],
    accountCurrencyCode: 'USD',
    accountName: TestData.usdCheckingAccountName,
    payeeName: payee,
  );

  static List<AccountValuation> flatValuations() => [
    for (final (date, value) in [
      (DateTime.utc(2026, 10, 31), 31000000),
      (DateTime.utc(2026, 4, 30), 30450000),
      (DateTime.utc(2025, 10, 31), 29800000),
    ])
      AccountValuation(
        accountId: UuidValue.fromString(flatId),
        valuationDate: date,
        valueMinor: value,
        source: ValuationSource.manual,
      ),
  ];

  static Wallet wallet() => Wallet(
    id: UuidValue.fromString(walletId),
    entityId: UuidValue.fromString(householdId),
    accountId: UuidValue.fromString(walletAccountId),
    network: WalletNetwork.solanaMainnet,
    address: '5xQfTbN7p1sWw8bP',
    syncStatus: SyncStatus.synced,
  );

  static List<WalletHolding> walletHoldings() => [
    WalletHolding(
      walletId: UuidValue.fromString(walletId),
      network: WalletNetwork.solanaMainnet,
      assetId: 'So11111111111111111111111111111111111111112',
      symbol: 'SOL',
      name: 'Solana',
      decimals: 9,
      quantityRaw: BigInt.parse('12500000000'),
      priceCurrencyCode: 'USD',
      valueMinor: 175000,
      costBasisMinor: 140000,
    ),
    WalletHolding(
      walletId: UuidValue.fromString(walletId),
      network: WalletNetwork.solanaMainnet,
      assetId: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
      symbol: 'USDC',
      name: 'USD Coin',
      decimals: 6,
      quantityRaw: BigInt.parse('90500000'),
      priceCurrencyCode: 'USD',
      valueMinor: 9050,
      costBasisMinor: 9050,
    ),
  ];

  // Net worth in GBP. USD is converted at a stale 0.79; NGN has no rate.
  static const int _gbpAssetsMinor = 250000 + 31000000 + 1200000;
  static const int _usdNativeMinor = 100000 + 184050;
  static const int _usdConvertedMinor = 79000 + 145400;
  static const int assetsMinor = _gbpAssetsMinor + _usdConvertedMinor;
  static const int liabilitiesMinor = 50000;
  static const int netWorthMinor = assetsMinor - liabilitiesMinor;
  static const int householdNetWorthMinor = netWorthMinor - 1200000;

  static NetWorthView netWorth() => NetWorthView(
    currencyCode: 'GBP',
    asOf: asOf,
    assetsMinor: assetsMinor,
    liabilitiesMinor: liabilitiesMinor,
    netWorthMinor: netWorthMinor,
    isComplete: false,
    missingCurrencyCodes: const ['NGN'],
    hasStaleRates: true,
    currencies: [
      NetWorthCurrencyRow(
        currencyCode: 'GBP',
        nativeMinor: _gbpAssetsMinor - liabilitiesMinor,
        convertedMinor: _gbpAssetsMinor - liabilitiesMinor,
        fxRate: '1',
        fxRateDate: asOf,
        isStale: false,
        accountCount: 4,
      ),
      NetWorthCurrencyRow(
        currencyCode: 'USD',
        nativeMinor: _usdNativeMinor,
        convertedMinor: _usdConvertedMinor,
        fxRate: TestData.usdToGbpRate,
        fxRateDate: staleRateDate,
        fxRateSource: FxRateSource.market,
        isStale: true,
        accountCount: 2,
      ),
      NetWorthCurrencyRow(
        currencyCode: 'NGN',
        nativeMinor: 45000000,
        isStale: false,
        accountCount: 1,
      ),
    ],
    entities: [
      NetWorthEntityRow(
        entityId: UuidValue.fromString(householdId),
        name: householdName,
        kind: EntityKind.individual,
        assetsMinor: assetsMinor - 1200000,
        liabilitiesMinor: liabilitiesMinor,
        netWorthMinor: householdNetWorthMinor,
        isComplete: false,
      ),
      NetWorthEntityRow(
        entityId: UuidValue.fromString(studioId),
        name: TestData.companyEntityName,
        kind: EntityKind.company,
        assetsMinor: 1200000,
        liabilitiesMinor: 0,
        netWorthMinor: 1200000,
        isComplete: true,
      ),
    ],
    accounts: [
      _row(
        mainCheckingId,
        TestData.checkingAccountName,
        AccountKind.checking,
        'GBP',
        250000,
        250000,
      ),
      _row(
        usdCheckingId,
        TestData.usdCheckingAccountName,
        AccountKind.checking,
        'USD',
        100000,
        79000,
      ),
      _row(
        nairaSavingsId,
        nairaSavingsName,
        AccountKind.savings,
        'NGN',
        45000000,
        null,
      ),
      _row(
        flatId,
        flatName,
        AccountKind.property,
        'GBP',
        31000000,
        31000000,
        valuationDate: DateTime.utc(2026, 10, 31),
      ),
      _row(
        walletAccountId,
        walletAccountName,
        AccountKind.crypto,
        'USD',
        184050,
        145400,
      ),
      _row(
        studioCurrentId,
        studioCurrentName,
        AccountKind.checking,
        'GBP',
        1200000,
        1200000,
        entityId: studioId,
      ),
      _row(
        visaId,
        TestData.creditCardAccountName,
        AccountKind.creditCard,
        'GBP',
        -50000,
        -50000,
        isLiability: true,
      ),
    ],
  );

  /// Net worth for one entity, as `report.netWorth(entityIds: ...)` scopes it.
  static NetWorthView netWorthFor(Set<String> entityIds) {
    final view = netWorth();
    return view.copyWith(
      entities: [
        for (final row in view.entities)
          if (entityIds.contains(row.entityId.toString())) row,
      ],
      accounts: [
        for (final row in view.accounts)
          if (entityIds.contains(row.entityId.toString())) row,
      ],
    );
  }

  static NetWorthAccountRow _row(
    String id,
    String name,
    AccountKind kind,
    String currencyCode,
    int balanceMinor,
    int? convertedMinor, {
    String entityId = householdId,
    bool isLiability = false,
    DateTime? valuationDate,
  }) => NetWorthAccountRow(
    accountId: UuidValue.fromString(id),
    entityId: UuidValue.fromString(entityId),
    name: name,
    kind: kind,
    isLiability: isLiability,
    currencyCode: currencyCode,
    balanceMinor: balanceMinor,
    convertedMinor: convertedMinor,
    valuationDate: valuationDate,
  );

  /// Ninety-odd daily points that wander upwards; the last week is
  /// incomplete because the NGN account has no rate.
  static NetWorthHistoryView history(NetWorthGranularity granularity) {
    const days = 92;
    final start = asOf.subtract(const Duration(days: days - 1));
    final points = <NetWorthPoint>[
      for (var day = 0; day < days; day++)
        () {
          // A steady climb with a slow swell and a dip after a big bill:
          // deterministic, no Random.
          final swell = ((day % 14) - 7).abs() * 1800;
          final dip = day > 48 && day < 62
              ? -(31 - (day - 55).abs() * 4) * 1500
              : 0;
          final value = netWorthMinor - (days - 1 - day) * 3100 - swell + dip;
          return NetWorthPoint(
            date: start.add(Duration(days: day)),
            assetsMinor: value + liabilitiesMinor,
            liabilitiesMinor: liabilitiesMinor,
            netWorthMinor: day == days - 1 ? netWorthMinor : value,
            isComplete: day < days - 7,
          );
        }(),
    ];
    return NetWorthHistoryView(
      currencyCode: 'GBP',
      granularity: granularity,
      points: points,
    );
  }

  static List<EntitySummaryView> summaries() => [
    EntitySummaryView(
      entity: household(),
      month: 202611,
      readyToAssignMinor: 42000,
      overspentEnvelopeCount: 1,
      netWorthMinor: householdNetWorthMinor,
      netWorthComplete: false,
      uncategorizedCount: 3,
      pendingProposalCount: 0,
      dueRecurringCount: 1,
    ),
    EntitySummaryView(
      entity: studio(),
      month: 202611,
      readyToAssignMinor: 0,
      overspentEnvelopeCount: 0,
      netWorthMinor: 1200000,
      netWorthComplete: true,
      uncategorizedCount: 0,
      pendingProposalCount: 2,
      dueRecurringCount: 0,
    ),
  ];

  static FxQuoteView quote(String from, String to) => FxQuoteView(
    fromCurrencyCode: from,
    toCurrencyCode: to,
    rate: from == 'USD' && to == 'GBP' ? TestData.usdToGbpRate : '1.27',
    rateDate: asOf,
    source: FxRateSource.market,
    isStale: false,
  );
}

/// What the create-entity flow picks: a Kenyan individual, a country with no
/// tax pack, and Russia, a country OpenBudget does not serve.
abstract final class AnyCountryData {
  static const kenyaName = 'Kenya';
  static const kenyaQuery = 'kenya';
  static const kenyaCode = 'KE';
  static const kenyaCurrencyRow = 'Kenyan Shilling (KES)';
  static const kenyaTimeZone = 'Africa/Nairobi';

  /// Kenya's individual tax year is the calendar year.
  static const kenyaTaxYear = 'Jan 1 to Dec 31';

  /// What a person types for the United Kingdom.
  static const ukAlias = 'uk';
  static const ukName = 'United Kingdom';

  static const unservableName = 'Russia';
  static const unservableQuery = 'russia';

  static const usDollarName = 'US Dollar';
  static const usDollarQuery = 'USD';
  static const usDollarCurrencyRow = 'US Dollar (USD)';

  /// The entity id the fake creator hands back.
  static const String createdEntityId = TestData.gbpEntityId;
}

/// What the tax export flow shows and opens: a Kenyan individual, a country
/// with no tax pack, whose summary is the universal panel's.
abstract final class TaxExportData {
  static const kenyaIntroTitle = 'No full tax rules for Kenya yet';
  static const vatRatesTitle = 'VAT rates';
  static const kenyaStandardRate = '16%';
  static const kenyaAuthorityUrl = 'https://www.kra.go.ke';
  static const exportButtonLabel = 'Export tax summary';

  /// The signed link the fake server hands out.
  static const exportLink =
      'https://api.openbudget.test/tax/export?token=signed-token-for-flow';

  /// The tax year the fake summary reports.
  static const taxYear = 2026;
  static const taxYearLabel = 'Tax year 2026';
}
