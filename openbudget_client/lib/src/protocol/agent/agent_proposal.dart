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

import '../agent/agent_proposal_kind.dart' as _i4huex49;
import '../agent/agent_proposal_status.dart' as _irqal209;

/// A change the assistant suggests but never makes itself.
abstract class AgentProposal
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AgentProposal._({
    this.id,
    required this.userId,
    required this.entityId,
    this.conversationId,
    required this.kind,
    required this.payloadJson,
    required this.summary,
    _irqal209.AgentProposalStatus? status,
    this.rulesVersion,
    DateTime? createdAt,
    this.resolvedAt,
  }) : status = status ?? _irqal209.AgentProposalStatus.pending,
       createdAt = createdAt ?? DateTime.now();

  factory AgentProposal({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required _isc.UuidValue entityId,
    _isc.UuidValue? conversationId,
    required _i4huex49.AgentProposalKind kind,
    required String payloadJson,
    required String summary,
    _irqal209.AgentProposalStatus? status,
    String? rulesVersion,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) = _AgentProposalImpl;

  factory AgentProposal.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentProposal(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      userId: _isc.UuidValueJsonExtension.fromJson(jsonSerialization['userId']),
      entityId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['entityId'],
      ),
      conversationId: jsonSerialization['conversationId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['conversationId'],
            ),
      kind: _i4huex49.AgentProposalKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      payloadJson: jsonSerialization['payloadJson'] as String,
      summary: jsonSerialization['summary'] as String,
      status: jsonSerialization['status'] == null
          ? null
          : _irqal209.AgentProposalStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      rulesVersion: jsonSerialization['rulesVersion'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['resolvedAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue userId;

  _isc.UuidValue entityId;

  /// The conversation that produced it, when it came from chat.
  _isc.UuidValue? conversationId;

  _i4huex49.AgentProposalKind kind;

  /// Kind-specific arguments, as a JSON object.
  String payloadJson;

  /// One sentence the user can decide on.
  String summary;

  _irqal209.AgentProposalStatus status;

  /// Version of the tax rule pack and guardrails the proposal was made under.
  String? rulesVersion;

  DateTime createdAt;

  DateTime? resolvedAt;

  /// Returns a shallow copy of this [AgentProposal]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AgentProposal copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    _isc.UuidValue? entityId,
    _isc.UuidValue? conversationId = const _isc.$UndefinedUuidValue(),
    _i4huex49.AgentProposalKind? kind,
    String? payloadJson,
    String? summary,
    _irqal209.AgentProposalStatus? status,
    String? rulesVersion,
    DateTime? createdAt,
    DateTime? resolvedAt = const _isc.$UndefinedDateTime(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentProposal',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'entityId': entityId.toJson(),
      if (conversationId != null) 'conversationId': conversationId?.toJson(),
      'kind': kind.toJson(),
      'payloadJson': payloadJson,
      'summary': summary,
      'status': status.toJson(),
      if (rulesVersion != null) 'rulesVersion': rulesVersion,
      'createdAt': createdAt.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentProposal',
      if (id != null) 'id': id?.toJson(),
      'userId': userId.toJson(),
      'entityId': entityId.toJson(),
      if (conversationId != null) 'conversationId': conversationId?.toJson(),
      'kind': kind.toJson(),
      'payloadJson': payloadJson,
      'summary': summary,
      'status': status.toJson(),
      if (rulesVersion != null) 'rulesVersion': rulesVersion,
      'createdAt': createdAt.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AgentProposalImpl extends AgentProposal {
  _AgentProposalImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue userId,
    required _isc.UuidValue entityId,
    _isc.UuidValue? conversationId,
    required _i4huex49.AgentProposalKind kind,
    required String payloadJson,
    required String summary,
    _irqal209.AgentProposalStatus? status,
    String? rulesVersion,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) : super._(
         id: id,
         userId: userId,
         entityId: entityId,
         conversationId: conversationId,
         kind: kind,
         payloadJson: payloadJson,
         summary: summary,
         status: status,
         rulesVersion: rulesVersion,
         createdAt: createdAt,
         resolvedAt: resolvedAt,
       );

  /// Returns a shallow copy of this [AgentProposal]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AgentProposal copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? userId,
    _isc.UuidValue? entityId,
    _isc.UuidValue? conversationId = const _isc.$UndefinedUuidValue(),
    _i4huex49.AgentProposalKind? kind,
    String? payloadJson,
    String? summary,
    _irqal209.AgentProposalStatus? status,
    Object? rulesVersion = _Undefined,
    DateTime? createdAt,
    DateTime? resolvedAt = const _isc.$UndefinedDateTime(),
  }) {
    return AgentProposal(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      userId: userId ?? this.userId,
      entityId: entityId ?? this.entityId,
      conversationId: conversationId is _isc.UndefinedSentinel
          ? this.conversationId
          : conversationId,
      kind: kind ?? this.kind,
      payloadJson: payloadJson ?? this.payloadJson,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      rulesVersion: rulesVersion is String? ? rulesVersion : this.rulesVersion,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt is _isc.UndefinedSentinel
          ? this.resolvedAt
          : resolvedAt,
    );
  }
}
