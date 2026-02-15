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

/// An envelope within a category, tracking budgeted and spent amounts.
abstract class Envelope implements _i1.SerializableModel {
  Envelope._({
    this.id,
    required this.name,
    required this.categoryId,
    required this.budgetedAmountCents,
    required this.spentAmountCents,
    required this.currencyCode,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Envelope({
    _i1.UuidValue? id,
    required String name,
    required _i1.UuidValue categoryId,
    required int budgetedAmountCents,
    required int spentAmountCents,
    required String currencyCode,
    DateTime? createdAt,
  }) = _EnvelopeImpl;

  factory Envelope.fromJson(Map<String, dynamic> jsonSerialization) {
    return Envelope(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      categoryId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['categoryId'],
      ),
      budgetedAmountCents: jsonSerialization['budgetedAmountCents'] as int,
      spentAmountCents: jsonSerialization['spentAmountCents'] as int,
      currencyCode: jsonSerialization['currencyCode'] as String,
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

  _i1.UuidValue categoryId;

  /// Budgeted amount stored as integer cents to avoid floating-point issues.
  int budgetedAmountCents;

  /// Spent amount stored as integer cents.
  int spentAmountCents;

  /// ISO 4217 currency code.
  String currencyCode;

  DateTime createdAt;

  /// Returns a shallow copy of this [Envelope]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Envelope copyWith({
    _i1.UuidValue? id,
    String? name,
    _i1.UuidValue? categoryId,
    int? budgetedAmountCents,
    int? spentAmountCents,
    String? currencyCode,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Envelope',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      'categoryId': categoryId.toJson(),
      'budgetedAmountCents': budgetedAmountCents,
      'spentAmountCents': spentAmountCents,
      'currencyCode': currencyCode,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EnvelopeImpl extends Envelope {
  _EnvelopeImpl({
    _i1.UuidValue? id,
    required String name,
    required _i1.UuidValue categoryId,
    required int budgetedAmountCents,
    required int spentAmountCents,
    required String currencyCode,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         categoryId: categoryId,
         budgetedAmountCents: budgetedAmountCents,
         spentAmountCents: spentAmountCents,
         currencyCode: currencyCode,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Envelope]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Envelope copyWith({
    Object? id = _Undefined,
    String? name,
    _i1.UuidValue? categoryId,
    int? budgetedAmountCents,
    int? spentAmountCents,
    String? currencyCode,
    DateTime? createdAt,
  }) {
    return Envelope(
      id: id is _i1.UuidValue? ? id : this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      budgetedAmountCents: budgetedAmountCents ?? this.budgetedAmountCents,
      spentAmountCents: spentAmountCents ?? this.spentAmountCents,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
