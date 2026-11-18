import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/reports/providers/month_figures_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';

import '../../../support/fake_endpoint_client.dart';

void main() {
  test('reads the range newest first from one monthSummaries call', () async {
    final client = FakeEndpointClient()
      ..handle(
        'report',
        'monthSummaries',
        (_) => [
          testMonthSummary(month: 202509, incomeMinor: 100),
          testMonthSummary(month: 202510, incomeMinor: 200),
          testMonthSummary(month: 202511, incomeMinor: 300),
        ],
      );
    final container = ProviderContainer(
      overrides: [serverpodClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    final summaries = await container.read(
      monthFiguresProvider(
        '00000000-0000-0000-0000-000000000001',
        202511,
        3,
      ).future,
    );

    expect(
      [for (final summary in summaries) summary.month],
      [
        202511,
        202510,
        202509,
      ],
    );
    final call = client.callsTo('report', 'monthSummaries').single;
    expect(call.args['fromMonth'], 202509);
    expect(call.args['toMonth'], 202511);
    expect(client.calls, hasLength(1));
  });

  test('a zero month count still asks for the end month alone', () async {
    final client = FakeEndpointClient()
      ..handle(
        'report',
        'monthSummaries',
        (_) => [testMonthSummary(month: 202511)],
      );
    final container = ProviderContainer(
      overrides: [serverpodClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    await container.read(
      monthFiguresProvider(
        '00000000-0000-0000-0000-000000000001',
        202511,
        0,
      ).future,
    );

    final call = client.callsTo('report', 'monthSummaries').single;
    expect(call.args['fromMonth'], 202511);
    expect(call.args['toMonth'], 202511);
  });
}
