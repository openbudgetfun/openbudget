import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/wallets/bitcoin/bitcoin_wallet_provider.dart';
import 'package:openbudget_server/src/wallets/bitcoin/esplora_client.dart';
import 'package:openbudget_server/src/wallets/jupiter_price_client.dart';
import 'package:openbudget_server/src/wallets/magic_eden_nft_price_client.dart';
import 'package:openbudget_server/src/wallets/prices/coingecko_price_client.dart';
import 'package:openbudget_server/src/wallets/prices/defillama_price_client.dart';
import 'package:openbudget_server/src/wallets/solana_wallet_provider.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/xrpl/xrpl_client.dart';
import 'package:openbudget_server/src/wallets/xrpl/xrpl_wallet_provider.dart';
import 'package:solana_kit_helius/solana_kit_helius.dart';
import 'package:test/test.dart';

const _testAddress = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin';
const _apiKey = 'super-secret-api-key';

/// An extended public key: a `[xyz]pub` prefix followed by its base58 body.
final _extendedKey = RegExp('[xyz]pub[1-9A-HJ-NP-Za-km-z]{20,}');

class _FakeIoResponse implements HttpClientResponse {
  _FakeIoResponse(this._status, this._body);

  final int _status;
  final List<int> _body;
  final _FakeHttpHeaders _headers = _FakeHttpHeaders();

  @override
  int get statusCode => _status;

