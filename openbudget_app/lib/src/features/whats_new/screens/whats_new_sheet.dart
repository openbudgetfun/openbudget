import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/whats_new/data/whats_new_repository.dart';
import 'package:openbudget_app/src/features/whats_new/models/release_notes.dart';
import 'package:openbudget_app/src/features/whats_new/providers/whats_new_providers.dart';
import 'package:openbudget_app/src/features/whats_new/widgets/whats_new_markdown.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Opens the What's new sheet.
///
/// The sheet respects the platform's reduce-motion setting by skipping its
/// entrance animation.
Future<void> showWhatsNewSheet(
  BuildContext context, {
  required WhatsNewNotesResult result,
}) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    sheetAnimationStyle: reduceMotion ? AnimationStyle.noAnimation : null,
    builder: (_) => WhatsNewSheet(result: result),
  );
}

/// The release notes for one version, in the OpenBudget hand-drawn style.
class WhatsNewSheet extends HookConsumerWidget {
  const WhatsNewSheet({required this.result, super.key});

  final WhatsNewNotesResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final notes = switch (result) {
      WhatsNewNotesAvailable(:final notes) => notes,
      WhatsNewNotesNotFound() || WhatsNewNotesInvalid() => null,
    };
    final version = switch (result) {
      WhatsNewNotesAvailable(:final version) ||
      WhatsNewNotesNotFound(:final version) ||
      WhatsNewNotesInvalid(:final version) => version,
    };
    final sections =
        notes?.sections
            .where((section) => section.entries.isNotEmpty)
            .toList(growable: false) ??
        const <ReleaseNotesSection>[];

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.md,
            0,
            SpacingTokens.md,
            SpacingTokens.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: SpacingTokens.sm),
                  children: [
                    _SheetHeader(
                      textTheme: theme.textTheme,
                      palette: palette,
                      version: version,
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    if (sections.isNotEmpty)
                      for (final section in sections) ...[
                        ObSectionHeader(
                          title: section.title,
                          padding: const EdgeInsets.fromLTRB(
                            SpacingTokens.xs,
                            SpacingTokens.md,
                            SpacingTokens.xs,
                            SpacingTokens.xs,
                          ),
                        ),
                        ObCard(
                          margin: EdgeInsets.zero,
                          padding: const EdgeInsets.all(SpacingTokens.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final (index, entry)
                                  in section.entries.indexed) ...[
                                if (index > 0)
                                  const Divider(height: SpacingTokens.lg),
                                _EntryView(entry: entry),
                              ],
                            ],
                          ),
                        ),
                      ]
                    else if (result is WhatsNewNotesInvalid)
                      ObStatePanel.problem(
                        title: l10n.whatsNewErrorTitle,
                        message: l10n.whatsNewErrorMessage,
                      )
                    else
                      ObStatePanel.empty(
                        title: l10n.whatsNewEmptyTitle,
                        message: l10n.whatsNewEmptyMessage,
                        doodle: WiredDoodleKind.sparkle,
                        tone: ObTone.neutral,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              ObFilledButton(
                onPressed: () async {
                  if (result is WhatsNewNotesAvailable) {
                    await ref
                        .read(whatsNewSeenVersionProvider.notifier)
                        .markSeen(version);
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(l10n.whatsNewGotIt),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetHeader extends HookWidget {
  const _SheetHeader({
    required this.textTheme,
    required this.palette,
    required this.version,
  });

  final TextTheme textTheme;
  final ObPalette palette;
  final String version;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ObCard(
      margin: EdgeInsets.zero,
      tone: ObTone.brand,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          ExcludeSemantics(
            child: WiredDoodle(
              kind: WiredDoodleKind.sparkle,
              size: 44,
              seed: 4,
              color: palette.brand,
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.whatsNewTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    color: palette.ink,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  l10n.whatsNewVersion(version),
                  style: textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryView extends HookWidget {
  const _EntryView({required this.entry});

  final ReleaseNotesEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            entry.summary,
            style: theme.textTheme.titleMedium?.copyWith(color: palette.ink),
          ),
        ),
        if (entry.detailsMarkdown.trim().isNotEmpty) ...[
          const SizedBox(height: SpacingTokens.sm),
          WhatsNewMarkdown(text: entry.detailsMarkdown),
        ],
      ],
    );
  }
}
