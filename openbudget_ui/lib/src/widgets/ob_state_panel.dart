import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/src/flourish/ob_spot_doodle.dart';
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
/// action. An empty state is an invitation: it leads with a doodle that
/// draws itself on over a blot of spot ink. A problem stays quiet: a small
/// cloud on the overspent wash, and a message that stays selectable so it
/// can be reported.
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

  /// Picks the blot behind an empty state's doodle: the action pink for
  /// [ObTone.brand], the highlighter for [ObTone.neutral], and the tone's
  /// wash otherwise.
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
    final spot = switch (tone) {
      ObTone.brand => palette.action,
      ObTone.neutral => palette.highlighter,
      _ => palette.wash(tone),
    };
    final align = isProblem
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;
    final textAlign = isProblem ? TextAlign.start : TextAlign.center;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: ObRoughDecoration(
        color: palette.surface,
        outline: palette.quietPen,
        radius: 18,
        seed: 67,
      ),
      child: Column(
        crossAxisAlignment: align,
        children: [
          ObSpotDoodle(
            kind: doodle,
            spot: spot,
            size: isProblem ? 72 : 112,
            seed: isProblem ? 5 : 3,
          ),
          SizedBox(height: isProblem ? 12 : 16),
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: textAlign,
              style:
                  (isProblem
                          ? theme.textTheme.titleLarge
                          : theme.textTheme.headlineSmall)
                      ?.copyWith(color: palette.ink),
            ),
          ),
          if (message case final text?) ...[
            const SizedBox(height: 8),
            if (isProblem)
              SelectableText(text, style: messageStyle)
            else
              Text(text, textAlign: textAlign, style: messageStyle),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(
              alignment: isProblem ? WrapAlignment.start : WrapAlignment.center,
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
              size: 32,
              color: palette.brand,
              strokeWidth: 3,
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
