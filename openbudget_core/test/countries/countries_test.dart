import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

/// The verbatim IANA tables the bootstrap committed as fixtures.
final File iso3166Tab = File('data/iso3166.tab');
final File zoneTab = File('data/zone.tab');
final File timezoneDefaults = File('data/timezone_defaults.json');
final File servableExclusions = File('data/servable_exclusions.json');

/// ISO codes with no economy, so no current currency exists in CLDR.
const noCurrencyCodes = {'AQ'};

/// ISO codes IANA tz zone.tab assigns no zone to.
const noZoneCodes = {'BV', 'HM'};

void main() {
  final isoNames = _parseIso3166Tab(iso3166Tab.readAsStringSync());
  final zoneZones = _parseZoneTab(zoneTab.readAsStringSync());
  final dataset = {
    for (final country in Countries.all) country.code: country,
  };

  group('country coverage', () {
    test('every ISO 3166-1 code in iso3166.tab has a data file', () {
      for (final code in isoNames.keys) {
        expect(
          File('data/countries/$code.json').existsSync(),
          isTrue,
          reason: 'missing data/countries/$code.json',
        );
      }
    });

    test('the dataset holds exactly the ISO codes, in code order', () {
      expect(dataset.keys.toList(), equals(isoNames.keys.toList()..sort()));
    });
  });

  group('country file schema', () {
    test('every file parses and round-trips to its exact content', () {
      for (final code in isoNames.keys) {
        final text = File('data/countries/$code.json').readAsStringSync();
        final json = jsonDecode(text) as Map<String, Object?>;
        final country = CountryInfo.fromJson(json);

        // The generator inlines this exact shape, so any drift between the
        // file and the parsed model fails here first.
        expect(
          jsonEncode(country.toJsonObject()),
          jsonEncode(json),
          reason: '$code.json is not in the canonical schema shape',
        );
        expect(country.name, isoNames[code], reason: code);
      }
    });

    test('only no-economy territories carry no currency', () {
      final empty = [
        for (final country in dataset.values)
          if (country.currencies.isEmpty) country.code,
      ];
      expect(empty, noCurrencyCodes.toList()..sort());
    });

    test('only territories outside zone.tab carry no zone', () {
      final empty = [
        for (final country in dataset.values)
          if (country.timeZones.isEmpty) country.code,
      ];
      expect(empty, noZoneCodes.toList()..sort());
    });

    test('every zone belongs to its own country in zone.tab', () {
      for (final country in dataset.values) {
        final allowed = zoneZones[country.code] ?? const <String>[];
        final unknown = country.timeZones.toSet()..removeAll(allowed);
        expect(unknown, isEmpty, reason: '${country.code} zone.tab zones');
      }
    });

    test('every source index points into the file sources', () {
      for (final country in dataset.values) {
        final indirect = country.indirectTax;
        if (indirect == null) {
          continue;
        }
        final limit = country.sources.length;
        for (final rate in indirect.rates) {
          expect(rate.source, lessThan(limit), reason: country.code);
        }
      }
    });
  });

  group('hand-kept time-zone defaults', () {
    final overrides =
        (jsonDecode(timezoneDefaults.readAsStringSync())
                as Map<String, Object?>)['countries']!
            as Map<String, Object?>;

    test('every multi-zone country has a hand-kept default', () {
      final multiZone = [
        for (final entry in zoneZones.entries)
          if (entry.value.length > 1) entry.key,
      ]..sort();
      expect(overrides.keys.toList()..sort(), equals(multiZone));
    });

    test('defaults move the chosen zone to the front', () {
      for (final country in dataset.values) {
        final override = overrides[country.code] as Map<String, Object?>?;
        if (override == null) {
          continue;
        }
        final curated = override['timeZones'] as List<Object?>?;
        if (curated != null) {
          expect(
            country.timeZones,
            curated.cast<String>(),
            reason: '${country.code} must use the curated list verbatim',
          );
          continue;
        }
        final wanted = override['default']! as String;
        expect(country.timeZones.first, wanted, reason: country.code);
        expect(
          country.timeZones.sublist(1).contains(wanted),
          isFalse,
          reason: '${country.code} lists $wanted twice',
        );
        final rest = zoneZones[country.code]!
            .where((zone) => zone != wanted)
            .toList();
        expect(
          country.timeZones.sublist(1),
          rest,
          reason: '${country.code} must keep the zone.tab order',
        );
      }
    });

    test('single-zone countries never carry an override', () {
      final singles = [
        for (final entry in zoneZones.entries)
          if (entry.value.length == 1) entry.key,
      ];
      for (final code in singles) {
        expect(overrides.containsKey(code), isFalse, reason: code);
      }
    });
  });

  group('servable placeholder', () {
    final exclusions =
        (jsonDecode(servableExclusions.readAsStringSync())
                as Map<String, Object?>)['excluded']!
            as List<Object?>;
    final excludedByCode = {
      for (final entry in exclusions)
        (entry! as Map<String, Object?>)['code']! as String: entry,
    };

    test('the exclusion list matches the servable flags', () {
      final hidden = [
        for (final country in dataset.values)
          if (!country.servable) country.code,
      ]..sort();
      expect(excludedByCode.keys.toList()..sort(), equals(hidden));
    });

    test('hidden countries say why on screen', () {
      for (final country in dataset.values) {
        if (!country.servable) {
          expect(country.caveats, isNotEmpty, reason: country.code);
          expect(
            country.caveats.join(' '),
            contains('Q1'),
            reason: country.code,
          );
        }
      }
    });

    test('the flagship countries stay servable', () {
      for (final code in ['GB', 'US', 'NG', 'DE']) {
        expect(dataset[code]!.servable, isTrue, reason: code);
      }
    });
  });

  group('Countries.byCode', () {
    test("resolves the flagship countries to today's reference facts", () {
      final gb = Countries.byCode('GB');
      expect(gb!.name, isoNames['GB']);
      expect(gb.currencies, ['GBP']);
      expect(gb.timeZones, ['Europe/London']);
      // Filled by the U3 research pass: HMRC's tax year (6 April) and VAT
      // rates (20% standard since 4 January 2011), preserving the app's
      // 31 March company year-end default.
      expect(gb.individualTaxYear!.startMonth, 4);
      expect(gb.individualTaxYear!.startDay, 6);
      expect(gb.companyYearEndDefault, (month: 3, day: 31));
      expect(gb.indirectTax!.kind, IndirectTaxKind.vat);
      expect(gb.indirectTax!.rates.first.basisPoints, 2000);
      expect(gb.authority!.name, 'HM Revenue & Customs (HMRC)');

      expect(Countries.byCode('US')!.currencies, ['USD']);
      expect(Countries.byCode('NG')!.timeZones, ['Africa/Lagos']);
      expect(Countries.byCode('DE')!.defaultCurrency, 'EUR');
    });

    test('is case-insensitive', () {
      expect(Countries.byCode('gb')!.code, 'GB');
      expect(Countries.byCode('ng'), same(Countries.byCode('NG')));
    });

    test('returns null for unknown codes', () {
      expect(Countries.byCode('ZZ'), isNull);
      expect(Countries.byCode(''), isNull);
      expect(Countries.byCode('GBR'), isNull);
      expect(Countries.byCode('1G'), isNull);
    });
  });
}

/// `code → English name`, verbatim from `iso3166.tab`.
Map<String, String> _parseIso3166Tab(String text) => {
  for (final line in text.split('\n'))
    if (line.isNotEmpty && !line.startsWith('#'))
      line.split('\t')[0]: line.split('\t')[1],
};

/// `code → zones in file order`, from `zone.tab`.
Map<String, List<String>> _parseZoneTab(String text) {
  final zones = <String, List<String>>{};
  for (final line in text.split('\n')) {
    if (line.isEmpty || line.startsWith('#')) {
      continue;
    }
    zones.putIfAbsent(line.split('\t')[0], () => []).add(line.split('\t')[2]);
  }
  return zones;
}
