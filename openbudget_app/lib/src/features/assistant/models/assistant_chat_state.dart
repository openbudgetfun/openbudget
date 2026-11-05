import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_failure.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_timeline_item.dart';

part 'assistant_chat_state.freezed.dart';

/// Everything the assistant screen draws for one budget.
@freezed
abstract class AssistantChatState with _$AssistantChatState {
  const factory AssistantChatState({
    /// The conversation being shown, or null for a new one.
    String? conversationId,

    /// Messages and proposals in the order they happened.
    @Default([]) List<AssistantTimelineItem> items,

    /// Whether an existing conversation is being opened.
    @Default(false) bool isLoadingHistory,

    /// Whether a turn is streaming right now.
    @Default(false) bool isStreaming,

    /// The last failure, cleared when the next turn starts.
    AssistantFailure? failure,
  }) = _AssistantChatState;
}
