import 'dart:math' as math;

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart';

/// The rates from one FX snapshot, relative to [baseCurrencyCode].
///
/// A snapshot's rates quote how many units of each currency one unit of
/// [baseCurrencyCode] buys, so the base currency's own rate is 1.
class TaxFxSnapshotRates {
  const TaxFxSnapshotRates({
    required this.baseCurrencyCode,
    required this.fetchedAt,
    required this.rates,
  });

  final String baseCurrencyCode;
  final DateTime fetchedAt;
  final Map<String, double> rates;
}

/// Converts budget amounts into a report's currency at the rate in force on
/// each transaction's date.
///
/// The snapshot fetched at or before the transaction date wins. When every
/// snapshot is newer than the transaction, the earliest one after it is used,
/// because a later rate is better than no report at all.
class TaxFxRates {
  TaxFxRates(Iterable<TaxFxSnapshotRates> snapshots)
    : _snapshots = List.unmodifiable(
        snapshots.toList()..sort((a, b) => a.fetchedAt.compareTo(b.fetchedAt)),
      );

  final List<TaxFxSnapshotRates> _snapshots;

  /// Whether no snapshot has been recorded yet.
  bool get isEmpty => _snapshots.isEmpty;

  /// Converts [amountMinor] from [fromCurrencyCode] to [toCurrencyCode].
  ///
  /// Returns [amountMinor] unchanged when the currencies match. Throws
  /// [TaxRateUnavailableException] when a required rate is missing rather than
  /// guessing one.
  int convert({
    required int amountMinor,
    required String fromCurrencyCode,
    required String toCurrencyCode,
    required DateTime date,
  }) {
    if (fromCurrencyCode == toCurrencyCode) return amountMinor;

    final snapshot = _snapshotFor(date);
    if (snapshot == null) {
      throw TaxRateUnavailableException(
        message:
            'No exchange rate is available to convert $fromCurrencyCode to '
            '$toCurrencyCode on ${date.toIso8601String()}.',
      );
    }

    final fromRate = _rateFor(snapshot, fromCurrencyCode, date);
    final toRate = _rateFor(snapshot, toCurrencyCode, date);
    // Amounts are in each currency's own minor unit, so 1,000 JPY minor
    // units (no decimals) are 1,000 yen while 1,000 GBP minor units are
    // ten pounds. Rescale between the two exponents.
    final exponentShift =
        _decimalsOf(toCurrencyCode) - _decimalsOf(fromCurrencyCode);
    final scale = math.pow(10, exponentShift);
    return (amountMinor * toRate / fromRate * scale).round();
  }

  static int _decimalsOf(String currencyCode) {
    final currency = CurrencyCode.tryParse(currencyCode);
    if (currency == null) {
      throw TaxRateUnavailableException(
        message:
            'OpenBudget does not know the minor unit of $currencyCode, so it '
            'cannot convert amounts in it.',
      );
    }
    return currency.decimals;
  }

  TaxFxSnapshotRates? _snapshotFor(DateTime date) {
    TaxFxSnapshotRates? latestBefore;
    for (final snapshot in _snapshots) {
      if (snapshot.fetchedAt.isAfter(date)) {
        return latestBefore ?? snapshot;
      }
      latestBefore = snapshot;
    }
    return latestBefore;
  }

  double _rateFor(
    TaxFxSnapshotRates snapshot,
    String currencyCode,
    DateTime date,
  ) {
    if (currencyCode == snapshot.baseCurrencyCode) return 1;

    final rate = snapshot.rates[currencyCode];
    if (rate == null || rate <= 0) {
      throw TaxRateUnavailableException(
        message:
            'The ${snapshot.baseCurrencyCode} snapshot from '
            '${snapshot.fetchedAt.toIso8601String()} has no $currencyCode rate to '
            'convert an amount dated ${date.toIso8601String()}.',
      );
    }
    return rate;
  }
}
