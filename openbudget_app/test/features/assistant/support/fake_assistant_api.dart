import 'dart:async';

import 'package:openbudget_app/src/features/assistant/api/assistant_api.dart';
import 'package:openbudget_client/openbudget_client.dart';

const testBudgetId = '00000000-0000-0000-0000-000000000e01';
const testUserId = '00000000-0000-0000-0000-000000000e02';
const testConversationId = '00000000-0000-0000-0000-000000000e03';
const testProposalId = '00000000-0000-0000-0000-000000000e04';

final testBudgetUuid = UuidValue.fromString(testBudgetId);
final testUserUuid = UuidValue.fromString(testUserId);
final testConversationUuid = UuidValue.fromString(testConversationId);
final testProposalUuid = UuidValue.fromString(testProposalId);

/// One agent stream event for the shared test conversation.
AgentEvent agentEvent(
  AgentEventKind kind, {
  String? text,
  String? toolName,
  AgentProposal? proposal,
  int? costMicroUsd,
}) => AgentEvent(
  kind: kind,
  conversationId: testConversationUuid,
  text: text,
  toolName: toolName,
  proposal: proposal,
  costMicroUsd: costMicroUsd,
);

AgentUsageView testUsage({
  AgentProvider provider = AgentProvider.zen,
  int allowanceMicroUsd = 5000000,
  int usedMicroUsd = 420000,
}) => AgentUsageView(
  provider: provider,
  allowanceMicroUsd: allowanceMicroUsd,
  usedMicroUsd: usedMicroUsd,
);

AgentConversation testConversation({
  String title = 'Where can I cut spending?',
  DateTime? updatedAt,
}) => AgentConversation(
  id: testConversationUuid,
  userId: testUserUuid,
  entityId: testBudgetUuid,
  title: title,
  updatedAt: updatedAt ?? DateTime(2026, 1, 2),
);

AgentMessage testMessage(
  AgentMessageRole role,
  String content, {
  DateTime? createdAt,
}) => AgentMessage(
  id: UuidValue.fromString(
    role == AgentMessageRole.user
        ? '00000000-0000-0000-0000-000000000e11'
        : '00000000-0000-0000-0000-000000000e12',
  ),
  conversationId: testConversationUuid,
  role: role,
  content: content,
  createdAt: createdAt,
);

AgentProposal testProposal({
  String summary = r'Move $50 from Dining Out to Groceries.',
  AgentProposalKind kind = AgentProposalKind.moveMoney,
  AgentProposalStatus status = AgentProposalStatus.pending,
  DateTime? createdAt,
}) => AgentProposal(
  id: testProposalUuid,
  userId: testUserUuid,
  entityId: testBudgetUuid,
  conversationId: testConversationUuid,
  kind: kind,
  payloadJson: '{}',
  summary: summary,
  status: status,
  createdAt: createdAt,
);

/// A fake [AssistantApi] that answers from memory and records every call.
class FakeAssistantApi implements AssistantApi {
  FakeAssistantApi({
    List<AgentConversation>? conversations,
    List<AgentMessage>? messages,
    List<AgentProposal>? proposals,
    AgentUsageView? usage,
    this.providerSettings,
    this.chatEvents = const [],
    this.chatStream,
    this.chatError,
    this.conversationsError,
    this.messagesError,
    this.usageError,
    this.proposalsError,
    this.providerSettingsError,
    this.saveError,
    this.clearError,
    this.proposalActionError,
    this.deleteError,
  }) : conversations = List.of(conversations ?? const []),
       messages = List.of(messages ?? const []),
       proposals = List.of(proposals ?? const []),
       usage = usage ?? testUsage();

  final List<AgentConversation> conversations;
  final List<AgentMessage> messages;
  final List<AgentProposal> proposals;
  AgentUsageView usage;
  AgentProviderSettingsView? providerSettings;

  /// Events a default chat call streams.
  final List<AgentEvent> chatEvents;

