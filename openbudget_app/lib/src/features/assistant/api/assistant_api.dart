import 'package:openbudget_client/openbudget_client.dart';

/// The assistant calls the app makes.
///
/// Keeping them behind an interface lets tests drive every state without a
/// server, and keeps the screens unaware of the generated client.
abstract interface class AssistantApi {
  /// Streams one assistant turn in [budgetId].
  Stream<AgentEvent> chat({
    required String budgetId,
    required String message,
    String? conversationId,
  });

  /// Lists the conversations in one budget, newest first.
  Future<List<AgentConversation>> listConversations(String budgetId);

  /// Returns the visible messages of one conversation.
  Future<List<AgentMessage>> getMessages(String conversationId);

  /// Deletes a conversation and its messages.
  Future<void> deleteConversation(String conversationId);

  /// Returns how much of the included usage is left.
  Future<AgentUsageView> getUsage();

  /// Saves the user's own OpenAI-compatible provider.
  Future<AgentProviderSettingsView> saveProviderSettings({
    required String baseUrl,
    required String model,
    required String apiKey,
  });

  /// Returns the user's own provider settings, when they have one.
  Future<AgentProviderSettingsView?> getProviderSettings();

  /// Removes the user's own provider.
  Future<void> clearProviderSettings();

  /// Lists the changes the assistant proposed for one budget.
  Future<List<AgentProposal>> listProposals(
    String budgetId, {
    bool pendingOnly = true,
  });

  /// Applies a pending proposal through the normal budget services.
  Future<AgentProposal> applyProposal(String proposalId);

  /// Dismisses a pending proposal without changing any data.
  Future<AgentProposal> dismissProposal(String proposalId);
}

/// The real [AssistantApi], backed by the Serverpod agent endpoint.
class ServerpodAssistantApi implements AssistantApi {
  const ServerpodAssistantApi(this._endpoint);

  final EndpointAgent _endpoint;

  @override
  Stream<AgentEvent> chat({
    required String budgetId,
    required String message,
    String? conversationId,
  }) => _endpoint.chat(
    UuidValue.fromString(budgetId),
    conversationId == null ? null : UuidValue.fromString(conversationId),
    message,
  );

  @override
  Future<List<AgentConversation>> listConversations(String budgetId) =>
      _endpoint.listConversations(UuidValue.fromString(budgetId));

  @override
  Future<List<AgentMessage>> getMessages(String conversationId) =>
      _endpoint.getMessages(UuidValue.fromString(conversationId));

  @override
  Future<void> deleteConversation(String conversationId) =>
      _endpoint.deleteConversation(UuidValue.fromString(conversationId));

  @override
  Future<AgentUsageView> getUsage() => _endpoint.getUsage();

  @override
  Future<AgentProviderSettingsView> saveProviderSettings({
    required String baseUrl,
    required String model,
    required String apiKey,
  }) => _endpoint.saveProviderSettings(baseUrl, model, apiKey);

  @override
  Future<AgentProviderSettingsView?> getProviderSettings() =>
      _endpoint.getProviderSettings();

  @override
  Future<void> clearProviderSettings() => _endpoint.clearProviderSettings();

  @override
  Future<List<AgentProposal>> listProposals(
    String budgetId, {
    bool pendingOnly = true,
  }) => _endpoint.listProposals(
    UuidValue.fromString(budgetId),
    pendingOnly: pendingOnly,
  );

  @override
  Future<AgentProposal> applyProposal(String proposalId) =>
      _endpoint.applyProposal(UuidValue.fromString(proposalId));

  @override
  Future<AgentProposal> dismissProposal(String proposalId) =>
      _endpoint.dismissProposal(UuidValue.fromString(proposalId));
}
