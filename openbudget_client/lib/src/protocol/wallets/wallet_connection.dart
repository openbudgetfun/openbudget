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

/// Read-only blockchain wallet connection.
abstract class WalletConnection implements _i1.SerializableModel {
  WalletConnection._({
    this.id,
    required this.budgetId,
    required this.chain,
    required this.address,
    this.label,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastSyncedAt,
    this.syncStatus,
    this.lastError,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory WalletConnection({
    _i1.UuidValue? id,
    required _i1.UuidValue budgetId,
    required String chain,
    required String address,
    String? label,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    String? syncStatus,
    String? lastError,
  }) = _WalletConnectionImpl;

  factory WalletConnection.fromJson(Map<String, dynamic> jsonSerialization) {
    return WalletConnection(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      budgetId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      chain: jsonSerialization['chain'] as String,
      address: jsonSerialization['address'] as String,
      label: jsonSerialization['label'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
      syncStatus: jsonSerialization['syncStatus'] as String?,
      lastError: jsonSerialization['lastError'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue budgetId;

  String chain;

  String address;

  String? label;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime? lastSyncedAt;

  String? syncStatus;

  String? lastError;

  /// Returns a shallow copy of this [WalletConnection]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  WalletConnection copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? budgetId,
    String? chain,
    String? address,
    String? label,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    String? syncStatus,
    String? lastError,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WalletConnection',
      if (id != null) 'id': id?.toJson(),
      'budgetId': budgetId.toJson(),
      'chain': chain,
      'address': address,
      if (label != null) 'label': label,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      if (syncStatus != null) 'syncStatus': syncStatus,
      if (lastError != null) 'lastError': lastError,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WalletConnectionImpl extends WalletConnection {
  _WalletConnectionImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue budgetId,
    required String chain,
    required String address,
    String? label,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncedAt,
    String? syncStatus,
    String? lastError,
  }) : super._(
         id: id,
         budgetId: budgetId,
         chain: chain,
         address: address,
         label: label,
         createdAt: createdAt,
         updatedAt: updatedAt,
         lastSyncedAt: lastSyncedAt,
         syncStatus: syncStatus,
         lastError: lastError,
       );

  /// Returns a shallow copy of this [WalletConnection]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  WalletConnection copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? budgetId,
    String? chain,
    String? address,
    Object? label = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? lastSyncedAt = _Undefined,
    Object? syncStatus = _Undefined,
    Object? lastError = _Undefined,
  }) {
    return WalletConnection(
      id: id is _i1.UuidValue? ? id : this.id,
      budgetId: budgetId ?? this.budgetId,
      chain: chain ?? this.chain,
      address: address ?? this.address,
      label: label is String? ? label : this.label,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncedAt: lastSyncedAt is DateTime?
          ? lastSyncedAt
          : this.lastSyncedAt,
      syncStatus: syncStatus is String? ? syncStatus : this.syncStatus,
      lastError: lastError is String? ? lastError : this.lastError,
    );
  }
}
