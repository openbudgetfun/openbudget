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

/// One category's total inside a tax summary.
abstract class TaxSummaryCategoryTotalView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TaxSummaryCategoryTotalView._({
    required this.categoryCode,
    required this.label,
    required this.totalMinor,
    required this.entryCount,
  });

  factory TaxSummaryCategoryTotalView({
    required String categoryCode,
    required String label,
    required int totalMinor,
    required int entryCount,
  }) = _TaxSummaryCategoryTotalViewImpl;

  factory TaxSummaryCategoryTotalView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return TaxSummaryCategoryTotalView(
      categoryCode: jsonSerialization['categoryCode'] as String,
      label: jsonSerialization['label'] as String,
      totalMinor: jsonSerialization['totalMinor'] as int,
      entryCount: jsonSerialization['entryCount'] as int,
    );
  }

  /// The tax category code the total is grouped under. A pack country
  /// reports the pack's own code, after mapping any universal code.
  String categoryCode;

  /// The category's catalogue label.
  String label;

  /// The total in the summary's currency. Expenses are after business-use
  /// share and net of any sales tax on the line.
  int totalMinor;

  /// The lines that make up the total.
  int entryCount;

  /// Returns a shallow copy of this [TaxSummaryCategoryTotalView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TaxSummaryCategoryTotalView copyWith({
    String? categoryCode,
    String? label,
    int? totalMinor,
    int? entryCount,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxSummaryCategoryTotalView',
      'categoryCode': categoryCode,
      'label': label,
      'totalMinor': totalMinor,
      'entryCount': entryCount,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxSummaryCategoryTotalView',
      'categoryCode': categoryCode,
      'label': label,
      'totalMinor': totalMinor,
      'entryCount': entryCount,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _TaxSummaryCategoryTotalViewImpl extends TaxSummaryCategoryTotalView {
  _TaxSummaryCategoryTotalViewImpl({
    required String categoryCode,
    required String label,
    required int totalMinor,
    required int entryCount,
  }) : super._(
         categoryCode: categoryCode,
         label: label,
         totalMinor: totalMinor,
         entryCount: entryCount,
       );

  /// Returns a shallow copy of this [TaxSummaryCategoryTotalView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TaxSummaryCategoryTotalView copyWith({
    String? categoryCode,
    String? label,
    int? totalMinor,
    int? entryCount,
  }) {
    return TaxSummaryCategoryTotalView(
      categoryCode: categoryCode ?? this.categoryCode,
      label: label ?? this.label,
      totalMinor: totalMinor ?? this.totalMinor,
      entryCount: entryCount ?? this.entryCount,
    );
  }
}
