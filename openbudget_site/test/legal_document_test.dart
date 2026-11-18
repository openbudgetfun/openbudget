import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/legal/legal_document.dart';
import 'package:openbudget_site/src/pages/legal_page.dart';
import 'package:test/test.dart';

void main() {
  group('legalSpans', () {
    test('keeps text without links as one run', () {
      expect(legalSpans('Plain words.'), [(text: 'Plain words.', href: null)]);
    });

    test('splits links out of the text around them', () {
      expect(legalSpans('Read the [policy](/privacy) or [mail](mailto:a@b).'), [
        (text: 'Read the ', href: null),
        (text: 'policy', href: '/privacy'),
        (text: ' or ', href: null),
        (text: 'mail', href: 'mailto:a@b'),
        (text: '.', href: null),
      ]);
    });

    test('a link can open or close the text', () {
      expect(legalSpans('[Start](/a) and [end](/b)'), [
        (text: 'Start', href: '/a'),
        (text: ' and ', href: null),
        (text: 'end', href: '/b'),
      ]);
    });
  });

  test('a section anchor is its heading in lower case with hyphens', () {
    expect(
      const LegalSection('Keeping it, and deleting it!', []).id,
      'keeping-it-and-deleting-it',
    );
  });

  group('legalDocuments', () {
    final documents = legalDocuments(siteConfig);

    test('serves the pages the store listings link to', () {
      expect(documents.keys, [
        '/privacy',
        '/terms',
        '/delete-account',
        '/support',
      ]);
    });

    test('every section of a page has its own anchor', () {
      for (final document in documents.values) {
        final ids = document.sections.map((section) => section.id);
        expect(ids.toSet(), hasLength(ids.length), reason: document.path);
        expect(ids, everyElement(isNotEmpty), reason: document.path);
      }
    });

    test('every link is an absolute URL, an email or a page on the site', () {
      for (final document in documents.values) {
        final texts = [
          for (final block in [
            ...document.intro,
            for (final section in document.sections) ...section.blocks,
          ])
            ...switch (block) {
              LegalParagraph(:final text) => [text],
              LegalList(:final items) => items,
            },
        ];
        for (final span in texts.expand(legalSpans)) {
          final href = span.href;
          if (href == null) {
            // A stray bracket would mean a link failed to parse.
            expect(span.text, isNot(contains('](')), reason: document.path);
            continue;
          }
          final internal = href.split('#').first;
          expect(
            href.startsWith('https://') ||
                href.startsWith('mailto:') ||
                internal == '/' ||
                documents.containsKey(internal),
            isTrue,
            reason: '${document.path} links to $href',
          );
        }
      }
    });
  });
}
