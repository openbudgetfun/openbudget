import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  Entity entity(String zone) => Entity(
    ownerId: Uuid().v4obj(),
    name: 'Home',
    kind: EntityKind.individual,
    countryCode: 'GB',
    baseCurrencyCode: 'GBP',
    timeZone: zone,
    fiscalYearEndMonth: 4,
    fiscalYearEndDay: 5,
  );

  test('today uses the entity date west of UTC', () {
    expect(
      EntityClock.today(
        entity('America/Los_Angeles'),
        now: DateTime.utc(2026, 11, 9, 1),
      ),
      DateTime.utc(2026, 11, 8),
    );
  });
  test('today uses the entity date east of UTC', () {
    expect(
      EntityClock.today(
        entity('Asia/Tokyo'),
        now: DateTime.utc(2026, 11, 9, 23),
      ),
      DateTime.utc(2026, 11, 10),
    );
  });
  test('today respects daylight saving', () {
    expect(
      EntityClock.today(
        entity('Europe/London'),
        now: DateTime.utc(2026, 7, 1, 23, 30),
      ),
      DateTime.utc(2026, 7, 2),
    );
    expect(
      EntityClock.today(
        entity('Europe/London'),
        now: DateTime.utc(2026, 12, 1, 23, 30),
      ),
      DateTime.utc(2026, 12, 1),
    );
  });
  test('unknown IANA zone is rejected', () {
    expect(
      () => EntityClock.location('Mars/Olympus'),
      throwsA(isA<ValidationException>()),
    );
  });
}
