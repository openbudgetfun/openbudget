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

/// The tax profile attached to a budget, stored as the tax engine's JSON.
abstract class TaxProfileRecord
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TaxProfileRecord._({
    this.id,
    required this.budgetId,
    required this.jurisdiction,
    required this.entityKind,
    required this.profileJson,
    this.linkedBudgetId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory TaxProfileRecord({
    _isc.UuidValue? id,
    required _isc.UuidValue budgetId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
    _isc.UuidValue? linkedBudgetId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TaxProfileRecordImpl;

  factory TaxProfileRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaxProfileRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      budgetId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      jurisdiction: jsonSerialization['jurisdiction'] as String,
      entityKind: jsonSerialization['entityKind'] as String,
      profileJson: jsonSerialization['profileJson'] as String,
      linkedBudgetId: jsonSerialization['linkedBudgetId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['linkedBudgetId'],
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

  _isc.UuidValue budgetId;

  /// ISO 3166-1 alpha-2 country code, such as GB.
  String jurisdiction;

  /// TaxEntityKind name: individual, soleTrader, or company.
  String entityKind;

  /// TaxProfile.toJson payload for the jurisdiction.
  String profileJson;

  /// Personal budget this business feeds, or the director's personal budget.
  _isc.UuidValue? linkedBudgetId;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [TaxProfileRecord]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TaxProfileRecord copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? budgetId,
    String? jurisdiction,
    String? entityKind,
    String? profileJson,
    _isc.UuidValue? linkedBudgetId = const _isc.$UndefinedUuidValue(),
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxProfileRecord',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'jurisdiction': jurisdiction,
      'entityKind': entityKind,
      'profileJson': profileJson,
      if (linkedBudgetId != null) 'linkedBudgetId': linkedBudgetId?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxProfileRecord',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'jurisdiction': jurisdiction,
      'entityKind': entityKind,
      'profileJson': profileJson,
      if (linkedBudgetId != null) 'linkedBudgetId': linkedBudgetId?.toJson(),
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _TaxProfileRecordImpl extends TaxProfileRecord {
  _TaxProfileRecordImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue budgetId,
    required String jurisdiction,
    required String entityKind,
    required String profileJson,
    _isc.UuidValue? linkedBudgetId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         budgetId: budgetId,
         jurisdiction: jurisdiction,
         entityKind: entityKind,
         profileJson: profileJson,
         linkedBudgetId: linkedBudgetId,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [TaxProfileRecord]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TaxProfileRecord copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? budgetId,
    String? jurisdiction,
    String? entityKind,
    String? profileJson,
    _isc.UuidValue? linkedBudgetId = const _isc.$UndefinedUuidValue(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaxProfileRecord(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      budgetId: budgetId ?? this.budgetId,
      jurisdiction: jurisdiction ?? this.jurisdiction,
      entityKind: entityKind ?? this.entityKind,
      profileJson: profileJson ?? this.profileJson,
      linkedBudgetId: linkedBudgetId is _isc.UndefinedSentinel
          ? this.linkedBudgetId
          : linkedBudgetId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
