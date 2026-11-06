/// Parses a plain amount such as `"12.34"` into integer minor units.
///
/// Works on integers only: the whole and fraction parts are split on the
/// decimal point and parsed separately, so no binary floating point touches
/// the value. Thousands separators (`,`) and spaces are ignored. Returns null
/// for anything that is not a non-negative amount with at most [decimals]
/// fractional digits, so a mistyped figure is refused instead of rounded.
int? parseMinorUnits(String text, int decimals) {
  final cleaned = text.trim().replaceAll(',', '').replaceAll(' ', '');
  if (cleaned.isEmpty) return null;

  final dot = cleaned.indexOf('.');
  final wholeText = dot < 0 ? cleaned : cleaned.substring(0, dot);
  final fractionText = dot < 0 ? '' : cleaned.substring(dot + 1);
  if (wholeText.isEmpty && fractionText.isEmpty) return null;
  final digits = RegExp(r'^\d*$');
  if (!digits.hasMatch(wholeText) || !digits.hasMatch(fractionText)) {
    return null;
  }
  if (fractionText.length > decimals) return null;

  final whole = wholeText.isEmpty ? 0 : int.parse(wholeText);
  final fraction = fractionText.isEmpty
      ? 0
      : int.parse(fractionText.padRight(decimals, '0'));
  return whole * _pow10(decimals) + fraction;
}

/// Renders [minor] as a plain editable figure such as `"12.34"`, with no
/// currency symbol or grouping.
String formatMinorUnits(int minor, int decimals) {
  final sign = minor < 0 ? '-' : '';
  final abs = minor.abs();
  final whole = abs ~/ _pow10(decimals);
  if (decimals == 0) return '$sign$whole';
  final fraction = (abs % _pow10(decimals)).toString().padLeft(decimals, '0');
  return '$sign$whole.$fraction';
}

int _pow10(int exponent) {
  var result = 1;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
