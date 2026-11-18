import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_actions_provider.dart';
import 'package:openbudget_app/src/features/home/screens/create_entity_screen.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';
import 'package:patrol/patrol.dart';

import 'common/patrol_helpers.dart';
import 'common/test_data.dart';
import 'helpers/screenshot_capture.dart';

/// What the screen asked the fake creator to make.
typedef _Created = ({
  EntityKind kind,
  String countryCode,
  String baseCurrencyCode,
  String timeZone,
  int? fiscalYearEndMonth,
  int? fiscalYearEndDay,
});

/// Records the create call and hands back a fixed id, so the screen routes
/// on without a server. The network-deny guard in `flutter_test_config.dart`
/// fails the test if anything else reaches for the real one.
class _RecordingEntityActions extends EntityActions {
  final List<_Created> created = [];

  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  @override
  Future<String> create({
    required String name,
    required EntityKind kind,
    required String countryCode,
    required String baseCurrencyCode,
    required String timeZone,
    int? fiscalYearEndMonth,
    int? fiscalYearEndDay,
  }) async {
    created.add((
      kind: kind,
      countryCode: countryCode,
      baseCurrencyCode: baseCurrencyCode,
      timeZone: timeZone,
      fiscalYearEndMonth: fiscalYearEndMonth,
      fiscalYearEndDay: fiscalYearEndDay,
    ));
    return AnyCountryData.createdEntityId;
  }
}

Future<_RecordingEntityActions> _pumpCreateEntity(WidgetTester tester) async {
  final actions = _RecordingEntityActions();
  final container = ProviderContainer(
    overrides: [entityActionsProvider.overrideWith(() => actions)],
  );
  addTearDown(container.dispose);

  final router = GoRouter(
    initialLocation: createEntityPath,
    routes: [
      GoRoute(
        path: createEntityPath,
        builder: (_, _) => const CreateEntityScreen(),
      ),
      GoRoute(
        name: addAccountRoute,
        path: addAccountPath,
        builder: (_, _) =>
            const Scaffold(body: Center(child: Text('Add Account Screen'))),
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
        builder: (context, child) => ObWiredScope(child: child!),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return actions;
}

void main() {
  patrolWidgetTest(
    'a Kenyan individual is created with KES, Nairobi and the Kenyan tax year',
    ($) async {
      final tester = $.tester;
      await useScreenshotSurface(tester, ScreenshotSurface.phone);
      final actions = await _pumpCreateEntity(tester);
      final page = CreateEntityPage(tester);

      expect(page.title, findsOneWidget);
      expect(page.valueOf(page.countryField), AnyCountryData.ukName);
      await captureIntegrationScreenshot(tester, 'after-create-entity-phone');

      // Open the country picker and look for a country with no tax pack.
      await page.open(page.countryField);
      expect(page.pickerSearch, findsOneWidget);
      await captureIntegrationScreenshot(tester, 'after-country-picker-phone');

      // A country OpenBudget does not serve never shows up.
      await page.search(AnyCountryData.unservableQuery);
      expect(page.pickerRow(AnyCountryData.unservableName), findsNothing);
      expect(find.textContaining('Nothing matches'), findsOneWidget);

      await page.search(AnyCountryData.kenyaQuery);
      expect(page.pickerRow(AnyCountryData.kenyaName), findsOneWidget);
      await captureIntegrationScreenshot(
        tester,
        'after-country-picker-search-phone',
      );
      await tester.tap(page.pickerRow(AnyCountryData.kenyaName));
      await tester.pumpAndSettle();

      // The country filled the currency, time zone and tax year.
      expect(page.valueOf(page.countryField), AnyCountryData.kenyaName);
      expect(
        page.valueOf(page.currencyField),
        AnyCountryData.kenyaCurrencyRow,
      );
      expect(page.valueOf(page.timeZoneField), AnyCountryData.kenyaTimeZone);
      expect(page.valueOf(page.taxYearField), AnyCountryData.kenyaTaxYear);
      await captureIntegrationScreenshot(tester, 'after-kenya-filled-phone');

      await page.create(navigatesTo: find.text('Add Account Screen'));

      expect(actions.created, [
        (
          kind: EntityKind.individual,
          countryCode: AnyCountryData.kenyaCode,
          baseCurrencyCode: 'KES',
          timeZone: AnyCountryData.kenyaTimeZone,
          fiscalYearEndMonth: 12,
          fiscalYearEndDay: 31,
        ),
      ]);
    },
  );

  patrolWidgetTest('the currency can be changed after choosing a country', (
    $,
  ) async {
    final tester = $.tester;
    await useScreenshotSurface(tester, ScreenshotSurface.phone);
    final actions = await _pumpCreateEntity(tester);
    final page = CreateEntityPage(tester);

    await page.chooseCountry(
      AnyCountryData.kenyaQuery,
      AnyCountryData.kenyaName,
    );
    await page.open(page.currencyField);
    await captureIntegrationScreenshot(tester, 'after-currency-picker-phone');
    await page.search(AnyCountryData.usDollarQuery);
    await tester.tap(page.pickerRow(AnyCountryData.usDollarName));
    await tester.pumpAndSettle();
    expect(
      page.valueOf(page.currencyField),
      AnyCountryData.usDollarCurrencyRow,
    );

    await page.create(navigatesTo: find.text('Add Account Screen'));
    expect(actions.created.single.countryCode, AnyCountryData.kenyaCode);
    expect(actions.created.single.baseCurrencyCode, 'USD');
  });

  patrolWidgetTest('a country is found by the name people use for it', (
    $,
  ) async {
    final tester = $.tester;
    await useScreenshotSurface(tester, ScreenshotSurface.desktop);
    await _pumpCreateEntity(tester);
    final page = CreateEntityPage(tester);

    await page.chooseCountry(
      AnyCountryData.kenyaQuery,
      AnyCountryData.kenyaName,
    );
    await page.open(page.countryField);
    await page.search(AnyCountryData.ukAlias);
    await captureIntegrationScreenshot(tester, 'after-country-picker-desktop');
    expect(page.pickerRow(AnyCountryData.ukName), findsOneWidget);
    await tester.tap(page.pickerRow(AnyCountryData.ukName));
    await tester.pumpAndSettle();

    // Back on a country with a tax pack, the defaults are the pack's.
    expect(page.valueOf(page.currencyField), 'British Pound (GBP)');
    expect(page.valueOf(page.timeZoneField), 'Europe/London');
    expect(page.valueOf(page.taxYearField), 'Apr 6 to Apr 5');
  });
}
