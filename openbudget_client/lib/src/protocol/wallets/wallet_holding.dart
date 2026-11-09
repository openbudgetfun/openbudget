/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import '../common/confidence.dart' as _itaosqa4;
import '../wallets/price_quality.dart' as _iy1clnxb;
import '../wallets/price_source.dart' as _ip9y7dom;

/// The current quantity and valuation of one asset in a wallet.
abstract class WalletHolding
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WalletHolding._({
    this.id,
    required this.walletId,
    required this.assetId,
    this.symbol,
    this.name,
    this.tokenProgram,
    required this.decimals,
    required this.quantityRaw,
    bool? isNft,
    this.priceCurrencyCode,
    this.unitPrice,
    this.valueMinor,
    this.priceSource,
    _iy1clnxb.PriceQuality? priceQuality,
    this.priceConfidence,
    this.priceAsOf,
    this.costBasisMinor,
    this.realizedPnlMinor,
    this.pnlAsOf,
    this.metadataJson,
    DateTime? updatedAt,
  }) : isNft = isNft ?? false,
       priceQuality = priceQuality ?? _iy1clnxb.PriceQuality.unpriced,
       updatedAt = updatedAt ?? DateTime.now();

  factory WalletHolding({
    _isc.UuidValue? id,
    required _isc.UuidValue walletId,
    required String assetId,
    String? symbol,
    String? name,
    String? tokenProgram,
    required int decimals,
    required BigInt quantityRaw,
    bool? isNft,
    String? priceCurrencyCode,
    String? unitPrice,
    int? valueMinor,
    _ip9y7dom.PriceSource? priceSource,
    _iy1clnxb.PriceQuality? priceQuality,
    _itaosqa4.Confidence? priceConfidence,
    DateTime? priceAsOf,
    int? costBasisMinor,
    int? realizedPnlMinor,
    DateTime? pnlAsOf,
    String? metadataJson,
    DateTime? updatedAt,
  }) = _WalletHoldingImpl;

  factory WalletHolding.fromJson(Map<String, dynamic> jsonSerialization) {
    return WalletHolding(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      walletId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletId'],
      ),
      assetId: jsonSerialization['assetId'] as String,
      symbol: jsonSerialization['symbol'] as String?,
      name: jsonSerialization['name'] as String?,
      tokenProgram: jsonSerialization['tokenProgram'] as String?,
      decimals: jsonSerialization['decimals'] as int,
      quantityRaw: _isc.BigIntJsonExtension.fromJson(
        jsonSerialization['quantityRaw'],
      ),
      isNft: jsonSerialization['isNft'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isNft']),
      priceCurrencyCode: jsonSerialization['priceCurrencyCode'] as String?,
      unitPrice: jsonSerialization['unitPrice'] as String?,
      valueMinor: jsonSerialization['valueMinor'] as int?,
      priceSource: jsonSerialization['priceSource'] == null
          ? null
          : _ip9y7dom.PriceSource.fromJson(
              (jsonSerialization['priceSource'] as String),
            ),
      priceQuality: jsonSerialization['priceQuality'] == null
          ? null
          : _iy1clnxb.PriceQuality.fromJson(
              (jsonSerialization['priceQuality'] as String),
            ),
      priceConfidence: jsonSerialization['priceConfidence'] == null
          ? null
          : _itaosqa4.Confidence.fromJson(
              (jsonSerialization['priceConfidence'] as String),
            ),
      priceAsOf: jsonSerialization['priceAsOf'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['priceAsOf']),
      costBasisMinor: jsonSerialization['costBasisMinor'] as int?,
      realizedPnlMinor: jsonSerialization['realizedPnlMinor'] as int?,
      pnlAsOf: jsonSerialization['pnlAsOf'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['pnlAsOf']),
      metadataJson: jsonSerialization['metadataJson'] as String?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue walletId;

  /// Mint address, or `native` for the chain's own token.
  String assetId;

  String? symbol;

  String? name;

  /// Token program id, such as Tokenkeg... or TokenzQd...
  String? tokenProgram;

  int decimals;

  /// Quantity in the asset's base units (lamports for SOL).
  BigInt quantityRaw;

  bool isNft;

  /// ISO 4217 code that unitPrice and every *Minor field here are in.
  String? priceCurrencyCode;

  /// Price of one whole token, exact decimal string.
  String? unitPrice;

  /// Quantity times unitPrice, in priceCurrencyCode minor units, half up.
  int? valueMinor;

  _ip9y7dom.PriceSource? priceSource;

  _iy1clnxb.PriceQuality priceQuality;

  _itaosqa4.Confidence? priceConfidence;

  DateTime? priceAsOf;

  /// Estimated acquisition cost of the current quantity.
  int? costBasisMinor;

  /// Estimated realised gain or loss accumulated for this asset.
  int? realizedPnlMinor;

  DateTime? pnlAsOf;

  /// JSON subset of the asset's metadata.
  String? metadataJson;

  DateTime updatedAt;

  /// Returns a shallow copy of this [WalletHolding]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WalletHolding copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? walletId,
    String? assetId,
    String? symbol,
    String? name,
    String? tokenProgram,
    int? decimals,
    BigInt? quantityRaw,
    bool? isNft,
    String? priceCurrencyCode,
    String? unitPrice,
    int? valueMinor,
    _ip9y7dom.PriceSource? priceSource,
    _iy1clnxb.PriceQuality? priceQuality,
    _itaosqa4.Confidence? priceConfidence,
    DateTime? priceAsOf = const _isc.$UndefinedDateTime(),
    int? costBasisMinor,
    int? realizedPnlMinor,
    DateTime? pnlAsOf = const _isc.$UndefinedDateTime(),
    String? metadataJson,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletHolding',
      if (id != null) 'id': id?.toJson(),
      'walletId': walletId.toJson(),
      'assetId': assetId,
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (tokenProgram != null) 'tokenProgram': tokenProgram,
      'decimals': decimals,
      'quantityRaw': quantityRaw.toJson(),
      'isNft': isNft,
      if (priceCurrencyCode != null) 'priceCurrencyCode': priceCurrencyCode,
      if (unitPrice != null) 'unitPrice': unitPrice,
      if (valueMinor != null) 'valueMinor': valueMinor,
      if (priceSource != null) 'priceSource': priceSource?.toJson(),
      'priceQuality': priceQuality.toJson(),
      if (priceConfidence != null) 'priceConfidence': priceConfidence?.toJson(),
      if (priceAsOf != null) 'priceAsOf': priceAsOf?.toJson(),
      if (costBasisMinor != null) 'costBasisMinor': costBasisMinor,
      if (realizedPnlMinor != null) 'realizedPnlMinor': realizedPnlMinor,
      if (pnlAsOf != null) 'pnlAsOf': pnlAsOf?.toJson(),
      if (metadataJson != null) 'metadataJson': metadataJson,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WalletHolding',
      if (id != null) 'id': id?.toJson(),
      'walletId': walletId.toJson(),
      'assetId': assetId,
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (tokenProgram != null) 'tokenProgram': tokenProgram,
      'decimals': decimals,
      'quantityRaw': quantityRaw.toJson(),
      'isNft': isNft,
      if (priceCurrencyCode != null) 'priceCurrencyCode': priceCurrencyCode,
      if (unitPrice != null) 'unitPrice': unitPrice,
      if (valueMinor != null) 'valueMinor': valueMinor,
      if (priceSource != null) 'priceSource': priceSource?.toJson(),
      'priceQuality': priceQuality.toJson(),
      if (priceConfidence != null) 'priceConfidence': priceConfidence?.toJson(),
      if (priceAsOf != null) 'priceAsOf': priceAsOf?.toJson(),
      if (costBasisMinor != null) 'costBasisMinor': costBasisMinor,
      if (realizedPnlMinor != null) 'realizedPnlMinor': realizedPnlMinor,
      if (pnlAsOf != null) 'pnlAsOf': pnlAsOf?.toJson(),
      if (metadataJson != null) 'metadataJson': metadataJson,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletHoldingImpl extends WalletHolding {
  _WalletHoldingImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue walletId,
    required String assetId,
    String? symbol,
    String? name,
    String? tokenProgram,
    required int decimals,
    required BigInt quantityRaw,
    bool? isNft,
    String? priceCurrencyCode,
    String? unitPrice,
    int? valueMinor,
    _ip9y7dom.PriceSource? priceSource,
    _iy1clnxb.PriceQuality? priceQuality,
    _itaosqa4.Confidence? priceConfidence,
    DateTime? priceAsOf,
    int? costBasisMinor,
    int? realizedPnlMinor,
    DateTime? pnlAsOf,
    String? metadataJson,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         walletId: walletId,
         assetId: assetId,
         symbol: symbol,
         name: name,
         tokenProgram: tokenProgram,
         decimals: decimals,
         quantityRaw: quantityRaw,
         isNft: isNft,
         priceCurrencyCode: priceCurrencyCode,
         unitPrice: unitPrice,
         valueMinor: valueMinor,
         priceSource: priceSource,
         priceQuality: priceQuality,
         priceConfidence: priceConfidence,
         priceAsOf: priceAsOf,
         costBasisMinor: costBasisMinor,
         realizedPnlMinor: realizedPnlMinor,
         pnlAsOf: pnlAsOf,
         metadataJson: metadataJson,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [WalletHolding]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WalletHolding copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? walletId,
    String? assetId,
    Object? symbol = _Undefined,
    Object? name = _Undefined,
    Object? tokenProgram = _Undefined,
    int? decimals,
    BigInt? quantityRaw,
    bool? isNft,
    Object? priceCurrencyCode = _Undefined,
    Object? unitPrice = _Undefined,
    Object? valueMinor = _Undefined,
    Object? priceSource = _Undefined,
    _iy1clnxb.PriceQuality? priceQuality,
    Object? priceConfidence = _Undefined,
    DateTime? priceAsOf = const _isc.$UndefinedDateTime(),
    Object? costBasisMinor = _Undefined,
    Object? realizedPnlMinor = _Undefined,
    DateTime? pnlAsOf = const _isc.$UndefinedDateTime(),
    Object? metadataJson = _Undefined,
    DateTime? updatedAt,
  }) {
    return WalletHolding(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      walletId: walletId ?? this.walletId,
      assetId: assetId ?? this.assetId,
      symbol: symbol is String? ? symbol : this.symbol,
      name: name is String? ? name : this.name,
      tokenProgram: tokenProgram is String? ? tokenProgram : this.tokenProgram,
      decimals: decimals ?? this.decimals,
      quantityRaw: quantityRaw ?? this.quantityRaw,
      isNft: isNft ?? this.isNft,
      priceCurrencyCode: priceCurrencyCode is String?
          ? priceCurrencyCode
          : this.priceCurrencyCode,
      unitPrice: unitPrice is String? ? unitPrice : this.unitPrice,
      valueMinor: valueMinor is int? ? valueMinor : this.valueMinor,
      priceSource: priceSource is _ip9y7dom.PriceSource?
          ? priceSource
          : this.priceSource,
      priceQuality: priceQuality ?? this.priceQuality,
      priceConfidence: priceConfidence is _itaosqa4.Confidence?
          ? priceConfidence
          : this.priceConfidence,
      priceAsOf: priceAsOf is _isc.UndefinedSentinel
          ? this.priceAsOf
          : priceAsOf,
      costBasisMinor: costBasisMinor is int?
          ? costBasisMinor
          : this.costBasisMinor,
      realizedPnlMinor: realizedPnlMinor is int?
          ? realizedPnlMinor
          : this.realizedPnlMinor,
      pnlAsOf: pnlAsOf is _isc.UndefinedSentinel ? this.pnlAsOf : pnlAsOf,
      metadataJson: metadataJson is String? ? metadataJson : this.metadataJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
