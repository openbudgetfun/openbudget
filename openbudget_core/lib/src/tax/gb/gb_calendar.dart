import 'package:openbudget_core/src/tax/gb/gb_corporation_tax.dart';
import 'package:openbudget_core/src/tax/gb/gb_profile.dart';
import 'package:openbudget_core/src/tax/tax_calendar.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';

final Uri _saDeadlines = Uri.parse(
  'https://www.gov.uk/self-assessment-tax-returns/deadlines',
);
final Uri _paymentsOnAccount = Uri.parse(
  'https://www.gov.uk/understand-self-assessment-bill/payments-on-account',
);
final Uri _mtdQuarterly = Uri.parse(
  'https://www.gov.uk/guidance/use-making-tax-digital-for-income-tax/send-quarterly-updates',
);
final Uri _ctObligations = Uri.parse(
  'https://www.gov.uk/guidance/company-tax-return-obligations',
);
final Uri _companiesHouseAccounts = Uri.parse(
  'https://www.gov.uk/annual-accounts/penalties-for-late-filing',
);
final Uri _sendVatReturn = Uri.parse('https://www.gov.uk/submit-vat-return');
final Uri _payrollReporting = Uri.parse(
  'https://www.gov.uk/guidance/what-payroll-information-to-report-to-hmrc',
);
final Uri _p60 = Uri.parse('https://www.gov.uk/paye-forms-p45-p60-p11d/p60');
final Uri _benefitsDeadlines = Uri.parse(
  'https://www.gov.uk/employer-reporting-expenses-benefits/deadlines',
);
final Uri _cwg2 = Uri.parse(
  'https://www.gov.uk/government/publications/cwg2-further-guide-to-paye-and-national-insurance-contributions/2026-to-2027-employer-further-guide-to-paye-and-national-insurance-contributions',
);

/// The qualifying-income threshold at which Making Tax Digital for Income
/// Tax becomes mandatory, by the tax year it starts applying.
const Map<int, String> _mtdThresholds = {
  2026: '£50,000',
  2027: '£30,000',
  2028: '£20,000',
};

/// The filing and payment dates [period] creates for a UK taxpayer, from the
/// uk-personal-tax, uk-company-tax and uk-vat-payroll skills.
///
/// HMRC states its dates as fixed calendar days and does not move them for
/// weekends, so none of these rolls forward: 31 January 2027 is a Sunday and
/// stays 31 January 2027.
List<TaxDeadline> gbDeadlines(TaxYear period, GbTaxProfile profile) =>
    sortTaxDeadlines([
      ...switch (profile.entityKind) {
        EntityKind.individual ||
        EntityKind.soleTrader => _selfAssessment(period),
        EntityKind.company => _company(period, profile),
      },
      if (profile.salesTaxRegistered) ..._vat(period),
    ]);

TaxDeadline _deadline({
  required String id,
  required String title,
  required TaxDeadlineKind kind,
  required DateTime dueDate,
  required TaxYear period,
  required Uri source,
  required String citation,
  required TaxEvidenceGrade grade,
  DateTime? periodStart,
  DateTime? periodEnd,
  String? periodLabel,
  bool dependsOnProfile = false,
  String? note,
}) => TaxDeadline(
  id: id,
  title: title,
  kind: kind,
  dueDate: dueDate,
  periodStart: periodStart ?? period.start,
  periodEnd: periodEnd ?? period.end,
  periodLabel: periodLabel ?? period.label,
  source: source,
  citation: citation,
  grade: grade,
  dependsOnProfile: dependsOnProfile,
  note: note,
);

