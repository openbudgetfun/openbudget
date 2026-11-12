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

import '../envelope_goals/envelope_goal_kind.dart' as _ietq9ydg;

/// A savings or funding target for one envelope.
abstract class EnvelopeGoal
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  EnvelopeGoal._({
    this.id,
    required this.entityId,
    required this.envelopeId,
    required this.kind,
    required this.amountMinor,
    this.targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory EnvelopeGoal({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required _isc.UuidValue envelopeId,
    required _ietq9ydg.EnvelopeGoalKind kind,
    required int amountMinor,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _EnvelopeGoalImpl;

  factory EnvelopeGoal.fromJson(Map<String, dynamic> jsonSerialization) {
    return EnvelopeGoal(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      envelopeId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['envelopeId'],
      ),
      kind: _ietq9ydg.EnvelopeGoalKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      amountMinor: jsonSerialization['amountMinor'] as int,
      targetDate: jsonSerialization['targetDate'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['targetDate'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue entityId;

  _isc.UuidValue envelopeId;

  _ietq9ydg.EnvelopeGoalKind kind;

  /// Base-currency minor units, positive. The target balance for
  /// targetBalance and targetByDate; the amount to assign each month for
  /// monthlyFunding.
  int amountMinor;

  /// Calendar date; required for targetByDate, null otherwise.
  DateTime? targetDate;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [EnvelopeGoal]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  EnvelopeGoal copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    _isc.UuidValue? envelopeId,
    _ietq9ydg.EnvelopeGoalKind? kind,
    int? amountMinor,
    DateTime? targetDate = const _isc.$UndefinedDateTime(),
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EnvelopeGoal',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'envelopeId': envelopeId.toJson(),
      'kind': kind.toJson(),
      'amountMinor': amountMinor,
      if (targetDate != null) 'targetDate': targetDate?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EnvelopeGoal',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'envelopeId': envelopeId.toJson(),
      'kind': kind.toJson(),
      'amountMinor': amountMinor,
      if (targetDate != null) 'targetDate': targetDate?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _EnvelopeGoalImpl extends EnvelopeGoal {
  _EnvelopeGoalImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required _isc.UuidValue envelopeId,
    required _ietq9ydg.EnvelopeGoalKind kind,
    required int amountMinor,
    DateTime? targetDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         envelopeId: envelopeId,
         kind: kind,
         amountMinor: amountMinor,
         targetDate: targetDate,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [EnvelopeGoal]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  EnvelopeGoal copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    _isc.UuidValue? envelopeId,
    _ietq9ydg.EnvelopeGoalKind? kind,
    int? amountMinor,
    DateTime? targetDate = const _isc.$UndefinedDateTime(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnvelopeGoal(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      envelopeId: envelopeId ?? this.envelopeId,
      kind: kind ?? this.kind,
      amountMinor: amountMinor ?? this.amountMinor,
      targetDate: targetDate is _isc.UndefinedSentinel
          ? this.targetDate
          : targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
