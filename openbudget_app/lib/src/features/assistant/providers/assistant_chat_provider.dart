import 'dart:async';

import 'package:openbudget_app/src/features/assistant/models/assistant_chat_state.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_failure.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_timeline_item.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_api_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_conversations_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_proposals_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_usage_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'assistant_chat_provider.g.dart';

/// Runs one assistant conversation in a budget.
@riverpod
class AssistantChat extends _$AssistantChat {
  // The notifier owns the subscription and cancels it in _cancelStream and on
  // dispose.
  // ignore: cancel_subscriptions
  StreamSubscription<AgentEvent>? _subscription;

  @override
  AssistantChatState build(String budgetId) {
    ref.onDispose(_cancelStream);
    return const AssistantChatState();
  }

  /// Clears the screen for a conversation that has not been started.
  void startNewConversation() {
    _cancelStream();
    state = const AssistantChatState();
  }

  /// Opens a stored conversation and lays its messages and proposals out in
  /// time order.
  Future<void> openConversation(AgentConversation conversation) async {
    final id = conversation.id?.toString();
    if (id == null) return;

    _cancelStream();
    state = AssistantChatState(conversationId: id, isLoadingHistory: true);

    try {
      final api = ref.read(assistantApiProvider);
      final messages = await api.getMessages(id);
      final proposals = await api.listProposals(budgetId, pendingOnly: false);
      if (!ref.mounted) return;

      final items = <AssistantTimelineItem>[
        for (final message in messages)
          if (message.role == AgentMessageRole.user)
            AssistantTimelineItem.user(
              text: message.content,
              createdAt: message.createdAt,
            )
          else if (message.role == AgentMessageRole.assistant &&
              message.content.trim().isNotEmpty)
            AssistantTimelineItem.assistant(
              text: message.content,
              createdAt: message.createdAt,
            ),
        for (final proposal in proposals)
          if (proposal.id != null && proposal.conversationId?.toString() == id)
            AssistantTimelineItem.proposal(
              proposal: proposalCardFrom(proposal),
              createdAt: proposal.createdAt,
            ),
      ]..sort((a, b) => _createdAt(a).compareTo(_createdAt(b)));

      state = state.copyWith(items: items, isLoadingHistory: false);
    } on Object catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoadingHistory: false,
        failure: assistantFailureFrom(error),
      );
    }
  }

  /// Sends [message] and follows the streamed turn.
  void send(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty || state.isStreaming) return;

    _cancelStream();
    state = state.copyWith(
      items: [
        ...state.items,
        AssistantTimelineItem.user(
          text: trimmed,
          createdAt: DateTime.now(),
        ),
      ],
      isStreaming: true,
      failure: null,
    );

    final Stream<AgentEvent> stream;
    try {
      stream = ref
          .read(assistantApiProvider)
          .chat(
            budgetId: budgetId,
            conversationId: state.conversationId,
            message: trimmed,
          );
    } on Object catch (error) {
      _fail(error);
      return;
    }

    _subscription = stream.listen(
      _handleEvent,
      onError: (Object error, StackTrace stackTrace) => _fail(error),
      onDone: _finishTurn,
      cancelOnError: true,
    );
  }

  /// Sends the most recent question again after a failure.
  void retryLastMessage() {
    if (state.isStreaming) return;

    final index = state.items.lastIndexWhere(
      (item) => item is AssistantUserMessage,
    );
    if (index == -1) {
      state = state.copyWith(failure: null);
      return;
    }

    final last = state.items[index] as AssistantUserMessage;
    state = state.copyWith(
      items: state.items.sublist(0, index),
      failure: null,
    );
    send(last.text);
  }

  /// Replaces one proposal card after it was applied or dismissed.
  void updateProposal(AgentProposal proposal) {
    final card = proposalCardFrom(proposal);
    state = state.copyWith(
      items: [
        for (final item in state.items)
          switch (item) {
            final AssistantProposalItem proposalItem
                when proposalItem.proposal.id == card.id =>
              AssistantTimelineItem.proposal(
                proposal: card,
                createdAt: proposalItem.createdAt,
              ),
            _ => item,
          },
      ],
    );
  }

  void _handleEvent(AgentEvent event) {
    if (!ref.mounted) return;

    // Every event carries the conversation, so a turn that fails partway can
    // still be retried into the same chat.
    final eventConversationId = event.conversationId.toString();
    if (state.conversationId != eventConversationId) {
      state = state.copyWith(conversationId: eventConversationId);
    }

    switch (event.kind) {
      case AgentEventKind.textDelta:
        final text = event.text?.trim();
        if (text == null || text.isEmpty) return;
        _append(
          AssistantTimelineItem.assistant(
            text: text,
            createdAt: DateTime.now(),
          ),
        );
      case AgentEventKind.toolCall:
        final toolName = event.toolName;
        if (toolName == null || toolName.isEmpty) return;
        _append(
          AssistantTimelineItem.tool(
            toolName: toolName,
            createdAt: DateTime.now(),
          ),
        );
      case AgentEventKind.proposal:
        final proposal = event.proposal;
        if (proposal == null || proposal.id == null) return;
        _append(
          AssistantTimelineItem.proposal(
            proposal: proposalCardFrom(proposal),
            createdAt: proposal.createdAt,
          ),
        );
        ref.invalidate(assistantProposalsProvider(budgetId));
      case AgentEventKind.usage:
        ref.invalidate(assistantUsageProvider);
      case AgentEventKind.done:
        state = state.copyWith(isStreaming: false);
        _refreshAfterTurn();
    }
  }

  void _append(AssistantTimelineItem item) {
    state = state.copyWith(items: [...state.items, item]);
  }

  void _finishTurn() {
    if (!ref.mounted || !state.isStreaming) return;
    state = state.copyWith(isStreaming: false);
    _refreshAfterTurn();
  }

  void _refreshAfterTurn() {
    ref
      ..invalidate(assistantConversationsProvider(budgetId))
      ..invalidate(assistantProposalsProvider(budgetId))
      ..invalidate(assistantUsageProvider);
  }

  void _fail(Object error) {
    if (!ref.mounted) return;
    _subscription = null;
    state = state.copyWith(
      isLoadingHistory: false,
      isStreaming: false,
      failure: assistantFailureFrom(error),
    );
  }

  void _cancelStream() {
    final subscription = _subscription;
    _subscription = null;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
  }

  DateTime _createdAt(AssistantTimelineItem item) => switch (item) {
    AssistantUserMessage(:final createdAt) => createdAt,
    AssistantAssistantMessage(:final createdAt) => createdAt,
    AssistantToolCall(:final createdAt) => createdAt,
    AssistantProposalItem(:final createdAt) => createdAt,
  };
}