List<TaxDeadline> _selfAssessment(TaxYear period) {
  final year = period.startYear;
  final next = year + 1;
  TaxDeadline sa({
    required String id,
    required String title,
    required TaxDeadlineKind kind,
    required DateTime dueDate,
    required Uri source,
    required String citation,
    TaxEvidenceGrade grade = TaxEvidenceGrade.primary,
    String? note,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? periodLabel,
  }) => _deadline(
    id: id,
    title: title,
    kind: kind,
    dueDate: dueDate,
    period: period,
    source: source,
    citation: citation,
    grade: grade,
    note: note,
    periodStart: periodStart,
    periodEnd: periodEnd,
    periodLabel: periodLabel,
  );

  final deadlines = [
    sa(
      id: 'gb.sa.notify',
      title: 'Self Assessment registration notice',
      kind: TaxDeadlineKind.filing,
      dueDate: DateTime.utc(next, 10, 5),
      source: _saDeadlines,
      citation: 'GOV.UK Self Assessment deadlines',
      note:
          'Applies to a first Self Assessment return; HMRC sets a later date '
          'when registration comes after this one.',
    ),
    sa(
      id: 'gb.sa.paper-return',
      title: 'Self Assessment paper return',
      kind: TaxDeadlineKind.filing,
      dueDate: DateTime.utc(next, 10, 31),
      source: _saDeadlines,
      citation: 'GOV.UK Self Assessment deadlines',
      note: 'Applies to a return sent on paper rather than online.',
    ),
    sa(
      id: 'gb.sa.coding-out',
      title: 'Self Assessment online return for tax-code collection',
      kind: TaxDeadlineKind.filing,
      dueDate: DateTime.utc(next, 12, 30),
      source: _saDeadlines,
      citation: 'GOV.UK Self Assessment deadlines',
      note:
          'Filing online by this day lets a balance under £3,000 be '
          'collected through the tax code.',
    ),
    sa(
      id: 'gb.sa.online-return',
      title: 'Self Assessment online return',
      kind: TaxDeadlineKind.filing,
      dueDate: DateTime.utc(year + 2, 1, 31),
      source: _saDeadlines,
      citation: 'GOV.UK Self Assessment deadlines, 11:59pm',
    ),
    sa(
      id: 'gb.sa.balancing-payment',
      title: 'Self Assessment balancing payment',
      kind: TaxDeadlineKind.payment,
      dueDate: DateTime.utc(year + 2, 1, 31),
      source: _saDeadlines,
      citation: 'GOV.UK Self Assessment deadlines',
    ),
    sa(
      id: 'gb.sa.class2-voluntary',
      title: 'Voluntary Class 2 National Insurance payment',
      kind: TaxDeadlineKind.payment,
      dueDate: DateTime.utc(year + 2, 1, 31),
      source: _saDeadlines,
      citation: 'GOV.UK Self Assessment deadlines',
      note:
          'Applies only when profits are under the Small Profits Threshold '
          'and voluntary contributions are being paid.',
    ),
    sa(
      id: 'gb.sa.payment-on-account-1',
      title: 'First payment on account',
      kind: TaxDeadlineKind.payment,
      dueDate: DateTime.utc(next, 1, 31),
      source: _paymentsOnAccount,
      citation: 'GOV.UK payments on account',
      note:
          'Each instalment is half of the previous year’s Income Tax and '
          'Class 4 bill. None falls due when that bill was under £1,000 or '
          'more than 80% was collected at source.',
    ),
    sa(
      id: 'gb.sa.payment-on-account-2',
      title: 'Second payment on account',
      kind: TaxDeadlineKind.payment,
      dueDate: DateTime.utc(next, 7, 31),
      source: _paymentsOnAccount,
      citation: 'GOV.UK payments on account',
      note:
          'Each instalment is half of the previous year’s Income Tax and '
          'Class 4 bill. None falls due when that bill was under £1,000 or '
          'more than 80% was collected at source.',
    ),
    sa(
      id: 'gb.sa.amend',
      title: 'Last day to amend the Self Assessment return',
      kind: TaxDeadlineKind.filing,
      dueDate: DateTime.utc(year + 3, 1, 31),
      source: _saDeadlines,
      citation:
          'GOV.UK Self Assessment deadlines: 12 months after the filing '
          'deadline',
    ),
  ];

  final threshold = _mtdThresholds[year];
  if (threshold != null) {
    deadlines.addAll(_mtdUpdates(period, threshold));
  }
  return deadlines;
}

