import 'package:openbudget_app/src/features/assistant/api/assistant_api.dart';
import 'package:openbudget_client/openbudget_client.dart';

import 'test_data.dart';

/// A fake assistant backend for the Patrol flow.
///
/// It knows one pending proposal and streams a short turn so the screen can
/// show a tool chip, a reply and a proposal without a server.
class FakeAssistantApi implements AssistantApi {
  FakeAssistantApi({
    List<AgentEvent>? events,
    List<AgentProposal>? proposals,
    AgentUsageView? usage,
  }) : events = events ?? _defaultEvents(),
       proposals = proposals ?? [_pendingProposal()],
       usage =
           usage ??
           AgentUsageView(
             provider: AgentProvider.zen,
             allowanceMicroUsd: 1000000,
             usedMicroUsd: 420000,
           );

  final List<AgentEvent> events;
  final List<AgentProposal> proposals;
  final AgentUsageView usage;
  final List<String> applyCalls = [];

  @override
  Stream<AgentEvent> chat({
    required String entityId,
    required String message,
    String? conversationId,
  }) => Stream.fromIterable(events);

  @override
  Future<List<AgentConversation>> listConversations(String entityId) async =>
      [];

  @override
  Future<List<AgentMessage>> getMessages(String conversationId) async => [];

  @override
  Future<void> deleteConversation(String conversationId) async {}

  @override
  Future<AgentUsageView> getUsage() async => usage;

  @override
  Future<AgentProviderSettingsView> saveProviderSettings({
    required String baseUrl,
    required String model,
    required String apiKey,
  }) async => AgentProviderSettingsView(
    baseUrl: baseUrl,
    model: model,
    keyHint: apiKey,
  );

  @override
  Future<AgentProviderSettingsView?> getProviderSettings() async => null;

  @override
  Future<void> clearProviderSettings() async {}

  @override
  Future<List<AgentProposal>> listProposals(
    String entityId, {
    bool pendingOnly = true,
  }) async => [
    for (final proposal in proposals)
      if (!pendingOnly || proposal.status == AgentProposalStatus.pending)
        proposal,
  ];

  @override
  Future<AgentProposal> applyProposal(String proposalId) async {
    applyCalls.add(proposalId);
    final index = proposals.indexWhere(
      (proposal) => proposal.id.toString() == proposalId,
    );
    final resolved = proposals[index].copyWith(
      status: AgentProposalStatus.applied,
      resolvedAt: DateTime(2026, 1, 2),
    );
    proposals[index] = resolved;
    return resolved;
  }

  @override
  Future<AgentProposal> dismissProposal(String proposalId) async {
    final index = proposals.indexWhere(
      (proposal) => proposal.id.toString() == proposalId,
    );
    final resolved = proposals[index].copyWith(
      status: AgentProposalStatus.dismissed,
      resolvedAt: DateTime(2026, 1, 2),
    );
    proposals[index] = resolved;
    return resolved;
  }
}

List<AgentEvent> _defaultEvents() {
  final proposal = _pendingProposal();
  final conversationId = UuidValue.fromString(
    TestData.assistantConversationId,
  );

  return [
    AgentEvent(
      kind: AgentEventKind.toolCall,
      conversationId: conversationId,
      toolName: 'get_tax_report',
    ),
    AgentEvent(
      kind: AgentEventKind.proposal,
      conversationId: conversationId,
      proposal: proposal,
    ),
    AgentEvent(
      kind: AgentEventKind.textDelta,
      conversationId: conversationId,
      text: TestData.assistantReply,
    ),
    AgentEvent(
      kind: AgentEventKind.done,
      conversationId: conversationId,
    ),
  ];
}

AgentProposal _pendingProposal() => AgentProposal(
  id: UuidValue.fromString(TestData.assistantProposalId),
  userId: UuidValue.fromString(TestData.assistantUserId),
  entityId: UuidValue.fromString(TestData.assistantEntityId),
  conversationId: UuidValue.fromString(TestData.assistantConversationId),
  kind: AgentProposalKind.moveMoney,
  payloadJson: '{}',
  summary: TestData.assistantProposalSummary,
  status: AgentProposalStatus.pending,
);
