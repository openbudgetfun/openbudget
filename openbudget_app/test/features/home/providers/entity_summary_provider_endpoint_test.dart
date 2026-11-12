import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/home/providers/entity_summary_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';

import '../../../support/fake_endpoint_client.dart';

void main() {
  test('reads every entity summary from one listSummaries call', () async {
    final client = FakeEndpointClient()
      ..handle(
        'entity',
        'listSummaries',
        (_) => [
          EntitySummaryView(
            entity: testEntity(),
            month: 202511,
            readyToAssignMinor: 125000,
            overspentEnvelopeCount: 2,
            netWorthMinor: 4300000,
            netWorthComplete: true,
            uncategorizedCount: 3,
            pendingProposalCount: 1,
            dueRecurringCount: 4,
          ),
          EntitySummaryView(
            entity: testEntity(
              id: '00000000-0000-0000-0000-000000000002',
              name: 'Studio',
              baseCurrencyCode: 'USD',
            ),
            month: 202511,
            overspentEnvelopeCount: 0,
            netWorthMinor: 0,
            netWorthComplete: false,
            uncategorizedCount: 0,
            pendingProposalCount: 0,
            dueRecurringCount: 0,
          ),
        ],
      );
    final container = ProviderContainer(
      overrides: [serverpodClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    final summaries = await container.read(entitySummariesProvider.future);

    expect(summaries, hasLength(2));
    expect(summaries.first.entity.name, 'Household');
    expect(summaries.first.readyToAssignMinor, 125000);
    expect(summaries.first.overspentEnvelopeCount, 2);
    expect(summaries.first.netWorthMinor, 4300000);
    expect(summaries.last.entity.name, 'Studio');
    expect(summaries.last.readyToAssignMinor, isNull);
    expect(client.calls, hasLength(1));
    expect(client.callsTo('entity', 'listSummaries'), hasLength(1));
  });
}
