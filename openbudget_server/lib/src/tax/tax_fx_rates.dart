import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/fx_rates/fx_quote_selection.dart';
import 'package:openbudget_server/src/generated/protocol.dart';

/// One currency conversion a tax entry needs.
class TaxFxRequest {
  const TaxFxRequest({
    required this.fromCurrencyCode,
    required this.toCurrencyCode,
    required this.date,
  });

  final String fromCurrencyCode;
  final String toCurrencyCode;

  /// Calendar date the entry belongs to.
  final DateTime date;

  /// Identity needs no stored rate.
  bool get isIdentity => fromCurrencyCode == toCurrencyCode;
}

/// Exact daily exchange rates for tax entry conversion.
///
/// Each quote comes from the shared daily USD quotes over the exclusive
/// seven-day window ending on the entry's date, so a missing day can fall back
/// within the week but never to a future quote. Identity is returned only when
/// both currency codes are identical. The rate is applied once through
/// [convertMinorUnits] with each currency's ISO exponent; no double or
/// `math.pow` arithmetic participates in money conversion.
///
/// A missing quote is never replaced with 1:1 or a zero amount. [missingFor]
/// reports every distinct gap so the caller can request one historical
/// backfill per date and then fail the read with [FxRateUnavailableException].
class TaxFxRates {
  TaxFxRates({
    required Iterable<FxDailyRate> rates,
    required this.evaluatedAt,
  }) : _rowsByCurrency = _indexByCurrency(rates);

  final DateTime evaluatedAt;
  final Map<String, List<FxDailyRate>> _rowsByCurrency;
  final Map<(String, String, DateTime), FxQuoteSelection?> _quotes = {};

  /// Every distinct request without a usable quote.
  List<TaxFxRequest> missingFor(Iterable<TaxFxRequest> requests) {
    final missing = <(String, String, DateTime), TaxFxRequest>{};

    for (final request in requests) {
      if (request.isIdentity) continue;
      _requireExponent(request.fromCurrencyCode);
      _requireExponent(request.toCurrencyCode);

      if (_quoteFor(request) != null) continue;
      missing[(
            request.fromCurrencyCode,
            request.toCurrencyCode,
            request.date,
          )] =
          request;
    }

    return missing.values.toList(growable: false);
  }

  /// Converts [amountMinor] into [toCurrencyCode] at the entry's daily rate.
  ///
  /// The caller passes an unsigned magnitude. Rounding happens once, half up
  /// on the absolute value, which is the ledger's single conversion boundary.
  int convert({
    required int amountMinor,
    required String fromCurrencyCode,
    required String toCurrencyCode,
    required DateTime date,
  }) {
    if (fromCurrencyCode == toCurrencyCode) return amountMinor;

    final request = TaxFxRequest(
      fromCurrencyCode: fromCurrencyCode,
      toCurrencyCode: toCurrencyCode,
      date: date,
    );
    final quote = _quoteFor(request);
    if (quote == null) {
      throw FxRateUnavailableException(
        message:
            'No exchange rate is available to convert $fromCurrencyCode to '
            '$toCurrencyCode on ${date.toIso8601String()}.',
        fromCurrencyCode: fromCurrencyCode,
        toCurrencyCode: toCurrencyCode,
        date: date,
      );
    }

    try {
      return convertMinorUnits(
        amountMinor: amountMinor,
        exchangeRate: quote.rate,
        transactionExponent: _requireExponent(fromCurrencyCode),
        functionalExponent: _requireExponent(toCurrencyCode),
        // A converted entry beyond the web-safe range is a data problem, not
        // a reason to publish a truncated tax figure.
      );
      // Security: the conversion boundary reports an out-of-range result as a
      // RangeError; turn it into a validation failure instead of a raw Error.
      // ignore: avoid_catching_errors
    } on RangeError {
      throw ValidationException(
        message:
            'Converting a $fromCurrencyCode tax entry to $toCurrencyCode '
            'exceeds the safe minor-unit range.',
      );
    }
  }

  FxQuoteSelection? _quoteFor(TaxFxRequest request) {
    final key = (
      request.fromCurrencyCode,
      request.toCurrencyCode,
      request.date,
    );
    if (_quotes.containsKey(key)) return _quotes[key];

    final fromRows = _rowsByCurrency[request.fromCurrencyCode] ?? const [];
    final toRows = _rowsByCurrency[request.toCurrencyCode] ?? const [];
    final selection = FxQuoteSelection.select(
      fromCurrencyCode: request.fromCurrencyCode,
      toCurrencyCode: request.toCurrencyCode,
      date: request.date,
      rates: [...fromRows, ...toRows],
      now: evaluatedAt,
    );

    _quotes[key] = selection;
    return selection;
  }

  static Map<String, List<FxDailyRate>> _indexByCurrency(
    Iterable<FxDailyRate> rates,
  ) {
    final indexed = <String, List<FxDailyRate>>{};
    for (final rate in rates) {
      (indexed[rate.currencyCode] ??= []).add(rate);
    }
    return indexed;
  }

  static int _requireExponent(String currencyCode) {
    final exponent = exponentForCurrency(currencyCode);
    if (exponent == null) {
      throw ValidationException(
        message:
            'OpenBudget does not know the minor unit of $currencyCode, so it '
            'cannot convert a tax entry in it.',
      );
    }
    return exponent;
  }
}
