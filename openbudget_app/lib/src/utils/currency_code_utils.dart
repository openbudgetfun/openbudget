import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// Parses [code] into a supported [CurrencyCode], defaulting to USD.
CurrencyCode parseCurrencyCode(String code) => CurrencyCode.values.firstWhere(
  (currency) => currency.code == code,
  orElse: () => CurrencyCode.usd,
);

/// Aggregates signed cents by currency.
Map<CurrencyCode, int> aggregateCentsByCurrency<T>(
  Iterable<T> items, {
  required String Function(T item) currencyCodeOf,
  required int Function(T item) amountCentsOf,
}) {
  final totals = <CurrencyCode, int>{};
  for (final item in items) {
    final currency = parseCurrencyCode(currencyCodeOf(item));
    totals[currency] = (totals[currency] ?? 0) + amountCentsOf(item);
  }
  return totals;
}

/// Formats a currency breakdown, for example:
/// `USD $1,200.00 · EUR €150.00`.
String formatCurrencyBreakdown(
  Map<CurrencyCode, int> totals, {
  bool includeCurrencyCode = true,
  String separator = ' · ',
}) {
  final entries = totals.entries.toList()
    ..sort((a, b) => a.key.code.compareTo(b.key.code));

  return entries
      .map((entry) {
        final formatted = formatCents(entry.value, entry.key);
        if (includeCurrencyCode) {
          return '${entry.key.code} $formatted';
        }
        return formatted;
      })
      .join(separator);
}
