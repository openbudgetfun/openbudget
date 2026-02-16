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
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// A savings goal or target for an envelope.
abstract class EnvelopeGoal implements _i1.SerializableModel {
  EnvelopeGoal._({
    this.id,
    required this.envelopeId,
    required this.goalType,
    required this.targetAmountCents,
    this.targetDate,
    this.monthlyFundingCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory EnvelopeGoal({
    _i1.UuidValue? id,
    required _i1.UuidValue envelopeId,
    required String goalType,
    required int targetAmountCents,
    DateTime? targetDate,
    int? monthlyFundingCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _EnvelopeGoalImpl;

  factory EnvelopeGoal.fromJson(Map<String, dynamic> jsonSerialization) {
    return EnvelopeGoal(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      envelopeId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['envelopeId'],
      ),
      goalType: jsonSerialization['goalType'] as String,
      targetAmountCents: jsonSerialization['targetAmountCents'] as int,
      targetDate: jsonSerialization['targetDate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['targetDate']),
      monthlyFundingCents: jsonSerialization['monthlyFundingCents'] as int?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue envelopeId;

  /// Goal type: 'target_balance', 'monthly_funding', or 'target_by_date'.
  String goalType;

  /// Target amount in integer cents.
  int targetAmountCents;

  /// Target date for 'target_by_date' goals (nullable for other types).
  DateTime? targetDate;

  /// Monthly funding amount in cents for 'monthly_funding' goals.
  int? monthlyFundingCents;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [EnvelopeGoal]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  EnvelopeGoal copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? envelopeId,
    String? goalType,
    int? targetAmountCents,
    DateTime? targetDate,
    int? monthlyFundingCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EnvelopeGoal',
      if (id != null) 'id': id?.toJson(),
      'envelopeId': envelopeId.toJson(),
      'goalType': goalType,
      'targetAmountCents': targetAmountCents,
      if (targetDate != null) 'targetDate': targetDate?.toJson(),
      if (monthlyFundingCents != null)
        'monthlyFundingCents': monthlyFundingCents,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EnvelopeGoalImpl extends EnvelopeGoal {
  _EnvelopeGoalImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue envelopeId,
    required String goalType,
    required int targetAmountCents,
    DateTime? targetDate,
    int? monthlyFundingCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         envelopeId: envelopeId,
         goalType: goalType,
         targetAmountCents: targetAmountCents,
         targetDate: targetDate,
         monthlyFundingCents: monthlyFundingCents,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [EnvelopeGoal]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  EnvelopeGoal copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? envelopeId,
    String? goalType,
    int? targetAmountCents,
    Object? targetDate = _Undefined,
    Object? monthlyFundingCents = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnvelopeGoal(
      id: id is _i1.UuidValue? ? id : this.id,
      envelopeId: envelopeId ?? this.envelopeId,
      goalType: goalType ?? this.goalType,
      targetAmountCents: targetAmountCents ?? this.targetAmountCents,
      targetDate: targetDate is DateTime? ? targetDate : this.targetDate,
      monthlyFundingCents: monthlyFundingCents is int?
          ? monthlyFundingCents
          : this.monthlyFundingCents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
