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

/// A personal access token an external agent uses to reach the MCP server.
///
/// Only the SHA-256 hash is stored, so a lost token can never be recovered,
/// only revoked and replaced.
abstract class AgentAccessToken
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AgentAccessToken._({
    this.id,
    required this.userId,
    required this.name,
    required this.tokenHash,
    required this.tokenPrefix,
    required this.canPropose,
    DateTime? createdAt,
    this.lastUsedAt,
    this.revokedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AgentAccessToken({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required String name,
    required String tokenHash,
    required String tokenPrefix,
    required bool canPropose,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    DateTime? revokedAt,
  }) = _AgentAccessTokenImpl;

  factory AgentAccessToken.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentAccessToken(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      name: jsonSerialization['name'] as String,
      tokenHash: jsonSerialization['tokenHash'] as String,
      tokenPrefix: jsonSerialization['tokenPrefix'] as String,
      canPropose: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['canPropose'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      lastUsedAt: jsonSerialization['lastUsedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastUsedAt'],
            ),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue userId;

  /// The user's label for the client, such as "Claude Code".
  String name;

  /// Lowercase hex SHA-256 of the full token.
  String tokenHash;

  /// The token's first 12 characters, for display only.
  String tokenPrefix;

  /// Whether the token may call the assistant's propose tools.
  bool canPropose;

  DateTime createdAt;

  /// Last time the token authenticated an MCP request.
  DateTime? lastUsedAt;

  /// When the user revoked it. Revoked tokens never authenticate again.
  DateTime? revokedAt;

  /// Returns a shallow copy of this [AgentAccessToken]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AgentAccessToken copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    String? name,
    String? tokenHash,
    String? tokenPrefix,
    bool? canPropose,
    DateTime? createdAt,
    DateTime? lastUsedAt = const _isc.$UndefinedDateTime(),
    DateTime? revokedAt = const _isc.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentAccessToken',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'name': name,
      'tokenHash': tokenHash,
      'tokenPrefix': tokenPrefix,
      'canPropose': canPropose,
      'createdAt': createdAt.toJson(),
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentAccessToken',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'name': name,
      'tokenHash': tokenHash,
      'tokenPrefix': tokenPrefix,
      'canPropose': canPropose,
      'createdAt': createdAt.toJson(),
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AgentAccessTokenImpl extends AgentAccessToken {
  _AgentAccessTokenImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required String name,
    required String tokenHash,
    required String tokenPrefix,
    required bool canPropose,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    DateTime? revokedAt,
  }) : super._(
         id: id,
         userId: userId,
         name: name,
         tokenHash: tokenHash,
         tokenPrefix: tokenPrefix,
         canPropose: canPropose,
         createdAt: createdAt,
         lastUsedAt: lastUsedAt,
         revokedAt: revokedAt,
       );

  /// Returns a shallow copy of this [AgentAccessToken]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AgentAccessToken copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    String? name,
    String? tokenHash,
    String? tokenPrefix,
    bool? canPropose,
    DateTime? createdAt,
    DateTime? lastUsedAt = const _isc.$UndefinedDateTime(),
    DateTime? revokedAt = const _isc.$UndefinedDateTime(),
  }) {
    return AgentAccessToken(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      tokenHash: tokenHash ?? this.tokenHash,
      tokenPrefix: tokenPrefix ?? this.tokenPrefix,
      canPropose: canPropose ?? this.canPropose,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt is _isc.UndefinedSentinel
          ? this.lastUsedAt
          : lastUsedAt,
      revokedAt: revokedAt is _isc.UndefinedSentinel
          ? this.revokedAt
          : revokedAt,
    );
  }
}
