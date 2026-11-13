import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

final RegExp _versionPattern = RegExp(r'^[a-z]{2}-\d{4}-r\d+$');

TaxProfile _profileFor(TaxJurisdiction jurisdiction, EntityKind kind) =>
    TaxProfile.fromJson({
      'jurisdiction': jurisdiction.countryCode,
      'entityKind': kind.name,
    });

void main() {
  group('the rule-pack contract', () {
    for (final jurisdiction in TaxJurisdiction.values) {
      group(jurisdiction.countryCode, () {
        final pack = TaxRules.forJurisdiction(jurisdiction);

        test('resolves to the matching pack', () {
          expect(pack.jurisdiction, jurisdiction);
        });

        test('declares coverage for every section', () {
          expect(
            pack.manifest.sections.keys.toSet(),
            TaxSection.values.toSet(),
          );
          for (final section in TaxSection.values) {
            expect(
              pack.manifest.coverageOf(section),
              pack.manifest.sections[section],
              reason: section.name,
            );
          }
        });

        test('supports the years its rule sets cover', () {
          expect(pack.supportedStartYears, isNotEmpty);
          for (final startYear in pack.supportedStartYears) {
            final ruleSet = pack.ruleSet(startYear);
            expect(ruleSet.startYear, startYear);
            expect(ruleSet.revision, greaterThan(0));
            expect(ruleSet.sources, isNotEmpty);
            expect(
              ruleSet.verifiedOn.isBefore(DateTime.now().toUtc()),
              isTrue,
              reason: 'verifiedOn must not be in the future',
            );
            expect(
              ruleSet.versionFor(jurisdiction),
              matches(_versionPattern),
            );
          }
        });

        test('versions are unique per supported year', () {
          final versions = {
            for (final startYear in pack.supportedStartYears)
              pack.ruleSet(startYear).versionFor(jurisdiction),
          };
          expect(versions, hasLength(pack.supportedStartYears.length));
        });

        test('rejects a year it does not know', () {
          expect(
            () => pack.ruleSet(1999),
            throwsA(isA<UnsupportedTaxYearException>()),
          );
        });

        test('every report carries its version, maturity and coverage', () {
          for (final startYear in pack.supportedStartYears) {
            final year = pack.taxYear(startYear);
            final ruleSet = pack.ruleSet(startYear);
            for (final kind in EntityKind.values) {
              final report = pack.report(
                TaxInput(
                  profile: _profileFor(jurisdiction, kind),
                  year: year,
                  entries: const [],
                ),
              );
              final reason = '${kind.name} $startYear';
              expect(
                report.rulesVersion,
                ruleSet.versionFor(jurisdiction),
                reason: reason,
              );
              expect(report.rulesVersion, matches(_versionPattern));
              expect(
                report.rulesVersion,
                startsWith(
                  '${jurisdiction.countryCode.toLowerCase()}-$startYear-',
                ),
              );
              expect(report.maturity, pack.manifest.maturity, reason: reason);
              expect(report.coverage, pack.manifest.sections, reason: reason);
              expect(report.sources, isNotEmpty, reason: reason);
              expect(
                report.rulesVerifiedOn,
                ruleSet.verifiedOn,
                reason: reason,
              );
            }
          }
        });
      });
    }

    test('the four shipped packs are preview until a professional reviews '
        'them', () {
      for (final jurisdiction in TaxJurisdiction.values) {
        expect(
          TaxRules.forJurisdiction(jurisdiction).manifest.maturity,
          TaxPackMaturity.preview,
          reason: jurisdiction.countryCode,
        );
      }
    });

    test('every applicable universal code maps or is declared unmapped', () {
      for (final jurisdiction in TaxJurisdiction.values) {
        final pack = TaxRules.forJurisdiction(jurisdiction);
        for (final kind in EntityKind.values) {
          for (final universal in UniversalTaxCategories.categoriesFor(kind)) {
            final mapped = pack.mapUniversalCategory(universal.code, kind);
            if (mapped == null) continue; // deliberately unmapped.

            final category = pack.category(mapped);
            final reason =
                '${jurisdiction.countryCode} '
                '${universal.code} → $mapped (${kind.name})';
            expect(category, isNotNull, reason: reason);
            expect(
              category!.entityKinds.contains(kind),
              isTrue,
              reason: reason,
            );
            expect(
              category.kind,
              universal.kind,
              reason:
                  'a universal entry of one kind must not land in '
                  'another ($reason)',
            );
          }
        }
      }
    });

    test('a non-universal code never maps through the universal path', () {
      for (final jurisdiction in TaxJurisdiction.values) {
        final pack = TaxRules.forJurisdiction(jurisdiction);
        for (final kind in EntityKind.values) {
          for (final category in pack.categoriesFor(kind)) {
            expect(
              pack.mapUniversalCategory(category.code, kind),
              isNull,
              reason: '${category.code} is not a universal code',
            );
          }
        }
      }
    });

    test('mappings count per pack, for the release notes', () {
      final counts = <String, String>{};
      for (final jurisdiction in TaxJurisdiction.values) {
        var mapped = 0;
        var unmapped = 0;
        final pack = TaxRules.forJurisdiction(jurisdiction);
        for (final kind in EntityKind.values) {
          for (final universal in UniversalTaxCategories.categoriesFor(kind)) {
            if (pack.mapUniversalCategory(universal.code, kind) == null) {
              unmapped++;
            } else {
              mapped++;
            }
          }
        }
        counts[jurisdiction.countryCode] = '$mapped mapped, $unmapped unmapped';
      }
      // Every pack must map at least the income and out-of-scope basics,
      // and every pack must leave genuinely unplaceable codes unmapped.
      for (final entry in counts.entries) {
        expect(
          int.parse(entry.value.split(' ')[0]),
          greaterThan(0),
          reason: entry.key,
        );
        expect(
          int.parse(entry.value.split(' ')[2]),
          greaterThan(0),
          reason: entry.key,
        );
      }
    });
  });
}
