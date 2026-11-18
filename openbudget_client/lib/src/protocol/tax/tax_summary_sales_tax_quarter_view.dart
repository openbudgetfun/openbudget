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

/// Sales tax grouped by quarter of the summary period.
///
/// Q1 starts on the period's first day; every quarter is three calendar
/// months.
abstract class TaxSummarySalesTaxQuarterView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TaxSummarySalesTaxQuarterView._({
    required this.label,
    required this.periodStart,
    required this.periodEnd,
    required this.collectedMinor,
    required this.paidMinor,
  });

  factory TaxSummarySalesTaxQuarterView({
    required String label,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int collectedMinor,
    required int paidMinor,
  }) = _TaxSummarySalesTaxQuarterViewImpl;

  factory TaxSummarySalesTaxQuarterView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return TaxSummarySalesTaxQuarterView(
      label: jsonSerialization['label'] as String,
      periodStart: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['periodStart'],
      ),
      periodEnd: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['periodEnd'],
      ),
      collectedMinor: jsonSerialization['collectedMinor'] as int,
      paidMinor: jsonSerialization['paidMinor'] as int,
    );
  }

  /// `Q1` to `Q4`, counted from the start of the summary period.
  String label;

  DateTime periodStart;

  /// First day after the quarter, exclusive.
  DateTime periodEnd;

  /// Tax charged to customers in the quarter, after business-use share.
  int collectedMinor;

  /// Tax paid on purchases in the quarter, after business-use share.
  int paidMinor;

  /// Returns a shallow copy of this [TaxSummarySalesTaxQuarterView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TaxSummarySalesTaxQuarterView copyWith({
    String? label,
    DateTime? periodStart,
    DateTime? periodEnd,
    int? collectedMinor,
    int? paidMinor,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxSummarySalesTaxQuarterView',
      'label': label,
      'periodStart': periodStart.toJson(),
      'periodEnd': periodEnd.toJson(),
      'collectedMinor': collectedMinor,
      'paidMinor': paidMinor,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxSummarySalesTaxQuarterView',
      'label': label,
      'periodStart': periodStart.toJson(),
      'periodEnd': periodEnd.toJson(),
      'collectedMinor': collectedMinor,
      'paidMinor': paidMinor,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _TaxSummarySalesTaxQuarterViewImpl extends TaxSummarySalesTaxQuarterView {
  _TaxSummarySalesTaxQuarterViewImpl({
    required String label,
    required DateTime periodStart,
    required DateTime periodEnd,
    required int collectedMinor,
    required int paidMinor,
  }) : super._(
         label: label,
         periodStart: periodStart,
         periodEnd: periodEnd,
         collectedMinor: collectedMinor,
         paidMinor: paidMinor,
       );

  /// Returns a shallow copy of this [TaxSummarySalesTaxQuarterView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TaxSummarySalesTaxQuarterView copyWith({
    String? label,
    DateTime? periodStart,
    DateTime? periodEnd,
    int? collectedMinor,
    int? paidMinor,
  }) {
    return TaxSummarySalesTaxQuarterView(
      label: label ?? this.label,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      collectedMinor: collectedMinor ?? this.collectedMinor,
      paidMinor: paidMinor ?? this.paidMinor,
    );
  }
}
