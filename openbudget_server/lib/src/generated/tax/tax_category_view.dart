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

/// One category of a jurisdiction's tax catalog, for display and assignment.
abstract class TaxCategoryView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TaxCategoryView._({
    required this.code,
    required this.label,
    required this.kind,
    this.reportReference,
    this.description,
  });

  factory TaxCategoryView({
    required String code,
    required String label,
    required String kind,
    String? reportReference,
    String? description,
  }) = _TaxCategoryViewImpl;

  factory TaxCategoryView.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaxCategoryView(
      code: jsonSerialization['code'] as String,
      label: jsonSerialization['label'] as String,
      kind: jsonSerialization['kind'] as String,
      reportReference: jsonSerialization['reportReference'] as String?,
      description: jsonSerialization['description'] as String?,
    );
  }

  /// Stable identifier, prefixed by jurisdiction: `gb.se.office_costs`.
  String code;

  /// The name the tax authority uses, in its own language.
  String label;

  /// TaxCategoryKind name: income, expense, relief, taxPaid, and so on.
  String kind;

  /// Where the total lands on the official return.
  String? reportReference;

  String? description;

  /// Returns a shallow copy of this [TaxCategoryView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TaxCategoryView copyWith({
    String? code,
    String? label,
    String? kind,
    String? reportReference,
    String? description,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxCategoryView',
      'code': code,
      'label': label,
      'kind': kind,
      if (reportReference != null) 'reportReference': reportReference,
      if (description != null) 'description': description,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxCategoryView',
      'code': code,
      'label': label,
      'kind': kind,
      if (reportReference != null) 'reportReference': reportReference,
      if (description != null) 'description': description,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaxCategoryViewImpl extends TaxCategoryView {
  _TaxCategoryViewImpl({
    required String code,
    required String label,
    required String kind,
    String? reportReference,
    String? description,
  }) : super._(
         code: code,
         label: label,
         kind: kind,
         reportReference: reportReference,
         description: description,
       );

  /// Returns a shallow copy of this [TaxCategoryView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TaxCategoryView copyWith({
    String? code,
    String? label,
    String? kind,
    Object? reportReference = _Undefined,
    Object? description = _Undefined,
  }) {
    return TaxCategoryView(
      code: code ?? this.code,
      label: label ?? this.label,
      kind: kind ?? this.kind,
      reportReference: reportReference is String?
          ? reportReference
          : this.reportReference,
      description: description is String? ? description : this.description,
    );
  }
}
