import 'package:meta/meta.dart';
import 'package:openbudget_core/src/tax/gb/gb_rates.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';

/// A company accounting period: Corporation Tax is assessed on this, never
/// on the 6 April personal tax year (CTA 2010 Part 4). A period is at most
/// twelve months.
@immutable
final class GbAccountingPeriod {
  const GbAccountingPeriod({required this.start, required this.end});

  /// First day, inclusive, as a date-only UTC value.
  final DateTime start;

  /// Last day, inclusive, as a date-only UTC value.
  final DateTime end;

  /// Whole days in the period, counting both ends.
  int get days => end.difference(start).inDays + 1;
}

/// The twelve-month accounting period that covers [taxYear] for a company
/// whose accounting period ends each year on [endMonth] [endDay]: the
/// instance of that date inside the tax year, with the period running from
/// the same date the year before. A 29 February end falls back to 28
/// February when the end year has no leap day.
///
/// The pack records entries by tax year, so it cannot see a first period, a
/// change of year end, or a longer accounts period split into two CT
/// periods; those need the books themselves.
GbAccountingPeriod gbAccountingPeriodFor({
  required TaxYear taxYear,
  required int endMonth,
  required int endDay,
}) {
  var day = endDay;
  final probe = DateTime.utc(taxYear.startYear, endMonth, day);
  if (probe.month != endMonth || probe.day != endDay) {
    day -= 1; // 29 February with no leap day: 28 February.
  }
  final earlier = DateTime.utc(taxYear.startYear, endMonth, day);
  final end = !earlier.isBefore(taxYear.start)
      ? earlier
      : DateTime.utc(taxYear.startYear + 1, endMonth, day);
  final start = DateTime.utc(end.year - 1, end.month, end.day).add(
    const Duration(days: 1),
  );
  return GbAccountingPeriod(start: start, end: end);
}

/// Whole calendar months an accounting period spans, which is how the
/// Annual Investment Allowance is pro-rated for a period that is not twelve
/// months (HMRC's own example: nine months gives three quarters of the cap).
int gbAccountingPeriodMonths(GbAccountingPeriod ap) =>
    (ap.end.year - ap.start.year) * 12 + ap.end.month - ap.start.month + 1;

/// The rule row whose Corporation Tax figures apply to the financial year
/// starting [fyStartYear]. Financial years run 1 April to 31 March and are
/// named by the start year.
///
/// The 19% small profits rate, the 25% main rate and the £50,000 and
/// £250,000 limits are held from FY2023 through FY2027 (GOV.UK "Rates and
/// allowances: Corporation Tax"; the FY2027 hold was re-checked on 5
/// November 2026). The pack stores FY2025 and FY2026 rows with those
/// identical figures, so held years outside the table read the nearest
/// stored row. Only the Corporation Tax figures may be read this way;
/// personal figures must always use their own tax year's row.
GbTaxYearRates gbRatesForFinancialYear(int fyStartYear) =>
    gbRatesByStartYear[fyStartYear.clamp(2025, 2026)]!;

@immutable
final class GbCorporationTaxPart {
  const GbCorporationTaxPart({
    required this.financialYearStartYear,
    required this.days,
    required this.financialYearDays,
    required this.profitMinor,
    required this.grossTaxMinor,
    required this.marginalReliefMinor,
    required this.taxMinor,
    required this.lowerLimitMinor,
    required this.upperLimitMinor,
  });

  /// The financial year (1 April start year) this part falls in.
  final int financialYearStartYear;
  final int days;
  final int financialYearDays;
  final int profitMinor;
  final int grossTaxMinor;
  final int marginalReliefMinor;
  final int taxMinor;

  /// The limits after short-period scaling and the associated-companies
  /// divisor, in pence.
  final int lowerLimitMinor;
  final int upperLimitMinor;
}

@immutable
final class GbCorporationTaxAssessment {
  const GbCorporationTaxAssessment({
    required this.parts,
    required this.grossTaxMinor,
    required this.marginalReliefMinor,
    required this.taxMinor,
  });

  /// One part per financial year the accounting period straddles. A period
  /// inside one financial year gives a single part.
  final List<GbCorporationTaxPart> parts;

