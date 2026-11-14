import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_source.dart';
import 'package:openbudget_client/openbudget_client.dart';

part 'assistant_timeline_item.freezed.dart';

/// One entry in the conversation, ready to draw.
///
/// The server stores messages and proposals separately; the screen shows them
/// in the order they happened in one list.
@freezed
sealed class AssistantTimelineItem with _$AssistantTimelineItem {
  /// Something the person asked.
  const factory AssistantTimelineItem.user({
    required String text,
    required DateTime createdAt,
  }) = AssistantUserMessage;

  /// Something the Money guide answered.
  const factory AssistantTimelineItem.assistant({
    required String text,
    required DateTime createdAt,

    /// The sources the reply's `[^key]` markers resolved to.
    @Default([]) List<AssistantSource> sources,

    /// Whether the reply touches tax or investments, so it carries the
    /// disclaimer.
    @Default(false) bool touchesTaxOrInvestment,
  }) = AssistantAssistantMessage;

  /// A tool the assistant used while answering. These only exist while the
  /// turn is live; the stored history keeps the reply, not its steps.
  const factory AssistantTimelineItem.tool({
    required String toolName,
    required DateTime createdAt,
  }) = AssistantToolCall;

  /// A change waiting for the person to apply or dismiss.
  const factory AssistantTimelineItem.proposal({
    required AssistantProposalCard proposal,
    required DateTime createdAt,
  }) = AssistantProposalItem;
}

/// The parts of an [AgentProposal] the card needs, detached from the mutable
/// server model.
@freezed
abstract class AssistantProposalCard with _$AssistantProposalCard {
  const factory AssistantProposalCard({
    required String id,
    required String summary,
    required AgentProposalKind kind,
    required AgentProposalStatus status,
    required DateTime createdAt,
  }) = _AssistantProposalCard;
}

/// Maps a stored proposal to its card data.
AssistantProposalCard proposalCardFrom(AgentProposal proposal) =>
    AssistantProposalCard(
      id: proposal.id.toString(),
      summary: proposal.summary,
      kind: proposal.kind,
      status: proposal.status,
      createdAt: proposal.createdAt,
    );
