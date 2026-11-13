import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/common/confidence.dart';
import 'package:openbudget_server/src/generated/wallets/holding_position.dart';
import 'package:openbudget_server/src/generated/wallets/price_quality.dart';
import 'package:openbudget_server/src/generated/wallets/price_source.dart';
import 'package:serverpod/serverpod.dart';

/// A provider failure that should leave the last committed wallet facts alone.
final class WalletProviderException implements Exception {
  const WalletProviderException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Builds the chain provider for one wallet and network.
///
/// The network is the wallet's home network; a provider that reads several
/// networks of one family, such as the future EVM provider, takes the rest
/// from the request.
typedef WalletProviderFactory = WalletProvider Function(
  Session session,
  WalletNetwork network,
);

/// What one read covers.
///
/// [address] is the canonical address, or the `hd:` identity of a sealed HD
/// key once HD wallets land. [networks] are the networks to read: the
/// wallet's `scanNetworks`, or `[homeNetwork]` when it has none, always
/// containing [homeNetwork] and at least one network. [descriptor] is opened
/// by the service for HD wallets only. [untilSignature] is the Solana history
/// cursor; [historyCursors] carry every other family's provider-defined
/// history position. [includeHistory] is false for every new family until
/// history sync ships.
final class WalletReadRequest {
  const WalletReadRequest({
    required this.homeNetwork,
    required this.networks,
    required this.address,
    this.descriptor,
    this.untilSignature,
    this.historyCursors = const {},
    this.includeHistory = true,
  });

  final WalletNetwork homeNetwork;

  /// The networks to read, in display order. Always contains
  /// [homeNetwork].
  final List<WalletNetwork> networks;

  final String address;
  final String? descriptor;
  final String? untilSignature;
  final Map<WalletNetwork, String> historyCursors;
  final bool includeHistory;
}

/// One price candidate for a holding, in preference order.
///
/// [unitPrice] is the price of one whole token. [totalPrice] is used when a
/// provider quotes the whole held position instead; the valuation then rounds
/// the provider total once instead of multiplying a derived unit price.
final class WalletProviderPrice {
  const WalletProviderPrice({
    required this.currencyCode,
    required this.source,
    required this.quality,
    required this.confidence,
    required this.asOf,
    this.unitPrice,
    this.totalPrice,
    this.collectionSymbol,
    this.solPrice,
  });

  final ExactDecimal? unitPrice;
  final ExactDecimal? totalPrice;
  final String currencyCode;
  final PriceSource source;
  final PriceQuality quality;
  final Confidence confidence;
  final DateTime asOf;
  final String? collectionSymbol;
  final double? solPrice;
}

/// One current asset a provider says the wallet holds.
///
/// [network] is the network the asset is on and [position] is spendable,
/// staked or unclaimed; each position of an asset is its own holding.
final class WalletProviderHolding {
  const WalletProviderHolding({
    required this.network,
    required this.assetId,
    required this.decimals,
    required this.quantityRaw,
    required this.isNft,
    required this.prices,
    this.position = HoldingPosition.available,
    this.symbol,
    this.name,
    this.tokenProgram,
    this.metadataJson,
  });

  final WalletNetwork network;
  final String assetId;
  final int decimals;
  final BigInt quantityRaw;
  final bool isNft;
  final HoldingPosition position;
  final List<WalletProviderPrice> prices;
  final String? symbol;
  final String? name;
  final String? tokenProgram;
  final String? metadataJson;
}

/// One on-chain token movement used to estimate FIFO P&L.
final class WalletProviderMovement {
  const WalletProviderMovement({
    required this.mint,
    required this.fromAccount,
    required this.toAccount,
    required this.amountRaw,
  });

  final String mint;
  final String fromAccount;
  final String toAccount;
  final BigInt amountRaw;
}

/// One parsed transaction ready to be persisted.
final class WalletProviderTransaction {
  const WalletProviderTransaction({
    required this.signature,
    required this.slot,
    required this.description,
    required this.txType,
    required this.source,
    required this.movements,
    this.occurredAt,
    this.interpretationConfidence,
    this.programsJson,
    this.nativeTransfersJson,
    this.tokenTransfersJson,
    this.rawJson,
  });

  final String signature;
  final int slot;
  final DateTime? occurredAt;
  final String description;
  final String txType;
  final String source;
  final Confidence? interpretationConfidence;
  final String? programsJson;
  final String? nativeTransfersJson;
  final String? tokenTransfersJson;
  final String? rawJson;
  final List<WalletProviderMovement> movements;
}

/// Everything one provider fetch contributes to a sync.
///
/// [readNetworks] are the networks whose results this snapshot carries;
/// [failedNetworks] maps each network that could not be read to a plain-words
/// reason fit to show the user, and [historyCursors] records the per-network
/// history position reached. Solana keeps its cursor in the wallet row, so
/// its snapshots carry no [historyCursors] yet.
final class WalletProviderSnapshot {
  const WalletProviderSnapshot({
    required this.readNetworks,
    required this.holdings,
    required this.transactions,
    required this.warnings,
    this.failedNetworks = const {},
    this.historyCursors = const {},
    this.newestSignature,
  });

  final List<WalletNetwork> readNetworks;

  /// Networks that could not be read, each with a plain-words reason.
  final Map<WalletNetwork, String> failedNetworks;
  final Map<WalletNetwork, String> historyCursors;
  final List<WalletProviderHolding> holdings;
  final List<WalletProviderTransaction> transactions;
  final String? newestSignature;
  final List<String> warnings;
}

/// The read-only chain data a wallet sync needs.
///
/// Implementations perform every network call before the service opens its
/// database transaction, so a slow provider never holds a wallet row lock.
// ignore: one_member_abstracts
abstract interface class WalletProvider {
  Future<WalletProviderSnapshot> fetchSnapshot(WalletReadRequest request);
}
