import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/gb/gb_rates.dart';

/// The two payments on account owed after one tax year, worked out from that
/// year's own figures (ITA 2007 s59A; GOV.UK "Understand your Self
/// Assessment bill: payments on account" and the SA110 working sheet, checked
/// 5 November 2026).
///
/// The base is the year's Income Tax plus Class 4 NIC less tax collected at
/// source. It excludes Capital Gains Tax, student loan repayments, the High
/// Income Child Benefit Charge and Class 2, which are all settled with the
/// balancing payment instead. No payments are needed when the base is under
/// [GbTaxYearRates.paymentsOnAccountMinimumMinor], or when the share
/// collected at source exceeds
/// [GbTaxYearRates.paymentsOnAccountCollectedSharePercent] percent, which
/// the sheet tests as "the base is at least 20% of the year's tax" for the
/// 80% figure.
@immutable
final class GbPaymentsOnAccount {
  const GbPaymentsOnAccount({
    required this.baseMinor,
    required this.collectedSharePercent,
    required this.required,
    required this.instalmentMinor,
    required this.firstDue,
    required this.secondDue,
  });

  /// The year's Income Tax plus Class 4 NIC less tax collected at source.
  final int baseMinor;

  /// The share of the year's Income Tax plus Class 4 that was collected at
  /// source, rounded down. Only used to explain the decision.
  final int collectedSharePercent;

  /// Whether HMRC expects the two instalments.
  final bool required;

  /// Each instalment: the rule-data instalment share of [baseMinor], rounded
  /// down to the penny.
  final int instalmentMinor;

  /// 31 January two calendar years after the tax year starts: the
  /// instalments for 2026/27 fall due with the 2026/27 return, on 31 January
  /// 2028. Weekends do not extend it.
  final DateTime firstDue;

  /// 31 July two calendar years after the tax year starts.
  final DateTime secondDue;

  /// Both instalments together, nil when they are not required.
  int get totalMinor => required ? instalmentMinor * 2 : 0;
}

/// Works the payments on account out for the tax year starting [startYear].
/// The instalments fall due with that year's return, on 31 January and 31
/// July two calendar years after the year starts (GOV.UK: the 2025/26
/// payments on account are due 31 January and 31 July 2027).
///
/// [incomeTaxAndClass4Minor] is the year's Income Tax plus Class 4 NIC:
/// Capital Gains Tax, student loan repayments and the High Income Child
/// Benefit Charge must not be included. [taxCollectedAtSourceMinor] is tax
/// withheld at source, such as PAYE; payments on account already made for
/// the year are not "collected at source", so a caller that cannot separate
/// them should not treat this as exact when they exist.
GbPaymentsOnAccount computeGbPaymentsOnAccount({
  required GbTaxYearRates rates,
  required int startYear,
  required int incomeTaxAndClass4Minor,
  required int taxCollectedAtSourceMinor,
}) {
  final base = math.max(
    0,
    incomeTaxAndClass4Minor - taxCollectedAtSourceMinor,
  );
  // SA110 working sheet: no payments when the base is under 20% of the
  // year's tax, which is the "more than 80% collected at source" rule.
  final aboveCollectedShare =
      incomeTaxAndClass4Minor *
          (100 - rates.paymentsOnAccountCollectedSharePercent) <=
      base * 100;
  final required =
      base >= rates.paymentsOnAccountMinimumMinor && aboveCollectedShare;
  final instalment =
      base * rates.paymentsOnAccountInstalmentSharePercent ~/ 100;
  return GbPaymentsOnAccount(
    baseMinor: base,
    collectedSharePercent: incomeTaxAndClass4Minor <= 0
        ? 0
        : taxCollectedAtSourceMinor * 100 ~/ incomeTaxAndClass4Minor,
    required: required,
    instalmentMinor: instalment,
    firstDue: DateTime.utc(startYear + 2, 1, 31),
    secondDue: DateTime.utc(startYear + 2, 7, 31),
  );
}
