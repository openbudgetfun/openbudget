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
import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:openbudget_server/src/generated/protocol.dart' as _is0sbm8r;
import 'package:serverpod/serverpod.dart' as _is;

/// One slice of an entity's crypto value, in the reporting currency.
abstract class CryptoBreakdownRow
    implements _is.SerializableModel, _is.ProtocolSerialization {
  CryptoBreakdownRow._({
    required this.key,
    required this.networks,
    this.symbol,
    this.name,
    this.assetId,
    required this.isOther,
    required this.holdingCount,
    required this.valueMinor,
    required this.shareBasisPoints,
  });

  factory CryptoBreakdownRow({
    required String key,
    required List<_ifz8weqz.WalletNetwork> networks,
    String? symbol,
    String? name,
    String? assetId,
    required bool isOther,
    required int holdingCount,
    required int valueMinor,
    required int shareBasisPoints,
  }) = _CryptoBreakdownRowImpl;

  factory CryptoBreakdownRow.fromJson(Map<String, dynamic> jsonSerialization) {
    return CryptoBreakdownRow(
      key: jsonSerialization['key'] as String,
      networks: _is0sbm8r.Protocol().deserialize<List<_ifz8weqz.WalletNetwork>>(
        jsonSerialization['networks'],
      ),
      symbol: jsonSerialization['symbol'] as String?,
      name: jsonSerialization['name'] as String?,
      assetId: jsonSerialization['assetId'] as String?,
      isOther: _is.BoolJsonExtension.fromJson(jsonSerialization['isOther']),
      holdingCount: jsonSerialization['holdingCount'] as int,
      valueMinor: jsonSerialization['valueMinor'] as int,
      shareBasisPoints: jsonSerialization['shareBasisPoints'] as int,
    );
  }

  /// Stable id of the slice within one view: the network name for `byChain`,
  /// `asset:<symbol>` for a merged canonical asset, `<network>:<assetId>` for
  /// any other token, and `other` for the remainder.
  String key;

  /// The networks that contribute to the slice: one for a chain row and for
  /// an unmerged token, several for a merged asset, and every network behind
  /// an "Other" row.
  List<_ifz8weqz.WalletNetwork> networks;

  /// The asset's ticker. Null for chain rows and the "Other" row.
  String? symbol;

  /// The asset's name. Null for chain rows and the "Other" row.
  String? name;

  /// The token's id on its network, for an unmerged token only, so two
  /// tokens that share a ticker stay apart.
  String? assetId;

  /// True for the remainder row after the top eight assets.
  bool isOther;

  /// How many holdings fed the slice.
  int holdingCount;

  /// The slice's value in the reporting currency's minor units.
  int valueMinor;

  /// The slice's share of the view's total, in basis points (1/100 of a
  /// percent). The shares of one view add up to exactly 10000.
  int shareBasisPoints;

  /// Returns a shallow copy of this [CryptoBreakdownRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  CryptoBreakdownRow copyWith({
    String? key,
    List<_ifz8weqz.WalletNetwork>? networks,
    String? symbol,
    String? name,
    String? assetId,
    bool? isOther,
    int? holdingCount,
    int? valueMinor,
    int? shareBasisPoints,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CryptoBreakdownRow',
      'key': key,
      'networks': networks.toJson(valueToJson: (v) => v.toJson()),
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (assetId != null) 'assetId': assetId,
      'isOther': isOther,
      'holdingCount': holdingCount,
      'valueMinor': valueMinor,
      'shareBasisPoints': shareBasisPoints,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CryptoBreakdownRow',
      'key': key,
      'networks': networks.toJson(valueToJson: (v) => v.toJson()),
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (assetId != null) 'assetId': assetId,
      'isOther': isOther,
      'holdingCount': holdingCount,
      'valueMinor': valueMinor,
      'shareBasisPoints': shareBasisPoints,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CryptoBreakdownRowImpl extends CryptoBreakdownRow {
  _CryptoBreakdownRowImpl({
    required String key,
    required List<_ifz8weqz.WalletNetwork> networks,
    String? symbol,
    String? name,
    String? assetId,
    required bool isOther,
    required int holdingCount,
    required int valueMinor,
    required int shareBasisPoints,
  }) : super._(
         key: key,
         networks: networks,
         symbol: symbol,
         name: name,
         assetId: assetId,
         isOther: isOther,
         holdingCount: holdingCount,
         valueMinor: valueMinor,
         shareBasisPoints: shareBasisPoints,
       );

  /// Returns a shallow copy of this [CryptoBreakdownRow]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  CryptoBreakdownRow copyWith({
    String? key,
    List<_ifz8weqz.WalletNetwork>? networks,
    Object? symbol = _Undefined,
    Object? name = _Undefined,
    Object? assetId = _Undefined,
    bool? isOther,
    int? holdingCount,
    int? valueMinor,
    int? shareBasisPoints,
  }) {
    return CryptoBreakdownRow(
      key: key ?? this.key,
      networks: networks ?? this.networks.map((e0) => e0).toList(),
      symbol: symbol is String? ? symbol : this.symbol,
      name: name is String? ? name : this.name,
      assetId: assetId is String? ? assetId : this.assetId,
      isOther: isOther ?? this.isOther,
      holdingCount: holdingCount ?? this.holdingCount,
      valueMinor: valueMinor ?? this.valueMinor,
      shareBasisPoints: shareBasisPoints ?? this.shareBasisPoints,
    );
  }
}
