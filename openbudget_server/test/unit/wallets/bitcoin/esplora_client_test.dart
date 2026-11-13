import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:openbudget_server/src/wallets/bitcoin/esplora_client.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:test/test.dart';

void main() {
  // The fake clock only moves when the injected delay moves it, so a
  // throttle bug that loops would hang the test instead of passing.
  final baseTime = DateTime(2026, 11, 13, 12);

  /// Builds a client. Tests inject [transport], [now] and [delay] so no
  /// test touches the network and no test sleeps.
  ///
  /// Returns the client plus the URLs it requested and the waits its
  /// throttle and `Retry-After` handling asked for.
  (EsploraClient, List<Uri>, List<Duration>) buildClient({
    required Future<Object> Function(Uri url) respond,
    List<Uri>? baseUrls,
    List<Uri>? urls,
    List<Duration>? waits,
  }) {
    final urlList = urls ?? <Uri>[];
    final waitList = waits ?? <Duration>[];
    var now = baseTime;
    final client = EsploraClient(
      baseUrls: baseUrls,
      transport: (url) async {
        urlList.add(url);
        final outcome = await respond(url);
        if (outcome is Exception) throw outcome;
        return outcome as EsploraResponse;
      },
      now: () => now,
      delay: (duration) async {
        waitList.add(duration);
        now = now.add(duration);
      },
    );
    return (client, urlList, waitList);
  }

  EsploraResponse json(Map<String, Object?> body) => EsploraResponse(
    statusCode: 200,
    headers: const {'content-type': 'application/json'},
    body: jsonEncode(body),
  );

  EsploraResponse tooManyRequests({String? retryAfter}) => EsploraResponse(
    statusCode: 429,
    headers: {
      'retry-after': ?retryAfter,
    },
    body: 'rate limited',
  );

  EsploraResponse status(int statusCode) =>
      EsploraResponse(statusCode: statusCode, body: 'error');

  /// The mempool.space recording of the genesis block address, taken on
  /// 13 November 2026. The address is public and famously not ours.
  Future<String> fixture(String name) async =>
      File('test/fixtures/wallets/esplora/$name').readAsString();

  group('Given the default hosts', () {
    test('when built without arguments then mempool.space comes first and '
        'Blockstream second', () {
      final client = EsploraClient(transport: (_) async => status(200));
      expect(client.baseUrls, [
        Uri.parse('https://mempool.space/api'),
        Uri.parse('https://blockstream.info/api'),
      ]);
    });

    test('when built with an empty host list then that is an error', () {
      expect(
        () => EsploraClient(
          baseUrls: const [],
          transport: (_) => throw UnimplementedError(),
        ),
        throwsArgumentError,
      );
    });

    test(
      'when an address is fetched then it is one encoded path segment',
      () async {
        final urls = <Uri>[];
        final client = EsploraClient(
          transport: (url) async {
            urls.add(url);
            return json({
              'chain_stats': {'funded_txo_sum': 100, 'spent_txo_sum': 40},
              'mempool_stats': {'funded_txo_sum': 0, 'spent_txo_sum': 0},
            });
          },
        );
        await client.fetchAddress('1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa');

        expect(urls.single.host, 'mempool.space');
        expect(
          urls.single.path,
          '/api/address/1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa',
        );
      },
    );
  });

  group('Given the recorded genesis address fixture', () {
    test(
      'when parsed then funded minus spent holds in both stat groups',
      () async {
        final body = await fixture('mempool_space_address_genesis.json');
        final summary = EsploraClient.parseAddressBody(body);

        expect(summary.confirmedSats, BigInt.from(5771135349));
        expect(summary.mempoolSats, BigInt.from(546));
        expect(summary.totalSats, BigInt.from(5771135895));
        expect(
          summary.totalSats,
          summary.chainStats.fundedSats -
              summary.chainStats.spentSats +
              summary.mempoolStats.fundedSats -
              summary.mempoolStats.spentSats,
        );
      },
    );
  });

  group('Given the recorded BitPay donation address fixture', () {
    test('when parsed then spent outputs reduce the balance', () async {
      final body = await fixture('blockstream_address_bitpay.json');
      final summary = EsploraClient.parseAddressBody(body);

      expect(summary.confirmedSats, BigInt.from(58942));
      expect(summary.mempoolSats, BigInt.zero);
      expect(summary.totalSats, BigInt.from(58942));
    });
  });

  group('Given a malformed payload', () {
    for (final (name, body) in <(String, String)>[
      ('not JSON at all', 'zzz'),
      ('a JSON list', '[]'),
      ('missing stat groups', '{"address":"x"}'),
      (
        'a string sum',
        '{"chain_stats":{"funded_txo_sum":"many"},'
            '"mempool_stats":{"funded_txo_sum":0,"spent_txo_sum":0}}',
      ),
      (
        'a negative sum',
        '{"chain_stats":{"funded_txo_sum":-5,'
            '"spent_txo_sum":0},"mempool_stats":{"funded_txo_sum":0,'
            '"spent_txo_sum":0}}',
      ),
    ]) {
      test('when the body is $name then the failure is plain words', () async {
        final (client, _, _) = buildClient(
          respond: (_) async => EsploraResponse(statusCode: 200, body: body),
        );
        await expectLater(
          client.fetchAddress('1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa'),
          throwsA(
            isA<WalletProviderException>().having(
              (error) => error.message,
              'message',
              'The Bitcoin service sent data OpenBudget could not read. '
                  'Try again later.',
            ),
          ),
        );
      });
    }
  });

  group('Given a 429 from the first host', () {
    test('when it carries Retry-After then the same host is retried after '
        'that wait and no other host is called', () async {
      final urls = <Uri>[];
      final waits = <Duration>[];
      final (built, _, _) = buildClient(
        respond: (url) async => urls.length == 1
            ? tooManyRequests(retryAfter: '3')
            : json({
                'chain_stats': {'funded_txo_sum': 1, 'spent_txo_sum': 0},
                'mempool_stats': {'funded_txo_sum': 0, 'spent_txo_sum': 0},
              }),
        urls: urls,
        waits: waits,
      );

      final summary = await built.fetchAddress('bc1qtest0000');

      expect(summary.totalSats, BigInt.one);
      expect(urls, hasLength(2));
      expect(urls.every((url) => url.host == 'mempool.space'), isTrue);
      expect(waits, [const Duration(seconds: 3)]);
    });

    test(
      'when it carries no Retry-After then the second host answers',
      () async {
        final (built, urls, waits) = buildClient(
          respond: (url) async => url.host == 'mempool.space'
              ? tooManyRequests()
              : json({
                  'chain_stats': {'funded_txo_sum': 2, 'spent_txo_sum': 0},
                  'mempool_stats': {'funded_txo_sum': 0, 'spent_txo_sum': 0},
                }),
        );

        final summary = await built.fetchAddress('bc1qtest0000');

        expect(summary.totalSats, BigInt.two);
        expect(urls.map((url) => url.host).toList(), [
          'mempool.space',
          'blockstream.info',
        ]);
        expect(waits, isEmpty);
      },
    );

    test('when the same-host retry is refused again then the client fails '
        'over after honouring the header once', () async {
      final urls = <Uri>[];
      final waits = <Duration>[];
      final (built, _, _) = buildClient(
        respond: (url) async => urls.length <= 2
            ? tooManyRequests(retryAfter: '1')
            : json({
                'chain_stats': {'funded_txo_sum': 3, 'spent_txo_sum': 0},
                'mempool_stats': {'funded_txo_sum': 0, 'spent_txo_sum': 0},
              }),
        urls: urls,
        waits: waits,
      );

      final summary = await built.fetchAddress('bc1qtest0000');

      expect(summary.totalSats, BigInt.from(3));
      expect(urls.map((url) => url.host).toList(), [
        'mempool.space',
        'mempool.space',
        'blockstream.info',
      ]);
      expect(waits, [const Duration(seconds: 1)]);
    });

    test('when every host is rate limited then the failure says so in '
        'plain words', () async {
      final (built, _, _) = buildClient(
        respond: (_) async => tooManyRequests(),
      );

      await expectLater(
        built.fetchAddress('bc1qtest0000'),
        throwsA(
          isA<WalletProviderException>().having(
            (error) => error.message,
            'message',
            'The Bitcoin service is rate limiting requests right now. '
                'Try again in a minute.',
          ),
        ),
      );
    });

    test('when Retry-After is longer than the cap then the client does not '
        'wait and fails over instead', () async {
      final (built, urls, waits) = buildClient(
        respond: (url) async => url.host == 'mempool.space'
            ? tooManyRequests(retryAfter: '3600')
            : json({
                'chain_stats': {'funded_txo_sum': 4, 'spent_txo_sum': 0},
                'mempool_stats': {'funded_txo_sum': 0, 'spent_txo_sum': 0},
              }),
      );

      final summary = await built.fetchAddress('bc1qtest0000');

      expect(summary.totalSats, BigInt.from(4));
      expect(waits, isEmpty);
      expect(urls.map((url) => url.host).toList(), [
        'mempool.space',
        'blockstream.info',
      ]);
    });
  });

  group('Given an HTTP error on every host', () {
    test('when both hosts return 503 then the failure names the status and '
        'nothing else', () async {
      final (built, _, _) = buildClient(
        respond: (_) async => status(503),
      );

      await expectLater(
        built.fetchAddress('bc1qtest0000'),
        throwsA(
          isA<WalletProviderException>().having(
            (error) => error.message,
            'message',
            'The Bitcoin service could not be read (HTTP 503). '
                'Try again later.',
          ),
        ),
      );
    });
  });

  group('Given transport errors', () {
    test(
      'when the first host is unreachable then the second host answers',
      () async {
        final (built, urls, _) = buildClient(
          respond: (url) async => url.host == 'mempool.space'
              ? const SocketException('offline')
              : json({
                  'chain_stats': {'funded_txo_sum': 5, 'spent_txo_sum': 0},
                  'mempool_stats': {'funded_txo_sum': 0, 'spent_txo_sum': 0},
                }),
        );

        final summary = await built.fetchAddress('bc1qtest0000');

        expect(summary.totalSats, BigInt.from(5));
        expect(urls.map((url) => url.host).toList(), [
          'mempool.space',
          'blockstream.info',
        ]);
      },
    );

    test('when every host is unreachable then the failure is plain words '
        'and carries no URL and no address', () async {
      final (built, _, _) = buildClient(
        respond: (_) async => const SocketException('offline'),
      );

      final error = await catchOf(
        built.fetchAddress('bc1qsomelongaddress000000000000000'),
      );
      expect(
        error.message,
        'The Bitcoin service could not be reached. '
        'Try again later.',
      );
      expect(error.message.contains('http'), isFalse);
      expect(error.message.contains('bc1q'), isFalse);
      expect(error.message.contains('SocketException'), isFalse);
    });
  });

  group('Given the five-requests-a-second throttle', () {
    test('when one host receives a burst of 50 calls then the first is '
        'immediate and every later call waits 200 ms', () async {
      final (built, urls, waits) = buildClient(
        respond: (_) async => json({
          'chain_stats': {'funded_txo_sum': 1, 'spent_txo_sum': 0},
          'mempool_stats': {'funded_txo_sum': 0, 'spent_txo_sum': 0},
        }),
      );

      for (var i = 0; i < 50; i++) {
        await built.fetchAddress('bc1qtest0000');
      }

      expect(urls, hasLength(50));
      expect(waits, hasLength(49));
      for (final wait in waits) {
        expect(wait, const Duration(milliseconds: 200));
      }
    });

    test('when the burst elapses on the fake clock then the requests sit '
        'exactly one interval apart', () async {
      final requestTimes = <DateTime>[];
      var now = DateTime(2026, 11, 13, 12);
      final client = EsploraClient(
        baseUrls: [Uri.parse('https://mempool.space/api')],
        transport: (_) async => json({
          'chain_stats': {'funded_txo_sum': 1, 'spent_txo_sum': 0},
          'mempool_stats': {'funded_txo_sum': 0, 'spent_txo_sum': 0},
        }),
        now: () => now,
        delay: (duration) async {
          now = now.add(duration);
        },
      );

      for (var i = 0; i < 50; i++) {
        await client.fetchAddress('bc1qtest0000');
        requestTimes.add(now);
      }

      for (var i = 1; i < requestTimes.length; i++) {
        final spacing = requestTimes[i].difference(requestTimes[i - 1]);
        expect(
          spacing,
          const Duration(milliseconds: 200),
          reason: 'request $i came after ${spacing.inMilliseconds} ms',
        );
      }
    });
  });
}

Future<WalletProviderException> catchOf(Future<Object?> future) async {
  try {
    await future;
    fail('expected WalletProviderException');
  } on WalletProviderException catch (error) {
    return error;
  }
}
