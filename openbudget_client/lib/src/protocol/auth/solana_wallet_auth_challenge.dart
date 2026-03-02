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

/// One-time login challenge used for Solana wallet signature auth.
abstract class SolanaWalletAuthChallenge implements _i1.SerializableModel {
  SolanaWalletAuthChallenge._({
    this.id,
    required this.publicKeyBase64,
    required this.challengeMessage,
    DateTime? createdAt,
    required this.expiresAt,
    this.usedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SolanaWalletAuthChallenge({
    _i1.UuidValue? id,
    required String publicKeyBase64,
    required String challengeMessage,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? usedAt,
  }) = _SolanaWalletAuthChallengeImpl;

  factory SolanaWalletAuthChallenge.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SolanaWalletAuthChallenge(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      publicKeyBase64: jsonSerialization['publicKeyBase64'] as String,
      challengeMessage: jsonSerialization['challengeMessage'] as String,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      expiresAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['expiresAt'],
      ),
      usedAt: jsonSerialization['usedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['usedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _i1.UuidValue? id;

  String publicKeyBase64;

  String challengeMessage;

  DateTime createdAt;

  DateTime expiresAt;

  DateTime? usedAt;

  /// Returns a shallow copy of this [SolanaWalletAuthChallenge]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SolanaWalletAuthChallenge copyWith({
    _i1.UuidValue? id,
    String? publicKeyBase64,
    String? challengeMessage,
    DateTime? createdAt,
    DateTime? expiresAt,
    DateTime? usedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SolanaWalletAuthChallenge',
      if (id != null) 'id': id?.toJson(),
      'publicKeyBase64': publicKeyBase64,
      'challengeMessage': challengeMessage,
      'createdAt': createdAt.toJson(),
      'expiresAt': expiresAt.toJson(),
      if (usedAt != null) 'usedAt': usedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SolanaWalletAuthChallengeImpl extends SolanaWalletAuthChallenge {
  _SolanaWalletAuthChallengeImpl({
    _i1.UuidValue? id,
    required String publicKeyBase64,
    required String challengeMessage,
    DateTime? createdAt,
    required DateTime expiresAt,
    DateTime? usedAt,
  }) : super._(
         id: id,
         publicKeyBase64: publicKeyBase64,
         challengeMessage: challengeMessage,
         createdAt: createdAt,
         expiresAt: expiresAt,
         usedAt: usedAt,
       );

  /// Returns a shallow copy of this [SolanaWalletAuthChallenge]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SolanaWalletAuthChallenge copyWith({
    Object? id = _Undefined,
    String? publicKeyBase64,
    String? challengeMessage,
    DateTime? createdAt,
    DateTime? expiresAt,
    Object? usedAt = _Undefined,
  }) {
    return SolanaWalletAuthChallenge(
      id: id is _i1.UuidValue? ? id : this.id,
      publicKeyBase64: publicKeyBase64 ?? this.publicKeyBase64,
      challengeMessage: challengeMessage ?? this.challengeMessage,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt is DateTime? ? usedAt : this.usedAt,
    );
  }
}
