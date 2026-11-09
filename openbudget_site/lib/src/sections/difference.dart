import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:openbudget_site/src/components/doodles.dart';

/// What sets OpenBudget apart, written up like entries in a ledger.
final class Difference extends StatelessComponent {
  const Difference({super.key});

  @override
  Component build(BuildContext context) => section(
    id: 'different',
    classes: 'difference',
    attributes: const {'aria-labelledby': 'different-title'},
    [
      const div(classes: 'section-head', [
        h2(id: 'different-title', classes: 'section-title', [
          Component.text('Different where it counts'),
          RawText(scribbleUnderline),
        ]),
        p(classes: 'section-lede', [
          Component.text(
            'The envelope method has kept kitchen-table budgets honest for '
            'generations. OpenBudget keeps the method and fits it to money '
            'that crosses borders, businesses and tax years.',
          ),
        ]),
      ]),
      ol(classes: 'ledger', [
        for (final (index, entry) in _entries.indexed)
          li(
            classes: 'ledger-entry',
            attributes: const {'data-reveal': ''},
            [
              span(
                classes: 'ledger-number',
                attributes: const {
                  'aria-hidden': 'true',
                },
                [Component.text((index + 1).toString().padLeft(2, '0'))],
              ),
              div(classes: 'ledger-text', [
                h3(classes: 'ledger-title', [Component.text(entry.title)]),
                p([Component.text(entry.body)]),
              ]),
              div(classes: 'ledger-doodle', [DoodleArt(entry.doodle)]),
            ],
          ),
      ]),
    ],
  );
}

typedef _Entry = ({String title, String body, Doodle doodle});

const List<_Entry> _entries = [
  (
    title: 'Envelopes, not spreadsheets',
    body:
        'Split each payday into envelopes for rent, food and everything '
        'else, then move money between them whenever life changes. When an '
        'envelope is full, it is sealed.',
    doodle: Doodle.envelopes,
  ),
  (
    title: 'Many currencies, one net worth',
    body:
        'Keep accounts in pounds, dollars, naira, euros and more side by side. '
        'Your net worth adds them up and shows which exchange rate it used '
        'and how fresh it is, so no value quietly rounds away.',
    doodle: Doodle.currencies,
  ),
  (
    title: 'Your books and your business’s',
    body:
        'Run the household budget and a company’s double-entry books in one '
        'place, with a clean line between what is yours and what belongs to '
        'the business.',
    doodle: Doodle.books,
  ),
  (
    title: 'Tax guidance for four countries',
    body:
        'Reports for the UK, US, Nigeria and Germany, built from your own '
        'transactions. They are guidance to prepare with and check with an '
        'adviser, not regulated tax advice.',
    doodle: Doodle.postmarks,
  ),
  (
    title: 'An assistant, or bring your own agent',
    body:
        'Ask the built-in assistant about your money in plain words. Or give '
        'Claude Code, Codex or any MCP client a personal token: agents can '
        'read your budgets and propose changes, and nothing moves until you '
        'approve it.',
    doodle: Doodle.agents,
  ),
  (
    title: 'Open source, top to bottom',
    body:
        'The app, the server and this page are public on GitHub. Read how '
        'your money is handled, report a problem, or send a fix.',
    doodle: Doodle.openSource,
  ),
];
