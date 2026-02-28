import 'package:openbudget_server/src/solana_wallets/magic_eden_nft_price_client.dart';
import 'package:test/test.dart';

void main() {
  group('MagicEdenNftPriceClient parsing', () {
    test('parses listing price and collection symbol from token payload', () {
      final listing = MagicEdenNftPriceClient.parseListingPriceSol({
        'price': '17.35',
      });
      final collection = MagicEdenNftPriceClient.parseCollectionSymbol({
        'collection': ' mad_lads ',
      });

      expect(listing, 17.35);
      expect(collection, 'mad_lads');
    });

    test('ignores invalid listing prices', () {
      expect(
        MagicEdenNftPriceClient.parseListingPriceSol({'price': 0}),
        isNull,
      );
      expect(
        MagicEdenNftPriceClient.parseListingPriceSol({'price': -1}),
        isNull,
      );
      expect(
        MagicEdenNftPriceClient.parseListingPriceSol({'price': 'nope'}),
        isNull,
      );
    });

    test('extracts recent sale price from activities', () {
      final price = MagicEdenNftPriceClient.parseRecentSalePriceSol([
        {'type': 'bid', 'price': 22},
        {'type': 'buyNow', 'price': 19.5},
      ]);

      expect(price, 19.5);
    });

    test('returns null when activities contain no sale events', () {
      final price = MagicEdenNftPriceClient.parseRecentSalePriceSol([
        {'type': 'bid', 'price': 22},
        {'type': 'list', 'price': 23},
      ]);

      expect(price, isNull);
    });

    test('converts collection floor lamports into SOL', () {
      final floor = MagicEdenNftPriceClient.parseCollectionFloorPriceSol({
        'floorPrice': 17351000000,
      });

      expect(floor, closeTo(17.351, 0.0000001));
    });
  });
}
