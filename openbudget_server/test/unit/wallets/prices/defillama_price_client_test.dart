import 'dart:convert';
import 'dart:io';

import 'package:openbudget_server/src/wallets/prices/defillama_price_client.dart';
import 'package:test/test.dart';

import '../../../support/fake_http_client.dart';

void main() {
  group('DefiLlamaPriceClient threshold', () {
    test('below threshold ignored, at/above used', () {
      final input = {
        'coins': {
          'low': {'price': 10.0, 'confidence': 0.85},
          'edge': {'price': 10.0, 'confidence': 0.9},
          'high': {'price': 10.0, 'confidence': 0.999},
        },
      };
      final parsed = DefiLlamaPriceClient.parsePricesResponse(input);
      final filtered = DefiLlamaPriceClient.filterByConfidence(parsed);
      expect(filtered.containsKey('low'), isFalse);
      expect(filtered.containsKey('edge'), isTrue);
      expect(filtered.containsKey('high'), isTrue);
      expect(parsed['edge']!.isAboveThreshold, isTrue);
    });

    test('confidenceThreshold is 0.9', () {
      expect(DefiLlamaPriceClient.confidenceThreshold, 0.9);
    });
  });

  group('DefiLlamaPriceClient fixtures parse', () {
    for (final entry in const [
      ('prices_current_native_ids.json', 14),
      ('prices_current_stablecoins.json', 9),
      ('prices_current_token_chains.json', 3),
      ('prices_current_untracked.json', 0),
    ]) {
      test('parses ${entry.$1}', () async {
        final body = await File(
          'test/fixtures/wallets/defillama/${entry.$1}',
        ).readAsString();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final parsed = DefiLlamaPriceClient.parsePricesResponse(json);
        expect(parsed.length, entry.$2);
        for (final p in parsed.values) {
          expect(p.price, greaterThan(0));
          expect(p.confidence, greaterThanOrEqualTo(0));
        }
      });
    }

    test('token_chains fixture keeps 0.9 entry at threshold', () async {
      final body = await File(
        'test/fixtures/wallets/defillama/prices_current_token_chains.json',
      ).readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final parsed = DefiLlamaPriceClient.parsePricesResponse(json);
      final filtered = DefiLlamaPriceClient.filterByConfidence(parsed);
      // TON USDT at exactly 0.9 is included.
      expect(filtered.length, 3);
    });

    test('fetchPrices uses fixture and returns confidences', () async {
      final body = await File(
        'test/fixtures/wallets/defillama/prices_current_stablecoins.json',
      ).readAsString();
      final client = FakeHttpClient(
        handler: (_, _) async => FakeHttpResponse(body: body),
      );
      final prices = await DefiLlamaPriceClient.fetchPrices(
        coins: const ['ethereum:0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'],
        httpClient: client,
      );
      expect(prices.length, 9);
      expect(prices.values.first.confidence, greaterThanOrEqualTo(0.9));
    });
  });

  group('DefiLlamaPriceClient privacy', () {
    test('no wallet address in request URL', () async {
      const address = '0x1111111111111111111111111111111111111111';
      final client = FakeHttpClient(
        handler: (uri, req) async {
          final haystack = '$uri ${req.headers}';
          if (haystack.contains(address)) {
            throw AssertionError('wallet address leaked in request');
          }
          return const FakeHttpResponse(body: '{"coins":{}}');
        },
      );
      await DefiLlamaPriceClient.fetchPrices(
        coins: const ['coingecko:bitcoin'],
        httpClient: client,
      );
      expect(client.requestedUris.single.toString(), isNot(contains(address)));
    });
  });
}
