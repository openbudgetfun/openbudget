import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/reports/providers/crypto_breakdown_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';

import '../../../fixtures/crypto_breakdown.dart';
import '../../../support/fake_endpoint_client.dart';

const _entityId = '00000000-0000-0000-0000-0000000000e1';

void main() {
  test('cryptoBreakdownProvider asks report.cryptoBreakdown for the entity '
      'and grouping and returns the view untouched', () async {
    final client = FakeEndpointClient()
      ..handle(
        'report',
        'cryptoBreakdown',
        (args) =>
            cryptoBreakdownView(args['grouping']! as CryptoBreakdownGrouping),
      );
    final container = ProviderContainer(
      overrides: [serverpodClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    final byAsset = await container.read(
      cryptoBreakdownProvider(
        _entityId,
        CryptoBreakdownGrouping.byAsset,
      ).future,
    );

    expect(byAsset.grouping, CryptoBreakdownGrouping.byAsset);
    expect(byAsset.totalMinor, 20000);
    expect(byAsset.rows.first.key, 'asset:USDC');
    final call = client.callsTo('report', 'cryptoBreakdown').single;
    expect(call.args['entityId'], UuidValue.fromString(_entityId));
    expect(call.args['grouping'], CryptoBreakdownGrouping.byAsset);
    // The reporting currency comes from the user's settings on the server.
    expect(call.args['currencyCode'], isNull);
  });

  test('each grouping is its own request', () async {
    final client = FakeEndpointClient()
      ..handle(
        'report',
        'cryptoBreakdown',
        (args) =>
            cryptoBreakdownView(args['grouping']! as CryptoBreakdownGrouping),
      );
    final container = ProviderContainer(
      overrides: [serverpodClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    await container.read(
      cryptoBreakdownProvider(
        _entityId,
        CryptoBreakdownGrouping.byChain,
      ).future,
    );
    await container.read(
      cryptoBreakdownProvider(
        _entityId,
        CryptoBreakdownGrouping.byAsset,
      ).future,
    );

    expect(
      [
        for (final call in client.callsTo('report', 'cryptoBreakdown'))
          call.args['grouping'],
      ],
      [CryptoBreakdownGrouping.byChain, CryptoBreakdownGrouping.byAsset],
    );
  });

  test('a server failure surfaces as an error state', () async {
    final client = FakeEndpointClient()
      ..handle('report', 'cryptoBreakdown', (_) => throw StateError('boom'));
    final container = ProviderContainer(
      overrides: [serverpodClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(
        cryptoBreakdownProvider(
          _entityId,
          CryptoBreakdownGrouping.byChain,
        ).future,
      ),
      throwsA(isA<StateError>()),
    );
  });
}
