import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/components/brand_artwork.dart';
import 'package:openbudget_site/src/components/github_mark.dart';

/// The foot of every page.
final class SiteFooter extends StatelessComponent {
  const SiteFooter({required this.config, required this.year, super.key});

  /// Where the links point.
  final SiteConfig config;

  /// The year the site was built, for the copyright line.
  final int year;

  @override
  Component build(BuildContext context) => footer(classes: 'site-footer', [
    const div(classes: 'footer-brand', [
      BrandArtwork('lockup-mono.svg', classes: 'lockup'),
      p([Component.text('Envelope budgeting across currencies.')]),
    ]),
    nav(
      classes: 'footer-nav',
      attributes: const {'aria-label': 'Footer'},
      [
        a(href: config.webAppUrl.toString(), const [
          Component.text('Open the web app'),
        ]),
        a(
          href: config.sourceUrl.toString(),
          classes: 'with-mark',
          const [GithubMark(), Component.text('Source on GitHub')],
        ),
        const a(href: '/#pricing', [Component.text('Pricing')]),
        const a(href: '/#questions', [Component.text('Questions')]),
      ],
    ),
    p(classes: 'footer-small', [
      Component.text(
        '© $year OpenBudget. Tax reports and the assistant are guidance, '
        'not regulated financial or tax advice.',
      ),
    ]),
  ]);
}
