import 'package:openbudget_core/src/tax/ng/ng_profile.dart';
import 'package:openbudget_core/src/tax/tax_calendar.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';

/// The Nigeria Tax Administration Act 2025 as gazetted.
final Uri _ntaa = Uri.parse('https://tat.gov.ng/Nigeria-Tax-Act-2025.pdf');
final Uri _personalReturnNews = Uri.parse(
  'https://businessday.ng/news/article/personal-income-tax-march-31-deadline-puts-nigerias-new-tax-system-to-test/',
);
final Uri _payeRemittance = Uri.parse(
  'https://anoorehr.com/blog/state-paye-remittance-nigeria-2026',
);
final Uri _whtRates = Uri.parse(
  'https://blog.taxspire.com/wht-rates-nigeria-2026/',
);

/// The filing and payment dates the calendar year [period] creates for a
/// Nigerian taxpayer, from the nigeria-tax skill.
///
/// The skill found no guidance on weekends for any Nigerian date, so none
/// of these moves: a date on a weekend stays on it.
List<TaxDeadline> ngDeadlines(TaxYear period, NgTaxProfile profile) {
  final year = period.startYear;
  final next = year + 1;
  final deadlines = <TaxDeadline>[];

  void add({
    required String id,
    required String title,
    required TaxDeadlineKind kind,
    required DateTime dueDate,
    required Uri source,
    required String citation,
    required TaxEvidenceGrade grade,
    String? note,
    bool dependsOnProfile = false,
    DateTime? periodStart,
    DateTime? periodEnd,
    String? periodLabel,
  }) => deadlines.add(
    TaxDeadline(
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
    ),
  );

  final isCompany = profile.entityKind == EntityKind.company;
  final isIndividual = profile.entityKind == EntityKind.individual;

  if (!isCompany) {
    add(
      id: 'ng.pit.annual-return',
      title: 'Personal income tax annual return and payment',
      kind: TaxDeadlineKind.filingAndPayment,
      dueDate: DateTime.utc(next, 3, 31),
      source: _personalReturnNews,
      citation: year < 2026
          ? 'Reported 31 March deadline for 2025 income, filed with the '
                'State Internal Revenue Service'
          : 'NTAA s. 49(1); the gazette gives no date for 2026 income, so '
                '31 March is the default',
      grade: year < 2026
          ? TaxEvidenceGrade.secondary
          : TaxEvidenceGrade.inferred,
      note:
          'The State Internal Revenue Service of residence receives the '
          'return; the date for 2026 income is a default until it is '
          'published.',
    );
  }

  if (isCompany) {
    add(
      id: 'ng.cit.annual-return',
      title: 'Company income tax return and payment',
      kind: TaxDeadlineKind.filingAndPayment,
      dueDate: DateTime.utc(next, 6, 30),
      source: _ntaa,
      citation:
          'NTAA s. 11(5) and s. 49(1): six months after the accounting year '
          'ends, with the tax payable by then',
      grade: TaxEvidenceGrade.primary,
      note: 'Assumes a 31 December accounting year, as the pack does.',
    );
  }

  if (!isIndividual) {
    const staffNote = 'Applies when the books employ staff.';
    add(
      id: 'ng.paye.employer-return',
      title: 'Employer annual PAYE return',
      kind: TaxDeadlineKind.filing,
      dueDate: DateTime.utc(next, 1, 31),
      source: _ntaa,
      citation:
          'NTAA s. 14(1): not later than 31 January for the previous '
          'year',
      grade: TaxEvidenceGrade.primary,
      note: staffNote,
    );
    for (var month = 1; month <= 12; month++) {
      final start = DateTime.utc(year, month);
      final due = DateTime.utc(year, month + 1, 10);
      add(
        id: 'ng.paye.monthly-remittance',
        title: 'Monthly PAYE remittance',
        kind: TaxDeadlineKind.payment,
        dueDate: due,
        periodStart: start,
        periodEnd: DateTime.utc(year, month + 1),
        periodLabel: englishTaxMonth(year, month),
        source: _payeRemittance,
        citation:
            'Commonly the 10th of the next month to the State Internal '
            'Revenue Service, inherited from PITA practice',
        grade: TaxEvidenceGrade.secondary,
        note: '$staffNote The date is configurable by state.',
      );
      add(
        id: 'ng.wht.monthly-remittance',
        title: 'Monthly withholding tax remittance',
        kind: TaxDeadlineKind.payment,
        dueDate: DateTime.utc(year, month + 1, 21),
        periodStart: start,
        periodEnd: DateTime.utc(year, month + 1),
        periodLabel: englishTaxMonth(year, month),
        source: _whtRates,
        citation: 'By the 21st of the month after the deduction',
        grade: TaxEvidenceGrade.secondary,
        note: 'Applies when tax is deducted at source from payments made.',
      );
    }
  }

  if (profile.salesTaxRegistered) {
    for (var month = 1; month <= 12; month++) {
      add(
        id: 'ng.vat.monthly-return',
        title: 'Monthly VAT return and payment',
        kind: TaxDeadlineKind.filingAndPayment,
        dueDate: DateTime.utc(year, month + 1, 21),
        periodStart: DateTime.utc(year, month),
        periodEnd: DateTime.utc(year, month + 1),
        periodLabel: englishTaxMonth(year, month),
        source: _ntaa,
        citation:
            'NTAA s. 22: on or before the 21st day of the following month, '
            'whether or not any activity occurred',
        grade: TaxEvidenceGrade.primary,
        dependsOnProfile: true,
        note:
            'A small business outside VAT registration files none unless it '
            'opts in. An extension to file does not extend the time to pay.',
      );
    }
  }

  return sortTaxDeadlines(deadlines);
}
