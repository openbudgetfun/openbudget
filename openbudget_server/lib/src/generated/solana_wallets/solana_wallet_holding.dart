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
import 'dart:async' as _ida;

import 'package:serverpod/serverpod.dart' as _is;

/// Current holding state for an asset in a Solana wallet.
abstract class SolanaWalletHolding
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
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
    this.priceQuality,
    this.priceConfidence,
    this.isPriceStale,
    this.priceAsOf,
    this.metadataJson,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory SolanaWalletHolding({
    _is.UuidValue? id,
    required _is.UuidValue walletId,
    required _is.UuidValue budgetId,
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
    String? priceQuality,
    String? priceConfidence,
    bool? isPriceStale,
    DateTime? priceAsOf,
    String? metadataJson,
    DateTime? updatedAt,
  }) = _SolanaWalletHoldingImpl;

  factory SolanaWalletHolding.fromJson(Map<String, dynamic> jsonSerialization) {
    return SolanaWalletHolding(
      id: jsonSerialization['id'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      walletId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletId'],
      ),
      budgetId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      assetId: jsonSerialization['assetId'] as String,
      symbol: jsonSerialization['symbol'] as String?,
      name: jsonSerialization['name'] as String?,
      tokenProgram: jsonSerialization['tokenProgram'] as String?,
      decimals: jsonSerialization['decimals'] as int,
      balanceRaw: jsonSerialization['balanceRaw'] as String,
      balanceUi: jsonSerialization['balanceUi'] as String,
      isNft: _is.BoolJsonExtension.fromJson(jsonSerialization['isNft']),
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
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['pnlAsOf']),
      priceSource: jsonSerialization['priceSource'] as String?,
      priceQuality: jsonSerialization['priceQuality'] as String?,
      priceConfidence: jsonSerialization['priceConfidence'] as String?,
      isPriceStale: jsonSerialization['isPriceStale'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isPriceStale']),
      priceAsOf: jsonSerialization['priceAsOf'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['priceAsOf']),
      metadataJson: jsonSerialization['metadataJson'] as String?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = SolanaWalletHoldingTable();

  static const db = SolanaWalletHoldingRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue walletId;

  _is.UuidValue budgetId;

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

  /// Qualitative pricing classification: provider, derived, stale_cache, unpriced.
  String? priceQuality;

  /// Confidence tier for the valuation source: high, medium, low.
  String? priceConfidence;

  /// True when valuation is using a cached fallback price.
  bool? isPriceStale;

  DateTime? priceAsOf;

  /// JSON-encoded asset metadata subset.
  String? metadataJson;

  DateTime updatedAt;

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [SolanaWalletHolding]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SolanaWalletHolding copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? walletId,
    _is.UuidValue? budgetId,
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
    DateTime? pnlAsOf = const _is.$UndefinedDateTime(),
    String? priceSource,
    String? priceQuality,
    String? priceConfidence,
    bool? isPriceStale,
    DateTime? priceAsOf = const _is.$UndefinedDateTime(),
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
      if (priceQuality != null) 'priceQuality': priceQuality,
      if (priceConfidence != null) 'priceConfidence': priceConfidence,
      if (isPriceStale != null) 'isPriceStale': isPriceStale,
      if (priceAsOf != null) 'priceAsOf': priceAsOf?.toJson(),
      if (metadataJson != null) 'metadataJson': metadataJson,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
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
      if (priceQuality != null) 'priceQuality': priceQuality,
      if (priceConfidence != null) 'priceConfidence': priceConfidence,
      if (isPriceStale != null) 'isPriceStale': isPriceStale,
      if (priceAsOf != null) 'priceAsOf': priceAsOf?.toJson(),
      if (metadataJson != null) 'metadataJson': metadataJson,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static SolanaWalletHoldingInclude include() {
    return SolanaWalletHoldingInclude._();
  }

  static SolanaWalletHoldingIncludeList includeList({
    _is.WhereExpressionBuilder<SolanaWalletHoldingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SolanaWalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletHoldingTable>? orderByList,
    SolanaWalletHoldingInclude? include,
  }) {
    return SolanaWalletHoldingIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaWalletHolding.t),
      orderByList: orderByList?.call(SolanaWalletHolding.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SolanaWalletHoldingImpl extends SolanaWalletHolding {
  _SolanaWalletHoldingImpl({
    _is.UuidValue? id,
    required _is.UuidValue walletId,
    required _is.UuidValue budgetId,
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
    String? priceQuality,
    String? priceConfidence,
    bool? isPriceStale,
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
         priceQuality: priceQuality,
         priceConfidence: priceConfidence,
         isPriceStale: isPriceStale,
         priceAsOf: priceAsOf,
         metadataJson: metadataJson,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [SolanaWalletHolding]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SolanaWalletHolding copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? walletId,
    _is.UuidValue? budgetId,
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
    DateTime? pnlAsOf = const _is.$UndefinedDateTime(),
    Object? priceSource = _Undefined,
    Object? priceQuality = _Undefined,
    Object? priceConfidence = _Undefined,
    Object? isPriceStale = _Undefined,
    DateTime? priceAsOf = const _is.$UndefinedDateTime(),
    Object? metadataJson = _Undefined,
    DateTime? updatedAt,
  }) {
    return SolanaWalletHolding(
      id: id is _is.UndefinedSentinel ? this.id : id,
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
      pnlAsOf: pnlAsOf is _is.UndefinedSentinel ? this.pnlAsOf : pnlAsOf,
      priceSource: priceSource is String? ? priceSource : this.priceSource,
      priceQuality: priceQuality is String? ? priceQuality : this.priceQuality,
      priceConfidence: priceConfidence is String?
          ? priceConfidence
          : this.priceConfidence,
      isPriceStale: isPriceStale is bool? ? isPriceStale : this.isPriceStale,
      priceAsOf: priceAsOf is _is.UndefinedSentinel
          ? this.priceAsOf
          : priceAsOf,
      metadataJson: metadataJson is String? ? metadataJson : this.metadataJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SolanaWalletHoldingUpdateTable
    extends _is.UpdateTable<SolanaWalletHoldingTable> {
  SolanaWalletHoldingUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> walletId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.walletId,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> budgetId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.budgetId,
        value,
      );

  _is.ColumnValue<String, String> assetId(String value) => _is.ColumnValue(
    table.assetId,
    value,
  );

  _is.ColumnValue<String, String> symbol(String? value) => _is.ColumnValue(
    table.symbol,
    value,
  );

  _is.ColumnValue<String, String> name(String? value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> tokenProgram(String? value) =>
      _is.ColumnValue(
        table.tokenProgram,
        value,
      );

  _is.ColumnValue<int, int> decimals(int value) => _is.ColumnValue(
    table.decimals,
    value,
  );

  _is.ColumnValue<String, String> balanceRaw(String value) => _is.ColumnValue(
    table.balanceRaw,
    value,
  );

  _is.ColumnValue<String, String> balanceUi(String value) => _is.ColumnValue(
    table.balanceUi,
    value,
  );

  _is.ColumnValue<bool, bool> isNft(bool value) => _is.ColumnValue(
    table.isNft,
    value,
  );

  _is.ColumnValue<String, String> priceCurrency(String? value) =>
      _is.ColumnValue(
        table.priceCurrency,
        value,
      );

  _is.ColumnValue<double, double> pricePerToken(double? value) =>
      _is.ColumnValue(
        table.pricePerToken,
        value,
      );

  _is.ColumnValue<double, double> totalValue(double? value) => _is.ColumnValue(
    table.totalValue,
    value,
  );

  _is.ColumnValue<double, double> estimatedCostBasis(double? value) =>
      _is.ColumnValue(
        table.estimatedCostBasis,
        value,
      );

  _is.ColumnValue<double, double> estimatedUnrealizedPnl(double? value) =>
      _is.ColumnValue(
        table.estimatedUnrealizedPnl,
        value,
      );

  _is.ColumnValue<double, double> estimatedUnrealizedPnlPercent(
    double? value,
  ) => _is.ColumnValue(
    table.estimatedUnrealizedPnlPercent,
    value,
  );

  _is.ColumnValue<double, double> estimatedRealizedPnl(double? value) =>
      _is.ColumnValue(
        table.estimatedRealizedPnl,
        value,
      );

  _is.ColumnValue<String, String> pnlCurrency(String? value) => _is.ColumnValue(
    table.pnlCurrency,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> pnlAsOf(DateTime? value) =>
      _is.ColumnValue(
        table.pnlAsOf,
        value,
      );

  _is.ColumnValue<String, String> priceSource(String? value) => _is.ColumnValue(
    table.priceSource,
    value,
  );

  _is.ColumnValue<String, String> priceQuality(String? value) =>
      _is.ColumnValue(
        table.priceQuality,
        value,
      );

  _is.ColumnValue<String, String> priceConfidence(String? value) =>
      _is.ColumnValue(
        table.priceConfidence,
        value,
      );

  _is.ColumnValue<bool, bool> isPriceStale(bool? value) => _is.ColumnValue(
    table.isPriceStale,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> priceAsOf(DateTime? value) =>
      _is.ColumnValue(
        table.priceAsOf,
        value,
      );

  _is.ColumnValue<String, String> metadataJson(String? value) =>
      _is.ColumnValue(
        table.metadataJson,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _is.ColumnValue(
        table.updatedAt,
        value,
      );
}

class SolanaWalletHoldingTable extends _is.Table<_is.UuidValue?> {
  SolanaWalletHoldingTable({super.tableRelation})
    : super(tableName: 'solana_wallet_holding') {
    updateTable = SolanaWalletHoldingUpdateTable(this);
    walletId = _is.ColumnUuid(
      'walletId',
      this,
    );
    budgetId = _is.ColumnUuid(
      'budgetId',
      this,
    );
    assetId = _is.ColumnString(
      'assetId',
      this,
    );
    symbol = _is.ColumnString(
      'symbol',
      this,
    );
    name = _is.ColumnString(
      'name',
      this,
    );
    tokenProgram = _is.ColumnString(
      'tokenProgram',
      this,
    );
    decimals = _is.ColumnInt(
      'decimals',
      this,
    );
    balanceRaw = _is.ColumnString(
      'balanceRaw',
      this,
    );
    balanceUi = _is.ColumnString(
      'balanceUi',
      this,
    );
    isNft = _is.ColumnBool(
      'isNft',
      this,
    );
    priceCurrency = _is.ColumnString(
      'priceCurrency',
      this,
    );
    pricePerToken = _is.ColumnDouble(
      'pricePerToken',
      this,
    );
    totalValue = _is.ColumnDouble(
      'totalValue',
      this,
    );
    estimatedCostBasis = _is.ColumnDouble(
      'estimatedCostBasis',
      this,
    );
    estimatedUnrealizedPnl = _is.ColumnDouble(
      'estimatedUnrealizedPnl',
      this,
    );
    estimatedUnrealizedPnlPercent = _is.ColumnDouble(
      'estimatedUnrealizedPnlPercent',
      this,
    );
    estimatedRealizedPnl = _is.ColumnDouble(
      'estimatedRealizedPnl',
      this,
    );
    pnlCurrency = _is.ColumnString(
      'pnlCurrency',
      this,
    );
    pnlAsOf = _is.ColumnDateTime(
      'pnlAsOf',
      this,
    );
    priceSource = _is.ColumnString(
      'priceSource',
      this,
    );
    priceQuality = _is.ColumnString(
      'priceQuality',
      this,
    );
    priceConfidence = _is.ColumnString(
      'priceConfidence',
      this,
    );
    isPriceStale = _is.ColumnBool(
      'isPriceStale',
      this,
    );
    priceAsOf = _is.ColumnDateTime(
      'priceAsOf',
      this,
    );
    metadataJson = _is.ColumnString(
      'metadataJson',
      this,
    );
    updatedAt = _is.ColumnDateTime(
      'updatedAt',
      this,
      hasDefault: true,
    );
  }

  late final SolanaWalletHoldingUpdateTable updateTable;

  late final _is.ColumnUuid walletId;

  late final _is.ColumnUuid budgetId;

  /// Asset identifier (mint address for fungible tokens / NFT ID).
  late final _is.ColumnString assetId;

  late final _is.ColumnString symbol;

  late final _is.ColumnString name;

  /// Token program identifier (e.g. Tokenkeg..., TokenzQd...).
  late final _is.ColumnString tokenProgram;

  late final _is.ColumnInt decimals;

  /// Raw integer amount in base units.
  late final _is.ColumnString balanceRaw;

  /// Decimal amount as a string for display.
  late final _is.ColumnString balanceUi;

  late final _is.ColumnBool isNft;

  /// Quote currency for valuation (for now typically USD).
  late final _is.ColumnString priceCurrency;

  late final _is.ColumnDouble pricePerToken;

  late final _is.ColumnDouble totalValue;

  /// Estimated aggregate acquisition basis in quote currency.
  late final _is.ColumnDouble estimatedCostBasis;

  /// Estimated unrealized gain/loss in quote currency.
  late final _is.ColumnDouble estimatedUnrealizedPnl;

  /// Estimated unrealized gain/loss percentage.
  late final _is.ColumnDouble estimatedUnrealizedPnlPercent;

  /// Estimated realized gain/loss accumulated for this asset.
  late final _is.ColumnDouble estimatedRealizedPnl;

  /// Quote currency used for estimated P&L values.
  late final _is.ColumnString pnlCurrency;

  /// Timestamp for the last P&L estimate update.
  late final _is.ColumnDateTime pnlAsOf;

  late final _is.ColumnString priceSource;

  /// Qualitative pricing classification: provider, derived, stale_cache, unpriced.
  late final _is.ColumnString priceQuality;

  /// Confidence tier for the valuation source: high, medium, low.
  late final _is.ColumnString priceConfidence;

  /// True when valuation is using a cached fallback price.
  late final _is.ColumnBool isPriceStale;

  late final _is.ColumnDateTime priceAsOf;

  /// JSON-encoded asset metadata subset.
  late final _is.ColumnString metadataJson;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    walletId,
    budgetId,
    assetId,
    symbol,
    name,
    tokenProgram,
    decimals,
    balanceRaw,
    balanceUi,
    isNft,
    priceCurrency,
    pricePerToken,
    totalValue,
    estimatedCostBasis,
    estimatedUnrealizedPnl,
    estimatedUnrealizedPnlPercent,
    estimatedRealizedPnl,
    pnlCurrency,
    pnlAsOf,
    priceSource,
    priceQuality,
    priceConfidence,
    isPriceStale,
    priceAsOf,
    metadataJson,
    updatedAt,
  ];
}

class SolanaWalletHoldingInclude extends _is.IncludeObject {
  SolanaWalletHoldingInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => SolanaWalletHolding.t;
}

class SolanaWalletHoldingIncludeList extends _is.IncludeList {
  SolanaWalletHoldingIncludeList._({
    _is.WhereExpressionBuilder<SolanaWalletHoldingTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SolanaWalletHolding.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => SolanaWalletHolding.t;
}

class SolanaWalletHoldingRepository {
  const SolanaWalletHoldingRepository._();

  /// Returns a list of [SolanaWalletHolding]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<SolanaWalletHolding>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SolanaWalletHoldingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SolanaWalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletHoldingTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SolanaWalletHolding>(
      where: where?.call(SolanaWalletHolding.t),
      orderBy: orderBy?.call(SolanaWalletHolding.t),
      orderByList: orderByList?.call(SolanaWalletHolding.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [SolanaWalletHolding]s matching the given query parameters every time the
  /// source tables are modified.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// Use [throttle] to specify the minimum interval between queries. It can
  /// also be set to `null`, in which case the stream will only be throttled
  /// when its subscription is paused.
  ///
  /// Source tables are collected from the queried table, [where], [orderBy],
  /// [orderByList], and the [include] graph. [alsoTriggerOnTables] is added
  /// to that set. Pass [Table] instances such as `SolanaWalletHolding.t`.
  ///
  /// Raw [Expression] SQL is not inspected. Tables referenced only in raw
  /// SQL must be passed via [alsoTriggerOnTables].
  ///
  /// The stream always reads committed state and never joins an ambient
  /// [Transaction]. Emissions for a write fire after that write commits.
  ///
  /// Currently only supported on SQLite. Calling this method on PostgreSQL
  /// throws an [UnsupportedError].
  ///
  /// ```dart
  /// var subscription = Persons.db.watch(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// ).listen((persons) {
  ///   // Handle the latest matching rows.
  /// });
  /// ```
  _ida.Stream<List<SolanaWalletHolding>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SolanaWalletHoldingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SolanaWalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletHoldingTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<SolanaWalletHolding>(
      where: where?.call(SolanaWalletHolding.t),
      orderBy: orderBy?.call(SolanaWalletHolding.t),
      orderByList: orderByList?.call(SolanaWalletHolding.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [SolanaWalletHolding] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<SolanaWalletHolding?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SolanaWalletHoldingTable>? where,
    int? offset,
    _is.OrderByBuilder<SolanaWalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletHoldingTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SolanaWalletHolding>(
      where: where?.call(SolanaWalletHolding.t),
      orderBy: orderBy?.call(SolanaWalletHolding.t),
      orderByList: orderByList?.call(SolanaWalletHolding.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SolanaWalletHolding] by its [id] or null if no such row exists.
  Future<SolanaWalletHolding?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SolanaWalletHolding>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SolanaWalletHolding]s in the list and returns the inserted rows.
  ///
  /// The returned [SolanaWalletHolding]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SolanaWalletHolding>> insert(
    _is.DatabaseSession session,
    List<SolanaWalletHolding> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SolanaWalletHolding>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SolanaWalletHolding] and returns the inserted row.
  ///
  /// The returned [SolanaWalletHolding] will have its `id` field set.
  Future<SolanaWalletHolding> insertRow(
    _is.DatabaseSession session,
    SolanaWalletHolding row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SolanaWalletHolding>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SolanaWalletHolding]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [SolanaWalletHolding]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SolanaWalletHolding>> upsert(
    _is.DatabaseSession session,
    List<SolanaWalletHolding> rows, {
    required _is.ColumnSelections<SolanaWalletHoldingTable> conflictColumns,
    _is.ColumnSelections<SolanaWalletHoldingTable>? updateColumns,
    _is.WhereExpressionBuilder<SolanaWalletHoldingTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SolanaWalletHolding>(
      rows,
      conflictColumns: conflictColumns(SolanaWalletHolding.t),
      updateColumns: updateColumns?.call(SolanaWalletHolding.t),
      updateWhere: updateWhere?.call(SolanaWalletHolding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SolanaWalletHolding] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [SolanaWalletHolding] will have its `id` field set.
  Future<SolanaWalletHolding?> upsertRow(
    _is.DatabaseSession session,
    SolanaWalletHolding row, {
    required _is.ColumnSelections<SolanaWalletHoldingTable> conflictColumns,
    _is.ColumnSelections<SolanaWalletHoldingTable>? updateColumns,
    _is.WhereExpressionBuilder<SolanaWalletHoldingTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SolanaWalletHolding>(
      row,
      conflictColumns: conflictColumns(SolanaWalletHolding.t),
      updateColumns: updateColumns?.call(SolanaWalletHolding.t),
      updateWhere: updateWhere?.call(SolanaWalletHolding.t),
      transaction: transaction,
    );
  }

  /// Updates all [SolanaWalletHolding]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SolanaWalletHolding>> update(
    _is.DatabaseSession session,
    List<SolanaWalletHolding> rows, {
    _is.ColumnSelections<SolanaWalletHoldingTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SolanaWalletHolding>(
      rows,
      columns: columns?.call(SolanaWalletHolding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SolanaWalletHolding]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SolanaWalletHolding> updateRow(
    _is.DatabaseSession session,
    SolanaWalletHolding row, {
    _is.ColumnSelections<SolanaWalletHoldingTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SolanaWalletHolding>(
      row,
      columns: columns?.call(SolanaWalletHolding.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SolanaWalletHolding] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SolanaWalletHolding?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<SolanaWalletHoldingUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SolanaWalletHolding>(
      id,
      columnValues: columnValues(SolanaWalletHolding.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SolanaWalletHolding]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SolanaWalletHolding>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SolanaWalletHoldingUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<SolanaWalletHoldingTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SolanaWalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletHoldingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SolanaWalletHolding>(
      columnValues: columnValues(SolanaWalletHolding.t.updateTable),
      where: where(SolanaWalletHolding.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaWalletHolding.t),
      orderByList: orderByList?.call(SolanaWalletHolding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SolanaWalletHolding]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SolanaWalletHolding>> delete(
    _is.DatabaseSession session,
    List<SolanaWalletHolding> rows, {
    _is.OrderByBuilder<SolanaWalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletHoldingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SolanaWalletHolding>(
      rows,
      orderBy: orderBy?.call(SolanaWalletHolding.t),
      orderByList: orderByList?.call(SolanaWalletHolding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SolanaWalletHolding].
  Future<SolanaWalletHolding> deleteRow(
    _is.DatabaseSession session,
    SolanaWalletHolding row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SolanaWalletHolding>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SolanaWalletHolding>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SolanaWalletHoldingTable> where,
    _is.OrderByBuilder<SolanaWalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<SolanaWalletHoldingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SolanaWalletHolding>(
      where: where(SolanaWalletHolding.t),
      orderBy: orderBy?.call(SolanaWalletHolding.t),
      orderByList: orderByList?.call(SolanaWalletHolding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SolanaWalletHoldingTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SolanaWalletHolding>(
      where: where?.call(SolanaWalletHolding.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SolanaWalletHolding] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SolanaWalletHoldingTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SolanaWalletHolding>(
      where: where(SolanaWalletHolding.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
