import 'dart:collection';
import 'dart:convert';

import 'package:openbudget_core/src/countries/country_info.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';
import 'package:openbudget_core/src/time/civil_date.dart';

// Re-check scheduling for the tax reference data (docs/tax-jurisdictions.md,
// sections 7 and 8.5).
//
// Every researched country carries a `recheckBy` date; this library decides
// which items are due on or before a given day and renders the report in the
// two shapes the weekly freshness workflow needs. The date logic is pure, so
// a unit test can trust exactly what the workflow reports.

/// One item in the tax reference data that must be re-checked by a date.
///
/// Countries and rule-set caveats are the two kinds today: a caveat's
/// `TaxRuleCaveat.recheckBy` maps onto this same shape and joins the
/// report input alongside the countries.
final class RecheckItem {
  const RecheckItem({
    required this.kind,
    required this.key,
    required this.title,
    required this.recheckBy,
    this.verifiedOn,
    this.region,
  });

  /// What family the item belongs to, such as `country`.
  final String kind;

  /// The stable identifier, for a country its ISO 3166-1 code.
  final String key;

  /// The display name, such as `Britain (UK)`.
  final String title;

  /// The last day the data is trusted without a re-check.
  final DateTime recheckBy;

  /// When the data was last verified, when known.
  final DateTime? verifiedOn;

  /// The region the item belongs to, when the data defines one.
  ///
  /// The country dataset has no regions yet, so every country reports
  /// without one and the reports come out grouped by country.
  final String? region;
}

/// The countries in [countries] as re-check items, in dataset order.
///
/// Countries without a `recheckBy` date have never been researched, so
/// nothing can be due for them and they are left out.
List<RecheckItem> countryRecheckItems(List<CountryInfo> countries) {
  final items = <RecheckItem>[];
  for (final country in countries) {
    final recheckBy = country.recheckBy;
    if (recheckBy != null) {
      items.add(
        RecheckItem(
          kind: 'country',
          key: country.code,
          title: country.name,
          verifiedOn: country.verifiedOn,
          recheckBy: recheckBy,
        ),
      );
    }
  }
  return UnmodifiableListView(items);
}

/// The rule-set caveats of [packs], as re-check items (task C2,
/// docs/tax-jurisdictions.md section 9.4).
///
/// One item per caveat per supported year, keyed
/// `<cc>/<startYear>/<caveat id>` and verified with its rule set, so the
/// weekly report joins them alongside the countries.
List<RecheckItem> ruleSetCaveatRecheckItems(Iterable<TaxRulePack> packs) {
  final items = <RecheckItem>[];
  for (final pack in packs) {
    for (final startYear in pack.supportedStartYears) {
      final ruleSet = pack.ruleSet(startYear);
      for (final caveat in ruleSet.caveats) {
        items.add(
          RecheckItem(
            kind: 'caveat',
            key: '${pack.jurisdiction.countryCode}/$startYear/${caveat.id}',
            title: caveat.text,
            verifiedOn: ruleSet.verifiedOn,
            recheckBy: caveat.recheckBy,
          ),
        );
      }
    }
  }
  return UnmodifiableListView(items);
}

/// One re-check that is due, and how far past its date the report's day is.
final class OverdueRecheck {
  const OverdueRecheck({required this.item, required this.overdueDays});

  /// The item that is due.
  final RecheckItem item;

  /// Days between the re-check date and the report's day. Zero on the
  /// boundary: data due exactly on the as-of day counts as overdue.
  final int overdueDays;
}

/// The freshness report for one as-of day.
final class FreshnessReport {
  const FreshnessReport({required this.asOf, required this.overdue});

  /// The civil day the report answers for.
  final DateTime asOf;

  /// The overdue items, most overdue first, ties broken by key.
  final List<OverdueRecheck> overdue;
}

/// Parses an `--as-of` value, strictly `YYYY-MM-DD`, as a UTC civil day.
///
/// Returns null for anything else, including dates that do not exist such
/// as `2027-02-30`.
DateTime? tryParseAsOfDate(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (match == null) {
    return null;
  }
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  final date = DateTime.utc(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  return date;
}

/// Today, as the UTC civil day the report defaults to.
DateTime todayAsCivilDate() {
  final now = DateTime.now().toUtc();
  return civilDate(now.year, now.month, now.day);
}

/// The items in [items] whose `recheckBy` falls on or before [asOf].
///
/// Both dates must be civil days ([civilDate] or [tryParseAsOfDate] produce
/// them), so the overdue count is an exact calendar-day difference. The
/// boundary counts: a re-check due on the as-of day is reported with zero
/// overdue days, because a date that has arrived is a date that is due.
FreshnessReport freshnessReport({
  required List<RecheckItem> items,
  required DateTime asOf,
}) {
  final overdue =
      [
        for (final item in items)
          if (!item.recheckBy.isAfter(asOf))
            OverdueRecheck(
              item: item,
              overdueDays: asOf.difference(item.recheckBy).inDays,
            ),
      ]..sort((a, b) {
        final byDate = a.item.recheckBy.compareTo(b.item.recheckBy);
        return byDate != 0 ? byDate : a.item.key.compareTo(b.item.key);
      });
  return FreshnessReport(asOf: asOf, overdue: UnmodifiableListView(overdue));
}

/// The human-readable report, grouped by region when the data defines them
/// and listed by country otherwise.
String formatFreshnessText(FreshnessReport report) {
  final buffer = StringBuffer();
  final asOf = civilDateString(report.asOf);
  final count = report.overdue.length;
  buffer
    ..writeln('Tax data re-checks as of $asOf: $count overdue')
    ..writeln();
  if (count == 0) {
    buffer.writeln('Nothing is due for a re-check.');
    return buffer.toString();
  }

  final grouped = report.overdue.any(
    (entry) => entry.item.region != null,
  );
  String? printedRegion;
  for (final entry in report.overdue) {
    if (grouped) {
      final region = entry.item.region;
      if (region != printedRegion) {
        buffer
          ..writeln(region ?? 'No region')
          ..writeln();
        printedRegion = region;
      }
    }
    final item = entry.item;
    final verified = item.verifiedOn == null
        ? 'never verified'
        : 'verified ${civilDateString(item.verifiedOn!)}';
    buffer.writeln(
      '${item.key}  ${item.title}  $verified; recheck due '
      '${civilDateString(item.recheckBy)}; ${entry.overdueDays} '
      '${entry.overdueDays == 1 ? 'day' : 'days'} overdue',
    );
  }
  return buffer.toString();
}

/// The machine-readable report the freshness workflow consumes.
String formatFreshnessJson(FreshnessReport report) =>
    const JsonEncoder.withIndent('  ').convert({
      'asOf': civilDateString(report.asOf),
      'overdueCount': report.overdue.length,
      'overdue': [
        for (final entry in report.overdue)
          {
            'kind': entry.item.kind,
            'key': entry.item.key,
            'title': entry.item.title,
            'region': entry.item.region,
            'verifiedOn': entry.item.verifiedOn == null
                ? null
                : civilDateString(entry.item.verifiedOn!),
            'recheckBy': civilDateString(entry.item.recheckBy),
            'overdueDays': entry.overdueDays,
          },
      ],
    });

/// The `YYYY-MM-DD` spelling of a civil day.
String civilDateString(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
