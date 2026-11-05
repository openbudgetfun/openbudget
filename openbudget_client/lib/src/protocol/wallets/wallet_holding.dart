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

/// Native-asset holding for a wallet connection.
abstract class WalletHolding
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WalletHolding._({
    this.id,
    required this.walletConnectionId,
    required this.chain,
    required this.assetId,
    required this.symbol,
    required this.decimals,
    required this.quantityBaseUnits,
    required this.quantityDisplay,
    this.usdPrice,
    this.usdValue,
    DateTime? lastSyncedAt,
  }) : lastSyncedAt = lastSyncedAt ?? DateTime.now();

  factory WalletHolding({
    _isc.UuidValue? id,
    required _isc.UuidValue walletConnectionId,
    required String chain,
    required String assetId,
    required String symbol,
    required int decimals,
    required String quantityBaseUnits,
    required double quantityDisplay,
    double? usdPrice,
    double? usdValue,
    DateTime? lastSyncedAt,
  }) = _WalletHoldingImpl;

  factory WalletHolding.fromJson(Map<String, dynamic> jsonSerialization) {
    return WalletHolding(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      walletConnectionId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletConnectionId'],
      ),
      chain: jsonSerialization['chain'] as String,
      assetId: jsonSerialization['assetId'] as String,
      symbol: jsonSerialization['symbol'] as String,
      decimals: jsonSerialization['decimals'] as int,
      quantityBaseUnits: jsonSerialization['quantityBaseUnits'] as String,
      quantityDisplay: (jsonSerialization['quantityDisplay'] as num).toDouble(),
      usdPrice: (jsonSerialization['usdPrice'] as num?)?.toDouble(),
      usdValue: (jsonSerialization['usdValue'] as num?)?.toDouble(),
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue walletConnectionId;

  String chain;

  String assetId;

  String symbol;

  int decimals;

  String quantityBaseUnits;

  double quantityDisplay;

  double? usdPrice;

  double? usdValue;

  DateTime lastSyncedAt;

  /// Returns a shallow copy of this [WalletHolding]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WalletHolding copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? walletConnectionId,
    String? chain,
    String? assetId,
    String? symbol,
    int? decimals,
    String? quantityBaseUnits,
    double? quantityDisplay,
    double? usdPrice,
    double? usdValue,
    DateTime? lastSyncedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletHolding',
      if (id != null) 'id': id?.toJson(),
      'walletConnectionId': walletConnectionId.toJson(),
      'chain': chain,
      'assetId': assetId,
      'symbol': symbol,
      'decimals': decimals,
      'quantityBaseUnits': quantityBaseUnits,
      'quantityDisplay': quantityDisplay,
      if (usdPrice != null) 'usdPrice': usdPrice,
      if (usdValue != null) 'usdValue': usdValue,
      'lastSyncedAt': lastSyncedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WalletHolding',
      if (id != null) 'id': id?.toJson(),
      'walletConnectionId': walletConnectionId.toJson(),
      'chain': chain,
      'assetId': assetId,
      'symbol': symbol,
      'decimals': decimals,
      'quantityBaseUnits': quantityBaseUnits,
      'quantityDisplay': quantityDisplay,
      if (usdPrice != null) 'usdPrice': usdPrice,
      if (usdValue != null) 'usdValue': usdValue,
      'lastSyncedAt': lastSyncedAt.toJson(),
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
    required _isc.UuidValue walletConnectionId,
    required String chain,
    required String assetId,
    required String symbol,
    required int decimals,
    required String quantityBaseUnits,
    required double quantityDisplay,
    double? usdPrice,
    double? usdValue,
    DateTime? lastSyncedAt,
  }) : super._(
         id: id,
         walletConnectionId: walletConnectionId,
         chain: chain,
         assetId: assetId,
         symbol: symbol,
         decimals: decimals,
         quantityBaseUnits: quantityBaseUnits,
         quantityDisplay: quantityDisplay,
         usdPrice: usdPrice,
         usdValue: usdValue,
         lastSyncedAt: lastSyncedAt,
       );

  /// Returns a shallow copy of this [WalletHolding]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WalletHolding copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? walletConnectionId,
    String? chain,
    String? assetId,
    String? symbol,
    int? decimals,
    String? quantityBaseUnits,
    double? quantityDisplay,
    Object? usdPrice = _Undefined,
    Object? usdValue = _Undefined,
    DateTime? lastSyncedAt,
  }) {
    return WalletHolding(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      walletConnectionId: walletConnectionId ?? this.walletConnectionId,
      chain: chain ?? this.chain,
      assetId: assetId ?? this.assetId,
      symbol: symbol ?? this.symbol,
      decimals: decimals ?? this.decimals,
      quantityBaseUnits: quantityBaseUnits ?? this.quantityBaseUnits,
      quantityDisplay: quantityDisplay ?? this.quantityDisplay,
      usdPrice: usdPrice is double? ? usdPrice : this.usdPrice,
      usdValue: usdValue is double? ? usdValue : this.usdValue,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}
