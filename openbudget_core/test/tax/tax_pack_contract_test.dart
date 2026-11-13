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

        test('every caveat has a unique id, a grade and a recheck date', () {
          final recheckById = <String, DateTime>{};
          for (final startYear in pack.supportedStartYears) {
            final ruleSet = pack.ruleSet(startYear);
            expect(ruleSet.caveats, isNotEmpty, reason: '$startYear');
            final idsThisYear = <String>{};
            for (final caveat in ruleSet.caveats) {
              final reason =
                  '${jurisdiction.countryCode} ${caveat.id} $startYear';
              expect(
                caveat.id,
                startsWith('${jurisdiction.countryCode.toLowerCase()}.'),
                reason: 'caveat ids carry the country prefix ($reason)',
              );
              expect(
                idsThisYear.add(caveat.id),
                isTrue,
                reason: '$reason is unique in its year',
              );
              expect(caveat.text, isNotEmpty, reason: reason);
              expect(
                caveat.recheckBy.isAfter(ruleSet.verifiedOn),
                isTrue,
                reason: '$reason recheckBy follows verifiedOn',
              );
              expect(
                caveat.sections.isNotEmpty || caveat.keys.isNotEmpty,
                isTrue,
                reason: '$reason touches something',
              );
              // The same caveat shared across years keeps its recheck date.
              final known = recheckById[caveat.id];
              if (known != null) {
                expect(known, caveat.recheckBy, reason: caveat.id);
              } else {
                recheckById[caveat.id] = caveat.recheckBy;
              }
            }
          }
        });

        test('every named figure is complete and unique in its year', () {
          final ids = <String>{};
          for (final startYear in pack.supportedStartYears) {
            final ruleSet = pack.ruleSet(startYear);
            expect(ruleSet.figures, isNotEmpty, reason: '$startYear');
            for (final figure in ruleSet.figures.values) {
              final reason =
                  '${jurisdiction.countryCode} ${figure.id} $startYear';
              expect(
                ids.add('${figure.id}_$startYear'),
                isTrue,
                reason: '$reason is unique',
              );
              expect(figure.value, greaterThanOrEqualTo(0), reason: reason);
              expect(figure.source, isNotNull, reason: reason);
              expect(figure.grade, isNotNull, reason: reason);
              expect(
                figure.verifiedOn,
                ruleSet.verifiedOn,
                reason: '$reason was checked with the rule set',
              );
            }
          }
        });

        test('every report line that names a figure the rule set carries', () {
          for (final startYear in pack.supportedStartYears) {
            final figures = pack.ruleSet(startYear).figures;
            for (final kind in EntityKind.values) {
              final report = pack.report(
                TaxInput(
                  profile: _profileFor(jurisdiction, kind),
                  year: pack.taxYear(startYear),
                  entries: const [],
                ),
              );
              for (final line in report.lines) {
                final figureId = line.figureId;
                if (figureId == null) continue;
                expect(
                  figures.containsKey(figureId),
                  isTrue,
                  reason:
                      '$figureId on a ${kind.name} $startYear line must be a '
                      'figure of that year',
                );
              }
            }
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

        test('decodes its own profiles through profileFromJson', () {
          for (final kind in EntityKind.values) {
            final json = {
              'jurisdiction': jurisdiction.countryCode,
              'entityKind': kind.name,
            };
            final fromPack = pack.profileFromJson(json);
            final fromProfile = TaxProfile.fromJson(json);
            expect(fromPack.runtimeType, fromProfile.runtimeType);
            expect(fromPack.toJson(), fromProfile.toJson());
            expect(
              () => pack.profileFromJson({
                'jurisdiction': jurisdiction.countryCode,
                'entityKind': 'partnership',
              }),
              throwsFormatException,
              reason: '${kind.name}: a bad entity kind is invalid input',
            );
          }
        });

        test('asks profile questions for every kind', () {
          for (final kind in EntityKind.values) {
            final questions = pack.profileQuestions(kind);
            expect(questions, isNotEmpty, reason: kind.name);
            final keys = [for (final question in questions) question.key];
            expect(keys, contains('entityKind'), reason: kind.name);
            expect(keys, contains('salesTaxRegistered'), reason: kind.name);
            expect(keys, contains('taxResident'), reason: kind.name);
            expect(keys, contains('usPerson'), reason: kind.name);
          }
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
              // Every report touches at least one section with caveats, so
              // a report with none means the pack forgot to wire them.
              expect(report.caveats, isNotEmpty, reason: reason);
              expect(
                report.caveats.toSet().difference(ruleSet.caveats.toSet()),
                isEmpty,
                reason: "$reason carries only its rule set's caveats",
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
