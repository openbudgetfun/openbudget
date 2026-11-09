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

/// The tax profile of one entity, stored as the tax engine's JSON.
abstract class TaxProfileRecord
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TaxProfileRecord._({
    this.id,
    required this.entityId,
    required this.profileJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory TaxProfileRecord({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required String profileJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TaxProfileRecordImpl;

  factory TaxProfileRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return TaxProfileRecord(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      profileJson: jsonSerialization['profileJson'] as String,
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

  /// `TaxProfile.toJson` payload. Its `jurisdiction`, `entityKind` and
  /// accounting-period keys are rewritten from the entity on every save and
  /// read; the entity is their source of truth.
  String profileJson;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [TaxProfileRecord]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TaxProfileRecord copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    String? profileJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TaxProfileRecord',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'profileJson': profileJson,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TaxProfileRecord',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'profileJson': profileJson,
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
    required _isc.UuidValue entityId,
    required String profileJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         profileJson: profileJson,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [TaxProfileRecord]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TaxProfileRecord copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    String? profileJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaxProfileRecord(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      profileJson: profileJson ?? this.profileJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