  final int grossTaxMinor;
  final int marginalReliefMinor;
  final int taxMinor;
}

/// Computes Corporation Tax for one accounting period (CTA 2010 Part 4; HMRC
/// CTM03925, CTM03930, CTM03935 and CTM03955, checked 5 November 2026).
///
/// An accounting period that straddles 1 April is split into financial-year
/// parts, with profits apportioned by days (CTM03955). Each part scales the
/// £50,000 and £250,000 limits by its days over its financial year's days
/// (CTM03930) and divides them by one plus [associatedCompanies] (CTM03935).
/// Profits are rounded down to whole pounds and each part's tax down to the
/// penny. Exempt distributions and losses are not modelled, so taxable total
/// profits equal augmented profits.
GbCorporationTaxAssessment computeGbCorporationTax({
  required GbAccountingPeriod ap,
  required int chargeableProfitsMinor,
  required int associatedCompanies,
  GbTaxYearRates Function(int fyStartYear) ratesForFinancialYear =
      gbRatesForFinancialYear,
}) {
  if (chargeableProfitsMinor <= 0) {
    return const GbCorporationTaxAssessment(
      parts: [],
      grossTaxMinor: 0,
      marginalReliefMinor: 0,
      taxMinor: 0,
    );
  }
  final totalDays = ap.days;
  final parts = <GbCorporationTaxPart>[];
  var gross = 0;
  var relief = 0;
  var tax = 0;
  var profitsLeft = chargeableProfitsMinor;
  var cursor = ap.start;
  while (!cursor.isAfter(ap.end)) {
    final fyStartYear = !cursor.isBefore(DateTime.utc(cursor.year, 4))
        ? cursor.year
        : cursor.year - 1;
    final fyEnd = DateTime.utc(fyStartYear + 1, 3, 31);
    final fyDays = fyEnd.difference(DateTime.utc(fyStartYear, 4)).inDays + 1;
    final partEnd = fyEnd.isBefore(ap.end) ? fyEnd : ap.end;
    final partDays = partEnd.difference(cursor).inDays + 1;
    final isLast = partEnd.isAtSameMomentAs(ap.end);
    // Apportion profits by days; the last part takes the rounding remainder
    // so the parts always add back up to the whole period's profits.
    final partProfit = isLast
        ? profitsLeft
        : chargeableProfitsMinor * partDays ~/ totalDays;
    profitsLeft -= partProfit;

    final rates = ratesForFinancialYear(fyStartYear);
    final divisor = 1 + associatedCompanies;
    final lower =
        rates.corporationTaxLowerLimitMinor * partDays ~/ fyDays ~/ divisor;
    final upper =
        rates.corporationTaxUpperLimitMinor * partDays ~/ fyDays ~/ divisor;
    final profit = (partProfit ~/ 100) * 100;
    int partGross;
    int partRelief;
    int partTax;
    if (profit <= 0) {
      partGross = 0;
      partRelief = 0;
      partTax = 0;
    } else if (profit <= lower) {
      partTax = partGross =
          profit * rates.corporationTaxSmallProfitsRateBasisPoints ~/ 10000;
      partRelief = 0;
    } else {
      partGross = profit * rates.corporationTaxMainRateBasisPoints ~/ 10000;
      if (profit >= upper) {
        partRelief = 0;
        partTax = partGross;
      } else {
        partRelief =
            (upper - profit) *
            rates.corporationTaxMarginalReliefBasisPoints ~/
            10000;
        partTax = partGross - partRelief;
      }
    }
    parts.add(
      GbCorporationTaxPart(
        financialYearStartYear: fyStartYear,
        days: partDays,
        financialYearDays: fyDays,
        profitMinor: partProfit,
        grossTaxMinor: partGross,
        marginalReliefMinor: partRelief,
        taxMinor: partTax,
        lowerLimitMinor: lower,
        upperLimitMinor: upper,
      ),
    );
    gross += partGross;
    relief += partRelief;
    tax += partTax;
    cursor = partEnd.add(const Duration(days: 1));
  }
  return GbCorporationTaxAssessment(
    parts: parts,
    grossTaxMinor: gross,
    marginalReliefMinor: relief,
    taxMinor: tax,
  );
}
