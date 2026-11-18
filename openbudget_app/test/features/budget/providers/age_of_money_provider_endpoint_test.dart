import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/budget/providers/age_of_money_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';

import '../../../support/fake_endpoint_client.dart';

const _entityId = '00000000-0000-0000-0000-000000000001';

void main() {
  test('reads the age of money from report.ageOfMoney', () async {
    final client = FakeEndpointClient()
      ..handle('report', 'ageOfMoney', (_) => 42);
    final container = ProviderContainer(
      overrides: [serverpodClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    expect(await container.read(ageOfMoneyProvider(_entityId).future), 42);
    final call = client.callsTo('report', 'ageOfMoney').single;
    expect(call.args['entityId'].toString(), _entityId);
  });

  test('keeps null when there is not enough history', () async {
    final client = FakeEndpointClient()
      ..handle('report', 'ageOfMoney', (_) => null);
    final container = ProviderContainer(
      overrides: [serverpodClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    expect(await container.read(ageOfMoneyProvider(_entityId).future), isNull);
  });
}
