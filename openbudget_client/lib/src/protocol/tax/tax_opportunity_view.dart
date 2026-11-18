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
import 'package:openbudget_client/src/protocol/protocol.dart' as _irkl4crj;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

/// A legal way to owe less, found in the taxpayer's own figures.
abstract class TaxOpportunityView
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TaxOpportunityView._({
    required this.id,
    required this.title,
    required this.explanation,
    this.estimatedSavingMinor,
    this.deadline,
    required this.source,
    required this.ruleYear,
    required this.grade,
    required this.announced,
    required this.signpostOnly,
    required this.needsEvidence,
    required this.assumptions,
  });

  factory TaxOpportunityView({
    required String id,
    required String title,
    required String explanation,
    int? estimatedSavingMinor,
    DateTime? deadline,
    required String source,
    required String ruleYear,
    required String grade,
    required bool announced,
    required bool signpostOnly,
    required bool needsEvidence,
    required List<String> assumptions,
  }) = _TaxOpportunityViewImpl;

  factory TaxOpportunityView.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaxOpportunityView(
      id: jsonSerialization['id'] as String,
      title: jsonSerialization['title'] as String,
      explanation: jsonSerialization['explanation'] as String,
      estimatedSavingMinor: jsonSerialization['estimatedSavingMinor'] as int?,
      deadline: jsonSerialization['deadline'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['deadline']),
      source: jsonSerialization['source'] as String,
      ruleYear: jsonSerialization['ruleYear'] as String,
      grade: jsonSerialization['grade'] as String,
      announced: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['announced'],
      ),
      signpostOnly: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['signpostOnly'],
      ),
      needsEvidence: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['needsEvidence'],
      ),
      assumptions: _irkl4crj.Protocol().deserialize<List<String>>(
        jsonSerialization['assumptions'],
      ),
    );
  }

  /// Stable identifier, such as `gb.pension_annual_allowance`.
  String id;

  /// A neutral noun phrase, never an imperative addressed to the user.
  String title;

  String explanation;

  /// The estimated tax saved if acted on. Null when the key figure is not
  /// primary-grade, the rule is announced, the row is signpost-only, or the
  /// saving depends on a fact the books do not hold.
  int? estimatedSavingMinor;

  /// The last day acting on it counts for the year.
  DateTime? deadline;

  /// The authority's guidance for it.
  String source;

  /// The tax year whose rules the figures come from: `2026/27` or `2026`.
  String ruleYear;

  /// `primary`, `secondary` or `inferred`; secondary and inferred rows
  /// carry no saving.
  String grade;

  /// True when the rule is announced but not yet law.
  bool announced;

  /// True when the topic is reserved to a professional in this country:
  /// the row explains the rule, computes nothing and signposts.
  bool signpostOnly;

  /// True when acting on the relief needs evidence the books do not hold.
  bool needsEvidence;

  /// What the explanation assumes, in plain sentences.
  List<String> assumptions;

  /// Returns a shallow copy of this [TaxOpportunityView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TaxOpportunityView copyWith({
    String? id,
    String? title,
    String? explanation,
    int? estimatedSavingMinor,
    DateTime? deadline = const _isc.$UndefinedDateTime(),
    String? source,
    String? ruleYear,
    String? grade,
    bool? announced,
    bool? signpostOnly,
    bool? needsEvidence,
    List<String>? assumptions,
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
      'ruleYear': ruleYear,
      'grade': grade,
      'announced': announced,
      'signpostOnly': signpostOnly,
      'needsEvidence': needsEvidence,
      'assumptions': assumptions.toJson(),
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
      'ruleYear': ruleYear,
      'grade': grade,
      'announced': announced,
      'signpostOnly': signpostOnly,
      'needsEvidence': needsEvidence,
      'assumptions': assumptions.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
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
    required String ruleYear,
    required String grade,
    required bool announced,
    required bool signpostOnly,
    required bool needsEvidence,
    required List<String> assumptions,
  }) : super._(
         id: id,
         title: title,
         explanation: explanation,
         estimatedSavingMinor: estimatedSavingMinor,
         deadline: deadline,
         source: source,
         ruleYear: ruleYear,
         grade: grade,
         announced: announced,
         signpostOnly: signpostOnly,
         needsEvidence: needsEvidence,
         assumptions: assumptions,
       );

  /// Returns a shallow copy of this [TaxOpportunityView]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TaxOpportunityView copyWith({
    String? id,
    String? title,
    String? explanation,
    Object? estimatedSavingMinor = _Undefined,
    DateTime? deadline = const _isc.$UndefinedDateTime(),
    String? source,
    String? ruleYear,
    String? grade,
    bool? announced,
    bool? signpostOnly,
    bool? needsEvidence,
    List<String>? assumptions,
  }) {
    return TaxOpportunityView(
      id: id ?? this.id,
      title: title ?? this.title,
      explanation: explanation ?? this.explanation,
      estimatedSavingMinor: estimatedSavingMinor is int?
          ? estimatedSavingMinor
          : this.estimatedSavingMinor,
      deadline: deadline is _isc.UndefinedSentinel ? this.deadline : deadline,
      source: source ?? this.source,
      ruleYear: ruleYear ?? this.ruleYear,
      grade: grade ?? this.grade,
      announced: announced ?? this.announced,
      signpostOnly: signpostOnly ?? this.signpostOnly,
      needsEvidence: needsEvidence ?? this.needsEvidence,
      assumptions: assumptions ?? this.assumptions.map((e0) => e0).toList(),
    );
  }
}
