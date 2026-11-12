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

import '../common/sync_status.dart' as _ijl385hj;

/// A Plaid item linked to an entity, for syncing its bank accounts.
abstract class PlaidConnection
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  PlaidConnection._({
    this.id,
    required this.entityId,
    required this.plaidItemId,
    this.plaidInstitutionId,
    this.institutionName,
    _ijl385hj.SyncStatus? syncStatus,
    this.lastSyncedAt,
    this.lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : syncStatus = syncStatus ?? _ijl385hj.SyncStatus.pending,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory PlaidConnection({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required String plaidItemId,
    String? plaidInstitutionId,
    String? institutionName,
    _ijl385hj.SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PlaidConnectionImpl;

  factory PlaidConnection.fromJson(Map<String, dynamic> jsonSerialization) {
    return PlaidConnection(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      plaidItemId: jsonSerialization['plaidItemId'] as String,
      plaidInstitutionId: jsonSerialization['plaidInstitutionId'] as String?,
      institutionName: jsonSerialization['institutionName'] as String?,
      syncStatus: jsonSerialization['syncStatus'] == null
          ? null
          : _ijl385hj.SyncStatus.fromJson(
              (jsonSerialization['syncStatus'] as String),
            ),
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
      lastSyncError: jsonSerialization['lastSyncError'] as String?,
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

  String plaidItemId;

  String? plaidInstitutionId;

  String? institutionName;

  _ijl385hj.SyncStatus syncStatus;

  DateTime? lastSyncedAt;

  String? lastSyncError;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [PlaidConnection]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  PlaidConnection copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    String? plaidItemId,
    String? plaidInstitutionId,
    String? institutionName,
    _ijl385hj.SyncStatus? syncStatus,
    DateTime? lastSyncedAt = const _isc.$UndefinedDateTime(),
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlaidConnection',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'plaidItemId': plaidItemId,
      if (plaidInstitutionId != null) 'plaidInstitutionId': plaidInstitutionId,
      if (institutionName != null) 'institutionName': institutionName,
      'syncStatus': syncStatus.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      if (lastSyncError != null) 'lastSyncError': lastSyncError,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PlaidConnection',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'plaidItemId': plaidItemId,
      if (plaidInstitutionId != null) 'plaidInstitutionId': plaidInstitutionId,
      if (institutionName != null) 'institutionName': institutionName,
      'syncStatus': syncStatus.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      if (lastSyncError != null) 'lastSyncError': lastSyncError,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
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
    required _isc.UuidValue entityId,
    required String plaidItemId,
    String? plaidInstitutionId,
    String? institutionName,
    _ijl385hj.SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         plaidItemId: plaidItemId,
         plaidInstitutionId: plaidInstitutionId,
         institutionName: institutionName,
         syncStatus: syncStatus,
         lastSyncedAt: lastSyncedAt,
         lastSyncError: lastSyncError,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [PlaidConnection]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  PlaidConnection copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    String? plaidItemId,
    Object? plaidInstitutionId = _Undefined,
    Object? institutionName = _Undefined,
    _ijl385hj.SyncStatus? syncStatus,
    DateTime? lastSyncedAt = const _isc.$UndefinedDateTime(),
    Object? lastSyncError = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlaidConnection(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      plaidItemId: plaidItemId ?? this.plaidItemId,
      plaidInstitutionId: plaidInstitutionId is String?
          ? plaidInstitutionId
          : this.plaidInstitutionId,
      institutionName: institutionName is String?
          ? institutionName
          : this.institutionName,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt is _isc.UndefinedSentinel
          ? this.lastSyncedAt
          : lastSyncedAt,
      lastSyncError: lastSyncError is String?
          ? lastSyncError
          : this.lastSyncError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
