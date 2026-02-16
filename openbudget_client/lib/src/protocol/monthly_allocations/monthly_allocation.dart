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

/// Per-month allocation for an envelope, enabling monthly budget cycles.
abstract class MonthlyAllocation implements _i1.SerializableModel {
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
    _i1.UuidValue? id,
    required _i1.UuidValue envelopeId,
    required _i1.UuidValue budgetId,
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
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      envelopeId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['envelopeId'],
      ),
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      year: jsonSerialization['year'] as int,
      month: jsonSerialization['month'] as int,
      allocatedCents: jsonSerialization['allocatedCents'] as int,
      carryoverCents: jsonSerialization['carryoverCents'] as int,
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

  _i1.UuidValue budgetId;

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
  @_i1.useResult
  MonthlyAllocation copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? envelopeId,
    _i1.UuidValue? budgetId,
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
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MonthlyAllocationImpl extends MonthlyAllocation {
  _MonthlyAllocationImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue envelopeId,
    required _i1.UuidValue budgetId,
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
  @_i1.useResult
  @override
  MonthlyAllocation copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? envelopeId,
    _i1.UuidValue? budgetId,
    int? year,
    int? month,
    int? allocatedCents,
    int? carryoverCents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MonthlyAllocation(
      id: id is _i1.UuidValue? ? id : this.id,
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
