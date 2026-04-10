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
import 'package:serverpod/serverpod.dart' as _i1;

/// Current holding state for an asset in a Solana wallet.
abstract class SolanaWalletHolding
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
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
      isNft: _i1.BoolJsonExtension.fromJson(jsonSerialization['isNft']),
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
      priceQuality: jsonSerialization['priceQuality'] as String?,
      priceConfidence: jsonSerialization['priceConfidence'] as String?,
      isPriceStale: jsonSerialization['isPriceStale'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isPriceStale']),
      priceAsOf: jsonSerialization['priceAsOf'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['priceAsOf']),
      metadataJson: jsonSerialization['metadataJson'] as String?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = SolanaWalletHoldingTable();

  static const db = SolanaWalletHoldingRepository._();

  @override
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
  _i1.Table<_i1.UuidValue?> get table => t;

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
    String? priceQuality,
    String? priceConfidence,
    bool? isPriceStale,
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
    _i1.WhereExpressionBuilder<SolanaWalletHoldingTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletHoldingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SolanaWalletHoldingTable>? orderByList,
    SolanaWalletHoldingInclude? include,
  }) {
    return SolanaWalletHoldingIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaWalletHolding.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(SolanaWalletHolding.t),
      include: include,
    );
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
    Object? priceQuality = _Undefined,
    Object? priceConfidence = _Undefined,
    Object? isPriceStale = _Undefined,
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
      priceQuality: priceQuality is String? ? priceQuality : this.priceQuality,
      priceConfidence: priceConfidence is String?
          ? priceConfidence
          : this.priceConfidence,
      isPriceStale: isPriceStale is bool? ? isPriceStale : this.isPriceStale,
      priceAsOf: priceAsOf is DateTime? ? priceAsOf : this.priceAsOf,
      metadataJson: metadataJson is String? ? metadataJson : this.metadataJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class SolanaWalletHoldingUpdateTable
    extends _i1.UpdateTable<SolanaWalletHoldingTable> {
  SolanaWalletHoldingUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> walletId(_i1.UuidValue value) =>
      _i1.ColumnValue(table.walletId, value);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> budgetId(_i1.UuidValue value) =>
      _i1.ColumnValue(table.budgetId, value);

  _i1.ColumnValue<String, String> assetId(String value) =>
      _i1.ColumnValue(table.assetId, value);

  _i1.ColumnValue<String, String> symbol(String? value) =>
      _i1.ColumnValue(table.symbol, value);

  _i1.ColumnValue<String, String> name(String? value) =>
      _i1.ColumnValue(table.name, value);

  _i1.ColumnValue<String, String> tokenProgram(String? value) =>
      _i1.ColumnValue(table.tokenProgram, value);

  _i1.ColumnValue<int, int> decimals(int value) =>
      _i1.ColumnValue(table.decimals, value);

  _i1.ColumnValue<String, String> balanceRaw(String value) =>
      _i1.ColumnValue(table.balanceRaw, value);

  _i1.ColumnValue<String, String> balanceUi(String value) =>
      _i1.ColumnValue(table.balanceUi, value);

  _i1.ColumnValue<bool, bool> isNft(bool value) =>
      _i1.ColumnValue(table.isNft, value);

  _i1.ColumnValue<String, String> priceCurrency(String? value) =>
      _i1.ColumnValue(table.priceCurrency, value);

  _i1.ColumnValue<double, double> pricePerToken(double? value) =>
      _i1.ColumnValue(table.pricePerToken, value);

  _i1.ColumnValue<double, double> totalValue(double? value) =>
      _i1.ColumnValue(table.totalValue, value);

  _i1.ColumnValue<double, double> estimatedCostBasis(double? value) =>
      _i1.ColumnValue(table.estimatedCostBasis, value);

  _i1.ColumnValue<double, double> estimatedUnrealizedPnl(double? value) =>
      _i1.ColumnValue(table.estimatedUnrealizedPnl, value);

  _i1.ColumnValue<double, double> estimatedUnrealizedPnlPercent(
    double? value,
  ) => _i1.ColumnValue(table.estimatedUnrealizedPnlPercent, value);

  _i1.ColumnValue<double, double> estimatedRealizedPnl(double? value) =>
      _i1.ColumnValue(table.estimatedRealizedPnl, value);

  _i1.ColumnValue<String, String> pnlCurrency(String? value) =>
      _i1.ColumnValue(table.pnlCurrency, value);

  _i1.ColumnValue<DateTime, DateTime> pnlAsOf(DateTime? value) =>
      _i1.ColumnValue(table.pnlAsOf, value);

  _i1.ColumnValue<String, String> priceSource(String? value) =>
      _i1.ColumnValue(table.priceSource, value);

  _i1.ColumnValue<String, String> priceQuality(String? value) =>
      _i1.ColumnValue(table.priceQuality, value);

  _i1.ColumnValue<String, String> priceConfidence(String? value) =>
      _i1.ColumnValue(table.priceConfidence, value);

  _i1.ColumnValue<bool, bool> isPriceStale(bool? value) =>
      _i1.ColumnValue(table.isPriceStale, value);

  _i1.ColumnValue<DateTime, DateTime> priceAsOf(DateTime? value) =>
      _i1.ColumnValue(table.priceAsOf, value);

  _i1.ColumnValue<String, String> metadataJson(String? value) =>
      _i1.ColumnValue(table.metadataJson, value);

  _i1.ColumnValue<DateTime, DateTime> updatedAt(DateTime value) =>
      _i1.ColumnValue(table.updatedAt, value);
}

