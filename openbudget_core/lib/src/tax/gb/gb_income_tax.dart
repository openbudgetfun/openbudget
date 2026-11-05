import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/gb/gb_rates.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';

/// Income tax for one individual, split by the kind of income it falls on.
///
/// Every amount is in minor units. Band ceilings are measured from zero
/// taxable income, exactly as [applyTaxBands] expects.
@immutable
final class GbIncomeTaxComputation {
  const GbIncomeTaxComputation({
    required this.totalIncomeMinor,
    required this.personalAllowanceMinor,
    required this.taxableIncomeMinor,
    required this.taxableNonSavingsMinor,
    required this.taxableSavingsMinor,
    required this.taxableDividendsMinor,
    required this.nonSavingsSlices,
    required this.savingsSlices,
    required this.dividendSlices,
  });

  /// All income before the personal allowance, after a loss has been set
  /// against the other kinds.
  final int totalIncomeMinor;

  final int personalAllowanceMinor;

  /// Total taxable income, rounded down to whole pounds.
  final int taxableIncomeMinor;

  final int taxableNonSavingsMinor;
  final int taxableSavingsMinor;
  final int taxableDividendsMinor;

  final List<TaxBandSlice> nonSavingsSlices;
  final List<TaxBandSlice> savingsSlices;
  final List<TaxBandSlice> dividendSlices;

  int get nonSavingsTaxMinor => sumBandTax(nonSavingsSlices);
  int get savingsTaxMinor => sumBandTax(savingsSlices);
  int get dividendTaxMinor => sumBandTax(dividendSlices);
  int get totalTaxMinor =>
      nonSavingsTaxMinor + savingsTaxMinor + dividendTaxMinor;
}

/// Applies [rates] to one individual's income.
///
/// Non-savings income is taxed first (at Scottish rates when
/// [scottishTaxpayer]), then savings, then dividends, as ITA 2007 requires.
/// Taxable income is rounded down to whole pounds and each band slice's tax
/// down to the penny, both in the taxpayer's favour.
GbIncomeTaxComputation computeGbIncomeTax({
  required GbTaxYearRates rates,
  required bool scottishTaxpayer,
  required int nonSavingsMinor,
  required int savingsMinor,
  required int dividendsMinor,
}) {
  var nonSavings = nonSavingsMinor;
  var savings = savingsMinor;
  var dividends = dividendsMinor;

  // A trading or property loss reduces the other kinds of income. It cannot
  // produce a repayment in this pack, which does not model loss relief.
  if (nonSavings < 0) {
    final loss = -nonSavings;
    final againstSavings = math.min(loss, savings);
    savings -= againstSavings;
    final againstDividends = math.min(loss - againstSavings, dividends);
    dividends -= againstDividends;
    nonSavings = 0;
  }

  final totalIncome = nonSavings + savings + dividends;
  final allowance = rates.personalAllowanceFor(totalIncome);

  var allowanceLeft = allowance;
  final nonSavingsAfterAllowance = math.max(0, nonSavings - allowanceLeft);
  allowanceLeft = math.max(0, allowanceLeft - nonSavings);
  final savingsAfterAllowance = math.max(0, savings - allowanceLeft);
  allowanceLeft = math.max(0, allowanceLeft - savings);
  final dividendsAfterAllowance = math.max(0, dividends - allowanceLeft);

  final (taxableNonSavings, taxableSavings, taxableDividends) = _wholePounds(
    nonSavingsAfterAllowance,
    savingsAfterAllowance,
    dividendsAfterAllowance,
  );
  final totalTaxable = taxableNonSavings + taxableSavings + taxableDividends;

  final bands = scottishTaxpayer ? rates.scottishBands : rates.rukBands;
  final nonSavingsSlices = applyTaxBands(taxableNonSavings, bands);

  final savingsAllowance = totalTaxable > rates.higherRateLimitMinor
      ? 0
      : totalTaxable > rates.basicRateLimitMinor
      ? rates.personalSavingsAllowanceHigherMinor
      : rates.personalSavingsAllowanceBasicMinor;

  final startingRateAvailable = math.max(
    0,
    rates.startingRateForSavingsMinor - taxableNonSavings,
  );
  final startingSlice = math.min(taxableSavings, startingRateAvailable);
  final afterStarting = taxableSavings - startingSlice;
  final reliefSlice = math.min(afterStarting, savingsAllowance);
  final taxedSavings = afterStarting - reliefSlice;

  final savingsSlices = <TaxBandSlice>[
    if (startingSlice > 0)
      TaxBandSlice(
        label: 'Starting rate for savings',
        baseMinor: startingSlice,
        rateBasisPoints: 0,
        taxMinor: 0,
      ),
    if (reliefSlice > 0)
      TaxBandSlice(
        label: 'Personal Savings Allowance',
        baseMinor: reliefSlice,
        rateBasisPoints: 0,
        taxMinor: 0,
      ),
    ...applyTaxBands(
      taxedSavings,
      rates.savingsBands,
      startMinor: taxableNonSavings + startingSlice + reliefSlice,
    ),
  ];

  final allowanceSlice = math.min(
    taxableDividends,
    rates.dividendAllowanceMinor,
  );
  final taxedDividends = taxableDividends - allowanceSlice;

  final dividendSlices = <TaxBandSlice>[
    if (allowanceSlice > 0)
      TaxBandSlice(
        label: 'Dividend allowance',
        baseMinor: allowanceSlice,
        rateBasisPoints: 0,
        taxMinor: 0,
      ),
    ...applyTaxBands(
      taxedDividends,
      rates.dividendBands,
      startMinor: taxableNonSavings + taxableSavings + allowanceSlice,
    ),
  ];

  return GbIncomeTaxComputation(
    totalIncomeMinor: totalIncome,
    personalAllowanceMinor: allowance,
    taxableIncomeMinor: totalTaxable,
    taxableNonSavingsMinor: taxableNonSavings,
    taxableSavingsMinor: taxableSavings,
    taxableDividendsMinor: taxableDividends,
    nonSavingsSlices: nonSavingsSlices,
    savingsSlices: savingsSlices,
    dividendSlices: dividendSlices,
  );
}

/// Drops the pence from the total taxable income, taking them from the top
/// of the stack (dividends first) so the categories still add up.
(int, int, int) _wholePounds(int nonSavings, int savings, int dividends) {
  var nonSavingsRemainder = nonSavings;
  var savingsRemainder = savings;
  var dividendsRemainder = dividends;
  var pence = (nonSavings + savings + dividends) % 100;
  if (pence == 0) {
    return (nonSavings, savings, dividends);
  }

  int takeFrom(int amount) {
    final taken = math.min(amount, pence);
    pence -= taken;
    return taken;
  }

  dividendsRemainder -= takeFrom(dividendsRemainder);
  savingsRemainder -= takeFrom(savingsRemainder);
  nonSavingsRemainder -= takeFrom(nonSavingsRemainder);
  return (nonSavingsRemainder, savingsRemainder, dividendsRemainder);
}
