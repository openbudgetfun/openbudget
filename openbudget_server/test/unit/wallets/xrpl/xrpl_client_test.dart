import 'dart:convert';

import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/xrpl/xrpl_client.dart';
import 'package:test/test.dart';

void main() {
  group('Given XrplClient', () {
    test('when the first server errors then it fails over', () async {
      final client = XrplClient(
        endpoints: const [
          'https://first.example',
          'https://second.example',
        ],
        transport: (Object url, [Object? body]) async {
          final uri = url as Uri;
          if (uri.host == 'first.example') {
            throw Exception('boom');
          }
          return XrplResponse(
            statusCode: 200,
            body: jsonEncode({
              'result': {'status': 'success'},
            }),
          );
        },
      );

      final result = await client.call('account_info', {'account': 'rX'});
      expect(result['status'], 'success');
    });

    test(
      'when all servers fail then it throws WalletProviderException',
      () async {
        final client = XrplClient(
          endpoints: const ['https://only.example'],
          transport: (Object url, [Object? body]) async {
            throw Exception('boom');
          },
        );

        await expectLater(
          client.call('account_info', {'account': 'rX'}),
          throwsA(isA<WalletProviderException>()),
        );
      },
    );
  });
}
