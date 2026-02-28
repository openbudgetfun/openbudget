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
    double? totalValuation,
    String? valuationCurrency,
    required DateTime syncedAt,
    String? warnings,
  }) : super._(
         walletId: walletId,
         insertedTransactions: insertedTransactions,
         updatedTransactions: updatedTransactions,
         holdingCount: holdingCount,
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
