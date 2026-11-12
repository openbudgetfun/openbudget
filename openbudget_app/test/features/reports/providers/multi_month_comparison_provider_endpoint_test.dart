import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/reports/providers/multi_month_comparison_provider.dart';
import 'package:openbudget_app/src/features/reports/utils/month_range.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

import '../../../support/fake_endpoint_client.dart';

const _entityId = '00000000-0000-0000-0000-000000000001';
const _foodId = '00000000-0000-0000-0000-000000000010';
const _funId = '00000000-0000-0000-0000-000000000011';
const _groceriesId = '00000000-0000-0000-0000-000000000020';
const _diningId = '00000000-0000-0000-0000-000000000021';
const _cinemaId = '00000000-0000-0000-0000-000000000022';

void main() {
  test(
    'compares envelope activity across months from one spending call',
    () async {
      final endMonth = MonthKey.fromDate(DateTime.now());
      final previousMonth = MonthKey.previous(endMonth);
      final client = FakeEndpointClient()
        ..handle('entity', 'get', (_) => testEntity())
        ..handle(
          'report',
          'monthSummaries',
          (_) => [
            testMonthSummary(month: endMonth, activityMinor: 81000),
            testMonthSummary(month: previousMonth, activityMinor: -5000),
          ],
        )
        ..handle(
          'category',
          'list',
          (_) => [
            testCategory(id: _foodId, name: 'Food'),
            testCategory(id: _funId, name: 'Fun', sortOrder: 1),
          ],
        )
        ..handle(
          'envelope',
          'list',
          (_) => [
            testEnvelope(
              id: _groceriesId,
              categoryId: _foodId,
              name: 'Groceries',
            ),
            testEnvelope(id: _diningId, categoryId: _foodId, name: 'Dining'),
            testEnvelope(id: _cinemaId, categoryId: _funId, name: 'Cinema'),
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
              outflowMinor: -10000,
            ),
            testSpendingRow(
              groupId: _groceriesId,
              name: 'Groceries',
              month: endMonth,
              inflowMinor: 3000,
            ),
            testSpendingRow(
              groupId: _groceriesId,
              name: 'Groceries',
              month: previousMonth,
              outflowMinor: -5000,
            ),
            testSpendingRow(
              groupId: _cinemaId,
              name: 'Cinema',
              month: endMonth,
              outflowMinor: -2000,
            ),
            testSpendingRow(
              name: 'No envelope',
              month: endMonth,
              inflowMinor: 90000,
            ),
          ],
        );
      final container = ProviderContainer(
        overrides: [serverpodClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);

      final comparison = await container.read(
        multiMonthComparisonProvider(_entityId, monthCount: 2).future,
      );

      expect(comparison.currencyCode, 'GBP');
      expect(
        [for (final month in comparison.months) month.month],
        [
          endMonth,
          previousMonth,
        ],
      );
      expect(comparison.months.first.totalActivityMinor, 81000);
      expect(comparison.uncategorisedMonthlyActivityMinor, {endMonth: 90000});
      expect(
        [for (final c in comparison.categories) c.category.name],
        [
          'Food',
          'Fun',
        ],
      );

      final food = comparison.categories.first;
      expect([for (final e in food.envelopes) e.envelope.name], ['Groceries']);
      expect(food.envelopes.single.monthlyActivityMinor, {
        endMonth: -7000,
        previousMonth: -5000,
      });
      expect(food.monthlyActivityMinor, {
        endMonth: -7000,
        previousMonth: -5000,
      });

      final fun = comparison.categories.last;
      expect(fun.envelopes.single.envelope.name, 'Cinema');
      expect(fun.monthlyActivityMinor, {endMonth: -2000});

      // The category rows plus the uncategorised row add up to each
      // month's total.
      for (final month in comparison.months) {
        final rowSum =
            comparison.categories.fold<int>(
              0,
              (sum, category) =>
                  sum + (category.monthlyActivityMinor[month.month] ?? 0),
            ) +
            (comparison.uncategorisedMonthlyActivityMinor[month.month] ?? 0);
        expect(rowSum, month.totalActivityMinor);
      }

      final call = client.callsTo('report', 'spending').single;
      expect(call.args['fromMonth'], monthRangeStart(endMonth, 2));
      expect(call.args['toMonth'], endMonth);
      expect(call.args['grouping'], ReportGrouping.envelope);
      expect(call.args['byMonth'], isTrue);
    },
  );
}
