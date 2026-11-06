import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// The server's validation text for a rejected journal or lock date,
/// otherwise the localized [fallback].
///
/// Only validation errors carry text written for the person filling in the
/// form; every other failure shows the screen's own message.
String ledgerErrorMessage(Object error, String fallback) => switch (error) {
  ValidationException(:final message) when message.isNotEmpty => message,
  _ => fallback,
};

/// The localized message for a core draft-validation issue.
///
/// The editor posts single-currency journals at a rate of exactly one, so
/// only a few of the core rules can ever fire; anything else falls back to
/// the core's own English text rather than hiding the reason.
String ledgerIssueMessage(
  AppLocalizations l10n,
  LedgerValidationIssue issue,
) => switch (issue.code) {
  'atLeastTwoLines' => l10n.journalIssueAtLeastTwoLines,
  'lineOneSideRequired' => l10n.journalIssueLineOneSideRequired(
    (issue.lineIndex ?? 0) + 1,
  ),
  'unbalancedFunctional' => l10n.journalIssueUnbalancedFunctional,
  _ => issue.message.isEmpty ? l10n.journalIssueFallback : issue.message,
};

/// The calendar date of [dateTime] with the time removed, so journal and
/// trial-balance dates stay calendar dates rather than UTC instants.
DateTime ledgerCalendarDate(DateTime dateTime) =>
    DateTime(dateTime.year, dateTime.month, dateTime.day);
