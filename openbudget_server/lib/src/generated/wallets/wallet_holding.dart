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

import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:serverpod/serverpod.dart' as _is;

import '../common/confidence.dart' as _itaosqa4;
import '../wallets/holding_position.dart' as _i33owk26;
import '../wallets/price_quality.dart' as _iy1clnxb;
import '../wallets/price_source.dart' as _ip9y7dom;
import '../wallets/spam_verdict.dart' as _ioka4inn;

/// The current quantity and valuation of one asset in a wallet, on one
/// network and in one position.
abstract class WalletHolding
    implements _is.TableRow<_is.UuidValue?>, _is.ProtocolSerialization {
  WalletHolding._({
    this.id,
    required this.walletId,
    required this.network,
    required this.assetId,
    _i33owk26.HoldingPosition? position,
    this.symbol,
    this.name,
    this.tokenProgram,
    required this.decimals,
    required this.quantityRaw,
    bool? isNft,
    _ioka4inn.SpamVerdict? spamVerdict,
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
  }) : position = position ?? _i33owk26.HoldingPosition.available,
       isNft = isNft ?? false,
       spamVerdict = spamVerdict ?? _ioka4inn.SpamVerdict.clean,
       priceQuality = priceQuality ?? _iy1clnxb.PriceQuality.unpriced,
       updatedAt = updatedAt ?? DateTime.now();

  factory WalletHolding({
    _is.UuidValue? id,
    required _is.UuidValue walletId,
    required _ifz8weqz.WalletNetwork network,
    required String assetId,
    _i33owk26.HoldingPosition? position,
    String? symbol,
    String? name,
    String? tokenProgram,
    required int decimals,
    required BigInt quantityRaw,
    bool? isNft,
    _ioka4inn.SpamVerdict? spamVerdict,
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
          : _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      walletId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletId'],
      ),
      network: _ifz8weqz.WalletNetwork.fromJson(
        (jsonSerialization['network'] as String),
      ),
      assetId: jsonSerialization['assetId'] as String,
      position: jsonSerialization['position'] == null
          ? null
          : _i33owk26.HoldingPosition.fromJson(
              (jsonSerialization['position'] as String),
            ),
      symbol: jsonSerialization['symbol'] as String?,
      name: jsonSerialization['name'] as String?,
      tokenProgram: jsonSerialization['tokenProgram'] as String?,
      decimals: jsonSerialization['decimals'] as int,
      quantityRaw: _is.BigIntJsonExtension.fromJson(
        jsonSerialization['quantityRaw'],
      ),
      isNft: jsonSerialization['isNft'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['isNft']),
      spamVerdict: jsonSerialization['spamVerdict'] == null
          ? null
          : _ioka4inn.SpamVerdict.fromJson(
              (jsonSerialization['spamVerdict'] as String),
            ),
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
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['priceAsOf']),
      costBasisMinor: jsonSerialization['costBasisMinor'] as int?,
      realizedPnlMinor: jsonSerialization['realizedPnlMinor'] as int?,
      pnlAsOf: jsonSerialization['pnlAsOf'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['pnlAsOf']),
      metadataJson: jsonSerialization['metadataJson'] as String?,
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = WalletHoldingTable();

  static const db = WalletHoldingRepository._();

  @override
  _is.UuidValue? id;

  _is.UuidValue walletId;

  /// The network the asset is on. A single-network wallet's holdings use the
  /// wallet's network.
  _ifz8weqz.WalletNetwork network;

  /// The asset on that network: `native`, or the contract, mint, coin type,
  /// jetton master or policy-and-name unit (multichain-wallets.md 7.2).
  String assetId;

  /// Spendable, staked or unclaimed. Each position of an asset is its own
  /// holding.
  _i33owk26.HoldingPosition position;

  String? symbol;

  String? name;

  /// The token standard or program: a Solana token program id, or erc20,
  /// trc20, trc10, xrplIou, jetton, cardanoNative, suiCoin or aptosFa.
  String? tokenProgram;

  int decimals;

  /// Quantity in the asset's base units (lamports, wei, satoshis, sun,
  /// drops).
  BigInt quantityRaw;

  bool isNft;

  /// Whether the holding counts toward net worth. The classifier sets clean
  /// or suspected; a user choice overrides it and survives syncs.
  _ioka4inn.SpamVerdict spamVerdict;

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

  @override
  _is.Table<_is.UuidValue?> get table => t;

  /// Returns a shallow copy of this [WalletHolding]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WalletHolding copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? walletId,
    _ifz8weqz.WalletNetwork? network,
    String? assetId,
    _i33owk26.HoldingPosition? position,
    String? symbol,
    String? name,
    String? tokenProgram,
    int? decimals,
    BigInt? quantityRaw,
    bool? isNft,
    _ioka4inn.SpamVerdict? spamVerdict,
    String? priceCurrencyCode,
    String? unitPrice,
    int? valueMinor,
    _ip9y7dom.PriceSource? priceSource,
    _iy1clnxb.PriceQuality? priceQuality,
    _itaosqa4.Confidence? priceConfidence,
    DateTime? priceAsOf = const _is.$UndefinedDateTime(),
    int? costBasisMinor,
    int? realizedPnlMinor,
    DateTime? pnlAsOf = const _is.$UndefinedDateTime(),
    String? metadataJson,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletHolding',
      if (id != null) 'id': id?.toJson(),
      'walletId': walletId.toJson(),
      'network': network.toJson(),
      'assetId': assetId,
      'position': position.toJson(),
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (tokenProgram != null) 'tokenProgram': tokenProgram,
      'decimals': decimals,
      'quantityRaw': quantityRaw.toJson(),
      'isNft': isNft,
      'spamVerdict': spamVerdict.toJson(),
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
      'network': network.toJson(),
      'assetId': assetId,
      'position': position.toJson(),
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (tokenProgram != null) 'tokenProgram': tokenProgram,
      'decimals': decimals,
      'quantityRaw': quantityRaw.toJson(),
      'isNft': isNft,
      'spamVerdict': spamVerdict.toJson(),
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

  static WalletHoldingInclude include() {
    return WalletHoldingInclude._();
  }

  static WalletHoldingIncludeList includeList({
    _is.WhereExpressionBuilder<WalletHoldingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<WalletHoldingTable>? orderByList,
    WalletHoldingInclude? include,
  }) {
    return WalletHoldingIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletHoldingImpl extends WalletHolding {
  _WalletHoldingImpl({
    _is.UuidValue? id,
    required _is.UuidValue walletId,
    required _ifz8weqz.WalletNetwork network,
    required String assetId,
    _i33owk26.HoldingPosition? position,
    String? symbol,
    String? name,
    String? tokenProgram,
    required int decimals,
    required BigInt quantityRaw,
    bool? isNft,
    _ioka4inn.SpamVerdict? spamVerdict,
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
         network: network,
         assetId: assetId,
         position: position,
         symbol: symbol,
         name: name,
         tokenProgram: tokenProgram,
         decimals: decimals,
         quantityRaw: quantityRaw,
         isNft: isNft,
         spamVerdict: spamVerdict,
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
  @_is.useResult
  @override
  WalletHolding copyWith({
    _is.UuidValue? id = const _is.$UndefinedUuidValue(),
    _is.UuidValue? walletId,
    _ifz8weqz.WalletNetwork? network,
    String? assetId,
    _i33owk26.HoldingPosition? position,
    Object? symbol = _Undefined,
    Object? name = _Undefined,
    Object? tokenProgram = _Undefined,
    int? decimals,
    BigInt? quantityRaw,
    bool? isNft,
    _ioka4inn.SpamVerdict? spamVerdict,
    Object? priceCurrencyCode = _Undefined,
    Object? unitPrice = _Undefined,
    Object? valueMinor = _Undefined,
    Object? priceSource = _Undefined,
    _iy1clnxb.PriceQuality? priceQuality,
    Object? priceConfidence = _Undefined,
    DateTime? priceAsOf = const _is.$UndefinedDateTime(),
    Object? costBasisMinor = _Undefined,
    Object? realizedPnlMinor = _Undefined,
    DateTime? pnlAsOf = const _is.$UndefinedDateTime(),
    Object? metadataJson = _Undefined,
    DateTime? updatedAt,
  }) {
    return WalletHolding(
      id: id is _is.UndefinedSentinel ? this.id : id,
      walletId: walletId ?? this.walletId,
      network: network ?? this.network,
      assetId: assetId ?? this.assetId,
      position: position ?? this.position,
      symbol: symbol is String? ? symbol : this.symbol,
      name: name is String? ? name : this.name,
      tokenProgram: tokenProgram is String? ? tokenProgram : this.tokenProgram,
      decimals: decimals ?? this.decimals,
      quantityRaw: quantityRaw ?? this.quantityRaw,
      isNft: isNft ?? this.isNft,
      spamVerdict: spamVerdict ?? this.spamVerdict,
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
      priceAsOf: priceAsOf is _is.UndefinedSentinel
          ? this.priceAsOf
          : priceAsOf,
      costBasisMinor: costBasisMinor is int?
          ? costBasisMinor
          : this.costBasisMinor,
      realizedPnlMinor: realizedPnlMinor is int?
          ? realizedPnlMinor
          : this.realizedPnlMinor,
      pnlAsOf: pnlAsOf is _is.UndefinedSentinel ? this.pnlAsOf : pnlAsOf,
      metadataJson: metadataJson is String? ? metadataJson : this.metadataJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class WalletHoldingUpdateTable extends _is.UpdateTable<WalletHoldingTable> {
  WalletHoldingUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> walletId(_is.UuidValue value) =>
      _is.ColumnValue(
        table.walletId,
        value,
      );

  _is.ColumnValue<_ifz8weqz.WalletNetwork, _ifz8weqz.WalletNetwork> network(
    _ifz8weqz.WalletNetwork value,
  ) => _is.ColumnValue(
    table.network,
    value,
  );

  _is.ColumnValue<String, String> assetId(String value) => _is.ColumnValue(
    table.assetId,
    value,
  );

  _is.ColumnValue<_i33owk26.HoldingPosition, _i33owk26.HoldingPosition>
  position(_i33owk26.HoldingPosition value) => _is.ColumnValue(
    table.position,
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

  _is.ColumnValue<BigInt, BigInt> quantityRaw(BigInt value) => _is.ColumnValue(
    table.quantityRaw,
    value,
  );

  _is.ColumnValue<bool, bool> isNft(bool value) => _is.ColumnValue(
    table.isNft,
    value,
  );

  _is.ColumnValue<_ioka4inn.SpamVerdict, _ioka4inn.SpamVerdict> spamVerdict(
    _ioka4inn.SpamVerdict value,
  ) => _is.ColumnValue(
    table.spamVerdict,
    value,
  );

  _is.ColumnValue<String, String> priceCurrencyCode(String? value) =>
      _is.ColumnValue(
        table.priceCurrencyCode,
        value,
      );

  _is.ColumnValue<String, String> unitPrice(String? value) => _is.ColumnValue(
    table.unitPrice,
    value,
  );

  _is.ColumnValue<int, int> valueMinor(int? value) => _is.ColumnValue(
    table.valueMinor,
    value,
  );

  _is.ColumnValue<_ip9y7dom.PriceSource, _ip9y7dom.PriceSource> priceSource(
    _ip9y7dom.PriceSource? value,
  ) => _is.ColumnValue(
    table.priceSource,
    value,
  );

  _is.ColumnValue<_iy1clnxb.PriceQuality, _iy1clnxb.PriceQuality> priceQuality(
    _iy1clnxb.PriceQuality value,
  ) => _is.ColumnValue(
    table.priceQuality,
    value,
  );

  _is.ColumnValue<_itaosqa4.Confidence, _itaosqa4.Confidence> priceConfidence(
    _itaosqa4.Confidence? value,
  ) => _is.ColumnValue(
    table.priceConfidence,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> priceAsOf(DateTime? value) =>
      _is.ColumnValue(
        table.priceAsOf,
        value,
      );

  _is.ColumnValue<int, int> costBasisMinor(int? value) => _is.ColumnValue(
    table.costBasisMinor,
    value,
  );

  _is.ColumnValue<int, int> realizedPnlMinor(int? value) => _is.ColumnValue(
    table.realizedPnlMinor,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> pnlAsOf(DateTime? value) =>
      _is.ColumnValue(
        table.pnlAsOf,
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

class WalletHoldingTable extends _is.Table<_is.UuidValue?> {
  WalletHoldingTable({super.tableRelation})
    : super(tableName: 'wallet_holding') {
    updateTable = WalletHoldingUpdateTable(this);
    walletId = _is.ColumnUuid(
      'walletId',
      this,
    );
    network = _is.ColumnEnum(
      'network',
      this,
      _is.EnumSerialization.byName,
    );
    assetId = _is.ColumnString(
      'assetId',
      this,
    );
    position = _is.ColumnEnum(
      'position',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
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
    quantityRaw = _is.ColumnBigInt(
      'quantityRaw',
      this,
    );
    isNft = _is.ColumnBool(
      'isNft',
      this,
      hasDefault: true,
    );
    spamVerdict = _is.ColumnEnum(
      'spamVerdict',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    priceCurrencyCode = _is.ColumnString(
      'priceCurrencyCode',
      this,
    );
    unitPrice = _is.ColumnString(
      'unitPrice',
      this,
    );
    valueMinor = _is.ColumnInt(
      'valueMinor',
      this,
    );
    priceSource = _is.ColumnEnum(
      'priceSource',
      this,
      _is.EnumSerialization.byName,
    );
    priceQuality = _is.ColumnEnum(
      'priceQuality',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    priceConfidence = _is.ColumnEnum(
      'priceConfidence',
      this,
      _is.EnumSerialization.byName,
    );
    priceAsOf = _is.ColumnDateTime(
      'priceAsOf',
      this,
    );
    costBasisMinor = _is.ColumnInt(
      'costBasisMinor',
      this,
    );
    realizedPnlMinor = _is.ColumnInt(
      'realizedPnlMinor',
      this,
    );
    pnlAsOf = _is.ColumnDateTime(
      'pnlAsOf',
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

  late final WalletHoldingUpdateTable updateTable;

  late final _is.ColumnUuid walletId;

  /// The network the asset is on. A single-network wallet's holdings use the
  /// wallet's network.
  late final _is.ColumnEnum<_ifz8weqz.WalletNetwork> network;

  /// The asset on that network: `native`, or the contract, mint, coin type,
  /// jetton master or policy-and-name unit (multichain-wallets.md 7.2).
  late final _is.ColumnString assetId;

  /// Spendable, staked or unclaimed. Each position of an asset is its own
  /// holding.
  late final _is.ColumnEnum<_i33owk26.HoldingPosition> position;

  late final _is.ColumnString symbol;

  late final _is.ColumnString name;

  /// The token standard or program: a Solana token program id, or erc20,
  /// trc20, trc10, xrplIou, jetton, cardanoNative, suiCoin or aptosFa.
  late final _is.ColumnString tokenProgram;

  late final _is.ColumnInt decimals;

  /// Quantity in the asset's base units (lamports, wei, satoshis, sun,
  /// drops).
  late final _is.ColumnBigInt quantityRaw;

  late final _is.ColumnBool isNft;

  /// Whether the holding counts toward net worth. The classifier sets clean
  /// or suspected; a user choice overrides it and survives syncs.
  late final _is.ColumnEnum<_ioka4inn.SpamVerdict> spamVerdict;

  /// ISO 4217 code that unitPrice and every *Minor field here are in.
  late final _is.ColumnString priceCurrencyCode;

  /// Price of one whole token, exact decimal string.
  late final _is.ColumnString unitPrice;

  /// Quantity times unitPrice, in priceCurrencyCode minor units, half up.
  late final _is.ColumnInt valueMinor;

  late final _is.ColumnEnum<_ip9y7dom.PriceSource> priceSource;

  late final _is.ColumnEnum<_iy1clnxb.PriceQuality> priceQuality;

  late final _is.ColumnEnum<_itaosqa4.Confidence> priceConfidence;

  late final _is.ColumnDateTime priceAsOf;

  /// Estimated acquisition cost of the current quantity.
  late final _is.ColumnInt costBasisMinor;

  /// Estimated realised gain or loss accumulated for this asset.
  late final _is.ColumnInt realizedPnlMinor;

  late final _is.ColumnDateTime pnlAsOf;

  /// JSON subset of the asset's metadata.
  late final _is.ColumnString metadataJson;

  late final _is.ColumnDateTime updatedAt;

  @override
  List<_is.Column> get columns => [
    id,
    walletId,
    network,
    assetId,
    position,
    symbol,
    name,
    tokenProgram,
    decimals,
    quantityRaw,
    isNft,
    spamVerdict,
    priceCurrencyCode,
    unitPrice,
    valueMinor,
    priceSource,
    priceQuality,
    priceConfidence,
    priceAsOf,
    costBasisMinor,
    realizedPnlMinor,
    pnlAsOf,
    metadataJson,
    updatedAt,
  ];
}

class WalletHoldingInclude extends _is.IncludeObject {
  WalletHoldingInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<_is.UuidValue?> get table => WalletHolding.t;
}

class WalletHoldingIncludeList extends _is.IncludeList {
  WalletHoldingIncludeList._({
    _is.WhereExpressionBuilder<WalletHoldingTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(WalletHolding.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<_is.UuidValue?> get table => WalletHolding.t;
}

class WalletHoldingRepository {
  const WalletHoldingRepository._();

  /// Returns a list of [WalletHolding]s matching the given query parameters.
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
  Future<List<WalletHolding>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletHoldingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<WalletHoldingTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<WalletHolding>(
      where: where?.call(WalletHolding.t),
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Emits [WalletHolding]s matching the given query parameters every time the
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
  /// to that set. Pass [Table] instances such as `WalletHolding.t`.
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
  _ida.Stream<List<WalletHolding>> watch(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletHoldingTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<WalletHoldingTable>? orderByList,
    Duration? throttle = const Duration(milliseconds: 30),
    Iterable<_is.Table>? alsoTriggerOnTables,
  }) {
    return session.db.watch<WalletHolding>(
      where: where?.call(WalletHolding.t),
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      limit: limit,
      offset: offset,
      throttle: throttle,
      alsoTriggerOnTables: alsoTriggerOnTables,
    );
  }

  /// Returns the first matching [WalletHolding] matching the given query parameters.
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
  Future<WalletHolding?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletHoldingTable>? where,
    int? offset,
    _is.OrderByBuilder<WalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<WalletHoldingTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<WalletHolding>(
      where: where?.call(WalletHolding.t),
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [WalletHolding] by its [id] or null if no such row exists.
  Future<WalletHolding?> findById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<WalletHolding>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [WalletHolding]s in the list and returns the inserted rows.
  ///
  /// The returned [WalletHolding]s will have their `id` fields set.
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
  Future<List<WalletHolding>> insert(
    _is.DatabaseSession session,
    List<WalletHolding> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<WalletHolding>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [WalletHolding] and returns the inserted row.
  ///
  /// The returned [WalletHolding] will have its `id` field set.
  Future<WalletHolding> insertRow(
    _is.DatabaseSession session,
    WalletHolding row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<WalletHolding>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [WalletHolding]s in the list and returns the resulting rows.
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
  /// The returned [WalletHolding]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WalletHolding>> upsert(
    _is.DatabaseSession session,
    List<WalletHolding> rows, {
    required _is.ColumnSelections<WalletHoldingTable> conflictColumns,
    _is.ColumnSelections<WalletHoldingTable>? updateColumns,
    _is.WhereExpressionBuilder<WalletHoldingTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<WalletHolding>(
      rows,
      conflictColumns: conflictColumns(WalletHolding.t),
      updateColumns: updateColumns?.call(WalletHolding.t),
      updateWhere: updateWhere?.call(WalletHolding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [WalletHolding] and returns the resulting row.
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
  /// The returned [WalletHolding] will have its `id` field set.
  Future<WalletHolding?> upsertRow(
    _is.DatabaseSession session,
    WalletHolding row, {
    required _is.ColumnSelections<WalletHoldingTable> conflictColumns,
    _is.ColumnSelections<WalletHoldingTable>? updateColumns,
    _is.WhereExpressionBuilder<WalletHoldingTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<WalletHolding>(
      row,
      conflictColumns: conflictColumns(WalletHolding.t),
      updateColumns: updateColumns?.call(WalletHolding.t),
      updateWhere: updateWhere?.call(WalletHolding.t),
      transaction: transaction,
    );
  }

  /// Updates all [WalletHolding]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WalletHolding>> update(
    _is.DatabaseSession session,
    List<WalletHolding> rows, {
    _is.ColumnSelections<WalletHoldingTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<WalletHolding>(
      rows,
      columns: columns?.call(WalletHolding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [WalletHolding]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<WalletHolding> updateRow(
    _is.DatabaseSession session,
    WalletHolding row, {
    _is.ColumnSelections<WalletHoldingTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<WalletHolding>(
      row,
      columns: columns?.call(WalletHolding.t),
      transaction: transaction,
    );
  }

  /// Updates a single [WalletHolding] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<WalletHolding?> updateById(
    _is.DatabaseSession session,
    _is.UuidValue id, {
    required _is.ColumnValueListBuilder<WalletHoldingUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<WalletHolding>(
      id,
      columnValues: columnValues(WalletHolding.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [WalletHolding]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<WalletHolding>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<WalletHoldingUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<WalletHoldingTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<WalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<WalletHoldingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<WalletHolding>(
      columnValues: columnValues(WalletHolding.t.updateTable),
      where: where(WalletHolding.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [WalletHolding]s in the list and returns the deleted rows.
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
  Future<List<WalletHolding>> delete(
    _is.DatabaseSession session,
    List<WalletHolding> rows, {
    _is.OrderByBuilder<WalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<WalletHoldingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<WalletHolding>(
      rows,
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [WalletHolding].
  Future<WalletHolding> deleteRow(
    _is.DatabaseSession session,
    WalletHolding row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<WalletHolding>(
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
  Future<List<WalletHolding>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WalletHoldingTable> where,
    _is.OrderByBuilder<WalletHoldingTable>? orderBy,
    _is.OrderByListBuilder<WalletHoldingTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<WalletHolding>(
      where: where(WalletHolding.t),
      orderBy: orderBy?.call(WalletHolding.t),
      orderByList: orderByList?.call(WalletHolding.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<WalletHoldingTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<WalletHolding>(
      where: where?.call(WalletHolding.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [WalletHolding] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<WalletHoldingTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<WalletHolding>(
      where: where(WalletHolding.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
