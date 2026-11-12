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
import 'package:openbudget_client/src/protocol/protocol.dart' as _irkl4crj;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// What one wallet sync did.
abstract class WalletSyncResult
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WalletSyncResult._({
    required this.walletId,
    required this.insertedTransactions,
    required this.updatedTransactions,
    required this.holdingCount,
    required this.pricedHoldingCount,
    required this.cachedHoldingCount,
    required this.unpricedHoldingCount,
    required this.nftHoldingCount,
    required this.pricedNftHoldingCount,
    required this.cachedNftHoldingCount,
    required this.unpricedNftHoldingCount,
    this.valuationCoverageRatio,
    this.totalValueMinor,
    this.valuationCurrencyCode,
    required this.syncedAt,
    required this.warnings,
  });

  factory WalletSyncResult({
    required _isc.UuidValue walletId,
    required int insertedTransactions,
    required int updatedTransactions,
    required int holdingCount,
    required int pricedHoldingCount,
    required int cachedHoldingCount,
    required int unpricedHoldingCount,
    required int nftHoldingCount,
    required int pricedNftHoldingCount,
    required int cachedNftHoldingCount,
    required int unpricedNftHoldingCount,
    double? valuationCoverageRatio,
    int? totalValueMinor,
    String? valuationCurrencyCode,
    required DateTime syncedAt,
    required List<String> warnings,
  }) = _WalletSyncResultImpl;

  factory WalletSyncResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return WalletSyncResult(
      walletId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletId'],
      ),
      insertedTransactions: jsonSerialization['insertedTransactions'] as int,
      updatedTransactions: jsonSerialization['updatedTransactions'] as int,
      holdingCount: jsonSerialization['holdingCount'] as int,
      pricedHoldingCount: jsonSerialization['pricedHoldingCount'] as int,
      cachedHoldingCount: jsonSerialization['cachedHoldingCount'] as int,
      unpricedHoldingCount: jsonSerialization['unpricedHoldingCount'] as int,
      nftHoldingCount: jsonSerialization['nftHoldingCount'] as int,
      pricedNftHoldingCount: jsonSerialization['pricedNftHoldingCount'] as int,
      cachedNftHoldingCount: jsonSerialization['cachedNftHoldingCount'] as int,
      unpricedNftHoldingCount:
          jsonSerialization['unpricedNftHoldingCount'] as int,
      valuationCoverageRatio:
          (jsonSerialization['valuationCoverageRatio'] as num?)?.toDouble(),
      totalValueMinor: jsonSerialization['totalValueMinor'] as int?,
      valuationCurrencyCode:
          jsonSerialization['valuationCurrencyCode'] as String?,
      syncedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['syncedAt'],
      ),
      warnings: _irkl4crj.Protocol().deserialize<List<String>>(
        jsonSerialization['warnings'],
      ),
    );
  }

  _isc.UuidValue walletId;

  int insertedTransactions;

  int updatedTransactions;

  int holdingCount;

  int pricedHoldingCount;

  int cachedHoldingCount;

  int unpricedHoldingCount;

  int nftHoldingCount;

  int pricedNftHoldingCount;

  int cachedNftHoldingCount;

  int unpricedNftHoldingCount;

  /// Share of holdings with a price, 0.0-1.0. Not money.
  double? valuationCoverageRatio;

  /// Sum of priced holdings, in valuationCurrencyCode minor units.
  int? totalValueMinor;

  String? valuationCurrencyCode;

  DateTime syncedAt;

  List<String> warnings;

  /// Returns a shallow copy of this [WalletSyncResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WalletSyncResult copyWith({
    _isc.UuidValue? walletId,
    int? insertedTransactions,
    int? updatedTransactions,
    int? holdingCount,
    int? pricedHoldingCount,
    int? cachedHoldingCount,
    int? unpricedHoldingCount,
    int? nftHoldingCount,
    int? pricedNftHoldingCount,
    int? cachedNftHoldingCount,
    int? unpricedNftHoldingCount,
    double? valuationCoverageRatio,
    int? totalValueMinor,
    String? valuationCurrencyCode,
    DateTime? syncedAt,
    List<String>? warnings,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletSyncResult',
      'walletId': walletId.toJson(),
      'insertedTransactions': insertedTransactions,
      'updatedTransactions': updatedTransactions,
      'holdingCount': holdingCount,
      'pricedHoldingCount': pricedHoldingCount,
      'cachedHoldingCount': cachedHoldingCount,
      'unpricedHoldingCount': unpricedHoldingCount,
      'nftHoldingCount': nftHoldingCount,
      'pricedNftHoldingCount': pricedNftHoldingCount,
      'cachedNftHoldingCount': cachedNftHoldingCount,
      'unpricedNftHoldingCount': unpricedNftHoldingCount,
      if (valuationCoverageRatio != null)
        'valuationCoverageRatio': valuationCoverageRatio,
      if (totalValueMinor != null) 'totalValueMinor': totalValueMinor,
      if (valuationCurrencyCode != null)
        'valuationCurrencyCode': valuationCurrencyCode,
      'syncedAt': syncedAt.toJson(),
      'warnings': warnings.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WalletSyncResult',
      'walletId': walletId.toJson(),
      'insertedTransactions': insertedTransactions,
      'updatedTransactions': updatedTransactions,
      'holdingCount': holdingCount,
      'pricedHoldingCount': pricedHoldingCount,
      'cachedHoldingCount': cachedHoldingCount,
      'unpricedHoldingCount': unpricedHoldingCount,
      'nftHoldingCount': nftHoldingCount,
      'pricedNftHoldingCount': pricedNftHoldingCount,
      'cachedNftHoldingCount': cachedNftHoldingCount,
      'unpricedNftHoldingCount': unpricedNftHoldingCount,
      if (valuationCoverageRatio != null)
        'valuationCoverageRatio': valuationCoverageRatio,
      if (totalValueMinor != null) 'totalValueMinor': totalValueMinor,
      if (valuationCurrencyCode != null)
        'valuationCurrencyCode': valuationCurrencyCode,
      'syncedAt': syncedAt.toJson(),
      'warnings': warnings.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletSyncResultImpl extends WalletSyncResult {
  _WalletSyncResultImpl({
    required _isc.UuidValue walletId,
    required int insertedTransactions,
    required int updatedTransactions,
    required int holdingCount,
    required int pricedHoldingCount,
    required int cachedHoldingCount,
    required int unpricedHoldingCount,
    required int nftHoldingCount,
    required int pricedNftHoldingCount,
    required int cachedNftHoldingCount,
    required int unpricedNftHoldingCount,
    double? valuationCoverageRatio,
    int? totalValueMinor,
    String? valuationCurrencyCode,
    required DateTime syncedAt,
    required List<String> warnings,
  }) : super._(
         walletId: walletId,
         insertedTransactions: insertedTransactions,
         updatedTransactions: updatedTransactions,
         holdingCount: holdingCount,
         pricedHoldingCount: pricedHoldingCount,
         cachedHoldingCount: cachedHoldingCount,
         unpricedHoldingCount: unpricedHoldingCount,
         nftHoldingCount: nftHoldingCount,
         pricedNftHoldingCount: pricedNftHoldingCount,
         cachedNftHoldingCount: cachedNftHoldingCount,
         unpricedNftHoldingCount: unpricedNftHoldingCount,
         valuationCoverageRatio: valuationCoverageRatio,
         totalValueMinor: totalValueMinor,
         valuationCurrencyCode: valuationCurrencyCode,
         syncedAt: syncedAt,
         warnings: warnings,
       );

  /// Returns a shallow copy of this [WalletSyncResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WalletSyncResult copyWith({
    _isc.UuidValue? walletId,
    int? insertedTransactions,
    int? updatedTransactions,
    int? holdingCount,
    int? pricedHoldingCount,
    int? cachedHoldingCount,
    int? unpricedHoldingCount,
    int? nftHoldingCount,
    int? pricedNftHoldingCount,
    int? cachedNftHoldingCount,
    int? unpricedNftHoldingCount,
    Object? valuationCoverageRatio = _Undefined,
    Object? totalValueMinor = _Undefined,
    Object? valuationCurrencyCode = _Undefined,
    DateTime? syncedAt,
    List<String>? warnings,
  }) {
    return WalletSyncResult(
      walletId: walletId ?? this.walletId,
      insertedTransactions: insertedTransactions ?? this.insertedTransactions,
      updatedTransactions: updatedTransactions ?? this.updatedTransactions,
      holdingCount: holdingCount ?? this.holdingCount,
      pricedHoldingCount: pricedHoldingCount ?? this.pricedHoldingCount,
      cachedHoldingCount: cachedHoldingCount ?? this.cachedHoldingCount,
      unpricedHoldingCount: unpricedHoldingCount ?? this.unpricedHoldingCount,
      nftHoldingCount: nftHoldingCount ?? this.nftHoldingCount,
      pricedNftHoldingCount:
          pricedNftHoldingCount ?? this.pricedNftHoldingCount,
      cachedNftHoldingCount:
          cachedNftHoldingCount ?? this.cachedNftHoldingCount,
      unpricedNftHoldingCount:
          unpricedNftHoldingCount ?? this.unpricedNftHoldingCount,
      valuationCoverageRatio: valuationCoverageRatio is double?
          ? valuationCoverageRatio
          : this.valuationCoverageRatio,
      totalValueMinor: totalValueMinor is int?
          ? totalValueMinor
          : this.totalValueMinor,
      valuationCurrencyCode: valuationCurrencyCode is String?
          ? valuationCurrencyCode
          : this.valuationCurrencyCode,
      syncedAt: syncedAt ?? this.syncedAt,
      warnings: warnings ?? this.warnings.map((e0) => e0).toList(),
    );
  }
}
