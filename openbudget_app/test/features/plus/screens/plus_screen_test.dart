import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/plus/models/plus_platform.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_billing_api.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_entitlement_provider.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_platform_provider.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_url_launcher_provider.dart';
import 'package:openbudget_app/src/features/plus/providers/solana_wallet_subscribe_flow.dart';
import 'package:openbudget_app/src/features/plus/providers/store_purchases_provider.dart';
import 'package:openbudget_app/src/features/plus/screens/plus_screen.dart';
import 'package:openbudget_app/src/features/plus/services/solana_subscribe_flow.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_test_utils/openbudget_test_utils.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

import '../support/fakes.dart';

final DateTime _periodEnd = DateTime.utc(2026, 2, 15, 12);
final String _formattedPeriodEnd = DateFormat.yMMMMd().format(
  _periodEnd.toLocal(),
);

ProviderContainer _container({
  required PlusPlatform platform,
  Entitlement? entitlement,
  FakePlusBillingApi? api,
  FakeStorePurchases? store,
  FakePlusUrlLauncher? launcher,
  FakeSolanaSubscribeFlow? solana,
  bool overrideStore = true,
}) {
  final billing = api ?? (FakePlusBillingApi()..entitlement = entitlement);
  final container = ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      plusPlatformProvider.overrideWithValue(platform),
      plusBillingApiProvider.overrideWithValue(billing),
      if (overrideStore)
        storePurchasesProvider.overrideWithValue(store ?? FakeStorePurchases()),
      if (launcher != null) plusUrlLauncherProvider.overrideWithValue(launcher),
      if (solana != null) solanaSubscribeFlowProvider.overrideWithValue(solana),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Future<void> _pumpPlus(
  WidgetTester tester,
  ProviderContainer container, {
  String? status,
}) {
  _useLargeSurface(tester);
  return tester.pumpApp(
    PlusScreen(status: status),
    container: container,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

void _useLargeSurface(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1200, 2400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('PlusScreen free plan', () {
    testWidgets('iOS offers only the App Store', (tester) async {
      final container = _container(
        platform: PlusPlatform.ios,
        store: FakeStorePurchases(),
      );

      await _pumpPlus(tester, container);
      await tester.pumpAndSettle();

      expect(find.text(r'$10'), findsOneWidget);
      expect(find.text('Get more from every envelope'), findsOneWidget);
      expect(find.text('Subscribe in the App Store'), findsOneWidget);
      expect(find.text('Pay with card'), findsNothing);
      expect(find.text('Pay with USDC'), findsNothing);
      expect(find.text('Restore purchases'), findsOneWidget);
      expect(find.text("I've paid, refresh"), findsNothing);
    });

    testWidgets('Android offers only Google Play', (tester) async {
      final container = _container(
        platform: PlusPlatform.android,
        store: FakeStorePurchases(),
      );

      await _pumpPlus(tester, container);
      await tester.pumpAndSettle();

      expect(find.text('Subscribe on Google Play'), findsOneWidget);
      expect(find.text('Subscribe in the App Store'), findsNothing);
      expect(find.text('Pay with card'), findsNothing);
      expect(find.text('Pay with USDC'), findsNothing);
    });

    testWidgets('a build without RevenueCat keys shows the rail unavailable', (
      tester,
    ) async {
      final container = _container(
        platform: PlusPlatform.ios,
        overrideStore: false,
      );

      await _pumpPlus(tester, container);
      await tester.pumpAndSettle();

      expect(
        find.text('Store purchases are unavailable in this build.'),
        findsOneWidget,
      );
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Subscribe in the App Store'),
      );
      expect(button.onPressed, isNull);
      expect(find.text('Restore purchases'), findsNothing);
    });

    testWidgets('web offers card and USDC, never the store', (tester) async {
      final container = _container(platform: PlusPlatform.web);

      await _pumpPlus(tester, container);
      await tester.pumpAndSettle();

      expect(find.text('Pay with card'), findsOneWidget);
      expect(find.text('Pay with USDC'), findsOneWidget);
      expect(find.text('Subscribe in the App Store'), findsNothing);
      expect(find.text('Subscribe on Google Play'), findsNothing);
    });

    testWidgets('macOS offers card and the refresh step', (tester) async {
      final container = _container(platform: PlusPlatform.macos);

      await _pumpPlus(tester, container);
      await tester.pumpAndSettle();

      expect(find.text('Pay with card'), findsOneWidget);
      expect(find.text('Pay with USDC'), findsNothing);
      expect(find.text("I've paid, refresh"), findsOneWidget);
    });

    testWidgets('shows the labelled loading panel first', (tester) async {
      final completer = Completer<Entitlement?>();
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          plusPlatformProvider.overrideWithValue(PlusPlatform.web),
          plusEntitlementProvider.overrideWith((ref) => completer.future),
        ],
      );
      addTearDown(container.dispose);

      await _pumpPlus(tester, container);
      await tester.pump();

      expect(find.byType(ObLoadingPanel), findsOneWidget);
      expect(find.text('Loading your plan…'), findsOneWidget);
    });

    testWidgets('shows the problem panel and retries', (tester) async {
      var reads = 0;
      final container = ProviderContainer(
        retry: (_, _) => null,
        overrides: [
          plusPlatformProvider.overrideWithValue(PlusPlatform.web),
          plusEntitlementProvider.overrideWith((ref) async {
            reads++;
            if (reads == 1) throw Exception('billing down');
            return null;
          }),
        ],
      );
      addTearDown(container.dispose);

      await _pumpPlus(tester, container);
      await tester.pumpAndSettle();

      expect(find.text('Could not load your plan'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();

      expect(find.text(r'$10'), findsOneWidget);
    });
  });

  group('PlusScreen subscribed plan', () {
    for (final (status, chip, datePrefix) in [
      (EntitlementStatus.active, 'Active', 'Renews on '),
      (EntitlementStatus.pastDue, 'Past due', 'Renews on '),
      (EntitlementStatus.canceled, 'Cancelled', 'Ends on '),
      (EntitlementStatus.expired, 'Expired', 'Ended on '),
    ]) {
      testWidgets('shows the $chip plan', (tester) async {
        final container = _container(
          platform: PlusPlatform.web,
          entitlement: makeEntitlement(status: status, periodEnd: _periodEnd),
        );

        await _pumpPlus(tester, container);
        await tester.pumpAndSettle();

        expect(find.text('Your OpenBudget Plus plan'), findsOneWidget);
        expect(find.text(chip), findsOneWidget);
        expect(find.text('Paid with Card'), findsOneWidget);
        expect(find.text('$datePrefix$_formattedPeriodEnd'), findsOneWidget);
        expect(find.text('Manage'), findsOneWidget);
        expect(find.text(r'$10'), findsNothing);
      });
    }

    testWidgets('Stripe manage opens the billing portal', (tester) async {
      final api = FakePlusBillingApi()
        ..entitlement = makeEntitlement(periodEnd: _periodEnd);
      final launcher = FakePlusUrlLauncher();
      final container = _container(
        platform: PlusPlatform.macos,
        api: api,
        launcher: launcher,
      );

      await _pumpPlus(tester, container);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();

      expect(api.portalCalls, 1);
      expect(launcher.opened, [Uri.parse(api.portalUrl)]);
    });

    testWidgets('store manage opens the management URL', (tester) async {
      final management = Uri.parse('https://apps.apple.com/account');
      final api = FakePlusBillingApi()
        ..entitlement = makeEntitlement(
          source: EntitlementSource.appStore,
          periodEnd: _periodEnd,
        );
      final store = FakeStorePurchases(management: management);
      final launcher = FakePlusUrlLauncher();
      final container = _container(
        platform: PlusPlatform.ios,
        api: api,
        store: store,
        launcher: launcher,
      );

      await _pumpPlus(tester, container);
      await tester.pumpAndSettle();

      expect(find.text('Paid with App Store'), findsOneWidget);
      await tester.tap(find.text('Manage'));
      await tester.pumpAndSettle();

      expect(store.managementCalls, 1);
      expect(launcher.opened, [management]);
    });

    testWidgets('Solana explains the wallet and offers a refresh', (
      tester,
    ) async {
      final container = _container(
        platform: PlusPlatform.web,
        entitlement: makeEntitlement(
          source: EntitlementSource.solana,
          periodEnd: _periodEnd,
        ),
      );

      await _pumpPlus(tester, container);
      await tester.pumpAndSettle();

      expect(find.text('Paid with Solana'), findsOneWidget);
      expect(find.text('Manage'), findsNothing);
      expect(
        find.textContaining('Cancel from the wallet'),
        findsOneWidget,
      );
      expect(find.text("I've paid, refresh"), findsOneWidget);
    });
  });

  group('PlusScreen actions', () {
    testWidgets('Stripe button calls checkout and launches the URL', (
      tester,
    ) async {
      final api = FakePlusBillingApi();
      final launcher = FakePlusUrlLauncher();
      final container = _container(
        platform: PlusPlatform.web,
        api: api,
        launcher: launcher,
      );

      await _pumpPlus(tester, container);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay with card'));
      await tester.pumpAndSettle();

      expect(api.checkoutCalls, 1);
      expect(api.lastSuccessUrl, endsWith('/plus?status=success'));
      expect(api.lastCancelUrl, endsWith('/plus?status=cancel'));
      expect(launcher.opened, [Uri.parse(api.checkoutUrl)]);
    });

    testWidgets('a launch failure shows the problem toast', (tester) async {
      final api = FakePlusBillingApi();
      final launcher = FakePlusUrlLauncher(result: false);
      final container = _container(
        platform: PlusPlatform.web,
        api: api,
        launcher: launcher,
      );

      await _pumpPlus(tester, container);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay with card'));
      await tester.pumpAndSettle();

      expect(find.text('That did not work. Try again.'), findsOneWidget);
    });

    testWidgets('Solana success shows the refreshed plan', (tester) async {
      final api = FakePlusBillingApi();
      final solana = FakeSolanaSubscribeFlow();
      final container = _container(
        platform: PlusPlatform.web,
        api: api,
        solana: solana,
      );

      await _pumpPlus(tester, container);
      await tester.pumpAndSettle();
      api.entitlement = makeEntitlement(periodEnd: _periodEnd);

      await tester.tap(find.text('Pay with USDC'));
      await tester.pumpAndSettle();

      expect(solana.calls, 1);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Your OpenBudget Plus plan'), findsOneWidget);
    });

    testWidgets('a rejected Solana wallet shows the rejected message', (
      tester,
    ) async {
      final solana = FakeSolanaSubscribeFlow(
        error: const SolanaSubscribeException(
          SolanaSubscribeFailure.walletRejected,
        ),
      );
      final container = _container(
        platform: PlusPlatform.web,
        solana: solana,
      );

      await _pumpPlus(tester, container);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pay with USDC'));
      await tester.pumpAndSettle();

      expect(solana.calls, 1);
      expect(find.text('The wallet request was cancelled.'), findsOneWidget);
      expect(find.text(r'$10'), findsOneWidget);
    });

    testWidgets('restore purchases reports success', (tester) async {
      final store = FakeStorePurchases();
      final container = _container(
        platform: PlusPlatform.ios,
        store: store,
      );

      await _pumpPlus(tester, container);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Restore purchases'));
      await tester.pumpAndSettle();

      expect(store.restoreCalls, 1);
      expect(find.text('Purchases restored.'), findsOneWidget);
    });

    testWidgets('desktop refresh re-reads the entitlement', (tester) async {
      final api = FakePlusBillingApi();
      final container = _container(
        platform: PlusPlatform.macos,
        api: api,
      );

      await _pumpPlus(tester, container);
      await tester.pumpAndSettle();
      expect(api.entitlementReads, 1);

      await tester.tap(find.text("I've paid, refresh"));
      await tester.pumpAndSettle();

      expect(api.entitlementReads, 2);
    });

    testWidgets('a success return refreshes and thanks the person', (
      tester,
    ) async {
      final api = FakePlusBillingApi()
        ..entitlement = makeEntitlement(periodEnd: _periodEnd);
      final container = _container(
        platform: PlusPlatform.web,
        api: api,
      );

      await _pumpPlus(tester, container, status: 'success');
      await tester.pumpAndSettle();

      expect(api.entitlementReads, greaterThanOrEqualTo(2));
      expect(
        find.text('Payment received. Checking your plan…'),
        findsOneWidget,
      );
    });

    testWidgets('a cancelled return explains nothing was charged', (
      tester,
    ) async {
      final container = _container(platform: PlusPlatform.web);

      await _pumpPlus(tester, container, status: 'cancel');
      await tester.pumpAndSettle();

      expect(
        find.text('Checkout cancelled. Nothing was charged.'),
        findsOneWidget,
      );
    });
  });
}
