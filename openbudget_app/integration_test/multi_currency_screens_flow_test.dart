import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_detail_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/institution_catalog_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/plaid_account_link_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/wallet_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_detail_screen.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_list_screen.dart';
import 'package:openbudget_app/src/features/accounts/screens/add_account_screen.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_list_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_summary_provider.dart';
import 'package:openbudget_app/src/features/home/screens/create_entity_screen.dart';
import 'package:openbudget_app/src/features/home/screens/home_screen.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/crypto_breakdown_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/screens/net_worth_screen.dart';
import 'package:openbudget_app/src/features/settings/providers/reporting_currency_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/duplicate_check_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_pages_provider.dart';
import 'package:openbudget_app/src/features/transactions/screens/add_expense_screen.dart';
import 'package:openbudget_app/src/features/transfers/screens/create_transfer_screen.dart';
import 'package:openbudget_app/src/providers/fx_rate_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';
import 'helpers/screenshot_capture.dart';

/// The multi-currency screens on the real theme, walked with a GBP
/// household holding USD and NGN accounts. USD rates are stale and NGN has
/// no rate, so every trust and incomplete state is on screen. Each test
/// captures the screen it lands on for visual review.
void main() {
  const household = MultiCurrencyData.householdId;

  patrolWidgetTest('home shows each entity and the combined net worth', (
    $,
  ) async {
    final tester = $.tester;
    await useScreenshotSurface(tester, ScreenshotSurface.phone);
    await _pumpTour(tester, initialLocation: homePath);

    final home = MultiCurrencyHomePage(tester);
    expect(home.combinedNetWorth, findsOneWidget);
    expect(home.entityCard(MultiCurrencyData.householdName), findsOneWidget);
    expect(home.entityCard(TestData.companyEntityName), findsOneWidget);
    expect(home.missingCurrencies('NGN'), findsOneWidget);
    await captureIntegrationScreenshot(tester, 'home-phone');
  });

  patrolWidgetTest('create entity shows the kind, country and currency', (
    $,
  ) async {
    final tester = $.tester;
    await useScreenshotSurface(tester, ScreenshotSurface.phone);
    await _pumpTour(tester, initialLocation: createEntityPath);

    final page = CreateEntityPage(tester);
    expect(page.title, findsOneWidget);
    expect(page.countryRow, findsOneWidget);
    await captureIntegrationScreenshot(tester, 'create-entity-phone');
  });

  patrolWidgetTest('the account type picker reads in plain words', ($) async {
    final tester = $.tester;
    await useScreenshotSurface(tester, ScreenshotSurface.phone);
    await _pumpTour(
      tester,
      initialLocation: '/budgets/$household/accounts/add',
    );

    final page = AccountTypePickerPage(tester);
    await page.open();
    await captureIntegrationScreenshot(tester, 'account-type-picker-phone');

    await scrollIntoView(tester, page.option('loan'));
    await captureIntegrationScreenshot(
      tester,
      'account-type-picker-loans-phone',
    );
    expect(find.text('Personal Loan'), findsOneWidget);
    expect(find.text('Mortgage'), findsOneWidget);
    expect(find.textContaining('Add Account Type'), findsNothing);

    await scrollIntoView(tester, page.option('crypto'));
    await captureIntegrationScreenshot(
      tester,
      'account-type-picker-tracking-phone',
    );
    expect(find.text('Solana Wallet'), findsOneWidget);
    expect(find.text('Property'), findsOneWidget);
  });

  for (final surface in ScreenshotSurface.values) {
    patrolWidgetTest(
      'account list groups assets and liabilities (${surface.name})',
      ($) async {
        final tester = $.tester;
        await useScreenshotSurface(tester, surface);
        await _pumpTour(
          tester,
          initialLocation: '/budgets/$household/accounts',
        );

        final page = AccountsTabPage(tester);
        expect(page.accountTile(TestData.usdCheckingAccountName), findsWidgets);
        // The USD account shows the server's GBP equivalent under it.
        expect(find.textContaining('£790.00'), findsWidgets);
        expect(find.text('No NGN rate'), findsOneWidget);
        await captureIntegrationScreenshot(
          tester,
          'account-list-${surface.name}',
        );
      },
    );
  }

  patrolWidgetTest(
    'USD account detail shows balances and the reconcile sheet',
    (
      $,
    ) async {
      final tester = $.tester;
      await useScreenshotSurface(tester, ScreenshotSurface.phone);
      await _pumpTour(
        tester,
        initialLocation:
            '/budgets/$household/accounts/${MultiCurrencyData.usdCheckingId}',
      );

      final page = AccountDetailPage(tester);
      expect(page.reconcileButton, findsOneWidget);
      expect(find.text('Figma subscription'), findsOneWidget);
      await captureIntegrationScreenshot(tester, 'account-detail-usd-phone');

      await page.openReconcileSheet();
      expect(page.reconcileSheet, findsOneWidget);
      expect(page.reconcileDifference, findsOneWidget);
      await captureIntegrationScreenshot(
        tester,
        'account-reconcile-sheet-phone',
      );

      // Dates read as calendar dates, never "2026-9-3".
      expect(find.textContaining('Sep 3, 2026'), findsOneWidget);
      expect(find.textContaining('2026-9-3'), findsNothing);
    },
  );

  patrolWidgetTest('property account detail shows its valuations', ($) async {
    final tester = $.tester;
    await useScreenshotSurface(tester, ScreenshotSurface.phone);
    await _pumpTour(
      tester,
      initialLocation:
          '/budgets/$household/accounts/${MultiCurrencyData.flatId}',
    );

    expect(find.text('£310,000.00'), findsWidgets);
    await captureIntegrationScreenshot(
      tester,
      'account-detail-valuations-phone',
    );
    expect(find.textContaining('Oct 31, 2026'), findsOneWidget);
  });

  patrolWidgetTest('wallet account detail shows its holdings', ($) async {
    final tester = $.tester;
    await useScreenshotSurface(tester, ScreenshotSurface.phone);
    await _pumpTour(
      tester,
      initialLocation:
          '/budgets/$household/accounts/${MultiCurrencyData.walletAccountId}',
    );

    // Each holding's name and ticker share one rich text ("Solana  SOL"),
    // and the chain stamp also reads "Solana".
    expect(find.textContaining('Solana  SOL'), findsOneWidget);
    expect(find.textContaining('USD Coin  USDC'), findsOneWidget);
    await captureIntegrationScreenshot(tester, 'account-detail-wallet-phone');
  });

  patrolWidgetTest(
    'expense on a USD account shows the live rate, lines and manual rate',
    ($) async {
      final tester = $.tester;
      await useScreenshotSurface(tester, ScreenshotSurface.phone);
      await _pumpTour(
        tester,
        initialLocation: '/budgets/$household/expenses/add',
        accounts: [
          MultiCurrencyData.usdChecking(),
          MultiCurrencyData.mainChecking(),
        ],
      );

      final page = ExpenseFxPage(tester);
      await tester.enterText(page.amountField, '30.00');
      await tester.pumpAndSettle();
      expect(page.fxLine, findsOneWidget);
      expect(find.textContaining('1 USD = 0.79 GBP'), findsOneWidget);
      await captureIntegrationScreenshot(tester, 'expense-fx-line-phone');

      await scrollAndTap(tester, page.splitButton);
      expect(page.linesEditor, findsOneWidget);
      // Bring the whole editor, its last line and "Add a line", into view.
      await tester.ensureVisible(find.text('Add a line'));
      await tester.pumpAndSettle();
      await captureIntegrationScreenshot(tester, 'expense-lines-editor-phone');

      await scrollIntoView(tester, page.setRateButton);
      await tester.tap(page.setRateButton);
      await tester.pumpAndSettle();
      expect(page.manualRateSheet, findsOneWidget);
      await captureIntegrationScreenshot(tester, 'expense-manual-rate-phone');
    },
  );

  patrolWidgetTest('cross-currency transfer shows Sent, Received and rate', (
    $,
  ) async {
    final tester = $.tester;
    await useScreenshotSurface(tester, ScreenshotSurface.phone);
    await _pumpTour(
      tester,
      initialLocation: '/budgets/$household/transfer',
    );

    final page = TransferPage(tester);
    await page.pickAccount(
      from: '${TestData.checkingAccountName} (GBP)',
      to: '${TestData.usdCheckingAccountName} (USD)',
    );
    await page.enterSent('100.00');
    await page.enterReceived('127.00');
    expect(page.impliedRate, findsOneWidget);
    await captureIntegrationScreenshot(tester, 'transfer-cross-currency-phone');
  });

  for (final surface in ScreenshotSurface.values) {
    patrolWidgetTest(
      'net worth shows the headline, trust line and breakdowns '
      '(${surface.name})',
      ($) async {
        final tester = $.tester;
        await useScreenshotSurface(tester, surface);
        await _pumpTour(
          tester,
          initialLocation: '/budgets/$household/reflect/net-worth',
        );

        final page = NetWorthPage(tester);
        expect(page.headline, findsOneWidget);
        expect(page.trustLine, findsOneWidget);
        expect(page.staleBadge, findsOneWidget);
        expect(page.incompleteCard, findsOneWidget);
        await captureIntegrationScreenshot(
          tester,
          'net-worth-${surface.name}',
        );

        if (surface != ScreenshotSurface.phone) return;

        await scrollIntoView(tester, page.tabByEntity);
        await captureIntegrationScreenshot(
          tester,
          'net-worth-by-entity-phone',
        );

        await page.showByCurrency();
        expect(page.currencyRow('NGN'), findsOneWidget);
        await scrollIntoView(tester, page.currencyRow('NGN'));
        await captureIntegrationScreenshot(
          tester,
          'net-worth-by-currency-phone',
        );

        await page.showByAccount();
        await scrollIntoView(tester, find.text(MultiCurrencyData.flatName));
        await captureIntegrationScreenshot(
          tester,
          'net-worth-by-account-phone',
        );
      },
    );
  }
}

