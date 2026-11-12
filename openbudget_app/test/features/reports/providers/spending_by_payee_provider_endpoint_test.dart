import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_by_payee_provider.dart';
import 'package:openbudget_app/src/features/reports/utils/report_group_names.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';

import '../../../support/fake_endpoint_client.dart';

const _entityId = '00000000-0000-0000-0000-000000000001';
const _tescoId = '00000000-0000-0000-0000-000000000020';
const _landlordId = '00000000-0000-0000-0000-000000000021';

void main() {
  test('groups one month by payee from one spending call', () async {
    final client = FakeEndpointClient()
      ..handle('entity', 'get', (_) => testEntity())
      ..handle(
        'report',
        'spending',
        (_) => [
          testSpendingRow(
            groupId: _tescoId,
            name: 'Tesco',
            outflowMinor: -50000,
            transactionCount: 3,
          ),
          testSpendingRow(
            groupId: _landlordId,
            name: 'Landlord',
            outflowMinor: -120000,
            transactionCount: 1,
          ),
          testSpendingRow(
            name: 'Refund',
            inflowMinor: 9900,
            transactionCount: 1,
          ),
          testSpendingRow(
            name: 'No payee',
            outflowMinor: -30000,
            transactionCount: 2,
          ),
        ],
      );
    final container = ProviderContainer(
      overrides: [serverpodClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    final report = await container.read(
      spendingByPayeeProvider(_entityId, 202511).future,
    );

    expect(report.currencyCode, 'GBP');
    expect(report.totalSpentMinor, 200000);
    expect(
      [for (final entry in report.entries) entry.payeeName],
      [
        'Landlord',
        'Tesco',
        reportUncategorisedGroup,
      ],
    );
    expect(report.entries.first.totalMinor, 120000);
    expect(report.entries.first.transactionCount, 1);
    expect(report.entries[1].transactionCount, 3);
    // The rows add up to the total.
    expect(
      report.entries.fold<int>(0, (sum, entry) => sum + entry.totalMinor),
      report.totalSpentMinor,
    );
    final call = client.callsTo('report', 'spending').single;
    expect(call.args['fromMonth'], 202511);
    expect(call.args['toMonth'], 202511);
    expect(call.args['grouping'], ReportGrouping.payee);
    expect(call.args['byMonth'], isFalse);
  });
}
