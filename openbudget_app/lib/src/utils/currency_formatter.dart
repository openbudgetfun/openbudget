import 'package:openbudget_core/openbudget_core.dart';

/// Formats [minor] using the symbol and precision of [currency].
String formatMinor(int minor, CurrencyCode currency) {
  final isNegative = minor < 0;
  final absMinor = minor.abs();
  final decimals = currency.decimals;

  if (decimals == 0) {
    final formatted = _addThousandsSeparator(absMinor.toString());
    return '${isNegative ? '-' : ''}${currency.symbol}$formatted';
  }

  return '${isNegative ? '-' : ''}${currency.symbol}${_formatUnits(absMinor, decimals)}';
}

/// Formats [minor] for [code], falling back to the raw code and a plain amount
/// for codes OpenBudget does not support.
///
/// An unsupported code is never rendered with another currency's symbol:
/// `formatMinorForCode(1250, 'XYZ')` returns `XYZ 12.50`.
String formatMinorForCode(int minor, String code) {
  final currency = CurrencyCode.tryParse(code);
  if (currency != null) return formatMinor(minor, currency);

  final normalized = code.trim().toUpperCase();
  final amount = formatPlainMinor(minor);
  return normalized.isEmpty ? amount : '$normalized $amount';
}

/// Formats [minor] as a plain two-decimal number with thousands separators.
String formatPlainMinor(int minor) {
  final isNegative = minor < 0;
  final absMinor = minor.abs();
  return '${isNegative ? '-' : ''}${_formatUnits(absMinor, 2)}';
}

/// The number of minor-unit decimals for [code].
///
/// Unsupported codes use two decimals, matching [formatMinorForCode], because
/// their real precision is unknown to the app.
int currencyDecimalsForCode(String code) =>
    CurrencyCode.tryParse(code)?.decimals ?? 2;

/// The symbol for [code], or the normalized code itself when unsupported.
String currencySymbolForCode(String code) {
  final currency = CurrencyCode.tryParse(code);
  return currency?.symbol ?? code.trim().toUpperCase();
}

String _formatUnits(int absMinor, int decimals) {
  final wholePart = absMinor ~/ _pow10(decimals);
  final fractionalPart = (absMinor % _pow10(decimals)).toString().padLeft(
    decimals,
    '0',
  );
  final formatted = _addThousandsSeparator(wholePart.toString());
  return '$formatted.$fractionalPart';
}

int _pow10(int exponent) {
  var result = 1;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}

String _addThousandsSeparator(String number) {
  if (number.length <= 3) return number;
  final buffer = StringBuffer();
  var count = 0;
  for (var i = number.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(number[i]);
    count++;
  }
  return buffer.toString().split('').reversed.join();
}