/// Pumps the real screens on the real theme behind a router that mirrors
/// the app's paths, with every server read answered from
/// [MultiCurrencyData].
Future<void> _pumpTour(
  WidgetTester tester, {
  required String initialLocation,
  List<Account>? accounts,
}) async {
  final accountRows = accounts ?? MultiCurrencyData.householdAccounts();
  final byId = {
    for (final account in MultiCurrencyData.householdAccounts())
      account.id.toString(): account,
  };

  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        name: homeRoute,
        path: homePath,
        builder: (_, _) => const HomeScreen(),
      ),
      GoRoute(
        name: createEntityRoute,
        path: createEntityPath,
        builder: (_, _) => const CreateEntityScreen(),
      ),
      GoRoute(
        name: planRoute,
        path: planPath,
        builder: (_, _) => const Scaffold(body: Text('Plan')),
      ),
      GoRoute(
        name: accountListRoute,
        path: accountListPath,
        builder: (_, state) =>
            AccountListScreen(entityId: state.pathParameters['entityId']!),
        routes: [
          GoRoute(
            name: addAccountRoute,
            path: 'add',
            builder: (_, state) =>
                AddAccountScreen(entityId: state.pathParameters['entityId']!),
          ),
          GoRoute(
            name: accountDetailRoute,
            path: ':accountId',
            builder: (_, state) => AccountDetailScreen(
              entityId: state.pathParameters['entityId']!,
              accountId: state.pathParameters['accountId']!,
            ),
          ),
        ],
      ),
      GoRoute(
        name: addExpenseRoute,
        path: addExpensePath,
        builder: (_, state) =>
            AddExpenseScreen(entityId: state.pathParameters['entityId']!),
      ),
      GoRoute(
        name: createTransferRoute,
        path: createTransferPath,
        builder: (_, state) =>
            CreateTransferScreen(entityId: state.pathParameters['entityId']!),
      ),
      GoRoute(
        name: netWorthRoute,
        path: netWorthPath,
        builder: (_, state) =>
            NetWorthScreen(entityId: state.pathParameters['entityId']!),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        entitySummariesProvider.overrideWith(
          (ref) async => MultiCurrencyData.summaries(),
        ),
        entityListProvider.overrideWith(
          (ref) async => [
            MultiCurrencyData.household(),
            MultiCurrencyData.studio(),
          ],
        ),
        entityDetailProvider.overrideWith(
          (ref, id) async => MultiCurrencyData.household(),
        ),
        reportingCurrencyProvider.overrideWith((ref) async => 'GBP'),
        cryptoBreakdownProvider.overrideWith(
          (ref, arg) async => TestData.noWalletsCryptoBreakdown(arg.$2),
        ),
        netWorthProvider.overrideWith(
          (ref) async => MultiCurrencyData.netWorth(),
        ),
        netWorthForEntitiesProvider.overrideWith(
          (ref, ids) async => MultiCurrencyData.netWorthFor(ids),
        ),
        netWorthHistoryProvider.overrideWith(
          (ref, range) async => MultiCurrencyData.history(range.granularity),
        ),
        accountListProvider.overrideWith((ref, id) async => accountRows),
        accountListAllProvider.overrideWith((ref) async => accountRows),
        accountDetailProvider.overrideWith((ref, id) async => byId[id]!),
        accountBalancesProvider.overrideWith(
          (ref, id) async => MultiCurrencyData.usdBalances(),
        ),
        accountValuationsProvider.overrideWith(
          (ref, id) async => id == MultiCurrencyData.flatId
              ? MultiCurrencyData.flatValuations()
              : const <AccountValuation>[],
        ),
        walletForAccountProvider.overrideWith(
          (ref, id) async => id == MultiCurrencyData.walletAccountId
              ? MultiCurrencyData.wallet()
              : null,
        ),
        walletHoldingsProvider.overrideWith(
          (ref, id) async => MultiCurrencyData.walletHoldings(),
        ),
        transactionPagesProvider.overrideWith2(
          (entityId) => _FixedTransactionPages(
            MultiCurrencyData.usdTransactions(),
          ),
        ),
        plaidConnectionsProvider.overrideWith(
          (ref, id) async => const <PlaidConnection>[],
        ),
        institutionCatalogProvider.overrideWith(
          (ref, code) async => const <Institution>[],
        ),
        payeeListProvider.overrideWith((ref, id) async => const []),
        budgetMonthGroupsProvider.overrideWith((ref, id) async => const []),
        // The expense form checks for duplicates when the amount loses
        // focus; the tour never reaches a server.
        duplicateCheckProvider.overrideWith(
          (ref, args) async => const <TransactionView>[],
        ),
        fxQuoteProvider.overrideWith((ref, currencies) async {
          final (from, to, _) = currencies;
          return MultiCurrencyData.quote(from, to);
        }),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: OpenBudgetTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// One fixed page of transactions; no server cursor.
class _FixedTransactionPages extends TransactionPages {
  _FixedTransactionPages(this.items);

  final List<TransactionView> items;

  @override
  Future<TransactionPageState> build(String entityId) async =>
      TransactionPageState(filter: const TransactionFilter(), items: items);
}
