import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/wallets/bitcoin/bitcoin_wallet_provider.dart';
import 'package:openbudget_server/src/wallets/bitcoin/esplora_client.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/wallet_provider_registry.dart';
import 'package:test/test.dart';

void main() {
  const genesisAddress = '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa';

  // The harness closes over one scripted host whose body the test sets.
  // The interval is zero here: pacing itself is proven in the client's
  // own tests, and a shared client must not throttle across cases.
  String? body;
  final client = EsploraClient(
    baseUrls: [Uri.parse('https://mempool.space/api')],
    minRequestInterval: Duration.zero,
    transport: (_) async => EsploraResponse(statusCode: 200, body: body),
  );

  WalletReadRequest requestFor(String address) => WalletReadRequest(
    homeNetwork: WalletNetwork.bitcoinMainnet,
    networks: const [WalletNetwork.bitcoinMainnet],
    address: address,
  );

  Future<String> fixture(String name) async =>
      File('test/fixtures/wallets/esplora/$name').readAsString();

  group('Given the recorded genesis address fixture', () {
    test('when fetched then funded minus spent becomes quantityRaw', () async {
      body = await fixture('mempool_space_address_genesis.json');
      final snapshot = await BitcoinWalletProvider(client: client)
          .fetchSnapshot(requestFor(genesisAddress));

      expect(snapshot.readNetworks, [WalletNetwork.bitcoinMainnet]);
      expect(snapshot.failedNetworks, isEmpty);
      expect(snapshot.transactions, isEmpty);
      expect(snapshot.warnings, isEmpty);
      expect(snapshot.holdings, hasLength(1));

      final holding = snapshot.holdings.single;
      expect(holding.network, WalletNetwork.bitcoinMainnet);
      expect(holding.assetId, 'native');
      expect(holding.symbol, 'BTC');
      expect(holding.name, 'Bitcoin');
      expect(holding.decimals, 8);
      expect(holding.isNft, isFalse);
      expect(holding.prices, isEmpty);
      expect(holding.quantityRaw, BigInt.from(5771135895));
      expect(
        holding.quantityRaw,
        BigInt.from(
          5771135349 - 0 + 546 - 0,
        ),
        reason: 'confirmed funded − spent, plus mempool funded − spent',
      );
    });
  });

  group('Given the recorded BitPay donation address fixture', () {
    test('when fetched then spent outputs reduce quantityRaw', () async {
      body = await fixture('blockstream_address_bitpay.json');
      final snapshot = await BitcoinWalletProvider(client: client)
          .fetchSnapshot(requestFor('3E8ociqZa9mZUSwGdSmAEMAoAxBK3FNDcd'));

      expect(snapshot.holdings.single.quantityRaw, BigInt.from(58942));
    });
  });

  group('Given an address with nothing on it', () {
    test('when both stat groups are zero then the holding is zero', () async {
      body = jsonEncode({
        'address': genesisAddress,
        'chain_stats': {
          'funded_txo_count': 0,
          'funded_txo_sum': 0,
          'spent_txo_count': 0,
          'spent_txo_sum': 0,
        },
        'mempool_stats': {
          'funded_txo_count': 0,
          'funded_txo_sum': 0,
          'spent_txo_count': 0,
          'spent_txo_sum': 0,
        },
      });
      final snapshot = await BitcoinWalletProvider(client: client)
          .fetchSnapshot(requestFor(genesisAddress));

      expect(snapshot.holdings.single.quantityRaw, BigInt.zero);
    });
  });

  group('Given an extended key', () {
    // A bare mainnet xpub (the BIP 32 first vector); the parser accepts it
    // and the wallet row would carry its `hd:` identity instead.
    const xpub =
        'xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8';
    const hdIdentity = 'hd:0123456789abcdef0123456789abcdef01234567';

    for (final (name, address) in [
      ('an hd: identity', hdIdentity),
      (
        'a bare xpub',
        xpub,
      ),
    ]) {
      test('when the address is $name then the refusal is plain words and '
          'carries no key material', () async {
        final error = await catchOf(
          BitcoinWalletProvider(client: client).fetchSnapshot(
            requestFor(address),
          ),
        );

        expect(
          error.message,
          'Extended Bitcoin keys such as xpub or zpub are not supported '
          'yet. Add single addresses for now.',
        );
        expect(error.message.contains(address), isFalse);
        expect(error.message.contains('hd:'), isFalse);
      });
    }
  });

  group('Given a transport failure behind the provider', () {
    test('when every host fails then the plain-words error surfaces', () async {
      final unreachable = EsploraClient(
        baseUrls: [Uri.parse('https://mempool.space/api')],
        transport: (_) async => throw const SocketException('offline'),
      );

      final error = await catchOf(
        BitcoinWalletProvider(client: unreachable).fetchSnapshot(
          requestFor(genesisAddress),
        ),
      );

      expect(error.message, contains('could not be reached'));
      expect(error.message.contains(genesisAddress), isFalse);
    });
  });

  group('Given the registry', () {
    test('when Bitcoin is registered then it needs no secret', () {
      expect(
        WalletProviderRegistry.defaultRegistry.isSupported(
          passwords: const {},
          environment: const {},
          family: ChainFamily.bitcoin,
        ),
        isTrue,
      );
      expect(
        BitcoinWalletProvider.hasSecret(const {}, const {}),
        isTrue,
      );
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
