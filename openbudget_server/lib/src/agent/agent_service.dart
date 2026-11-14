import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/agent/agent_access.dart';
import 'package:openbudget_server/src/agent/agent_prompt.dart';
import 'package:openbudget_server/src/agent/agent_provider_resolver.dart';
import 'package:openbudget_server/src/agent/agent_tool_registry.dart';
import 'package:openbudget_server/src/agent/agent_usage_service.dart';
import 'package:openbudget_server/src/agent/chat_completions_client.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/money_guide/citation_resolver.dart';
import 'package:serverpod/serverpod.dart';

/// Runs agent conversations: history, tools, metering and persistence.
///
/// The endpoint owns authentication and ownership checks; this service keeps
/// the model loop and can therefore be driven by tests with a mock transport.
abstract final class AgentService {
  /// The most model calls one turn may make, including tool round trips.
  static const int maxModelCalls = 6;

  /// The most characters of the first message kept as a title.
  static const int titleLength = 60;

  static final ObLogger _log = ObLogger('AgentService');

  static final ChatCompletionsClient _defaultClient = ChatCompletionsClient();

  /// Replaces the chat transport in tests.
  @visibleForTesting
  static ChatCompletionsClient? chatClientOverride;

  static ChatCompletionsClient get _client =>
      chatClientOverride ?? _defaultClient;

  /// Streams one turn as it happens.
  ///
  /// Events arrive in this order: a `usage` event after each model call, a
  /// `toolCall` for each requested tool, a `proposal` for each change the tool
  /// proposed, one `textDelta` with the assistant's reply, and finally `done`.
  static Stream<AgentEvent> chat(
    Session session, {
    required UuidValue entityId,
    required String message,
    UuidValue? conversationId,
  }) async* {
    final userId = requireAgentUserId(session);
    final trimmed = message.trim();
    if (trimmed.isEmpty) {
      throw ValidationException(message: 'Message must not be empty.');
    }

    // Resolve before writing anything, so a missing plan or key leaves no
    // half-started conversation behind.
    await AgentProviderResolver.resolve(session, userId);
    await requireOwnedEntity(session, userId: userId, entityId: entityId);

    final conversation = conversationId == null
        ? await _createConversation(
            session,
            userId: userId,
            entityId: entityId,
            title: _titleFor(trimmed),
          )
        : await _requireConversation(
            session,
            userId: userId,
            entityId: entityId,
            conversationId: conversationId,
          );
    final id = conversation.id!;

    await _appendMessage(
      session,
      conversationId: id,
      role: AgentMessageRole.user,
      content: trimmed,
    );
    await _touch(session, conversation);

    const registry = AgentToolRegistry();
    final tools = registry.definitions(canPropose: true);
    final citations = await _citationCatalogue(session, id);

    for (var call = 0; call < maxModelCalls; call++) {
      // Recheck on every pass: an earlier call in this turn may have used up
      // the remaining allowance.
      final provider = await AgentProviderResolver.resolve(session, userId);
      final result = await _client.complete(
        endpoint: provider.endpoint,
        apiKey: provider.apiKey,
        model: provider.model,
        messages: [
          {'role': 'system', 'content': AgentPrompt.system},
          ...await _history(session, id),
        ],
        tools: tools,
      );

      final usage = await AgentUsageService.record(
        session,
        userId: userId,
        conversationId: id,
        provider: provider.provider,
        model: provider.model,
        usage: result.usage,
      );
      yield AgentEvent(
        kind: AgentEventKind.usage,
        conversationId: id,
        costMicroUsd: usage.costMicroUsd,
      );

      final reply = result.message;
      // Resolve before anything is stored or sent, so the stored text, the
      // streamed text and the history the model sees next all agree. The
      // reply arrives whole, so no chunk can split a key.
      final resolution = citations.resolve(reply.content ?? '');
      final content = resolution.text;
      if (resolution.strippedCount > 0) {
        _log.info(
          'Stripped ${resolution.strippedCount} unresolved citation keys '
          'conversation=$id',
        );
      }
      final resolvedCitations = [
        for (final source in resolution.sources) _citationFor(source),
      ];
      await _appendMessage(
        session,
        conversationId: id,
        role: AgentMessageRole.assistant,
        content: content,
        toolCallsJson: reply.toolCalls.isEmpty
            ? null
            : jsonEncode([for (final call in reply.toolCalls) call.toJson()]),
        citationsJson: resolvedCitations.isEmpty
            ? null
            : jsonEncode([
                for (final citation in resolvedCitations) citation.toJson(),
              ]),
        touchesTaxOrInvestment: resolution.touchesTaxOrInvestment,
      );

      if (reply.toolCalls.isEmpty) {
        if (content.isEmpty) {
          throw AgentProviderException(
            message: 'The assistant returned an empty reply.',
          );
        }
        yield AgentEvent(
          kind: AgentEventKind.textDelta,
          conversationId: id,
          text: content,
          citations: resolvedCitations,
          touchesTaxOrInvestment: resolution.touchesTaxOrInvestment,
        );
        break;
      }

      final context = AgentToolContext(
        session: session,
        userId: userId,
        canPropose: true,
        conversationId: id,
      );
      for (final toolCall in reply.toolCalls) {
        yield AgentEvent(
          kind: AgentEventKind.toolCall,
          conversationId: id,
          toolName: toolCall.name,
        );
        final output = await _runTool(registry, context, toolCall);
        await _appendMessage(
          session,
          conversationId: id,
          role: AgentMessageRole.tool,
          content: output,
          toolCallId: toolCall.id,
        );
        citations.addToolResult(output);
        final proposal = await _proposalFrom(session, output);
        if (proposal != null) {
          yield AgentEvent(
            kind: AgentEventKind.proposal,
            conversationId: id,
            proposal: proposal,
          );
        }
      }
      await _touch(session, conversation);
    }

    _log.info('Agent turn finished conversation=$id');
    yield AgentEvent(kind: AgentEventKind.done, conversationId: id);
  }

