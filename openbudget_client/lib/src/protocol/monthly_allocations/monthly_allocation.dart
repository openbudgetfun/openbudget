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

/// Money assigned to an envelope for one month. The only stored figure of
/// the envelope plan; activity, carryover and available are derived.
abstract class MonthlyAllocation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  MonthlyAllocation._({
    this.id,
    required this.entityId,
    required this.envelopeId,
    required this.month,
    required this.allocatedMinor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory MonthlyAllocation({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required _isc.UuidValue envelopeId,
    required int month,
    required int allocatedMinor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MonthlyAllocationImpl;

  factory MonthlyAllocation.fromJson(Map<String, dynamic> jsonSerialization) {
    return MonthlyAllocation(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      envelopeId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['envelopeId'],
      ),
      month: jsonSerialization['month'] as int,
      allocatedMinor: jsonSerialization['allocatedMinor'] as int,
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

  /// Budget month as yyyymm, such as 202611.
  int month;

  /// Assigned amount in base-currency minor units. Negative when more was
  /// moved out than was assigned this month. Never 0: a zero deletes the row.
  int allocatedMinor;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [MonthlyAllocation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  MonthlyAllocation copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    _isc.UuidValue? envelopeId,
    int? month,
    int? allocatedMinor,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MonthlyAllocation',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'envelopeId': envelopeId.toJson(),
      'month': month,
      'allocatedMinor': allocatedMinor,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MonthlyAllocation',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'envelopeId': envelopeId.toJson(),
      'month': month,
      'allocatedMinor': allocatedMinor,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _MonthlyAllocationImpl extends MonthlyAllocation {
  _MonthlyAllocationImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required _isc.UuidValue envelopeId,
    required int month,
    required int allocatedMinor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         envelopeId: envelopeId,
         month: month,
         allocatedMinor: allocatedMinor,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [MonthlyAllocation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  MonthlyAllocation copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    _isc.UuidValue? envelopeId,
    int? month,
    int? allocatedMinor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MonthlyAllocation(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      envelopeId: envelopeId ?? this.envelopeId,
      month: month ?? this.month,
      allocatedMinor: allocatedMinor ?? this.allocatedMinor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
