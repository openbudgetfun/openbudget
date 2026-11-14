import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_list_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/crypto_breakdown_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/screens/net_worth_screen.dart';
import 'package:openbudget_app/src/features/settings/providers/reporting_currency_provider.dart';
import 'package:openbudget_app/src/features/settings/screens/currency_settings_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';

/// The display-currency feature is gone: reporting currency is a user
/// setting, set from Settings -> Currency and from the net worth screen's
/// currency chip, and every converted figure comes from the server. This
/// flow covers both entry points.
void main() {
  patrolWidgetTest('reporting currency is set from the currency settings', (
    $,
  ) async {
    final tester = $.tester;
    var savedCurrency = 'USD';
    final container = ProviderContainer(
      overrides: [
        userSettingsProvider.overrideWith(
          (ref) async => UserSettings(
            userId: UuidValue.fromString(TestData.ownerId),
            reportingCurrencyCode: savedCurrency,
          ),
        ),
        reportingCurrencyActionsProvider.overrideWith(
          () => _RecordingReportingCurrency(
            onSaved: (code) => savedCurrency = code,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final router = GoRouter(
      initialLocation:
          '/budgets/${TestData.gbpEntityId}/more/settings/plan/currency',
      routes: [
        GoRoute(
          name: currencySettingsRoute,
          path: currencySettingsPath,
          builder: (context, state) => CurrencySettingsScreen(
            entityId: state.pathParameters['entityId']!,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          theme: OpenBudgetTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Currency'), findsOneWidget);
    expect(find.text('Reporting currency'), findsOneWidget);
    expect(find.text('US Dollar - USD'), findsOneWidget);

    await tester.tap(find.text('Reporting currency'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('British Pound (GBP)'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('British Pound (GBP)'));
    await tester.pumpAndSettle();

    expect(savedCurrency, 'GBP');
    expect(find.textContaining('Plan currency updated to'), findsOneWidget);
  });

  patrolWidgetTest(
    'net worth chip switches the reporting currency and reconverts',
    ($) async {
      final tester = $.tester;
      var reportingCurrency = 'USD';
      final container = ProviderContainer(
        overrides: [
          reportingCurrencyProvider.overrideWith(
            (ref) async => reportingCurrency,
          ),
          reportingCurrencyActionsProvider.overrideWith(
            () => _RecordingReportingCurrency(
              onSaved: (code) => reportingCurrency = code,
            ),
          ),
          cryptoBreakdownProvider.overrideWith(
            (ref, arg) async => TestData.noWalletsCryptoBreakdown(arg.$2),
          ),
          netWorthProvider.overrideWith(
            (ref) async => reportingCurrency == 'GBP'
                ? TestData.gbpNetWorthWithUsd()
                : _usdView(),
          ),
          entityListProvider.overrideWith(
            (ref) async => [
              TestData.gbpEntity(),
            ],
          ),
          netWorthForEntitiesProvider.overrideWith(
            (ref, entityIds) async => reportingCurrency == 'GBP'
                ? TestData.gbpNetWorthWithUsd()
                : _usdView(),
          ),
          netWorthHistoryProvider.overrideWith(
            (ref, range) async => _historyFor(
              reportingCurrency,
              range.granularity,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final router = GoRouter(
        initialLocation: '/budgets/${TestData.gbpEntityId}/reflect/net-worth',
        routes: [
          GoRoute(
            name: netWorthRoute,
            path: netWorthPath,
            builder: (context, state) => NetWorthScreen(
              entityId: state.pathParameters['entityId']!,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            theme: OpenBudgetTheme.light,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final netWorth = NetWorthPage(tester);
      expect(netWorth.headline, findsOneWidget);
      // USD reporting: the converted total comes from the server view.
      expect(find.text(r'$4,161.50'), findsWidgets);

      await netWorth.switchReportingCurrency('GBP');
      await tester.pumpAndSettle();

      expect(reportingCurrency, 'GBP');
      // GBP reporting re-renders the converted headline and, on the By
      // currency tab, the rate line that produced it.
      expect(find.text('£3,290.00'), findsWidgets);
      await netWorth.showByCurrency();
      await tester.pumpAndSettle();
      expect(
        find.textContaining('1 USD = 0.79 GBP'),
        findsOneWidget,
      );
    },
  );
}

/// Two-point history matching the flow's net worth fixture so the screen's
/// history section has data without a server round trip.
NetWorthHistoryView _historyFor(
  String reportingCurrency,
  NetWorthGranularity granularity,
) {
  final view = reportingCurrency == 'GBP'
      ? TestData.gbpNetWorthWithUsd()
      : _usdView();
  return NetWorthHistoryView(
    currencyCode: view.currencyCode,
    granularity: granularity,
    points: [
      NetWorthPoint(
        date: DateTime.utc(2026, 11, 4),
        assetsMinor: view.assetsMinor ~/ 2,
        liabilitiesMinor: view.liabilitiesMinor,
        netWorthMinor: view.netWorthMinor ~/ 2,
        isComplete: true,
      ),
      NetWorthPoint(
        date: view.asOf,
        assetsMinor: view.assetsMinor,
        liabilitiesMinor: view.liabilitiesMinor,
        netWorthMinor: view.netWorthMinor,
        isComplete: true,
      ),
    ],
  );
}

/// The same books reported in USD: the USD account stays native and the
/// GBP account is converted at the fixture's USD-per-GBP rate.
NetWorthView _usdView() {
  const rate = '1.2646';
  const gbpConverted = 316150; // 250000 GBP minor at 1.2646 USD per GBP.
  const totalMinor = 100000 + gbpConverted;
  return NetWorthView(
    currencyCode: 'USD',
    asOf: DateTime.utc(2026, 11, 8),
    assetsMinor: totalMinor,
    liabilitiesMinor: 0,
    netWorthMinor: totalMinor,
    isComplete: true,
    missingCurrencyCodes: const [],
    hasStaleRates: false,
    currencies: [
      NetWorthCurrencyRow(
        currencyCode: 'USD',
        nativeMinor: 100000,
        convertedMinor: 100000,
        fxRate: '1',
        fxRateDate: DateTime.utc(2026, 11, 8),
        isStale: false,
        accountCount: 1,
      ),
      NetWorthCurrencyRow(
        currencyCode: 'GBP',
        nativeMinor: 250000,
        convertedMinor: gbpConverted,
        fxRate: rate,
        fxRateDate: DateTime.utc(2026, 11, 8),
        isStale: false,
        accountCount: 1,
      ),
    ],
    entities: [
      NetWorthEntityRow(
        entityId: UuidValue.fromString(TestData.gbpEntityId),
        name: TestData.entityName,
        kind: EntityKind.individual,
        assetsMinor: totalMinor,
        liabilitiesMinor: 0,
        netWorthMinor: totalMinor,
        isComplete: true,
      ),
    ],
    accounts: const [],
  );
}

class _RecordingReportingCurrency extends ReportingCurrencyActions {
  _RecordingReportingCurrency({required this.onSaved});

  final ValueChanged<String> onSaved;
  int saveCalls = 0;

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  @override
  Future<void> setReportingCurrency(String currencyCode) async {
    saveCalls++;
    onSaved(currencyCode);
  }
}
