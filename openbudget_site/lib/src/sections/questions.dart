import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';
import 'package:openbudget_site/site_config.dart';
import 'package:openbudget_site/src/components/doodles.dart';

/// Answers to the questions people ask before they sign up.
final class Questions extends StatelessComponent {
  const Questions({required this.config, super.key});

  /// Decides whether the "when are the apps coming" answer still applies.
  final SiteConfig config;

  @override
  Component build(BuildContext context) {
    final answers = [
      ..._answers,
      if (config.hasPendingDownloads) _appsAnswer,
    ];
    return section(
      id: 'questions',
      classes: 'questions',
      attributes: const {'aria-labelledby': 'questions-title'},
      [
        const div(classes: 'section-head', [
          h2(id: 'questions-title', classes: 'section-title', [
            Component.text('Questions, answered'),
            RawText(scribbleUnderline),
          ]),
        ]),
        div(classes: 'faq', [
          for (final answer in answers)
            details(classes: 'faq-item', [
              summary(classes: 'faq-question', [
                span([Component.text(answer.question)]),
                const span(
                  classes: 'faq-mark',
                  attributes: {
                    'aria-hidden': 'true',
                  },
                  [],
                ),
              ]),
              div(classes: 'faq-answer', [
                p([Component.text(answer.answer)]),
              ]),
            ]),
        ]),
      ],
    );
  }
}

typedef _Answer = ({String question, String answer});

const List<_Answer> _answers = [
  (
    question: 'What is envelope budgeting?',
    answer:
        'You give every bit of income a job by putting it in an envelope: '
        'rent, food, savings, fun. You spend from the envelopes, and when one '
        'runs low you move money over from another. Nothing gets spent twice, '
        'and nothing is left unplanned.',
  ),
  (
    question: 'Is OpenBudget really free?',
    answer:
        'Yes. Budgeting, your accounts, net worth and books cost nothing. '
        r'OpenBudget Plus adds tax reports and the assistant for $10 a month, '
        'billed in US dollars, and you can cancel whenever you like.',
  ),
  (
    question: 'Which currencies can I use?',
    answer:
        'More than twenty, including pounds, dollars, euros, naira, yen, '
        'rupees, rand, cedis and bitcoin. Each account keeps its own '
        'currency, and when OpenBudget converts for your net worth it shows '
        'the rate it used and how old that rate is.',
  ),
  (
    question: 'Is the tax guidance professional advice?',
    answer:
        'No. Tax reports and the assistant’s suggestions help you prepare and '
        'ask better questions, but they are not regulated financial or tax '
        'advice. Check important decisions with a qualified adviser.',
  ),
  (
    question: 'Can I connect my own AI agent?',
    answer:
        'Yes. Create a personal access token in OpenBudget and point Claude '
        'Code, Codex or any other MCP client at it. Agents can read your '
        'budgets and tax reports and propose changes; nothing changes until '
        'you apply it.',
  ),
  (
    question: 'Where does my data live?',
    answer:
        'On OpenBudget’s servers, so your budget is the same on every device. '
        'The code that stores and handles it is public, so you can read '
        'exactly what happens to it.',
  ),
];

const _Answer _appsAnswer = (
  question: 'When are the phone and desktop apps coming?',
  answer:
      'Soon. The web app works today in any modern browser, phones included, '
      'and your account carries straight over to the apps when they arrive.',
);
