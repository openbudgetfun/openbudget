import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

/// A country fixture with the given re-check dates.
CountryInfo country(
  String code,
  String name, {
  DateTime? verifiedOn,
  DateTime? recheckBy,
}) => CountryInfo(
  code: code,
  name: name,
  servable: true,
  currencies: const ['XXX'],
  timeZones: const ['UTC'],
  verifiedOn: verifiedOn,
  recheckBy: recheckBy,
);

/// A re-check item fixture due on the given day.
RecheckItem item(
  String key,
  DateTime recheckBy, {
  String kind = 'country',
  String title = 'Fixture',
  DateTime? verifiedOn,
  String? region,
}) => RecheckItem(
  kind: kind,
  key: key,
  title: title,
  verifiedOn: verifiedOn,
  region: region,
  recheckBy: recheckBy,
);

void main() {
  final asOf = civilDate(2027, 6, 1);

  group('tryParseAsOfDate', () {
    test('parses a strict YYYY-MM-DD value as a UTC civil day', () {
      expect(tryParseAsOfDate('2027-06-01'), civilDate(2027, 6, 1));
      final parsed = tryParseAsOfDate('2026-02-14');
      expect(parsed, isNotNull);
      expect(parsed!.isUtc, isTrue);
      expect(parsed.hour, 0);
      expect(parsed.minute, 0);
    });

    test('returns null for loose spellings and impossible dates', () {
      const bad = <String>[
        '',
        '2027-6-01',
        '2027-06-1',
        '2027/06/01',
        '01-06-2027',
        'not-a-date',
        '2027-13-01',
        '2027-00-10',
        '2027-02-30',
      ];
      for (final value in bad) {
        expect(tryParseAsOfDate(value), isNull, reason: value);
      }
    });
  });

  group('countryRecheckItems', () {
    test('maps a researched country onto a country item', () {
      final items = countryRecheckItems([
        country(
          'GB',
          'Britain (UK)',
          verifiedOn: civilDate(2026, 11, 13),
          recheckBy: civilDate(2027, 5, 13),
        ),
      ]);
      expect(items, hasLength(1));
      expect(items.single.kind, 'country');
      expect(items.single.key, 'GB');
      expect(items.single.title, 'Britain (UK)');
      expect(items.single.verifiedOn, civilDate(2026, 11, 13));
      expect(items.single.recheckBy, civilDate(2027, 5, 13));
    });

    test('ignores countries with no recheckBy date', () {
      final items = countryRecheckItems([
        country('US', 'United States', recheckBy: civilDate(2027, 1, 1)),
        country('AQ', 'Antarctica'),
        country('XX', 'Unresearched Republic'),
      ]);
      expect(items.map((entry) => entry.key), ['US']);
    });
  });

  group('freshnessReport', () {
    test('reports a past date with the exact overdue day count', () {
      final report = freshnessReport(
        items: [item('GB', civilDate(2027, 5, 13))],
        asOf: asOf,
      );
      expect(report.overdue.single.item.key, 'GB');
      expect(report.overdue.single.overdueDays, 19);
    });

    test('the boundary counts: due on the as-of day is overdue at zero', () {
      final report = freshnessReport(
        items: [item('GB', asOf)],
        asOf: asOf,
      );
      expect(report.overdue, hasLength(1));
      expect(report.overdue.single.overdueDays, 0);
    });

    test('a future date is not reported', () {
      final report = freshnessReport(
        items: [
          item('GB', civilDate(2027, 6, 2)),
          item('US', civilDate(2028, 1, 1)),
        ],
        asOf: asOf,
      );
      expect(report.overdue, isEmpty);
    });

    test('one day past the boundary reports a single day', () {
      final report = freshnessReport(
        items: [item('GB', civilDate(2027, 5, 31))],
        asOf: asOf,
      );
      expect(report.overdue.single.overdueDays, 1);
    });

    test('lists most overdue first and breaks ties by key', () {
      final report = freshnessReport(
        items: [
          item('US', civilDate(2027, 1, 15)),
          item('NG', civilDate(2026, 12, 15)),
          item('GB', civilDate(2027, 1, 15)),
          item('DE', civilDate(2027, 2, 13)),
        ],
        asOf: asOf,
      );
      expect(
        report.overdue.map((entry) => entry.item.key).toList(),
        ['NG', 'GB', 'US', 'DE'],
      );
      expect(report.overdue.map((entry) => entry.overdueDays).toList(), [
        168,
        137,
        137,
        108,
      ]);
    });
  });

  group('formatFreshnessText', () {
    test('lists key, name, verified date and overdue days', () {
      final text = formatFreshnessText(
        freshnessReport(
          items: [
            item(
              'GB',
              civilDate(2027, 5, 13),
              title: 'Britain (UK)',
              verifiedOn: civilDate(2026, 11, 13),
            ),
          ],
          asOf: asOf,
        ),
      );
      expect(text, contains('Tax data re-checks as of 2027-06-01: 1 overdue'));
      expect(text, contains('GB  Britain (UK)  verified 2026-11-13;'));
      expect(text, contains('recheck due 2027-05-13; 19 days overdue'));
    });

    test('says a country never verified is never verified', () {
      final text = formatFreshnessText(
        freshnessReport(items: [item('GB', asOf)], asOf: asOf),
      );
      expect(text, contains('GB  Fixture  never verified;'));
      expect(text, contains('0 days overdue'));
    });

    test('an empty report says nothing is due', () {
      final text = formatFreshnessText(
        freshnessReport(items: [item('GB', civilDate(2028, 1, 1))], asOf: asOf),
      );
      expect(text, contains('Tax data re-checks as of 2027-06-01: 0 overdue'));
      expect(text, contains('Nothing is due for a re-check.'));
    });

    test('groups by region when items carry one', () {
      final text = formatFreshnessText(
        freshnessReport(
          items: [
            item('GB', civilDate(2027, 5, 13), region: 'Europe'),
            item('NG', civilDate(2027, 5, 13), region: 'Africa'),
          ],
          asOf: asOf,
        ),
      );
      final africa = text.indexOf('Africa');
      final europe = text.indexOf('Europe');
      expect(africa, isNot(-1));
      expect(europe, isNot(-1));
      // Within each region the report order is preserved.
      expect(text.indexOf('NG'), greaterThan(africa));
      expect(text.indexOf('GB'), greaterThan(europe));
    });

    test('does not print region headers when no item carries one', () {
      final text = formatFreshnessText(
        freshnessReport(items: [item('GB', asOf)], asOf: asOf),
      );
      expect(text, isNot(contains('Europe')));
      expect(text, isNot(contains('No region')));
    });
  });

  group('formatFreshnessJson', () {
    test('decodes to the documented shape', () {
      final json = jsonDecode(
        formatFreshnessJson(
          freshnessReport(
            items: [
              item(
                'GB',
                civilDate(2027, 5, 13),
                title: 'Britain (UK)',
                verifiedOn: civilDate(2026, 11, 13),
              ),
              item('AQ', civilDate(2027, 6, 1), title: 'Antarctica'),
            ],
            asOf: asOf,
          ),
        ),
      ) as Map<String, Object?>;

      expect(json['asOf'], '2027-06-01');
      expect(json['overdueCount'], 2);
      final overdue = json['overdue']! as List<Object?>;
      expect(overdue, hasLength(2));

      final gb = overdue.first! as Map<String, Object?>;
      expect(gb, {
        'kind': 'country',
        'key': 'GB',
        'title': 'Britain (UK)',
        'region': null,
        'verifiedOn': '2026-11-13',
        'recheckBy': '2027-05-13',
        'overdueDays': 19,
      });

      // The boundary item keeps its zero-day count as a number.
      final aq = overdue.last! as Map<String, Object?>;
      expect(aq['overdueDays'], 0);
      expect(aq['verifiedOn'], null);
    });

    test('keeps the same order as the report', () {
      final json = jsonDecode(
        formatFreshnessJson(
          freshnessReport(
            items: [
              item('NG', civilDate(2026, 12, 15)),
              item('US', civilDate(2027, 1, 15)),
            ],
            asOf: asOf,
          ),
        ),
      ) as Map<String, Object?>;
      final overdue = json['overdue']! as List<Object?>;
      expect(
        overdue.map((entry) => (entry! as Map<String, Object?>)['key']),
        ['NG', 'US'],
      );
    });
  });

  group('ruleSetCaveatRecheckItems', () {
    final packs = TaxJurisdiction.values.map(TaxRules.forJurisdiction);

    test('maps every caveat of every year onto a caveat item', () {
      final items = ruleSetCaveatRecheckItems(packs);
      expect(items, isNotEmpty);
      var expected = 0;
      for (final pack in packs) {
        for (final startYear in pack.supportedStartYears) {
          expected += pack.ruleSet(startYear).caveats.length;
        }
      }
      expect(items, hasLength(expected));
      for (final item in items) {
        expect(item.kind, 'caveat');
        expect(item.title, isNotEmpty);
        expect(item.verifiedOn, isNotNull);
        expect(item.key, matches(RegExp(r'^[A-Z]{2}/\d{4}/[a-z]{2}\..+$')));
      }
      // Keys are unique: one item per caveat per year.
      expect(items.map((item) => item.key).toSet(), hasLength(items.length));
    });

    test('an overdue caveat is reported given an as-of past its recheckBy', () {
      final items = [
        ...countryRecheckItems(Countries.all),
        ...ruleSetCaveatRecheckItems(packs),
      ];
      // The GB company caveats are due 1 December 2026; a June 2027 report
      // must carry them.
      final report = freshnessReport(items: items, asOf: asOf);
      final overdueCaveats = report.overdue
          .where((entry) => entry.item.kind == 'caveat')
          .map((entry) => entry.item.key)
          .toList();
      expect(
        overdueCaveats,
        containsAll([
          for (final item in items)
            if (item.kind == 'caveat' &&
                item.recheckBy.isBefore(DateTime.utc(2026, 12, 2)) &&
                item.key.startsWith('GB/'))
              item.key,
        ]),
      );
      expect(
        report.overdue
            .where((entry) => entry.item.kind == 'country')
            .isNotEmpty,
        isTrue,
        reason: 'countries still share the same report',
      );
    });

    test('no caveat is due before the pack was verified', () {
      for (final item in ruleSetCaveatRecheckItems(packs)) {
        expect(
          item.recheckBy.isAfter(item.verifiedOn!),
          isTrue,
          reason: item.key,
        );
      }
    });
  });

  group('the real dataset', () {
    test('reports exactly the items due by the as-of day', () {
      // A report over all of `Countries.all` must contain exactly the
      // researched countries whose recheckBy date has arrived, and be
      // renderable both ways.
      final items = countryRecheckItems(Countries.all);
      final asOf = civilDate(2027, 6, 1);
      final expected = items
          .where((entry) => !entry.recheckBy.isAfter(asOf))
          .length;
      expect(items.length, greaterThan(0));
      expect(expected, greaterThan(0));
      expect(expected, lessThan(items.length));
      final report = freshnessReport(items: items, asOf: asOf);
      expect(report.overdue, hasLength(expected));
      expect(formatFreshnessText(report), isNotEmpty);
      expect(
        (jsonDecode(formatFreshnessJson(report))
            as Map<String, Object?>)['overdueCount'],
        expected,
      );
    });
  });
}
