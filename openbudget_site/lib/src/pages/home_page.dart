import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/sections/difference.dart';
import 'package:openbudget_site/src/sections/hero.dart';
import 'package:openbudget_site/src/sections/masthead.dart';
import 'package:openbudget_site/src/sections/pricing.dart';
import 'package:openbudget_site/src/sections/questions.dart';
import 'package:openbudget_site/src/sections/site_footer.dart';

/// The landing page.
final class HomePage extends StatelessComponent {
  const HomePage({required this.config, super.key});

  /// Where the page's links point.
  final SiteConfig config;

  @override
  Component build(BuildContext context) => Component.fragment([
    Masthead(config: config),
    main_(id: 'main', [
      Hero(config: config),
      const Difference(),
      Pricing(config: config),
      Questions(config: config),
    ]),
    SiteFooter(config: config, year: DateTime.now().year),
  ]);
}
