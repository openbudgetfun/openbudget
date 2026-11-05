// The expected tax amounts are the § 32a EStG formula evaluated exactly for
// each year's coefficients:
//   https://www.gesetze-im-internet.de/estg/__32a.html
//   https://www.recht.bund.de/bgbl/1/2024/449/regelungstext.pdf (BGBl. 2024 I
//   Nr. 449, Artikel 1 und 2: the 2025 and 2026 tariff)
//   https://www.bmf-steuerrechner.de/interface/programmablauf.xhtml
//   (Tarifhistorie, 14.10.2025)
//
// The tax is the formula's result rounded down to whole euros, as § 32a
// Abs. 1 Satz 6 EStG requires.
import 'package:openbudget_core/src/tax/de/de_assessment.dart';
import 'package:openbudget_core/src/tax/de/de_tables.dart';
import 'package:openbudget_core/src/tax/de/de_tariff.dart';
import 'package:test/test.dart';

void main() {
  for (final (year, cases) in <(int, List<(int, int)>)>[
    (
      2025,
      [
        (12096, 0),
        (12097, 0),
        (17443, 1015),
        (17444, 1015),
        (40000, 7320),
        (50000, 10691),
        (68480, 17849),
        (68481, 17850),
        (100000, 31088),
        (277825, 105774),
        (277826, 105775),
        (1000000, 430753),
      ],
    ),
    (
      2026,
      [
        (12348, 0),
        (12349, 0),
        (17799, 1034),
        (17800, 1035),
        (40000, 7209),
        (50000, 10548),
        (69878, 18213),
        (69879, 18213),
        (100000, 30864),
        (277825, 105550),
        (277826, 105551),
        (1000000, 430529),
        (100000000, 44980529),
      ],
    ),
  ]) {
    group('§ 32a EStG $year', () {
      final tariff = deTaxTables[year]!.tariff;
      for (final (income, tax) in cases) {
        test('zvE $income gives $tax', () {
          expect(deIncomeTaxMinor(income * 100, tariff), tax * 100);
        });
      }

      test('rounds the taxable income down before applying the formula', () {
        expect(
          deIncomeTaxMinor(40000 * 100 + 99, tariff),
          deIncomeTaxMinor(40000 * 100, tariff),
        );
      });

      test('splits the tax into zones that add up', () {
        final slices = deTariffSlices(100000 * 100, tariff);
        expect(slices, hasLength(3));
        expect(
          slices.fold(0, (sum, slice) => sum + slice.taxMinor),
          deIncomeTaxMinor(100000 * 100, tariff),
        );
        expect(slices.first.rateBasisPoints, lessThan(2000));
        expect(slices.last.rateBasisPoints, inInclusiveRange(4100, 4200));
      });
    });
  }

  test('the marginal rate follows the tariff zones', () {
    final tariff2026 = deTaxTables[2026]!.tariff;
    expect(deMarginalRateBasisPoints(12348 * 100, tariff2026), 0);
    expect(deMarginalRateBasisPoints(12349 * 100, tariff2026), 1400);
    expect(deMarginalRateBasisPoints(17799 * 100, tariff2026), 2396);
    expect(deMarginalRateBasisPoints(40000 * 100, tariff2026), 3165);
    expect(deMarginalRateBasisPoints(277825 * 100, tariff2026), 4200);
    expect(deMarginalRateBasisPoints(277826 * 100, tariff2026), 4500);
  });

  group('Solidaritätszuschlag 2026', () {
    final rules = deTaxTables[2026]!.solidarity;
    int soli(int taxEuros) => deSolidaritySurchargeMinor(
      incomeTaxMinor: taxEuros * 100,
      freigrenzeMinor: rules.freigrenze,
      rules: rules,
    );

    test('is not levied at the Freigrenze', () {
      expect(soli(20350), 0);
    });

    test('starts with 11.9 % of the excess just above the Freigrenze', () {
      // 1 Euro over the Freigrenze: 11.9 cents, floored to 11 cents.
      expect(soli(20351), 11);
    });

    test('stays in the Milderungszone at 30 000 Euro', () {
      // 11.9 % of 9 650 Euro = 1 148.35 Euro, below 5.5 % of the tax.
      expect(soli(30000), 114835);
    });

    test('caps at 5.5 % above the zone', () {
      expect(soli(40000), 220000);
    });

    test('uses the doubled Freigrenze for joint assessment', () {
      final joint = deSolidaritySurchargeMinor(
        incomeTaxMinor: 40700 * 100,
        freigrenzeMinor: rules.freigrenzeJoint,
        rules: rules,
      );
      expect(joint, 0);
    });
  });

  group('§ 32d EStG', () {
    test('is 25 % of the capital income', () {
      expect(
        deCapitalIncomeTaxMinor(baseMinor: 100000, churchTaxRateBasisPoints: 0),
        25000,
      );
    });

    test('applies the church tax factor', () {
      // 1 000 Euro / 4.09 = 244.49 Euro.
      expect(
        deCapitalIncomeTaxMinor(
          baseMinor: 100000,
          churchTaxRateBasisPoints: 900,
        ),
        24449,
      );
    });

    test('the surcharge on it has no Freigrenze', () {
      expect(deCapitalIncomeSoliMinor(25000), 1375);
    });
  });

  group('Gewerbesteuer', () {
    test('keeps the 24 500 Euro Freibetrag for a natural person', () {
      // (100 000 - 24 500) * 3.5 % = 2 642.50 Euro.
      expect(
        deTradeTaxMessbetragMinor(
          profitMinor: 100000 * 100,
          freeAmountMinor: 24500 * 100,
          messzahlBasisPoints: 350,
        ),
        264250,
      );
    });

    test('charges no Freibetrag for a corporation', () {
      expect(
        deTradeTaxMessbetragMinor(
          profitMinor: 100000 * 100,
          freeAmountMinor: 0,
          messzahlBasisPoints: 350,
        ),
        350000,
      );
    });

    test('applies the Hebesatz to the Messbetrag', () {
      expect(deTradeTaxMinor(messbetragMinor: 264250, hebesatz: 400), 1057000);
    });

    test('credits four times the Messbetrag under § 35 EStG', () {
      expect(
        deSection35CreditMinor(
          incomeTaxMinor: 5000000,
          businessProfitMinor: 100000 * 100,
          positiveIncomeMinor: 100000 * 100,
          tradeTaxMinor: 1057000,
          messbetragMinor: 264250,
        ),
        1057000,
      );
    });

    test('limits the credit to the trade tax actually paid', () {
      expect(
        deSection35CreditMinor(
          incomeTaxMinor: 5000000,
          businessProfitMinor: 100000 * 100,
          positiveIncomeMinor: 100000 * 100,
          tradeTaxMinor: 300000,
          messbetragMinor: 100000,
        ),
        300000,
      );
    });

    test('limits the credit to the share of income tax it falls on', () {
      expect(
        deSection35CreditMinor(
          incomeTaxMinor: 100000,
          businessProfitMinor: 1000 * 100,
          positiveIncomeMinor: 2000 * 100,
          tradeTaxMinor: 300000,
          messbetragMinor: 100000,
        ),
        50000,
      );
    });
  });
}
