import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/xrpl/xrpl_client.dart';
import 'package:openbudget_server/src/wallets/xrpl/xrpl_currency.dart';
import 'package:openbudget_server/src/wallets/xrpl/xrpl_wallet_provider.dart';
import 'package:test/test.dart';

Future<String> fixture(String name) =>
    File('test/fixtures/wallets/xrpl/$name').readAsString();

void main() {
  group('Given XrplWalletProvider', () {
    test('when account is unfunded then it reads as empty', () async {
      final client = XrplClient(
        endpoints: const ['https://xrpl.example'],
        transport: (Object url, [Object? body]) async => XrplResponse(
          statusCode: 200,
          body: await fixture('actNotFound.json'),
        ),
      );
      // Transport returns actNotFound for any method; account_info path.
      final provider = XrplWalletProvider(client: client);
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
        final client = XrplClient(
          endpoints: const ['https://xrpl.example'],
          transport: (Object url, [Object? body]) async {
            final decoded = jsonDecode(body! as String) as Map<String, dynamic>;
            final method = decoded['method'] as String;
            if (method == 'account_info') {
              return XrplResponse(
                statusCode: 200,
                body: await fixture('account_info.json'),
              );
            }
            if (method == 'server_state') {
              return XrplResponse(
                statusCode: 200,
                body: await fixture('server_state.json'),
              );
            }
            return XrplResponse(
              statusCode: 200,
              body: jsonEncode({
                'result': {'lines': <Map<String, dynamic>>[]},
              }),
            );
          },
        );
        final provider = XrplWalletProvider(client: client);
        final snapshot = await provider.fetchSnapshot(
          const WalletReadRequest(
            homeNetwork: WalletNetwork.xrplMainnet,
            networks: [WalletNetwork.xrplMainnet],
            address: 'rN7n7otQDd6FczFgLdSqtcsAUxDkw6fzRH',
          ),
        );
        expect(snapshot.holdings, isNotEmpty);
        final holding = snapshot.holdings.first;
        expect(holding.assetId, 'native');
        expect(holding.decimals, 6);
        final info = jsonDecode(
          await fixture('account_info.json'),
        ) as Map<String, dynamic>;
        final infoResult = info['result'] as Map<String, dynamic>;
        final accountData = infoResult['account_data'] as Map<String, dynamic>;
        expect(
          holding.quantityRaw,
          BigInt.parse(accountData['Balance'] as String),
        );
        final serverState = jsonDecode(
          await fixture('server_state.json'),
        ) as Map<String, dynamic>;
        final ssResult = serverState['result'] as Map<String, dynamic>;
        final ssState = ssResult['state'] as Map<String, dynamic>;
        final validated = ssState['validated_ledger'] as Map<String, dynamic>;
        final base = validated['reserve_base'] as int;
        final inc = validated['reserve_inc'] as int;
        final ownerCount = accountData['OwnerCount'] as int;
        final metadata =
            jsonDecode(holding.metadataJson!) as Map<String, dynamic>;
        expect(
          metadata['reserveDrops'],
          (base + inc * ownerCount).toString(),
        );
      },
    );

    test(
      'when a trust line has a negative balance it is skipped with warning',
      () async {
        final client = XrplClient(
          endpoints: const ['https://xrpl.example'],
          transport: (Object url, [Object? body]) async {
            final decoded = jsonDecode(body! as String) as Map<String, dynamic>;
            final method = decoded['method'] as String;
            if (method == 'account_info') {
              return XrplResponse(
                statusCode: 200,
                body: jsonEncode({
                  'result': {
                    'account_data': {
                      'Balance': '10000000',
                      'OwnerCount': 0,
                      'Flags': 0,
                    },
                  },
                }),
              );
            }
            if (method == 'server_state') {
              return XrplResponse(
                statusCode: 200,
                body: jsonEncode({
                  'result': {
                    'state': {
                      'validated_ledger': {
                        'reserve_base': 1000000,
                        'reserve_inc': 200000,
                      },
                    },
                  },
                }),
              );
            }
            return XrplResponse(
              statusCode: 200,
              body: jsonEncode({
                'result': {
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
              }),
            );
          },
        );
        final provider = XrplWalletProvider(client: client);
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

    test(
      'when a trust line uses exponent notation it is parsed exactly',
      () async {
        final client = XrplClient(
          endpoints: const ['https://xrpl.example'],
          transport: (Object url, [Object? body]) async {
            final decoded = jsonDecode(body! as String) as Map<String, dynamic>;
            final method = decoded['method'] as String;
            if (method == 'account_info') {
              return XrplResponse(
                statusCode: 200,
                body: jsonEncode({
                  'result': {
                    'account_data': {
                      'Balance': '10000000',
                      'OwnerCount': 0,
                      'Flags': 0,
                    },
                  },
                }),
              );
            }
            if (method == 'server_state') {
              return XrplResponse(
                statusCode: 200,
                body: jsonEncode({
                  'result': {
                    'state': {
                      'validated_ledger': {
                        'reserve_base': 1000000,
                        'reserve_inc': 200000,
                      },
                    },
                  },
                }),
              );
            }
            return XrplResponse(
              statusCode: 200,
              body: jsonEncode({
                'result': {
                  'lines': [
                    {
                      'currency': 'USD',
                      'balance': '1.5e-7',
                      'account': 'rIssuer1',
                    },
                    {
                      'currency': 'EUR',
                      'balance': '9999999999999999e80',
                      'account': 'rIssuer2',
                    },
                  ],
                },
              }),
            );
          },
        );
        final provider = XrplWalletProvider(client: client);
        final snapshot = await provider.fetchSnapshot(
          const WalletReadRequest(
            homeNetwork: WalletNetwork.xrplMainnet,
            networks: [WalletNetwork.xrplMainnet],
            address: 'rN7n7otQDd6FczFgLdSqtcsAUxDkw6fzRH',
          ),
        );
        final usd = snapshot.holdings.firstWhere((h) => h.symbol == 'USD');
        expect(usd.quantityRaw, BigInt.from(150000000));
        final eur = snapshot.holdings.firstWhere((h) => h.symbol == 'EUR');
        expect(
          eur.quantityRaw,
          BigInt.parse('9999999999999999') * BigInt.from(10).pow(95),
        );
      },
    );

    test('when account_lines is paged then all pages are read', () async {
      var accountLinesCalls = 0;
      final client = XrplClient(
        endpoints: const ['https://xrpl.example'],
        transport: (Object url, [Object? body]) async {
          final decoded = jsonDecode(body! as String) as Map<String, dynamic>;
          final method = decoded['method'] as String;
          if (method == 'account_info') {
            return XrplResponse(
              statusCode: 200,
              body: await fixture('account_info.json'),
            );
          }
          if (method == 'server_state') {
            return XrplResponse(
              statusCode: 200,
              body: await fixture('server_state.json'),
            );
          }
          accountLinesCalls++;
          final params =
              (decoded['params'] as List).first as Map<String, dynamic>;
          if (!params.containsKey('marker')) {
            return XrplResponse(
              statusCode: 200,
              body: await fixture('account_lines_page1.json'),
            );
          }
          final marker = params['marker']?.toString() ?? '';
          if (marker.startsWith('0E08')) {
            return XrplResponse(
              statusCode: 200,
              body: await fixture('account_lines_page2.json'),
            );
          }
          return XrplResponse(
            statusCode: 200,
            body: jsonEncode({
              'result': {'lines': <Map<String, dynamic>>[]},
            }),
          );
        },
      );
      final provider = XrplWalletProvider(client: client);
      await provider.fetchSnapshot(
        const WalletReadRequest(
          homeNetwork: WalletNetwork.xrplMainnet,
          networks: [WalletNetwork.xrplMainnet],
          address: 'rN7n7otQDd6FczFgLdSqtcsAUxDkw6fzRH',
        ),
      );
      expect(accountLinesCalls, greaterThanOrEqualTo(2));
    });

    test('when a 40-hex currency code is used it round-trips', () {
      const hex = '0000000000000000000000004D454D4500000000';
      final canonical = XrplCurrency.decode(hex);
      expect(XrplCurrency.encode(canonical), hex.toUpperCase());
    });

    test('when RequireDest is set then a warning is surfaced', () async {
      final smartClient = XrplClient(
        endpoints: const ['https://xrpl.example'],
        transport: (Object url, [Object? body]) async {
          final decoded = jsonDecode(body! as String) as Map<String, dynamic>;
          final method = decoded['method'] as String;
          if (method == 'server_state') {
            return XrplResponse(
              statusCode: 200,
              body: jsonEncode({
                'result': {
                  'state': {
                    'validated_ledger': {
                      'reserve_base': 1000000,
                      'reserve_inc': 200000,
                    },
                  },
                },
              }),
            );
          }
          return XrplResponse(
            statusCode: 200,
            body: jsonEncode({
              'result': {
                'account_data': {
                  'Balance': '10000000',
                  'OwnerCount': 0,
                  'Flags': 0x00020000,
                },
              },
            }),
          );
        },
      );
      final provider = XrplWalletProvider(client: smartClient);
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
