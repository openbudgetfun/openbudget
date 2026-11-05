import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// One message in a conversation, drawn as a hand-drawn paper bubble.
class AssistantMessageBubble extends HookWidget {
  const AssistantMessageBubble({
    required this.text,
    required this.isUser,
    super.key,
  });

  final String text;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.86,
        ),
        child: ObCard(
          tone: isUser ? ObTone.brand : null,
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
            vertical: SpacingTokens.xs,
          ),
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(color: palette.ink),
          ),
        ),
      ),
    );
  }
}

/// A small, quiet note that the assistant used one of its tools.
class AssistantToolChip extends HookWidget {
  const AssistantToolChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;

    return Align(
      alignment: Alignment.centerLeft,
      child: ObToneChip(
        label: label,
        icon: SkribbleIcon(
          data: OpenBudgetIcons.insight,
          size: 14,
          color: palette.mutedInk,
        ),
      ),
    );
  }
}

/// The wait while the assistant is answering.
class AssistantTypingIndicator extends HookWidget {
  const AssistantTypingIndicator({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;

    return Semantics(
      label: label,
      liveRegion: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          WiredLoadingIndicator(size: 18, color: palette.ink),
          const SizedBox(width: SpacingTokens.xs),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
            ),
          ),
        ],
      ),
    );
  }
}
