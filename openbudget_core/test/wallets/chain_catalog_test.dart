import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

/// The value list of multichain-wallets.md 7.1, verbatim. Existing names
/// never change, new values only ever append.
const _section71Values = [
  'solanaMainnet',
  'solanaDevnet',
  'bitcoinMainnet',
  'ethereumMainnet',
  'baseMainnet',
  'arbitrumOne',
  'opMainnet',
  'polygonPos',
  'bnbSmartChain',
  'avalancheCChain',
  'tronMainnet',
  'xrplMainnet',
  'hyperliquid',
  'dogecoinMainnet',
  'litecoinMainnet',
  'cardanoMainnet',
  'tonMainnet',
  'suiMainnet',
  'aptosMainnet',
];

const Map<WalletNetwork, ChainFamily> _expectedFamilies = {
  WalletNetwork.solanaMainnet: ChainFamily.solana,
  WalletNetwork.solanaDevnet: ChainFamily.solana,
  WalletNetwork.bitcoinMainnet: ChainFamily.bitcoin,
  WalletNetwork.ethereumMainnet: ChainFamily.evm,
  WalletNetwork.baseMainnet: ChainFamily.evm,
  WalletNetwork.arbitrumOne: ChainFamily.evm,
  WalletNetwork.opMainnet: ChainFamily.evm,
  WalletNetwork.polygonPos: ChainFamily.evm,
  WalletNetwork.bnbSmartChain: ChainFamily.evm,
  WalletNetwork.avalancheCChain: ChainFamily.evm,
  WalletNetwork.tronMainnet: ChainFamily.tron,
  WalletNetwork.xrplMainnet: ChainFamily.xrpl,
  WalletNetwork.hyperliquid: ChainFamily.hyperliquid,
  WalletNetwork.dogecoinMainnet: ChainFamily.dogecoin,
  WalletNetwork.litecoinMainnet: ChainFamily.litecoin,
  WalletNetwork.cardanoMainnet: ChainFamily.cardano,
  WalletNetwork.tonMainnet: ChainFamily.ton,
  WalletNetwork.suiMainnet: ChainFamily.sui,
  WalletNetwork.aptosMainnet: ChainFamily.aptos,
};

const Map<WalletNetwork, (String, int)> _expectedNatives = {
  WalletNetwork.solanaMainnet: ('SOL', 9),
  WalletNetwork.solanaDevnet: ('SOL', 9),
  WalletNetwork.bitcoinMainnet: ('BTC', 8),
  WalletNetwork.ethereumMainnet: ('ETH', 18),
  WalletNetwork.baseMainnet: ('ETH', 18),
  WalletNetwork.arbitrumOne: ('ETH', 18),
  WalletNetwork.opMainnet: ('ETH', 18),
  WalletNetwork.polygonPos: ('POL', 18),
  WalletNetwork.bnbSmartChain: ('BNB', 18),
  WalletNetwork.avalancheCChain: ('AVAX', 18),
  WalletNetwork.tronMainnet: ('TRX', 6),
  WalletNetwork.xrplMainnet: ('XRP', 6),
  WalletNetwork.hyperliquid: ('HYPE', 8),
  WalletNetwork.dogecoinMainnet: ('DOGE', 8),
  WalletNetwork.litecoinMainnet: ('LTC', 8),
  WalletNetwork.cardanoMainnet: ('ADA', 6),
  WalletNetwork.tonMainnet: ('TON', 9),
  WalletNetwork.suiMainnet: ('SUI', 9),
  WalletNetwork.aptosMainnet: ('APT', 8),
};

const Map<WalletNetwork, int> _expectedEvmChainIds = {
  WalletNetwork.ethereumMainnet: 1,
  WalletNetwork.opMainnet: 10,
  WalletNetwork.polygonPos: 137,
  WalletNetwork.bnbSmartChain: 56,
  WalletNetwork.arbitrumOne: 42161,
  WalletNetwork.avalancheCChain: 43114,
  WalletNetwork.baseMainnet: 8453,
};

/// EVM contracts are stored lowercase with a 0x prefix.
final _evmContract = RegExp(r'^0x[0-9a-f]{40}$');

/// Solana mints are Base58, 32 to 44 characters.
final _solanaMint = RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$');

