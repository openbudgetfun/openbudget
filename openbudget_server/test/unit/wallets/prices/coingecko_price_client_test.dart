import 'dart:convert';
import 'dart:io';

import 'package:openbudget_server/src/wallets/prices/coingecko_price_client.dart';
import 'package:test/test.dart';

import '../../../support/fake_http_client.dart';

void main() {
  group('CoinGeckoPriceClient chunking', () {
    test('one call serves 515 ids', () async {
      final client = FakeHttpClient(
        handler: (_, _) async => const FakeHttpResponse(),
      );
      final ids = List.generate(515, (i) => 'id$i');
      await CoinGeckoPriceClient.fetchSimplePrices(
        ids: ids,
        httpClient: client,
      );
      expect(client.requestedUris.length, 1);
    });

    test('516 ids make exactly two calls', () async {
      final client = FakeHttpClient(
        handler: (_, _) async => const FakeHttpResponse(),
      );
      final ids = List.generate(516, (i) => 'id$i');
      await CoinGeckoPriceClient.fetchSimplePrices(
        ids: ids,
        httpClient: client,
      );
      expect(client.requestedUris.length, 2);
    });

    test('token prices chunk at 515 too', () async {
      final client = FakeHttpClient(
        handler: (_, _) async => const FakeHttpResponse(),
      );
      final contracts = List.generate(
        516,
        (i) => '0x${i.toString().padLeft(40, '0')}',
      );
      await CoinGeckoPriceClient.fetchTokenPrices(
        platform: 'ethereum',
        contractAddresses: contracts,
        httpClient: client,
      );
      expect(client.requestedUris.length, 2);
    });
  });

  group('CoinGeckoPriceClient host/header selection', () {
    const proKey = 'pro-secret-key';
    const demoKey = 'demo-secret-key';

    test('pro key -> pro host + x-cg-pro-api-key', () {
      final passwords = {'coingeckoProApiKey': proKey};
      expect(
        CoinGeckoPriceClient.baseUri(
          passwords: passwords,
          environment: const {},
        ).host,
        'pro-api.coingecko.com',
      );
      expect(
        CoinGeckoPriceClient.headerName(
          passwords: passwords,
          environment: const {},
        ),
        'x-cg-pro-api-key',
      );
      expect(
        CoinGeckoPriceClient.apiKey(
          passwords: passwords,
          environment: const {},
        ),
        proKey,
      );
    });

    test('only demo key -> demo host + x-cg-demo-api-key', () {
      final passwords = {'coingeckoDemoApiKey': demoKey};
      expect(
        CoinGeckoPriceClient.baseUri(
          passwords: passwords,
          environment: const {},
        ).host,
        'api.coingecko.com',
      );
      expect(
        CoinGeckoPriceClient.headerName(
          passwords: passwords,
          environment: const {},
        ),
        'x-cg-demo-api-key',
      );
    });

    test('both keys -> pro', () {
      final passwords = {
        'coingeckoProApiKey': proKey,
        'coingeckoDemoApiKey': demoKey,
      };
      expect(
        CoinGeckoPriceClient.baseUri(
          passwords: passwords,
          environment: const {},
        ).host,
        'pro-api.coingecko.com',
      );
      expect(
        CoinGeckoPriceClient.headerName(
          passwords: passwords,
          environment: const {},
        ),
        'x-cg-pro-api-key',
      );
      expect(
        CoinGeckoPriceClient.apiKey(
          passwords: passwords,
          environment: const {},
        ),
        proKey,
      );
    });

    test('key never appears in error message', () async {
      final passwords = {'coingeckoProApiKey': proKey};
      final client = FakeHttpClient(
        handler: (_, _) async =>
            const FakeHttpResponse(statusCode: 401, body: 'nope'),
      );
      final warnings = <String>[];
      await CoinGeckoPriceClient.fetchSimplePrices(
        ids: const ['bitcoin'],
        passwords: passwords,
        httpClient: client,
        onWarning: warnings.add,
      );
      final joined = warnings.join('\n');
      expect(joined, isNot(contains(proKey)));
      expect(joined, contains('HTTP 401'));
    });

    test('key travels in header not URL', () async {
      final passwords = {'coingeckoProApiKey': proKey};
      final client = FakeHttpClient(
        handler: (uri, req) async {
          expect(req.headers.value('x-cg-pro-api-key'), proKey);
          expect(uri.toString(), isNot(contains(proKey)));
          return const FakeHttpResponse();
        },
      );
      await CoinGeckoPriceClient.fetchSimplePrices(
        ids: const ['bitcoin'],
        passwords: passwords,
        httpClient: client,
      );
      expect(client.requestedUris.single.toString(), isNot(contains(proKey)));
    });
  });

  group('CoinGeckoPriceClient parsing', () {
    test('parses simple price fixture', () async {
      final file = File(
        'test/fixtures/wallets/coingecko/simple_price_natives.json',
      );
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final parsed = CoinGeckoPriceClient.parseSimplePriceResponse(json);
      expect(parsed.length, 15);
      expect(parsed['bitcoin'], 68830.0);
      expect(parsed['ethereum'], 1940.13);
    });

    test('parses token price fixture', () async {
      final file = File(
        'test/fixtures/wallets/coingecko/simple_token_price_ethereum.json',
      );
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;
      final parsed = CoinGeckoPriceClient.parseTokenPriceResponse(json);
      expect(parsed.length, 1);
      expect(
        parsed['0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48'],
        0.999551,
      );
    });

    test('fixture parse via fetchSimplePrices maps ids to prices', () async {
      final body = await File(
        'test/fixtures/wallets/coingecko/simple_price_natives.json',
      ).readAsString();
      final client = FakeHttpClient(
        handler: (_, _) async => FakeHttpResponse(body: body),
      );
      final prices = await CoinGeckoPriceClient.fetchSimplePrices(
        ids: const ['bitcoin', 'ethereum'],
        httpClient: client,
      );
      expect(prices['bitcoin'], 68830.0);
      expect(prices['ethereum'], 1940.13);
    });
  });

  group('CoinGeckoPriceClient symbol is never a key', () {
    test('request URL contains contract not bare symbol', () async {
      final client = FakeHttpClient(
        handler: (_, _) async => const FakeHttpResponse(),
      );
      await CoinGeckoPriceClient.fetchTokenPrices(
        platform: 'ethereum',
        contractAddresses: const ['0x1234567890123456789012345678901234567890'],
        httpClient: client,
      );
      final uri = client.requestedUris.single;
      expect(
        uri.queryParameters['contract_addresses'],
        '0x1234567890123456789012345678901234567890',
      );
      expect(uri.toString(), isNot(contains('USDC')));
    });
  });
}
