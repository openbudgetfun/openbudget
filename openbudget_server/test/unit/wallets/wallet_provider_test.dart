import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:test/test.dart';

void main() {
  group('Given WalletReadRequest', () {
    test('when built then history and HD fields default empty', () {
      const request = WalletReadRequest(
        homeNetwork: WalletNetwork.solanaMainnet,
        networks: [WalletNetwork.solanaMainnet],
        address: '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin',
      );
      expect(request.historyCursors, isEmpty);
      expect(request.includeHistory, isTrue);
      expect(request.descriptor, isNull);
      expect(request.untilSignature, isNull);
    });

    test(
      'when turned into a string then it never carries the address or the '
      'descriptor',
      () {
        const address = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin';
        const descriptor = 'wpkh(xpubDescriptorBody/<0;1>/*)';
        const request = WalletReadRequest(
          homeNetwork: WalletNetwork.bitcoinMainnet,
          networks: [WalletNetwork.bitcoinMainnet],
          address: address,
          descriptor: descriptor,
        );

        final text = request.toString();
        expect(text, isNot(contains(address)));
        expect(text, isNot(contains('xpubDescriptorBody')));
        expect(text, isNot(contains('https://')));
      },
    );
  });

  group('Given WalletProviderSnapshot', () {
    test('when built then failure and cursor maps default empty', () {
      const snapshot = WalletProviderSnapshot(
        readNetworks: [WalletNetwork.solanaMainnet],
        holdings: [],
        transactions: [],
        warnings: [],
      );
      expect(snapshot.failedNetworks, isEmpty);
      expect(snapshot.historyCursors, isEmpty);
      expect(snapshot.newestSignature, isNull);
    });

    test(
      'when turned into a string then it never carries a plain-words '
      'failure reason mapped to an address',
      () {
        final snapshot = WalletProviderSnapshot(
          readNetworks: [WalletNetwork.solanaMainnet],
          holdings: [
            WalletProviderHolding(
              network: WalletNetwork.solanaMainnet,
              assetId: 'native',
              decimals: 9,
              quantityRaw: BigInt.parse('1000000000'),
              isNft: false,
              prices: [],
            ),
          ],
          transactions: [],
          warnings: [],
        );

        final text = snapshot.toString();
        expect(
          text,
          isNot(contains('9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin')),
        );
        expect(text, isNot(contains('https://')));
      },
    );
  });
}
