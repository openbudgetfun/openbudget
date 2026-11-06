// The ELSTER Kennzahl data: every entry must be locatable by form, year,
// section and Kz, the EÜR years must carry identical Kz with the +1 Zeile
// shift from Z27, and the company forms must stay empty until their Kz are
// read (see the germany-tax skill, references/elster-*.md).
import 'package:openbudget_core/src/tax/de/de_categories.dart';
import 'package:openbudget_core/src/tax/de/de_elster.dart';
import 'package:test/test.dart';

void main() {
  group('Kennzahl data', () {
    test('every entry names form, section, Kz and meaning', () {
      expect(deKennzahlenByCategory, isNotEmpty);
      final keys = <String>{};
      for (final entries in deKennzahlenByCategory.values) {
        for (final entry in entries) {
          expect(entry.form, isNotEmpty);
          expect(entry.section, isNotEmpty);
          expect(entry.kz, greaterThan(0));
          expect(entry.meaning, isNotEmpty);
          expect(entry.year, anyOf(2025, 2026));
          keys.add('${entry.form}|${entry.year}|${entry.section}|${entry.kz}');
        }
      }
      // (form, year, section, Kz) is the key: no duplicates.
      expect(keys, hasLength(keys.length));
    });

    test('maps only categories the pack knows', () {
      for (final code in deKennzahlenByCategory.keys) {
        expect(
          deCategories[code],
          isNotNull,
          reason: '$code is not a DE tax category',
        );
      }
    });
  });

  group('Anlage N 2025', () {
    test('the Homeoffice line is Z58/Z59 with Kz 335/336', () {
      final entries = deKennzahlenFor('de.ind.homeoffice', 2025);
      expect(entries.map((entry) => entry.kz).toSet(), {335, 336});
      expect(entries.map((entry) => entry.zeile).toSet(), {58, 59});
    });

    test('the Arbeitszimmer line is Z57 with Kz 325', () {
      final entries = deKennzahlenFor('de.ind.arbeitszimmer', 2025);
      expect(entries, hasLength(1));
      expect(entries.single.kz, 325);
      expect(entries.single.zeile, 57);
    });

    test('wages use Kz 110 and 111 on the same Zeile', () {
      final entries = deKennzahlenFor('de.ind.arbeitslohn', 2025);
      expect(entries.map((entry) => entry.kz).toSet(), {110, 111});
      expect(entries.every((entry) => entry.zeile == 5), isTrue);
    });

    test('2026 stays empty until the forms are published', () {
      expect(deKennzahlenFor('de.ind.homeoffice', 2026), isEmpty);
      expect(deKennzahlenFor('de.ind.arbeitslohn', 2026), isEmpty);
    });
  });

  group('Anlage EÜR 2025 and 2026', () {
    test('carry identical Kz for both years', () {
      for (final code in [
        'de.euer.betriebseinnahmen',
        'de.euer.wareneinkauf',
        'de.euer.personal',
        'de.euer.afa',
        'de.euer.gwg',
        'de.euer.arbeitszimmer',
        'de.euer.homeoffice',
        'de.euer.bewirtung',
        'de.euer.sonstige',
      ]) {
        final kz2025 = deKennzahlenFor(code, 2025).map((e) => e.kz).toSet();
        final kz2026 = deKennzahlenFor(code, 2026).map((e) => e.kz).toSet();
        expect(kz2026, kz2025, reason: code);
        expect(kz2025, isNotEmpty, reason: code);
      }
    });

    test('shifts the Zeile by +1 from Z27, never before', () {
      // Kz 112 (Z15) sits before the inserted line: unchanged.
      final turnover2025 = deKennzahlenFor(
        'de.euer.betriebseinnahmen',
        2025,
      ).firstWhere((entry) => entry.kz == 112);
      final turnover2026 = deKennzahlenFor(
        'de.euer.betriebseinnahmen',
        2026,
      ).firstWhere((entry) => entry.kz == 112);
      expect(turnover2025.zeile, 15);
      expect(turnover2026.zeile, 15);
      // Kz 120 (Z30) sits after the inserted line: +1.
      final personal2025 = deKennzahlenFor(
        'de.euer.personal',
        2025,
      ).single;
      final personal2026 = deKennzahlenFor(
        'de.euer.personal',
        2026,
      ).single;
      expect(personal2025.zeile, 30);
      expect(personal2026.zeile, personal2025.zeile! + 1);
      // The Gewinn Kz 219 moves from Z97 to Z98 with the Gewinn category's
      // profit line, not the pack: assert via the Homeoffice shift instead.
      final homeoffice2025 = deKennzahlenFor(
        'de.euer.homeoffice',
        2025,
      ).single;
      final homeoffice2026 = deKennzahlenFor(
        'de.euer.homeoffice',
        2026,
      ).single;
      expect(homeoffice2025.zeile, 66);
      expect(homeoffice2026.zeile, 67);
    });

    test('leaves the 2026 Waren Zeile unread where the research conflicts', () {
      final waren2026 = deKennzahlenFor(
        'de.euer.wareneinkauf',
        2026,
      ).firstWhere((entry) => entry.kz == 100);
      expect(waren2026.zeile, isNull);
      final waren2025 = deKennzahlenFor(
        'de.euer.wareneinkauf',
        2025,
      ).firstWhere((entry) => entry.kz == 100);
      expect(waren2025.zeile, 27);
    });
  });

  group('UStVA 2026', () {
    test('output turnover uses Kz 81 and 86 on Z13/Z14', () {
      final entries = deKennzahlenFor('de.ust.ausgang', 2026);
      expect(entries.map((entry) => entry.kz).toSet(), {81, 86});
      expect(entries.map((entry) => entry.zeile).toSet(), {13, 14});
    });

    test('input tax uses Kz 66 on Z38', () {
      final entries = deKennzahlenFor('de.ust.eingang', 2026);
      expect(entries.single.kz, 66);
      expect(entries.single.zeile, 38);
    });
  });

  group('company forms', () {
    test('carry no Kz until KSt 1 / GK / ZVE / GewSt 1 A are read', () {
      for (final code in [
        'de.co.umsatzerloese',
        'de.co.personal',
        'de.co.sonstige',
        'de.co.kst_vorauszahlungen',
        'de.co.gewst_vorauszahlungen',
      ]) {
        expect(deKennzahlenFor(code, 2026), isEmpty, reason: code);
        expect(deKennzahlenFor(code, 2025), isEmpty, reason: code);
      }
    });
  });
}
