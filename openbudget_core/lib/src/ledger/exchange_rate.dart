/// Exact decimal parsing and currency conversion for journal amounts.
///
/// FX rates are exact decimals carried as strings (`"1.234567"`), never
/// doubles: a rate that cannot be reproduced bit for bit cannot support an
/// audit. All arithmetic runs on [BigInt] so no rounding happens before the
/// single, documented half-up step.
library;

import 'package:openbudget_core/src/constants/currencies.dart';

/// A non-negative exact decimal, parsed from a plain string.
class ExactDecimal {
  /// Creates a decimal from its integer numerator and denominator.
  ///
  /// [denominator] must be positive.
  ExactDecimal(this.numerator, this.denominator)
    : assert(denominator > BigInt.zero, 'denominator must be positive');

  /// The exact decimal `1`, the rate between a currency and itself.
  static final ExactDecimal one = ExactDecimal(BigInt.one, BigInt.one);

  /// The scaled integer value: `"1.234567"` is `1234567 / 1000000`.
  final BigInt numerator;

  /// The positive scale denominator.
  final BigInt denominator;

  static final RegExp _pattern = RegExp(r'^\d+(\.\d+)?$');

  /// Parses `"1.234567"`-style decimal strings.
  ///
  /// Returns null for anything else: signs, exponent notation, thousands
  /// separators and empty strings are all rejected so a malformed rate can
  /// never silently change a posting.
  static ExactDecimal? tryParse(String raw) {
    final text = raw.trim();
    if (!_pattern.hasMatch(text)) {
      return null;
    }
    final dot = text.indexOf('.');
    final whole = dot < 0 ? text : text.substring(0, dot);
    final fraction = dot < 0 ? '' : text.substring(dot + 1);
    final digits = '$whole$fraction';
    if (digits.isEmpty || digits.contains(RegExp(r'^0+$'))) {
      // A zero rate is never a meaningful exchange rate.
      return null;
    }
    return ExactDecimal(
      BigInt.parse(digits),
      BigInt.from(10).pow(fraction.length),
    );
  }

  /// True when this decimal equals exactly 1.
  bool get isOne => numerator == denominator;

  @override
  String toString() {
    if (denominator == BigInt.one) {
      return numerator.toString();
    }
    var text = numerator.toString();
    final scale = denominator.toString().length - 1;
    if (text.length <= scale) {
      text = text.padLeft(scale + 1, '0');
    }
    final dot = text.length - scale;
    return '${text.substring(0, dot)}.${text.substring(dot)}';
  }
}

/// Rounds `numerator / denominator` half up for a non-negative numerator.
BigInt _roundHalfUp(BigInt numerator, BigInt denominator) {
  final doubled = numerator * BigInt.two + denominator;
  return doubled ~/ (denominator * BigInt.two);
}

/// The minor-unit exponent of an ISO currency code used in the ledger, or
/// null when the code is not supported.
int? exponentForCurrency(String currencyCode) {
  for (final currency in CurrencyCode.values) {
    if (currency.code == currencyCode.toUpperCase()) {
      return currency.decimals;
    }
  }
  return null;
}

/// Converts a transaction-currency amount into functional-currency minor
/// units, rounding half up on the absolute value.
///
/// The rate is functional per one transaction currency, as the ledger stores
/// it. For example, USD 100.00 (10000 minor) at a rate of `"1.5"` JPY per
/// USD lands on exactly 150 JPY (exponent 0); USD 33.33 (3333 minor) at
/// `"0.8"` GBP per USD lands on 2666 minor because 26.664 rounds to 26.66.
int convertMinorUnits({
  required int amountMinor,
  required ExactDecimal exchangeRate,
  required int transactionExponent,
  required int functionalExponent,
}) {
  final scaled =
      BigInt.from(amountMinor) *
      exchangeRate.numerator *
      BigInt.from(10).pow(functionalExponent);
  final divisor =
      BigInt.from(10).pow(transactionExponent) * exchangeRate.denominator;
  final rounded = _roundHalfUp(scaled.abs(), divisor);
  return (scaled.isNegative ? -rounded : rounded).toInt();
}
