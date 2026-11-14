import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_detail_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/account_detail_screen.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_pages_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

import 'common/fake_wallet_settings_server.dart';
import 'common/patrol_helpers.dart';
import 'common/test_data.dart';
import 'helpers/screenshot_capture.dart';

/// Wallet settings on account detail: rename a wallet, stop reading a chain
/// that holds value (after an in-page confirmation of what leaves net
/// worth), then look for assets on other chains and read what turns up. The
/// server is faked, so the flow also asserts what the app sent.
void main() {
  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    final theme = themeMode.name;

    patrolWidgetTest(
      'renames a wallet and removes a network ($theme)',
      ($) async {
        final tester = $.tester;
        final server = FakeWalletSettingsServer();
        await _pumpAccountDetail(tester, server, themeMode: themeMode);
        final page = WalletSettingsPage(tester);

        // Holdings by chain: Ethereum and Base, with Base's $310.
        expect(find.text(WalletSettingsFlowData.accountName), findsOneWidget);
        await page.showHoldings();
        expect(find.text(r'$310.00'), findsWidgets);
        await captureIntegrationScreenshot(
          tester,
          'wallet-settings-account-$theme',
        );

        await page.open();
        expect(page.networkStamp('baseMainnet'), findsOneWidget);
        await captureIntegrationScreenshot(
          tester,
          'wallet-settings-sheet-$theme',
        );

        // Rename: the account name on the page follows.
        await page.rename(WalletSettingsFlowData.renamedAccount);
        expect(find.text('Wallet renamed'), findsOneWidget);
        expect(
          server.callsTo('account.update').single.args['name'],
          WalletSettingsFlowData.renamedAccount,
        );
        expect(
          find.text(WalletSettingsFlowData.renamedAccount),
          findsWidgets,
        );
        expect(find.text(WalletSettingsFlowData.accountName), findsNothing);

        // Stop reading Base. It holds value, so the page asks first and
        // nothing is sent until it is confirmed.
        await page.toggleNetwork('baseMainnet');
        expect(find.text('1 network selected'), findsOneWidget);
        await captureIntegrationScreenshot(
          tester,
          'wallet-settings-network-editor-$theme',
        );
        await page.saveChains();
        expect(find.text('Stop reading Base?'), findsOneWidget);
        expect(
          find.textContaining(
            r'$310.00 on Base will drop out of your net worth',
          ),
          findsOneWidget,
        );
        expect(server.callsTo('wallet.setScanNetworks'), isEmpty);
        await captureIntegrationScreenshot(
          tester,
          'wallet-settings-remove-confirm-$theme',
        );

        await page.confirmRemoval();
        expect(
          server.callsTo('wallet.setScanNetworks').single.args['networks'],
          [WalletNetwork.ethereumMainnet],
        );
        expect(find.text('Chains updated'), findsOneWidget);
        expect(server.totalMinor, WalletSettingsFlowData.ethereumMinor);

        // Base's holdings are gone from the page, and so is its value.
        await page.close();
        await page.showHoldings();
        expect(find.text(r'$2,000.00'), findsWidgets);
        expect(find.text(r'$310.00'), findsNothing);
      },
    );

    patrolWidgetTest(
      'looks for assets on other chains and reads what turns up ($theme)',
      ($) async {
        final tester = $.tester;
        final server = FakeWalletSettingsServer()
          ..scan = [WalletNetwork.ethereumMainnet];
        await _pumpAccountDetail(tester, server, themeMode: themeMode);
        final page = WalletSettingsPage(tester);
        await page.showHoldings();
        expect(find.text(r'$310.00'), findsNothing);

        await page.open();
        await page.lookForOtherChains();
        // Base holds $310 and Arbitrum One $50, both new, both picked.
        expect(
          find.text('Found assets on Base and Arbitrum One'),
          findsOneWidget,
        );
        expect(find.text('3 networks selected'), findsOneWidget);
        await captureIntegrationScreenshot(
          tester,
          'wallet-settings-look-ahead-$theme',
        );

        await page.saveChains();
        expect(
          server.callsTo('wallet.setScanNetworks').single.args['networks'],
          [
            WalletNetwork.ethereumMainnet,
            WalletNetwork.baseMainnet,
            WalletNetwork.arbitrumOne,
          ],
        );
        expect(find.text('Chains updated'), findsOneWidget);

        // Nothing is left to find now.
        await page.lookForOtherChains();
        expect(find.text('Nothing new found'), findsOneWidget);
        expect(
          find.text(
            'OpenBudget already reads every chain this address can use.',
          ),
          findsOneWidget,
        );

        // The new chains were read at once and show on the page.
        await page.close();
        await page.showHoldings();
        expect(find.text(r'$310.00'), findsWidgets);
        expect(find.text(r'$50.00'), findsWidgets);
      },
    );
  }
}

Future<void> _pumpAccountDetail(
  WidgetTester tester,
  FakeWalletSettingsServer server, {
  ThemeMode themeMode = ThemeMode.light,
}) async {
  await useScreenshotSurface(tester, ScreenshotSurface.phone);
  final router = GoRouter(
    initialLocation:
        '/budgets/${WalletSettingsFlowData.entityId}/accounts/'
        '${WalletSettingsFlowData.accountId}',
    routes: [
      GoRoute(
        name: accountListRoute,
        path: accountListPath,
        builder: (_, _) => const Scaffold(body: Text('Account List')),
      ),
      GoRoute(
        name: accountDetailRoute,
        path: accountDetailPath,
        builder: (_, state) => AccountDetailScreen(
          entityId: state.pathParameters['entityId']!,
          accountId: state.pathParameters['accountId']!,
        ),
      ),
    ],
  );
  final container = ProviderContainer(
    overrides: [
      serverpodClientProvider.overrideWithValue(server),
      entityDetailProvider.overrideWith(
        (ref, id) async => TestData.gbpEntity(),
      ),
      accountBalancesProvider.overrideWith(
        (ref, id) async => AccountBalancesView(
          accountId: UuidValue.fromString(WalletSettingsFlowData.accountId),
          currencyCode: 'USD',
          balanceMinor: server.totalMinor,
          clearedMinor: server.totalMinor,
          unclearedMinor: 0,
        ),
      ),
      accountValuationsProvider.overrideWith((ref, id) async => const []),
      accountListProvider.overrideWith((ref, entityId) async => const []),
      transactionPagesProvider.overrideWith2((entityId) => _NoTransactions()),
      netWorthForEntitiesProvider.overrideWith(
        (ref, ids) async => NetWorthView(
          currencyCode: 'USD',
          asOf: DateTime.utc(2026, 11, 14),
          assetsMinor: server.totalMinor,
          liabilitiesMinor: 0,
          netWorthMinor: server.totalMinor,
          isComplete: true,
          missingCurrencyCodes: const [],
          hasStaleRates: false,
          currencies: const [],
          entities: const [],
          accounts: const [],
        ),
      ),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(
        theme: OpenBudgetTheme.light,
        darkTheme: OpenBudgetTheme.dark,
        themeMode: themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// An account with no transactions, which the detail page pages through.
class _NoTransactions extends TransactionPages {
  @override
  Future<TransactionPageState> build(String entityId) async =>
      const TransactionPageState(
        filter: TransactionFilter(
          accountId: WalletSettingsFlowData.accountId,
        ),
        items: [],
      );
}
