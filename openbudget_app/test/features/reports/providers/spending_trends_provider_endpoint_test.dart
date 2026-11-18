import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_trends_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_core/openbudget_core.dart';

import '../../../support/fake_endpoint_client.dart';

const _entityId = '00000000-0000-0000-0000-000000000001';

void main() {
  test('builds every month from one monthSummaries call', () async {
    final endMonth = MonthKey.fromDate(DateTime.now());
    final previousMonth = MonthKey.previous(endMonth);
    final client = FakeEndpointClient()
      ..handle('entity', 'get', (_) => testEntity())
      ..handle(
        'report',
        'monthSummaries',
        (_) => [
          testMonthSummary(
            month: endMonth,
            incomeMinor: 400000,
            activityMinor: -150000,
          ),
          testMonthSummary(
            month: previousMonth,
            incomeMinor: 200000,
            activityMinor: -50000,
          ),
        ],
      );
    final container = ProviderContainer(
      overrides: [serverpodClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    final trends = await container.read(
      spendingTrendsProvider(_entityId, months: 2).future,
    );

    expect(trends.currencyCode, 'GBP');
    expect(trends.averageIncome, 300000);
    expect(trends.averageExpenses, 100000);
    expect(
      [for (final month in trends.months) month.month],
      [
        endMonth,
        previousMonth,
      ],
    );
    expect(trends.months.first.totalIncome, 400000);
    expect(trends.months.first.totalExpenses, 150000);
    expect(trends.months.first.netIncome, 250000);
    expect(client.callsTo('report', 'spending'), isEmpty);
  });
}
