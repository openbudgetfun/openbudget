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

/// An amount in minor units as a plain field value, without a currency symbol.
String minorToPlainText(int minor, int decimals) =>
    (minor / pow10(decimals)).toStringAsFixed(decimals);

/// Parses a plain field value into minor units, or null when it is not a
/// non-negative number.
int? parsePlainMinor(String text, int decimals) {
  final normalized = text.trim().replaceAll(',', '');
  if (normalized.isEmpty) return null;
  final amount = double.tryParse(normalized);
  if (amount == null || amount < 0) return null;
  return (amount * pow10(decimals)).round();
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

double pow10(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
