import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_detail_provider.dart';
import 'package:openbudget_app/src/features/accounts/widgets/wallet_holdings_section.dart';
import 'package:openbudget_app/src/features/accounts/widgets/wallet_settings_sheet.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../fixtures/budget_month.dart';
import '../fixtures/wallet_holdings_fixtures.dart';
import '../fixtures/wallet_settings_fixtures.dart';

const WalletNetwork _ethereum = WalletNetwork.ethereumMainnet;
const WalletNetwork _base = WalletNetwork.baseMainnet;
const WalletNetwork _arbitrum = WalletNetwork.arbitrumOne;

/// The account detail page's wallet parts: the title, the holdings by chain
/// and the button that opens the settings.
class _Page extends HookConsumerWidget {
  const _Page();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(accountDetailProvider(fixtureAccountId)).value;
    return Scaffold(
      appBar: AppBar(title: Text(account?.name ?? '')),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: [
          OutlinedButton(
            key: walletSettingsButtonKey,
            onPressed: () => showWalletSettingsSheet(
              context,
              entityId: fixtureEntityId,
              accountId: fixtureAccountId,
            ),
            child: const Text('Wallet settings'),
          ),
          const WalletHoldingsSection(
            walletId: fixtureWalletId,
            fallbackCurrencyCode: 'USD',
          ),
        ],
      ),
    );
  }
}

