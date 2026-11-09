import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/components/doodles.dart';
import 'package:openbudget_site/src/sections/masthead.dart';
import 'package:openbudget_site/src/sections/site_footer.dart';

/// The page served for any address the site does not have.
final class NotFoundPage extends StatelessComponent {
  const NotFoundPage({required this.config, super.key});

  /// Where the page's links point.
  final SiteConfig config;

  @override
  Component build(BuildContext context) => Component.fragment([
    Masthead(config: config, showSections: false),
    main_(id: 'main', classes: 'not-found', [
      const div(classes: 'not-found-art', [DoodleArt(Doodle.openSource)]),
      const h1(classes: 'not-found-title', [
        Component.text('Nothing in this envelope.'),
      ]),
      const p(classes: 'lede', [
        Component.text(
          'The page you were after does not exist, or it has moved.',
        ),
      ]),
      div(classes: 'cta-row', [
        const a(href: '/', classes: 'button button-ink', [
          Component.text('Back to OpenBudget'),
        ]),
        a(
          href: config.webAppUrl.toString(),
          classes: 'button button-paper',
          const [
            Component.text('Open the web app'),
          ],
        ),
      ]),
    ]),
    SiteFooter(config: config, year: DateTime.now().year),
  ]);
}
