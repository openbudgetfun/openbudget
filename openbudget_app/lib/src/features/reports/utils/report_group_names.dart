import 'package:openbudget_app/l10n/generated/app_localizations.dart';

/// The provider-side key for spending the server returned without a group,
/// whether the report groups by category, envelope or payee.
///
/// The server names the row itself ("No category", "No envelope",
/// "No payee"); the app keeps one stable key so every report shows the same
/// translated row and its rows still add up to the report total.
const reportUncategorisedGroup = '__uncategorised__';

/// The provider-side key for spending the transaction never attributed to a
/// payee, used when the report groups by payee.
const reportUnknownPayeeGroup = '__unknown_payee__';

/// The display name for one report group, translated at render time.
///
/// Everything except the two buckets above is a real category, envelope or
/// payee name and is shown as the server sent it.
String reportGroupLabel(AppLocalizations l10n, String group) => switch (group) {
  reportUncategorisedGroup => l10n.reportsUncategorised,
  reportUnknownPayeeGroup => l10n.transactionsUnknownPayee,
  _ => group,
};
