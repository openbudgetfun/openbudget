import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_cited_reply.dart';
import 'package:openbudget_app/src/features/assistant/models/assistant_source.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_sources_sheet.dart';
import 'package:openbudget_app/src/features/assistant/widgets/assistant_text.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The smallest side of the area that opens an inline citation mark.
const double _citationTarget = 44;

/// How a citation number reads inline: the number between no-break spaces
/// (U+00A0). The spaces pad the mark's wash, and because they never allow a
/// line break, the mark stays on the line of the word it follows and keeps
/// the punctuation after it.
String assistantCitationMark(String number) => '\u00A0$number\u00A0';

/// Room inside a bubble for the pencil outline, which wobbles a few points
/// inwards, so it never runs through the first or last letters.
const EdgeInsets _bubblePadding = EdgeInsets.symmetric(
  horizontal: SpacingTokens.md,
  vertical: SpacingTokens.sm + SpacingTokens.xs,
);

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
          padding: _bubblePadding,
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(color: palette.ink),
          ),
        ),
      ),
    );
  }
}

/// A Money guide reply: its text with numbered citation chips, a button that
/// opens its sources, and its country's disclaimer when it touches tax or
/// investments.
///
/// Each citation is a number on a spot-ink wash, set as text so it wraps with
/// the word it follows and never changes the line height. A tap on a mark
/// opens the sources sheet at that source; a tap that misses the small mark
/// but lands within its 44-point target opens it too.
class AssistantReplyBubble extends HookWidget {
  const AssistantReplyBubble({
    required this.text,
    this.sources = const [],
    this.touchesTaxOrInvestment = false,
    this.jurisdiction,
    super.key,
  });

  static const sourcesButtonKey = Key('assistant-reply-sources-button');
  static const disclaimerKey = Key('assistant-reply-disclaimer');

  /// The reply text with its `[^key]` markers.
  final String text;

  /// The sources the markers resolved to.
  final List<AssistantSource> sources;

  /// Whether the reply carries the disclaimer.
  final bool touchesTaxOrInvestment;

  /// The tax jurisdiction of the entity being discussed, which picks the
  /// disclaimer's wording. Null for a country with no rule pack.
  final TaxJurisdiction? jurisdiction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final reply = useMemoized(
      () => parseCitedReply(text, sources),
      [text, sources],
    );
    final citations = reply.segments.whereType<AssistantReplyCitation>().toList(
      growable: false,
    );
    final textKey = useMemoized(GlobalKey.new);

    void openSources([int? focusNumber]) => showAssistantSourcesSheet(
      context,
      sources: reply.sources,
      focusNumber: focusNumber,
    );

    // One recognizer per mark, so a direct tap and a screen reader's
    // activation both open the sheet at that source.
    final recognizers = useMemoized(
      () => [
        for (final citation in citations)
          TapGestureRecognizer()..onTap = () => openSources(citation.number),
      ],
      [reply],
    );
    useEffect(
      () => () {
        for (final recognizer in recognizers) {
          recognizer.dispose();
        }
      },
      [recognizers],
    );

    final numberFormat = NumberFormat.decimalPattern();
    final bodyStyle = theme.textTheme.bodyLarge?.copyWith(color: palette.ink);
    final markStyle = bodyStyle?.copyWith(
      fontSize: (bodyStyle.fontSize ?? 16) * 0.85,
      fontWeight: FontWeight.w700,
      height: 1,
      fontFeatures: const [FontFeature.tabularFigures()],
      backgroundColor: palette.brandWash,
    );

    // Where each mark sits in the paragraph's text, to find it from a tap.
    final markRanges = <TextRange>[];
    var offset = 0;
    var markIndex = 0;
    final spans = <InlineSpan>[];
    for (final segment in reply.segments) {
      switch (segment) {
        case AssistantReplyText(:final text):
          spans.add(TextSpan(text: text));
          offset += text.length;
        case AssistantReplyCitation(:final number, :final title):
          final mark = assistantCitationMark(numberFormat.format(number));
          spans.add(
            TextSpan(
              text: mark,
              style: markStyle,
              recognizer: recognizers[markIndex],
              mouseCursor: SystemMouseCursors.click,
              semanticsLabel: l10n.assistantCitationSemantics(number, title),
            ),
          );
          markRanges.add(TextRange(start: offset, end: offset + mark.length));
          offset += mark.length;
          markIndex++;
      }
    }

    // A mark is smaller than a fingertip, so a tap that lands near one but
    // misses its glyphs opens the nearest mark whose 44-point target holds it.
    void openNearestMark(TapUpDetails details) {
      final paragraph = textKey.currentContext?.findRenderObject();
      if (paragraph is! RenderParagraph) return;
      final tap = paragraph.globalToLocal(details.globalPosition);
      int? nearest;
      var nearestDistance = double.infinity;
      for (final (index, range) in markRanges.indexed) {
        final boxes = paragraph.getBoxesForSelection(
          TextSelection(baseOffset: range.start, extentOffset: range.end),
        );
        for (final box in boxes) {
          final mark = box.toRect();
          final target = Rect.fromCenter(
            center: mark.center,
            width: math.max(mark.width, _citationTarget),
            height: math.max(mark.height, _citationTarget),
          );
          if (!target.contains(tap)) continue;
          final distance = (mark.center - tap).distanceSquared;
          if (distance < nearestDistance) {
            nearestDistance = distance;
            nearest = citations[index].number;
          }
        }
      }
      if (nearest != null) openSources(nearest);
    }

    final body = Text.rich(
      key: textKey,
      TextSpan(style: bodyStyle, children: spans),
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.86,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: citations.isEmpty ? null : openNearestMark,
              child: ObCard(padding: _bubblePadding, child: body),
            ),
            if (reply.hasSources || touchesTaxOrInvestment)
              Padding(
                padding: const EdgeInsets.only(left: SpacingTokens.xs),
                child: Wrap(
                  spacing: SpacingTokens.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (reply.hasSources)
                      _SourcesButton(
                        key: sourcesButtonKey,
                        label: l10n.assistantSourcesButton(
                          reply.sourceCount,
                        ),
                        onTap: openSources,
                      ),
                    if (touchesTaxOrInvestment)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: SpacingTokens.xs,
                        ),
                        child: Text(
                          assistantReplyDisclaimer(l10n, jurisdiction),
                          key: disclaimerKey,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.mutedInk,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The quiet button under a reply that lists its sources.
class _SourcesButton extends HookWidget {
  const _SourcesButton({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SkribbleIcon(
                  data: OpenBudgetIcons.bookmark,
                  size: 16,
                  color: palette.brand,
                ),
                const SizedBox(width: SpacingTokens.xs),
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: palette.brand,
                      decoration: TextDecoration.underline,
                      decorationColor: palette.brand,
                    ),
                  ),
                ),
              ],
            ),
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
