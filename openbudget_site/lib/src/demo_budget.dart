/// The sample month on the hero's envelope desk.
///
/// The desk is server-rendered from this data, and `web/site.js` reads the
/// same data as JSON to make it playable, so the numbers and words live in
/// one place.
library;

import 'dart:convert';

/// One envelope on the desk.
final class DemoEnvelope {
  const DemoEnvelope({
    required this.id,
    required this.name,
    required this.height,
    required this.tilt,
  });

  /// A stable id for the envelope's controls.
  final String id;

  /// The envelope's name.
  final String name;

  /// How tall the envelope stands, as a share of the tallest.
  final double height;

  /// How far the envelope leans, in degrees.
  final double tilt;
}

/// A month's income in one currency, split across [demoEnvelopes].
final class DemoCurrency {
  const DemoCurrency({
    required this.code,
    required this.symbol,
    required this.word,
    required this.name,
    required this.step,
    required this.targets,
    required this.start,
  });

  /// The ISO 4217 code.
  final String code;

  /// The symbol amounts are written with.
  final String symbol;

  /// The unit in a sentence: "Put every dollar in an envelope."
  final String word;

  /// The currency's name, for assistive technology.
  final String name;

  /// How much one drag or arrow-key step moves.
  final int step;

  /// What fills each envelope, in [demoEnvelopes] order.
  final List<int> targets;

  /// What each envelope holds when the page loads.
  final List<int> start;

  /// The month's income: exactly what the envelopes can hold.
  int get income => targets.fold(0, (sum, target) => sum + target);

  /// What is left once the starting amounts are assigned.
  int get readyToAssign =>
      income - start.fold(0, (sum, amount) => sum + amount);

  /// [amount] with this currency's symbol and thousands separators.
  String format(int amount) {
    final digits = amount.abs().toString();
    final grouped = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => ',',
    );
    return '${amount < 0 ? '-' : ''}$symbol$grouped';
  }
}

/// The envelopes, left to right. Like the mark, they stand at different
/// heights, so the desk reads as a bar chart.
const demoEnvelopes = [
  DemoEnvelope(id: 'groceries', name: 'Groceries', height: .66, tilt: -4),
  DemoEnvelope(id: 'rent', name: 'Rent', height: 1, tilt: 1),
  DemoEnvelope(id: 'savings', name: 'Savings', height: .84, tilt: 3),
  DemoEnvelope(id: 'fun', name: 'Fun', height: .52, tilt: -2),
];

/// The currencies the desk can switch between; the first is the default.
const demoCurrencies = [
  DemoCurrency(
    code: 'USD',
    symbol: r'$',
    word: 'dollar',
    name: 'US dollars',
    step: 50,
    targets: [500, 1350, 900, 250],
    start: [300, 1350, 200, 100],
  ),
  DemoCurrency(
    code: 'GBP',
    symbol: '£',
    word: 'pound',
    name: 'British pounds',
    step: 50,
    targets: [400, 1150, 850, 200],
    start: [250, 1150, 150, 100],
  ),
  DemoCurrency(
    code: 'EUR',
    symbol: '€',
    word: 'euro',
    name: 'Euros',
    step: 50,
    targets: [450, 1200, 900, 250],
    start: [300, 1200, 200, 100],
  ),
  DemoCurrency(
    code: 'NGN',
    symbol: '₦',
    word: 'naira',
    name: 'Nigerian naira',
    step: 5000,
    targets: [180000, 300000, 300000, 70000],
    start: [120000, 300000, 50000, 30000],
  ),
];

/// The words the desk speaks as it changes. `{amount}`, `{word}` and
/// `{name}` are filled in by `web/site.js`.
const demoMessages = {
  'hint': 'Drag or tap an envelope to fill it.',
  'left': '{amount} still needs an envelope.',
  'done': 'Every {word} is in an envelope.',
  'sealed': '{name} is full, so it is sealed.',
  'valueText': '{amount} of {target}',
};

/// The desk's data as JSON, safe to embed in a `<script>` element.
String demoBudgetJson() {
  final json = jsonEncode({
    'envelopes': [
      for (final envelope in demoEnvelopes)
        {'id': envelope.id, 'name': envelope.name},
    ],
    'currencies': [
      for (final currency in demoCurrencies)
        {
          'code': currency.code,
          'symbol': currency.symbol,
          'word': currency.word,
          'step': currency.step,
          'targets': currency.targets,
          'start': currency.start,
        },
    ],
    'messages': demoMessages,
  });
  // A literal `</script>` inside the JSON would end the element early.
  return json.replaceAll('</', r'<\/');
}
