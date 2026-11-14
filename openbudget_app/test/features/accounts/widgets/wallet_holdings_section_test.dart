import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/widgets/wallet_holdings_section.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../../../support/fake_endpoint_client.dart';
import '../fixtures/wallet_holdings_fixtures.dart';

final DateTime _now = DateTime.utc(2026, 11, 13, 12);

/// A fake server that keeps the wallet's holdings, so a verdict the app
/// sets is what the next `listHoldings` returns.
class _Server {
  _Server(List<WalletHolding> holdings, this.states)
    : holdings = [...holdings] {
    client
      ..handle('wallet', 'listHoldings', (_) => [...this.holdings])
      ..handle('wallet', 'listNetworkStates', (_) => states)
      ..handle('wallet', 'setHoldingVerdict', (args) {
        final id = args['walletHoldingId'] as UuidValue;
        final verdict = args['verdict'] as SpamVerdict?;
        if (failVerdicts) throw Exception('server unavailable');
        final index = this.holdings.indexWhere((h) => h.id == id);
        final updated = this.holdings[index].copyWith(
          spamVerdict: verdict ?? SpamVerdict.clean,
        );
        this.holdings[index] = updated;
        return updated;
      });
  }

  final List<WalletHolding> holdings;
  final List<WalletNetworkState> states;
  final FakeEndpointClient client = FakeEndpointClient();
  bool failVerdicts = false;

  List<({String id, SpamVerdict? verdict})> get verdictCalls => [
    for (final call in client.callsTo('wallet', 'setHoldingVerdict'))
      (
        id: (call.args['walletHoldingId'] as UuidValue).uuid,
        verdict: call.args['verdict'] as SpamVerdict?,
      ),
  ];
}

_Server _evmServer() {
  final wallet = fixtureEvmWallet(_now);
  return _Server(wallet.holdings, wallet.states);
}

