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
import 'package:openbudget_core/openbudget_core.dart' as _ifz8weqz;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import '../common/sync_status.dart' as _ijl385hj;

/// A read-only blockchain wallet whose holdings value one crypto account.
abstract class Wallet
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Wallet._({
    this.id,
    required this.entityId,
    required this.accountId,
    required this.network,
    required this.address,
    this.label,
    this.lastSignature,
    _ijl385hj.SyncStatus? syncStatus,
    this.lastSyncedAt,
    this.lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : syncStatus = syncStatus ?? _ijl385hj.SyncStatus.pending,
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory Wallet({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required _isc.UuidValue accountId,
    required _ifz8weqz.WalletNetwork network,
    required String address,
    String? label,
    String? lastSignature,
    _ijl385hj.SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WalletImpl;

  factory Wallet.fromJson(Map<String, dynamic> jsonSerialization) {
    return Wallet(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      accountId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      network: _ifz8weqz.WalletNetwork.fromJson(
        (jsonSerialization['network'] as String),
      ),
      address: jsonSerialization['address'] as String,
      label: jsonSerialization['label'] as String?,
      lastSignature: jsonSerialization['lastSignature'] as String?,
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

  /// The crypto account carrying the wallet's value into net worth.
  _isc.UuidValue accountId;

  _ifz8weqz.WalletNetwork network;

  /// Base58 address.
  String address;

  String? label;

  /// Newest signature already processed, for incremental sync.
  String? lastSignature;

  _ijl385hj.SyncStatus syncStatus;

  DateTime? lastSyncedAt;

  String? lastSyncError;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [Wallet]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Wallet copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    _isc.UuidValue? accountId,
    _ifz8weqz.WalletNetwork? network,
    String? address,
    String? label,
    String? lastSignature,
    _ijl385hj.SyncStatus? syncStatus,
    DateTime? lastSyncedAt = const _isc.$UndefinedDateTime(),
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Wallet',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'accountId': accountId.toJson(),
      'network': network.toJson(),
      'address': address,
      if (label != null) 'label': label,
      if (lastSignature != null) 'lastSignature': lastSignature,
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
      '__className__': 'Wallet',
      if (id != null) 'id': id?.toJson(),
      'entityId': entityId.toJson(),
      'accountId': accountId.toJson(),
      'network': network.toJson(),
      'address': address,
      if (label != null) 'label': label,
      if (lastSignature != null) 'lastSignature': lastSignature,
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

class _WalletImpl extends Wallet {
  _WalletImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue entityId,
    required _isc.UuidValue accountId,
    required _ifz8weqz.WalletNetwork network,
    required String address,
    String? label,
    String? lastSignature,
    _ijl385hj.SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         entityId: entityId,
         accountId: accountId,
         network: network,
         address: address,
         label: label,
         lastSignature: lastSignature,
         syncStatus: syncStatus,
         lastSyncedAt: lastSyncedAt,
         lastSyncError: lastSyncError,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [Wallet]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Wallet copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? entityId,
    _isc.UuidValue? accountId,
    _ifz8weqz.WalletNetwork? network,
    String? address,
    Object? label = _Undefined,
    Object? lastSignature = _Undefined,
    _ijl385hj.SyncStatus? syncStatus,
    DateTime? lastSyncedAt = const _isc.$UndefinedDateTime(),
    Object? lastSyncError = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Wallet(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      entityId: entityId ?? this.entityId,
      accountId: accountId ?? this.accountId,
      network: network ?? this.network,
      address: address ?? this.address,
      label: label is String? ? label : this.label,
      lastSignature: lastSignature is String?
          ? lastSignature
          : this.lastSignature,
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
