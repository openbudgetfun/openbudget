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

/// Estimated realized wallet P&L grouped by tax year.
abstract class SolanaWalletTaxYearSummary
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  SolanaWalletTaxYearSummary._({
    required this.walletId,
    required this.taxYear,
    required this.transactionCount,
    required this.estimatedRealizedPnl,
    required this.estimatedProceeds,
    required this.estimatedCostBasis,
    required this.pnlCurrency,
  });

  factory SolanaWalletTaxYearSummary({
    required _i1.UuidValue walletId,
    required int taxYear,
    required int transactionCount,
    required double estimatedRealizedPnl,
    required double estimatedProceeds,
    required double estimatedCostBasis,
    required String pnlCurrency,
  }) = _SolanaWalletTaxYearSummaryImpl;

  factory SolanaWalletTaxYearSummary.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SolanaWalletTaxYearSummary(
      walletId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletId'],
      ),
      taxYear: jsonSerialization['taxYear'] as int,
      transactionCount: jsonSerialization['transactionCount'] as int,
      estimatedRealizedPnl: (jsonSerialization['estimatedRealizedPnl'] as num)
          .toDouble(),
      estimatedProceeds: (jsonSerialization['estimatedProceeds'] as num)
          .toDouble(),
      estimatedCostBasis: (jsonSerialization['estimatedCostBasis'] as num)
          .toDouble(),
      pnlCurrency: jsonSerialization['pnlCurrency'] as String,
    );
  }

  _i1.UuidValue walletId;

  int taxYear;

  int transactionCount;

  double estimatedRealizedPnl;

  double estimatedProceeds;

  double estimatedCostBasis;

  String pnlCurrency;

  /// Returns a shallow copy of this [SolanaWalletTaxYearSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SolanaWalletTaxYearSummary copyWith({
    _i1.UuidValue? walletId,
    int? taxYear,
    int? transactionCount,
    double? estimatedRealizedPnl,
    double? estimatedProceeds,
    double? estimatedCostBasis,
    String? pnlCurrency,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SolanaWalletTaxYearSummary',
      'walletId': walletId.toJson(),
      'taxYear': taxYear,
      'transactionCount': transactionCount,
      'estimatedRealizedPnl': estimatedRealizedPnl,
      'estimatedProceeds': estimatedProceeds,
      'estimatedCostBasis': estimatedCostBasis,
      'pnlCurrency': pnlCurrency,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SolanaWalletTaxYearSummary',
      'walletId': walletId.toJson(),
      'taxYear': taxYear,
      'transactionCount': transactionCount,
      'estimatedRealizedPnl': estimatedRealizedPnl,
      'estimatedProceeds': estimatedProceeds,
      'estimatedCostBasis': estimatedCostBasis,
      'pnlCurrency': pnlCurrency,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _SolanaWalletTaxYearSummaryImpl extends SolanaWalletTaxYearSummary {
  _SolanaWalletTaxYearSummaryImpl({
    required _i1.UuidValue walletId,
    required int taxYear,
    required int transactionCount,
    required double estimatedRealizedPnl,
    required double estimatedProceeds,
    required double estimatedCostBasis,
    required String pnlCurrency,
  }) : super._(
         walletId: walletId,
         taxYear: taxYear,
         transactionCount: transactionCount,
         estimatedRealizedPnl: estimatedRealizedPnl,
         estimatedProceeds: estimatedProceeds,
         estimatedCostBasis: estimatedCostBasis,
         pnlCurrency: pnlCurrency,
       );

  /// Returns a shallow copy of this [SolanaWalletTaxYearSummary]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SolanaWalletTaxYearSummary copyWith({
    _i1.UuidValue? walletId,
    int? taxYear,
    int? transactionCount,
    double? estimatedRealizedPnl,
    double? estimatedProceeds,
    double? estimatedCostBasis,
    String? pnlCurrency,
  }) {
    return SolanaWalletTaxYearSummary(
      walletId: walletId ?? this.walletId,
      taxYear: taxYear ?? this.taxYear,
      transactionCount: transactionCount ?? this.transactionCount,
      estimatedRealizedPnl: estimatedRealizedPnl ?? this.estimatedRealizedPnl,
      estimatedProceeds: estimatedProceeds ?? this.estimatedProceeds,
      estimatedCostBasis: estimatedCostBasis ?? this.estimatedCostBasis,
      pnlCurrency: pnlCurrency ?? this.pnlCurrency,
    );
  }
}
