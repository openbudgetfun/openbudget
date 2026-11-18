import 'package:openbudget_app/src/features/assistant/providers/assistant_api_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_chat_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_proposals_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_usage_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assistant_proposal_actions_provider.g.dart';

/// Applies and dismisses proposals, then refreshes everything that shows
/// them.
@Riverpod(keepAlive: true)
class AssistantProposalActions extends _$AssistantProposalActions {
  @override
  void build() {}

  /// Applies [proposalId] and returns the resolved proposal.
  Future<AgentProposal> apply({
    required String entityId,
    required String proposalId,
  }) => _resolve(entityId: entityId, proposalId: proposalId, apply: true);

  /// Dismisses [proposalId] and returns the resolved proposal.
  Future<AgentProposal> dismiss({
    required String entityId,
    required String proposalId,
  }) => _resolve(entityId: entityId, proposalId: proposalId, apply: false);

  Future<AgentProposal> _resolve({
    required String entityId,
    required String proposalId,
    required bool apply,
  }) async {
    final api = ref.read(assistantApiProvider);
    final resolved = apply
        ? await api.applyProposal(proposalId)
        : await api.dismissProposal(proposalId);

    if (!ref.mounted) return resolved;

    ref
      ..invalidate(assistantProposalsProvider(entityId))
      ..invalidate(assistantUsageProvider);
    ref.read(assistantChatProvider(entityId).notifier).updateProposal(resolved);
    return resolved;
  }
}