/// The four cumulative quarterly updates and the final declaration of
/// Making Tax Digital for Income Tax, from the first year it applies.
List<TaxDeadline> _mtdUpdates(TaxYear period, String threshold) {
  final year = period.startYear;
  final next = year + 1;
  final note =
      'Applies when qualifying income is over $threshold. A '
      'prepare-only app cannot send the update; MTD-compatible software '
      'does.';
  // Standard periods: 6 April to 5 July due 7 August, and so on.
  final quarters = [
    (
      DateTime.utc(year, 4, 6),
      DateTime.utc(year, 7, 6),
      DateTime.utc(year, 8, 7),
    ),
    (
      DateTime.utc(year, 7, 6),
      DateTime.utc(year, 10, 6),
      DateTime.utc(year, 11, 7),
    ),
    (
      DateTime.utc(year, 10, 6),
      DateTime.utc(next, 1, 6),
      DateTime.utc(next, 2, 7),
    ),
    (
      DateTime.utc(next, 1, 6),
      DateTime.utc(next, 4, 6),
      DateTime.utc(next, 5, 7),
    ),
  ];
  return [
    for (var index = 0; index < quarters.length; index++)
      _deadline(
        id: 'gb.mtd.quarterly-update',
        title: 'Making Tax Digital quarterly update ${index + 1}',
        kind: TaxDeadlineKind.filing,
        dueDate: quarters[index].$3,
        period: period,
        periodStart: quarters[index].$1,
        periodEnd: quarters[index].$2,
        periodLabel:
            '${englishTaxDate(quarters[index].$1)} to '
            '${englishTaxDate(addTaxDays(quarters[index].$2, -1))}',
        source: _mtdQuarterly,
        citation:
            'GOV.UK send quarterly updates: one month and 7 days after the '
            'period end',
        grade: TaxEvidenceGrade.primary,
        note: note,
      ),
    _deadline(
      id: 'gb.mtd.final-declaration',
      title: 'Making Tax Digital final declaration',
      kind: TaxDeadlineKind.filing,
      dueDate: DateTime.utc(year + 2, 1, 31),
      period: period,
      source: _mtdQuarterly,
      citation:
          'GOV.UK use Making Tax Digital for Income Tax: final '
          'declaration',
      grade: TaxEvidenceGrade.primary,
      note: note,
    ),
  ];
}

