import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/gb/gb_rates.dart';

/// What was bought in one accounting period, by allowance route.
@immutable
final class GbCapitalAllowanceAdditions {
  const GbCapitalAllowanceAdditions({
    this.otherQualifyingMinor = 0,
    this.newMainRatePlantMinor = 0,
    this.newSpecialRatePlantMinor = 0,
    this.carMinor = 0,
  });

  /// Plant and machinery claimed through the Annual Investment Allowance
  /// route: second-hand assets, and any qualifying spend not recorded as new
  /// main-rate or special-rate plant.
  final int otherQualifyingMinor;

  /// New and unused main-rate plant and machinery bought from 1 April 2023.
  /// Companies fully expense it; sole traders claim it through the AIA.
  final int newMainRatePlantMinor;

  /// New and unused special-rate (long-life, integral feature) plant.
  final int newSpecialRatePlantMinor;

  /// Cars. They never qualify for the Annual Investment Allowance, full
  /// expensing or the special-rate first-year allowance; they belong in a
  /// pool, which is not modelled yet.
  final int carMinor;
}

@immutable
final class GbCapitalAllowances {
  const GbCapitalAllowances({
    required this.annualInvestmentAllowanceMinor,
    required this.fullExpensingMinor,
    required this.specialRateFirstYearAllowanceMinor,
    required this.unrelievedMinor,
    required this.aiaCapMinor,
  });

  /// The Annual Investment Allowance given, capped at [aiaCapMinor].
  final int annualInvestmentAllowanceMinor;

  /// The 100% full-expensing allowance, companies only.
  final int fullExpensingMinor;

  /// The 50% special-rate first-year allowance, companies only.
  final int specialRateFirstYearAllowanceMinor;

  /// Expenditure with no allowance yet: cars, spend above the AIA cap, and
  /// the balance of special-rate spend after the 50% first-year allowance.
  /// Pools and writing-down allowances are not modelled yet, so this is
  /// shown as unrelieved rather than quietly dropped.
  final int unrelievedMinor;

  /// The AIA cap that applied, already pro-rated for a short period.
  final int aiaCapMinor;

  /// Every allowance given in the period.
  int get totalMinor =>
      annualInvestmentAllowanceMinor +
      fullExpensingMinor +
      specialRateFirstYearAllowanceMinor;
}

/// Computes capital allowances for one accounting period (CAA 2001; GOV.UK
/// "Annual Investment Allowance", "Full expensing" and "First year
/// allowances", checked 5 November 2026).
///
/// Companies (and only companies) fully expense new and unused main-rate
/// plant and take a 50% first-year allowance on new and unused special-rate
/// plant; everything else goes through the Annual Investment Allowance,
/// capped at [aiaCapMinor] and never covering cars. Pass the cap already
/// pro-rated for a short period: HMRC works the twelve-month basis out in
/// whole calendar months, as `gbAccountingPeriodMonths` does. Non-companies
/// claim all plant except cars through the AIA. Writing-down allowances,
/// balancing charges and the AIA shared across companies under common
/// control are not modelled yet.
GbCapitalAllowances computeGbCapitalAllowances({
  required GbTaxYearRates rates,
  required int aiaCapMinor,
  GbCapitalAllowanceAdditions additions = const GbCapitalAllowanceAdditions(),
  bool company = false,
}) {
  final fullExpensing = company
      ? additions.newMainRatePlantMinor *
            rates.fullExpensingRateBasisPoints ~/
            10000
      : 0;
  final specialRateFya = company
      ? additions.newSpecialRatePlantMinor *
            rates.specialRateFirstYearAllowanceBasisPoints ~/
            10000
      : 0;
  final aiaQualifying = company
      ? additions.otherQualifyingMinor
      : additions.otherQualifyingMinor +
            additions.newMainRatePlantMinor +
            additions.newSpecialRatePlantMinor;
  final aia = math.min(aiaQualifying, aiaCapMinor);
  final unrelieved =
      (aiaQualifying - aia) +
      additions.carMinor +
      (additions.newMainRatePlantMinor - fullExpensing) +
      (additions.newSpecialRatePlantMinor - specialRateFya);
  return GbCapitalAllowances(
    annualInvestmentAllowanceMinor: aia,
    fullExpensingMinor: fullExpensing,
    specialRateFirstYearAllowanceMinor: specialRateFya,
    unrelievedMinor: unrelieved,
    aiaCapMinor: aiaCapMinor,
  );
}
