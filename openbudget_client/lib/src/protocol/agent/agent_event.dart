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
import 'package:openbudget_client/src/protocol/protocol.dart' as _irkl4crj;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

import '../agent/agent_event_kind.dart' as _izvlfgta;
import '../agent/agent_proposal.dart' as _icn0jr7x;

/// One event in a streamed agent turn.
abstract class AgentEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AgentEvent._({
    required this.kind,
    required this.conversationId,
    this.text,
    this.toolName,
    this.proposal,
    this.costMicroUsd,
  });

  factory AgentEvent({
    required _izvlfgta.AgentEventKind kind,
    required _isc.UuidValue conversationId,
    String? text,
    String? toolName,
    _icn0jr7x.AgentProposal? proposal,
    int? costMicroUsd,
  }) = _AgentEventImpl;

  factory AgentEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentEvent(
      kind: _izvlfgta.AgentEventKind.fromJson(
        (jsonSerialization['kind'] as String),
      ),
      conversationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['conversationId'],
      ),
      text: jsonSerialization['text'] as String?,
      toolName: jsonSerialization['toolName'] as String?,
      proposal: jsonSerialization['proposal'] == null
          ? null
          : _irkl4crj.Protocol().deserialize<_icn0jr7x.AgentProposal>(
              jsonSerialization['proposal'],
            ),
      costMicroUsd: jsonSerialization['costMicroUsd'] as int?,
    );
  }

  _izvlfgta.AgentEventKind kind;

  _isc.UuidValue conversationId;

  /// Assistant text, for [AgentEventKind.textDelta].
  String? text;

  /// The tool being called, for [AgentEventKind.toolCall].
  String? toolName;

  /// The proposed change, for [AgentEventKind.proposal].
  _icn0jr7x.AgentProposal? proposal;

  /// Cost of the model call that just finished, for
  /// [AgentEventKind.usage]. Zero for BYO calls.
  int? costMicroUsd;

  /// Returns a shallow copy of this [AgentEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AgentEvent copyWith({
    _izvlfgta.AgentEventKind? kind,
    _isc.UuidValue? conversationId,
    String? text,
    String? toolName,
    _icn0jr7x.AgentProposal? proposal = const _UndefinedAgentEvent$proposal(),
    int? costMicroUsd,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentEvent',
      'kind': kind.toJson(),
      'conversationId': conversationId.toJson(),
      if (text != null) 'text': text,
      if (toolName != null) 'toolName': toolName,
      if (proposal != null) 'proposal': proposal?.toJson(),
      if (costMicroUsd != null) 'costMicroUsd': costMicroUsd,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentEvent',
      'kind': kind.toJson(),
      'conversationId': conversationId.toJson(),
      if (text != null) 'text': text,
      if (toolName != null) 'toolName': toolName,
      if (proposal != null) 'proposal': proposal?.toJsonForProtocol(),
      if (costMicroUsd != null) 'costMicroUsd': costMicroUsd,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UndefinedAgentEvent$proposal extends _isc.UndefinedSentinel
    implements _icn0jr7x.AgentProposal {
  const _UndefinedAgentEvent$proposal();
}

class _AgentEventImpl extends AgentEvent {
  _AgentEventImpl({
    required _izvlfgta.AgentEventKind kind,
    required _isc.UuidValue conversationId,
    String? text,
    String? toolName,
    _icn0jr7x.AgentProposal? proposal,
    int? costMicroUsd,
  }) : super._(
         kind: kind,
         conversationId: conversationId,
         text: text,
         toolName: toolName,
         proposal: proposal,
         costMicroUsd: costMicroUsd,
       );

  /// Returns a shallow copy of this [AgentEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AgentEvent copyWith({
    _izvlfgta.AgentEventKind? kind,
    _isc.UuidValue? conversationId,
    Object? text = _Undefined,
    Object? toolName = _Undefined,
    _icn0jr7x.AgentProposal? proposal = const _UndefinedAgentEvent$proposal(),
    Object? costMicroUsd = _Undefined,
  }) {
    return AgentEvent(
      kind: kind ?? this.kind,
      conversationId: conversationId ?? this.conversationId,
      text: text is String? ? text : this.text,
      toolName: toolName is String? ? toolName : this.toolName,
      proposal: proposal is _isc.UndefinedSentinel
          ? this.proposal?.copyWith()
          : proposal,
      costMicroUsd: costMicroUsd is int? ? costMicroUsd : this.costMicroUsd,
    );
  }
}
