import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/add_wallet_provider.dart';
import 'package:openbudget_app/src/features/accounts/widgets/add_wallet_step.dart';
import 'package:openbudget_app/src/features/accounts/widgets/add_wallet_views.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../fixtures/add_wallet_fixtures.dart';

late ProviderContainer _container;
int _doneCalls = 0;

Future<void> _pump(
  WidgetTester tester,
  AddWalletServer server, {
  Size size = const Size(390, 900),
  double textScale = 1,
  ThemeMode themeMode = ThemeMode.light,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  _doneCalls = 0;
  _container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [serverpodClientProvider.overrideWithValue(server.client)],
  );
  addTearDown(_container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: _container,
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
        home: Scaffold(
          body: AddWalletStep(
            entityId: fixtureEntityId,
            onDone: () => _doneCalls++,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _paste(WidgetTester tester, String text) async {
  await tester.enterText(find.byKey(addWalletFieldKey), text);
  await tester.pumpAndSettle();
}

Future<void> _tapAdd(WidgetTester tester) async {
  final button = find.byKey(addWalletSubmitKey);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
}

String _fieldText(WidgetTester tester) =>
    tester.widget<TextField>(find.byKey(addWalletFieldKey)).controller!.text;

bool _addEnabled(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byKey(addWalletSubmitKey)).onPressed !=
    null;

void main() {
  group('a pasted EVM address', () {
    testWidgets('shows the picker with the found networks selected', (
      tester,
    ) async {
      final server = AddWalletServer(
        preview: () async => ethereumBaseArbitrumPreview(),
      );
      await _pump(tester, server);

      // Nothing is asked of the server until there is an address.
      expect(server.workCalls, isEmpty);
      expect(_addEnabled(tester), isFalse);

      await _paste(tester, fixtureEvmAddress);

      expect(server.workCalls, ['preview']);
      expect(
        server.client.callsTo('wallet', 'preview').single.args['address'],
        fixtureEvmAddress,
      );
      // The detected chain lands as a stamp: ETHEREUM, + 6.
      expect(
        find.byKey(const Key('add-wallet-detected-stamp')),
        findsOneWidget,
      );
      // The picker: each network with what was found there.
      expect(find.text('Where should OpenBudget look?'), findsOneWidget);
      expect(find.text(r'$1,240.00'), findsOneWidget);
      expect(find.text(r'$310.00'), findsOneWidget);
      expect(find.text('Nothing'), findsOneWidget);
      // Ethereum and Base hold something, so they start selected.
      expect(find.text('2 networks selected'), findsOneWidget);
      expect(_addEnabled(tester), isTrue);
    });

    testWidgets('selects only Ethereum when nothing is found anywhere', (
      tester,
    ) async {
      final server = AddWalletServer(
        preview: () async => previewOf([
          previewRow(WalletNetwork.ethereumMainnet),
          previewRow(WalletNetwork.baseMainnet),
          previewRow(WalletNetwork.arbitrumOne, unpriced: 2),
        ]),
      );
      await _pump(tester, server);
      await _paste(tester, fixtureEvmAddress);

      expect(find.text('1 network selected'), findsOneWidget);
      expect(find.text('No price'), findsOneWidget);
      expect(_addEnabled(tester), isTrue);
    });

    testWidgets("adds the picked networks, named in the reader's words", (
      tester,
    ) async {
      final server = AddWalletServer(
        preview: () async => ethereumBaseArbitrumPreview(),
        connectResult: (args) async => fixtureWallet(),
      );
      await _pump(tester, server);
      await _paste(tester, fixtureEvmAddress);

      // Tap Arbitrum One on, then add.
      await tester.tap(
        find.byKey(walletNetworkStampKey(WalletNetwork.arbitrumOne)),
      );
      await tester.pumpAndSettle();
      expect(find.text('3 networks selected'), findsOneWidget);
      await _tapAdd(tester);
      await tester.pumpAndSettle();

      final args = server.lastConnect.args;
      expect(args['network'], WalletNetwork.ethereumMainnet);
      expect(args['address'], fixtureEvmAddress);
      expect(args['scanNetworks'], [
        WalletNetwork.ethereumMainnet,
        WalletNetwork.baseMainnet,
        WalletNetwork.arbitrumOne,
      ]);
      expect(args['accountName'], 'Ethereum wallet (0x5a…eAed)');

      // The success postmark.
      expect(find.byType(ObPostmark), findsOneWidget);
      expect(find.text('Wallet added'), findsOneWidget);
      expect(
        find.textContaining('Ethereum wallet (0x5a…eAed) is in your accounts'),
        findsOneWidget,
      );
    });

    testWidgets('keeps the home network on and a network off when tapped', (
      tester,
    ) async {
      final server = AddWalletServer(
        preview: () async => ethereumBaseArbitrumPreview(),
      );
      await _pump(tester, server);
      await _paste(tester, fixtureEvmAddress);

      // Base off.
      await tester.tap(
        find.byKey(walletNetworkStampKey(WalletNetwork.baseMainnet)),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 network selected'), findsOneWidget);
      // Ethereum is the wallet's home: it is not a toggle, so a tap does
      // nothing.
      await tester.tap(
        find.byKey(walletNetworkStampKey(WalletNetwork.ethereumMainnet)),
      );
      await tester.pumpAndSettle();
      expect(find.text('1 network selected'), findsOneWidget);
    });

    testWidgets('does not look an address up twice', (tester) async {
      final server = AddWalletServer(
        preview: () async => ethereumBaseArbitrumPreview(),
      );
      await _pump(tester, server);
      await _paste(tester, fixtureEvmAddress);
      await _paste(tester, '');
      await _paste(tester, fixtureEvmAddress);

      expect(server.client.callsTo('wallet', 'preview'), hasLength(1));
      expect(find.text('2 networks selected'), findsOneWidget);
    });

    testWidgets('can still be added when the look-ahead is rate limited', (
      tester,
    ) async {
      final server = AddWalletServer(
        preview: () async => throw WalletPreviewRateLimitedException(),
        connectResult: (args) async => fixtureWallet(),
      );
      await _pump(tester, server);
      await _paste(tester, fixtureEvmAddress);

      expect(find.text("Couldn't look ahead"), findsOneWidget);
      expect(find.textContaining("You've looked up a lot"), findsOneWidget);
      expect(_addEnabled(tester), isTrue);

      await _tapAdd(tester);
      await tester.pumpAndSettle();
      // No picked networks, so the wallet reads its home network.
      expect(server.lastConnect.args['scanNetworks'], isNull);
      expect(find.byType(ObPostmark), findsOneWidget);
    });

    testWidgets('retries a failed look-ahead', (tester) async {
      var attempts = 0;
      final server = AddWalletServer(
        preview: () async {
          attempts++;
          if (attempts == 1) throw Exception('offline');
          return ethereumBaseArbitrumPreview();
        },
      );
      await _pump(tester, server);
      await _paste(tester, fixtureEvmAddress);
      expect(find.text("Couldn't look ahead"), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.text('Where should OpenBudget look?'), findsOneWidget);
      expect(find.text('2 networks selected'), findsOneWidget);
    });

    testWidgets('waits on the look-ahead before it can be added', (
      tester,
    ) async {
      final pending = Completer<WalletPreview>();
      final server = AddWalletServer(preview: () => pending.future);
      await _pump(tester, server);
      await tester.enterText(find.byKey(addWalletFieldKey), fixtureEvmAddress);
      await tester.pump();
      await tester.pump();

      expect(
        find.text(
          'Looking for assets on Ethereum, Base, Arbitrum One and 4 more…',
        ),
        findsOneWidget,
      );
      expect(_addEnabled(tester), isFalse);

      pending.complete(ethereumBaseArbitrumPreview());
      await tester.pumpAndSettle();
      expect(_addEnabled(tester), isTrue);
    });

    testWidgets('ignores a look-ahead for an address that was replaced', (
      tester,
    ) async {
      final first = Completer<WalletPreview>();
      final calls = <String>[];
      final server = AddWalletServer();
      server.client.handle('wallet', 'preview', (args) {
        calls.add(args['address']! as String);
        return calls.length == 1
            ? first.future
            : Future.value(
                previewOf([
                  previewRow(WalletNetwork.ethereumMainnet),
                  previewRow(WalletNetwork.baseMainnet, valueMinor: 500),
                ]),
              );
      });
      await _pump(tester, server);
      await tester.enterText(find.byKey(addWalletFieldKey), fixtureEvmAddress);
      await tester.pump();
      await tester.pump();
      await tester.enterText(
        find.byKey(addWalletFieldKey),
        '0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe',
      );
      await tester.pumpAndSettle();

      // The slow first answer arrives last and must not win.
      first.complete(ethereumBaseArbitrumPreview());
      await tester.pumpAndSettle();
      expect(find.text(r'$5.00'), findsOneWidget);
      expect(find.text(r'$1,240.00'), findsNothing);
    });
  });

  group('a secret', () {
    Future<void> expectRefused(
      WidgetTester tester,
      AddWalletServer server,
      String secret, {
      required String title,
    }) async {
      await _paste(tester, secret);

      // The field cleared itself and the refusal explains why.
      expect(_fieldText(tester), isEmpty);
      expect(find.text(title), findsOneWidget);
      // A secret wears a lock, not the cloud of a failed request.
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is SkribbleIcon && widget.data == OpenBudgetIcons.lock,
        ),
        findsOneWidget,
      );
      expect(_addEnabled(tester), isFalse);
      // No wallet request of any kind was sent.
      expect(server.workCalls, isEmpty);
      // The secret is on screen nowhere, nor in the flow's state.
      expect(find.textContaining('abandon'), findsNothing);
      expect(find.textContaining(secret), findsNothing);
      expect(
        _container.read(addWalletFlowProvider).toString(),
        isNot(contains(secret)),
      );
      expect(tester.takeException(), isNull);
    }

    testWidgets('a recovery phrase clears the field and sends nothing', (
      tester,
    ) async {
      final server = AddWalletServer(
        preview: () async => throw StateError('must not be called'),
        connectResult: (_) async => throw StateError('must not be called'),
      );
      await _pump(tester, server);
      await expectRefused(
        tester,
        server,
        fixtureRecoveryPhrase,
        title: "That's a private key",
      );
      expect(
        find.textContaining('OpenBudget never needs it'),
        findsOneWidget,
      );
      expect(server.client.callsTo('wallet', 'preview'), isEmpty);
      expect(server.client.callsTo('wallet', 'connect'), isEmpty);
    });

    testWidgets('a partial recovery phrase is cleared too', (tester) async {
      final server = AddWalletServer();
      await _pump(tester, server);
      await expectRefused(
        tester,
        server,
        'abandon abandon abandon abandon',
        title: "That's a private key",
      );
    });

    testWidgets('a raw private key clears the field and sends nothing', (
      tester,
    ) async {
      final server = AddWalletServer();
      await _pump(tester, server);
      await expectRefused(
        tester,
        server,
        '4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318',
        title: "That's a private key",
      );
    });

    testWidgets('an Ethereum-style private key clears the field', (
      tester,
    ) async {
      final server = AddWalletServer();
      await _pump(tester, server);
      await expectRefused(
        tester,
        server,
        '0x4c0883a69102937d6231471b5dbb6204fe5129617082792ae468d01a3f362318',
        title: 'That looks like a private key',
      );
    });

    testWidgets('the refusal goes once something else is typed', (
      tester,
    ) async {
      final server = AddWalletServer(
        preview: () async => ethereumBaseArbitrumPreview(),
      );
      await _pump(tester, server);
      await _paste(tester, fixtureRecoveryPhrase);
      expect(find.text("That's a private key"), findsOneWidget);

      await _paste(tester, fixtureEvmAddress);
      expect(find.text("That's a private key"), findsNothing);
      expect(find.text('2 networks selected'), findsOneWidget);
    });

    testWidgets('a form that is not secret stays in the field', (
      tester,
    ) async {
      final server = AddWalletServer();
      await _pump(tester, server);
      // A testnet Bitcoin address: refused, but public, so it stays.
      await _paste(tester, 'tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx');

      expect(find.text('Mainnet only'), findsOneWidget);
      expect(_fieldText(tester), isNotEmpty);
      expect(server.workCalls, isEmpty);
      expect(_addEnabled(tester), isFalse);
    });
  });

  group('input that is not an address', () {
    testWidgets('says nothing while a short address is being typed', (
      tester,
    ) async {
      final server = AddWalletServer();
      await _pump(tester, server);
      await _paste(tester, '0x5aAeb');

      expect(
        find.text("That doesn't look like a wallet address."),
        findsNothing,
      );
      expect(_addEnabled(tester), isFalse);
    });

    testWidgets('says so beside the field once it is long enough', (
      tester,
    ) async {
      final server = AddWalletServer();
      await _pump(tester, server);
      await _paste(tester, 'hello-this-is-not-an-address-at-all');

      expect(
        find.text("That doesn't look like a wallet address."),
        findsOneWidget,
      );
      expect(_addEnabled(tester), isFalse);
      expect(server.workCalls, isEmpty);
    });

    testWidgets('names a wrong character', (tester) async {
      final server = AddWalletServer();
      await _pump(tester, server);
      // The EIP-55 address with one letter's case changed.
      await _paste(tester, '0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAeD');

      expect(
        find.text('One character is wrong. Check the address and try again.'),
        findsOneWidget,
      );
      expect(server.workCalls, isEmpty);
    });
  });

  group('a Bitcoin extended public key', () {
    testWidgets('connects as a Bitcoin HD wallet', (tester) async {
      final server = AddWalletServer(
        connectResult: (args) async => fixtureWallet(
          network: WalletNetwork.bitcoinMainnet,
          address: 'hd:abc',
        ),
      );
      await _pump(tester, server);
      await _paste(tester, fixtureZpub);

      // A BITCOIN stamp lettered ZPUB, and no look-ahead: one network.
      expect(
        find.byKey(const Key('add-wallet-detected-stamp')),
        findsOneWidget,
      );
      expect(find.text('BITCOIN'), findsOneWidget);
      expect(find.text('ZPUB'), findsOneWidget);
      expect(
        find.textContaining('A Bitcoin extended public key'),
        findsOneWidget,
      );
      expect(server.workCalls, isEmpty);

      await _tapAdd(tester);
      await tester.pumpAndSettle();

      final args = server.lastConnect.args;
      expect(args['network'], WalletNetwork.bitcoinMainnet);
      expect(args['address'], fixtureZpub);
      expect(args['scanNetworks'], isNull);
      expect(args['accountName'], 'Bitcoin wallet, zpub');
      expect(find.byType(ObPostmark), findsOneWidget);
      expect(find.text('BTC'), findsOneWidget);
    });

    testWidgets('a bare xpub says its address type will be checked', (
      tester,
    ) async {
      final server = AddWalletServer();
      await _pump(tester, server);
      await _paste(tester, fixtureXpub);

      expect(find.text('XPUB'), findsOneWidget);
      expect(
        find.text("We'll check which kind of address this key makes."),
        findsOneWidget,
      );
      expect(_addEnabled(tester), isTrue);
    });

    testWidgets('is not offered when the chain is switched off', (
      tester,
    ) async {
      final server = AddWalletServer(
        supported: [
          for (final network in allMainnets)
            if (network != WalletNetwork.bitcoinMainnet) network,
        ],
      );
      await _pump(tester, server);
      await _paste(tester, fixtureZpub);

      expect(find.text("Bitcoin isn't available yet"), findsOneWidget);
      expect(_addEnabled(tester), isFalse);
      expect(server.workCalls, isEmpty);
    });
  });

  group('the first read', () {
    testWidgets('says which chains are being read until the server answers', (
      tester,
    ) async {
      final read = Completer<Wallet>();
      final server = AddWalletServer(
        preview: () async => ethereumBaseArbitrumPreview(),
        connectResult: (args) => read.future,
      );
      await _pump(tester, server);
      await _paste(tester, fixtureEvmAddress);
      await tester.tap(
        find.byKey(walletNetworkStampKey(WalletNetwork.arbitrumOne)),
      );
      await tester.pumpAndSettle();
      await _tapAdd(tester);
      await tester.pump();

      expect(
        find.text('Reading Ethereum, Base and Arbitrum One…'),
        findsOneWidget,
      );
      expect(find.byKey(addWalletSubmitKey), findsNothing);
      expect(find.byType(ObPostmark), findsNothing);

      read.complete(fixtureWallet());
      await tester.pumpAndSettle();
      expect(find.textContaining('Reading'), findsNothing);
      expect(find.byType(ObPostmark), findsOneWidget);
    });

    testWidgets('a single chain reads under its own name', (tester) async {
      final read = Completer<Wallet>();
      final server = AddWalletServer(connectResult: (args) => read.future);
      await _pump(tester, server);
      await _paste(tester, fixtureZpub);
      await _tapAdd(tester);
      await tester.pump();

      expect(find.text('Reading Bitcoin…'), findsOneWidget);
      read.complete(fixtureWallet(network: WalletNetwork.bitcoinMainnet));
      await tester.pumpAndSettle();
    });
  });

  group('when every network fails to read', () {
    testWidgets('says so and retries until a read works', (tester) async {
      var attempts = 0;
      final server = AddWalletServer(
        connectResult: (args) async => fixtureWallet(
          network: WalletNetwork.bitcoinMainnet,
          syncStatus: SyncStatus.failed,
          lastSyncError: 'Bitcoin could not be reached (HTTP 503).',
        ),
      );
      server.client.handle('wallet', 'sync', (args) async {
        attempts++;
        if (attempts == 1) throw Exception('still down');
        return fixtureSyncResult(readNetworks: [WalletNetwork.bitcoinMainnet]);
      });
      await _pump(tester, server);
      await _paste(tester, fixtureZpub);
      await _tapAdd(tester);
      await tester.pumpAndSettle();

      expect(find.text("Couldn't read your wallet"), findsOneWidget);
      expect(
        find.textContaining("Couldn't reach Bitcoin. The wallet is in your"),
        findsOneWidget,
      );
      expect(
        find.textContaining('Bitcoin could not be reached (HTTP 503).'),
        findsOneWidget,
      );
      expect(find.byType(ObPostmark), findsNothing);

      // The first retry still fails: the panel stays, with the retry.
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(attempts, 1);
      expect(find.text("Couldn't read your wallet"), findsOneWidget);

      // The second works: the wallet is added.
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(attempts, 2);
      expect(find.text("Couldn't read your wallet"), findsNothing);
      expect(find.byType(ObPostmark), findsOneWidget);
      expect(find.text('Wallet added'), findsOneWidget);
    });

    testWidgets('lets the person carry on without a successful read', (
      tester,
    ) async {
      final server = AddWalletServer(
        connectResult: (args) async => fixtureWallet(
          network: WalletNetwork.bitcoinMainnet,
          syncStatus: SyncStatus.failed,
        ),
      );
      await _pump(tester, server);
      await _paste(tester, fixtureZpub);
      await _tapAdd(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Done'));
      expect(_doneCalls, 1);
    });
  });

  group('when connecting fails', () {
    testWidgets("shows the server's words and keeps the form", (
      tester,
    ) async {
      final server = AddWalletServer(
        connectResult: (args) async =>
            throw ValidationException(message: 'That network has no reader.'),
      );
      await _pump(tester, server);
      await _paste(tester, fixtureZpub);
      await _tapAdd(tester);
      await tester.pumpAndSettle();

      expect(find.text("Couldn't add the wallet"), findsOneWidget);
      expect(find.text('That network has no reader.'), findsOneWidget);
      // Still the form: the address is there and Add is ready to try again.
      expect(_fieldText(tester), fixtureZpub);
      expect(_addEnabled(tester), isTrue);
    });

    testWidgets('says something went wrong for a dropped connection', (
      tester,
    ) async {
      final server = AddWalletServer(
        connectResult: (args) async => throw Exception('socket closed'),
      );
      await _pump(tester, server);
      await _paste(tester, fixtureZpub);
      await _tapAdd(tester);
      await tester.pumpAndSettle();

      expect(find.text("Couldn't add the wallet"), findsOneWidget);
      expect(
        find.text('Something went wrong. Check your connection and try again.'),
        findsOneWidget,
      );
      // Typing again clears the message.
      await _paste(tester, fixtureXpub);
      expect(find.text("Couldn't add the wallet"), findsNothing);
    });
  });

  group('after the wallet is added', () {
    testWidgets('Add another starts over with an empty field', (
      tester,
    ) async {
      final server = AddWalletServer(
        connectResult: (args) async =>
            fixtureWallet(network: WalletNetwork.bitcoinMainnet),
      );
      await _pump(tester, server);
      await _paste(tester, fixtureZpub);
      await _tapAdd(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add-wallet-add-another')));
      await tester.pumpAndSettle();
      expect(_fieldText(tester), isEmpty);
      expect(_addEnabled(tester), isFalse);
      expect(find.byType(ObPostmark), findsNothing);
    });

    testWidgets('Done leaves the flow', (tester) async {
      final server = AddWalletServer(
        connectResult: (args) async =>
            fixtureWallet(network: WalletNetwork.bitcoinMainnet),
      );
      await _pump(tester, server);
      await _paste(tester, fixtureZpub);
      await _tapAdd(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add-wallet-done')));
      expect(_doneCalls, 1);
    });
  });

  group('the question for an ambiguous address', () {
    testWidgets('offers each chain and answers with the one tapped', (
      tester,
    ) async {
      var chosen = 0;
      final candidates = [
        const WalletAddressCandidate(
          family: ChainFamily.bitcoin,
          networks: [WalletNetwork.bitcoinMainnet],
          canonical: 'a',
          display: 'a',
          kind: WalletAddressKind.address,
        ),
        const WalletAddressCandidate(
          family: ChainFamily.litecoin,
          networks: [WalletNetwork.litecoinMainnet],
          canonical: 'a',
          display: 'a',
          kind: WalletAddressKind.address,
        ),
      ];
      await tester.pumpWidget(
        MaterialApp(
          theme: OpenBudgetTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => WalletCandidateQuestion(
                candidates: candidates,
                selectedIndex: chosen,
                onSelected: (index) => setState(() => chosen = index),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Which chain is this address on?'), findsOneWidget);
      expect(find.text('BITCOIN'), findsOneWidget);
      expect(find.text('LITECOIN'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('add-wallet-candidate-1')));
      await tester.pump();
      expect(chosen, 1);
      // Tapping the chosen one again keeps it chosen.
      await tester.tap(find.byKey(const ValueKey('add-wallet-candidate-1')));
      await tester.pump();
      expect(chosen, 1);
    });
  });

  group('layout and semantics', () {
    for (final theme in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('the seven-network picker fits 320 wide at 2x text '
          '(${theme.name})', (tester) async {
        final handle = tester.ensureSemantics();
        final server = AddWalletServer(
          preview: () async => previewOf([
            previewRow(WalletNetwork.ethereumMainnet, valueMinor: 124000),
            previewRow(WalletNetwork.baseMainnet, valueMinor: 31000),
            previewRow(WalletNetwork.arbitrumOne),
            previewRow(WalletNetwork.opMainnet, error: 'could not be read'),
            previewRow(WalletNetwork.polygonPos, unpriced: 3),
            previewRow(WalletNetwork.bnbSmartChain, valueMinor: 12345678901),
            previewRow(WalletNetwork.avalancheCChain),
          ]),
        );
        await _pump(
          tester,
          server,
          size: const Size(320, 640),
          textScale: 2,
          themeMode: theme,
        );
        await _paste(tester, fixtureEvmAddress);

        expect(tester.takeException(), isNull);
        expect(find.text('Where should OpenBudget look?'), findsOneWidget);
        // Each stamp says its chain, what was found, and whether it is
        // picked.
        final base = find.byKey(
          walletNetworkStampKey(WalletNetwork.baseMainnet),
        );
        await tester.ensureVisible(base);
        await tester.pumpAndSettle();
        final baseNode = tester.getSemantics(base);
        expect(baseNode.label, r'Base, $310.00');
        expect(baseNode.value, 'included');
        final arbitrum = find.byKey(
          walletNetworkStampKey(WalletNetwork.arbitrumOne),
        );
        await tester.ensureVisible(arbitrum);
        await tester.pumpAndSettle();
        expect(tester.getSemantics(arbitrum).value, 'left out');
        expect(tester.getSemantics(arbitrum).label, 'Arbitrum One, Nothing');

        // Nothing sticks out of the 320-wide view.
        final view = tester.view.physicalSize / tester.view.devicePixelRatio;
        for (final network in evmNetworks) {
          final box = tester.getRect(
            find.byKey(walletNetworkStampKey(network)),
          );
          expect(box.left, greaterThanOrEqualTo(0), reason: network.name);
          expect(
            box.right,
            lessThanOrEqualTo(view.width),
            reason: network.name,
          );
        }
        // The Add button is pinned below the scrolling content.
        expect(find.byKey(addWalletSubmitKey).hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull);
        handle.dispose();
      });
    }

    testWidgets('the postmark, the reading and the retry fit 320 at 2x', (
      tester,
    ) async {
      final read = Completer<Wallet>();
      final server = AddWalletServer(
        preview: () async => ethereumBaseArbitrumPreview(),
        connectResult: (args) => read.future,
      );
      await _pump(
        tester,
        server,
        size: const Size(320, 640),
        textScale: 2,
      );
      await _paste(tester, fixtureEvmAddress);
      await _tapAdd(tester);
      await tester.pump();
      expect(find.textContaining('Reading'), findsOneWidget);
      expect(tester.takeException(), isNull);

      read.complete(fixtureWallet());
      await tester.pumpAndSettle();
      expect(find.byType(ObPostmark), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the field is not a place the keyboard learns from', (
      tester,
    ) async {
      final server = AddWalletServer();
      await _pump(tester, server);
      final field = tester.widget<TextField>(find.byKey(addWalletFieldKey));
      expect(field.autocorrect, isFalse);
      expect(field.enableSuggestions, isFalse);
      expect(field.enableIMEPersonalizedLearning, isFalse);
    });

    testWidgets('announces the postmark as added, with the chain', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final server = AddWalletServer(
        connectResult: (args) async =>
            fixtureWallet(network: WalletNetwork.bitcoinMainnet),
      );
      await _pump(tester, server);
      await _paste(tester, fixtureZpub);
      await _tapAdd(tester);
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(RegExp('Added, BTC')), findsOneWidget);
      handle.dispose();
    });
  });
}
