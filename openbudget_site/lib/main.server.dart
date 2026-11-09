/// Renders the OpenBudget landing page.
///
/// `jaspr build` runs this entry point and saves every page it renders as
/// static HTML in `build/jaspr`, next to the files in `web/`.
library;

import 'package:jaspr/server.dart';
import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/site.dart';

void main() {
  Jaspr.initializeApp();
  runApp(OpenBudgetSite(config: siteConfig));
}