Future<void> _pump(
  WidgetTester tester,
  WalletSettingsServer server, {
  Size size = const Size(390, 900),
  double textScale = 1,
  ThemeMode themeMode = ThemeMode.light,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [serverpodClientProvider.overrideWithValue(server.client)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: OpenBudgetTheme.light,
        darkTheme: OpenBudgetTheme.dark,
        themeMode: themeMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const _Page(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openSettings(WidgetTester tester) async {
  await tester.tap(find.byKey(walletSettingsButtonKey));
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

bool _enabled(WidgetTester tester, Key key) {
  final widget = tester.widget<ButtonStyleButton>(find.byKey(key));
  return widget.onPressed != null;
}

/// Ethereum $2,000 and Base $310, both read.
WalletSettingsServer _twoChainServer() => WalletSettingsServer(
  reading: [_ethereum, _base],
  valueByNetwork: {_ethereum: 200000, _base: 31000, _arbitrum: 0},
);

void main() {
  group('the chain editor', () {
    testWidgets('shows what each chain holds, inked when read and outlined '
        'when not', (tester) async {
      final server = _twoChainServer();
      await _pump(tester, server);
      await _openSettings(tester);

      expect(find.text('Wallet settings'), findsWidgets);
      for (final network in [_ethereum, _base, _arbitrum]) {
        expect(find.byKey(walletSettingsNetworkKey(network)), findsOneWidget);
      }
      expect(find.text(r'$2,000.00'), findsWidgets);
      expect(find.text(r'$310.00'), findsWidgets);
      expect(find.text('Not read'), findsWidgets);
      expect(find.text('2 networks selected'), findsOneWidget);
      // The home chain is always read, so Save has nothing to say yet.
      expect(_enabled(tester, walletSettingsSaveNetworksKey), isFalse);
    });

    testWidgets('removing a chain that holds value confirms in the page, and '
        'the chain is gone from the holdings after', (tester) async {
      final server = _twoChainServer();
      await _pump(tester, server);
      // Holdings by chain: Base is a section, with its $310.00.
      expect(find.text(r'$310.00'), findsWidgets);
      await _openSettings(tester);

      await _tap(tester, walletSettingsNetworkKey(_base));
      expect(find.text('1 network selected'), findsOneWidget);
      await _tap(tester, walletSettingsSaveNetworksKey);

      // Nothing is sent yet: the page says what drops out of net worth.
      expect(server.workCalls, isEmpty);
      expect(find.text('Stop reading Base?'), findsOneWidget);
      expect(
        find.textContaining(r'$310.00 on Base will drop out of your net worth'),
        findsOneWidget,
      );

      await _tap(tester, walletSettingsRemoveConfirmKey);

      final call = server.client.callsTo('wallet', 'setScanNetworks').single;
      expect(call.args['networks'], [_ethereum]);
      expect(server.workCalls, ['setScanNetworks']);
      expect(find.text('Chains updated'), findsOneWidget);
      // The server dropped Base's holdings and the valuation with them.
      expect(server.totalMinor, 200000);
      expect(find.text(r'$310.00'), findsNothing);
      expect(find.text('Not read'), findsWidgets);
    });

    testWidgets('keeping the chain withdraws the confirmation', (tester) async {
      final server = _twoChainServer();
      await _pump(tester, server);
      await _openSettings(tester);

      await _tap(tester, walletSettingsNetworkKey(_base));
      await _tap(tester, walletSettingsSaveNetworksKey);
      await _tap(tester, walletSettingsRemoveCancelKey);

      expect(find.text('Stop reading Base?'), findsNothing);
      expect(server.workCalls, isEmpty);
      expect(find.byKey(walletSettingsSaveNetworksKey), findsOneWidget);
    });

    testWidgets('removing a chain that holds nothing saves without asking', (
      tester,
    ) async {
      final server = WalletSettingsServer(
        reading: [_ethereum, _arbitrum],
        valueByNetwork: {_ethereum: 200000},
      );
      await _pump(tester, server);
      await _openSettings(tester);

      await _tap(tester, walletSettingsNetworkKey(_arbitrum));
      await _tap(tester, walletSettingsSaveNetworksKey);

      expect(find.textContaining('Stop reading'), findsNothing);
      expect(
        server.client
            .callsTo('wallet', 'setScanNetworks')
            .single
            .args['networks'],
        [_ethereum],
      );
      expect(find.text('Chains updated'), findsOneWidget);
    });

    testWidgets('adding a chain reads it at once and its holdings appear', (
      tester,
    ) async {
      final server = WalletSettingsServer(
        reading: [_ethereum],
        valueByNetwork: {_ethereum: 200000, _base: 31000},
      );
      await _pump(tester, server);
      expect(find.text(r'$310.00'), findsNothing);
      await _openSettings(tester);

      await _tap(tester, walletSettingsNetworkKey(_base));
      expect(_enabled(tester, walletSettingsSaveNetworksKey), isTrue);
      await _tap(tester, walletSettingsSaveNetworksKey);

      // Adding never asks: nothing leaves net worth.
      expect(
        server.client
            .callsTo('wallet', 'setScanNetworks')
            .single
            .args['networks'],
        [_ethereum, _base],
      );
      expect(find.text('Chains updated'), findsOneWidget);
      expect(server.totalMinor, 231000);
      // The page underneath shows Base's section now.
      expect(find.text(r'$310.00'), findsWidgets);
    });

    testWidgets('says so when a saved read could not reach any chain', (
      tester,
    ) async {
      final server = WalletSettingsServer(
        reading: [_ethereum],
        valueByNetwork: {_ethereum: 200000, _base: 31000},
      )..readFails = true;
      await _pump(tester, server);
      await _openSettings(tester);

      await _tap(tester, walletSettingsNetworkKey(_base));
      await _tap(tester, walletSettingsSaveNetworksKey);

      expect(
        find.textContaining("Saved, but Ethereum and Base couldn't be read"),
        findsOneWidget,
      );
    });

    testWidgets('a failed save keeps the edit and says why', (tester) async {
      final server = _twoChainServer()..setScanError = Exception('offline');
      await _pump(tester, server);
      await _openSettings(tester);

      await _tap(tester, walletSettingsNetworkKey(_arbitrum));
      await _tap(tester, walletSettingsSaveNetworksKey);

      expect(
        find.text("Couldn't update the chains. Try again."),
        findsOneWidget,
      );
      expect(find.text('3 networks selected'), findsOneWidget);
    });

    testWidgets('a wallet on one chain has nothing to pick', (tester) async {
      final server = WalletSettingsServer(
        reading: [WalletNetwork.bitcoinMainnet],
        network: WalletNetwork.bitcoinMainnet,
        valueByNetwork: {WalletNetwork.bitcoinMainnet: 50000},
      );
      await _pump(tester, server);
      await _openSettings(tester);

      expect(
        find.text(
          "Bitcoin wallets are read on one chain, so there's nothing "
          'to choose.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(walletSettingsLookAheadKey), findsNothing);
      expect(find.byKey(walletSettingsSaveNetworksKey), findsNothing);
    });
  });

  group('Look for assets on other chains', () {
    testWidgets('offers the chains that turned up, already picked', (
      tester,
    ) async {
      final server =
          WalletSettingsServer(
              reading: [_ethereum],
              valueByNetwork: {_ethereum: 200000, _arbitrum: 5000},
            )
            ..previewAnswer = previewOfRows([
              settingsPreviewRow(_ethereum, valueMinor: 200000),
              settingsPreviewRow(_base),
              settingsPreviewRow(_arbitrum, valueMinor: 5000),
            ]);
      await _pump(tester, server);
      await _openSettings(tester);

      await _tap(tester, walletSettingsLookAheadKey);

      expect(server.client.callsTo('wallet', 'preview'), hasLength(1));
      // It asked about the wallet's own address, and nothing else.
      expect(find.text('Found assets on Arbitrum One'), findsOneWidget);
      expect(find.text(r'$50.00'), findsWidgets);
      expect(find.text('2 networks selected'), findsOneWidget);
      expect(_enabled(tester, walletSettingsSaveNetworksKey), isTrue);

      await _tap(tester, walletSettingsSaveNetworksKey);
      expect(
        server.client
            .callsTo('wallet', 'setScanNetworks')
            .single
            .args['networks'],
        [_ethereum, _arbitrum],
      );
      // Saved, so the finding is spent and the result card is gone.
      expect(find.text('Found assets on Arbitrum One'), findsNothing);
    });

    testWidgets('says nothing new was found, with how many chains it looked '
        'at', (tester) async {
      final server =
          WalletSettingsServer(
              reading: [_ethereum],
              valueByNetwork: {_ethereum: 200000},
            )
            ..previewAnswer = previewOfRows([
              settingsPreviewRow(_ethereum, valueMinor: 200000),
              settingsPreviewRow(_base),
              settingsPreviewRow(_arbitrum),
            ]);
      await _pump(tester, server);
      await _openSettings(tester);

      await _tap(tester, walletSettingsLookAheadKey);

      expect(find.text('Nothing new found'), findsOneWidget);
      expect(
        find.textContaining('looked at'),
        findsOneWidget,
      );
      expect(find.text('1 network selected'), findsOneWidget);
      expect(_enabled(tester, walletSettingsSaveNetworksKey), isFalse);
      expect(server.workCalls, ['preview']);
    });

    testWidgets('says so when every chain is already read', (tester) async {
      final server =
          WalletSettingsServer(
              reading: [_ethereum, _base],
              valueByNetwork: {_ethereum: 200000},
              supported: [_ethereum, _base],
            )
            ..previewAnswer = previewOfRows([
              settingsPreviewRow(_ethereum, valueMinor: 200000),
              settingsPreviewRow(_base),
            ]);
      await _pump(tester, server);
      await _openSettings(tester);

      await _tap(tester, walletSettingsLookAheadKey);

      expect(find.text('Nothing new found'), findsOneWidget);
      expect(
        find.text('OpenBudget already reads every chain this address can use.'),
        findsOneWidget,
      );
    });

    testWidgets('a failed look-ahead can be tried again', (tester) async {
      final server = _twoChainServer()..previewError = Exception('offline');
      await _pump(tester, server);
      await _openSettings(tester);

      await _tap(tester, walletSettingsLookAheadKey);
      expect(
        find.text("We couldn't check the other chains. Try again in a moment."),
        findsOneWidget,
      );

      server
        ..previewError = null
        ..previewAnswer = previewOfRows([
          settingsPreviewRow(_ethereum),
          settingsPreviewRow(_base),
        ]);
      await _tap(tester, walletSettingsLookAheadKey);
      expect(find.text('Nothing new found'), findsOneWidget);
      expect(server.client.callsTo('wallet', 'preview'), hasLength(2));
    });

    testWidgets('a rate limit gets its own words', (tester) async {
      final server = _twoChainServer()
        ..previewError = WalletPreviewRateLimitedException();
      await _pump(tester, server);
      await _openSettings(tester);

      await _tap(tester, walletSettingsLookAheadKey);

      expect(
        find.text(
          "You've looked up a lot of wallets. Try again in a little while.",
        ),
        findsOneWidget,
      );
    });
  });

  group('rename and disconnect', () {
    testWidgets('renaming updates the account name shown on the page', (
      tester,
    ) async {
      final server = _twoChainServer();
      await _pump(tester, server);
      expect(find.text('Ethereum wallet (0x5a…eAed)'), findsOneWidget);
      await _openSettings(tester);
      expect(_enabled(tester, walletSettingsNameSaveKey), isFalse);

      await tester.enterText(
        find.byKey(walletSettingsNameFieldKey),
        '  Cold storage ',
      );
      await tester.pumpAndSettle();
      expect(_enabled(tester, walletSettingsNameSaveKey), isTrue);
      await _tap(tester, walletSettingsNameSaveKey);

      final call = server.client.callsTo('account', 'update').single;
      expect(call.args['name'], 'Cold storage');
      expect(find.text('Wallet renamed'), findsOneWidget);
      expect(find.text('Cold storage'), findsWidgets);
      expect(find.text('Ethereum wallet (0x5a…eAed)'), findsNothing);
    });

    testWidgets('a blank name cannot be saved', (tester) async {
      final server = _twoChainServer();
      await _pump(tester, server);
      await _openSettings(tester);

      await tester.enterText(find.byKey(walletSettingsNameFieldKey), '   ');
      await tester.pumpAndSettle();

      expect(_enabled(tester, walletSettingsNameSaveKey), isFalse);
    });

    testWidgets('disconnecting asks in the page, then closes the sheet', (
      tester,
    ) async {
      final server = _twoChainServer();
      await _pump(tester, server);
      await _openSettings(tester);

      await _tap(tester, walletSettingsDisconnectKey);
      expect(
        find.text('Disconnect Ethereum wallet (0x5a…eAed)?'),
        findsOneWidget,
      );
      expect(server.disconnected, isFalse);

      await _tap(tester, walletSettingsDisconnectConfirmKey);

      expect(server.disconnected, isTrue);
      expect(
        server.client
            .callsTo('wallet', 'disconnect')
            .single
            .args['deleteAccount'],
        isFalse,
      );
      // The sheet is closed and the page says so.
      expect(find.byKey(walletSettingsDisconnectConfirmKey), findsNothing);
      expect(find.text('Wallet disconnected'), findsOneWidget);
    });

    testWidgets('a failed disconnect leaves the wallet and says why', (
      tester,
    ) async {
      final server = _twoChainServer()..disconnectError = Exception('offline');
      await _pump(tester, server);
      await _openSettings(tester);

      await _tap(tester, walletSettingsDisconnectKey);
      await _tap(tester, walletSettingsDisconnectConfirmKey);

      expect(
        find.text("Couldn't disconnect the wallet. Try again."),
        findsOneWidget,
      );
      expect(find.byKey(walletSettingsDisconnectConfirmKey), findsOneWidget);
    });
  });

  group('layout and semantics', () {
    for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('fits 320 wide at 2x text with the confirmation open '
          '(${themeMode.name})', (tester) async {
        final server = _twoChainServer();
        await _pump(
          tester,
          server,
          size: const Size(320, 700),
          textScale: 2,
          themeMode: themeMode,
        );
        await _openSettings(tester);
        await _tap(tester, walletSettingsNetworkKey(_base));
        await _tap(tester, walletSettingsSaveNetworksKey);
        expect(find.text('Stop reading Base?'), findsOneWidget);
        await _tap(tester, walletSettingsDisconnectKey);

        expect(tester.takeException(), isNull);
        // Every control is reachable by scrolling, not clipped.
        for (final key in [
          walletSettingsNameSaveKey,
          walletSettingsLookAheadKey,
          walletSettingsRemoveConfirmKey,
          walletSettingsDisconnectConfirmKey,
        ]) {
          await tester.ensureVisible(find.byKey(key));
          await tester.pumpAndSettle();
          expect(find.byKey(key), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('chains are announced with their name, value and state', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final server = _twoChainServer();
      await _pump(tester, server);
      await _openSettings(tester);

      final base = tester.getSemantics(
        find.byKey(walletSettingsNetworkKey(_base)),
      );
      expect(base.label, contains('Base'));
      expect(base.label, contains(r'$310.00'));
      expect(base.value, 'included');
      final arbitrum = tester.getSemantics(
        find.byKey(walletSettingsNetworkKey(_arbitrum)),
      );
      expect(arbitrum.label, contains('Arbitrum One'));
      expect(arbitrum.value, 'left out');
      handle.dispose();
    });
  });
}

/// A preview of the fixture address with [rows].
WalletPreview previewOfRows(List<WalletPreviewNetwork> rows) => WalletPreview(
  network: WalletNetwork.ethereumMainnet,
  address: settingsEvmAddress.toLowerCase(),
  networks: rows,
  warnings: const [],
);
