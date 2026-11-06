import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// Parses a plain amount such as `"12.34"` into minor units.
///
/// The work runs on integers only: the whole and fraction parts are split on
/// the decimal mark, the fraction is right-padded to [decimals] and every
/// digit is parsed with [int.parse]. Thousands separators and spaces are
/// stripped first. Returns null for anything that is not a non-negative
/// amount carrying at most [decimals] fractional digits — no rounding hides
/// a mistyped figure.
int? parseAmountToMinor(String text, int decimals) {
  final cleaned = text.trim().replaceAll(',', '').replaceAll(' ', '');
  if (cleaned.isEmpty) return null;

  final dot = cleaned.indexOf('.');
  final wholeText = dot < 0 ? cleaned : cleaned.substring(0, dot);
  final fractionText = dot < 0 ? '' : cleaned.substring(dot + 1);
  if (wholeText.isEmpty && fractionText.isEmpty) return null;
  if (wholeText.contains(RegExp(r'\D')) ||
      fractionText.contains(RegExp(r'\D'))) {
    return null;
  }
  if (fractionText.length > decimals) return null;

  final whole = wholeText.isEmpty ? 0 : int.parse(wholeText);
  final fraction = fractionText.isEmpty
      ? 0
      : int.parse(fractionText.padRight(decimals, '0'));
  return whole * _pow10(decimals) + fraction;
}

/// Renders [minor] as a plain editable figure such as `"12.34"`.
String minorToPlainString(int minor, int decimals) {
  final isNegative = minor < 0;
  final abs = minor.abs();
  final whole = abs ~/ _pow10(decimals);
  if (decimals == 0) {
    return '${isNegative ? '-' : ''}$whole';
  }
  final fraction = (abs % _pow10(decimals)).toString().padLeft(decimals, '0');
  return '${isNegative ? '-' : ''}$whole.$fraction';
}

int _pow10(int exponent) {
  var result = 1;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}

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
    _lineIndex(issue),
  ),
  'unbalancedFunctional' => l10n.journalIssueUnbalancedFunctional,
  _ => issue.message.isEmpty ? l10n.journalIssueFallback : issue.message,
};

/// The 1-based line index encoded in a core issue message such as
/// `Line 2 (1000) ...`, or 0 when the message does not name a line.
int _lineIndex(LedgerValidationIssue issue) {
  final match = RegExp(r'^Line (\d+)').firstMatch(issue.message);
  return match == null ? 0 : int.parse(match.group(1)!);
}

/// The calendar date of [dateTime] with the time removed, so journal and
/// trial-balance dates stay calendar dates rather than UTC instants.
DateTime ledgerCalendarDate(DateTime dateTime) =>
    DateTime(dateTime.year, dateTime.month, dateTime.day);
