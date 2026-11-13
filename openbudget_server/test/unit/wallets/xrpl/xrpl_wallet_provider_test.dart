import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/xrpl/xrpl_client.dart';
import 'package:openbudget_server/src/wallets/xrpl/xrpl_wallet_provider.dart';
import 'package:test/test.dart';

void main() {
  group('Given XrplWalletProvider', () {
    XrplClient clientFor(
      Map<String, dynamic> info, [
      Map<String, dynamic>? lines,
    ]) => XrplClient(
      endpoints: const ['https://xrpl.example'],
      transport: (Object url, [Object? body]) async {
        final decoded = jsonDecode(body! as String) as Map<String, dynamic>;
        final method = decoded['method'] as String;
        if (method == 'account_info') {
          return XrplResponse(
            statusCode: 200,
            body: jsonEncode({'result': info}),
          );
        }
        return XrplResponse(
          statusCode: 200,
          body: jsonEncode({
            'result': lines ?? {'lines': <Map<String, dynamic>>[]},
          }),
        );
      },
    );

    test('when account is unfunded then it reads as empty', () async {
      final provider = XrplWalletProvider(
        client: clientFor({'error': 'actNotFound'}),
      );
      final snapshot = await provider.fetchSnapshot(
        const WalletReadRequest(
          homeNetwork: WalletNetwork.xrplMainnet,
          networks: [WalletNetwork.xrplMainnet],
          address: 'rN7n7otQDd6FczFgLdSqtcsAUxDkw6fzRH',
        ),
      );
      expect(snapshot.readNetworks, [WalletNetwork.xrplMainnet]);
      expect(snapshot.holdings, isEmpty);
      expect(snapshot.failedNetworks, isEmpty);
    });

    test(
      'when account is funded then XRP holding carries reserve metadata',
      () async {
        final provider = XrplWalletProvider(
          client: clientFor({
            'account_data': {
              'Balance': '100000000',
              'OwnerCount': 2,
              'Flags': 0,
            },
          }),
        );
        final snapshot = await provider.fetchSnapshot(
          const WalletReadRequest(
            homeNetwork: WalletNetwork.xrplMainnet,
            networks: [WalletNetwork.xrplMainnet],
            address: 'rN7n7otQDd6FczFgLdSqtcsAUxDkw6fzRH',
          ),
        );
        expect(snapshot.holdings, hasLength(1));
        final holding = snapshot.holdings.first;
        expect(holding.assetId, 'native');
        expect(holding.decimals, 6);
        expect(holding.quantityRaw, BigInt.from(100000000));
        final metadata =
            jsonDecode(holding.metadataJson!) as Map<String, dynamic>;
        expect(metadata['reserveDrops'], (10000000 + 2 * 2000000).toString());
      },
    );

    test(
      'when a trust line has a negative balance it is skipped with warning',
      () async {
        final provider = XrplWalletProvider(
          client: clientFor(
            {
              'account_data': {
                'Balance': '10000000',
                'OwnerCount': 0,
                'Flags': 0,
              },
            },
            {
              'lines': [
                {
                  'currency': 'USD',
                  'balance': '-5',
                  'account': 'rIssuer123',
                },
                {
                  'currency': 'USD',
                  'balance': '10',
                  'account': 'rIssuer456',
                },
              ],
            },
          ),
        );
        final snapshot = await provider.fetchSnapshot(
          const WalletReadRequest(
            homeNetwork: WalletNetwork.xrplMainnet,
            networks: [WalletNetwork.xrplMainnet],
            address: 'rN7n7otQDd6FczFgLdSqtcsAUxDkw6fzRH',
          ),
        );
        expect(snapshot.holdings, hasLength(2)); // native + positive line
        expect(
          snapshot.warnings.any((w) => w.contains('negative')),
          isTrue,
        );
        expect(
          snapshot.holdings.any((h) => h.assetId == 'USD.rIssuer456'),
          isTrue,
        );
      },
    );

    test('when a 40-hex currency code is used it round-trips', () {
      const hex = '0000000000000000000000004D454D4500000000';
      final canonical = XrplCurrency.decode(hex);
      expect(XrplCurrency.encode(canonical), hex.toUpperCase());
    });

    test('when RequireDest is set then a warning is surfaced', () async {
      final provider = XrplWalletProvider(
        client: clientFor({
          'account_data': {
            'Balance': '10000000',
            'OwnerCount': 0,
            'Flags': 0x00020000,
          },
        }),
      );
      final snapshot = await provider.fetchSnapshot(
        const WalletReadRequest(
          homeNetwork: WalletNetwork.xrplMainnet,
          networks: [WalletNetwork.xrplMainnet],
          address: 'rN7n7otQDd6FczFgLdSqtcsAUxDkw6fzRH',
        ),
      );
      expect(
        snapshot.warnings.any((w) => w.contains('RequireDest')),
        isTrue,
      );
    });

    test('hasSecret is always true', () {
      expect(
        XrplWalletProvider.hasSecret(const {}, const {}),
        isTrue,
      );
    });
  });
}
