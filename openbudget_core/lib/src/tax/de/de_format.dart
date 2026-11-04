/// Formats whole euros with German thousands separators.
String deEuro(int minor) {
  final euros = minor ~/ 100;
  final digits = euros.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[index]);
  }
  return '$buffer Euro';
}

/// Formats a date the way a German tax letter does: `31.07.2027`.
String deDate(DateTime value) =>
    '${value.day.toString().padLeft(2, '0')}.'
    '${value.month.toString().padLeft(2, '0')}.${value.year}';
