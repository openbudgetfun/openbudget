import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

Entity _entity(String zone) => Entity(
  ownerId: const Uuid().v4obj(),
  name: 'Home',
  kind: EntityKind.individual,
  countryCode: 'UG',
  baseCurrencyCode: 'UGX',
  timeZone: zone,
  fiscalYearEndMonth: 12,
  fiscalYearEndDay: 31,
);

void main() {
  group('EntityClock time zones', () {
    test('today resolves for a UG entity whose zone is an IANA alias', () {
      expect(
        () => EntityClock.today(
          _entity('Africa/Kampala'),
          now: DateTime.utc(2026),
        ),
        returnsNormally,
      );
    });

    test('every country time zone resolves through EntityClock.location', () {
      final failures = <String>[];
      for (final country in Countries.all) {
        for (final zone in country.timeZones) {
          try {
            EntityClock.location(zone);
          } on Object catch (_) {
            failures.add('${country.code}: $zone');
          }
        }
      }
      expect(
        failures,
        isEmpty,
        reason: '${failures.length} unresolvable zones: $failures',
      );
    });
  });
}
