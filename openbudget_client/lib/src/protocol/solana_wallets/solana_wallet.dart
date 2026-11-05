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

/// A Solana wallet linked to an OpenBudget account.
abstract class SolanaWallet
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SolanaWallet._({
    this.id,
    required this.accountId,
    required this.budgetId,
    required this.address,
    this.label,
    required this.cluster,
    this.lastSignature,
    this.lastSyncedAt,
    required this.syncStatus,
    this.lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory SolanaWallet({
    _isc.UuidValue? id,
    required _isc.UuidValue accountId,
    required _isc.UuidValue budgetId,
    required String address,
    String? label,
    required String cluster,
    String? lastSignature,
    DateTime? lastSyncedAt,
    required String syncStatus,
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SolanaWalletImpl;

  factory SolanaWallet.fromJson(Map<String, dynamic> jsonSerialization) {
    return SolanaWallet(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      accountId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['accountId'],
      ),
      budgetId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['budgetId'],
      ),
      address: jsonSerialization['address'] as String,
      label: jsonSerialization['label'] as String?,
      cluster: jsonSerialization['cluster'] as String,
      lastSignature: jsonSerialization['lastSignature'] as String?,
      lastSyncedAt: jsonSerialization['lastSyncedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSyncedAt'],
            ),
      syncStatus: jsonSerialization['syncStatus'] as String,
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

  _isc.UuidValue accountId;

  _isc.UuidValue budgetId;

  /// Solana wallet address (base58).
  String address;

  /// Optional wallet label shown in the UI.
  String? label;

  /// Solana cluster: mainnet or devnet.
  String cluster;

  /// Last processed signature for incremental syncing.
  String? lastSignature;

  /// Last successful sync timestamp.
  DateTime? lastSyncedAt;

  /// Current sync status: pending, success, error.
  String syncStatus;

  /// Last sync error, if any.
  String? lastSyncError;

  DateTime createdAt;

  DateTime updatedAt;

  /// Returns a shallow copy of this [SolanaWallet]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SolanaWallet copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? accountId,
    _isc.UuidValue? budgetId,
    String? address,
    String? label,
    String? cluster,
    String? lastSignature,
    DateTime? lastSyncedAt = const _isc.$UndefinedDateTime(),
    String? syncStatus,
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SolanaWallet',
      if (id != null) 'id': id?.toJson(),
      'accountId': accountId.toJson(),
      'budgetId': budgetId.toJson(),
      'address': address,
      if (label != null) 'label': label,
      'cluster': cluster,
      if (lastSignature != null) 'lastSignature': lastSignature,
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      'syncStatus': syncStatus,
      if (lastSyncError != null) 'lastSyncError': lastSyncError,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SolanaWallet',
      if (id != null) 'id': id?.toJson(),
      'accountId': accountId.toJson(),
      'budgetId': budgetId.toJson(),
      'address': address,
      if (label != null) 'label': label,
      'cluster': cluster,
      if (lastSignature != null) 'lastSignature': lastSignature,
      if (lastSyncedAt != null) 'lastSyncedAt': lastSyncedAt?.toJson(),
      'syncStatus': syncStatus,
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

class _SolanaWalletImpl extends SolanaWallet {
  _SolanaWalletImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue accountId,
    required _isc.UuidValue budgetId,
    required String address,
    String? label,
    required String cluster,
    String? lastSignature,
    DateTime? lastSyncedAt,
    required String syncStatus,
    String? lastSyncError,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         accountId: accountId,
         budgetId: budgetId,
         address: address,
         label: label,
         cluster: cluster,
         lastSignature: lastSignature,
         lastSyncedAt: lastSyncedAt,
         syncStatus: syncStatus,
         lastSyncError: lastSyncError,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [SolanaWallet]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SolanaWallet copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? accountId,
    _isc.UuidValue? budgetId,
    String? address,
    Object? label = _Undefined,
    String? cluster,
    Object? lastSignature = _Undefined,
    DateTime? lastSyncedAt = const _isc.$UndefinedDateTime(),
    String? syncStatus,
    Object? lastSyncError = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SolanaWallet(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      accountId: accountId ?? this.accountId,
      budgetId: budgetId ?? this.budgetId,
      address: address ?? this.address,
      label: label is String? ? label : this.label,
      cluster: cluster ?? this.cluster,
      lastSignature: lastSignature is String?
          ? lastSignature
          : this.lastSignature,
      lastSyncedAt: lastSyncedAt is _isc.UndefinedSentinel
          ? this.lastSyncedAt
          : lastSyncedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncError: lastSyncError is String?
          ? lastSyncError
          : this.lastSyncError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
