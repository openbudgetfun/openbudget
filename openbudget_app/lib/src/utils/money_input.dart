import 'package:openbudget_core/openbudget_core.dart';

/// Parses typed money text into integer minor units for a currency with
/// [decimals] fractional digits.
///
/// A single leading `-` is accepted only when [allowNegative] is true. The
/// rest of the text goes through [parseMinorUnits], so grouping separators and
/// spaces are ignored and anything that is not an amount with at most
/// [decimals] decimals is refused instead of rounded.
int? parseMoneyInput(
  String text, {
  required int decimals,
  bool allowNegative = false,
}) {
  final trimmed = text.trim();
  if (trimmed.startsWith('-')) {
    if (!allowNegative) return null;
    final minor = parseMinorUnits(trimmed.substring(1), decimals);
    return minor == null ? null : -minor;
  }
  return parseMinorUnits(trimmed, decimals);
}

/// The validation message for a typed money field.
///
/// Returns null when the field is empty or [text] is an exact amount for
/// [decimals]. Empty text stays valid so an untouched field does not start
/// with an error.
String? moneyInputError(
  String text, {
  required int decimals,
  required String message,
  bool allowNegative = false,
}) {
  if (text.trim().isEmpty) return null;
  final minor = parseMoneyInput(
    text,
    decimals: decimals,
    allowNegative: allowNegative,
  );
  return minor == null ? message : null;
}
