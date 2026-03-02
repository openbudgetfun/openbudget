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

/// Cached USD quote for a blockchain asset.
abstract class AssetQuoteCache implements _i1.SerializableModel {
  AssetQuoteCache._({
    this.id,
    required this.chain,
    required this.assetId,
    required this.symbol,
    required this.usdPrice,
    DateTime? fetchedAt,
    required this.expiresAt,
  }) : fetchedAt = fetchedAt ?? DateTime.now();

  factory AssetQuoteCache({
    _i1.UuidValue? id,
    required String chain,
    required String assetId,
    required String symbol,
    required double usdPrice,
    DateTime? fetchedAt,
    required DateTime expiresAt,
  }) = _AssetQuoteCacheImpl;

  factory AssetQuoteCache.fromJson(Map<String, dynamic> jsonSerialization) {
    return AssetQuoteCache(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      chain: jsonSerialization['chain'] as String,
      assetId: jsonSerialization['assetId'] as String,
      symbol: jsonSerialization['symbol'] as String,
      usdPrice: (jsonSerialization['usdPrice'] as num).toDouble(),
      fetchedAt: jsonSerialization['fetchedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['fetchedAt']),
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  String chain;

  String assetId;

  String symbol;

  double usdPrice;

  DateTime fetchedAt;

  DateTime expiresAt;

  /// Returns a shallow copy of this [AssetQuoteCache]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AssetQuoteCache copyWith({
    _i1.UuidValue? id,
    String? chain,
    String? assetId,
    String? symbol,
    double? usdPrice,
    DateTime? fetchedAt,
    DateTime? expiresAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AssetQuoteCache',
      if (id != null) 'id': id?.toJson(),
      'chain': chain,
      'assetId': assetId,
      'symbol': symbol,
      'usdPrice': usdPrice,
      'fetchedAt': fetchedAt.toJson(),
      'expiresAt': expiresAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AssetQuoteCacheImpl extends AssetQuoteCache {
  _AssetQuoteCacheImpl({
    _i1.UuidValue? id,
    required String chain,
    required String assetId,
    required String symbol,
    required double usdPrice,
    DateTime? fetchedAt,
    required DateTime expiresAt,
  }) : super._(
         id: id,
         chain: chain,
         assetId: assetId,
         symbol: symbol,
         usdPrice: usdPrice,
         fetchedAt: fetchedAt,
         expiresAt: expiresAt,
       );

  /// Returns a shallow copy of this [AssetQuoteCache]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AssetQuoteCache copyWith({
    Object? id = _Undefined,
    String? chain,
    String? assetId,
    String? symbol,
    double? usdPrice,
    DateTime? fetchedAt,
    DateTime? expiresAt,
  }) {
    return AssetQuoteCache(
      id: id is _i1.UuidValue? ? id : this.id,
      chain: chain ?? this.chain,
      assetId: assetId ?? this.assetId,
      symbol: symbol ?? this.symbol,
      usdPrice: usdPrice ?? this.usdPrice,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
