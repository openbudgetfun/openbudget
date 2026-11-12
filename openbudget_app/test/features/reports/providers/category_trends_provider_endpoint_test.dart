import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/reports/providers/category_trends_provider.dart';
import 'package:openbudget_app/src/features/reports/utils/month_range.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

import '../../../support/fake_endpoint_client.dart';

const _entityId = '00000000-0000-0000-0000-000000000001';
const _groceriesId = '00000000-0000-0000-0000-000000000010';
const _rentId = '00000000-0000-0000-0000-000000000011';

void main() {
  test('pivots byMonth spending into one series per category', () async {
    final endMonth = MonthKey.fromDate(DateTime.now());
    final startMonth = monthRangeStart(endMonth, 2);
    final client = FakeEndpointClient()
      ..handle('entity', 'get', (_) => testEntity())
      ..handle(
        'report',
        'monthSummaries',
        (_) => [
          testMonthSummary(month: endMonth),
          testMonthSummary(month: startMonth),
        ],
      )
      ..handle(
        'report',
        'spending',
        (_) => [
          testSpendingRow(
            groupId: _groceriesId,
            name: 'Groceries',
            month: endMonth,
            outflowMinor: -100000,
          ),
          testSpendingRow(
            groupId: _groceriesId,
            name: 'Groceries',
            month: startMonth,
            outflowMinor: -200000,
          ),
          testSpendingRow(
            groupId: _rentId,
            name: 'Rent',
            month: endMonth,
            outflowMinor: -50000,
          ),
          testSpendingRow(
            name: 'No category',
            month: endMonth,
            outflowMinor: -90000,
          ),
          testSpendingRow(
            name: 'Refund',
            month: endMonth,
            inflowMinor: 10000,
          ),
        ],
      );
    final container = ProviderContainer(
      overrides: [serverpodClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    final trends = await container.read(
      categoryTrendsProvider(_entityId, months: 2).future,
    );

    expect(trends.months, [endMonth, startMonth]);
    expect(trends.currencyCode, 'GBP');
    expect(
      [for (final line in trends.categories) line.categoryName],
      [
        'Groceries',
        'Rent',
      ],
    );
    final groceries = trends.categories.first;
    expect(groceries.monthlyMinor, [100000, 200000]);
    expect(groceries.totalMinor, 300000);
    expect(trends.categories.last.monthlyMinor, [50000, 0]);
    final call = client.callsTo('report', 'spending').single;
    expect(call.args['fromMonth'], startMonth);
    expect(call.args['toMonth'], endMonth);
    expect(call.args['grouping'], ReportGrouping.category);
    expect(call.args['byMonth'], isTrue);
  });
}