  /// Replaces the default event list, for tests that hold the stream open.
  final Stream<AgentEvent> Function(
    String entityId,
    String? conversationId,
    String message,
  )?
  chatStream;

  final Exception? chatError;
  final Exception? conversationsError;
  final Exception? messagesError;
  final Exception? usageError;
  final Exception? proposalsError;
  final Exception? providerSettingsError;
  final Exception? saveError;
  final Exception? clearError;
  final Exception? proposalActionError;
  final Exception? deleteError;

  final List<({String entityId, String? conversationId, String message})>
  chatRequests = [];
  final List<({String baseUrl, String model, String apiKey})> saveRequests = [];
  final List<String> applyCalls = [];
  final List<String> dismissCalls = [];
  final List<String> deletedConversations = [];
  int clearCalls = 0;

  @override
  Stream<AgentEvent> chat({
    required String entityId,
    required String message,
    String? conversationId,
  }) {
    chatRequests.add((
      entityId: entityId,
      conversationId: conversationId,
      message: message,
    ));
    if (chatError case final error?) {
      return Stream.error(error);
    }
    if (chatStream case final stream?) {
      return stream(entityId, conversationId, message);
    }
    return Stream.fromIterable(chatEvents);
  }

  @override
  Future<List<AgentConversation>> listConversations(String entityId) async {
    if (conversationsError case final error?) throw error;
    return List.of(conversations);
  }

  @override
  Future<List<AgentMessage>> getMessages(String conversationId) async {
    if (messagesError case final error?) throw error;
    return [
      for (final message in messages)
        if (message.conversationId.toString() == conversationId) message,
    ];
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    if (deleteError case final error?) throw error;
    deletedConversations.add(conversationId);
    conversations.removeWhere(
      (conversation) => conversation.id.toString() == conversationId,
    );
  }

  @override
  Future<AgentUsageView> getUsage() async {
    if (usageError case final error?) throw error;
    return usage;
  }

  @override
  Future<AgentProviderSettingsView> saveProviderSettings({
    required String baseUrl,
    required String model,
    required String apiKey,
  }) async {
    if (saveError case final error?) throw error;
    saveRequests.add((baseUrl: baseUrl, model: model, apiKey: apiKey));
    final view = AgentProviderSettingsView(
      baseUrl: baseUrl,
      model: model,
      keyHint: apiKey.length <= 4
          ? apiKey
          : apiKey.substring(apiKey.length - 4),
    );
    providerSettings = view;
    return view;
  }

  @override
  Future<AgentProviderSettingsView?> getProviderSettings() async {
    if (providerSettingsError case final error?) throw error;
    return providerSettings;
  }

  @override
  Future<void> clearProviderSettings() async {
    if (clearError case final error?) throw error;
    clearCalls++;
    providerSettings = null;
  }

  @override
  Future<List<AgentProposal>> listProposals(
    String entityId, {
    bool pendingOnly = true,
  }) async {
    if (proposalsError case final error?) throw error;
    return [
      for (final proposal in proposals)
        if (!pendingOnly || proposal.status == AgentProposalStatus.pending)
          proposal,
    ];
  }

  @override
  Future<AgentProposal> applyProposal(String proposalId) async {
    if (proposalActionError case final error?) throw error;
    applyCalls.add(proposalId);
    return _resolve(proposalId, AgentProposalStatus.applied);
  }

  @override
  Future<AgentProposal> dismissProposal(String proposalId) async {
    if (proposalActionError case final error?) throw error;
    dismissCalls.add(proposalId);
    return _resolve(proposalId, AgentProposalStatus.dismissed);
  }

  AgentProposal _resolve(String proposalId, AgentProposalStatus status) {
    final index = proposals.indexWhere(
      (proposal) => proposal.id.toString() == proposalId,
    );
    if (index == -1) {
      throw StateError('No proposal with id $proposalId');
    }

    final resolved = proposals[index].copyWith(
      status: status,
      resolvedAt: DateTime(2026, 1, 2),
    );
    proposals[index] = resolved;
    return resolved;
  }
}