List<TaxDeadline> _company(TaxYear period, GbTaxProfile profile) {
  final ap = gbAccountingPeriodFor(
    taxYear: period,
    endMonth: profile.accountingPeriodEndMonth,
    endDay: profile.accountingPeriodEndDay,
  );
  final apLabel = 'year to ${englishTaxDate(ap.end)}';
  final apStart = ap.start;
  final apEndExclusive = addTaxDays(ap.end, 1);
  // Nine months and one day after the end: the day the ninth month of the
  // period that starts the day after the end closes, plus one. For a
  // 31 March year end that is 1 January, as the skill's worked example says.
  final paymentDue = addTaxMonths(apEndExclusive, 9);
  final returnDue = addTaxDays(addTaxMonths(apEndExclusive, 12), -1);
  // Companies House counts nine months from the accounting reference date
  // to the same day, or to the last day of a shorter month.
  final accountsDue =
      ap.end.day == lastDayOfTaxMonth(ap.end.year, ap.end.month).day
      ? lastDayOfTaxMonth(
          addTaxMonths(ap.end, 9).year,
          addTaxMonths(ap.end, 9).month,
        )
      : addTaxMonths(ap.end, 9);

  TaxDeadline co({
    required String id,
    required String title,
    required TaxDeadlineKind kind,
    required DateTime dueDate,
    required Uri source,
    required String citation,
    required TaxEvidenceGrade grade,
    String? note,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? periodLabel,
    bool dependsOnProfile = true,
  }) => _deadline(
    id: id,
    title: title,
    kind: kind,
    dueDate: dueDate,
    period: period,
    periodStart: periodStart ?? apStart,
    periodEnd: periodEnd ?? apEndExclusive,
    periodLabel: periodLabel ?? apLabel,
    source: source,
    citation: citation,
    grade: grade,
    dependsOnProfile: dependsOnProfile,
    note: note,
  );

  return [
    co(
      id: 'gb.ct.payment',
      title: 'Corporation Tax payment',
      kind: TaxDeadlineKind.payment,
      dueDate: paymentDue,
      source: _ctObligations,
      citation:
          'GOV.UK company tax return obligations: 9 months and 1 day '
          'after the accounting period ends',
      grade: TaxEvidenceGrade.primary,
    ),
    co(
      id: 'gb.ct.return',
      title: 'Company Tax Return (CT600)',
      kind: TaxDeadlineKind.filing,
      dueDate: returnDue,
      source: _ctObligations,
      citation:
          'GOV.UK company tax return obligations: 12 months after the '
          'accounting period ends',
      grade: TaxEvidenceGrade.primary,
    ),
    co(
      id: 'gb.ct.s455',
      title: 'Tax on loans to participators (section 455)',
      kind: TaxDeadlineKind.payment,
      dueDate: paymentDue,
      source: Uri.parse(
        'https://www.gov.uk/hmrc-internal-manuals/company-taxation-manual/ctm61610',
      ),
      citation:
          'CTM61610: 9 months and 1 day after the accounting period '
          'ends',
      grade: TaxEvidenceGrade.primary,
      note:
          'Applies when a participator owes the company money at the end of '
          'the period and has not repaid it within nine months.',
    ),
    co(
      id: 'gb.co.accounts',
      title: 'Annual accounts at Companies House',
      kind: TaxDeadlineKind.filing,
      dueDate: accountsDue,
      source: _companiesHouseAccounts,
      citation:
          'Companies House: 9 months after the accounting reference '
          'date',
      grade: TaxEvidenceGrade.inferred,
      note:
          'Assumes the accounting reference date is the period end; first '
          'accounts have a longer limit.',
    ),
    ..._payroll(period),
  ];
}

