/// Exact parsing of XRP Ledger issued-currency amount strings.
///
/// XRPL serialises issued-currency balances as strings that may use
/// exponent notation (for example `"1.5e-7"` or `"9999999999999999e80"`).
/// Dart's [BigInt.parse] and ExactDecimal.tryParse reject that form, so
/// this parser handles the mantissa and exponent separately on [BigInt]
/// values and never goes through a [double].
class XrplAmount {
  /// Converts an XRPL amount string to its 15-decimal raw integer form.
  ///
  /// Returns `null` when [raw] is not a valid decimal number. A value that
  /// underflows to zero at 15 decimals returns [BigInt.zero], so callers
  /// can distinguish "unparseable" from "dust".
  static BigInt? tryParse(String raw, {int decimals = 15}) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    var negative = false;
    var body = text;
    if (body.startsWith('+')) {
      body = body.substring(1);
    } else if (body.startsWith('-')) {
      negative = true;
      body = body.substring(1);
    }
    if (body.isEmpty) return null;

    String mantissa;
    int exponent;
    final eIndex = body.toLowerCase().indexOf('e');
    if (eIndex >= 0) {
      mantissa = body.substring(0, eIndex);
      final expText = body.substring(eIndex + 1);
      if (mantissa.isEmpty || expText.isEmpty) return null;
      try {
        exponent = int.parse(expText);
      } on FormatException {
        return null;
      }
    } else {
      mantissa = body;
      exponent = 0;
    }

    if (!RegExp(r'^(\d+\.?\d*|\.\d+)$').hasMatch(mantissa)) {
      return null;
    }

    final dotIndex = mantissa.indexOf('.');
    String digits;
    int fractionDigits;
    if (dotIndex < 0) {
      digits = mantissa;
      fractionDigits = 0;
    } else {
      digits =
          mantissa.substring(0, dotIndex) + mantissa.substring(dotIndex + 1);
      fractionDigits = mantissa.length - dotIndex - 1;
    }
    if (digits.isEmpty) return null;
    final mantissaInt = BigInt.tryParse(digits);
    if (mantissaInt == null) return null;

    final totalExponent = exponent - fractionDigits + decimals;
    BigInt rawValue;
    if (totalExponent >= 0) {
      rawValue = mantissaInt * _pow10(totalExponent);
    } else {
      rawValue = mantissaInt ~/ _pow10(-totalExponent);
    }
    if (negative) rawValue = -rawValue;
    return rawValue;
  }

  /// Alias for [tryParse].
  static BigInt? parse(String raw, {int decimals = 15}) =>
      tryParse(raw, decimals: decimals);

  /// Alias for [tryParse].
  static BigInt? toQuantityRaw(String raw, {int decimals = 15}) =>
      tryParse(raw, decimals: decimals);

  /// Alias for [tryParse].
  static BigInt? quantityRaw(String raw, {int decimals = 15}) =>
      tryParse(raw, decimals: decimals);

  /// Alias for [tryParse].
  static BigInt? parseAmount(String raw, {int decimals = 15}) =>
      tryParse(raw, decimals: decimals);

  static BigInt _pow10(int n) {
    var result = BigInt.one;
    final ten = BigInt.from(10);
    for (var i = 0; i < n; i++) {
      result *= ten;
    }
    return result;
  }
}

// Backwards/alternative spellings.
typedef XrplDecimal = XrplAmount;
typedef XrplQuantity = XrplAmount;
