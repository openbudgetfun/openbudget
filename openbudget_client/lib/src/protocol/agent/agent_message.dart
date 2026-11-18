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

import '../agent/agent_message_role.dart' as _ilmyi46t;

/// One message in an agent conversation, including hidden tool traffic.
abstract class AgentMessage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AgentMessage._({
    this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.toolCallsJson,
    this.toolCallId,
    this.citationsJson,
    bool? touchesTaxOrInvestment,
    DateTime? createdAt,
  }) : touchesTaxOrInvestment = touchesTaxOrInvestment ?? false,
       createdAt = createdAt ?? DateTime.now();

  factory AgentMessage({
    _isc.UuidValue? id,
    required _isc.UuidValue conversationId,
    required _ilmyi46t.AgentMessageRole role,
    required String content,
    String? toolCallsJson,
    String? toolCallId,
    String? citationsJson,
    bool? touchesTaxOrInvestment,
    DateTime? createdAt,
  }) = _AgentMessageImpl;

  factory AgentMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentMessage(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      conversationId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['conversationId'],
      ),
      role: _ilmyi46t.AgentMessageRole.fromJson(
        (jsonSerialization['role'] as String),
      ),
      content: jsonSerialization['content'] as String,
      toolCallsJson: jsonSerialization['toolCallsJson'] as String?,
      toolCallId: jsonSerialization['toolCallId'] as String?,
      citationsJson: jsonSerialization['citationsJson'] as String?,
      touchesTaxOrInvestment:
          jsonSerialization['touchesTaxOrInvestment'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(
              jsonSerialization['touchesTaxOrInvestment'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  _isc.UuidValue? id;

  _isc.UuidValue conversationId;

  _ilmyi46t.AgentMessageRole role;

  /// The message text. Empty for an assistant turn that only calls tools.
  String content;

  /// JSON list of OpenAI tool calls the assistant requested, when any.
  String? toolCallsJson;

  /// The tool call this message answers, for role tool.
  String? toolCallId;

  /// JSON list of the sources the assistant's citations resolved to, when
  /// the reply cited any. Each item is an `AgentCitation`.
  String? citationsJson;

  /// True when the reply cites a tax card, a tax tool result or an
  /// opportunity, so the app shows the country's disclaimer under it.
  bool touchesTaxOrInvestment;

  DateTime createdAt;

  /// Returns a shallow copy of this [AgentMessage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AgentMessage copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? conversationId,
    _ilmyi46t.AgentMessageRole? role,
    String? content,
    String? toolCallsJson,
    String? toolCallId,
    String? citationsJson,
    bool? touchesTaxOrInvestment,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentMessage',
      if (id != null) 'id': id?.toJson(),
      'conversationId': conversationId.toJson(),
      'role': role.toJson(),
      'content': content,
      if (toolCallsJson != null) 'toolCallsJson': toolCallsJson,
      if (toolCallId != null) 'toolCallId': toolCallId,
      if (citationsJson != null) 'citationsJson': citationsJson,
      'touchesTaxOrInvestment': touchesTaxOrInvestment,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AgentMessage',
      if (id != null) 'id': id?.toJson(),
      'conversationId': conversationId.toJson(),
      'role': role.toJson(),
      'content': content,
      if (toolCallsJson != null) 'toolCallsJson': toolCallsJson,
      if (toolCallId != null) 'toolCallId': toolCallId,
      if (citationsJson != null) 'citationsJson': citationsJson,
      'touchesTaxOrInvestment': touchesTaxOrInvestment,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AgentMessageImpl extends AgentMessage {
  _AgentMessageImpl({
    _isc.UuidValue? id,
    required _isc.UuidValue conversationId,
    required _ilmyi46t.AgentMessageRole role,
    required String content,
    String? toolCallsJson,
    String? toolCallId,
    String? citationsJson,
    bool? touchesTaxOrInvestment,
    DateTime? createdAt,
  }) : super._(
         id: id,
         conversationId: conversationId,
         role: role,
         content: content,
         toolCallsJson: toolCallsJson,
         toolCallId: toolCallId,
         citationsJson: citationsJson,
         touchesTaxOrInvestment: touchesTaxOrInvestment,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AgentMessage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AgentMessage copyWith({
    _isc.UuidValue? id = const _isc.$UndefinedUuidValue(),
    _isc.UuidValue? conversationId,
    _ilmyi46t.AgentMessageRole? role,
    String? content,
    Object? toolCallsJson = _Undefined,
    Object? toolCallId = _Undefined,
    Object? citationsJson = _Undefined,
    bool? touchesTaxOrInvestment,
    DateTime? createdAt,
  }) {
    return AgentMessage(
      id: id is _isc.UndefinedSentinel ? this.id : id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      toolCallsJson: toolCallsJson is String?
          ? toolCallsJson
          : this.toolCallsJson,
      toolCallId: toolCallId is String? ? toolCallId : this.toolCallId,
      citationsJson: citationsJson is String?
          ? citationsJson
          : this.citationsJson,
      touchesTaxOrInvestment:
          touchesTaxOrInvestment ?? this.touchesTaxOrInvestment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