/// Tron TRC-20 contracts are T followed by 33 Base58 characters.
final _tronContract = RegExp(r'^T[1-9A-HJ-NP-Za-km-z]{33}$');

/// XRP Ledger tokens are a 40-hex currency code and an issuer r-address.
final _xrplToken = RegExp(r'^[0-9A-Fa-f]{40}\.r[1-9A-HJ-NP-Za-km-z]{32,34}$');

/// TON jetton masters are raw 0: and 64 hex digits.
final _tonJetton = RegExp(r'^0:[0-9a-f]{64}$');

/// Sui coin types are an address, module and name.
final _suiCoinType = RegExp(
  r'^0x[0-9a-f]{64}::[a-z][a-z0-9_]*::[A-Z][A-Za-z0-9]*$',
);

/// Aptos fungible assets are a 0x and 64 hex digits.
final _aptosAsset = RegExp(r'^0x[0-9a-f]{64}$');

void main() {
  group('WalletNetwork serialization', () {
    test('holds exactly the values of multichain-wallets.md 7.1', () {
      expect(
        WalletNetwork.values.map((value) => value.name),
        _section71Values,
      );
    });

    test('serializes every value by its name, both ways', () {
      for (final value in WalletNetwork.values) {
        expect(WalletNetwork.fromJson(value.name), value, reason: value.name);
      }
    });

    test(
      'keeps the pre-existing Solana names serialising exactly as before',
      () {
        expect(
          WalletNetwork.fromJson('solanaMainnet'),
          WalletNetwork.solanaMainnet,
        );
        expect(
          WalletNetwork.fromJson('solanaDevnet'),
          WalletNetwork.solanaDevnet,
        );
        expect(WalletNetwork.solanaMainnet.name, 'solanaMainnet');
        expect(WalletNetwork.solanaDevnet.name, 'solanaDevnet');
      },
    );

    test('rejects names that were never values', () {
      expect(
        () => WalletNetwork.fromJson('ethereumSepolia'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => WalletNetwork.fromJson('SOL'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('WalletNetworkRules', () {
    test('derives the expected family for every network', () {
      for (final network in WalletNetwork.values) {
        expect(
          network.family,
          _expectedFamilies[network],
          reason: '${network.name} maps to the wrong family',
        );
      }
    });

    test('marks only solanaDevnet as a testnet', () {
      for (final network in WalletNetwork.values) {
        expect(network.isTestnet, network == WalletNetwork.solanaDevnet);
      }
    });

    test('gives every network its native symbol and decimals', () {
      for (final network in WalletNetwork.values) {
        final expected = _expectedNatives[network]!;
        expect(network.nativeSymbol, expected.$1, reason: network.name);
        expect(network.nativeDecimals, expected.$2, reason: network.name);
      }
    });

    test('sets an EVM chain id on exactly the seven EVM networks', () {
      for (final entry in _expectedEvmChainIds.entries) {
        expect(entry.key.evmChainId, entry.value, reason: entry.key.name);
      }
      for (final network in WalletNetwork.values) {
        if (!_expectedEvmChainIds.containsKey(network)) {
          expect(network.evmChainId, isNull, reason: network.name);
        }
      }
    });

    test("shows every network under the plan's name", () {
      final names = {
        for (final network in WalletNetwork.values)
          network: network.displayName,
      };
      expect(names[WalletNetwork.solanaMainnet], 'Solana');
      expect(names[WalletNetwork.solanaDevnet], 'Solana Devnet');
      expect(names[WalletNetwork.ethereumMainnet], 'Ethereum');
      expect(names[WalletNetwork.arbitrumOne], 'Arbitrum One');
      expect(names[WalletNetwork.opMainnet], 'OP Mainnet');
      expect(names[WalletNetwork.polygonPos], 'Polygon PoS');
      expect(names[WalletNetwork.bnbSmartChain], 'BNB Smart Chain');
      expect(names[WalletNetwork.avalancheCChain], 'Avalanche C-Chain');
      expect(names[WalletNetwork.tronMainnet], 'Tron');
      expect(names[WalletNetwork.xrplMainnet], 'XRP Ledger');
      expect(names[WalletNetwork.hyperliquid], 'Hyperliquid');
      expect(names[WalletNetwork.tonMainnet], 'TON');
      expect(names[WalletNetwork.suiMainnet], 'Sui');
      expect(names[WalletNetwork.aptosMainnet], 'Aptos');
    });
  });

  group('ChainCatalog', () {
    test('has exactly one entry for every WalletNetwork value', () {
      expect(
        ChainCatalog.entries.map((entry) => entry.network),
        WalletNetwork.values,
      );
    });

    test("derives each entry's family through the network rules", () {
      for (final entry in ChainCatalog.entries) {
        expect(entry.network.family, _expectedFamilies[entry.network]);
      }
    });

    test('every entry starts with its native coin', () {
      for (final entry in ChainCatalog.entries) {
        final native = entry.nativeAsset;
        expect(native.assetId, 'native');
        expect(native.isNative, isTrue);
        expect(native.network, entry.network);
        expect(
          entry.canonicalTokens.map((asset) => asset.isNative),
          everyElement(isFalse),
        );
      }
    });

    test('resolves assets by id and misses unknown ones quietly', () {
      expect(
        ChainCatalog.tryAsset(
          WalletNetwork.ethereumMainnet,
          '0xdac17f958d2ee523a2206206994597c13d831ec7',
        )?.symbol,
        'USDT',
      );
      expect(
        ChainCatalog.tryAsset(WalletNetwork.ethereumMainnet, 'native')?.symbol,
        'ETH',
      );
      expect(
        ChainCatalog.tryAsset(
          WalletNetwork.solanaDevnet,
          'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',
        ),
        isNull,
        reason: 'a mainnet asset must not resolve on another network',
      );
    });

    test("stores every token id in its family's canonical form", () {
      final shapes = {
        ChainFamily.evm: _evmContract,
        ChainFamily.solana: _solanaMint,
        ChainFamily.tron: _tronContract,
        ChainFamily.xrpl: _xrplToken,
        ChainFamily.ton: _tonJetton,
        ChainFamily.sui: _suiCoinType,
        ChainFamily.aptos: _aptosAsset,
      };

      for (final entry in ChainCatalog.entries) {
        for (final asset in entry.canonicalTokens) {
          final shape = shapes[asset.network.family];
          if (shape == null) {
            fail(
              '${asset.network.name} holds no canonical tokens, so ${asset.symbol} '
              'should not be listed',
            );
          }
          expect(
            asset.assetId,
            matches(shape),
            reason:
                '${asset.symbol} on ${asset.network.name} is not in the '
                "family's canonical form: ${asset.assetId}",
          );
          expect(asset.decimals, inInclusiveRange(0, 36));
        }
      }
    });

    test('lists no tokens on chains that carry only their own coin', () {
      final tokenless = [
        WalletNetwork.bitcoinMainnet,
        WalletNetwork.dogecoinMainnet,
        WalletNetwork.litecoinMainnet,
        WalletNetwork.cardanoMainnet,
        WalletNetwork.hyperliquid,
        WalletNetwork.solanaDevnet,
      ];
      for (final network in tokenless) {
        expect(
          ChainCatalog.entryFor(network).canonicalTokens,
          isEmpty,
          reason: '${network.name} has no citable canonical tokens yet',
        );
      }
    });

    test("carries the catalogue's stablecoins on every launch value chain", () {
      final usdtNetworks = [
        for (final entry in ChainCatalog.entries)
          if (entry.canonicalTokens.any((asset) => asset.symbol == 'USDT'))
            entry.network,
      ];
      expect(
        usdtNetworks,
        containsAll([
          WalletNetwork.ethereumMainnet,
          WalletNetwork.tronMainnet,
          WalletNetwork.solanaMainnet,
          WalletNetwork.tonMainnet,
          WalletNetwork.avalancheCChain,
          WalletNetwork.aptosMainnet,
        ]),
      );

      final usdcNetworks = [
        for (final entry in ChainCatalog.entries)
          if (entry.canonicalTokens.any((asset) => asset.symbol == 'USDC'))
            entry.network,
      ];
      expect(
        usdcNetworks,
        containsAll([
          WalletNetwork.ethereumMainnet,
          WalletNetwork.baseMainnet,
          WalletNetwork.arbitrumOne,
          WalletNetwork.opMainnet,
          WalletNetwork.polygonPos,
          WalletNetwork.solanaMainnet,
          WalletNetwork.xrplMainnet,
          WalletNetwork.suiMainnet,
          WalletNetwork.aptosMainnet,
        ]),
      );
    });
  });
}
