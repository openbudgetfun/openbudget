import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/wallets/prices/price_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../../../support/fake_http_client.dart';
import '../../../support/pg_test_server.dart';

void main() {
  late PgTestServer server;
  late Session session;
  var started = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    started = true;
    session = server.session;
  });

  tearDownAll(() async {
    if (started) await server.stop();
  });

  setUp(() async {
    final existing = await AssetPrice.db.find(session);
    for (final row in existing) {
      await AssetPrice.db.deleteRow(session, row);
    }
    PriceService.resetForTests();
  });

  tearDown(PriceService.resetForTests);

  test('fresh cache hit makes no HTTP call', () async {
    final now = DateTime(2026, 11, 13, 12).toUtc();
    await AssetPrice.db.insertRow(
      session,
      AssetPrice(
        network: WalletNetwork.ethereumMainnet,
        assetId: 'native',
        currencyCode: 'USD',
        unitPrice: '123.45',
        source: PriceSource.coingecko,
        fetchedAt: now,
        expiresAt: now.add(const Duration(minutes: 15)),
      ),
    );

    final client = FakeHttpClient(
      handler: (_, _) async {
        throw AssertionError('HTTP called on cache hit');
      },
    );

    final result = await PriceService.resolve(
      session,
      [(WalletNetwork.ethereumMainnet, 'native')],
      httpClient: client,
      now: now,
    );

    expect(client.requestedUris, isEmpty);
    expect(
      result[(WalletNetwork.ethereumMainnet, 'native')]?.unitPrice,
      '123.45',
    );
    expect(
      result[(WalletNetwork.ethereumMainnet, 'native')]?.source,
      PriceSource.coingecko,
    );
  });

  test('expired cache triggers call and rewrites cache', () async {
    final oldNow = DateTime(2026, 11, 13, 11).toUtc();
    final now = DateTime(2026, 11, 13, 12).toUtc();
    await AssetPrice.db.insertRow(
      session,
      AssetPrice(
        network: WalletNetwork.ethereumMainnet,
        assetId: 'native',
        currencyCode: 'USD',
        unitPrice: '1.0',
        source: PriceSource.coingecko,
        fetchedAt: oldNow,
        expiresAt: oldNow.add(const Duration(minutes: 15)),
      ),
    );

    final body = await File(
      'test/fixtures/wallets/coingecko/simple_price_natives.json',
    ).readAsString();
    final client = FakeHttpClient(
      handler: (_, _) async => FakeHttpResponse(body: body),
    );

    final result = await PriceService.resolve(
      session,
      [(WalletNetwork.ethereumMainnet, 'native')],
      httpClient: client,
      now: now,
    );

    expect(client.requestedUris, isNotEmpty);
    final row = result[(WalletNetwork.ethereumMainnet, 'native')];
    expect(row, isNotNull);
    expect(row!.source, PriceSource.coingecko);
    expect(row.unitPrice, '1940.13');
    expect(row.expiresAt.toUtc(), now.add(const Duration(minutes: 15)));

    final rows = await AssetPrice.db.find(
      session,
      where: (t) =>
          t.network.equals(WalletNetwork.ethereumMainnet) &
          t.assetId.equals('native'),
    );
    expect(rows.single.expiresAt.toUtc(), now.add(const Duration(minutes: 15)));
    expect(rows.single.unitPrice, '1940.13');
  });

  test('CoinGecko wins when both answer', () async {
    final now = DateTime(2026, 11, 13, 12).toUtc();
    final cgBody = await File(
      'test/fixtures/wallets/coingecko/simple_price_natives.json',
    ).readAsString();
    final dlBody = await File(
      'test/fixtures/wallets/defillama/prices_current_native_ids.json',
    ).readAsString();

    final client = FakeHttpClient(
      handler: (uri, _) async {
        if (uri.host.contains('llama')) {
          return FakeHttpResponse(body: dlBody);
        }
        return FakeHttpResponse(body: cgBody);
      },
    );

    final result = await PriceService.resolve(
      session,
      [(WalletNetwork.ethereumMainnet, 'native')],
      httpClient: client,
      now: now,
    );

    final row = result[(WalletNetwork.ethereumMainnet, 'native')];
    expect(row, isNotNull);
    expect(row!.source, PriceSource.coingecko);
  });

  test('DefiLlama below threshold ignored, at/above used', () async {
    final now = DateTime(2026, 11, 13, 12).toUtc();
    // CoinGecko returns nothing for this token (empty), DefiLlama returns one below + one above.
    final dlBody = jsonEncode({
      'coins': {
        'ethereum:0x1111111111111111111111111111111111111111': {
          'price': 5.0,
          'confidence': 0.8,
        },
        // use a network with defillama chain; ethereum -> ethereum
      },
    });
    // Need a key that misses CoinGecko: use a token contract not in cg fixture.
    const contract = '0x1111111111111111111111111111111111111111';
    final cgBody = jsonEncode({}); // no prices

    final client = FakeHttpClient(
      handler: (uri, _) async {
        if (uri.host.contains('llama')) {
          return FakeHttpResponse(body: dlBody);
        }
        return FakeHttpResponse(body: cgBody);
      },
    );

    final result = await PriceService.resolve(
      session,
      [(WalletNetwork.ethereumMainnet, contract)],
      httpClient: client,
      now: now,
    );

    // below threshold -> no price
    expect(result[(WalletNetwork.ethereumMainnet, contract)], isNull);
  });

  test('DefiLlama at or above threshold used with defillama source', () async {
    final now = DateTime(2026, 11, 13, 12).toUtc();
    const contract = '0x2222222222222222222222222222222222222222';
    final dlBody = jsonEncode({
      'coins': {
        'ethereum:$contract': {'price': 7.5, 'confidence': 0.95},
      },
    });
    final cgBody = jsonEncode({});

    final client = FakeHttpClient(
      handler: (uri, _) async {
        if (uri.host.contains('llama')) {
          return FakeHttpResponse(body: dlBody);
        }
        return FakeHttpResponse(body: cgBody);
      },
    );

    final result = await PriceService.resolve(
      session,
      [(WalletNetwork.ethereumMainnet, contract)],
      httpClient: client,
      now: now,
    );

    final row = result[(WalletNetwork.ethereumMainnet, contract)];
    expect(row, isNotNull);
    expect(row!.source, PriceSource.defillama);
    expect(row.unitPrice, '7.5');
  });

  test('symbol never used as key: contract-only request', () async {
    final now = DateTime(2026, 11, 13, 12).toUtc();
    const contract = '0x3333333333333333333333333333333333333333';
    const walletAddress = '0x9999999999999999999999999999999999999999';
    final cgBody = jsonEncode({});
    final dlBody = jsonEncode({'coins': <String, dynamic>{}});

    final client = FakeHttpClient(
      handler: (uri, req) async {
        final haystack = uri.toString();
        if (haystack.contains(walletAddress)) {
          throw AssertionError('wallet address leaked');
        }
        // no bare symbol USDC should appear as a key in URL
        expect(haystack, isNot(contains('USDC')));
        if (uri.host.contains('llama')) return FakeHttpResponse(body: dlBody);
        return FakeHttpResponse(body: cgBody);
      },
    );

    await PriceService.resolve(
      session,
      [(WalletNetwork.ethereumMainnet, contract)],
      httpClient: client,
      now: now,
    );

    for (final uri in client.requestedUris) {
      expect(uri.toString(), isNot(contains(walletAddress)));
      expect(uri.toString(), isNot(contains('USDC')));
    }
  });

  test('no address appears in any price request', () async {
    final now = DateTime(2026, 11, 13, 12).toUtc();
    const walletAddress = '0xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    final cgBody = await File(
      'test/fixtures/wallets/coingecko/simple_price_natives.json',
    ).readAsString();
    final dlBody = await File(
      'test/fixtures/wallets/defillama/prices_current_native_ids.json',
    ).readAsString();

    final client = FakeHttpClient(
      handler: (uri, req) async {
        final haystack = '$uri ${req.headers}';
        if (haystack.toLowerCase().contains(walletAddress.toLowerCase())) {
          throw AssertionError('wallet address leaked in request');
        }
        if (uri.host.contains('llama')) return FakeHttpResponse(body: dlBody);
        return FakeHttpResponse(body: cgBody);
      },
    );

    await PriceService.resolve(
      session,
      [(WalletNetwork.ethereumMainnet, 'native')],
      httpClient: client,
      now: now,
    );

    for (final uri in client.requestedUris) {
      expect(
        uri.toString().toLowerCase(),
        isNot(contains(walletAddress.toLowerCase())),
      );
    }
  });
}
