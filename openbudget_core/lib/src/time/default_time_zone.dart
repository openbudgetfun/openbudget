/// Default IANA time zone for a country, used when creating an entity.
///
/// OpenBudget deliberately reads no device time zone plugin (Q7): the zone
/// comes from the entity's country, and the user can pick another one. Where
/// a country spans several zones this returns the most common one; the
/// create-entity screen offers the remaining zones as explicit choices.
String defaultTimeZone(String countryCode) =>
    switch (countryCode.toUpperCase()) {
      'US' => 'America/New_York',
      'GB' => 'Europe/London',
      'NG' => 'Africa/Lagos',
      'DE' => 'Europe/Berlin',
      _ => 'UTC',
    };

/// Time zone choices offered for a country, most common first.
///
/// Only countries spanning several zones return more than one entry.
List<String> timeZoneChoices(String countryCode) =>
    switch (countryCode.toUpperCase()) {
      'US' => const [
        'America/New_York',
        'America/Chicago',
        'America/Denver',
        'America/Phoenix',
        'America/Los_Angeles',
        'America/Anchorage',
        'Pacific/Honolulu',
      ],
      'GB' => const ['Europe/London'],
      'NG' => const ['Africa/Lagos'],
      'DE' => const ['Europe/Berlin'],
      _ => const ['UTC'],
    };
