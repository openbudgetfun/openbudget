import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';

import '../../../support/fake_endpoint_client.dart';

NetWorthView _view({
  String currencyCode = 'USD',
  int assetsMinor = 150000,
  int liabilitiesMinor = -30000,
  bool isComplete = true,
  List<String> missingCurrencyCodes = const [],
}) => NetWorthView(
  currencyCode: currencyCode,
  asOf: DateTime.utc(2026, 9, 5),
  assetsMinor: assetsMinor,
  liabilitiesMinor: liabilitiesMinor,
  netWorthMinor: assetsMinor + liabilitiesMinor,
  isComplete: isComplete,
  missingCurrencyCodes: missingCurrencyCodes,
  hasStaleRates: false,
  currencies: const [],
  entities: const [],
  accounts: const [],
);

void main() {
  test('netWorthProvider asks report.netWorth and returns the view', () async {
    final client = FakeEndpointClient()
      ..handle('report', 'netWorth', (_) => _view());
    final container = ProviderContainer(
      overrides: [serverpodClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    final data = await container.read(netWorthProvider.future);

    expect(data.assetsMinor, 150000);
    expect(data.liabilitiesMinor, -30000);
    expect(data.netWorthMinor, 120000);
    expect(client.callsTo('report', 'netWorth'), hasLength(1));
  });

  test(
    'netWorthForEntitiesProvider forwards the entity ids to the server',
    () async {
      const entityId = '00000000-0000-0000-0000-000000000001';
      final client = FakeEndpointClient()
        ..handle('report', 'netWorth', (args) {
          final entityIds = args['entityIds'] as List<dynamic>? ?? const [];
          return _view(
            assetsMinor: entityIds.isEmpty ? 0 : 120000,
          );
        });
      final container = ProviderContainer(
        overrides: [serverpodClientProvider.overrideWithValue(client)],
      );
      addTearDown(container.dispose);

      final data = await container.read(
        netWorthForEntitiesProvider({
          entityId,
          '00000000-0000-0000-0000-000000000002',
        }).future,
      );

      expect(data.assetsMinor, 120000);
      final call = client.callsTo('report', 'netWorth').single;
      expect(call.args['entityIds'], hasLength(2));
    },
  );

  test('netWorthProvider surfaces an incomplete view untouched', () async {
    final client = FakeEndpointClient()
      ..handle(
        'report',
        'netWorth',
        (_) => _view(
          isComplete: false,
          missingCurrencyCodes: const ['JPY'],
        ),
      );
    final container = ProviderContainer(
      overrides: [serverpodClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    final data = await container.read(netWorthProvider.future);

    // No conversion happens in the app: incomplete currencies are
    // listed, never guessed.
    expect(data.isComplete, isFalse);
    expect(data.missingCurrencyCodes, ['JPY']);
  });

  test('range dates bound the history window per toggle', () {
    final now = DateTime.utc(2026, 9, 15);

    final threeMonths = NetWorthRange.threeMonths.dates(now: now);
    expect(threeMonths.to, DateTime.utc(2026, 9, 15));
    expect(threeMonths.from, DateTime.utc(2026, 6, 15));

    final oneYear = NetWorthRange.oneYear.dates(now: now);
    // 366 days back from 2026-09-15 crosses the leap day: 2025-09-14.
    expect(oneYear.from, DateTime.utc(2025, 9, 14));

    final all = NetWorthRange.all.dates(now: now);
    expect(all.from, DateTime.utc(1900));
    expect(
      NetWorthRange.threeMonths.granularity,
      NetWorthGranularity.day,
    );
    expect(NetWorthRange.oneYear.granularity, NetWorthGranularity.week);
    expect(NetWorthRange.all.granularity, NetWorthGranularity.month);
  });
}
