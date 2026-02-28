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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// Current holding state for an asset in a Solana wallet.
abstract class SolanaWalletHolding implements _i1.SerializableModel {
  SolanaWalletHolding._({
    this.id,
    required this.walletId,
    required this.budgetId,
    required this.assetId,
    this.symbol,
    this.name,
    this.tokenProgram,
    required this.decimals,
    required this.balanceRaw,
    required this.balanceUi,
    required this.isNft,
    this.priceCurrency,
    this.pricePerToken,
    this.totalValue,
    this.estimatedCostBasis,
    this.estimatedUnrealizedPnl,
    this.estimatedUnrealizedPnlPercent,
    this.estimatedRealizedPnl,
    this.pnlCurrency,
    this.pnlAsOf,
    this.priceSource,
    this.priceAsOf,
    this.metadataJson,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory SolanaWalletHolding({
    _i1.UuidValue? id,
    required _i1.UuidValue walletId,
    required _i1.UuidValue budgetId,
    required String assetId,
    String? symbol,
    String? name,
    String? tokenProgram,
    required int decimals,
    required String balanceRaw,
    required String balanceUi,
    required bool isNft,
    String? priceCurrency,
    double? pricePerToken,
    double? totalValue,
    double? estimatedCostBasis,
    double? estimatedUnrealizedPnl,
    double? estimatedUnrealizedPnlPercent,
    double? estimatedRealizedPnl,
    String? pnlCurrency,
    DateTime? pnlAsOf,
    String? priceSource,
    DateTime? priceAsOf,
    String? metadataJson,
    DateTime? updatedAt,
  }) = _SolanaWalletHoldingImpl;

  factory SolanaWalletHolding.fromJson(Map<String, dynamic> jsonSerialization) {
    return SolanaWalletHolding(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      walletId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletId'],
      ),
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      assetId: jsonSerialization['assetId'] as String,
      symbol: jsonSerialization['symbol'] as String?,
      name: jsonSerialization['name'] as String?,
      tokenProgram: jsonSerialization['tokenProgram'] as String?,
      decimals: jsonSerialization['decimals'] as int,
      balanceRaw: jsonSerialization['balanceRaw'] as String,
      balanceUi: jsonSerialization['balanceUi'] as String,
      isNft: jsonSerialization['isNft'] as bool,
      priceCurrency: jsonSerialization['priceCurrency'] as String?,
      pricePerToken: (jsonSerialization['pricePerToken'] as num?)?.toDouble(),
      totalValue: (jsonSerialization['totalValue'] as num?)?.toDouble(),
      estimatedCostBasis: (jsonSerialization['estimatedCostBasis'] as num?)
          ?.toDouble(),
      estimatedUnrealizedPnl:
          (jsonSerialization['estimatedUnrealizedPnl'] as num?)?.toDouble(),
      estimatedUnrealizedPnlPercent:
          (jsonSerialization['estimatedUnrealizedPnlPercent'] as num?)
              ?.toDouble(),
      estimatedRealizedPnl: (jsonSerialization['estimatedRealizedPnl'] as num?)
          ?.toDouble(),
      pnlCurrency: jsonSerialization['pnlCurrency'] as String?,
      pnlAsOf: jsonSerialization['pnlAsOf'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['pnlAsOf']),
      priceSource: jsonSerialization['priceSource'] as String?,
      priceAsOf: jsonSerialization['priceAsOf'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['priceAsOf']),
      metadataJson: jsonSerialization['metadataJson'] as String?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue walletId;

  _i1.UuidValue budgetId;

  /// Asset identifier (mint address for fungible tokens / NFT ID).
  String assetId;

  String? symbol;

  String? name;

  /// Token program identifier (e.g. Tokenkeg..., TokenzQd...).
  String? tokenProgram;

  int decimals;

  /// Raw integer amount in base units.
  String balanceRaw;

  /// Decimal amount as a string for display.
  String balanceUi;

  bool isNft;

  /// Quote currency for valuation (for now typically USD).
  String? priceCurrency;

  double? pricePerToken;

  double? totalValue;

  /// Estimated aggregate acquisition basis in quote currency.
  double? estimatedCostBasis;

  /// Estimated unrealized gain/loss in quote currency.
  double? estimatedUnrealizedPnl;

  /// Estimated unrealized gain/loss percentage.
  double? estimatedUnrealizedPnlPercent;

  /// Estimated realized gain/loss accumulated for this asset.
  double? estimatedRealizedPnl;

  /// Quote currency used for estimated P&L values.
  String? pnlCurrency;

  /// Timestamp for the last P&L estimate update.
  DateTime? pnlAsOf;

  String? priceSource;

  DateTime? priceAsOf;

  /// JSON-encoded asset metadata subset.
  String? metadataJson;

  DateTime updatedAt;

  /// Returns a shallow copy of this [SolanaWalletHolding]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SolanaWalletHolding copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? walletId,
    _i1.UuidValue? budgetId,
    String? assetId,
    String? symbol,
    String? name,
    String? tokenProgram,
    int? decimals,
    String? balanceRaw,
    String? balanceUi,
    bool? isNft,
    String? priceCurrency,
    double? pricePerToken,
    double? totalValue,
    double? estimatedCostBasis,
    double? estimatedUnrealizedPnl,
    double? estimatedUnrealizedPnlPercent,
    double? estimatedRealizedPnl,
    String? pnlCurrency,
    DateTime? pnlAsOf,
    String? priceSource,
    DateTime? priceAsOf,
    String? metadataJson,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SolanaWalletHolding',
      if (id != null) 'id': id?.toJson(),
      'walletId': walletId.toJson(),
      'budgetId': budgetId.toJson(),
      'assetId': assetId,
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (tokenProgram != null) 'tokenProgram': tokenProgram,
      'decimals': decimals,
      'balanceRaw': balanceRaw,
      'balanceUi': balanceUi,
      'isNft': isNft,
      if (priceCurrency != null) 'priceCurrency': priceCurrency,
      if (pricePerToken != null) 'pricePerToken': pricePerToken,
      if (totalValue != null) 'totalValue': totalValue,
      if (estimatedCostBasis != null) 'estimatedCostBasis': estimatedCostBasis,
      if (estimatedUnrealizedPnl != null)
        'estimatedUnrealizedPnl': estimatedUnrealizedPnl,
      if (estimatedUnrealizedPnlPercent != null)
        'estimatedUnrealizedPnlPercent': estimatedUnrealizedPnlPercent,
      if (estimatedRealizedPnl != null)
        'estimatedRealizedPnl': estimatedRealizedPnl,
      if (pnlCurrency != null) 'pnlCurrency': pnlCurrency,
      if (pnlAsOf != null) 'pnlAsOf': pnlAsOf?.toJson(),
      if (priceSource != null) 'priceSource': priceSource,
      if (priceAsOf != null) 'priceAsOf': priceAsOf?.toJson(),
      if (metadataJson != null) 'metadataJson': metadataJson,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SolanaWalletHoldingImpl extends SolanaWalletHolding {
  _SolanaWalletHoldingImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue walletId,
    required _i1.UuidValue budgetId,
    required String assetId,
    String? symbol,
    String? name,
    String? tokenProgram,
    required int decimals,
    required String balanceRaw,
    required String balanceUi,
    required bool isNft,
    String? priceCurrency,
    double? pricePerToken,
    double? totalValue,
    double? estimatedCostBasis,
    double? estimatedUnrealizedPnl,
    double? estimatedUnrealizedPnlPercent,
    double? estimatedRealizedPnl,
    String? pnlCurrency,
    DateTime? pnlAsOf,
    String? priceSource,
    DateTime? priceAsOf,
    String? metadataJson,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         walletId: walletId,
         budgetId: budgetId,
         assetId: assetId,
         symbol: symbol,
         name: name,
         tokenProgram: tokenProgram,
         decimals: decimals,
         balanceRaw: balanceRaw,
         balanceUi: balanceUi,
         isNft: isNft,
         priceCurrency: priceCurrency,
         pricePerToken: pricePerToken,
         totalValue: totalValue,
         estimatedCostBasis: estimatedCostBasis,
         estimatedUnrealizedPnl: estimatedUnrealizedPnl,
         estimatedUnrealizedPnlPercent: estimatedUnrealizedPnlPercent,
         estimatedRealizedPnl: estimatedRealizedPnl,
         pnlCurrency: pnlCurrency,
         pnlAsOf: pnlAsOf,
         priceSource: priceSource,
         priceAsOf: priceAsOf,
         metadataJson: metadataJson,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [SolanaWalletHolding]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SolanaWalletHolding copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? walletId,
    _i1.UuidValue? budgetId,
    String? assetId,
    Object? symbol = _Undefined,
    Object? name = _Undefined,
    Object? tokenProgram = _Undefined,
    int? decimals,
    String? balanceRaw,
    String? balanceUi,
    bool? isNft,
    Object? priceCurrency = _Undefined,
    Object? pricePerToken = _Undefined,
    Object? totalValue = _Undefined,
    Object? estimatedCostBasis = _Undefined,
    Object? estimatedUnrealizedPnl = _Undefined,
    Object? estimatedUnrealizedPnlPercent = _Undefined,
    Object? estimatedRealizedPnl = _Undefined,
    Object? pnlCurrency = _Undefined,
    Object? pnlAsOf = _Undefined,
    Object? priceSource = _Undefined,
    Object? priceAsOf = _Undefined,
    Object? metadataJson = _Undefined,
    DateTime? updatedAt,
  }) {
    return SolanaWalletHolding(
      id: id is _i1.UuidValue? ? id : this.id,
      walletId: walletId ?? this.walletId,
      budgetId: budgetId ?? this.budgetId,
      assetId: assetId ?? this.assetId,
      symbol: symbol is String? ? symbol : this.symbol,
      name: name is String? ? name : this.name,
      tokenProgram: tokenProgram is String? ? tokenProgram : this.tokenProgram,
      decimals: decimals ?? this.decimals,
      balanceRaw: balanceRaw ?? this.balanceRaw,
      balanceUi: balanceUi ?? this.balanceUi,
      isNft: isNft ?? this.isNft,
      priceCurrency: priceCurrency is String?
          ? priceCurrency
          : this.priceCurrency,
      pricePerToken: pricePerToken is double?
          ? pricePerToken
          : this.pricePerToken,
      totalValue: totalValue is double? ? totalValue : this.totalValue,
      estimatedCostBasis: estimatedCostBasis is double?
          ? estimatedCostBasis
          : this.estimatedCostBasis,
      estimatedUnrealizedPnl: estimatedUnrealizedPnl is double?
          ? estimatedUnrealizedPnl
          : this.estimatedUnrealizedPnl,
      estimatedUnrealizedPnlPercent: estimatedUnrealizedPnlPercent is double?
          ? estimatedUnrealizedPnlPercent
          : this.estimatedUnrealizedPnlPercent,
      estimatedRealizedPnl: estimatedRealizedPnl is double?
          ? estimatedRealizedPnl
          : this.estimatedRealizedPnl,
      pnlCurrency: pnlCurrency is String? ? pnlCurrency : this.pnlCurrency,
      pnlAsOf: pnlAsOf is DateTime? ? pnlAsOf : this.pnlAsOf,
      priceSource: priceSource is String? ? priceSource : this.priceSource,
      priceAsOf: priceAsOf is DateTime? ? priceAsOf : this.priceAsOf,
      metadataJson: metadataJson is String? ? metadataJson : this.metadataJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
