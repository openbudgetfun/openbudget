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

/// A payee (merchant or person) associated with transactions in a budget.
abstract class Payee implements _i1.SerializableModel {
  Payee._({
    this.id,
    required this.name,
    required this.budgetId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Payee({
    _i1.UuidValue? id,
    required String name,
    required _i1.UuidValue budgetId,
    DateTime? createdAt,
  }) = _PayeeImpl;

  factory Payee.fromJson(Map<String, dynamic> jsonSerialization) {
    return Payee(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  String name;

  _i1.UuidValue budgetId;

  DateTime createdAt;

  /// Returns a shallow copy of this [Payee]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Payee copyWith({
    _i1.UuidValue? id,
    String? name,
    _i1.UuidValue? budgetId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Payee',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'budgetId': budgetId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PayeeImpl extends Payee {
  _PayeeImpl({
    _i1.UuidValue? id,
    required String name,
    required _i1.UuidValue budgetId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         budgetId: budgetId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Payee]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Payee copyWith({
    Object? id = _Undefined,
    String? name,
    _i1.UuidValue? budgetId,
    DateTime? createdAt,
  }) {
    return Payee(
      id: id is _i1.UuidValue? ? id : this.id,
      name: name ?? this.name,
      budgetId: budgetId ?? this.budgetId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
