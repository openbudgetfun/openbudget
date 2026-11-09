import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;

/// Civil dates in an entity's IANA time zone, including DST transitions.
abstract final class EntityClock {
  static bool _initialized = false;

  /// Validates the zone before accepting it at a write boundary.
  static tz.Location location(String name) {
    if (!_initialized) {
      data.initializeTimeZones();
      _initialized = true;
    }
    try {
      return tz.getLocation(name);
    } on tz.LocationNotFoundException {
      throw ValidationException(message: 'Unknown IANA time zone');
    }
  }

  /// Returns UTC midnight representing the local calendar day.
  static DateTime today(Entity entity, {DateTime? now}) {
    final local = tz.TZDateTime.from(
      now ?? DateTime.now().toUtc(),
      location(entity.timeZone),
    );
    return DateTime.utc(local.year, local.month, local.day);
  }
}
