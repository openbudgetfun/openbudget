// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:openbudget_server/src/reports/net_worth_periods.dart';
import 'package:test/test.dart';

void main() {
  group('Given a day range', () {
    test('when it crosses a leap day then every day is one point', () {
      final points = NetWorthPeriods.points(
        fromDate: DateTime.utc(2024, 2, 28),
        toDate: DateTime.utc(2024, 3, 1),
        granularity: NetWorthGranularity.day,
      );

      expect(points, [
        DateTime.utc(2024, 2, 28),
        DateTime.utc(2024, 2, 29),
        DateTime.utc(2024, 3, 1),
      ]);
    });

    test('when the range is one day then it has one point', () {
      final points = NetWorthPeriods.points(
        fromDate: DateTime.utc(2026, 12, 31),
        toDate: DateTime.utc(2026, 12, 31),
        granularity: NetWorthGranularity.day,
      );

      expect(points, [DateTime.utc(2026, 12, 31)]);
    });

    test('when it is 92 days then it is allowed and 93 is rejected', () {
      final allowed = NetWorthPeriods.points(
        fromDate: DateTime.utc(2024, 1, 1),
        toDate: DateTime.utc(2024, 4, 2),
        granularity: NetWorthGranularity.day,
      );

      expect(allowed, hasLength(93));
      expect(
        () => NetWorthPeriods.points(
          fromDate: DateTime.utc(2024, 1, 1),
          toDate: DateTime.utc(2024, 4, 3),
          granularity: NetWorthGranularity.day,
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('Given a week range', () {
    test('when it starts mid-week then points are Sundays and the end', () {
      final points = NetWorthPeriods.points(
        fromDate: DateTime.utc(2024, 1, 1),
        toDate: DateTime.utc(2024, 1, 20),
        granularity: NetWorthGranularity.week,
      );

      expect(points, [
        DateTime.utc(2024, 1, 7),
        DateTime.utc(2024, 1, 14),
        DateTime.utc(2024, 1, 20),
      ]);
    });

    test('when the end is a Sunday then it is not repeated', () {
      final points = NetWorthPeriods.points(
        fromDate: DateTime.utc(2024, 1, 8),
        toDate: DateTime.utc(2024, 1, 14),
        granularity: NetWorthGranularity.week,
      );

      expect(points, [DateTime.utc(2024, 1, 14)]);
    });

    test('when the range has no Sunday then only the end is a point', () {
      final points = NetWorthPeriods.points(
        fromDate: DateTime.utc(2024, 1, 3),
        toDate: DateTime.utc(2024, 1, 6),
        granularity: NetWorthGranularity.week,
      );

      expect(points, [DateTime.utc(2024, 1, 6)]);
    });

    test(
      'when it is two leap years then it is allowed and one day more is not',
      () {
        final allowed = NetWorthPeriods.points(
          fromDate: DateTime.utc(2024, 2, 29),
          toDate: DateTime.utc(2026, 2, 28),
          granularity: NetWorthGranularity.week,
        );

        expect(allowed, isNotEmpty);
        expect(
          () => NetWorthPeriods.points(
            fromDate: DateTime.utc(2024, 2, 29),
            toDate: DateTime.utc(2026, 3, 1),
            granularity: NetWorthGranularity.week,
          ),
          throwsA(isA<ValidationException>()),
        );
      },
    );
  });

  group('Given a month range', () {
    test('when it spans a leap February then month ends are exact', () {
      final points = NetWorthPeriods.points(
        fromDate: DateTime.utc(2024, 1, 15),
        toDate: DateTime.utc(2024, 3, 31),
        granularity: NetWorthGranularity.month,
      );

      expect(points, [
        DateTime.utc(2024, 1, 31),
        DateTime.utc(2024, 2, 29),
        DateTime.utc(2024, 3, 31),
      ]);
    });

    test('when it starts and ends mid-month then both ends are points', () {
      final points = NetWorthPeriods.points(
        fromDate: DateTime.utc(2024, 1, 31),
        toDate: DateTime.utc(2024, 2, 15),
        granularity: NetWorthGranularity.month,
      );

      expect(points, [DateTime.utc(2024, 1, 31), DateTime.utc(2024, 2, 15)]);
    });

    test('when the end is a month end then it is not repeated', () {
      final points = NetWorthPeriods.points(
        fromDate: DateTime.utc(2023, 11, 30),
        toDate: DateTime.utc(2024, 1, 31),
        granularity: NetWorthGranularity.month,
      );

      expect(points, [
        DateTime.utc(2023, 11, 30),
        DateTime.utc(2023, 12, 31),
        DateTime.utc(2024, 1, 31),
      ]);
    });

    test('when it is 400 months then it is allowed and 401 is rejected', () {
      final allowed = NetWorthPeriods.points(
        fromDate: DateTime.utc(2020, 1, 1),
        toDate: DateTime.utc(2053, 4, 30),
        granularity: NetWorthGranularity.month,
      );

      expect(allowed, hasLength(NetWorthPeriods.maxPoints));
      expect(
        () => NetWorthPeriods.points(
          fromDate: DateTime.utc(2020, 1, 1),
          toDate: DateTime.utc(2053, 5, 1),
          granularity: NetWorthGranularity.month,
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('Given an invalid range', () {
    test('when fromDate is after toDate then it is rejected', () {
      expect(
        () => NetWorthPeriods.points(
          fromDate: DateTime.utc(2024, 2, 1),
          toDate: DateTime.utc(2024, 1, 31),
          granularity: NetWorthGranularity.month,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('when a date is not a UTC civil date then it is rejected', () {
      expect(
        () => NetWorthPeriods.points(
          fromDate: DateTime.utc(2024, 1, 1, 12),
          toDate: DateTime.utc(2024, 1, 31),
          granularity: NetWorthGranularity.month,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('when a date is outside the supported years then it is rejected', () {
      expect(
        () => NetWorthPeriods.points(
          fromDate: DateTime.utc(1899, 12, 31),
          toDate: DateTime.utc(1900, 1, 31),
          granularity: NetWorthGranularity.month,
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