Future<void> _pump(
  WidgetTester tester,
  _Server server, {
  Size size = const Size(390, 2600),
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
          child: ObWiredScope(child: child!),
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: WalletHoldingsSection(
              walletId: fixtureWalletId,
              fallbackCurrencyCode: 'USD',
              now: _now,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('WalletHoldingsSection', () {
    testWidgets(
      'a three-network wallet renders three sections with subtotals',
      (
        tester,
      ) async {
        await _pump(tester, _evmServer());

        expect(find.byType(ObChainStamp), findsNWidgets(3));
        // A stamp letters its chain in capitals.
        for (final name in ['ETHEREUM', 'BASE', 'ARBITRUM ONE']) {
          expect(
            find.descendant(
              of: find.byType(ObChainStamp),
              matching: find.text(name),
            ),
            findsOneWidget,
            reason: '$name has a chain stamp',
          );
        }
        // 4,120.50 + 125.00 + 8,241.00, then 2,060.25, then 216.00 + 10.80.
        expect(find.text(r'$12,486.50'), findsOneWidget);
        expect(
          find.text(r'$2,060.25'),
          findsNWidgets(2),
          reason: 'subtotal + row',
        );
        expect(find.text(r'$226.80'), findsOneWidget);
        expect(find.text('Read 5 minutes ago'), findsOneWidget);
        expect(find.text('Read 2 hours ago'), findsOneWidget);
        expect(find.text('Read 1 hour ago'), findsOneWidget);
      },
    );

    testWidgets(
      'staked and rewards positions sit under their asset with chips',
      (
        tester,
      ) async {
        await _pump(tester, _evmServer());

        expect(find.widgetWithText(ObToneChip, 'Staked'), findsOneWidget);
        expect(find.widgetWithText(ObToneChip, 'Rewards'), findsOneWidget);
        // The staked ETH is its own tile under the available ETH, not a second
        // headed row: "Ether" is named once on Ethereum and once on Base.
        expect(find.textContaining('Ether'), findsNWidgets(2));
        expect(find.text('Quantity 2'), findsOneWidget, reason: 'staked ETH');
        expect(find.text('Quantity 12'), findsOneWidget, reason: 'ARB rewards');
      },
    );

    testWidgets('a cached price wears the old-price chip', (tester) async {
      await _pump(tester, _evmServer());

      expect(
        find.widgetWithText(ObToneChip, 'Price from 3 days ago'),
        findsOneWidget,
      );
      expect(find.widgetWithText(ObToneChip, 'Staked'), findsOneWidget);
    });

    testWidgets("a partly read wallet shows the failed network's note", (
      tester,
    ) async {
      await _pump(tester, _evmServer());

      expect(
        find.text("Base couldn't be read. Showing amounts from 2 hours ago."),
        findsOneWidget,
      );
      expect(find.text('Base did not answer in time.'), findsOneWidget);
      // Only the failed network has a note.
      expect(find.textContaining("couldn't be read"), findsOneWidget);
      // Its amounts still count.
      expect(find.text(r'$2,060.25'), findsNWidgets(2));
    });

    testWidgets('a network with nothing to show says so as a problem', (
      tester,
    ) async {
      final server = _Server(const [], [
        fixtureNetworkState(
          WalletNetwork.baseMainnet,
          lastError: 'Base did not answer in time.',
        ),
      ]);
      await _pump(tester, server);

      expect(
        find.text("Base couldn't be read yet. There are no amounts to show."),
        findsOneWidget,
      );
      expect(find.text('Nothing counted'), findsOneWidget);
    });

    testWidgets('the Hidden group is collapsed and counts why', (tester) async {
      await _pump(tester, _evmServer());

      expect(find.text('3 hidden'), findsOneWidget);
      expect(
        find.text('1 without a price, 1 suspected spam, 1 hidden by you'),
        findsOneWidget,
      );
      expect(find.textContaining('Visit claim-usdc.xyz'), findsNothing);

      await tester.tap(find.text('3 hidden'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Visit claim-usdc.xyz'), findsOneWidget);
      expect(find.textContaining('Obscure'), findsOneWidget);
      expect(find.textContaining('Dust'), findsOneWidget);
      expect(find.text('Suspected spam'), findsOneWidget);
      expect(find.text('No price'), findsOneWidget);
      expect(find.text('Hidden by you'), findsOneWidget);
      // An unpriced token says so plainly and has no Show: showing it would
      // add nothing to count.
      expect(find.text('No price yet'), findsOneWidget);
      expect(find.text('Show'), findsNWidgets(2));
    });

    testWidgets('Show on a suspected holding allows it and refreshes', (
      tester,
    ) async {
      final server = _evmServer();
      await _pump(tester, server);
      await tester.tap(find.text('3 hidden'));
      await tester.pumpAndSettle();
      final listsBefore = server.client
          .callsTo('wallet', 'listHoldings')
          .length;

      await tester.tap(find.byTooltip('Show CLAIM-USDC.xyz'));
      await tester.pumpAndSettle();

      expect(server.verdictCalls, [
        (
          id: '00000000-0000-0000-0000-000000000e04',
          verdict: SpamVerdict.allowedByUser,
        ),
      ]);
      expect(
        server.client.callsTo('wallet', 'listHoldings').length,
        greaterThan(listsBefore),
        reason: 'the holdings are refreshed',
      );
      // It now counts: out of Hidden, into Ethereum's subtotal.
      expect(find.text('2 hidden'), findsOneWidget);
      expect(find.text(r'$111,486.50'), findsOneWidget);
    });

    testWidgets('Hide on a holding hides it and refreshes', (tester) async {
      final server = _evmServer();
      await _pump(tester, server);
      final listsBefore = server.client
          .callsTo('wallet', 'listHoldings')
          .length;

      await tester.tap(find.byTooltip('Hide USDC'));
      await tester.pumpAndSettle();

      expect(server.verdictCalls, [
        (
          id: '00000000-0000-0000-0000-000000000e02',
          verdict: SpamVerdict.hiddenByUser,
        ),
      ]);
      expect(
        server.client.callsTo('wallet', 'listHoldings').length,
        greaterThan(listsBefore),
      );
      expect(find.text('4 hidden'), findsOneWidget);
      // Ethereum's subtotal drops by the $125.00 of USDC.
      expect(find.text(r'$12,361.50'), findsOneWidget);
    });

    testWidgets('hiding an asset hides its staked position with it', (
      tester,
    ) async {
      final server = _evmServer();
      await _pump(tester, server);

      await tester.tap(find.byTooltip('Hide ETH').first);
      await tester.pumpAndSettle();

      expect(server.verdictCalls.map((c) => c.id), [
        '00000000-0000-0000-0000-000000000e01',
        '00000000-0000-0000-0000-000000000e03',
      ]);
      expect(
        server.verdictCalls.map((c) => c.verdict),
        everyElement(SpamVerdict.hiddenByUser),
      );
    });

    testWidgets('a failed verdict says so and leaves the holding in place', (
      tester,
    ) async {
      final server = _evmServer()..failVerdicts = true;
      await _pump(tester, server);

      await tester.tap(find.byTooltip('Hide USDC'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't update USDC. Try again."), findsOneWidget);
      expect(find.text('3 hidden'), findsOneWidget);
      expect(find.byTooltip('Hide USDC'), findsOneWidget);
    });

    testWidgets('a Solana-only wallet keeps working and looks the same', (
      tester,
    ) async {
      final server = _Server(
        [
          fixtureHolding(
            network: WalletNetwork.solanaMainnet,
            id: '00000000-0000-0000-0000-000000000c01',
            assetId: 'So11111111111111111111111111111111111111112',
            symbol: 'SOL',
            decimals: 9,
            quantityRaw: BigInt.from(1500000000),
            valueMinor: 28000,
            costBasisMinor: 25000,
          ),
        ],
        [
          fixtureNetworkState(
            WalletNetwork.solanaMainnet,
            lastReadAt: _now.subtract(const Duration(minutes: 20)),
          ),
        ],
      );
      await _pump(tester, server);

      expect(find.byType(ObChainStamp), findsOneWidget);
      expect(find.text('SOLANA'), findsOneWidget);
      expect(find.text('Read 20 minutes ago'), findsOneWidget);
      expect(find.text('Quantity 1.5'), findsOneWidget);
      expect(find.text(r'P&L $30.00'), findsOneWidget);
      expect(find.textContaining('hidden'), findsNothing);
      expect(find.textContaining("couldn't be read"), findsNothing);
    });

    testWidgets('a holding without a cost basis says cost unknown', (
      tester,
    ) async {
      await _pump(tester, _evmServer());

      // USDC, Base ETH and the staked ETH have no cost basis.
      expect(find.text('Cost unknown'), findsWidgets);
    });

    testWidgets('shows nothing until the wallet has holdings', (tester) async {
      await _pump(tester, _Server(const [], const []));

      expect(find.text('Holdings'), findsNothing);
      expect(find.byType(ObChainStamp), findsNothing);
    });

    testWidgets('a section header reads as one: network, total and status', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _evmServer());

      expect(
        find.bySemanticsLabel(r'Ethereum, $12,486.50, Read 5 minutes ago'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(r'Base, $2,060.25, Read 2 hours ago'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('the Hide button is a labelled 48 pixel target', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, _evmServer());

      final button = find.byTooltip('Hide USDC');
      expect(button, findsOneWidget);
      expect(tester.getSize(button).shortestSide, greaterThanOrEqualTo(48));
      expect(
        tester.getSemantics(button),
        matchesSemantics(
          isButton: true,
          isEnabled: true,
          isFocusable: true,
          hasEnabledState: true,
          hasTapAction: true,
          hasFocusAction: true,
          tooltip: 'Hide USDC',
        ),
      );
      handle.dispose();
    });

    for (final (label, size, scale, mode) in [
      ('phone', const Size(360, 2000), 1.0, ThemeMode.light),
      ('phone at large text', const Size(360, 7000), 2.0, ThemeMode.light),
      ('desktop', const Size(1280, 1400), 1.0, ThemeMode.light),
      ('phone at night', const Size(390, 2000), 1.0, ThemeMode.dark),
    ]) {
      testWidgets('lays out without overflow on $label', (tester) async {
        await _pump(
          tester,
          _evmServer(),
          size: size,
          textScale: scale,
          themeMode: mode,
        );
        await tester.tap(find.textContaining('hidden').first);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
