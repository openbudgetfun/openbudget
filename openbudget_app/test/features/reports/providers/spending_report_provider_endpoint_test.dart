import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:openbudget_app/src/features/reports/utils/report_group_names.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';

import '../../../support/fake_endpoint_client.dart';

const _entityId = '00000000-0000-0000-0000-000000000001';
const _groceriesId = '00000000-0000-0000-0000-000000000010';
const _rentId = '00000000-0000-0000-0000-000000000011';

void main() {
  test('one month: category rows and the month summary', () async {
    final client = _clientWith(
      summaries: [
        testMonthSummary(
          month: 202511,
          incomeMinor: 500000,
          activityMinor: -120000,
        ),
      ],
      rows: [
        testSpendingRow(
          groupId: _groceriesId,
          name: 'Groceries',
          outflowMinor: -80000,
        ),
        testSpendingRow(
          groupId: _rentId,
          name: 'Rent',
          outflowMinor: -40000,
        ),
        testSpendingRow(name: 'Refunds', inflowMinor: 5000),
        testSpendingRow(name: 'No category', outflowMinor: -30000),
      ],
    );
    final container = ProviderContainer(
      overrides: [serverpodClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    final report = await container.read(
      spendingReportProvider(_entityId, 202511).future,
    );

    expect(report.month, 202511);
    expect(report.currencyCode, 'GBP');
    expect(report.totalIncome, 500000);
    expect(report.totalExpenses, 150000);
    expect(report.netIncome, 350000);
    expect(report.categorySpending, {
      'Groceries': 80000,
      'Rent': 40000,
      reportUncategorisedGroup: 30000,
    });
    // The rows add up to the report total.
    expect(
      report.categorySpending.values.fold<int>(0, (sum, minor) => sum + minor),
      report.totalExpenses,
    );
    final call = client.callsTo('report', 'spending').single;
    expect(call.args['fromMonth'], 202511);
    expect(call.args['toMonth'], 202511);
    expect(call.args['grouping'], ReportGrouping.category);
    expect(call.args['byMonth'], isFalse);
  });

  test('preset: one spending call over the whole range', () async {
    final client = _clientWith(
      summaries: [
        testMonthSummary(
          month: 202511,
          incomeMinor: 300000,
          activityMinor: -60000,
        ),
        testMonthSummary(
          month: 202510,
          incomeMinor: 200000,
          activityMinor: -40000,
        ),
        testMonthSummary(
          month: 202509,
          incomeMinor: 100000,
          activityMinor: -20000,
        ),
      ],
      rows: [
        testSpendingRow(
          groupId: _groceriesId,
          name: 'Groceries',
          outflowMinor: -100000,
        ),
        testSpendingRow(
          groupId: _rentId,
          name: 'Rent',
          outflowMinor: -20000,
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [serverpodClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    final report = await container.read(
      spendingReportPresetProvider(_entityId, 202511, 3).future,
    );

    expect(report.month, isNull);
    expect(report.totalIncome, 600000);
    expect(report.totalExpenses, 120000);
    expect(report.netIncome, 480000);
    expect(report.categorySpending, {'Groceries': 100000, 'Rent': 20000});
    expect(
      report.categorySpending.values.fold<int>(0, (sum, minor) => sum + minor),
      report.totalExpenses,
    );
    final call = client.callsTo('report', 'spending').single;
    expect(call.args['fromMonth'], 202509);
    expect(call.args['toMonth'], 202511);
    expect(call.args['byMonth'], isFalse);
  });
}

FakeEndpointClient _clientWith({
  required List<BudgetMonthSummary> summaries,
  required List<SpendingRow> rows,
}) => FakeEndpointClient()
  ..handle('entity', 'get', (_) => testEntity())
  ..handle('report', 'monthSummaries', (_) => summaries)
  ..handle('report', 'spending', (_) => rows);
