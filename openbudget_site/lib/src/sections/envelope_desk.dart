import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:openbudget_site/src/demo_budget.dart';

/// A month's budget the visitor can play with: four envelopes to fill
/// until nothing is left to assign.
///
/// The server renders the starting state, so the desk reads as a picture
/// without JavaScript. `web/site.js` reads [demoBudgetJson] and makes the
/// envelopes draggable, the currencies switchable and the seals stamp.
final class EnvelopeDesk extends StatelessComponent {
  const EnvelopeDesk({super.key});

  @override
  Component build(BuildContext context) {
    final currency = demoCurrencies.first;
    return div(
      classes: 'desk',
      attributes: const {
        'role': 'group',
        'aria-labelledby': 'desk-title',
        'data-desk': '',
      },
      [
        div(classes: 'desk-sheet', [
          div(classes: 'desk-head', [
            const p(id: 'desk-title', classes: 'desk-title', [
              Component.text('This month, in envelopes'),
            ]),
            fieldset(classes: 'currencies', [
              const legend(classes: 'sr-only', [Component.text('Currency')]),
              for (final option in demoCurrencies)
                label(classes: 'currency', [
                  Component.element(
                    tag: 'input',
                    attributes: {
                      'type': 'radio',
                      'name': 'currency',
                      'value': option.code,
                      'aria-label': option.name,
                      if (option == currency) 'checked': '',
                    },
                  ),
                  span(
                    classes: 'currency-face',
                    attributes: const {
                      'aria-hidden': 'true',
                    },
                    [
                      span(classes: 'currency-symbol', [
                        Component.text(option.symbol),
                      ]),
                      span(classes: 'currency-code', [
                        Component.text(option.code),
                      ]),
                    ],
                  ),
                ]),
            ]),
          ]),
          p(classes: 'ready', [
            const span(classes: 'ready-label', [
              Component.text('Ready to assign'),
            ]),
            Component.element(
              tag: 'output',
              classes: 'ready-amount',
              attributes: const {'data-ready': ''},
              children: [
                Component.text(currency.format(currency.readyToAssign)),
              ],
            ),
          ]),
          ul(classes: 'envelopes', [
            for (final (index, envelope) in demoEnvelopes.indexed)
              _Envelope(
                envelope: envelope,
                amount: currency.start[index],
                target: currency.targets[index],
                currency: currency,
              ),
          ]),
          p(
            classes: 'desk-status',
            attributes: const {'data-status': ''},
            [Component.text(demoMessages['hint']!)],
          ),
          // Speaks only seals and the finished budget; each slider already
          // announces its own value.
          const p(
            classes: 'sr-only',
            attributes: {'data-announce': '', 'aria-live': 'polite'},
            [],
          ),
        ]),
        script(
          id: 'desk-data',
          attributes: const {'type': 'application/json'},
          content: demoBudgetJson(),
        ),
      ],
    );
  }
}

final class _Envelope extends StatelessComponent {
  const _Envelope({
    required this.envelope,
    required this.amount,
    required this.target,
    required this.currency,
  });

  final DemoEnvelope envelope;
  final int amount;
  final int target;
  final DemoCurrency currency;

  @override
  Component build(BuildContext context) {
    final inputId = 'envelope-${envelope.id}';
    final sealed = amount == target;
    return li(
      classes: 'envelope',
      attributes: {
        'data-envelope': envelope.id,
        if (sealed) 'data-sealed': '',
        'style':
            '--fill: ${(amount / target).toStringAsFixed(3)}; '
            '--height: ${envelope.height}; --tilt: ${envelope.tilt}deg',
      },
      [
        label(
          classes: 'envelope-body',
          htmlFor: inputId,
          attributes: const {'data-envelope-body': ''},
          const [
            span(classes: 'envelope-fill', []),
            RawText(
              '<svg class="envelope-flap" viewBox="0 0 100 44" '
              'preserveAspectRatio="none" aria-hidden="true" '
              'focusable="false"><path class="flap-halo" d="M6 5C22 17 34 27 50 37C66 27 78 17 94 5" '
              'vector-effect="non-scaling-stroke"/><path class="flap-line" '
              'd="M6 5C22 17 34 27 50 37C66 27 78 17 94 5" vector-effect="non-scaling-stroke"/></svg>',
            ),
            span(classes: 'envelope-seal', []),
          ],
        ),
        Component.element(
          tag: 'input',
          id: inputId,
          classes: 'envelope-input',
          attributes: {
            'type': 'range',
            'min': '0',
            'max': '$target',
            'step': '${currency.step}',
            'value': '$amount',
            'aria-label': envelope.name,
            'aria-valuetext': demoMessages['valueText']!
                .replaceFirst('{amount}', currency.format(amount))
                .replaceFirst('{target}', currency.format(target)),
          },
        ),
        span(classes: 'envelope-name', [Component.text(envelope.name)]),
        span(
          classes: 'envelope-amount',
          attributes: const {'data-amount': ''},
          [Component.text(currency.format(amount))],
        ),
      ],
    );
  }
}
