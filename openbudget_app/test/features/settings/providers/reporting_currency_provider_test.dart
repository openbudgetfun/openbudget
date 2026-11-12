import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/settings/providers/reporting_currency_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';

import '../../../fixtures/budget_month.dart';
import '../../../support/fake_endpoint_client.dart';

UserSettings _settings(String currencyCode) => UserSettings(
  userId: UuidValue.fromString(fixtureOwnerId),
  reportingCurrencyCode: currencyCode,
);

void main() {
  test(
    'reportingCurrencyProvider reads the stored reporting currency',
    () async {
      final client = FakeEndpointClient()
        ..handle('settings', 'get', (_) => _settings('GBP'));
      final container = ProviderContainer(
        overrides: [serverpodClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);

      final currency = await container.read(reportingCurrencyProvider.future);

      expect(currency, 'GBP');
    },
  );

  test(
    'setReportingCurrency persists through settings and refreshes readers',
    () async {
      var stored = 'GBP';
      final client = FakeEndpointClient()
        ..handle('settings', 'get', (_) => _settings(stored))
        ..handle('settings', 'setReportingCurrency', (args) {
          stored = args['currencyCode'] as String? ?? stored;
          return _settings(stored);
        });
      final container = ProviderContainer(
        overrides: [serverpodClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);

      await container.read(reportingCurrencyProvider.future);
      await container
          .read(reportingCurrencyActionsProvider.notifier)
          .setReportingCurrency('EUR');

      expect(
        client.callsTo('settings', 'setReportingCurrency'),
        hasLength(1),
      );
      final refreshed = await container.read(reportingCurrencyProvider.future);
      expect(refreshed, 'EUR');
      expect(
        container.read(reportingCurrencyActionsProvider),
        const AsyncValue<void>.data(null),
      );
    },
  );

  test(
    'a failed set records the error state and keeps the old currency',
    () async {
      final client = FakeEndpointClient()
        ..handle('settings', 'get', (_) => _settings('GBP'))
        ..handle(
          'settings',
          'setReportingCurrency',
          (_) => throw Exception('offline'),
        );
      final container = ProviderContainer(
        overrides: [serverpodClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);

      await container.read(reportingCurrencyProvider.future);
      await expectLater(
        container
            .read(reportingCurrencyActionsProvider.notifier)
            .setReportingCurrency('EUR'),
        throwsA(isA<Exception>()),
      );
      expect(container.read(reportingCurrencyActionsProvider).hasError, isTrue);
      expect(await container.read(reportingCurrencyProvider.future), 'GBP');
    },
  );
}