  @override
  HttpHeaders get headers => _headers;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.fromIterable(<List<int>>[_body]).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  @override
  Stream<T> transform<T>(StreamTransformer<List<int>, T> streamTransformer) =>
      streamTransformer.bind(
        Stream<List<int>>.fromIterable(<List<int>>[_body]),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeIoRequest implements HttpClientRequest {
  _FakeIoRequest(this._uri, this._response);

  final Uri _uri;
  final _FakeIoResponse _response;
  final _FakeHttpHeaders _headers = _FakeHttpHeaders();

  @override
  Uri get uri => _uri;

  @override
  HttpHeaders get headers => _headers;

  @override
  Future<HttpClientResponse> close() async => _response;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClient implements HttpClient {
  _FakeHttpClient(this._handler);

  final _FakeIoResponse Function(Uri uri) _handler;
  final List<_FakeIoRequest> requests = <_FakeIoRequest>[];

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    final request = _FakeIoRequest(url, _handler(url));
    requests.add(request);
    return request;
  }

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttp extends http.BaseClient {
  _FakeHttp(this._handler);

  final http.Response Function(http.BaseRequest request) _handler;
  final List<http.BaseRequest> requests = <http.BaseRequest>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    final response = _handler(request);
    return http.StreamedResponse(
      Stream<List<int>>.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

class _FakeHttpHeaders implements HttpHeaders {
  final Map<String, String> _values = <String, String>{};

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _values[name.toLowerCase()] = value.toString();
  }

  @override
  String? value(String name) => _values[name.toLowerCase()];

  Iterable<String> get keys => _values.keys;

  @override
  String toString() => _values.toString();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late List<String> captured;
  late StreamSubscription<LogRecord> subscription;

  setUp(() {
    Logger.root.level = Level.ALL;
    captured = <String>[];
    subscription = Logger.root.onRecord.listen((record) {
      captured.add(record.message);
      if (record.error != null) captured.add(record.error.toString());
      if (record.stackTrace != null) {
        captured.add(record.stackTrace.toString());
      }
    });
  });

  tearDown(() async {
    await subscription.cancel();
  });

  bool containsForbidden(String output) {
    final lower = output.toLowerCase();
    if (lower.contains(_testAddress.toLowerCase())) return true;
    if (lower.contains(_apiKey.toLowerCase())) return true;
    if (_extendedKey.hasMatch(output)) return true;
    if (lower.contains('descriptor')) return true;
    if (lower.contains('http://')) return true;
    if (lower.contains('https://')) return true;
    return false;
  }

  void assertClean() {
    for (final entry in captured) {
      expect(
        containsForbidden(entry),
        isFalse,
        reason: 'Captured output leaked forbidden data: $entry',
      );
    }
  }

  group('privacy: provider failure paths', () {
    test('Jupiter price client failure paths are clean', () async {
      for (final status in <int>[400, 429, 500]) {
        final fake = _FakeHttpClient(
          (uri) => _FakeIoResponse(status, utf8.encode('{"error":"nope"}')),
        );
        await JupiterPriceClient.fetchUsdPrices(
          mintAddresses: <String>[_testAddress],
          httpClient: fake,
          onWarning: captured.add,
        );
      }

      // Malformed JSON.
      final malformed = _FakeHttpClient(
        (uri) => _FakeIoResponse(200, utf8.encode('{not json')),
      );
      await JupiterPriceClient.fetchUsdPrices(
        mintAddresses: <String>[_testAddress],
        httpClient: malformed,
        onWarning: captured.add,
      );

      // Timeout.
      final timingOut = _FakeHttpClient((uri) {
        throw TimeoutException('timed out');
      });
      await JupiterPriceClient.fetchUsdPrices(
        mintAddresses: <String>[_testAddress],
        httpClient: timingOut,
        onWarning: captured.add,
      );

      assertClean();
    });

    test('Magic Eden price client failure paths are clean', () async {
      for (final status in <int>[400, 429, 500]) {
        final fake = _FakeHttpClient(
          (uri) => _FakeIoResponse(status, utf8.encode('{"error":"nope"}')),
        );
        await MagicEdenNftPriceClient.fetchUsdQuotes(
          mintAddresses: <String>[_testAddress],
          solUsdPrice: 100,
          httpClient: fake,
          onWarning: captured.add,
        );
      }

      final malformed = _FakeHttpClient(
        (uri) => _FakeIoResponse(200, utf8.encode('{not json')),
      );
      await MagicEdenNftPriceClient.fetchUsdQuotes(
        mintAddresses: <String>[_testAddress],
        solUsdPrice: 100,
        httpClient: malformed,
        onWarning: captured.add,
      );

      final timingOut = _FakeHttpClient((uri) {
        throw TimeoutException('timed out');
      });
      await MagicEdenNftPriceClient.fetchUsdQuotes(
        mintAddresses: <String>[_testAddress],
        solUsdPrice: 100,
        httpClient: timingOut,
        onWarning: captured.add,
      );

      assertClean();
    });

    test('Solana provider failure paths are clean', () async {
      for (final status in <int>[400, 429, 500]) {
        final fakeHttp = _FakeHttp(
          (request) => http.Response('{"error":"nope"}', status),
        );
        final helius = createHelius(
          HeliusConfig(apiKey: _apiKey),
          client: fakeHttp,
        );
        final provider = SolanaWalletProvider(helius: helius);
        try {
          await provider.fetchSnapshot(
            const WalletReadRequest(
              homeNetwork: WalletNetwork.solanaMainnet,
              networks: <WalletNetwork>[WalletNetwork.solanaMainnet],
              address: _testAddress,
            ),
          );
        } on Object catch (error) {
          captured.add(error.toString());
        }
      }

      // Malformed JSON (200 with bad body).
      final malformedHttp = _FakeHttp(
        (request) => http.Response('{not json', 200),
      );
      final malformedHelius = createHelius(
        HeliusConfig(apiKey: _apiKey),
        client: malformedHttp,
      );
      final malformedProvider = SolanaWalletProvider(helius: malformedHelius);
      try {
        await malformedProvider.fetchSnapshot(
          const WalletReadRequest(
            homeNetwork: WalletNetwork.solanaMainnet,
            networks: <WalletNetwork>[WalletNetwork.solanaMainnet],
            address: _testAddress,
          ),
        );
      } on Object catch (error) {
        captured.add(error.toString());
      }

      // Timeout.
      final timingOutHttp = _FakeHttp((request) {
        throw TimeoutException('timed out');
      });
      final timingOutHelius = createHelius(
        HeliusConfig(apiKey: _apiKey),
        client: timingOutHttp,
      );
      final timingOutProvider = SolanaWalletProvider(helius: timingOutHelius);
      try {
        await timingOutProvider.fetchSnapshot(
          const WalletReadRequest(
            homeNetwork: WalletNetwork.solanaMainnet,
            networks: <WalletNetwork>[WalletNetwork.solanaMainnet],
            address: _testAddress,
          ),
        );
      } on Object catch (error) {
        captured.add(error.toString());
      }

      assertClean();
    });
  });

  group('privacy: HTTP request shape', () {
    test(
      'Jupiter request carries only the address and no extra headers',
      () async {
        final fake = _FakeHttpClient(
          (uri) => _FakeIoResponse(200, utf8.encode('{}')),
        );
        await JupiterPriceClient.fetchUsdPrices(
          mintAddresses: <String>[_testAddress],
          httpClient: fake,
        );

        expect(fake.requests, isNotEmpty);
        for (final request in fake.requests) {
          final serialized = '${request.uri} ${request.headers}';
          expect(
            serialized.toLowerCase(),
            contains(_testAddress.toLowerCase()),
          );
          expect(serialized.toLowerCase(), isNot(contains('userid')));
          expect(serialized.toLowerCase(), isNot(contains('user_id')));
          expect(serialized.toLowerCase(), isNot(contains('entity')));
          expect(serialized.toLowerCase(), isNot(contains('email')));
          expect(request.headers.value('x-user-id'), isNull);
          expect(request.headers.value('authorization'), isNull);
        }
      },
    );

    test(
      'Magic Eden request carries only the address and a generic user agent',
      () async {
        final fake = _FakeHttpClient(
          (uri) => _FakeIoResponse(200, utf8.encode('{}')),
        );
        await MagicEdenNftPriceClient.fetchUsdQuotes(
          mintAddresses: <String>[_testAddress],
          solUsdPrice: 100,
          httpClient: fake,
        );

        expect(fake.requests, isNotEmpty);
        for (final request in fake.requests) {
          final serialized = '${request.uri} ${request.headers}';
          expect(
            serialized.toLowerCase(),
            contains(_testAddress.toLowerCase()),
          );
          expect(serialized.toLowerCase(), isNot(contains('userid')));
          expect(serialized.toLowerCase(), isNot(contains('user_id')));
          expect(serialized.toLowerCase(), isNot(contains('entity')));
          expect(serialized.toLowerCase(), isNot(contains('email')));
        }
      },
    );

    test(
      'Helius request carries the address and key but no user data',
      () async {
        final fakeHttp = _FakeHttp((request) => http.Response('{}', 200));
        final helius = createHelius(
          HeliusConfig(apiKey: _apiKey),
          client: fakeHttp,
        );

        try {
          await helius.wallet.getBalances(
            const GetBalancesRequest(address: _testAddress),
          );
        } on Object catch (_) {
          // Parsing may fail; the request was still captured.
        }

        expect(fakeHttp.requests, isNotEmpty);
        for (final request in fakeHttp.requests) {
          final serialized = '${request.url} ${request.headers}';
          expect(serialized, contains(_testAddress));
          expect(serialized, isNot(contains('user')));
          expect(serialized, isNot(contains('entity')));
          expect(serialized, isNot(contains('email')));
        }
      },
    );
  });

  group('privacy: bitcoin/esplora failure paths', () {
    test('Esplora client failure paths are clean', () async {
      for (final status in <int>[400, 429, 500]) {
        final client = EsploraClient(
          baseUrls: [Uri.parse('https://mempool.space/api')],
          transport: (_) async =>
              EsploraResponse(statusCode: status, body: '{"error":"nope"}'),
        );
        try {
          await client.fetchAddress(_testAddress);
        } on Object catch (error) {
          captured.add(error.toString());
        }
      }

      final malformed = EsploraClient(
        baseUrls: [Uri.parse('https://mempool.space/api')],
        transport: (_) async =>
            const EsploraResponse(statusCode: 200, body: '{not json'),
      );
      try {
        await malformed.fetchAddress(_testAddress);
      } on Object catch (error) {
        captured.add(error.toString());
      }

      final timingOut = EsploraClient(
        baseUrls: [Uri.parse('https://mempool.space/api')],
        transport: (_) async => throw TimeoutException('timed out'),
      );
      try {
        await timingOut.fetchAddress(_testAddress);
      } on Object catch (error) {
        captured.add(error.toString());
      }

      // xpub input must never appear in captured output.
      final xpubClient = EsploraClient(
        baseUrls: [Uri.parse('https://mempool.space/api')],
        transport: (_) async =>
            const EsploraResponse(statusCode: 500, body: 'err'),
      );
      const xpub =
          'xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8';
      try {
        await xpubClient.fetchAddress(xpub);
      } on Object catch (error) {
        captured.add(error.toString());
      }

      assertClean();
    });

    test('Bitcoin provider refuses xpub without leaking', () async {
      const xpub =
          'xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8';
      final client = EsploraClient(
        baseUrls: [Uri.parse('https://mempool.space/api')],
        transport: (_) async =>
            const EsploraResponse(statusCode: 200, body: '{}'),
      );
      try {
        await BitcoinWalletProvider(client: client).fetchSnapshot(
          const WalletReadRequest(
            homeNetwork: WalletNetwork.bitcoinMainnet,
            networks: <WalletNetwork>[WalletNetwork.bitcoinMainnet],
            address: xpub,
          ),
        );
      } on Object catch (error) {
        captured.add(error.toString());
      }
      assertClean();
    });
  });

  group('privacy: xrpl failure paths', () {
    test('Xrpl client failure paths are clean', () async {
      for (final status in <int>[400, 429, 500]) {
        final client = XrplClient(
          endpoints: ['https://xrplcluster.com'],
          transport: (_, [_]) async => XrplResponse(
            statusCode: status,
            body: '{"result":{"error":"nope"}}',
          ),
        );
        try {
          await client.call('account_info', {'account': _testAddress});
        } on Object catch (error) {
          captured.add(error.toString());
        }
      }

      final malformed = XrplClient(
        endpoints: ['https://xrplcluster.com'],
        transport: (_, [_]) async =>
            const XrplResponse(statusCode: 200, body: '{not json'),
      );
      try {
        await malformed.call('account_info', {'account': _testAddress});
      } on Object catch (error) {
        captured.add(error.toString());
      }

      final timingOut = XrplClient(
        endpoints: ['https://xrplcluster.com'],
        transport: (_, [_]) async => throw TimeoutException('timed out'),
      );
      try {
        await timingOut.call('account_info', {'account': _testAddress});
      } on Object catch (error) {
        captured.add(error.toString());
      }

      assertClean();
    });

    test('Xrpl provider failure paths are clean', () async {
      final provider = XrplWalletProvider(
        transport: (_, [_]) async => const XrplResponse(
          statusCode: 500,
          body: '{"result":{"error":"nope"}}',
        ),
      );
      try {
        await provider.fetchSnapshot(
          const WalletReadRequest(
            homeNetwork: WalletNetwork.xrplMainnet,
            networks: <WalletNetwork>[WalletNetwork.xrplMainnet],
            address: _testAddress,
          ),
        );
      } on Object catch (error) {
        captured.add(error.toString());
      }
      assertClean();
    });
  });

  group('privacy: coingecko failure paths', () {
    test('CoinGecko client failure paths are clean', () async {
      for (final status in <int>[400, 429, 500]) {
        final fake = _FakeHttpClient(
          (uri) => _FakeIoResponse(status, utf8.encode('{"error":"nope"}')),
        );
        await CoinGeckoPriceClient.fetchSimplePrices(
          ids: <String>['bitcoin'],
          httpClient: fake,
          passwords: const {'coingeckoProApiKey': _apiKey},
        );
      }

      final malformed = _FakeHttpClient(
        (uri) => _FakeIoResponse(200, utf8.encode('{not json')),
      );
      await CoinGeckoPriceClient.fetchSimplePrices(
        ids: <String>['bitcoin'],
        httpClient: malformed,
        passwords: const {'coingeckoProApiKey': _apiKey},
      );

      final timingOut = _FakeHttpClient((uri) {
        throw TimeoutException('timed out');
      });
      await CoinGeckoPriceClient.fetchSimplePrices(
        ids: <String>['bitcoin'],
        httpClient: timingOut,
        passwords: const {'coingeckoProApiKey': _apiKey},
      );

      assertClean();
    });
  });

  group('privacy: defillama failure paths', () {
    test('DefiLlama client failure paths are clean', () async {
      for (final status in <int>[400, 429, 500]) {
        final fake = _FakeHttpClient(
          (uri) => _FakeIoResponse(status, utf8.encode('{"error":"nope"}')),
        );
        await DefiLlamaPriceClient.fetchPrices(
          coins: <String>['coingecko:bitcoin'],
          httpClient: fake,
        );
      }

      final malformed = _FakeHttpClient(
        (uri) => _FakeIoResponse(200, utf8.encode('{not json')),
      );
      await DefiLlamaPriceClient.fetchPrices(
        coins: <String>['coingecko:bitcoin'],
        httpClient: malformed,
      );

      final timingOut = _FakeHttpClient((uri) {
        throw TimeoutException('timed out');
      });
      await DefiLlamaPriceClient.fetchPrices(
        coins: <String>['coingecko:bitcoin'],
        httpClient: timingOut,
      );

      assertClean();
    });
  });

  group('privacy: HTTP request shape (extra vendors)', () {
    test('Esplora request carries only the address', () async {
      final urls = <Uri>[];
      final client = EsploraClient(
        baseUrls: [Uri.parse('https://mempool.space/api')],
        transport: (uri) async {
          urls.add(uri);
          return const EsploraResponse(
            statusCode: 200,
            body: '{"chain_stats":{"funded_txo_sum":0,"spent_txo_sum":0},"mempool_stats":{"funded_txo_sum":0,"spent_txo_sum":0}}',
          );
        },
      );
      await client.fetchAddress(_testAddress);
      expect(urls, isNotEmpty);
      for (final uri in urls) {
        expect(uri.toString(), contains(_testAddress));
      }
    });
  });
}
