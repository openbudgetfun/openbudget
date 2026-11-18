import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_cited_reply.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_source_number.dart';
import 'package:openbudget_app/src/features/tax/tax_formatting.dart';
import 'package:openbudget_app/src/features/tax/widgets/source_widgets.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Opens the sheet that lists one reply's [sources], scrolled to and marking
/// [focusNumber] when the person tapped a chip.
Future<void> showAssistantSourcesSheet(
  BuildContext context, {
  required List<AssistantNumberedSource> sources,
  int? focusNumber,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  useSafeArea: true,
  builder: (_) =>
      AssistantSourcesSheet(sources: sources, focusNumber: focusNumber),
);

/// Where a Money guide reply's rules and figures come from.
///
/// Each source shows its number from the reply, its title, who publishes it,
/// when it was checked, any badge that qualifies it, and a link to read it.
/// The badges and the link are the tax screens' own, so a cited source looks
/// the same wherever it appears in the app.
class AssistantSourcesSheet extends HookWidget {
  const AssistantSourcesSheet({
    required this.sources,
    this.focusNumber,
    super.key,
  });

  static const sheetKey = Key('assistant-sources-sheet');

  final List<AssistantNumberedSource> sources;
  final int? focusNumber;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final focusKey = useMemoized(GlobalKey.new);
    final focusIndex = sources.indexWhere(
      (entry) => entry.number == focusNumber,
    );

    useEffect(() {
      if (focusIndex <= 0) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final target = focusKey.currentContext;
        if (target == null || !target.mounted) return;
        Scrollable.ensureVisible(
          target,
          // Only scroll when the source is below the fold, so the sheet's
          // title stays in view whenever it can.
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
          duration: MediaQuery.disableAnimationsOf(target)
              ? Duration.zero
              : const Duration(milliseconds: 220),
        );
      });
      return null;
    }, [focusIndex]);

    return ListView(
      key: sheetKey,
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        0,
        SpacingTokens.md,
        SpacingTokens.lg,
      ),
      children: [
        ObSectionHeader(
          title: l10n.assistantSourcesTitle,
          subtitle: l10n.assistantSourcesIntro,
          padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
        ),
        for (final (index, entry) in sources.indexed)
          _SourceCard(
            key: index == focusIndex ? focusKey : null,
            entry: entry,
            highlighted: entry.number == focusNumber,
          ),
      ],
    );
  }
}

class _SourceCard extends HookWidget {
  const _SourceCard({
    required this.entry,
    required this.highlighted,
    super.key,
  });

  final AssistantNumberedSource entry;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final AssistantNumberedSource(:number, :source) = entry;
    final verifiedOn = source.verifiedOn;
    final grade = source.grade;
    final showGrade = grade != null && grade != SourceGrade.primary;

    return ObCard(
      key: ValueKey('assistant-source-$number-${source.url}'),
      raised: highlighted,
      seed: 60 + number,
      margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.sm,
        SpacingTokens.sm,
        SpacingTokens.md,
        SpacingTokens.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Align(
              alignment: Alignment.topCenter,
              child: AssistantSourceNumber(
                number: number,
                semanticLabel: l10n.assistantSourceNumber(number),
                highlighted: highlighted,
              ),
            ),
          ),
          const SizedBox(width: SpacingTokens.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MergeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: palette.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        source.authority,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.ink,
                        ),
                      ),
                      if (verifiedOn != null)
                        Text(
                          l10n.assistantSourceChecked(
                            DateFormat.yMMMd().format(verifiedOn),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.mutedInk,
                          ),
                        ),
                      if (showGrade || source.announced) ...[
                        const SizedBox(height: SpacingTokens.xs),
                        Wrap(
                          spacing: SpacingTokens.xs,
                          runSpacing: SpacingTokens.xs,
                          children: [
                            if (showGrade)
                              SourceGradeChip(
                                key: ValueKey(
                                  'assistant-source-$number-${grade.name}',
                                ),
                                grade: grade,
                              ),
                            if (source.announced)
                              ObToneChip(
                                key: ValueKey(
                                  'assistant-source-$number-announced',
                                ),
                                label: l10n.assistantSourceAnnouncedBadge,
                                tone: ObTone.underfunded,
                                icon: const SkribbleIcon(
                                  data: OpenBudgetIcons.schedule,
                                  size: 14,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SourceLinkText(
                  label: l10n.assistantSourceOpen(source.authority),
                  semanticLabel: l10n.assistantSourceOpenSemantics(
                    source.title,
                  ),
                  tooltip: source.url,
                  url: webLink(source.url),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
