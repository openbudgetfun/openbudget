import 'package:openbudget_core/src/countries/country_info.dart';
import 'package:openbudget_core/src/generated/entity_kind.dart';

/// Default month and day of an entity's financial year end.
///
/// Companies read the country's `companyYearEndDefault` from the generated
/// dataset. Individuals keep the hand-kept defaults until the dataset carries
/// individual tax years (docs/tax-jurisdictions.md, U3 to U5); that fallback
/// also preserves today's results for GB, US, NG and DE, whose packs predate
/// the dataset.
({int month, int day}) defaultFiscalYearEnd(
  String countryCode,
  EntityKind kind,
) {
  if (kind == EntityKind.company) {
    final companyEnd = Countries.byCode(countryCode)?.companyYearEndDefault;
    if (companyEnd != null) {
      return companyEnd;
    }
  }
  if (countryCode.toUpperCase() == 'GB') {
    return kind == EntityKind.company
        ? (month: 3, day: 31)
        : (month: 4, day: 5);
  }
  return (month: 12, day: 31);
}
