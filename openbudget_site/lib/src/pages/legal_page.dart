import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/legal/delete_account.dart';
import 'package:openbudget_site/src/legal/legal_document.dart';
import 'package:openbudget_site/src/legal/privacy_policy.dart';
import 'package:openbudget_site/src/legal/support.dart';
import 'package:openbudget_site/src/legal/terms.dart';
import 'package:openbudget_site/src/sections/masthead.dart';
import 'package:openbudget_site/src/sections/site_footer.dart';

/// Every policy and help page the site serves, keyed by path.
Map<String, LegalDocument> legalDocuments(SiteConfig config) => {
  for (final document in [
    privacyPolicy(config),
    termsOfService(config),
    deleteAccount(config),
    support(config),
  ])
    document.path: document,
};

/// A policy or help page: a heading, the date it changed, and its sections.
final class LegalPage extends StatelessComponent {
  const LegalPage({required this.config, required this.document, super.key});

  /// Where the page's links point.
  final SiteConfig config;

  /// The words on the page.
  final LegalDocument document;

  @override
  Component build(BuildContext context) => Component.fragment([
    Masthead(config: config, showSections: false),
    main_(id: 'main', classes: 'legal', [
      article(classes: 'legal-sheet', [
        h1(classes: 'legal-title', [Component.text(document.title)]),
        p(classes: 'legal-updated', [
          Component.text('Last updated ${document.updated}'),
        ]),
        for (final block in document.intro) _block(block),
        if (document.sections.length > 2)
          nav(
            classes: 'legal-contents',
            attributes: const {'aria-label': 'On this page'},
            [
              ol([
                for (final section in document.sections)
                  li([
                    a(href: '#${section.id}', [
                      Component.text(section.heading),
                    ]),
                  ]),
              ]),
            ],
          ),
        for (final section in document.sections) _section(section),
      ]),
    ]),
    SiteFooter(config: config, year: DateTime.now().year),
  ]);
}

Component _section(LegalSection legal) => section(
  id: legal.id,
  classes: 'legal-section',
  [
    h2([Component.text(legal.heading)]),
    for (final block in legal.blocks) _block(block),
  ],
);

Component _block(LegalBlock block) => switch (block) {
  LegalParagraph(:final text) => p(_spans(text)),
  LegalList(:final items) => ul([
    for (final item in items) li(_spans(item)),
  ]),
};

List<Component> _spans(String text) => [
  for (final span in legalSpans(text))
    if (span.href case final href?)
      a(
        href: href,
        attributes: href.startsWith('https://')
            ? const {'rel': 'noopener'}
            : null,
        [Component.text(span.text)],
      )
    else
      Component.text(span.text),
];