/// The company payroll dates: monthly pension and EPS dates and the
/// year-end forms.
List<TaxDeadline> _payroll(TaxYear period) {
  final year = period.startYear;
  final next = year + 1;
  const employerNote =
      'Applies when the company pays staff or directors '
      'through payroll.';
  TaxDeadline payroll({
    required String id,
    required String title,
    required TaxDeadlineKind kind,
    required DateTime dueDate,
    required Uri source,
    required String citation,
    required TaxEvidenceGrade grade,
    String note = employerNote,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? periodLabel,
  }) => _deadline(
    id: id,
    title: title,
    kind: kind,
    dueDate: dueDate,
    period: period,
    periodStart: periodStart,
    periodEnd: periodEnd,
    periodLabel: periodLabel,
    source: source,
    citation: citation,
    grade: grade,
    note: note,
  );

  final monthly = <TaxDeadline>[];
  for (var offset = 0; offset < 12; offset++) {
    // A tax month runs from the 6th of one month to the 5th of the next.
    final monthStart = DateTime.utc(year, 4 + offset, 6);
    final monthEnd = DateTime.utc(year, 5 + offset, 6);
    final labelEnd = addTaxDays(monthEnd, -1);
    final label =
        '${monthStart.day} ${englishTaxMonth(monthStart.year, monthStart.month)} '
        'to ${labelEnd.day} ${englishTaxMonth(labelEnd.year, labelEnd.month)}';
    monthly.add(
      payroll(
        id: 'gb.paye.eps',
        title: 'Employer Payment Summary (EPS)',
        kind: TaxDeadlineKind.filing,
        dueDate: DateTime.utc(labelEnd.year, labelEnd.month, 19),
        periodStart: monthStart,
        periodEnd: monthEnd,
        periodLabel: label,
        source: _payrollReporting,
        citation:
            'GOV.UK payroll information to report: by the 19th after '
            'the tax month',
        grade: TaxEvidenceGrade.primary,
        note:
            'Sent instead of a Full Payment Submission when no employee is '
            'paid in a whole tax month.',
      ),
    );
    // Pension deductions made in a calendar month reach the scheme by the
    // 22nd of the next one when paid electronically.
    final pensionMonth = DateTime.utc(year, 4 + offset);
    monthly.add(
      payroll(
        id: 'gb.paye.pension-contributions',
        title: 'Workplace pension contributions to the scheme',
        kind: TaxDeadlineKind.payment,
        dueDate: DateTime.utc(pensionMonth.year, pensionMonth.month + 1, 22),
        periodStart: pensionMonth,
        periodEnd: DateTime.utc(pensionMonth.year, pensionMonth.month + 1),
        periodLabel: englishTaxMonth(pensionMonth.year, pensionMonth.month),
        source: _cwg2,
        citation:
            'CWG2 2026 to 2027: the 22nd of the following month when '
            'paid electronically, the 19th by cheque',
        grade: TaxEvidenceGrade.primary,
        note: 'Applies when pension deductions are taken from pay.',
      ),
    );
  }

  return [
    payroll(
      id: 'gb.paye.p60',
      title: 'P60 for each employee',
      kind: TaxDeadlineKind.filing,
      dueDate: DateTime.utc(next, 5, 31),
      source: _p60,
      citation: 'GOV.UK P60: by 31 May for employees working on 5 April',
      grade: TaxEvidenceGrade.primary,
    ),
    payroll(
      id: 'gb.paye.p11d',
      title: 'P11D and P11D(b) benefits returns',
      kind: TaxDeadlineKind.filing,
      dueDate: DateTime.utc(next, 7, 6),
      source: _benefitsDeadlines,
      citation: 'GOV.UK employer reporting of expenses and benefits: 6 July',
      grade: TaxEvidenceGrade.primary,
      note: 'Applies when the company provides taxable benefits.',
    ),
    payroll(
      id: 'gb.paye.class-1a',
      title: 'Class 1A National Insurance on benefits',
      kind: TaxDeadlineKind.payment,
      dueDate: DateTime.utc(next, 7, 22),
      source: _benefitsDeadlines,
      citation:
          'GOV.UK employer reporting of expenses and benefits: 22 July '
          'when paid electronically, 19 July by cheque',
      grade: TaxEvidenceGrade.primary,
      note: 'Applies when the company provides taxable benefits.',
    ),
    ...monthly,
  ];
}

/// The VAT return and payment dates for quarterly periods ending in March,
/// June, September and December.
///
/// HMRC staggers VAT quarters by registration, and the profile does not hold
/// the stagger, so the calendar quarters are an assumption the note states.
List<TaxDeadline> _vat(TaxYear period) {
  final year = period.startYear;
  final next = year + 1;
  final quarterEnds = [
    DateTime.utc(year, 6, 30),
    DateTime.utc(year, 9, 30),
    DateTime.utc(year, 12, 31),
    DateTime.utc(next, 3, 31),
  ];
  return [
    for (final end in quarterEnds)
      () {
        // One calendar month and 7 days: the end of the next month plus
        // 7 days, as the skill's due-date logic has it.
        final nextMonth = addTaxMonths(DateTime.utc(end.year, end.month), 1);
        final due = addTaxDays(
          lastDayOfTaxMonth(nextMonth.year, nextMonth.month),
          7,
        );
        final start = DateTime.utc(end.year, end.month - 2);
        return _deadline(
          id: 'gb.vat.return',
          title: 'VAT return and payment',
          kind: TaxDeadlineKind.filingAndPayment,
          dueDate: due,
          period: period,
          periodStart: start,
          periodEnd: addTaxDays(end, 1),
          periodLabel: '${englishTaxDate(start)} to ${englishTaxDate(end)}',
          source: _sendVatReturn,
          citation:
              'GOV.UK send a VAT return: one calendar month and 7 days '
              'after the period end; weekends do not extend it',
          grade: TaxEvidenceGrade.primary,
          dependsOnProfile: true,
          note:
              'Assumes VAT periods end in March, June, September and '
              'December; HMRC’s stagger for the registration may differ.',
        );
      }(),
  ];
}
