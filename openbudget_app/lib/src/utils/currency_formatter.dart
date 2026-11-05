import 'package:openbudget_core/openbudget_core.dart';

/// Formats [cents] using the symbol and precision of [currency].
String formatCents(int cents, CurrencyCode currency) {
  final isNegative = cents < 0;
  final absCents = cents.abs();
  final decimals = currency.decimals;

  if (decimals == 0) {
    final formatted = _addThousandsSeparator(absCents.toString());
    return '${isNegative ? '-' : ''}${currency.symbol}$formatted';
  }

  return '${isNegative ? '-' : ''}${currency.symbol}${_formatUnits(absCents, decimals)}';
}

/// Formats [cents] for [code], falling back to the raw code and a plain amount
/// for codes OpenBudget does not support.
///
/// An unsupported code is never rendered with another currency's symbol:
/// `formatCentsForCode(1250, 'XYZ')` returns `XYZ 12.50`.
String formatCentsForCode(int cents, String code) {
  final currency = CurrencyCode.tryParse(code);
  if (currency != null) return formatCents(cents, currency);

  final normalized = code.trim().toUpperCase();
  final amount = formatPlainCents(cents);
  return normalized.isEmpty ? amount : '$normalized $amount';
}

/// Formats [cents] as a plain two-decimal number with thousands separators.
String formatPlainCents(int cents) {
  final isNegative = cents < 0;
  final absCents = cents.abs();
  return '${isNegative ? '-' : ''}${_formatUnits(absCents, 2)}';
}

/// The number of minor-unit decimals for [code].
///
/// Unsupported codes use two decimals, matching [formatCentsForCode], because
/// their real precision is unknown to the app.
int currencyDecimalsForCode(String code) =>
    CurrencyCode.tryParse(code)?.decimals ?? 2;

/// The symbol for [code], or the normalized code itself when unsupported.
String currencySymbolForCode(String code) {
  final currency = CurrencyCode.tryParse(code);
  return currency?.symbol ?? code.trim().toUpperCase();
}

String _formatUnits(int absCents, int decimals) {
  final wholePart = absCents ~/ _pow10(decimals);
  final fractionalPart = (absCents % _pow10(decimals)).toString().padLeft(
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
