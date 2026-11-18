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
import 'package:serverpod/serverpod.dart' as _is;

/// Estimated realised wallet P&L for one tax year of the wallet's entity.
abstract class WalletTaxYearSummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  WalletTaxYearSummary._({
    required this.walletId,
    required this.taxYear,
    required this.transactionCount,
    required this.pnlCurrencyCode,
    required this.realizedPnlMinor,
    required this.proceedsMinor,
    required this.costBasisMinor,
  });

  factory WalletTaxYearSummary({
    required _is.UuidValue walletId,
    required int taxYear,
    required int transactionCount,
    required String pnlCurrencyCode,
    required int realizedPnlMinor,
    required int proceedsMinor,
    required int costBasisMinor,
  }) = _WalletTaxYearSummaryImpl;

  factory WalletTaxYearSummary.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return WalletTaxYearSummary(
      walletId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletId'],
      ),
      taxYear: jsonSerialization['taxYear'] as int,
      transactionCount: jsonSerialization['transactionCount'] as int,
      pnlCurrencyCode: jsonSerialization['pnlCurrencyCode'] as String,
      realizedPnlMinor: jsonSerialization['realizedPnlMinor'] as int,
      proceedsMinor: jsonSerialization['proceedsMinor'] as int,
      costBasisMinor: jsonSerialization['costBasisMinor'] as int,
    );
  }

  _is.UuidValue walletId;

  /// Calendar year the entity's tax year starts in.
  int taxYear;

  int transactionCount;

  String pnlCurrencyCode;

  int realizedPnlMinor;

  int proceedsMinor;

  int costBasisMinor;

  /// Returns a shallow copy of this [WalletTaxYearSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  WalletTaxYearSummary copyWith({
    _is.UuidValue? walletId,
    int? taxYear,
    int? transactionCount,
    String? pnlCurrencyCode,
    int? realizedPnlMinor,
    int? proceedsMinor,
    int? costBasisMinor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletTaxYearSummary',
      'walletId': walletId.toJson(),
      'taxYear': taxYear,
      'transactionCount': transactionCount,
      'pnlCurrencyCode': pnlCurrencyCode,
      'realizedPnlMinor': realizedPnlMinor,
      'proceedsMinor': proceedsMinor,
      'costBasisMinor': costBasisMinor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WalletTaxYearSummary',
      'walletId': walletId.toJson(),
      'taxYear': taxYear,
      'transactionCount': transactionCount,
      'pnlCurrencyCode': pnlCurrencyCode,
      'realizedPnlMinor': realizedPnlMinor,
      'proceedsMinor': proceedsMinor,
      'costBasisMinor': costBasisMinor,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _WalletTaxYearSummaryImpl extends WalletTaxYearSummary {
  _WalletTaxYearSummaryImpl({
    required _is.UuidValue walletId,
    required int taxYear,
    required int transactionCount,
    required String pnlCurrencyCode,
    required int realizedPnlMinor,
    required int proceedsMinor,
    required int costBasisMinor,
  }) : super._(
         walletId: walletId,
         taxYear: taxYear,
         transactionCount: transactionCount,
         pnlCurrencyCode: pnlCurrencyCode,
         realizedPnlMinor: realizedPnlMinor,
         proceedsMinor: proceedsMinor,
         costBasisMinor: costBasisMinor,
       );

  /// Returns a shallow copy of this [WalletTaxYearSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  WalletTaxYearSummary copyWith({
    _is.UuidValue? walletId,
    int? taxYear,
    int? transactionCount,
    String? pnlCurrencyCode,
    int? realizedPnlMinor,
    int? proceedsMinor,
    int? costBasisMinor,
  }) {
    return WalletTaxYearSummary(
      walletId: walletId ?? this.walletId,
      taxYear: taxYear ?? this.taxYear,
      transactionCount: transactionCount ?? this.transactionCount,
      pnlCurrencyCode: pnlCurrencyCode ?? this.pnlCurrencyCode,
      realizedPnlMinor: realizedPnlMinor ?? this.realizedPnlMinor,
      proceedsMinor: proceedsMinor ?? this.proceedsMinor,
      costBasisMinor: costBasisMinor ?? this.costBasisMinor,
    );
  }
}
