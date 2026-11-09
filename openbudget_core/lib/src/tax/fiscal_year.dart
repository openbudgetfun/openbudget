import 'package:openbudget_core/src/generated/entity_kind.dart';

/// Default month and day of an entity's financial year end.
({int month, int day}) defaultFiscalYearEnd(
  String countryCode,
  EntityKind kind,
) {
  if (countryCode.toUpperCase() == 'GB') {
    return kind == EntityKind.company
        ? (month: 3, day: 31)
        : (month: 4, day: 5);
  }
  return (month: 12, day: 31);
}
