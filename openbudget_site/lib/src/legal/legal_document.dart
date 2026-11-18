/// The plain-text model behind the site's policy and help pages.
///
/// The privacy policy, terms, account deletion and support pages are prose
/// with headings, paragraphs and lists. Writing them as data keeps the words
/// readable in review and lets one component lay every page out the same way.
library;

/// One page of policy or help text.
final class LegalDocument {
  const LegalDocument({
    required this.path,
    required this.title,
    required this.description,
    required this.updated,
    required this.intro,
    required this.sections,
  });

  /// Where the page is served, such as `/privacy`.
  final String path;

  /// The page heading, also used for the browser title.
  final String title;

  /// One sentence for search results and social cards.
  final String description;

  /// When the words last changed, as people write a date.
  final String updated;

  /// The paragraphs under the heading, before the first section.
  final List<LegalBlock> intro;

  /// The numbered sections of the page.
  final List<LegalSection> sections;
}

/// A titled part of a [LegalDocument].
final class LegalSection {
  const LegalSection(this.heading, this.blocks);

  /// The section heading.
  final String heading;

  /// The paragraphs and lists in the section.
  final List<LegalBlock> blocks;

  /// The anchor for the section, so other pages can link straight to it.
  String get id => heading
      .toLowerCase()
      .replaceAll(RegExp('[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

/// A paragraph or a list inside a section.
///
/// Text may hold Markdown-style links, `[words](https://…)`, which render as
/// anchors. Nothing else is interpreted.
sealed class LegalBlock {
  const LegalBlock();
}

/// A paragraph of text.
final class LegalParagraph extends LegalBlock {
  const LegalParagraph(this.text);

  /// The paragraph, with optional links.
  final String text;
}

/// A bulleted list.
final class LegalList extends LegalBlock {
  const LegalList(this.items);

  /// One string per bullet, with optional links.
  final List<String> items;
}

/// A run of text or a link inside a paragraph or bullet.
typedef LegalSpan = ({String text, String? href});

final _link = RegExp(r'\[([^\]]+)\]\(([^)\s]+)\)');

/// Splits [text] into plain runs and links.
List<LegalSpan> legalSpans(String text) {
  final spans = <LegalSpan>[];
  var start = 0;
  for (final match in _link.allMatches(text)) {
    if (match.start > start) {
      spans.add((text: text.substring(start, match.start), href: null));
    }
    spans.add((text: match.group(1)!, href: match.group(2)));
    start = match.end;
  }
  if (start < text.length) {
    spans.add((text: text.substring(start), href: null));
  }
  return spans;
}
