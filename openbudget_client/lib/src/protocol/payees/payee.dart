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

/// A payee (merchant or person) associated with transactions in a budget.
abstract class Payee
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Payee._({
    this.id,
    required this.name,
    required this.budgetId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Payee({
    _isc.UuidValue? id,
    required String name,
    required _isc.UuidValue budgetId,
    DateTime? createdAt,
  }) = _PayeeImpl;

  factory Payee.fromJson(Map<String, dynamic> jsonSerialization) {
    return Payee(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      budgetId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  String name;

  _isc.UuidValue budgetId;

  DateTime createdAt;

  /// Returns a shallow copy of this [Payee]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Payee copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    String? name,
    _isc.UuidValue? budgetId,
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
  Map<String, dynamic> toJsonForProtocol() {
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
    return _isc.SerializationManager.encode(this);
  }
}

class _PayeeImpl extends Payee {
  _PayeeImpl({
    _isc.UuidValue? id,
    required String name,
    required _isc.UuidValue budgetId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         budgetId: budgetId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Payee]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Payee copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    String? name,
    _isc.UuidValue? budgetId,
    DateTime? createdAt,
  }) {
    return Payee(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      name: name ?? this.name,
      budgetId: budgetId ?? this.budgetId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
