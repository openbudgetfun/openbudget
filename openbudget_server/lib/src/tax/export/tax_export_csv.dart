/// RFC 4180 CSV formatting for the tax export.
library;

/// One CSV field, escaped per RFC 4180.
///
/// A field that carries a comma, a double quote or a line break is wrapped
/// in double quotes with any inner quote doubled; every other field is
/// written as-is. Amounts never pass through here as doubles — callers
/// format minor units with [minorToDecimalString] first.
String csvField(Object? value) {
  final text = value?.toString() ?? '';
  final needsQuotes =
      text.contains(',') ||
      text.contains('"') ||
      text.contains('\n') ||
      text.contains('\r');
  if (!needsQuotes) return text;
  return '"${text.replaceAll('"', '""')}"';
}

/// One CSV row of [fields], joined with commas and a CRLF terminator as
/// RFC 4180 prescribes.
String csvRow(Iterable<Object?> fields) =>
    '${fields.map(csvField).join(',')}\r\n';

/// Writes [minor] as a decimal string at the currency's [exponent].
///
/// 123456 at exponent 2 is `1234.56`; 1234 at exponent 0 is `1234`;
/// -125 at exponent 3 is `-0.125`. The digits never pass through a double,
/// so the text is exact for every web-safe minor-unit amount.
String minorToDecimalString(int minor, int exponent) {
  if (exponent < 0) {
    throw ArgumentError.value(exponent, 'exponent', 'must not be negative');
  }
  final sign = minor.isNegative ? '-' : '';
  final digits = minor.abs().toString().padLeft(exponent + 1, '0');
  if (exponent == 0) return '$sign$digits';
  final cut = digits.length - exponent;
  return '$sign${digits.substring(0, cut)}.${digits.substring(cut)}';
}
