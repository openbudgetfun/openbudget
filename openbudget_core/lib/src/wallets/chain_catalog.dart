import 'package:openbudget_core/src/generated/wallet_network.dart';

/// One canonical asset of one network: its on-chain id in the exact form
/// holdings store it (multichain-wallets.md 7.2), plus its fixed metadata.
///
/// The native coin of every network uses the asset id `native`. Token ids
/// are canonical contract addresses or their family's equivalent, and every
/// one carries a citation in its doc comment to the issuer's or chain's own
/// documentation.
final class CanonicalAsset {
  const CanonicalAsset({
    required this.network,
    required this.assetId,
    required this.symbol,
    required this.name,
    required this.decimals,
    this.coingeckoId,
    this.coingeckoVerified = false,
  }) : isNative = assetId == 'native';

  /// The network the asset lives on.
  final WalletNetwork network;

  /// `native`, or the asset's own id on its network: an EVM contract in
  /// lowercase `0x…`, a Solana mint in Base58, a Tron TRC-20 contract,
  /// an XRP Ledger `<40 hex currency code>.<issuer>`, a TON jetton master
  /// `0:<hex>`, a Sui coin type, or an Aptos fungible-asset address.
  final String assetId;

  /// The asset's ticker as the catalogue displays it.
  final String symbol;

  /// The asset's full name as the issuer or chain names it.
  final String name;

  /// Base units per whole token: 0 to 36.
  final int decimals;

  /// CoinGecko coin id for this asset when it is a native coin with its own
  /// id (tokens are priced by platform plus contract instead).
  final String? coingeckoId;

  /// Whether [coingeckoId] was verified against /coins/list.
  final bool coingeckoVerified;

  /// Whether this is the network's own coin, not a token.
  final bool isNative;
}

/// The canonical assets of one network: its native coin and the tokens
/// worth recognizing everywhere (USDT, USDC, DAI, WETH, WBTC where they
/// exist under a citable deployment).
final class ChainCatalogEntry {
  const ChainCatalogEntry({
    required this.network,
    required this.nativeAsset,
    required this.canonicalTokens,
    this.coingeckoId,
    this.coingeckoPlatform,
    this.defillamaChain,
    this.coingeckoVerified = false,
  });

  /// The network the entry belongs to. Every [WalletNetwork] value has one.
  final WalletNetwork network;

  /// The network's own coin, always asset id `native`.
  final CanonicalAsset nativeAsset;

  /// Canonical tokens besides the native coin, in display order.
  final List<CanonicalAsset> canonicalTokens;

  /// CoinGecko coin id for the network's native coin (used by /simple/price),
  /// or null when the network has no priced native coin on CoinGecko.
  final String? coingeckoId;

  /// CoinGecko platform id for token pricing via /simple/token_price/{platform},
  /// or null when the network's tokens are not priced on CoinGecko.
  final String? coingeckoPlatform;

  /// DefiLlama chain key for this network's `chain:address` keys, or null.
  final String? defillamaChain;

  /// Whether [coingeckoId] and [coingeckoPlatform] were verified against the
  /// live /coins/list and /asset_platforms endpoints. Unverified until the
  /// manual --check tool confirms them.
  final bool coingeckoVerified;

  // Aliases for naming flexibility.
  String? get coingeckoCoinId => coingeckoId;
  String? get coinGeckoId => coingeckoId;
  String? get nativeCoingeckoId => coingeckoId;
  String? get coingeckoNativeId => coingeckoId;
  String? get coingeckoPlatformId => coingeckoPlatform;
  String? get platform => coingeckoPlatform;
  String? get coingeckoPlatformName => coingeckoPlatform;
}

