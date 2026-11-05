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

/// One figure of a tax report: a category total or a computed amount.
abstract class TaxReportLineView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TaxReportLineView._({
    required this.label,
    required this.amountMinor,
    this.code,
    this.reportReference,
    required this.entryCount,
  });

  factory TaxReportLineView({
    required String label,
    required int amountMinor,
    String? code,
    String? reportReference,
    required int entryCount,
  }) = _TaxReportLineViewImpl;

  factory TaxReportLineView.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaxReportLineView(
      label: jsonSerialization['label'] as String,
      amountMinor: jsonSerialization['amountMinor'] as int,
      code: jsonSerialization['code'] as String?,
      reportReference: jsonSerialization['reportReference'] as String?,
      entryCount: jsonSerialization['entryCount'] as int,
    );
  }

  String label;

  int amountMinor;

  /// The TaxCategory code this line totals, when it totals one.
  String? code;

  String? reportReference;

  int entryCount;

  /// Returns a shallow copy of this [TaxReportLineView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TaxReportLineView copyWith({
    String? label,
    int? amountMinor,
    String? code,
    String? reportReference,
    int? entryCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxReportLineView',
      'label': label,
      'amountMinor': amountMinor,
      if (code != null) 'code': code,
      if (reportReference != null) 'reportReference': reportReference,
      'entryCount': entryCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxReportLineView',
      'label': label,
      'amountMinor': amountMinor,
      if (code != null) 'code': code,
      if (reportReference != null) 'reportReference': reportReference,
      'entryCount': entryCount,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaxReportLineViewImpl extends TaxReportLineView {
  _TaxReportLineViewImpl({
    required String label,
    required int amountMinor,
    String? code,
    String? reportReference,
    required int entryCount,
  }) : super._(
         label: label,
         amountMinor: amountMinor,
         code: code,
         reportReference: reportReference,
         entryCount: entryCount,
       );

  /// Returns a shallow copy of this [TaxReportLineView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TaxReportLineView copyWith({
    String? label,
    int? amountMinor,
    Object? code = _Undefined,
    Object? reportReference = _Undefined,
    int? entryCount,
  }) {
    return TaxReportLineView(
      label: label ?? this.label,
      amountMinor: amountMinor ?? this.amountMinor,
      code: code is String? ? code : this.code,
      reportReference: reportReference is String?
          ? reportReference
          : this.reportReference,
      entryCount: entryCount ?? this.entryCount,
    );
  }
}
