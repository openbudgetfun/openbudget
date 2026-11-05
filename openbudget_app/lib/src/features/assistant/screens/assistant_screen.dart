import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_timeline_item.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_chat_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_proposals_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_usage_provider.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_conversations_sheet.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_failure_panel.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_message_bubble.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_proposal_card_view.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_text.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_usage_meter.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The financial assistant: a conversation about one budget, the changes it
/// proposes, and how much of the included usage is left.
class AssistantScreen extends HookConsumerWidget {
  const AssistantScreen({required this.budgetId, super.key});

  final String budgetId;

  static const composerFieldKey = Key('assistant-composer-field');
  static const sendButtonKey = Key('assistant-send-button');
  static const conversationsButtonKey = Key('assistant-conversations-button');
  static const proposalsButtonKey = Key('assistant-proposals-button');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final chat = ref.watch(assistantChatProvider(budgetId));
    final usage = ref.watch(assistantUsageProvider);
    final proposals = ref.watch(assistantProposalsProvider(budgetId));
    final controller = useTextEditingController();
    final scrollController = useScrollController();
    final hasText = useState(false);

    useEffect(() {
      void listener() => hasText.value = controller.text.trim().isNotEmpty;
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller, hasText]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!scrollController.hasClients) return;
        final target = scrollController.position.maxScrollExtent;
        if (MediaQuery.disableAnimationsOf(context)) {
          scrollController.jumpTo(target);
        } else {
          scrollController.animateTo(
            target,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
          );
        }
      });
      return null;
    }, [chat.items.length, chat.isStreaming, chat.failure, scrollController]);

    void sendComposer() {
      final text = controller.text.trim();
      if (text.isEmpty || chat.isStreaming) return;
      controller.clear();
      ref.read(assistantChatProvider(budgetId).notifier).send(text);
    }

    void sendPrompt(String prompt) {
      ref.read(assistantChatProvider(budgetId).notifier).send(prompt);
    }

    Future<void> openConversations() => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => AssistantConversationsSheet(budgetId: budgetId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.assistantTitle),
        actions: [
          IconButton(
            key: conversationsButtonKey,
            tooltip: l10n.assistantConversations,
            onPressed: openConversations,
            icon: SkribbleIcon(
              data: OpenBudgetIcons.history,
              color: palette.ink,
            ),
          ),
          IconButton(
            key: proposalsButtonKey,
            tooltip: l10n.assistantOpenProposals,
            onPressed: () => context.pushNamed(
              assistantProposalsRoute,
              pathParameters: {'id': budgetId},
            ),
            icon: SkribbleIcon(
              data: OpenBudgetIcons.note,
              color: palette.ink,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.xs,
              SpacingTokens.md,
              0,
            ),
            child: AssistantUsageMeter(
              usage: usage,
              pendingProposals: proposals.asData?.value.pending.length ?? 0,
              onOpenProposals: () => context.pushNamed(
                assistantProposalsRoute,
                pathParameters: {'id': budgetId},
              ),
            ),
          ),
          Expanded(
            child: chat.isLoadingHistory
                ? ObLoadingPanel(label: l10n.assistantLoadingHistory)
                : ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      SpacingTokens.md,
                      SpacingTokens.sm,
                      SpacingTokens.md,
                      SpacingTokens.sm,
                    ),
                    children: [
                      if (chat.items.isEmpty && chat.failure == null)
                        _EmptyConversation(onPrompt: sendPrompt)
                      else
                        for (final item in chat.items)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: SpacingTokens.xs,
                            ),
                            child: _TimelineItemView(
                              budgetId: budgetId,
                              item: item,
                            ),
                          ),
                      if (chat.isStreaming)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: SpacingTokens.xs,
                          ),
                          child: AssistantTypingIndicator(
                            label: l10n.assistantTyping,
                          ),
                        ),
                      if (chat.failure case final failure?)
                        AssistantFailurePanel(
                          budgetId: budgetId,
                          failure: failure,
                          onRetry: () => ref
                              .read(assistantChatProvider(budgetId).notifier)
                              .retryLastMessage(),
                        ),
                    ],
                  ),
          ),
          Text(
            l10n.assistantDisclaimer,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                SpacingTokens.xs,
                SpacingTokens.md,
                SpacingTokens.xs,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: ObTextField(
                      key: composerFieldKey,
                      controller: controller,
                      hintText: l10n.assistantComposerHint,
                      enabled: !chat.isStreaming,
                      onSubmitted: (_) => sendComposer(),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Tooltip(
                    message: l10n.assistantSend,
                    child: ObFilledButton(
                      key: sendButtonKey,
                      onPressed: hasText.value && !chat.isStreaming
                          ? sendComposer
                          : null,
                      child: SkribbleIcon(
                        data: OpenBudgetIcons.send,
                        size: 20,
                        color: palette.onAction,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyConversation extends HookWidget {
  const _EmptyConversation({required this.onPrompt});

  final ValueChanged<String> onPrompt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ObStatePanel.empty(
          title: l10n.assistantEmptyTitle,
          message: l10n.assistantEmptyMessage,
          doodle: WiredDoodleKind.sparkle,
        ),
        const SizedBox(height: SpacingTokens.sm),
        Wrap(
          spacing: SpacingTokens.xs,
          runSpacing: SpacingTokens.xs,
          children: [
            ActionChip(
              label: Text(l10n.assistantSuggestionTax),
              onPressed: () => onPrompt(l10n.assistantSuggestionTax),
            ),
            ActionChip(
              label: Text(l10n.assistantSuggestionCuts),
              onPressed: () => onPrompt(l10n.assistantSuggestionCuts),
            ),
            ActionChip(
              label: Text(l10n.assistantSuggestionGoals),
              onPressed: () => onPrompt(l10n.assistantSuggestionGoals),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimelineItemView extends HookWidget {
  const _TimelineItemView({required this.budgetId, required this.item});

  final String budgetId;
  final AssistantTimelineItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (item) {
      AssistantUserMessage(:final text) => AssistantMessageBubble(
        text: text,
        isUser: true,
      ),
      AssistantAssistantMessage(:final text) => AssistantMessageBubble(
        text: text,
        isUser: false,
      ),
      AssistantToolCall(:final toolName) => AssistantToolChip(
        label: assistantToolLabel(l10n, toolName),
      ),
      AssistantProposalItem(:final proposal) => AssistantProposalCardView(
        budgetId: budgetId,
        proposal: proposal,
      ),
    };
  }
}