/// The chain catalogue: canonical assets per network, the address-level
/// source of truth behind wallet holdings and, later, price pinning (W2.1).
///
/// Token prices are not pinned here yet; CoinGecko and DefiLlama ids are
/// W2.1. An asset joins this catalogue only with a contract address cited
/// from its issuer's or chain's own documentation.
final class ChainCatalog {
  /// One entry per network, in enum order.
  static const List<ChainCatalogEntry> entries = [
    ChainCatalogEntry(
      network: WalletNetwork.solanaMainnet,
      coingeckoId: 'solana',
      coingeckoPlatform: 'solana',
      defillamaChain: 'solana',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.solanaMainnet,
        assetId: 'native',
        symbol: 'SOL',
        name: 'Solana',
        decimals: 9,
      ),
      canonicalTokens: [
        // Issuer integration guide, https://tether.to/en/supported-protocols
        CanonicalAsset(
          network: WalletNetwork.solanaMainnet,
          assetId: 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',
          symbol: 'USDT',
          name: 'Tether USD',
          decimals: 6,
        ),
        // Circle USDC contract addresses,
        // https://developers.circle.com/stablecoins/usdc-contract-addresses
        CanonicalAsset(
          network: WalletNetwork.solanaMainnet,
          assetId: 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
          symbol: 'USDC',
          name: 'USD Coin',
          decimals: 6,
        ),
        // BitGo custodian contract addresses,
        // https://docs.wbtc.network/resources/contract-addresses
        CanonicalAsset(
          network: WalletNetwork.solanaMainnet,
          assetId: '5XZw2LKTyrfvfiskJ78AMpackRjPcyCif1WhUsPDuVqQ',
          symbol: 'WBTC',
          name: 'Wrapped Bitcoin',
          decimals: 8,
        ),
      ],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.solanaDevnet,
      coingeckoId: 'solana',
      coingeckoPlatform: 'solana',
      defillamaChain: 'solana',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.solanaDevnet,
        assetId: 'native',
        symbol: 'SOL',
        name: 'Solana Devnet',
        decimals: 9,
      ),
      canonicalTokens: [],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.bitcoinMainnet,
      coingeckoId: 'bitcoin',
      defillamaChain: 'bitcoin',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.bitcoinMainnet,
        assetId: 'native',
        symbol: 'BTC',
        name: 'Bitcoin',
        decimals: 8,
      ),
      canonicalTokens: [],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.ethereumMainnet,
      coingeckoId: 'ethereum',
      coingeckoPlatform: 'ethereum',
      defillamaChain: 'ethereum',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.ethereumMainnet,
        assetId: 'native',
        symbol: 'ETH',
        name: 'Ethereum',
        decimals: 18,
      ),
      canonicalTokens: [
        // Issuer integration guide, https://tether.to/en/supported-protocols
        CanonicalAsset(
          network: WalletNetwork.ethereumMainnet,
          assetId: '0xdac17f958d2ee523a2206206994597c13d831ec7',
          symbol: 'USDT',
          name: 'Tether USD',
          decimals: 6,
        ),
        // Circle USDC contract addresses,
        // https://developers.circle.com/stablecoins/usdc-contract-addresses
        CanonicalAsset(
          network: WalletNetwork.ethereumMainnet,
          assetId: '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',
          symbol: 'USDC',
          name: 'USD Coin',
          decimals: 6,
        ),
        // Maker developer guide, Dai is available on the Ethereum mainnet at
        // 0x6B175474E89094C44Da98b954EedeAC495271d0F,
        // https://github.com/sky-ecosystem/developerguides/blob/master/dai/dai-token/dai-token.md
        CanonicalAsset(
          network: WalletNetwork.ethereumMainnet,
          assetId: '0x6b175474e89094c44da98b954eedeac495271d0f',
          symbol: 'DAI',
          name: 'Dai Stablecoin',
          decimals: 18,
        ),
        // ethereum.org names this the canonical implementation of WETH,
        // https://ethereum.org/en/wrapped-eth/
        CanonicalAsset(
          network: WalletNetwork.ethereumMainnet,
          assetId: '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2',
          symbol: 'WETH',
          name: 'Wrapped Ether',
          decimals: 18,
        ),
        // BitGo custodian contract addresses,
        // https://docs.wbtc.network/resources/contract-addresses
        CanonicalAsset(
          network: WalletNetwork.ethereumMainnet,
          assetId: '0x2260fac5e5542a773aa44fbcfedf7c193bc2c599',
          symbol: 'WBTC',
          name: 'Wrapped Bitcoin',
          decimals: 8,
        ),
      ],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.baseMainnet,
      coingeckoId: 'ethereum',
      coingeckoPlatform: 'base',
      defillamaChain: 'base',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.baseMainnet,
        assetId: 'native',
        symbol: 'ETH',
        name: 'Base',
        decimals: 18,
      ),
      canonicalTokens: [
        // Circle USDC contract addresses,
        // https://developers.circle.com/stablecoins/usdc-contract-addresses
        CanonicalAsset(
          network: WalletNetwork.baseMainnet,
          assetId: '0x833589fcd6edb6e08f4c7c32d4f71b54bda02913',
          symbol: 'USDC',
          name: 'USD Coin',
          decimals: 6,
        ),
        // WETH9 predeploy, Base contract addresses,
        // https://docs.base.org/specifications/reference/base-contracts
        CanonicalAsset(
          network: WalletNetwork.baseMainnet,
          assetId: '0x4200000000000000000000000000000000000006',
          symbol: 'WETH',
          name: 'Wrapped Ether',
          decimals: 18,
        ),
        // BitGo custodian contract addresses,
        // https://docs.wbtc.network/resources/contract-addresses
        CanonicalAsset(
          network: WalletNetwork.baseMainnet,
          assetId: '0x1cea84203673764244e05693e42e6ace62be9ba5',
          symbol: 'WBTC',
          name: 'Wrapped Bitcoin',
          decimals: 8,
        ),
      ],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.arbitrumOne,
      coingeckoId: 'ethereum',
      coingeckoPlatform: 'arbitrum-one',
      defillamaChain: 'arbitrum',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.arbitrumOne,
        assetId: 'native',
        symbol: 'ETH',
        name: 'Arbitrum One',
        decimals: 18,
      ),
      canonicalTokens: [
        // Circle USDC contract addresses,
        // https://developers.circle.com/stablecoins/usdc-contract-addresses
        CanonicalAsset(
          network: WalletNetwork.arbitrumOne,
          assetId: '0xaf88d065e77c8cc2239327c5edb3a432268e5831',
          symbol: 'USDC',
          name: 'USD Coin',
          decimals: 6,
        ),
        // Arbitrum contract addresses, L2 Weth on Arbitrum One,
        // https://docs.arbitrum.io/arbitrum-essentials/reference/contract-addresses
        CanonicalAsset(
          network: WalletNetwork.arbitrumOne,
          assetId: '0x82af49447d8a07e3bd95bd0d56f35241523fbab1',
          symbol: 'WETH',
          name: 'Wrapped Ether',
          decimals: 18,
        ),
      ],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.opMainnet,
      coingeckoId: 'ethereum',
      coingeckoPlatform: 'optimistic-ethereum',
      defillamaChain: 'optimism',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.opMainnet,
        assetId: 'native',
        symbol: 'ETH',
        name: 'OP Mainnet',
        decimals: 18,
      ),
      canonicalTokens: [
        // Circle USDC contract addresses,
        // https://developers.circle.com/stablecoins/usdc-contract-addresses
        CanonicalAsset(
          network: WalletNetwork.opMainnet,
          assetId: '0x0b2c639c533813f4aa9d7837caf62653d097ff85',
          symbol: 'USDC',
          name: 'USD Coin',
          decimals: 6,
        ),
        // WETH9 predeploy, OP Stack predeploys,
        // https://specs.optimism.io/protocol/predeploys.html
        CanonicalAsset(
          network: WalletNetwork.opMainnet,
          assetId: '0x4200000000000000000000000000000000000006',
          symbol: 'WETH',
          name: 'Wrapped Ether',
          decimals: 18,
        ),
      ],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.polygonPos,
      coingeckoId: 'polygon-ecosystem-token',
      coingeckoPlatform: 'polygon-pos',
      defillamaChain: 'polygon',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.polygonPos,
        assetId: 'native',
        symbol: 'POL',
        name: 'Polygon PoS',
        decimals: 18,
      ),
      canonicalTokens: [
        // Circle USDC contract addresses,
        // https://developers.circle.com/stablecoins/usdc-contract-addresses
        CanonicalAsset(
          network: WalletNetwork.polygonPos,
          assetId: '0x3c499c542cef5e3811e1192ce70d8cc03d5c3359',
          symbol: 'USDC',
          name: 'USD Coin',
          decimals: 6,
        ),
        // BitGo Polygon token list, Wrapped BTC polygon:wbtc, from WBTC's
        // custodian,
        // https://developers.bitgo.com/coins/polygon-erc20-tokens
        CanonicalAsset(
          network: WalletNetwork.polygonPos,
          assetId: '0x1bfd67037b42cf73acf2047067bd4f2c47d9bfd6',
          symbol: 'WBTC',
          name: 'Wrapped Bitcoin',
          decimals: 8,
        ),
      ],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.bnbSmartChain,
      coingeckoId: 'binancecoin',
      coingeckoPlatform: 'binance-smart-chain',
      defillamaChain: 'bsc',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.bnbSmartChain,
        assetId: 'native',
        symbol: 'BNB',
        name: 'BNB Smart Chain',
        decimals: 18,
      ),
      canonicalTokens: [
        // Binance proof of collateral, Binance-Peg USDT BEP20,
        // https://www.binance.com/en/collateral-btokens
        CanonicalAsset(
          network: WalletNetwork.bnbSmartChain,
          assetId: '0x55d398326f99059ff775485246999027b3197955',
          symbol: 'USDT',
          name: 'Tether USD (Binance-Peg)',
          decimals: 18,
        ),
        // BitGo custodian contract addresses,
        // https://docs.wbtc.network/resources/contract-addresses
        CanonicalAsset(
          network: WalletNetwork.bnbSmartChain,
          assetId: '0x39665e85a68a4d7328b8799135e2ff301a0ca86f',
          symbol: 'WBTC',
          name: 'Wrapped Bitcoin',
          decimals: 8,
        ),
      ],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.avalancheCChain,
      coingeckoId: 'avalanche-2',
      coingeckoPlatform: 'avalanche',
      defillamaChain: 'avalanche',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.avalancheCChain,
        assetId: 'native',
        symbol: 'AVAX',
        name: 'Avalanche C-Chain',
        decimals: 18,
      ),
      canonicalTokens: [
        // Circle USDC contract addresses,
        // https://developers.circle.com/stablecoins/usdc-contract-addresses
        CanonicalAsset(
          network: WalletNetwork.avalancheCChain,
          assetId: '0xb97ef9ef8734c71904d8002f8b6bc66dd9c48a6e',
          symbol: 'USDC',
          name: 'USD Coin',
          decimals: 6,
        ),
        // Issuer integration guide, https://tether.to/en/supported-protocols
        CanonicalAsset(
          network: WalletNetwork.avalancheCChain,
          assetId: '0x9702230a8ea53601f5cd2dc00fdbc13d4df4a8c7',
          symbol: 'USDT',
          name: 'Tether USD',
          decimals: 6,
        ),
      ],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.tronMainnet,
      coingeckoId: 'tron',
      coingeckoPlatform: 'tron',
      defillamaChain: 'tron',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.tronMainnet,
        assetId: 'native',
        symbol: 'TRX',
        name: 'Tron',
        decimals: 6,
      ),
      canonicalTokens: [
        // Issuer integration guide, https://tether.to/en/supported-protocols
        CanonicalAsset(
          network: WalletNetwork.tronMainnet,
          assetId: 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t',
          symbol: 'USDT',
          name: 'Tether USD',
          decimals: 6,
        ),
        // BitGo custodian contract addresses,
        // https://docs.wbtc.network/resources/contract-addresses
        CanonicalAsset(
          network: WalletNetwork.tronMainnet,
          assetId: 'TYhWwKpw43ENFWBTGpzLHn3882f2au7SMi',
          symbol: 'WBTC',
          name: 'Wrapped Bitcoin',
          decimals: 8,
        ),
      ],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.xrplMainnet,
      coingeckoId: 'ripple',
      coingeckoPlatform: 'ripple',
      defillamaChain: 'ripple',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.xrplMainnet,
        assetId: 'native',
        symbol: 'XRP',
        name: 'XRP Ledger',
        decimals: 6,
      ),
      canonicalTokens: [
        // Circle USDC on XRPL: hex currency code USDC at issuer
        // rGm7WCVp9gb4jZHWTEtGUr4dd74z2XuWhE, from Circle's contract table,
        // https://developers.circle.com/stablecoins/usdc-contract-addresses
        CanonicalAsset(
          network: WalletNetwork.xrplMainnet,
          assetId:
              '5553444300000000000000000000000000000000.'
              'rGm7WCVp9gb4jZHWTEtGUr4dd74z2XuWhE',
          symbol: 'USDC',
          name: 'USD Coin',
          decimals: 15,
        ),
      ],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.hyperliquid,
      coingeckoId: 'hyperliquid',
      defillamaChain: 'hyperliquid',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.hyperliquid,
        assetId: 'native',
        symbol: 'HYPE',
        name: 'Hyperliquid',
        decimals: 8,
      ),
      canonicalTokens: [],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.dogecoinMainnet,
      coingeckoId: 'dogecoin',
      defillamaChain: 'dogecoin',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.dogecoinMainnet,
        assetId: 'native',
        symbol: 'DOGE',
        name: 'Dogecoin',
        decimals: 8,
      ),
      canonicalTokens: [],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.litecoinMainnet,
      coingeckoId: 'litecoin',
      defillamaChain: 'litecoin',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.litecoinMainnet,
        assetId: 'native',
        symbol: 'LTC',
        name: 'Litecoin',
        decimals: 8,
      ),
      canonicalTokens: [],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.cardanoMainnet,
      coingeckoId: 'cardano',
      defillamaChain: 'cardano',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.cardanoMainnet,
        assetId: 'native',
        symbol: 'ADA',
        name: 'Cardano',
        decimals: 6,
      ),
      canonicalTokens: [],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.tonMainnet,
      coingeckoId: 'the-open-network',
      coingeckoPlatform: 'ton',
      defillamaChain: 'ton',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.tonMainnet,
        assetId: 'native',
        symbol: 'TON',
        name: 'TON',
        decimals: 9,
      ),
      canonicalTokens: [
        // Tether USD jetton master, quoted in TON's own documentation,
        // https://docs.ton.org/applications/payments/jettons
        CanonicalAsset(
          network: WalletNetwork.tonMainnet,
          assetId:
              '0:b113a994b5024a16719f69139328eb759596c38a25f59028b146'
              'fecdc3621dfe',
          symbol: 'USDT',
          name: 'Tether USD',
          decimals: 6,
        ),
      ],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.suiMainnet,
      coingeckoId: 'sui',
      coingeckoPlatform: 'sui',
      defillamaChain: 'sui',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.suiMainnet,
        assetId: 'native',
        symbol: 'SUI',
        name: 'Sui',
        decimals: 9,
      ),
      canonicalTokens: [
        // Circle USDC contract addresses,
        // https://developers.circle.com/stablecoins/usdc-contract-addresses
        CanonicalAsset(
          network: WalletNetwork.suiMainnet,
          assetId:
              '0xdba34672e30cb065b1f93e3ab55318768fd6fef66c15942c9f7cb'
              '846e2f900e7::usdc::USDC',
          symbol: 'USDC',
          name: 'USD Coin',
          decimals: 6,
        ),
      ],
    ),
    ChainCatalogEntry(
      network: WalletNetwork.aptosMainnet,
      coingeckoId: 'aptos',
      coingeckoPlatform: 'aptos',
      defillamaChain: 'aptos',
      nativeAsset: CanonicalAsset(
        network: WalletNetwork.aptosMainnet,
        assetId: 'native',
        symbol: 'APT',
        name: 'Aptos',
        decimals: 8,
      ),
      canonicalTokens: [
        // Issuer integration guide, the USD₮ Token Object Asset ID,
        // https://tether.to/en/supported-protocols
        CanonicalAsset(
          network: WalletNetwork.aptosMainnet,
          assetId:
              '0x357b0b74bc833e95a115ad22604854d6b0fca151cecd94111770e5'
              'd6ffc9dc2b',
          symbol: 'USDT',
          name: 'Tether USD',
          decimals: 6,
        ),
        // Circle USDC contract addresses,
        // https://developers.circle.com/stablecoins/usdc-contract-addresses
        CanonicalAsset(
          network: WalletNetwork.aptosMainnet,
          assetId:
              '0xbae207659db88bea0cbead6da0ed00aac12edcdda169e591cd41c94'
              '180b46f3b',
          symbol: 'USDC',
          name: 'USD Coin',
          decimals: 6,
        ),
      ],
    ),
  ];

  /// The catalogue entry of [network]. Every enum value has one; a missing
  /// entry is a programming error, not a runtime condition.
  static ChainCatalogEntry entryFor(WalletNetwork network) =>
      entries.firstWhere((entry) => entry.network == network);

  /// The canonical token with [assetId] on [network], or null when the
  /// asset is not in the catalogue.
  static CanonicalAsset? tryAsset(WalletNetwork network, String assetId) {
    for (final asset in assetsFor(network)) {
      if (asset.assetId == assetId) {
        return asset;
      }
    }
    return null;
  }

  /// The network's native coin followed by its canonical tokens.
  static List<CanonicalAsset> assetsFor(WalletNetwork network) {
    final entry = entryFor(network);
    return [entry.nativeAsset, ...entry.canonicalTokens];
  }
}
