import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Calendar dates written the way the reader's locale writes them, through
/// `intl`, so no screen builds a date string by hand.
///
/// Dates from the server are calendar dates at UTC midnight; they are
/// formatted as stored, never shifted into the device's time zone.
abstract final class DateLabels {
  /// "Nov 8, 2026" in English: a full date that reads at a glance.
  static String full(BuildContext context, DateTime date) =>
      DateFormat.yMMMd(_locale(context)).format(date);

  /// "Nov 8" in English: a date within a range the reader already knows.
  static String short(BuildContext context, DateTime date) =>
      DateFormat.MMMd(_locale(context)).format(date);

  static String _locale(BuildContext context) =>
      Localizations.localeOf(context).toLanguageTag();
}
