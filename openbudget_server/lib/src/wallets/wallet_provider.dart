import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/common/confidence.dart';
import 'package:openbudget_server/src/generated/wallets/price_quality.dart';
import 'package:openbudget_server/src/generated/wallets/price_source.dart';
import 'package:openbudget_server/src/generated/wallets/wallet_network.dart';

/// A provider failure that should leave the last committed wallet facts alone.
final class WalletProviderException implements Exception {
  const WalletProviderException(this.message);

  final String message;

  @override
  String toString() => message;
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
final class WalletProviderHolding {
  const WalletProviderHolding({
    required this.assetId,
    required this.decimals,
    required this.quantityRaw,
    required this.isNft,
    required this.prices,
    this.symbol,
    this.name,
    this.tokenProgram,
    this.metadataJson,
  });

  final String assetId;
  final int decimals;
  final BigInt quantityRaw;
  final bool isNft;
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
final class WalletProviderSnapshot {
  const WalletProviderSnapshot({
    required this.holdings,
    required this.transactions,
    required this.warnings,
    this.newestSignature,
  });

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
  Future<WalletProviderSnapshot> fetchSnapshot({
    required WalletNetwork network,
    required String address,
    String? untilSignature,
  });
}
