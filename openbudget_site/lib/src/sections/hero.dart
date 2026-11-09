import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/components/doodles.dart';
import 'package:openbudget_site/src/components/download_stamps.dart';
import 'package:openbudget_site/src/demo_budget.dart';
import 'package:openbudget_site/src/sections/envelope_desk.dart';

/// The first screen: the promise, the way in, and a budget to play with.
final class Hero extends StatelessComponent {
  const Hero({required this.config, super.key});

  /// Where the links point.
  final SiteConfig config;

  @override
  Component build(BuildContext context) => section(
    classes: 'hero',
    attributes: const {'aria-labelledby': 'hero-title'},
    [
      div(classes: 'hero-copy', [
        h1(id: 'hero-title', classes: 'hero-title', [
          const Component.text('Put every '),
          span(
            classes: 'swap',
            attributes: const {'data-word': ''},
            [
              Component.text(demoCurrencies.first.word),
            ],
          ),
          const Component.text(' in an envelope.'),
        ]),
        const p(classes: 'lede', [
          Component.text(
            'OpenBudget is envelope budgeting for money that lives in more '
            'than one currency, with your household and business books side '
            'by side and tax guidance for the UK, US, Nigeria and Germany.',
          ),
        ]),
        div(classes: 'cta-row', [
          a(
            href: config.webAppUrl.toString(),
            classes: 'button button-ink',
            const [
              Component.text('Open the web app'),
              RawText(_arrow),
            ],
          ),
          a(
            href: config.sourceUrl.toString(),
            classes: 'button button-paper',
            const [Component.text('Read the code')],
          ),
        ]),
        const p(classes: 'cta-note', [
          Component.text('Free to start. Open source on GitHub.'),
        ]),
        DownloadStamps(config: config),
      ]),
      const div(classes: 'hero-play', [
        p(
          classes: 'hand-note',
          attributes: {'aria-hidden': 'true'},
          [
            Component.text('go on, fill one'),
            RawText(heroArrow),
          ],
        ),
        EnvelopeDesk(),
      ]),
    ],
  );
}

const _arrow =
    '<svg class="button-arrow" viewBox="0 0 20 12" aria-hidden="true" '
    'focusable="false"><path d="M1 6.4C6 5.8 11 6.2 18 6M13 1.6L18.4 6L13.4 '
    '10.6" fill="none" stroke="currentColor" stroke-width="2" '
    'stroke-linecap="round" stroke-linejoin="round"/></svg>';
