import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/theme/ob_palette.dart';
import 'package:openbudget_ui/src/theme/ob_rough_decoration.dart';
import 'package:skribble/skribble.dart';

/// A next step offered by an [ObStatePanel].
@immutable
class ObStateAction {
  const ObStateAction({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

enum _ObStateKind { empty, problem }

/// What a screen shows in place of content: nothing yet, or a request that
/// did not work.
///
/// Both are a paper panel with a plain title, what is known, and the next
/// action. An empty state leads with a doodle on its tone's wash because it
/// is an invitation. A problem stays on quiet paper with a red-pencil rule,
/// and its message stays selectable so it can be reported.
class ObStatePanel extends HookWidget {
  const ObStatePanel.empty({
    required this.title,
    this.message,
    this.action,
    this.secondaryAction,
    this.doodle = WiredDoodleKind.sprout,
    this.tone = ObTone.brand,
    super.key,
  }) : _kind = _ObStateKind.empty;

  const ObStatePanel.problem({
    required this.title,
    this.message,
    this.action,
    this.secondaryAction,
    super.key,
  }) : _kind = _ObStateKind.problem,
       doodle = WiredDoodleKind.cloud,
       tone = ObTone.overspent;

  final _ObStateKind _kind;
  final String title;
  final String? message;
  final ObStateAction? action;
  final ObStateAction? secondaryAction;

  /// The drawing an empty state leads with. Decoration only.
  final WiredDoodleKind doodle;

  /// The wash behind an empty state's doodle.
  final ObTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final isProblem = _kind == _ObStateKind.problem;
    final actions = [?action, ?secondaryAction];
    final messageStyle = theme.textTheme.bodyMedium?.copyWith(
      color: palette.mutedInk,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ObRoughDecoration(
        color: palette.surface,
        outline: palette.quietPen,
        seed: 67,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: ObRoughDecoration(
                color: palette.wash(tone),
                outline: palette.quietPen,
                radius: 14,
                seed: 71,
              ),
              child: WiredDoodle(
                kind: doodle,
                size: 48,
                seed: 3,
                color: palette.hue(tone),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(color: palette.ink),
            ),
          ),
          if (message case final text?) ...[
            const SizedBox(height: 8),
            if (isProblem)
              SelectableText(text, style: messageStyle)
            else
              Text(text, style: messageStyle),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final (index, item) in actions.indexed)
                  if (index == 0)
                    FilledButton(
                      onPressed: item.onPressed,
                      child: Text(item.label),
                    )
                  else
                    OutlinedButton(
                      onPressed: item.onPressed,
                      child: Text(item.label),
                    ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// A labelled wait in place of content.
///
/// A bare spinner tells a screen reader nothing, so the label is both shown
/// and announced.
class ObLoadingPanel extends HookWidget {
  const ObLoadingPanel({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Semantics(
      label: label,
      liveRegion: true,
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            WiredLoadingIndicator(
              size: 28,
              color: palette.ink,
              strokeWidth: 2.2,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.mutedInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
