import 'dart:math';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

void main() {
  test('civil dates reject normalization and non-midnight instants', () {
    expect(civilDate(2024, 2, 29), DateTime.utc(2024, 2, 29));
    expect(() => civilDate(2023, 2, 29), throwsArgumentError);
    expect(isCivilDate(DateTime.utc(2026, 1, 1, 1)), isFalse);
    expect(isCivilDate(DateTime(2026)), isFalse);
  });
  test('month keys cross years and reject invalid dates', () {
    expect(MonthKey.next(202612), 202701);
    expect(MonthKey.previous(202601), 202512);
    expect(MonthKey.toLastDate(202402), DateTime.utc(2024, 2, 29));
    for (final month in [189912, 202600, 202613, 1000001]) {
      expect(MonthKey.isValid(month), isFalse);
      expect(() => MonthKey.validate(month), throwsArgumentError);
    }
    expect(() => MonthKey.next(999912), throwsArgumentError);
  });
  test('every account kind has a complete consistent rule', () {
    for (final kind in AccountKind.values) {
      expect(kind.allowedBalanceSources, contains(kind.defaultBalanceSource));
      if (kind.canBeOnBudget) {
        expect(kind.defaultBalanceSource, AccountBalanceSource.transactions);
      }
      expect(
        kind.isLiability,
        [
          AccountKind.creditCard,
          AccountKind.loan,
          AccountKind.mortgage,
          AccountKind.otherLiability,
        ].contains(kind),
      );
    }
  });
  test('KWD and BHD use three decimal minor units', () {
    for (final code in ['KWD', 'BHD']) {
      final currency = CurrencyCode.tryParse(code)!;
      expect(currency.decimals, 3);
      expect(parseMinorUnits('1.234', currency.decimals), 1234);
      expect(formatMinorUnits(1234, currency.decimals), '1.234');
    }
  });
  test('recurrence retains month-end and leap-day anchors', () {
    final anchor = DateTime.utc(2024, 1, 31);
    expect(
      nextOccurrence(RecurrenceFrequency.monthly, anchor, anchor),
      DateTime.utc(2024, 2, 29),
    );
    expect(
      nextOccurrence(
        RecurrenceFrequency.monthly,
        anchor,
        DateTime.utc(2024, 2, 29),
      ),
      DateTime.utc(2024, 3, 31),
    );
    expect(
      nextOccurrence(
        RecurrenceFrequency.yearly,
        DateTime.utc(2024, 2, 29),
        DateTime.utc(2025, 2, 28),
      ),
      DateTime.utc(2026, 2, 28),
    );
    expect(
      nextOccurrence(RecurrenceFrequency.biweekly, anchor, anchor),
      DateTime.utc(2024, 2, 14),
    );
  });
  test('carryover, overspending and future assignments remain zero sum', () {
    final result = foldEnvelopeMonths(
      month: 202602,
      envelopes: {
        'hidden': {202601: (allocatedMinor: 100, activityMinor: -150)},
        'food': {
          202601: (allocatedMinor: 200, activityMinor: -50),
          202603: (allocatedMinor: 20, activityMinor: 0),
        },
      },
      flows: {202601: 1000},
    );
    expect(result.envelopes['food']!.carryoverMinor, 150);
    expect(result.envelopes['hidden']!.carryoverMinor, 0);
    expect(result.overspentLastMonthMinor, 50);
    expect(result.readyToAssignMinor, 630);
    expect(result.assignedInFutureMinor, 20);
  });
  test('1000 seeded envelope sequences preserve zero sum after each month', () {
    final random = Random(643);
    for (var trial = 0; trial < 1000; trial++) {
      final data = <String, Map<int, EnvelopeMonthAmounts>>{
        'one': {},
        'hidden': {},
      };
      final flows = <int, int>{};
      var total = 0;
      for (var month = 202601; month <= 202612; month++) {
        final flow = random.nextInt(10000) - 1000;
        flows[month] = flow;
        total += flow;
        for (final envelope in data.values) {
          final activity = random.nextInt(4000) - 3000;
          envelope[month] = (
            allocatedMinor: random.nextInt(5000) - 1000,
            activityMinor: activity,
          );
          total += activity;
        }
        final result = foldEnvelopeMonths(
          month: month,
          envelopes: data,
          flows: flows,
        );
        final available = result.envelopes.values.fold(
          0,
          (sum, e) => sum + e.availableMinor,
        );
        expect(
          available + result.readyToAssignMinor + result.assignedInFutureMinor,
          total,
        );
      }
    }
  });
  test('a month range folds exactly like one fold per month', () {
    final envelopes = <String, Map<int, EnvelopeMonthAmounts>>{
      'food': {
        202511: (allocatedMinor: 100, activityMinor: -150),
        202601: (allocatedMinor: 200, activityMinor: -50),
        202603: (allocatedMinor: 20, activityMinor: 0),
      },
      'empty': <int, EnvelopeMonthAmounts>{},
      'future': {202701: (allocatedMinor: 40, activityMinor: 0)},
    };
    final flows = <int, int>{202511: 1000, 202602: 300};

    final range = foldEnvelopeMonthRange(
      fromMonth: 202512,
      toMonth: 202612,
      envelopes: envelopes,
      flows: flows,
    );

    expect(range.months.keys.first, 202512);
    expect(range.months.keys.last, 202612);
    for (var month = 202512; month <= 202612; month = MonthKey.next(month)) {
      final single = foldEnvelopeMonths(
        month: month,
        envelopes: envelopes,
        flows: flows,
      );
      final totals = range.months[month]!;
      expect(totals.readyToAssignMinor, single.readyToAssignMinor);
      expect(totals.assignedInFutureMinor, single.assignedInFutureMinor);
      expect(totals.overspentLastMonthMinor, single.overspentLastMonthMinor);
      expect(
        totals.availableMinor,
        single.envelopes.values.fold(
          0,
          (sum, envelope) => sum + envelope.availableMinor,
        ),
      );
    }
    expect(range.envelopes, hasLength(envelopes.length));
    expect(range.envelopes['empty'], (
      carryoverMinor: 0,
      allocatedMinor: 0,
      activityMinor: 0,
      availableMinor: 0,
    ));
    expect(range.envelopes['future'], (
      carryoverMinor: 0,
      allocatedMinor: 0,
      activityMinor: 0,
      availableMinor: 0,
    ));
  });
}
