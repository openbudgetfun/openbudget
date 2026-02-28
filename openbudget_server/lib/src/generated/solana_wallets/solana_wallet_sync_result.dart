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

/// Sync response payload for Solana wallet refreshes.
abstract class SolanaWalletSyncResult
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  SolanaWalletSyncResult._({
    required this.walletId,
    required this.insertedTransactions,
    required this.updatedTransactions,
    required this.holdingCount,
    required this.pricedHoldingCount,
    required this.staleHoldingCount,
    required this.unpricedHoldingCount,
    required this.nftHoldingCount,
    required this.pricedNftHoldingCount,
    required this.staleNftHoldingCount,
    required this.unpricedNftHoldingCount,
    this.valuationCoverageRatio,
    this.totalValuation,
    this.valuationCurrency,
    required this.syncedAt,
    this.warnings,
  });

  factory SolanaWalletSyncResult({
    required _i1.UuidValue walletId,
    required int insertedTransactions,
    required int updatedTransactions,
    required int holdingCount,
    required int pricedHoldingCount,
    required int staleHoldingCount,
    required int unpricedHoldingCount,
    required int nftHoldingCount,
    required int pricedNftHoldingCount,
    required int staleNftHoldingCount,
    required int unpricedNftHoldingCount,
    double? valuationCoverageRatio,
    double? totalValuation,
    String? valuationCurrency,
    required DateTime syncedAt,
    String? warnings,
  }) = _SolanaWalletSyncResultImpl;

  factory SolanaWalletSyncResult.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SolanaWalletSyncResult(
      walletId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletId'],
      ),
      insertedTransactions: jsonSerialization['insertedTransactions'] as int,
      updatedTransactions: jsonSerialization['updatedTransactions'] as int,
      holdingCount: jsonSerialization['holdingCount'] as int,
      pricedHoldingCount: jsonSerialization['pricedHoldingCount'] as int,
      staleHoldingCount: jsonSerialization['staleHoldingCount'] as int,
      unpricedHoldingCount: jsonSerialization['unpricedHoldingCount'] as int,
      nftHoldingCount: jsonSerialization['nftHoldingCount'] as int,
      pricedNftHoldingCount: jsonSerialization['pricedNftHoldingCount'] as int,
      staleNftHoldingCount: jsonSerialization['staleNftHoldingCount'] as int,
      unpricedNftHoldingCount:
          jsonSerialization['unpricedNftHoldingCount'] as int,
      valuationCoverageRatio:
          (jsonSerialization['valuationCoverageRatio'] as num?)?.toDouble(),
      totalValuation: (jsonSerialization['totalValuation'] as num?)?.toDouble(),
      valuationCurrency: jsonSerialization['valuationCurrency'] as String?,
      syncedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['syncedAt'],
      ),
      warnings: jsonSerialization['warnings'] as String?,
    );
  }

  _i1.UuidValue walletId;

  int insertedTransactions;

  int updatedTransactions;

  int holdingCount;

  int pricedHoldingCount;

  int staleHoldingCount;

  int unpricedHoldingCount;

  int nftHoldingCount;

  int pricedNftHoldingCount;

  int staleNftHoldingCount;

  int unpricedNftHoldingCount;

  double? valuationCoverageRatio;

  double? totalValuation;

  String? valuationCurrency;

  DateTime syncedAt;

  String? warnings;

  /// Returns a shallow copy of this [SolanaWalletSyncResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SolanaWalletSyncResult copyWith({
    _i1.UuidValue? walletId,
    int? insertedTransactions,
    int? updatedTransactions,
    int? holdingCount,
    int? pricedHoldingCount,
    int? staleHoldingCount,
    int? unpricedHoldingCount,
    int? nftHoldingCount,
    int? pricedNftHoldingCount,
    int? staleNftHoldingCount,
    int? unpricedNftHoldingCount,
    double? valuationCoverageRatio,
    double? totalValuation,
    String? valuationCurrency,
    DateTime? syncedAt,
    String? warnings,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SolanaWalletSyncResult',
      'walletId': walletId.toJson(),
      'insertedTransactions': insertedTransactions,
      'updatedTransactions': updatedTransactions,
      'holdingCount': holdingCount,
      'pricedHoldingCount': pricedHoldingCount,
      'staleHoldingCount': staleHoldingCount,
      'unpricedHoldingCount': unpricedHoldingCount,
      'nftHoldingCount': nftHoldingCount,
      'pricedNftHoldingCount': pricedNftHoldingCount,
      'staleNftHoldingCount': staleNftHoldingCount,
      'unpricedNftHoldingCount': unpricedNftHoldingCount,
      if (valuationCoverageRatio != null)
        'valuationCoverageRatio': valuationCoverageRatio,
      if (totalValuation != null) 'totalValuation': totalValuation,
      if (valuationCurrency != null) 'valuationCurrency': valuationCurrency,
      'syncedAt': syncedAt.toJson(),
      if (warnings != null) 'warnings': warnings,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SolanaWalletSyncResult',
      'walletId': walletId.toJson(),
      'insertedTransactions': insertedTransactions,
      'updatedTransactions': updatedTransactions,
      'holdingCount': holdingCount,
      'pricedHoldingCount': pricedHoldingCount,
      'staleHoldingCount': staleHoldingCount,
      'unpricedHoldingCount': unpricedHoldingCount,
      'nftHoldingCount': nftHoldingCount,
      'pricedNftHoldingCount': pricedNftHoldingCount,
      'staleNftHoldingCount': staleNftHoldingCount,
      'unpricedNftHoldingCount': unpricedNftHoldingCount,
      if (valuationCoverageRatio != null)
        'valuationCoverageRatio': valuationCoverageRatio,
      if (totalValuation != null) 'totalValuation': totalValuation,
      if (valuationCurrency != null) 'valuationCurrency': valuationCurrency,
      'syncedAt': syncedAt.toJson(),
      if (warnings != null) 'warnings': warnings,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SolanaWalletSyncResultImpl extends SolanaWalletSyncResult {
  _SolanaWalletSyncResultImpl({
    required _i1.UuidValue walletId,
    required int insertedTransactions,
    required int updatedTransactions,
    required int holdingCount,
    required int pricedHoldingCount,
    required int staleHoldingCount,
    required int unpricedHoldingCount,
    required int nftHoldingCount,
    required int pricedNftHoldingCount,
    required int staleNftHoldingCount,
    required int unpricedNftHoldingCount,
    double? valuationCoverageRatio,
    double? totalValuation,
    String? valuationCurrency,
    required DateTime syncedAt,
    String? warnings,
  }) : super._(
         walletId: walletId,
         insertedTransactions: insertedTransactions,
         updatedTransactions: updatedTransactions,
         holdingCount: holdingCount,
         pricedHoldingCount: pricedHoldingCount,
         staleHoldingCount: staleHoldingCount,
         unpricedHoldingCount: unpricedHoldingCount,
         nftHoldingCount: nftHoldingCount,
         pricedNftHoldingCount: pricedNftHoldingCount,
         staleNftHoldingCount: staleNftHoldingCount,
         unpricedNftHoldingCount: unpricedNftHoldingCount,
         valuationCoverageRatio: valuationCoverageRatio,
         totalValuation: totalValuation,
         valuationCurrency: valuationCurrency,
         syncedAt: syncedAt,
         warnings: warnings,
       );

  /// Returns a shallow copy of this [SolanaWalletSyncResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SolanaWalletSyncResult copyWith({
    _i1.UuidValue? walletId,
    int? insertedTransactions,
    int? updatedTransactions,
    int? holdingCount,
    int? pricedHoldingCount,
    int? staleHoldingCount,
    int? unpricedHoldingCount,
    int? nftHoldingCount,
    int? pricedNftHoldingCount,
    int? staleNftHoldingCount,
    int? unpricedNftHoldingCount,
    Object? valuationCoverageRatio = _Undefined,
    Object? totalValuation = _Undefined,
    Object? valuationCurrency = _Undefined,
    DateTime? syncedAt,
    Object? warnings = _Undefined,
  }) {
    return SolanaWalletSyncResult(
      walletId: walletId ?? this.walletId,
      insertedTransactions: insertedTransactions ?? this.insertedTransactions,
      updatedTransactions: updatedTransactions ?? this.updatedTransactions,
      holdingCount: holdingCount ?? this.holdingCount,
      pricedHoldingCount: pricedHoldingCount ?? this.pricedHoldingCount,
      staleHoldingCount: staleHoldingCount ?? this.staleHoldingCount,
      unpricedHoldingCount: unpricedHoldingCount ?? this.unpricedHoldingCount,
      nftHoldingCount: nftHoldingCount ?? this.nftHoldingCount,
      pricedNftHoldingCount:
          pricedNftHoldingCount ?? this.pricedNftHoldingCount,
      staleNftHoldingCount: staleNftHoldingCount ?? this.staleNftHoldingCount,
      unpricedNftHoldingCount:
          unpricedNftHoldingCount ?? this.unpricedNftHoldingCount,
      valuationCoverageRatio: valuationCoverageRatio is double?
          ? valuationCoverageRatio
          : this.valuationCoverageRatio,
      totalValuation: totalValuation is double?
          ? totalValuation
          : this.totalValuation,
      valuationCurrency: valuationCurrency is String?
          ? valuationCurrency
          : this.valuationCurrency,
      syncedAt: syncedAt ?? this.syncedAt,
      warnings: warnings is String? ? warnings : this.warnings,
    );
  }
}
