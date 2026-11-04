import 'package:openbudget_server/src/agent/agent_access.dart';
import 'package:openbudget_server/src/agent/agent_proposal_service.dart';
import 'package:openbudget_server/src/agent/agent_provider_settings_service.dart';
import 'package:openbudget_server/src/agent/agent_service.dart';
import 'package:openbudget_server/src/agent/agent_usage_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// The financial assistant: chat, its history, its proposals and the user's
/// own provider settings.
///
/// Every method requires a signed-in user and checks that the budget, chat or
/// proposal belongs to them. The assistant never changes financial data; it
/// creates proposals that `applyProposal` carries out on the user's behalf.
class AgentEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Streams one assistant turn in budget `budgetId`.
  ///
  /// A null [conversationId] starts a conversation titled from [message].
  /// Events are `usage` after each model call, `toolCall` before a tool runs,
  /// `proposal` for each change suggested, one `textDelta` with the reply, and
  /// a final `done`.
  Stream<AgentEvent> chat(
    Session session,
    UuidValue budgetId,
    UuidValue? conversationId,
    String message,
  ) => AgentService.chat(
    session,
    budgetId: budgetId,
    conversationId: conversationId,
    message: message,
  );

  /// Lists the user's conversations in one budget, newest first.
  Future<List<AgentConversation>> listConversations(
    Session session,
    UuidValue budgetId,
  ) => AgentService.listConversations(session, budgetId: budgetId);

  /// Returns the visible user and assistant messages of a conversation.
  Future<List<AgentMessage>> getMessages(
    Session session,
    UuidValue conversationId,
  ) => AgentService.getMessages(session, conversationId: conversationId);

  /// Deletes a conversation and its messages, keeping its proposals.
  Future<void> deleteConversation(
    Session session,
    UuidValue conversationId,
  ) => AgentService.deleteConversation(
    session,
    conversationId: conversationId,
  );

  /// Returns how much of the included agent allowance is left.
  Future<AgentUsageView> getUsage(Session session) =>
      AgentUsageService.view(session, requireAgentUserId(session));

  /// Saves the user's own OpenAI-compatible provider and returns it without
  /// the API key.
  Future<AgentProviderSettingsView> saveProviderSettings(
    Session session,
    String baseUrl,
    String model,
    String apiKey,
  ) => AgentProviderSettingsService.save(
    session,
    userId: requireAgentUserId(session),
    baseUrl: baseUrl,
    model: model,
    apiKey: apiKey,
  );

  /// Returns the user's provider settings, or null when they use the
  /// built-in provider.
  Future<AgentProviderSettingsView?> getProviderSettings(Session session) =>
      AgentProviderSettingsService.view(session, requireAgentUserId(session));

  /// Removes the user's provider settings so the built-in provider is used.
  Future<void> clearProviderSettings(Session session) =>
      AgentProviderSettingsService.clear(session, requireAgentUserId(session));

  /// Lists the changes the assistant proposed for one budget.
  Future<List<AgentProposal>> listProposals(
    Session session,
    UuidValue budgetId, {
    bool pendingOnly = true,
  }) => AgentProposalService.list(
    session,
    budgetId: budgetId,
    pendingOnly: pendingOnly,
  );

  /// Applies a pending proposal through the normal budget and tax services.
  Future<AgentProposal> applyProposal(
    Session session,
    UuidValue proposalId,
  ) => AgentProposalService.apply(session, proposalId: proposalId);

  /// Dismisses a pending proposal without changing any data.
  Future<AgentProposal> dismissProposal(
    Session session,
    UuidValue proposalId,
  ) => AgentProposalService.dismiss(session, proposalId: proposalId);
}
