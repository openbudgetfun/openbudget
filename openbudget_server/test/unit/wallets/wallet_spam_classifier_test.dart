import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/wallets/wallet_spam_classifier.dart';
import 'package:test/test.dart';

void main() {
  group('WalletSpamClassifier', () {
    test('folds look-alikes', () {
      expect(WalletSpamClassifier.foldLookAlikes('UЅDT'), 'USDT');
    });

    test('fake USDT is suspected', () {
      final verdict = WalletSpamClassifier.classify(
        network: WalletNetwork.ethereumMainnet,
        assetId: '0x0000000000000000000000000000000000000001',
        symbol: 'USDT',
        name: 'Tether USD',
        priceSource: PriceSource.defillama,
        valueMinor: 5000000,
        walletTotalValueMinor: 100000,
      );
      expect(verdict, SpamVerdict.suspected);
    });

    test('visit claim-site.com is suspected', () {
      final verdict = WalletSpamClassifier.classify(
        network: WalletNetwork.ethereumMainnet,
        assetId: '0x0000000000000000000000000000000000000002',
        symbol: 'VISIT',
        name: 'visit claim-site.com',
      );
      expect(verdict, SpamVerdict.suspected);
    });

    test('unlisted 50k outlier is suspected', () {
      final verdict = WalletSpamClassifier.classify(
        network: WalletNetwork.ethereumMainnet,
        assetId: '0x0000000000000000000000000000000000000003',
        symbol: 'FOO',
        name: 'Foo Token',
        priceSource: PriceSource.defillama,
        valueMinor: 5000000,
        walletTotalValueMinor: 100000,
      );
      expect(verdict, SpamVerdict.suspected);
    });

    test('real USDC is clean', () {
      final verdict = WalletSpamClassifier.classify(
        network: WalletNetwork.ethereumMainnet,
        assetId: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
        symbol: 'USDC',
        name: 'USD Coin',
        priceSource: PriceSource.coingecko,
        valueMinor: 100000,
        walletTotalValueMinor: 100000,
      );
      expect(verdict, SpamVerdict.clean);
    });

    test('native coin is clean', () {
      final verdict = WalletSpamClassifier.classify(
        network: WalletNetwork.ethereumMainnet,
        assetId: 'native',
        symbol: 'ETH',
        name: 'Ethereum',
      );
      expect(verdict, SpamVerdict.clean);
    });
  });
}
