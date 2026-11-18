import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// The canonical wire form of a currency code.
///
/// Codes are compared and grouped in this form so `usd`, `USD`, and ` USD `
/// never become separate buckets. Unsupported codes keep their own bucket
/// instead of being folded into a supported currency.
String normalizeCurrencyCode(String code) => code.trim().toUpperCase();

/// Aggregates signed minor-unit amounts by raw currency code.
///
/// Unknown codes stay separate, keyed by their normalized code, so an
/// unsupported currency is never merged into USD.
Map<String, int> aggregateMinorByCurrency<T>(
  Iterable<T> items, {
  required String Function(T item) currencyCodeOf,
  required int Function(T item) amountMinorOf,
}) {
  final totals = <String, int>{};
  for (final item in items) {
    final code = normalizeCurrencyCode(currencyCodeOf(item));
    totals[code] = (totals[code] ?? 0) + amountMinorOf(item);
  }
  return totals;
}

/// Formats a currency breakdown, for example:
/// `USD $1,200.00 · EUR €150.00`.
///
/// Unsupported codes print their raw code and a plain amount, for example
/// `XYZ 12.50`, rather than borrowing another currency's symbol.
String formatCurrencyBreakdown(
  Map<String, int> totals, {
  bool includeCurrencyCode = true,
  String separator = ' · ',
}) {
  final entries = totals.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  return entries
      .map((entry) {
        final formatted = formatMinorForCode(entry.value, entry.key);
        // Unsupported codes already carry their code; supported amounts get
        // the code prefix so mixed-currency totals stay unambiguous.
        if (!includeCurrencyCode ||
            entry.key.isEmpty ||
            CurrencyCode.tryParse(entry.key) == null) {
          return formatted;
        }
        return '${entry.key} $formatted';
      })
      .join(separator);
}
