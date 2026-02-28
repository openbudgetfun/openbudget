import 'package:openbudget_server/src/solana_wallets/jupiter_price_client.dart';
import 'package:test/test.dart';

void main() {
  group('JupiterPriceClient.parseUsdPriceResponse', () {
    test('parses v3 response with data wrapper and price field', () {
      final parsed = JupiterPriceClient.parseUsdPriceResponse({
        'timeTaken': 12.3,
        'data': {
          'So11111111111111111111111111111111111111112': {'price': '154.23'},
          'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v': {'price': 1},
        },
      });

      expect(parsed.length, 2);
      expect(parsed['So11111111111111111111111111111111111111112'], 154.23);
      expect(parsed['EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v'], 1.0);
    });

    test('parses legacy payload with root map and usdPrice field', () {
      final parsed = JupiterPriceClient.parseUsdPriceResponse({
        'So11111111111111111111111111111111111111112': {'usdPrice': 155.5},
        'jtojtomepa8beP8AuQc6eXt5FriJwfFMwQx2v2f9mCL': {'usdPrice': '2.47'},
      });

      expect(parsed.length, 2);
      expect(parsed['So11111111111111111111111111111111111111112'], 155.5);
      expect(parsed['jtojtomepa8beP8AuQc6eXt5FriJwfFMwQx2v2f9mCL'], 2.47);
    });

    test('ignores entries without usable positive prices', () {
      final parsed = JupiterPriceClient.parseUsdPriceResponse({
        'data': {
          'So11111111111111111111111111111111111111112': {'price': 0},
          'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v': {'price': -1},
          'invalid': {'foo': 'bar'},
          'token': 'not-a-number',
        },
      });

      expect(parsed, isEmpty);
    });
  });
}