class SolanaWalletHoldingTable extends _i1.Table<_i1.UuidValue?> {
  SolanaWalletHoldingTable({super.tableRelation})
    : super(tableName: 'solana_wallet_holding') {
    updateTable = SolanaWalletHoldingUpdateTable(this);
    walletId = _i1.ColumnUuid('walletId', this);
    budgetId = _i1.ColumnUuid('budgetId', this);
    assetId = _i1.ColumnString('assetId', this);
    symbol = _i1.ColumnString('symbol', this);
    name = _i1.ColumnString('name', this);
    tokenProgram = _i1.ColumnString('tokenProgram', this);
    decimals = _i1.ColumnInt('decimals', this);
    balanceRaw = _i1.ColumnString('balanceRaw', this);
    balanceUi = _i1.ColumnString('balanceUi', this);
    isNft = _i1.ColumnBool('isNft', this);
    priceCurrency = _i1.ColumnString('priceCurrency', this);
    pricePerToken = _i1.ColumnDouble('pricePerToken', this);
    totalValue = _i1.ColumnDouble('totalValue', this);
    estimatedCostBasis = _i1.ColumnDouble('estimatedCostBasis', this);
    estimatedUnrealizedPnl = _i1.ColumnDouble('estimatedUnrealizedPnl', this);
    estimatedUnrealizedPnlPercent = _i1.ColumnDouble(
      'estimatedUnrealizedPnlPercent',
      this,
    );
    estimatedRealizedPnl = _i1.ColumnDouble('estimatedRealizedPnl', this);
    pnlCurrency = _i1.ColumnString('pnlCurrency', this);
    pnlAsOf = _i1.ColumnDateTime('pnlAsOf', this);
    priceSource = _i1.ColumnString('priceSource', this);
    priceQuality = _i1.ColumnString('priceQuality', this);
    priceConfidence = _i1.ColumnString('priceConfidence', this);
    isPriceStale = _i1.ColumnBool('isPriceStale', this);
    priceAsOf = _i1.ColumnDateTime('priceAsOf', this);
    metadataJson = _i1.ColumnString('metadataJson', this);
    updatedAt = _i1.ColumnDateTime('updatedAt', this, hasDefault: true);
  }

  late final SolanaWalletHoldingUpdateTable updateTable;

  late final _i1.ColumnUuid walletId;

  late final _i1.ColumnUuid budgetId;

  /// Asset identifier (mint address for fungible tokens / NFT ID).
  late final _i1.ColumnString assetId;

  late final _i1.ColumnString symbol;

  late final _i1.ColumnString name;

  /// Token program identifier (e.g. Tokenkeg..., TokenzQd...).
  late final _i1.ColumnString tokenProgram;

  late final _i1.ColumnInt decimals;

  /// Raw integer amount in base units.
  late final _i1.ColumnString balanceRaw;

  /// Decimal amount as a string for display.
  late final _i1.ColumnString balanceUi;

  late final _i1.ColumnBool isNft;

  /// Quote currency for valuation (for now typically USD).
  late final _i1.ColumnString priceCurrency;

  late final _i1.ColumnDouble pricePerToken;

  late final _i1.ColumnDouble totalValue;

  /// Estimated aggregate acquisition basis in quote currency.
  late final _i1.ColumnDouble estimatedCostBasis;

  /// Estimated unrealized gain/loss in quote currency.
  late final _i1.ColumnDouble estimatedUnrealizedPnl;

  /// Estimated unrealized gain/loss percentage.
  late final _i1.ColumnDouble estimatedUnrealizedPnlPercent;

