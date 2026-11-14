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

/// One filing or payment date from the country's filing calendar, with the
/// period it covers and the authority page it came from.
abstract class TaxDeadlineView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  TaxDeadlineView._({
    required this.id,
    required this.title,
    required this.kind,
    required this.dueDate,
    required this.daysLeft,
    required this.periodStart,
    required this.periodEnd,
    required this.periodLabel,
    required this.source,
    required this.citation,
    required this.grade,
    required this.dependsOnProfile,
    this.note,
    this.rolledFrom,
  });

  factory TaxDeadlineView({
    required String id,
    required String title,
    required String kind,
    required DateTime dueDate,
    required int daysLeft,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String periodLabel,
    required String source,
    required String citation,
    required String grade,
    required bool dependsOnProfile,
    String? note,
    DateTime? rolledFrom,
  }) = _TaxDeadlineViewImpl;

  factory TaxDeadlineView.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaxDeadlineView(
      id: jsonSerialization['id'] as String,
      title: jsonSerialization['title'] as String,
      kind: jsonSerialization['kind'] as String,
      dueDate: _is.DateTimeJsonExtension.fromJson(jsonSerialization['dueDate']),
      daysLeft: jsonSerialization['daysLeft'] as int,
      periodStart: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['periodStart'],
      ),
      periodEnd: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['periodEnd'],
      ),
      periodLabel: jsonSerialization['periodLabel'] as String,
      source: jsonSerialization['source'] as String,
      citation: jsonSerialization['citation'] as String,
      grade: jsonSerialization['grade'] as String,
      dependsOnProfile: _is.BoolJsonExtension.fromJson(
        jsonSerialization['dependsOnProfile'],
      ),
      note: jsonSerialization['note'] as String?,
      rolledFrom: jsonSerialization['rolledFrom'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['rolledFrom']),
    );
  }

  /// Stable identifier of the rule, prefixed by country:
  /// `gb.sa.online-return`. Every instance of a recurring rule shares it.
  String id;

  /// A neutral noun phrase in the authority's own language.
  String title;

  /// `filing`, `payment` or `filingAndPayment`.
  String kind;

  /// The day the deadline falls, after any weekend or holiday roll-forward.
  DateTime dueDate;

  /// The whole days from the entity's local today to [dueDate].
  int daysLeft;

  /// First day of the period the deadline covers.
  DateTime periodStart;

  /// First day after the period the deadline covers.
  DateTime periodEnd;

  /// How the authority names the period: `2025/26` or `1. Quartal 2026`.
  String periodLabel;

  /// The authority page the rule came from.
  String source;

  /// The provision behind the date: `§ 149 Abs. 2 AO`.
  String citation;

  /// `primary`, `secondary` or `inferred`.
  String grade;

  /// True when the profile's answers decide whether it applies or when it
  /// falls.
  bool dependsOnProfile;

  /// When it applies, or what the date assumes.
  String? note;

  /// The date before a weekend or holiday moved it, when one did.
  DateTime? rolledFrom;

  /// Returns a shallow copy of this [TaxDeadlineView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  TaxDeadlineView copyWith({
    String? id,
    String? title,
    String? kind,
    DateTime? dueDate,
    int? daysLeft,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? periodLabel,
    String? source,
    String? citation,
    String? grade,
    bool? dependsOnProfile,
    String? note,
    DateTime? rolledFrom = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxDeadlineView',
      'id': id,
      'title': title,
      'kind': kind,
      'dueDate': dueDate.toJson(),
      'daysLeft': daysLeft,
      'periodStart': periodStart.toJson(),
      'periodEnd': periodEnd.toJson(),
      'periodLabel': periodLabel,
      'source': source,
      'citation': citation,
      'grade': grade,
      'dependsOnProfile': dependsOnProfile,
      if (note != null) 'note': note,
      if (rolledFrom != null) 'rolledFrom': rolledFrom?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxDeadlineView',
      'id': id,
      'title': title,
      'kind': kind,
      'dueDate': dueDate.toJson(),
      'daysLeft': daysLeft,
      'periodStart': periodStart.toJson(),
      'periodEnd': periodEnd.toJson(),
      'periodLabel': periodLabel,
      'source': source,
      'citation': citation,
      'grade': grade,
      'dependsOnProfile': dependsOnProfile,
      if (note != null) 'note': note,
      if (rolledFrom != null) 'rolledFrom': rolledFrom?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaxDeadlineViewImpl extends TaxDeadlineView {
  _TaxDeadlineViewImpl({
    required String id,
    required String title,
    required String kind,
    required DateTime dueDate,
    required int daysLeft,
    required DateTime periodStart,
    required DateTime periodEnd,
    required String periodLabel,
    required String source,
    required String citation,
    required String grade,
    required bool dependsOnProfile,
    String? note,
    DateTime? rolledFrom,
  }) : super._(
         id: id,
         title: title,
         kind: kind,
         dueDate: dueDate,
         daysLeft: daysLeft,
         periodStart: periodStart,
         periodEnd: periodEnd,
         periodLabel: periodLabel,
         source: source,
         citation: citation,
         grade: grade,
         dependsOnProfile: dependsOnProfile,
         note: note,
         rolledFrom: rolledFrom,
       );

  /// Returns a shallow copy of this [TaxDeadlineView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  TaxDeadlineView copyWith({
    String? id,
    String? title,
    String? kind,
    DateTime? dueDate,
    int? daysLeft,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? periodLabel,
    String? source,
    String? citation,
    String? grade,
    bool? dependsOnProfile,
    Object? note = _Undefined,
    DateTime? rolledFrom = const _is.$UndefinedDateTime(),
  }) {
    return TaxDeadlineView(
      id: id ?? this.id,
      title: title ?? this.title,
      kind: kind ?? this.kind,
      dueDate: dueDate ?? this.dueDate,
      daysLeft: daysLeft ?? this.daysLeft,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      periodLabel: periodLabel ?? this.periodLabel,
      source: source ?? this.source,
      citation: citation ?? this.citation,
      grade: grade ?? this.grade,
      dependsOnProfile: dependsOnProfile ?? this.dependsOnProfile,
      note: note is String? ? note : this.note,
      rolledFrom: rolledFrom is _is.UndefinedSentinel
          ? this.rolledFrom
          : rolledFrom,
    );
  }
}
