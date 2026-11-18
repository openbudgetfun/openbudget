import 'package:openbudget_app/src/features/assistant/models/assistant_proposals_state.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_timeline_item.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_api_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assistant_proposals_provider.g.dart';

/// The proposals for one budget, newest first in both groups.
@riverpod
class AssistantProposals extends _$AssistantProposals {
  @override
  Future<AssistantProposalsState> build(String entityId) async {
    final proposals = await ref
        .watch(assistantApiProvider)
        .listProposals(entityId, pendingOnly: false);
    final cards = proposals.map(proposalCardFrom).toList();

    return AssistantProposalsState(
      pending: [
        for (final card in cards)
          if (card.status == AgentProposalStatus.pending) card,
      ],
      history: [
        for (final card in cards)
          if (card.status != AgentProposalStatus.pending) card,
      ],
    );
  }
}
