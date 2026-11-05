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

/// A legal way to owe less, found in the taxpayer's own figures.
abstract class TaxOpportunityView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TaxOpportunityView._({
    required this.id,
    required this.title,
    required this.explanation,
    this.estimatedSavingMinor,
    this.deadline,
    required this.source,
  });

  factory TaxOpportunityView({
    required String id,
    required String title,
    required String explanation,
    int? estimatedSavingMinor,
    DateTime? deadline,
    required String source,
  }) = _TaxOpportunityViewImpl;

  factory TaxOpportunityView.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaxOpportunityView(
      id: jsonSerialization['id'] as String,
      title: jsonSerialization['title'] as String,
      explanation: jsonSerialization['explanation'] as String,
      estimatedSavingMinor: jsonSerialization['estimatedSavingMinor'] as int?,
      deadline: jsonSerialization['deadline'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['deadline']),
      source: jsonSerialization['source'] as String,
    );
  }

  /// Stable identifier, such as `gb.pension_annual_allowance`.
  String id;

  String title;

  String explanation;

  /// The estimated tax saved if acted on, when it can be computed.
  int? estimatedSavingMinor;

  /// The last day acting on it counts for the year.
  DateTime? deadline;

  /// The authority's guidance for it.
  String source;

  /// Returns a shallow copy of this [TaxOpportunityView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TaxOpportunityView copyWith({
    String? id,
    String? title,
    String? explanation,
    int? estimatedSavingMinor,
    DateTime? deadline = const _is.$UndefinedDateTime(),
    String? source,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxOpportunityView',
      'id': id,
      'title': title,
      'explanation': explanation,
      if (estimatedSavingMinor != null)
        'estimatedSavingMinor': estimatedSavingMinor,
      if (deadline != null) 'deadline': deadline?.toJson(),
      'source': source,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxOpportunityView',
      'id': id,
      'title': title,
      'explanation': explanation,
      if (estimatedSavingMinor != null)
        'estimatedSavingMinor': estimatedSavingMinor,
      if (deadline != null) 'deadline': deadline?.toJson(),
      'source': source,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaxOpportunityViewImpl extends TaxOpportunityView {
  _TaxOpportunityViewImpl({
    required String id,
    required String title,
    required String explanation,
    int? estimatedSavingMinor,
    DateTime? deadline,
    required String source,
  }) : super._(
         id: id,
         title: title,
         explanation: explanation,
         estimatedSavingMinor: estimatedSavingMinor,
         deadline: deadline,
         source: source,
       );

  /// Returns a shallow copy of this [TaxOpportunityView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TaxOpportunityView copyWith({
    String? id,
    String? title,
    String? explanation,
    Object? estimatedSavingMinor = _Undefined,
    DateTime? deadline = const _is.$UndefinedDateTime(),
    String? source,
  }) {
    return TaxOpportunityView(
      id: id ?? this.id,
      title: title ?? this.title,
      explanation: explanation ?? this.explanation,
      estimatedSavingMinor: estimatedSavingMinor is int?
          ? estimatedSavingMinor
          : this.estimatedSavingMinor,
      deadline: deadline is _is.UndefinedSentinel ? this.deadline : deadline,
      source: source ?? this.source,
    );
  }
}