  /// Lists the user's conversations for one entity, newest first.
  static Future<List<AgentConversation>> listConversations(
    Session session, {
    required UuidValue entityId,
  }) async {
    final userId = requireAgentUserId(session);
    await requireOwnedEntity(session, userId: userId, entityId: entityId);

    return AgentConversation.db.find(
      session,
      where: (t) => t.entityId.equals(entityId) & t.userId.equals(userId),
      orderBy: (t) => t.updatedAt.desc(),
    );
  }

  /// Returns the user and assistant messages of one conversation, oldest
  /// first. Tool traffic stays hidden.
  static Future<List<AgentMessage>> getMessages(
    Session session, {
    required UuidValue conversationId,
  }) async {
    final userId = requireAgentUserId(session);
    await _requireConversation(
      session,
      userId: userId,
      conversationId: conversationId,
    );

    final messages = await AgentMessage.db.find(
      session,
      where: (t) =>
          t.conversationId.equals(conversationId) &
          t.role.inSet({
            AgentMessageRole.user,
            AgentMessageRole.assistant,
          }),
      orderBy: (t) => t.createdAt,
    );
    return [
      for (final message in messages)
        if (message.role == AgentMessageRole.user || message.content.isNotEmpty)
          message,
    ];
  }

  /// Deletes a conversation and its messages. Proposals survive so the user
  /// can still review what was suggested.
  static Future<void> deleteConversation(
    Session session, {
    required UuidValue conversationId,
  }) async {
    final userId = requireAgentUserId(session);
    final conversation = await _requireConversation(
      session,
      userId: userId,
      conversationId: conversationId,
    );

    await AgentMessage.db.deleteWhere(
      session,
      where: (t) => t.conversationId.equals(conversationId),
    );
    await AgentConversation.db.deleteRow(session, conversation);
  }

