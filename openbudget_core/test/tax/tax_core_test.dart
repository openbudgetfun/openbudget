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

    for (final (description, fields) in <(String, Map<String, Object?>)>[
      ('a missing entity kind', {'entityKind': null}),
      ('an unknown entity kind', {'entityKind': 'partnership'}),
      ('a string where a flag belongs', {'salesTaxRegistered': 'true'}),
      ('an unknown student loan plan', {'studentLoanPlan': 'plan9'}),
      ('a negative count', {'associatedCompanies': -1}),
      ('a month past December', {'accountingPeriodEndMonth': 13}),
      (
        'a day past the month end',
        {
          'accountingPeriodEndMonth': 4,
          'accountingPeriodEndDay': 31,
        },
      ),
    ]) {
      test('rejects $description with a FormatException', () {
        expect(
          () => TaxProfile.fromJson({
            'jurisdiction': 'GB',
            'entityKind': 'company',
            ...fields,
          }),
          throwsFormatException,
        );
      });
    }

    for (final (description, fields) in <(String, Map<String, Object?>)>[
      ('a negative German child count', {'children': -1}),
      ('an unknown Land', {'churchTaxState': 'atlantis'}),
      ('an unknown Einkunftsart', {'einkunftsArt': 'landwirtschaft'}),
    ]) {
      test('rejects $description with a FormatException', () {
        expect(
          () => TaxProfile.fromJson({
            'jurisdiction': 'DE',
            'entityKind': 'soleTrader',
            ...fields,
          }),
          throwsFormatException,
        );
      });
    }

    test('accepts 29 February as a company year end', () {
      final profile = TaxProfile.fromJson({
        'jurisdiction': 'GB',
        'entityKind': 'company',
        'accountingPeriodEndMonth': 2,
        'accountingPeriodEndDay': 29,
      }) as GbTaxProfile;
      expect(profile.accountingPeriodEndDay, 29);
    });

    test('rejects a US dependent that is not an object', () {
      expect(
        () => TaxProfile.fromJson({
          'jurisdiction': 'US',
          'entityKind': 'individual',
          'dependents': [true],
        }),
        throwsFormatException,
      );
    });

    test('rejects an unknown Nigerian small-company ceiling', () {
      expect(
        () => TaxProfile.fromJson({
          'jurisdiction': 'NG',
          'entityKind': 'company',
          'smallCompanyCeiling': 'n75m',
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

  test('every jurisdiction resolves to its own rule pack', () {
    for (final jurisdiction in TaxJurisdiction.values) {
      expect(TaxRules.forJurisdiction(jurisdiction).jurisdiction, jurisdiction);
    }
  });
}
