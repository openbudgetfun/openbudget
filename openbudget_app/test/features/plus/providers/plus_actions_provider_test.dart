import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/features/plus/models/plus_action_state.dart';
import 'package:openbudget_app/src/features/plus/models/plus_platform.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_actions_provider.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_billing_api.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_entitlement_provider.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_platform_provider.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_url_launcher_provider.dart';
import 'package:openbudget_app/src/features/plus/providers/solana_wallet_subscribe_flow.dart';
import 'package:openbudget_app/src/features/plus/providers/store_purchases_provider.dart';
import 'package:openbudget_app/src/features/plus/services/solana_subscribe_flow.dart';
import 'package:openbudget_client/openbudget_client.dart';

import '../support/fakes.dart';

void main() {
  late FakePlusBillingApi api;
  late FakeStorePurchases store;
  late FakePlusUrlLauncher launcher;
  late FakeSolanaSubscribeFlow solana;

  ProviderContainer makeContainer({PlusPlatform platform = PlusPlatform.web}) {
    final container = ProviderContainer(
      overrides: [
        plusPlatformProvider.overrideWithValue(platform),
        plusBillingApiProvider.overrideWithValue(api),
        storePurchasesProvider.overrideWithValue(store),
        plusUrlLauncherProvider.overrideWithValue(launcher),
        solanaSubscribeFlowProvider.overrideWithValue(solana),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(plusActionsProvider, (_, _) {});
    addTearDown(subscription.close);
    return container;
  }

  setUp(() {
    api = FakePlusBillingApi();
    store = FakeStorePurchases();
    launcher = FakePlusUrlLauncher();
    solana = FakeSolanaSubscribeFlow();
  });

  group('PlusActions Stripe', () {
    test('creates checkout and opens the returned URL', () async {
      final container = makeContainer();

      final started = await container
          .read(plusActionsProvider.notifier)
          .startStripeCheckout();

      expect(started, isTrue);
      expect(api.checkoutCalls, 1);
      expect(api.lastSuccessUrl, endsWith('/plus?status=success'));
      expect(api.lastCancelUrl, endsWith('/plus?status=cancel'));
      expect(launcher.opened, [Uri.parse(api.checkoutUrl)]);
    });

    test('opens the billing portal with the return link', () async {
      final container = makeContainer();

      expect(
        await container.read(plusActionsProvider.notifier).openStripePortal(),
        isTrue,
      );

      expect(api.portalCalls, 1);
      expect(api.lastPortalReturnUrl, endsWith('/plus?status=manage'));
      expect(launcher.opened, [Uri.parse(api.portalUrl)]);
    });

    test('reports a payment method the server has switched off', () async {
      api.checkoutError = BillingRailUnavailableException();
      final container = makeContainer();

      expect(
        await container
            .read(plusActionsProvider.notifier)
            .startStripeCheckout(),
        isFalse,
      );
      expect(
        container.read(plusActionsProvider).failure,
        PlusActionFailure.unavailable,
      );
      expect(launcher.opened, isEmpty);
    });

    test('reports a launcher failure', () async {
      launcher.result = false;
      final container = makeContainer();

      expect(
        await container
            .read(plusActionsProvider.notifier)
            .startStripeCheckout(),
        isFalse,
      );
      expect(
        container.read(plusActionsProvider).failure,
        PlusActionFailure.failed,
      );
    });
  });

  group('PlusActions store', () {
    test('purchase refreshes the entitlement', () async {
      final container = makeContainer(platform: PlusPlatform.ios);
      final entitlement = container.listen(plusEntitlementProvider, (_, _) {});
      addTearDown(entitlement.close);
      expect(await container.read(plusEntitlementProvider.future), isNull);
      api.entitlement = makeEntitlement(source: EntitlementSource.appStore);

      final purchased = await container
          .read(plusActionsProvider.notifier)
          .purchaseMonthly();

      expect(purchased, isTrue);
      expect(store.purchaseCalls, 1);
      expect(
        (await container.read(plusEntitlementProvider.future))?.source,
        EntitlementSource.appStore,
      );
    });

    test('a cancelled purchase carries the cancelled failure', () async {
      store.purchaseOutcome = StorePurchaseOutcome.cancelled;
      final container = makeContainer(platform: PlusPlatform.android);

      expect(
        await container.read(plusActionsProvider.notifier).purchaseMonthly(),
        isFalse,
      );
      expect(
        container.read(plusActionsProvider).failure,
        PlusActionFailure.cancelled,
      );
    });

    test('an unavailable store reports unavailable', () async {
      store
        ..available = false
        ..purchaseOutcome = StorePurchaseOutcome.unavailable;
      final container = makeContainer(platform: PlusPlatform.ios);

      expect(
        await container.read(plusActionsProvider.notifier).purchaseMonthly(),
        isFalse,
      );
      expect(
        container.read(plusActionsProvider).failure,
        PlusActionFailure.unavailable,
      );
    });

    test('management opens the store URL when one exists', () async {
      final management = Uri.parse('https://apps.apple.com/account');
      store.management = management;
      final container = makeContainer(platform: PlusPlatform.ios);

      expect(
        await container
            .read(plusActionsProvider.notifier)
            .openStoreManagement(),
        isTrue,
      );
      expect(launcher.opened, [management]);
    });

    test('management reports unavailable without a store URL', () async {
      final container = makeContainer(platform: PlusPlatform.ios);

      expect(
        await container
            .read(plusActionsProvider.notifier)
            .openStoreManagement(),
        isFalse,
      );
      expect(
        container.read(plusActionsProvider).failure,
        PlusActionFailure.unavailable,
      );
    });
  });

  group('PlusActions Solana', () {
    test('subscribes then refreshes the entitlement', () async {
      final container = makeContainer();
      final entitlement = container.listen(plusEntitlementProvider, (_, _) {});
      addTearDown(entitlement.close);
      await container.read(plusEntitlementProvider.future);
      api.entitlement = makeEntitlement(source: EntitlementSource.solana);

      final subscribed = await container
          .read(plusActionsProvider.notifier)
          .subscribeWithSolana(const _AnyBuildContext());

      expect(subscribed, isTrue);
      expect(solana.calls, 1);
      final refreshed = await container.read(plusEntitlementProvider.future);
      expect(refreshed?.source, EntitlementSource.solana);
      expect(api.entitlementReads, 2);
    });

    test('a rejected wallet request carries the rejected failure', () async {
      solana.error = const SolanaSubscribeException(
        SolanaSubscribeFailure.walletRejected,
      );
      final container = makeContainer();

      final subscribed = await container
          .read(plusActionsProvider.notifier)
          .subscribeWithSolana(const _AnyBuildContext());

      expect(subscribed, isFalse);
      expect(
        container.read(plusActionsProvider).failure,
        PlusActionFailure.rejected,
      );
    });

    test('an unavailable wallet reports unavailable', () async {
      solana.error = const SolanaSubscribeException(
        SolanaSubscribeFailure.walletUnavailable,
      );
      final container = makeContainer();

      await container
          .read(plusActionsProvider.notifier)
          .subscribeWithSolana(const _AnyBuildContext());

      expect(
        container.read(plusActionsProvider).failure,
        PlusActionFailure.unavailable,
      );
    });
  });

  group('PlusActions refresh', () {
    test('re-reads the entitlement', () async {
      final container = makeContainer();
      final entitlement = container.listen(plusEntitlementProvider, (_, _) {});
      addTearDown(entitlement.close);
      await container.read(plusEntitlementProvider.future);

      expect(
        await container.read(plusActionsProvider.notifier).refreshEntitlement(),
        isTrue,
      );
      expect(api.entitlementReads, 2);
    });

    test('reports a failed refresh', () async {
      api.entitlementError = Exception('billing down');
      final container = makeContainer();

      expect(
        await container.read(plusActionsProvider.notifier).refreshEntitlement(),
        isFalse,
      );
      expect(
        container.read(plusActionsProvider).failure,
        PlusActionFailure.failed,
      );
    });

    test('clearFailure resets the message', () async {
      launcher.result = false;
      final container = makeContainer();
      await container.read(plusActionsProvider.notifier).startStripeCheckout();

      container.read(plusActionsProvider.notifier).clearFailure();

      expect(container.read(plusActionsProvider).failure, isNull);
    });
  });
}

/// A build context that is never used: the fake wallet flow ignores it.
class _AnyBuildContext implements BuildContext {
  const _AnyBuildContext();

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('No widget context in this test');
}
