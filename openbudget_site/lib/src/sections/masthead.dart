import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/components/brand_artwork.dart';

/// The bar across the top: the lockup, the page's sections, and the way
/// into the web app.
final class Masthead extends StatelessComponent {
  const Masthead({required this.config, this.showSections = true, super.key});

  /// Where the links point.
  final SiteConfig config;

  /// Whether to link to the home page's sections.
  final bool showSections;

  @override
  Component build(BuildContext context) => header(classes: 'masthead', [
    const a(href: '#main', classes: 'skip-link', [
      Component.text('Skip to content'),
    ]),
    const a(
      href: '/',
      classes: 'masthead-brand',
      attributes: {'aria-label': 'OpenBudget home'},
      [BrandArtwork('lockup.svg', classes: 'lockup brand-art')],
    ),
    nav(
      classes: 'masthead-nav',
      attributes: const {'aria-label': 'Main'},
      [
        if (showSections) ...[
          const a(href: '/#different', [
            Component.text('Why it’s different'),
          ]),
          const a(href: '/#pricing', [Component.text('Pricing')]),
          const a(href: '/#questions', [Component.text('Questions')]),
        ],
        a(href: config.sourceUrl.toString(), const [
          Component.text('GitHub'),
        ]),
      ],
    ),
    a(
      href: config.webAppUrl.toString(),
      classes: 'button button-ink button-small masthead-cta',
      const [Component.text('Open the web app')],
    ),
  ]);
}
