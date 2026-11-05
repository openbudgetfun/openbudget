import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_timeline_item.dart';

part 'assistant_proposals_state.freezed.dart';

/// The proposals for one budget, split by whether they still need a decision.
@freezed
abstract class AssistantProposalsState with _$AssistantProposalsState {
  const factory AssistantProposalsState({
    @Default([]) List<AssistantProposalCard> pending,
    @Default([]) List<AssistantProposalCard> history,
  }) = _AssistantProposalsState;
}