  static Future<AgentConversation> _createConversation(
    Session session, {
    required UuidValue userId,
    required UuidValue entityId,
    required String title,
  }) {
    final now = DateTime.now().toUtc();
    return AgentConversation.db.insertRow(
      session,
      AgentConversation(
        userId: userId,
        entityId: entityId,
        title: title,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  static Future<AgentConversation> _requireConversation(
    Session session, {
    required UuidValue userId,
    required UuidValue conversationId,
    UuidValue? entityId,
  }) async {
    final conversation = await AgentConversation.db.findById(
      session,
      conversationId,
    );
    if (conversation == null ||
        conversation.userId != userId ||
        (entityId != null && conversation.entityId != entityId)) {
      throw NotFoundException(message: 'Conversation not found');
    }
    return conversation;
  }

  static Future<AgentMessage> _appendMessage(
    Session session, {
    required UuidValue conversationId,
    required AgentMessageRole role,
    required String content,
    String? toolCallsJson,
    String? toolCallId,
    String? citationsJson,
    bool touchesTaxOrInvestment = false,
  }) => AgentMessage.db.insertRow(
    session,
    AgentMessage(
      conversationId: conversationId,
      role: role,
      content: content,
      toolCallsJson: toolCallsJson,
      toolCallId: toolCallId,
      citationsJson: citationsJson,
      touchesTaxOrInvestment: touchesTaxOrInvestment,
      createdAt: DateTime.now().toUtc(),
    ),
  );

  /// Reads the keys every tool result stored in the conversation makes
  /// citable, so a later turn can cite what an earlier turn retrieved.
  static Future<CitationCatalogue> _citationCatalogue(
    Session session,
    UuidValue conversationId,
  ) async {
    final toolMessages = await AgentMessage.db.find(
      session,
      where: (t) =>
          t.conversationId.equals(conversationId) &
          t.role.equals(AgentMessageRole.tool),
      orderBy: (t) => t.createdAt,
    );
    final catalogue = CitationCatalogue();
    for (final message in toolMessages) {
      catalogue.addToolResult(message.content);
    }
    return catalogue;
  }

  static AgentCitation _citationFor(CitationSource source) => AgentCitation(
    key: source.key,
    title: source.title,
    url: source.url,
    authority: source.authority,
    verifiedOn: source.verifiedOn,
    grade: source.grade,
    announced: source.announced,
  );

  static Future<void> _touch(
    Session session,
    AgentConversation conversation,
  ) async {
    await AgentConversation.db.updateRow(
      session,
      conversation.copyWith(updatedAt: DateTime.now().toUtc()),
    );
  }

  static Future<List<Map<String, Object?>>> _history(
    Session session,
    UuidValue conversationId,
  ) async {
    final messages = await AgentMessage.db.find(
      session,
      where: (t) => t.conversationId.equals(conversationId),
      orderBy: (t) => t.createdAt,
    );

    final history = <Map<String, Object?>>[];
    for (final message in messages) {
      switch (message.role) {
        case AgentMessageRole.user:
          history.add({'role': 'user', 'content': message.content});
        case AgentMessageRole.assistant:
          history.add(_assistantMessage(message));
        case AgentMessageRole.tool:
          final toolCallId = message.toolCallId;
          if (toolCallId != null) {
            history.add({
              'role': 'tool',
              'tool_call_id': toolCallId,
              'content': message.content,
            });
          }
      }
    }
    return history;
  }

  static Map<String, Object?> _assistantMessage(AgentMessage message) {
    final toolCalls = _decodeToolCalls(message.toolCallsJson);
    return {
      'role': 'assistant',
      'content': message.content.isEmpty ? null : message.content,
      'tool_calls': ?toolCalls,
    };
  }

  static List<Object?>? _decodeToolCalls(String? json) {
    if (json == null || json.isEmpty) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      return null;
    }
    return decoded is List ? decoded : null;
  }

  static Future<String> _runTool(
    AgentToolRegistry registry,
    AgentToolContext context,
    ChatCompletionToolCall toolCall,
  ) async {
    final Map<String, Object?> arguments;
    try {
      arguments = _decodeArguments(toolCall.argumentsJson);
    } on FormatException {
      return jsonEncode({'error': 'Tool arguments were not valid JSON.'});
    }
    return registry.call(context, toolCall.name, arguments);
  }

  static Map<String, Object?> _decodeArguments(String json) {
    if (json.trim().isEmpty) return const {};
    final decoded = jsonDecode(json);
    if (decoded is Map<String, Object?>) return decoded;
    throw const FormatException('Tool arguments must be a JSON object.');
  }

  static Future<AgentProposal?> _proposalFrom(
    Session session,
    String toolOutput,
  ) async {
    final Object? decoded;
    try {
      decoded = jsonDecode(toolOutput);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, Object?>) return null;
    final proposalId = decoded['proposalId'];
    if (proposalId is! String || proposalId.isEmpty) return null;
    return AgentProposal.db.findById(
      session,
      UuidValue.fromString(proposalId),
    );
  }

  static String _titleFor(String message) => message.runes.length <= titleLength
      ? message
      : String.fromCharCodes(message.runes.take(titleLength));
}
