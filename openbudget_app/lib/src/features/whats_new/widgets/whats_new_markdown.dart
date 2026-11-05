import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Renders the small Markdown subset used in release-notes details:
/// blank-line paragraphs, `- ` bullets, and `**bold**`.
///
/// It is intentionally not a general Markdown renderer. Release notes are
/// short, human-written text, and a package would be more surface than the
/// job needs.
class WhatsNewMarkdown extends HookWidget {
  const WhatsNewMarkdown({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(color: palette.ink);
    final blocks = _parseBlocks(text);

    if (blocks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, block) in blocks.indexed) ...[
          if (index > 0) const SizedBox(height: SpacingTokens.sm),
          switch (block) {
            _Paragraph(:final text) => Text.rich(
              TextSpan(
                style: bodyStyle,
                children: _inlineSpans(
                  text,
                  boldStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            _BulletList(:final items) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final item in items)
                  Padding(
                    padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExcludeSemantics(
                          child: Text(
                            '•',
                            style: bodyStyle?.copyWith(color: palette.brand),
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              style: bodyStyle,
                              children: _inlineSpans(
                                item,
                                boldStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          },
        ],
      ],
    );
  }
}

sealed class _Block {
  const _Block();
}

final class _Paragraph extends _Block {
  const _Paragraph(this.text);

  final String text;
}

final class _BulletList extends _Block {
  const _BulletList(this.items);

  final List<String> items;
}

List<_Block> _parseBlocks(String source) {
  final normalized = source.replaceAll('\r\n', '\n').trim();
  if (normalized.isEmpty) {
    return const [];
  }

  final blocks = <_Block>[];
  final paragraph = <String>[];
  final bullets = <String>[];

  void flushParagraph() {
    if (paragraph.isEmpty) {
      return;
    }
    blocks.add(_Paragraph(paragraph.join(' ')));
    paragraph.clear();
  }

  void flushBullets() {
    if (bullets.isEmpty) {
      return;
    }
    blocks.add(_BulletList(List<String>.unmodifiable(bullets)));
    bullets.clear();
  }

  for (final rawLine in normalized.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) {
      flushParagraph();
      flushBullets();
      continue;
    }

    if (line.startsWith('- ')) {
      flushParagraph();
      final item = line.substring(2).trim();
      if (item.isNotEmpty) {
        bullets.add(item);
      }
      continue;
    }

    flushBullets();
    paragraph.add(line);
  }

  flushParagraph();
  flushBullets();
  return blocks;
}

/// Splits `**bold**` runs from plain text.
///
/// An unmatched `**` stays visible as literal text, because losing half a
/// sentence is worse than showing the marker.
List<InlineSpan> _inlineSpans(String source, {required TextStyle boldStyle}) {
  final spans = <InlineSpan>[];
  var cursor = 0;

  while (cursor < source.length) {
    final open = source.indexOf('**', cursor);
    if (open == -1) {
      spans.add(TextSpan(text: source.substring(cursor)));
      break;
    }

    final close = source.indexOf('**', open + 2);
    if (close == -1) {
      spans.add(TextSpan(text: source.substring(cursor)));
      break;
    }

    if (open > cursor) {
      spans.add(TextSpan(text: source.substring(cursor, open)));
    }
    spans.add(
      TextSpan(text: source.substring(open + 2, close), style: boldStyle),
    );
    cursor = close + 2;
  }

  return spans;
}
