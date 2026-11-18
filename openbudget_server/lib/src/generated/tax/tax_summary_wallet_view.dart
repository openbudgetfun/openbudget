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
import 'package:openbudget_server/src/generated/protocol.dart' as _is0sbm8r;
import 'package:serverpod/serverpod.dart' as _is;

/// One wallet's estimated digital-asset disposals for a summary period.
///
/// The figures are the stored FIFO estimates on the wallet's transactions,
/// in [currencyCode], which is the wallet's own P&L currency and not the
/// summary's base currency. They are not a tax disposal computation; the
/// caveats say so.
abstract class TaxSummaryWalletView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TaxSummaryWalletView._({
    required this.walletId,
    this.label,
    required this.currencyCode,
    required this.transactionCount,
    required this.proceedsMinor,
    required this.costBasisMinor,
    required this.gainMinor,
    required this.costBasisMethod,
    required this.caveats,
  });

  factory TaxSummaryWalletView({
    required _is.UuidValue walletId,
    String? label,
    required String currencyCode,
    required int transactionCount,
    required int proceedsMinor,
    required int costBasisMinor,
    required int gainMinor,
    required String costBasisMethod,
    required List<String> caveats,
  }) = _TaxSummaryWalletViewImpl;

  factory TaxSummaryWalletView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return TaxSummaryWalletView(
      walletId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['walletId'],
      ),
      label: jsonSerialization['label'] as String?,
      currencyCode: jsonSerialization['currencyCode'] as String,
      transactionCount: jsonSerialization['transactionCount'] as int,
      proceedsMinor: jsonSerialization['proceedsMinor'] as int,
      costBasisMinor: jsonSerialization['costBasisMinor'] as int,
      gainMinor: jsonSerialization['gainMinor'] as int,
      costBasisMethod: jsonSerialization['costBasisMethod'] as String,
      caveats: _is0sbm8r.Protocol().deserialize<List<String>>(
        jsonSerialization['caveats'],
      ),
    );
  }

  _is.UuidValue walletId;

  /// The wallet's label, when one is set.
  String? label;

  /// ISO 4217 code of every amount in this row.
  String currencyCode;

  /// The valued transactions dated inside the period.
  int transactionCount;

  int proceedsMinor;

  int costBasisMinor;

  /// Realised profit or loss: proceeds less cost, negative when a loss.
  int gainMinor;

  /// The matching method behind the figures: `fifo`.
  String costBasisMethod;

  /// The method caveat, plus a count of the period's transactions that
  /// carry no stored valuation.
  List<String> caveats;

  /// Returns a shallow copy of this [TaxSummaryWalletView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TaxSummaryWalletView copyWith({
    _is.UuidValue? walletId,
    String? label,
    String? currencyCode,
    int? transactionCount,
    int? proceedsMinor,
    int? costBasisMinor,
    int? gainMinor,
    String? costBasisMethod,
    List<String>? caveats,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxSummaryWalletView',
      'walletId': walletId.toJson(),
      if (label != null) 'label': label,
      'currencyCode': currencyCode,
      'transactionCount': transactionCount,
      'proceedsMinor': proceedsMinor,
      'costBasisMinor': costBasisMinor,
      'gainMinor': gainMinor,
      'costBasisMethod': costBasisMethod,
      'caveats': caveats.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxSummaryWalletView',
      'walletId': walletId.toJson(),
      if (label != null) 'label': label,
      'currencyCode': currencyCode,
      'transactionCount': transactionCount,
      'proceedsMinor': proceedsMinor,
      'costBasisMinor': costBasisMinor,
      'gainMinor': gainMinor,
      'costBasisMethod': costBasisMethod,
      'caveats': caveats.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaxSummaryWalletViewImpl extends TaxSummaryWalletView {
  _TaxSummaryWalletViewImpl({
    required _is.UuidValue walletId,
    String? label,
    required String currencyCode,
    required int transactionCount,
    required int proceedsMinor,
    required int costBasisMinor,
    required int gainMinor,
    required String costBasisMethod,
    required List<String> caveats,
  }) : super._(
         walletId: walletId,
         label: label,
         currencyCode: currencyCode,
         transactionCount: transactionCount,
         proceedsMinor: proceedsMinor,
         costBasisMinor: costBasisMinor,
         gainMinor: gainMinor,
         costBasisMethod: costBasisMethod,
         caveats: caveats,
       );

  /// Returns a shallow copy of this [TaxSummaryWalletView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TaxSummaryWalletView copyWith({
    _is.UuidValue? walletId,
    Object? label = _Undefined,
    String? currencyCode,
    int? transactionCount,
    int? proceedsMinor,
    int? costBasisMinor,
    int? gainMinor,
    String? costBasisMethod,
    List<String>? caveats,
  }) {
    return TaxSummaryWalletView(
      walletId: walletId ?? this.walletId,
      label: label is String? ? label : this.label,
      currencyCode: currencyCode ?? this.currencyCode,
      transactionCount: transactionCount ?? this.transactionCount,
      proceedsMinor: proceedsMinor ?? this.proceedsMinor,
      costBasisMinor: costBasisMinor ?? this.costBasisMinor,
      gainMinor: gainMinor ?? this.gainMinor,
      costBasisMethod: costBasisMethod ?? this.costBasisMethod,
      caveats: caveats ?? this.caveats.map((e0) => e0).toList(),
    );
  }
}
