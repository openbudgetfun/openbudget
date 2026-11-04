import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  group('applyTaxBands', () {
    const bands = [
      TaxBand(label: 'Basic', rateBasisPoints: 2000, ceilingMinor: 100000),
      TaxBand(label: 'Higher', rateBasisPoints: 4000, ceilingMinor: 300000),
      TaxBand(label: 'Top', rateBasisPoints: 4500),
    ];

    test('splits a base across bands', () {
      final slices = applyTaxBands(350000, bands);
      expect(slices.map((slice) => slice.baseMinor), [100000, 200000, 50000]);
      expect(sumBandTax(slices), 20000 + 80000 + 22500);
    });

    test('stops inside the first band', () {
      final slices = applyTaxBands(5000, bands);
      expect(slices, hasLength(1));
      expect(slices.single.taxMinor, 1000);
    });

    test('starts higher up when income is already stacked below', () {
      final slices = applyTaxBands(50000, bands, startMinor: 80000);
      expect(slices.map((slice) => slice.label), ['Basic', 'Higher']);
      expect(slices.map((slice) => slice.baseMinor), [20000, 30000]);
    });

    test('skips bands already filled', () {
      final slices = applyTaxBands(10000, bands, startMinor: 320000);
      expect(slices.single.label, 'Top');
    });

    test('nothing to tax gives no slices', () {
      expect(applyTaxBands(0, bands), isEmpty);
    });

    test('rounds each slice down', () {
      final slices = applyTaxBands(3, const [
        TaxBand(label: 'Rate', rateBasisPoints: 3333),
      ]);
      expect(slices.single.taxMinor, 0);
    });
  });

  group('TaxEntry', () {
    test('allowable amount excludes sales tax and private use', () {
      final entry = TaxEntry(
        date: DateTime.utc(2026, 5),
        amountMinor: 12000,
        salesTaxMinor: 2000,
        businessUsePercent: 50,
        categoryCode: 'gb.se.phone',
      );
      expect(entry.allowableMinor, 5000);
    });
  });

  group('TaxYear', () {
    final year = TaxYear(
      jurisdiction: TaxJurisdiction.gb,
      startYear: 2026,
      start: DateTime.utc(2026, 4, 6),
      end: DateTime.utc(2027, 4, 6),
      label: '2026/27',
    );

    test('includes its first day and excludes the next year', () {
      expect(year.contains(DateTime.utc(2026, 4, 6)), isTrue);
      expect(year.contains(DateTime(2027, 4, 5, 23, 59)), isTrue);
      expect(year.contains(DateTime.utc(2027, 4, 6)), isFalse);
      expect(year.contains(DateTime.utc(2026, 4, 5)), isFalse);
    });
  });

  group('TaxProfile', () {
    for (final profile in <TaxProfile>[
      const GbTaxProfile(
        entityKind: TaxEntityKind.individual,
        scottishTaxpayer: true,
        studentLoanPlan: GbStudentLoanPlan.plan2,
      ),
      const UsTaxProfile(
        entityKind: TaxEntityKind.soleTrader,
        filingStatus: UsFilingStatus.marriedFilingJointly,
      ),
      const NgTaxProfile(
        entityKind: TaxEntityKind.individual,
        annualRentMinor: 240000000,
      ),
      const DeTaxProfile(
        entityKind: TaxEntityKind.company,
        salesTaxRegistered: true,
        smallBusinessExemption: false,
      ),
    ]) {
      test('${profile.jurisdiction.countryCode} round-trips through JSON', () {
        final restored = TaxProfile.fromJson(profile.toJson());
        expect(restored.toJson(), profile.toJson());
        expect(restored.runtimeType, profile.runtimeType);
      });
    }

    test('rejects an unknown jurisdiction', () {
      expect(
        () => TaxProfile.fromJson({
          'jurisdiction': 'ZZ',
          'entityKind': 'individual',
        }),
        throwsFormatException,
      );
    });
  });

  test('every jurisdiction reports in its own currency', () {
    expect(TaxJurisdiction.gb.currencyCode, 'GBP');
    expect(TaxJurisdiction.fromCountryCode('de'), TaxJurisdiction.de);
    expect(TaxJurisdiction.fromCountryCode('FR'), isNull);
  });
}
