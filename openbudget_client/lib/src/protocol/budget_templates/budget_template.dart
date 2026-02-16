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

/// A saved allocation template that can be applied to any month.
abstract class BudgetTemplate implements _i1.SerializableModel {
  BudgetTemplate._({
    this.id,
    required this.budgetId,
    required this.name,
    required this.allocationData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory BudgetTemplate({
    _i1.UuidValue? id,
    required _i1.UuidValue budgetId,
    required String name,
    required String allocationData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BudgetTemplateImpl;

  factory BudgetTemplate.fromJson(Map<String, dynamic> jsonSerialization) {
    return BudgetTemplate(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      name: jsonSerialization['name'] as String,
      allocationData: jsonSerialization['allocationData'] as String,
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

  _i1.UuidValue budgetId;

  /// User-chosen name for the template (e.g. "Standard Month").
  String name;

  /// JSON-encoded map of envelope ID → allocated cents.
  String allocationData;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [BudgetTemplate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  BudgetTemplate copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? budgetId,
    String? name,
    String? allocationData,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BudgetTemplate',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'name': name,
      'allocationData': allocationData,
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

class _BudgetTemplateImpl extends BudgetTemplate {
  _BudgetTemplateImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue budgetId,
    required String name,
    required String allocationData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         budgetId: budgetId,
         name: name,
         allocationData: allocationData,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [BudgetTemplate]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  BudgetTemplate copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? budgetId,
    String? name,
    String? allocationData,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetTemplate(
      id: id is _i1.UuidValue? ? id : this.id,
      budgetId: budgetId ?? this.budgetId,
      name: name ?? this.name,
      allocationData: allocationData ?? this.allocationData,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