  /// Estimated realized gain/loss accumulated for this asset.
  late final _i1.ColumnDouble estimatedRealizedPnl;

  /// Quote currency used for estimated P&L values.
  late final _i1.ColumnString pnlCurrency;

  /// Timestamp for the last P&L estimate update.
  late final _i1.ColumnDateTime pnlAsOf;

  late final _i1.ColumnString priceSource;

  /// Qualitative pricing classification: provider, derived, stale_cache, unpriced.
  late final _i1.ColumnString priceQuality;

  /// Confidence tier for the valuation source: high, medium, low.
  late final _i1.ColumnString priceConfidence;

  /// True when valuation is using a cached fallback price.
  late final _i1.ColumnBool isPriceStale;

  late final _i1.ColumnDateTime priceAsOf;

  /// JSON-encoded asset metadata subset.
  late final _i1.ColumnString metadataJson;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
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

class SolanaWalletHoldingInclude extends _i1.IncludeObject {
  SolanaWalletHoldingInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SolanaWalletHolding.t;
}

class SolanaWalletHoldingIncludeList extends _i1.IncludeList {
  SolanaWalletHoldingIncludeList._({
    _i1.WhereExpressionBuilder<SolanaWalletHoldingTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SolanaWalletHolding.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SolanaWalletHolding.t;
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
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SolanaWalletHoldingTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletHoldingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SolanaWalletHoldingTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SolanaWalletHolding>(
      where: where?.call(SolanaWalletHolding.t),
      orderBy: orderBy?.call(SolanaWalletHolding.t),
      orderByList: orderByList?.call(SolanaWalletHolding.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
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
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SolanaWalletHoldingTable>? where,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletHoldingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SolanaWalletHoldingTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SolanaWalletHolding>(
      where: where?.call(SolanaWalletHolding.t),
      orderBy: orderBy?.call(SolanaWalletHolding.t),
      orderByList: orderByList?.call(SolanaWalletHolding.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SolanaWalletHolding] by its [id] or null if no such row exists.
  Future<SolanaWalletHolding?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
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
  Future<List<SolanaWalletHolding>> insert(
    _i1.DatabaseSession session,
    List<SolanaWalletHolding> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<SolanaWalletHolding>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [SolanaWalletHolding] and returns the inserted row.
  ///
  /// The returned [SolanaWalletHolding] will have its `id` field set.
  Future<SolanaWalletHolding> insertRow(
    _i1.DatabaseSession session,
    SolanaWalletHolding row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<SolanaWalletHolding>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [SolanaWalletHolding]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<SolanaWalletHolding>> update(
    _i1.DatabaseSession session,
    List<SolanaWalletHolding> rows, {
    _i1.ColumnSelections<SolanaWalletHoldingTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<SolanaWalletHolding>(
      rows,
      columns: columns?.call(SolanaWalletHolding.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SolanaWalletHolding]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SolanaWalletHolding> updateRow(
    _i1.DatabaseSession session,
    SolanaWalletHolding row, {
    _i1.ColumnSelections<SolanaWalletHoldingTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<SolanaWalletHoldingUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<SolanaWalletHolding>(
      id,
      columnValues: columnValues(SolanaWalletHolding.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SolanaWalletHolding]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<SolanaWalletHolding>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<SolanaWalletHoldingUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<SolanaWalletHoldingTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SolanaWalletHoldingTable>? orderBy,
    _i1.OrderByListBuilder<SolanaWalletHoldingTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<SolanaWalletHolding>(
      columnValues: columnValues(SolanaWalletHolding.t.updateTable),
      where: where(SolanaWalletHolding.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SolanaWalletHolding.t),
      orderByList: orderByList?.call(SolanaWalletHolding.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [SolanaWalletHolding]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<SolanaWalletHolding>> delete(
    _i1.DatabaseSession session,
    List<SolanaWalletHolding> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<SolanaWalletHolding>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [SolanaWalletHolding].
  Future<SolanaWalletHolding> deleteRow(
    _i1.DatabaseSession session,
    SolanaWalletHolding row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SolanaWalletHolding>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<SolanaWalletHolding>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SolanaWalletHoldingTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<SolanaWalletHolding>(
      where: where(SolanaWalletHolding.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SolanaWalletHoldingTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<SolanaWalletHolding>(
      where: where?.call(SolanaWalletHolding.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SolanaWalletHolding] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SolanaWalletHoldingTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SolanaWalletHolding>(
      where: where(SolanaWalletHolding.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
