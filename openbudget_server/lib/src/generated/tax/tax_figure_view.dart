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

/// One named figure of a rule set, such as the personal allowance, that
/// reports and knowledge cards quote by id.
abstract class TaxFigureView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TaxFigureView._({
    required this.id,
    required this.value,
    required this.unit,
    required this.grade,
    required this.verifiedOn,
    required this.source,
  });

  factory TaxFigureView({
    required String id,
    required int value,
    required String unit,
    required String grade,
    required DateTime verifiedOn,
    required String source,
  }) = _TaxFigureViewImpl;

  factory TaxFigureView.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaxFigureView(
      id: jsonSerialization['id'] as String,
      value: jsonSerialization['value'] as int,
      unit: jsonSerialization['unit'] as String,
      grade: jsonSerialization['grade'] as String,
      verifiedOn: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['verifiedOn'],
      ),
      source: jsonSerialization['source'] as String,
    );
  }

  /// Stable identifier, unique in its rule set: `personalAllowance`.
  String id;

  /// The figure in [unit].
  int value;

  /// `currencyMinor`, `rateBasisPoints`, `percent` or `count`.
  String unit;

  /// `primary`, `secondary` or `inferred`. A secondary-grade figure
  /// computes a liability only with a visible caveat, and its lines carry
  /// a "from a secondary source" badge.
  String grade;

  /// When the figure was last checked against its source.
  DateTime verifiedOn;

  /// The authority page the figure came from.
  String source;

  /// Returns a shallow copy of this [TaxFigureView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TaxFigureView copyWith({
    String? id,
    int? value,
    String? unit,
    String? grade,
    DateTime? verifiedOn,
    String? source,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxFigureView',
      'id': id,
      'value': value,
      'unit': unit,
      'grade': grade,
      'verifiedOn': verifiedOn.toJson(),
      'source': source,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxFigureView',
      'id': id,
      'value': value,
      'unit': unit,
      'grade': grade,
      'verifiedOn': verifiedOn.toJson(),
      'source': source,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _TaxFigureViewImpl extends TaxFigureView {
  _TaxFigureViewImpl({
    required String id,
    required int value,
    required String unit,
    required String grade,
    required DateTime verifiedOn,
    required String source,
  }) : super._(
         id: id,
         value: value,
         unit: unit,
         grade: grade,
         verifiedOn: verifiedOn,
         source: source,
       );

  /// Returns a shallow copy of this [TaxFigureView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TaxFigureView copyWith({
    String? id,
    int? value,
    String? unit,
    String? grade,
    DateTime? verifiedOn,
    String? source,
  }) {
    return TaxFigureView(
      id: id ?? this.id,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      grade: grade ?? this.grade,
      verifiedOn: verifiedOn ?? this.verifiedOn,
      source: source ?? this.source,
    );
  }
}
