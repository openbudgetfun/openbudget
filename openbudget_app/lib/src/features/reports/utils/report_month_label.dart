import 'package:openbudget_app/l10n/generated/app_localizations.dart';

/// Splits an int yyyymm month into its year and calendar month.
({int year, int calendarMonth}) monthKeyParts(int yyyymm) =>
    (year: yyyymm ~/ 100, calendarMonth: yyyymm % 100);

/// The month's name in the active locale, followed by its year, from a
/// yyyymm int.
String reportYyyymmLabel(AppLocalizations l10n, int yyyymm) {
  final (year, calendarMonth) = monthKeyParts(yyyymm);
  return reportMonthLabel(l10n, calendarMonth, year);
}

/// The month's short axis label from a yyyymm int.
String reportYyyymmAxisLabel(AppLocalizations l10n, int yyyymm) =>
    reportMonthAxisLabel(l10n, monthKeyParts(yyyymm).calendarMonth);

/// The month's name in the active locale, followed by its year.
String reportMonthLabel(AppLocalizations l10n, int month, int year) =>
    '${reportMonthName(l10n, month)} $year';

/// The month's full name in the active locale.
String reportMonthName(AppLocalizations l10n, int month) => switch (month) {
  1 => l10n.budgetMonthJanuary,
  2 => l10n.budgetMonthFebruary,
  3 => l10n.budgetMonthMarch,
  4 => l10n.budgetMonthApril,
  5 => l10n.budgetMonthMay,
  6 => l10n.budgetMonthJune,
  7 => l10n.budgetMonthJuly,
  8 => l10n.budgetMonthAugust,
  9 => l10n.budgetMonthSeptember,
  10 => l10n.budgetMonthOctober,
  11 => l10n.budgetMonthNovember,
  12 => l10n.budgetMonthDecember,
  _ => '',
};

/// The month's name clipped to three letters for a chart axis.
String reportMonthAxisLabel(AppLocalizations l10n, int month) {
  final name = reportMonthName(l10n, month);
  return name.length > 3 ? name.substring(0, 3) : name;
}
