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

/// Per-month allocation for an envelope, enabling monthly budget cycles.
abstract class MonthlyAllocation
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  MonthlyAllocation._({
    this.id,
    required this.envelopeId,
    required this.budgetId,
    required this.year,
    required this.month,
    required this.allocatedCents,
    required this.carryoverCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory MonthlyAllocation({
    _isc.UuidValue? id,
    required _isc.UuidValue envelopeId,
    required _isc.UuidValue budgetId,
    required int year,
    required int month,
    required int allocatedCents,
    required int carryoverCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _MonthlyAllocationImpl;

  factory MonthlyAllocation.fromJson(Map<String, dynamic> jsonSerialization) {
    return MonthlyAllocation(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      envelopeId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['envelopeId'],
      ),
      budgetId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      year: jsonSerialization['year'] as int,
      month: jsonSerialization['month'] as int,
      allocatedCents: jsonSerialization['allocatedCents'] as int,
      carryoverCents: jsonSerialization['carryoverCents'] as int,
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

  _isc.UuidValue envelopeId;

  _isc.UuidValue budgetId;

  /// The year of the budget month (e.g. 2026).
  int year;

  /// The month of the budget month (1-12).
  int month;

  /// Amount allocated to this envelope for this month, in integer cents.
  int allocatedCents;

  /// Amount carried over from the previous month, in integer cents.
  int carryoverCents;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [MonthlyAllocation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  MonthlyAllocation copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? envelopeId,
    _isc.UuidValue? budgetId,
    int? year,
    int? month,
    int? allocatedCents,
    int? carryoverCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MonthlyAllocation',
      if (id != null) 'id': id?.toJson(),
      'envelopeId': envelopeId.toJson(),
      'budgetId': budgetId.toJson(),
      'year': year,
      'month': month,
      'allocatedCents': allocatedCents,
      'carryoverCents': carryoverCents,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MonthlyAllocation',
      if (id != null) 'id': id?.toJson(),
      'envelopeId': envelopeId.toJson(),
      'budgetId': budgetId.toJson(),
      'year': year,
      'month': month,
      'allocatedCents': allocatedCents,
      'carryoverCents': carryoverCents,
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
    required _isc.UuidValue envelopeId,
    required _isc.UuidValue budgetId,
    required int year,
    required int month,
    required int allocatedCents,
    required int carryoverCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         envelopeId: envelopeId,
         budgetId: budgetId,
         year: year,
         month: month,
         allocatedCents: allocatedCents,
         carryoverCents: carryoverCents,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [MonthlyAllocation]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  MonthlyAllocation copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? envelopeId,
    _isc.UuidValue? budgetId,
    int? year,
    int? month,
    int? allocatedCents,
    int? carryoverCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MonthlyAllocation(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      envelopeId: envelopeId ?? this.envelopeId,
      budgetId: budgetId ?? this.budgetId,
      year: year ?? this.year,
      month: month ?? this.month,
      allocatedCents: allocatedCents ?? this.allocatedCents,
      carryoverCents: carryoverCents ?? this.carryoverCents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
