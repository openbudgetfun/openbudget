import 'package:openbudget_core/openbudget_core.dart';

String formatCents(int cents, CurrencyCode currency) {
  final isNegative = cents < 0;
  final absCents = cents.abs();
  final decimals = currency.decimals;

  if (decimals == 0) {
    final formatted = _addThousandsSeparator(absCents.toString());
    return '${isNegative ? '-' : ''}${currency.symbol}$formatted';
  }

  final wholePart = absCents ~/ _pow10(decimals);
  final fractionalPart = (absCents % _pow10(decimals)).toString().padLeft(
    decimals,
    '0',
  );
  final formatted = _addThousandsSeparator(wholePart.toString());
  return '${isNegative ? '-' : ''}${currency.symbol}$formatted.$fractionalPart';
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
