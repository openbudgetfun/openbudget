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

/// A budget owned by a user, representing a financial plan in a specific currency.
abstract class Budget implements _i1.SerializableModel {
  Budget._({
    this.id,
    required this.name,
    required this.currencyCode,
    required this.ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Budget({
    _i1.UuidValue? id,
    required String name,
    required String currencyCode,
    required _i1.UuidValue ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BudgetImpl;

  factory Budget.fromJson(Map<String, dynamic> jsonSerialization) {
    return Budget(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      currencyCode: jsonSerialization['currencyCode'] as String,
      ownerId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['ownerId'],
      ),
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

  String name;

  /// ISO 4217 currency code (e.g. USD, EUR).
  String currencyCode;

  /// The user who owns this budget.
  _i1.UuidValue ownerId;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Budget]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Budget copyWith({
    _i1.UuidValue? id,
    String? name,
    String? currencyCode,
    _i1.UuidValue? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Budget',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'currencyCode': currencyCode,
      'ownerId': ownerId.toJson(),
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

class _BudgetImpl extends Budget {
  _BudgetImpl({
    _i1.UuidValue? id,
    required String name,
    required String currencyCode,
    required _i1.UuidValue ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         name: name,
         currencyCode: currencyCode,
         ownerId: ownerId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Budget]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Budget copyWith({
    Object? id = _Undefined,
    String? name,
    String? currencyCode,
    _i1.UuidValue? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id is _i1.UuidValue? ? id : this.id,
      name: name ?? this.name,
      currencyCode: currencyCode ?? this.currencyCode,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
