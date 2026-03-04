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

/// Mapping between a Solana wallet public key and an auth user.
abstract class SolanaWalletAuthAccount implements _i1.SerializableModel {
  SolanaWalletAuthAccount._({
    this.id,
    required this.authUserId,
    required this.publicKeyBase64,
    this.walletAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAuthenticatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now(),
       lastAuthenticatedAt = lastAuthenticatedAt ?? DateTime.now();

  factory SolanaWalletAuthAccount({
    _i1.UuidValue? id,
    required _i1.UuidValue authUserId,
    required String publicKeyBase64,
    String? walletAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAuthenticatedAt,
  }) = _SolanaWalletAuthAccountImpl;

  factory SolanaWalletAuthAccount.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SolanaWalletAuthAccount(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      publicKeyBase64: jsonSerialization['publicKeyBase64'] as String,
      walletAddress: jsonSerialization['walletAddress'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
      lastAuthenticatedAt: jsonSerialization['lastAuthenticatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastAuthenticatedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  _i1.UuidValue authUserId;

  String publicKeyBase64;

  String? walletAddress;

  DateTime createdAt;

  DateTime updatedAt;

  DateTime lastAuthenticatedAt;

  /// Returns a shallow copy of this [SolanaWalletAuthAccount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SolanaWalletAuthAccount copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    String? publicKeyBase64,
    String? walletAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAuthenticatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SolanaWalletAuthAccount',
      if (id != null) 'id': id?.toJson(),
      'authUserId': authUserId.toJson(),
      'publicKeyBase64': publicKeyBase64,
      if (walletAddress != null) 'walletAddress': walletAddress,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
      'lastAuthenticatedAt': lastAuthenticatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SolanaWalletAuthAccountImpl extends SolanaWalletAuthAccount {
  _SolanaWalletAuthAccountImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue authUserId,
    required String publicKeyBase64,
    String? walletAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAuthenticatedAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         publicKeyBase64: publicKeyBase64,
         walletAddress: walletAddress,
         createdAt: createdAt,
         updatedAt: updatedAt,
         lastAuthenticatedAt: lastAuthenticatedAt,
       );

  /// Returns a shallow copy of this [SolanaWalletAuthAccount]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SolanaWalletAuthAccount copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? authUserId,
    String? publicKeyBase64,
    Object? walletAddress = _Undefined,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastAuthenticatedAt,
  }) {
    return SolanaWalletAuthAccount(
      id: id is _i1.UuidValue? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      publicKeyBase64: publicKeyBase64 ?? this.publicKeyBase64,
      walletAddress: walletAddress is String?
          ? walletAddress
          : this.walletAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastAuthenticatedAt: lastAuthenticatedAt ?? this.lastAuthenticatedAt,
    );
  }
}
