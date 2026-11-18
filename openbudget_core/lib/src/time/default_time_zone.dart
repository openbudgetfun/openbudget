import 'package:openbudget_core/src/countries/country_info.dart';

/// Default IANA time zone for a country, used when creating an entity.
///
/// OpenBudget deliberately reads no device time zone plugin (Q7): the zone
/// comes from the entity's country, and the user can pick another one. The
/// zone is the country's first in the generated dataset (a hand-kept choice
/// for countries spanning several zones); territories no zone covers get
/// `UTC`.
String defaultTimeZone(String countryCode) =>
    Countries.byCode(countryCode)?.defaultTimeZone ?? 'UTC';

/// Time zone choices offered for a country, most common first.
///
/// Only countries spanning several zones return more than one entry;
/// unknown countries get the single `UTC` fallback.
List<String> timeZoneChoices(String countryCode) =>
    Countries.byCode(countryCode)?.timeZoneChoices ?? const ['UTC'];
