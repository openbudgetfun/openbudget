import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

/// Dates every standard rate must cover: the start of the coverage window
/// (docs/tax-jurisdictions.md, 8.5), a mid-window checkpoint that catches
/// mid-year changes such as Finland's 1 September 2024 rise, and today.
final List<DateTime> coverageDates = [
  DateTime.utc(2022),
  DateTime.utc(2024, 7),
  DateTime.now().toUtc(),
];

void main() {
  final withIndirectTax = [
    for (final country in Countries.all)
      if (country.indirectTax != null && country.indirectTax!.rates.isNotEmpty)
        country,
  ];

  test('every researched country carries indirect-tax rates', () {
    // 43 countries were filled by the EU/EEA/OECD research task; this guards
    // against a file silently losing its rates.
    expect(withIndirectTax.length, greaterThanOrEqualTo(43));
  });

  group('effective-dated rates', () {
    for (final country in withIndirectTax) {
      final tax = country.indirectTax!;

      test(
        '${country.code} applies a standard rate on every coverage date',
        () {
          for (final date in coverageDates) {
            final standard = _rateOn(tax.rates, 'standard', date);
            expect(
              standard,
              isNotNull,
              reason:
                  '${country.code} has no standard rate in force on '
                  '${date.toIso8601String().substring(0, 10)}',
            );
          }
        },
      );

      test('${country.code} rate rows of one label never overlap', () {
        final rows = [
          ...tax.rates,
          for (final subdivision in tax.subdivisions) ...subdivision.rates,
        ];
        final byLabel = <String, List<IndirectTaxRate>>{};
        for (final rate in rows) {
          byLabel.putIfAbsent(rate.label, () => []).add(rate);
        }
        for (final entry in byLabel.entries) {
          final sorted = entry.value.toList()
            ..sort((a, b) => a.from.compareTo(b.from));
          for (var i = 1; i < sorted.length; i++) {
            final previous = sorted[i - 1];
            final current = sorted[i];
            expect(
              previous.to,
              isNot(null),
              reason:
                  '${country.code} label "${entry.key}" has an open-ended '
                  'row followed by another row',
            );
            expect(
              previous.to!.isBefore(current.from) ||
                  previous.to!.isAtSameMomentAs(current.from),
              isTrue,
              reason:
                  '${country.code} label "${entry.key}" rows overlap: '
                  '${_describe(previous)} and ${_describe(current)}',
            );
          }
        }
      });

      test('${country.code} rate rows reference real sources', () {
        for (final rate in tax.rates) {
          expect(
            rate.source,
            lessThan(country.sources.length),
            reason:
                '${country.code} rate "${rate.label}" cites source index '
                '${rate.source} but the file has ${country.sources.length}',
          );
        }
      });
    }
  });
}

/// The rate with [label] in force on [date], or null when none applies.
IndirectTaxRate? _rateOn(
  List<IndirectTaxRate> rates,
  String label,
  DateTime date,
) {
  for (final rate in rates) {
    if (rate.label != label) {
      continue;
    }
    final started =
        rate.from.isBefore(date) || rate.from.isAtSameMomentAs(date);
    final ended =
        rate.to != null &&
        (rate.to!.isBefore(date) || rate.to!.isAtSameMomentAs(date));
    if (started && !ended) {
      return rate;
    }
  }
  return null;
}

String _describe(IndirectTaxRate rate) {
  final from = _day(rate.from);
  final to = rate.to == null ? 'open' : _day(rate.to!);
  return '${rate.basisPoints / 100}% [$from, $to)';
}

String _day(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
