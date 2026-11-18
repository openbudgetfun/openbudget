import 'package:openbudget_core/src/countries/country_info.dart';
import 'package:openbudget_core/src/generated/entity_kind.dart';

/// Default month and day of an entity's financial year end.
///
/// Companies read the country's `companyYearEndDefault` from the generated
/// dataset. Individuals and sole traders end on the day before the country's
/// individual tax year starts, so a Kenyan person ends on 31 December and a
/// British one on 5 April. Countries whose dataset has no tax year yet, or
/// whose tax year follows a calendar other than the Gregorian one (month and
/// day cannot be mapped onto a Gregorian date), fall back to 31 December.
({int month, int day}) defaultFiscalYearEnd(
  String countryCode,
  EntityKind kind,
) {
  final country = Countries.byCode(countryCode);
  if (kind == EntityKind.company) {
    final companyEnd = country?.companyYearEndDefault;
    if (companyEnd != null) {
      return companyEnd;
    }
  } else if (country?.individualTaxYear case final taxYear?
      when taxYear.calendar == TaxYearCalendar.gregorian) {
    return _dayBefore(taxYear.startMonth, taxYear.startDay);
  }
  return (month: 12, day: 31);
}

/// Days in each month of a non-leap year.
const List<int> _monthLengths = [
  31,
  28,
  31,
  30,
  31,
  30,
  31,
  31,
  30,
  31,
  30,
  31,
];

/// The day before [month]/[day] in a non-leap year, wrapping across the year
/// boundary (1 January becomes 31 December).
({int month, int day}) _dayBefore(int month, int day) {
  if (day > 1) {
    return (month: month, day: day - 1);
  }
  final previous = month == 1 ? 12 : month - 1;
  return (month: previous, day: _monthLengths[previous - 1]);
}
