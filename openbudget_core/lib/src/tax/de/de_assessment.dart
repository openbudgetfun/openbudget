import 'dart:math' as math;

import 'package:openbudget_core/src/tax/de/de_tables.dart';

/// § 4 SolzG 1995: 5.5 % of the income tax, capped by the Milderungszone.
///
/// The Freigrenze is compared with the income tax itself, not with the taxable
/// income, so most returns owe nothing. Inside the Milderungszone the surcharge
/// is 11.9 % of the amount above the Freigrenze, never more than 5.5 % of the
/// whole tax. Fractions of a cent are dropped.
int deSolidaritySurchargeMinor({
  required int incomeTaxMinor,
  required int freigrenzeMinor,
  required DeSolidaritySurcharge rules,
}) {
  if (incomeTaxMinor <= freigrenzeMinor) {
    return 0;
  }
  final proportional = incomeTaxMinor * rules.rateBasisPoints ~/ 10000;
  final mild =
      (incomeTaxMinor - freigrenzeMinor) * rules.mildRateBasisPoints ~/ 10000;
  return math.min(proportional, mild);
}

/// § 32d Abs. 1 EStG: the tax on capital income.
///
/// With church tax the rate is `e / (4 + k)`, which is the statute's
/// `(e - 4q) / (4 + k)` with no foreign tax to credit; `k` is the church tax
/// rate as a fraction. That makes the combined burden, income tax plus church
/// tax, the same whichever church the saver belongs to.
int deCapitalIncomeTaxMinor({
  required int baseMinor,
  required int churchTaxRateBasisPoints,
}) {
  if (baseMinor <= 0) {
    return 0;
  }
  if (churchTaxRateBasisPoints <= 0) {
    return baseMinor ~/ 4;
  }
  return baseMinor * 10000 ~/ (40000 + churchTaxRateBasisPoints);
}

/// § 3 Abs. 3 Satz 2 SolzG 1995: the surcharge on capital income tax is always
/// levied, without the Freigrenze.
int deCapitalIncomeSoliMinor(int capitalIncomeTaxMinor) =>
    capitalIncomeTaxMinor * 55 ~/ 1000;

/// § 11 GewStG: the Steuermessbetrag in cents.
///
/// The Gewerbeertrag is rounded down to whole hundreds of euros and reduced by
/// [freeAmountMinor], but never below zero. The Messbetrag is 3.5 % of what is
/// left; the statute sets no rounding for it, so it stays exact to the cent.
int deTradeTaxMessbetragMinor({
  required int profitMinor,
  required int freeAmountMinor,
  required int messzahlBasisPoints,
}) {
  final euros = profitMinor ~/ 100;
  final roundedDown = (euros ~/ 100) * 100;
  final reduced = roundedDown > freeAmountMinor ~/ 100
      ? roundedDown - freeAmountMinor ~/ 100
      : 0;
  return reduced * messzahlBasisPoints ~/ 100;
}

/// The Gewerbesteuer itself: the Messbetrag times the municipality's Hebesatz.
int deTradeTaxMinor({required int messbetragMinor, required int hebesatz}) =>
    messbetragMinor * hebesatz ~/ 100;

/// § 35 Abs. 1 EStG: the credit against income tax for trade tax paid.
///
/// Four times the Messbetrag, limited by the trade tax actually paid and by
/// the share of the income tax that falls on the business's positive income.
int deSection35CreditMinor({
  required int incomeTaxMinor,
  required int businessProfitMinor,
  required int positiveIncomeMinor,
  required int tradeTaxMinor,
  required int messbetragMinor,
}) {
  if (businessProfitMinor <= 0 || messbetragMinor <= 0) {
    return 0;
  }
  final fourTimes = messbetragMinor * 4;
  var credit = math.min(fourTimes, tradeTaxMinor);
  if (positiveIncomeMinor > 0) {
    final share = incomeTaxMinor * businessProfitMinor ~/ positiveIncomeMinor;
    credit = math.min(credit, share);
  }
  return math.min(credit, incomeTaxMinor);
}
