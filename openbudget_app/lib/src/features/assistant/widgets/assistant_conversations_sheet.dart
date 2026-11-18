import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_api_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_chat_provider.dart';
import 'package:openbudget_app/src/features/assistant/providers/assistant_conversations_provider.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The conversations in one budget, opened as a sheet over the chat.
class AssistantConversationsSheet extends HookConsumerWidget {
  const AssistantConversationsSheet({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final conversations = ref.watch(assistantConversationsProvider(entityId));
    final current = ref.watch(assistantChatProvider(entityId)).conversationId;

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.62,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                SpacingTokens.sm,
                SpacingTokens.md,
                SpacingTokens.xs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.assistantConversations,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  ObTextButton(
                    onPressed: () {
                      ref
                          .read(assistantChatProvider(entityId).notifier)
                          .startNewConversation();
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.assistantNewConversation),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: conversations.when(
                loading: () =>
                    ObLoadingPanel(label: l10n.assistantLoadingHistory),
                error: (_, _) => SingleChildScrollView(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: ObStatePanel.problem(
                    title: l10n.assistantConversationsLoadError,
                    action: ObStateAction(
                      label: l10n.assistantRetry,
                      onPressed: () => ref.invalidate(
                        assistantConversationsProvider(entityId),
                      ),
                    ),
                  ),
                ),
                data: (items) {
                  if (items.isEmpty) {
                    return ListView(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      children: [
                        ObStatePanel.empty(
                          title: l10n.assistantNewConversation,
                          message: l10n.assistantConversationListEmpty,
                          doodle: WiredDoodleKind.scribble,
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(
                      bottom: SpacingTokens.md,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final conversation = items[index];
                      final id = conversation.id?.toString();
                      final isCurrent = id != null && id == current;

                      return ListTile(
                        selected: isCurrent,
                        leading: SkribbleIcon(
                          data: isCurrent
                              ? OpenBudgetIcons.history
                              : OpenBudgetIcons.note,
                          color: isCurrent ? palette.brand : palette.mutedInk,
                        ),
                        title: Text(
                          conversation.title.trim().isEmpty
                              ? l10n.assistantUntitledConversation
                              : conversation.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          _formatDate(context, conversation.updatedAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.mutedInk,
                          ),
                        ),
                        trailing: IconButton(
                          tooltip: l10n.assistantConversationDelete,
                          onPressed: () => _delete(
                            context,
                            ref,
                            l10n,
                            conversation,
                          ),
                          icon: SkribbleIcon(
                            data: OpenBudgetIcons.delete,
                            size: 18,
                            color: palette.mutedInk,
                          ),
                        ),
                        onTap: () {
                          final chat = ref.read(
                            assistantChatProvider(entityId).notifier,
                          );
                          Navigator.of(context).pop();
                          unawaited(chat.openConversation(conversation));
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AgentConversation conversation,
  ) async {
    final id = conversation.id?.toString();
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.assistantConversationDeleteTitle),
        content: Text(l10n.assistantConversationDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.assistantConversationDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(assistantApiProvider).deleteConversation(id);
      if (!context.mounted) return;

      ref.invalidate(assistantConversationsProvider(entityId));
      if (ref.read(assistantChatProvider(entityId)).conversationId == id) {
        ref
            .read(assistantChatProvider(entityId).notifier)
            .startNewConversation();
      }
      showAppToast(
        context,
        message: l10n.assistantConversationDeletedToast,
        variant: AppToastVariant.success,
      );
    } on Object {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.assistantConversationDeleteError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  String _formatDate(BuildContext context, DateTime timestamp) =>
      MaterialLocalizations.of(context).formatShortDate(timestamp.toLocal());
}
