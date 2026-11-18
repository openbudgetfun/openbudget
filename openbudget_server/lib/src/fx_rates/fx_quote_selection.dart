import 'package:openbudget_core/openbudget_core.dart';

/// One stored daily USD quote, reduced to the fields quote selection needs.
///
/// The provider stores `units of currency per one USD`; this type keeps the
/// exact decimal text so selection never passes through a double.
class FxDailyRate {
  const FxDailyRate({
    required this.currencyCode,
    required this.rateDate,
    required this.rate,
    required this.fetchedAt,
  });

  final String currencyCode;
  final DateTime rateDate;
  final String rate;
  final DateTime fetchedAt;
}

/// The rate chosen for one currency pair on one calendar date.
class FxQuoteSelection {
  const FxQuoteSelection._({
    required this.fromCurrencyCode,
    required this.toCurrencyCode,
    required this.rate,
    required this.rateText,
    required this.rateDate,
    required this.source,
    required this.fetchedAt,
    required this.isStale,
  });

  /// The identity quote. It is used only when both codes are identical.
  factory FxQuoteSelection.identity({
    required String fromCurrencyCode,
    required String toCurrencyCode,
    required DateTime date,
  }) => FxQuoteSelection._(
    fromCurrencyCode: fromCurrencyCode,
    toCurrencyCode: toCurrencyCode,
    rate: ExactDecimal.one,
    rateText: '1',
    rateDate: date,
    source: FxRateSource.identity,
    fetchedAt: null,
    isStale: false,
  );

  final String fromCurrencyCode;
  final String toCurrencyCode;

  /// Units of [toCurrencyCode] per one unit of [fromCurrencyCode].
  final ExactDecimal rate;

  /// [rate] as the plain decimal string the API exposes.
  final String rateText;
  final DateTime rateDate;
  final FxRateSource source;
  final DateTime? fetchedAt;
  final bool isStale;

  /// Chooses the rate for [fromCurrencyCode] to [toCurrencyCode] on [date].
  ///
  /// Both codes need a parseable daily row in the exclusive seven-day window
  /// `(date - lookbackDays, date]`. The latest usable date on each side wins,
  /// the cross rate is rounded once to twelve significant digits, and a
  /// missing or unusable side returns null so no caller invents a 1:1 quote.
  ///
  /// [rates] may contain rows for other currencies and dates; they are
  /// filtered here. [now] is the configured server clock, used for the same
  /// staleness rule as `FxService`: more than [maxStaleDays] behind the asked
  /// date, or today's row fetched more than [maxFetchedAge] ago.
  static FxQuoteSelection? select({
    required String fromCurrencyCode,
    required String toCurrencyCode,
    required DateTime date,
    required Iterable<FxDailyRate> rates,
    required DateTime now,
    int lookbackDays = 7,
    int maxStaleDays = 2,
    Duration maxFetchedAge = const Duration(hours: 48),
  }) {
    if (fromCurrencyCode == toCurrencyCode) {
      return FxQuoteSelection.identity(
        fromCurrencyCode: fromCurrencyCode,
        toCurrencyCode: toCurrencyCode,
        date: date,
      );
    }

    final windowStart = date.subtract(Duration(days: lookbackDays));
    ({FxDailyRate row, ExactDecimal value})? fromBest;
    ({FxDailyRate row, ExactDecimal value})? toBest;

    for (final row in rates) {
      if (!row.rateDate.isAfter(windowStart) || row.rateDate.isAfter(date)) {
        continue;
      }

      final parsed = ExactDecimal.tryParse(row.rate);
      if (parsed == null) continue;

      if (row.currencyCode == fromCurrencyCode) {
        if (fromBest == null || row.rateDate.isAfter(fromBest.row.rateDate)) {
          fromBest = (row: row, value: parsed);
        }
      } else if (row.currencyCode == toCurrencyCode) {
        if (toBest == null || row.rateDate.isAfter(toBest.row.rateDate)) {
          toBest = (row: row, value: parsed);
        }
      }
    }

    if (fromBest == null || toBest == null) return null;

    final rate = crossRate(
      fromPerUsd: fromBest.value,
      toPerUsd: toBest.value,
    );
    final rateDate = fromBest.row.rateDate.isBefore(toBest.row.rateDate)
        ? fromBest.row.rateDate
        : toBest.row.rateDate;
    final fetchedAt = fromBest.row.fetchedAt.isBefore(toBest.row.fetchedAt)
        ? fromBest.row.fetchedAt
        : toBest.row.fetchedAt;

    return FxQuoteSelection._(
      fromCurrencyCode: fromCurrencyCode,
      toCurrencyCode: toCurrencyCode,
      rate: rate,
      rateText: _formatRate(rate),
      rateDate: rateDate,
      source: FxRateSource.market,
      fetchedAt: fetchedAt,
      isStale: _isStale(
        rateDate: rateDate,
        fetchedAt: fetchedAt,
        requestedDate: date,
        now: now,
        maxStaleDays: maxStaleDays,
        maxFetchedAge: maxFetchedAge,
      ),
    );
  }

  static bool _isStale({
    required DateTime rateDate,
    required DateTime fetchedAt,
    required DateTime requestedDate,
    required DateTime now,
    required int maxStaleDays,
    required Duration maxFetchedAge,
  }) {
    if (requestedDate.difference(rateDate).inDays > maxStaleDays) return true;

    final today = DateTime.utc(now.year, now.month, now.day);
    return rateDate == today && now.difference(fetchedAt) > maxFetchedAge;
  }

  /// Drops insignificant trailing zeros from a twelve-digit cross rate.
  ///
  /// The value is unchanged; `"0.800000000000"` becomes `"0.8"` so stored and
  /// displayed rates match the provider's own plain decimal form.
  static String _formatRate(ExactDecimal rate) {
    final text = rate.toString();
    if (!text.contains('.')) return text;

    final trimmed = text.replaceFirst(RegExp(r'0+$'), '');
    return trimmed.endsWith('.')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}
