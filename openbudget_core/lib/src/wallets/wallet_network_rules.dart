import 'package:openbudget_core/src/generated/wallet_network.dart';
import 'package:openbudget_core/src/wallets/chain_catalog.dart';
import 'package:openbudget_core/src/wallets/chain_family.dart';

/// Per-network wallet rules: the chain family, testnet flag, native coin,
/// display name, EVM chain id and catalogue entry of a [WalletNetwork].
///
/// Derived, never stored; adding a network value means adding its row here
/// and its [ChainCatalogEntry].
extension WalletNetworkRules on WalletNetwork {
  /// The family whose provider reads this network.
  ChainFamily get family => switch (this) {
    WalletNetwork.solanaMainnet ||
    WalletNetwork.solanaDevnet => ChainFamily.solana,
    WalletNetwork.bitcoinMainnet => ChainFamily.bitcoin,
    WalletNetwork.ethereumMainnet ||
    WalletNetwork.baseMainnet ||
    WalletNetwork.arbitrumOne ||
    WalletNetwork.opMainnet ||
    WalletNetwork.polygonPos ||
    WalletNetwork.bnbSmartChain ||
    WalletNetwork.avalancheCChain => ChainFamily.evm,
    WalletNetwork.tronMainnet => ChainFamily.tron,
    WalletNetwork.xrplMainnet => ChainFamily.xrpl,
    WalletNetwork.hyperliquid => ChainFamily.hyperliquid,
    WalletNetwork.dogecoinMainnet => ChainFamily.dogecoin,
    WalletNetwork.litecoinMainnet => ChainFamily.litecoin,
    WalletNetwork.cardanoMainnet => ChainFamily.cardano,
    WalletNetwork.tonMainnet => ChainFamily.ton,
    WalletNetwork.suiMainnet => ChainFamily.sui,
    WalletNetwork.aptosMainnet => ChainFamily.aptos,
  };

  /// Whether this network is a test network whose holdings never carry
  /// value. Every other value is a mainnet.
  bool get isTestnet => this == WalletNetwork.solanaDevnet;

  /// The ticker of the network's own coin, the asset priced as `native`.
  String get nativeSymbol => entry.nativeAsset.symbol;

  /// Base units per whole native coin, from the network's own protocol.
  int get nativeDecimals => entry.nativeAsset.decimals;

  /// The network's name as the app shows it.
  String get displayName => entry.nativeAsset.name;

  /// The network's EIP-155 chain id, or null for every non-EVM network.
  int? get evmChainId => switch (this) {
    WalletNetwork.ethereumMainnet => 1,
    WalletNetwork.opMainnet => 10,
    WalletNetwork.polygonPos => 137,
    WalletNetwork.bnbSmartChain => 56,
    WalletNetwork.arbitrumOne => 42161,
    WalletNetwork.avalancheCChain => 43114,
    WalletNetwork.baseMainnet => 8453,
    _ => null,
  };

  /// The network's chain catalogue entry.
  ChainCatalogEntry get entry => ChainCatalog.entryFor(this);

  /// CoinGecko coin id for the network's native coin.
  String? get coingeckoId => entry.coingeckoId;
  String? get coingeckoCoinId => entry.coingeckoId;
  String? get coinGeckoId => entry.coingeckoId;
  String? get nativeCoingeckoId => entry.coingeckoId;
  String? get coingeckoNativeId => entry.coingeckoId;

  /// CoinGecko platform id for token pricing.
  String? get coingeckoPlatform => entry.coingeckoPlatform;
  String? get coingeckoPlatformId => entry.coingeckoPlatform;
  String? get platform => entry.coingeckoPlatform;
  String? get coingeckoPlatformName => entry.coingeckoPlatform;

  /// DefiLlama chain key.
  String? get defillamaChain => entry.defillamaChain;
}
