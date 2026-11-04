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

/// Plaid item connection persisted for syncing linked bank accounts.
abstract class PlaidConnection
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PlaidConnection._({
    this.id,
    required this.budgetId,
    required this.plaidItemId,
    required this.accessToken,
    this.institutionName,
    this.institutionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastSyncedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory PlaidConnection({
    _isc.UuidValue? id,
    required _isc.UuidValue budgetId,
    required String plaidItemId,
    required String accessToken,
    String? institutionName,
    String? institutionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
  }) = _PlaidConnectionImpl;

  factory PlaidConnection.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlaidConnection(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      budgetId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      plaidItemId: jsonSerialization['plaidItemId'] as String,
      accessToken: jsonSerialization['accessToken'] as String,
      institutionName: jsonSerialization['institutionName'] as String?,
      institutionId: jsonSerialization['institutionId'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue budgetId;

  String plaidItemId;

  String accessToken;

  String? institutionName;

  String? institutionId;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? lastSyncedAt;

  /// Returns a shallow copy of this [PlaidConnection]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PlaidConnection copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? budgetId,
    String? plaidItemId,
    String? accessToken,
    String? institutionName,
    String? institutionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt = const _isc.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlaidConnection',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'plaidItemId': plaidItemId,
      'accessToken': accessToken,
      if (institutionName != null) 'institutionName': institutionName,
      if (institutionId != null) 'institutionId': institutionId,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PlaidConnection',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'plaidItemId': plaidItemId,
      'accessToken': accessToken,
      if (institutionName != null) 'institutionName': institutionName,
      if (institutionId != null) 'institutionId': institutionId,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PlaidConnectionImpl extends PlaidConnection {
  _PlaidConnectionImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue budgetId,
    required String plaidItemId,
    required String accessToken,
    String? institutionName,
    String? institutionId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
  }) : super._(
         id: id,
         budgetId: budgetId,
         plaidItemId: plaidItemId,
         accessToken: accessToken,
         institutionName: institutionName,
         institutionId: institutionId,
         createdAt: createdAt,
         updatedAt: updatedAt,
         lastSyncedAt: lastSyncedAt,
       );

  /// Returns a shallow copy of this [PlaidConnection]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PlaidConnection copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? budgetId,
    String? plaidItemId,
    String? accessToken,
    Object? institutionName = _Undefined,
    Object? institutionId = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt = const _isc.$UndefinedDateTime(),
  }) {
    return PlaidConnection(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      budgetId: budgetId ?? this.budgetId,
      plaidItemId: plaidItemId ?? this.plaidItemId,
      accessToken: accessToken ?? this.accessToken,
      institutionName: institutionName is String?
          ? institutionName
          : this.institutionName,
      institutionId: institutionId is String?
          ? institutionId
          : this.institutionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt is _isc.UndefinedSentinel
          ? this.lastSyncedAt
          : lastSyncedAt,
    );
  }
}
