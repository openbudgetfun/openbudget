import 'dart:convert';

import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// Parses the stored profile payload into its typed jurisdiction profile.
///
/// A malformed payload returns null rather than taking a screen down: the
/// profile screen can still replace it.
TaxProfile? parseTaxProfileJson(String json) {
  try {
    final decoded = jsonDecode(json);
    if (decoded is! Map<String, Object?>) {
      return null;
    }
    return TaxProfile.fromJson(decoded);
  } on FormatException {
    return null;
  }
}

/// The tax year that contains [now] in [jurisdiction], falling back to the
/// calendar year when the rule pack has no rates for the current year.
int currentTaxYearStart(TaxJurisdiction jurisdiction, {DateTime? now}) {
  final date = (now ?? DateTime.now()).toUtc();
  try {
    return TaxRules.forJurisdiction(jurisdiction).taxYearFor(date).startYear;
  } on UnsupportedTaxYearException {
    return date.year;
  }
}

/// The rate of a band in basis points, written the way a person reads it.
String formatRateBasisPoints(int basisPoints) {
  final percent = basisPoints / 100;
  return percent == percent.roundToDouble()
      ? percent.toInt().toString()
      : percent.toStringAsFixed(2);
}

/// The server's validation text for a rejected input, otherwise the
/// localized [fallback].
///
/// Only validation errors carry text written for the person filling in the
/// form; every other failure shows the screen's own message.
String taxErrorMessage(Object error, String fallback) => switch (error) {
  ValidationException(:final message) when message.isNotEmpty => message,
  _ => fallback,
};

/// An indirect-tax rate written the way a person reads it, such as `9.975`
/// or `16`, without the percent sign.
///
/// [ratePerMillion] is millionths of the taxed amount, so 1% is `10000`. The
/// text is built from the integer's digits: no double is involved, so no
/// rate is ever rounded or nudged by floating point. [decimalSeparator] is
/// the locale's.
String formatRatePerMillion(
  int ratePerMillion, {
  String decimalSeparator = '.',
}) {
  final sign = ratePerMillion < 0 ? '-' : '';
  final magnitude = ratePerMillion.abs();
  final whole = magnitude ~/ 10000;
  final fraction = (magnitude % 10000)
      .toString()
      .padLeft(4, '0')
      .replaceFirst(RegExp(r'0+$'), '');
  return fraction.isEmpty
      ? '$sign$whole'
      : '$sign$whole$decimalSeparator$fraction';
}

/// The rates in [rates] that apply on [date], in dataset order.
///
/// A rate applies from its `from` day up to, but not including, its `to`
/// day; a null `to` is a rate still in force. Dates compare by calendar day.
List<IndirectTaxRate> ratesInForce(List<IndirectTaxRate> rates, DateTime date) {
  final day = DateTime.utc(date.year, date.month, date.day);
  return [
    for (final rate in rates)
      if (!rate.from.isAfter(day) &&
          (rate.to == null || day.isBefore(rate.to!)))
        rate,
  ];
}

/// [value] as a link to open outside the app, or null unless it is a plain
/// http or https address.
Uri? webLink(String value) {
  final uri = Uri.tryParse(value);
  if (uri == null || uri.host.isEmpty) {
    return null;
  }
  return uri.scheme == 'https' || uri.scheme == 'http' ? uri : null;
}
