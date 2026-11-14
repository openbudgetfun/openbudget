import 'package:flutter_test/flutter_test.dart';
import 'package:openbudget_app/src/features/accounts/models/wallet_holdings_view.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

import '../fixtures/wallet_holdings_fixtures.dart';

void main() {
  final now = DateTime.utc(2026, 11, 13, 12);

  WalletHoldingsView build({
    List<WalletHolding>? holdings,
    List<WalletNetworkState>? states,
  }) {
    final wallet = fixtureEvmWallet(now);
    return buildWalletHoldingsView(
      holdings: holdings ?? wallet.holdings,
      networkStates: states ?? wallet.states,
      fallbackCurrencyCode: 'GBP',
    );
  }

  group('buildWalletHoldingsView', () {
    test('makes one section per network with the counted subtotal', () {
      final view = build();

      expect(view.sections.map((s) => s.network), [
        // 4,120.50 + 125.00 + 8,241.00 beats 2,060.25 and 216.00 + 10.80.
        WalletNetwork.ethereumMainnet,
        WalletNetwork.baseMainnet,
        WalletNetwork.arbitrumOne,
      ]);
      expect(view.sections.map((s) => s.subtotalMinor), [
        412050 + 12500 + 824100,
        206025,
        21600 + 1080,
      ]);
      expect(view.sections.map((s) => s.currencyCode), ['USD', 'USD', 'USD']);
    });

    test('puts staked and unclaimed positions under their asset', () {
      final view = build();
      final ethereum = view.sections.first;

      final eth = ethereum.groups.firstWhere(
        (group) => group.primary.symbol == 'ETH',
      );
      expect(eth.primary.position, HoldingPosition.available);
      expect(eth.positions.map((h) => h.position), [HoldingPosition.staked]);
      expect(ethereum.groups, hasLength(2), reason: 'ETH and USDC');

      final arbitrum = view.sections.last;
      expect(
        arbitrum.groups.single.positions.single.position,
        HoldingPosition.unclaimedRewards,
      );
    });

    test('leads an asset held only as a position with that position', () {
      final view = build(
        holdings: [
          fixtureHolding(
            network: WalletNetwork.solanaMainnet,
            id: '00000000-0000-0000-0000-000000000c01',
            symbol: 'SOL',
            position: HoldingPosition.staked,
            valueMinor: 5000,
          ),
        ],
        states: const [],
      );

      final group = view.sections.single.groups.single;
      expect(group.primary.position, HoldingPosition.staked);
      expect(group.positions, isEmpty);
    });

    test('folds suspected, user-hidden and unpriced holdings into Hidden', () {
      final view = build();

      expect(view.hidden.map((h) => h.reason), [
        HiddenReason.hiddenByUser,
        HiddenReason.suspected,
        HiddenReason.unpriced,
      ]);
      expect(view.hiddenCount(HiddenReason.unpriced), 1);
      expect(
        view.sections.expand((s) => s.groups).expand((g) => g.holdings),
        isNot(contains(view.hidden.first.holding)),
      );
    });

    test('a suspected holding stays hidden whatever its price', () {
      final view = build();
      final suspected = view.hidden.firstWhere(
        (h) => h.reason == HiddenReason.suspected,
      );

      expect(suspected.holding.valueMinor, 9900000);
      // Its $99,000 never reaches a subtotal.
      expect(
        view.sections.map((s) => s.subtotalMinor!).reduce((a, b) => a + b),
        412050 + 12500 + 824100 + 206025 + 21600 + 1080,
      );
    });

    test('an allowed holding counts again', () {
      final wallet = fixtureEvmWallet(now);
      final allowed = wallet.holdings
          .firstWhere((h) => h.symbol == 'CLAIM-USDC.xyz')
          .copyWith(spamVerdict: SpamVerdict.allowedByUser);

      final view = build(
        holdings: [
          for (final holding in wallet.holdings)
            if (holding.id == allowed.id) allowed else holding,
        ],
      );

      expect(view.hiddenCount(HiddenReason.suspected), 0);
      expect(
        view.sections.first.subtotalMinor,
        412050 + 12500 + 824100 + 9900000,
      );
    });

    test('a failed network with nothing to count still gets a section', () {
      final view = build(
        holdings: const [],
        states: [
          fixtureNetworkState(
            WalletNetwork.baseMainnet,
            lastError: 'Base did not answer in time.',
          ),
          fixtureNetworkState(
            WalletNetwork.ethereumMainnet,
            lastReadAt: now,
          ),
        ],
      );

      expect(view.sections, hasLength(1));
      final section = view.sections.single;
      expect(section.network, WalletNetwork.baseMainnet);
      expect(section.failed, isTrue);
      expect(section.subtotalMinor, isNull);
      expect(section.currencyCode, 'GBP');
      expect(view.isEmpty, isFalse);
    });

    test('a wallet with no holdings and no failures is empty', () {
      final view = build(holdings: const [], states: const []);

      expect(view.isEmpty, isTrue);
    });

    test("carries each network's read state onto its section", () {
      final base = build().sections.firstWhere(
        (s) => s.network == WalletNetwork.baseMainnet,
      );

      expect(base.lastReadAt, now.subtract(const Duration(hours: 2)));
      expect(base.lastError, 'Base did not answer in time.');
      expect(base.hasReadState, isTrue);
    });
  });
}
