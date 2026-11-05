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
import 'package:serverpod/serverpod.dart' as _is;

/// A personal access token without its secret.
abstract class AgentAccessTokenView
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AgentAccessTokenView._({
    required this.id,
    required this.name,
    required this.tokenPrefix,
    required this.canPropose,
    required this.createdAt,
    this.lastUsedAt,
    this.revokedAt,
  });

  factory AgentAccessTokenView({
    required _is.UuidValue id,
    required String name,
    required String tokenPrefix,
    required bool canPropose,
    required DateTime createdAt,
    DateTime? lastUsedAt,
    DateTime? revokedAt,
  }) = _AgentAccessTokenViewImpl;

  factory AgentAccessTokenView.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return AgentAccessTokenView(
      id: _is.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      tokenPrefix: jsonSerialization['tokenPrefix'] as String,
      canPropose: _is.BoolJsonExtension.fromJson(
        jsonSerialization['canPropose'],
      ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      lastUsedAt: jsonSerialization['lastUsedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['lastUsedAt']),
      revokedAt: jsonSerialization['revokedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['revokedAt']),
    );
  }

  _is.UuidValue id;

  String name;

  /// The token's first 12 characters, so the user can recognise it.
  String tokenPrefix;

  bool canPropose;

  DateTime createdAt;

  DateTime? lastUsedAt;

  DateTime? revokedAt;

  /// Returns a shallow copy of this [AgentAccessTokenView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AgentAccessTokenView copyWith({
    _is.UuidValue? id,
    String? name,
    String? tokenPrefix,
    bool? canPropose,
    DateTime? createdAt,
    DateTime? lastUsedAt = const _is.$UndefinedDateTime(),
    DateTime? revokedAt = const _is.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentAccessTokenView',
      'id': id.toJson(),
      'name': name,
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
      '__className__': 'AgentAccessTokenView',
      'id': id.toJson(),
      'name': name,
      'tokenPrefix': tokenPrefix,
      'canPropose': canPropose,
      'createdAt': createdAt.toJson(),
      if (lastUsedAt != null) 'lastUsedAt': lastUsedAt?.toJson(),
      if (revokedAt != null) 'revokedAt': revokedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _AgentAccessTokenViewImpl extends AgentAccessTokenView {
  _AgentAccessTokenViewImpl({
    required _is.UuidValue id,
    required String name,
    required String tokenPrefix,
    required bool canPropose,
    required DateTime createdAt,
    DateTime? lastUsedAt,
    DateTime? revokedAt,
  }) : super._(
         id: id,
         name: name,
         tokenPrefix: tokenPrefix,
         canPropose: canPropose,
         createdAt: createdAt,
         lastUsedAt: lastUsedAt,
         revokedAt: revokedAt,
       );

  /// Returns a shallow copy of this [AgentAccessTokenView]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AgentAccessTokenView copyWith({
    _is.UuidValue? id,
    String? name,
    String? tokenPrefix,
    bool? canPropose,
    DateTime? createdAt,
    DateTime? lastUsedAt = const _is.$UndefinedDateTime(),
    DateTime? revokedAt = const _is.$UndefinedDateTime(),
  }) {
    return AgentAccessTokenView(
      id: id ?? this.id,
      name: name ?? this.name,
      tokenPrefix: tokenPrefix ?? this.tokenPrefix,
      canPropose: canPropose ?? this.canPropose,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt is _is.UndefinedSentinel
          ? this.lastUsedAt
          : lastUsedAt,
      revokedAt: revokedAt is _is.UndefinedSentinel
          ? this.revokedAt
          : revokedAt,
    );
  }
}
