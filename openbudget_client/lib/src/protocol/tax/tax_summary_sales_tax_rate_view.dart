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

/// Sales tax grouped by the rate each line implies.
///
/// The rate comes from the line: tax over the net amount it was charged
/// on, in millionths of the taxed amount — the same exact integer unit
/// the country dataset uses for `IndirectTaxRate.ratePerMillion`. A
/// separate VAT line — one tagged with a sales-tax category — carries
/// no net amount, so its rate is unknown and it is grouped under the
/// null rate.
abstract class TaxSummarySalesTaxRateView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TaxSummarySalesTaxRateView._({
    this.ratePerMillion,
    required this.collectedMinor,
    required this.paidMinor,
  });

  factory TaxSummarySalesTaxRateView({
    int? ratePerMillion,
    required int collectedMinor,
    required int paidMinor,
  }) = _TaxSummarySalesTaxRateViewImpl;

  factory TaxSummarySalesTaxRateView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return TaxSummarySalesTaxRateView(
      ratePerMillion: jsonSerialization['ratePerMillion'] as int?,
      collectedMinor: jsonSerialization['collectedMinor'] as int,
      paidMinor: jsonSerialization['paidMinor'] as int,
    );
  }

  /// 200000 is 20%; the derived ratio is rounded half away from zero
  /// at the millionth. Null when the rate could not be derived from
  /// the line.
  int? ratePerMillion;

  /// Tax charged to customers in this group, after business-use share.
  int collectedMinor;

  /// Tax paid on purchases in this group, after business-use share.
  int paidMinor;

  /// Returns a shallow copy of this [TaxSummarySalesTaxRateView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TaxSummarySalesTaxRateView copyWith({
    int? ratePerMillion,
    int? collectedMinor,
    int? paidMinor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxSummarySalesTaxRateView',
      if (ratePerMillion != null) 'ratePerMillion': ratePerMillion,
      'collectedMinor': collectedMinor,
      'paidMinor': paidMinor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxSummarySalesTaxRateView',
      if (ratePerMillion != null) 'ratePerMillion': ratePerMillion,
      'collectedMinor': collectedMinor,
      'paidMinor': paidMinor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaxSummarySalesTaxRateViewImpl extends TaxSummarySalesTaxRateView {
  _TaxSummarySalesTaxRateViewImpl({
    int? ratePerMillion,
    required int collectedMinor,
    required int paidMinor,
  }) : super._(
         ratePerMillion: ratePerMillion,
         collectedMinor: collectedMinor,
         paidMinor: paidMinor,
       );

  /// Returns a shallow copy of this [TaxSummarySalesTaxRateView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TaxSummarySalesTaxRateView copyWith({
    Object? ratePerMillion = _Undefined,
    int? collectedMinor,
    int? paidMinor,
  }) {
    return TaxSummarySalesTaxRateView(
      ratePerMillion: ratePerMillion is int?
          ? ratePerMillion
          : this.ratePerMillion,
      collectedMinor: collectedMinor ?? this.collectedMinor,
      paidMinor: paidMinor ?? this.paidMinor,
    );
  }
}
