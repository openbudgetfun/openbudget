import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/components/doodles.dart';

/// The two plans, each drawn as an envelope. The plan names, price and
/// benefits follow the app's own OpenBudget Plus screen.
final class Pricing extends StatelessComponent {
  const Pricing({required this.config, super.key});

  /// Where the links point.
  final SiteConfig config;

  @override
  Component build(BuildContext context) {
    final webApp = config.webAppUrl.toString();
    return section(
      id: 'pricing',
      classes: 'pricing',
      attributes: const {'aria-labelledby': 'pricing-title'},
      [
        const div(classes: 'section-head', [
          h2(id: 'pricing-title', classes: 'section-title', [
            Component.text('Start free. Add Plus when tax season comes.'),
            RawText(scribbleUnderline),
          ]),
        ]),
        div(classes: 'plans', [
          _Plan(
            name: 'Free',
            price: r'$0',
            period: null,
            summary: 'Everything you need to budget.',
            benefits: const [
              'Envelope budgeting',
              'Accounts in more than twenty currencies, and your net worth',
              'Household and business books',
              'The web app on any device with a browser',
            ],
            action: a(href: webApp, classes: 'button button-paper', const [
              Component.text('Open the web app'),
            ]),
          ),
          _Plan(
            name: 'OpenBudget Plus',
            price: r'$20',
            period: 'a month',
            summary: r'$5 of assistant usage included every month.',
            benefits: const [
              'Everything in Free',
              'Tax reports for the UK, US, Nigeria and Germany, built from your own transactions',
              'The assistant: ask questions about your money',
              'Bring your own agent: connect an OpenAI-compatible provider and use your own key',
            ],
            note: 'Billed in US dollars. Cancel whenever you like.',
            sealed: true,
            action: a(href: webApp, classes: 'button button-ink', const [
              Component.text('Get Plus in the web app'),
            ]),
          ),
        ]),
        const p(classes: 'pricing-disclaimer', [
          Component.text(
            'Tax reports and the assistant offer guidance, not regulated '
            'financial or tax advice.',
          ),
        ]),
      ],
    );
  }
}

final class _Plan extends StatelessComponent {
  const _Plan({
    required this.name,
    required this.price,
    required this.period,
    required this.summary,
    required this.benefits,
    required this.action,
    this.note,
    this.sealed = false,
  });

  final String name;
  final String price;
  final String? period;
  final String summary;
  final List<String> benefits;
  final Component action;
  final String? note;
  final bool sealed;

  @override
  Component build(BuildContext context) => article(
    classes: sealed ? 'plan plan-sealed' : 'plan',
    attributes: const {'data-reveal': ''},
    [
      const RawText(
        '<svg class="plan-flap" viewBox="0 0 400 60" preserveAspectRatio="none" '
        'aria-hidden="true" focusable="false"><path d="M4 4C70 22 136 40 200 '
        '54C264 40 330 22 396 4" fill="none" stroke="currentColor" '
        'stroke-width="2.4" stroke-linecap="round" '
        'vector-effect="non-scaling-stroke"/></svg>',
      ),
      if (sealed) const span(classes: 'plan-seal', []),
      h3(classes: 'plan-name', [Component.text(name)]),
      p(classes: 'plan-price', [
        span(classes: 'plan-amount', [Component.text(price)]),
        if (period case final period?)
          span(classes: 'plan-period', [Component.text(period)]),
      ]),
      p(classes: 'plan-summary', [Component.text(summary)]),
      ul(classes: 'plan-benefits', [
        for (final benefit in benefits) li([Component.text(benefit)]),
      ]),
      if (note case final note?)
        p(classes: 'plan-note', [Component.text(note)]),
      action,
    ],
  );
}
