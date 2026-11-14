import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/tax/tax_summary_service.dart';
import 'package:serverpod/serverpod.dart' hide Transaction;
import 'package:test/test.dart';

void main() {
  group('TaxSummaryService.startYearFor', () {
    test('matches a far-east local date across the GB tax-year boundary', () {
      final entity = Entity(
        ownerId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
        name: 'Test',
        kind: EntityKind.individual,
        countryCode: 'GB',
        baseCurrencyCode: 'GBP',
        timeZone: 'Asia/Tokyo',
        fiscalYearEndMonth: 12,
        fiscalYearEndDay: 30,
      );

      // UTC 2026-04-05 20:00 is 2026-04-06 05:00 in Tokyo, i.e. the first
      // day of the GB tax year starting 2026, while the UTC date is still
      // the previous day.
      final now = DateTime.utc(2026, 4, 5, 20);
      expect(TaxSummaryService.startYearFor(entity, now: now), 2026);
    });

    test('a non-pack country falls back to the calendar year', () {
      final entity = Entity(
        ownerId: UuidValue.fromString('00000000-0000-0000-0000-000000000001'),
        name: 'Test',
        kind: EntityKind.individual,
        countryCode: 'KE',
        baseCurrencyCode: 'KES',
        timeZone: 'Africa/Nairobi',
        fiscalYearEndMonth: 12,
        fiscalYearEndDay: 30,
      );
      final now = DateTime.utc(2026, 7);
      expect(TaxSummaryService.startYearFor(entity, now: now), 2026);
    });
  });

  group('TaxSummaryService.currentYearLastDayFor', () {
    test('KE entity pinned to 2026-07-01 gives 2026-12-31', () {
      final previous = TaxSummaryService.clock;
      TaxSummaryService.clock = () => DateTime.utc(2026, 7, 1);
      try {
        final entity = Entity(
          ownerId: UuidValue.fromString(
            '00000000-0000-0000-0000-000000000001',
          ),
          name: 'Test',
          kind: EntityKind.individual,
          countryCode: 'KE',
          baseCurrencyCode: 'KES',
          timeZone: 'Africa/Nairobi',
          fiscalYearEndMonth: 12,
          fiscalYearEndDay: 30,
        );
        expect(
          TaxSummaryService.currentYearLastDayFor(entity),
          DateTime.utc(2026, 12, 31),
        );
      } finally {
        TaxSummaryService.clock = previous;
      }
    });

    test('GB individual pinned to 2026-07-01 gives 2027-04-05', () {
      final previous = TaxSummaryService.clock;
      TaxSummaryService.clock = () => DateTime.utc(2026, 7, 1);
      try {
        final entity = Entity(
          ownerId: UuidValue.fromString(
            '00000000-0000-0000-0000-000000000001',
          ),
          name: 'Test',
          kind: EntityKind.individual,
          countryCode: 'GB',
          baseCurrencyCode: 'GBP',
          timeZone: 'Europe/London',
          fiscalYearEndMonth: 4,
          fiscalYearEndDay: 5,
        );
        expect(
          TaxSummaryService.currentYearLastDayFor(entity),
          DateTime.utc(2027, 4, 5),
        );
      } finally {
        TaxSummaryService.clock = previous;
      }
    });
  });
}
