import 'package:flutter/widgets.dart';
import 'package:openbudget_app/src/features/plus/models/plus_action_state.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_billing_api.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_checkout_links_provider.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_entitlement_provider.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_url_launcher_provider.dart';
import 'package:openbudget_app/src/features/plus/providers/solana_wallet_subscribe_flow.dart';
import 'package:openbudget_app/src/features/plus/providers/store_purchases_provider.dart';
import 'package:openbudget_app/src/features/plus/services/solana_subscribe_flow.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'plus_actions_provider.g.dart';

final _log = ObLogger('PlusActions');

/// Payment actions offered by the Plus screen.
///
/// Every rail funnels through here so the screen only has to show one busy
/// state and one message. Successful purchases invalidate
/// [plusEntitlementProvider] so the plan card updates when the webhook lands.
@riverpod
class PlusActions extends _$PlusActions {
  @override
  PlusActionState build() => const PlusActionState();

  /// Starts Stripe Checkout and opens the hosted URL.
  Future<bool> startStripeCheckout() =>
      _run(PlusActionKind.stripeCheckout, () async {
        final links = ref.read(plusCheckoutLinksProvider);
        final url = await ref
            .read(plusBillingApiProvider)
            .createStripeCheckout(links.successUrl, links.cancelUrl);
        return _open(Uri.parse(url));
      });

  /// Opens the Stripe billing portal.
  Future<bool> openStripePortal() =>
      _run(PlusActionKind.stripePortal, () async {
        final links = ref.read(plusCheckoutLinksProvider);
        final url = await ref
            .read(plusBillingApiProvider)
            .createStripePortal(links.portalReturnUrl);
        return _open(Uri.parse(url));
      });

  /// Buys the monthly package from the App Store or Play Store.
  Future<bool> purchaseMonthly() => _run(
    PlusActionKind.storePurchase,
    () async {
      final outcome = await ref.read(storePurchasesProvider).purchaseMonthly();
      if (outcome == StorePurchaseOutcome.purchased) {
        _reloadEntitlement();
        return null;
      }
      return _failureForStore(outcome);
    },
  );

  /// Restores purchases owned by the store account.
  Future<bool> restorePurchases() =>
      _run(PlusActionKind.storeRestore, () async {
        final outcome = await ref.read(storePurchasesProvider).restore();
        if (outcome == StorePurchaseOutcome.purchased) {
          _reloadEntitlement();
          return null;
        }
        return _failureForStore(outcome);
      });

  /// Opens the store's subscription management page.
  Future<bool> openStoreManagement() =>
      _run(PlusActionKind.storeManage, () async {
        final url = await ref.read(storePurchasesProvider).managementUrl();
        if (url == null) return PlusActionFailure.unavailable;
        return _open(url);
      });

  /// Connects a Solana wallet, subscribes on chain, and confirms ownership.
  Future<bool> subscribeWithSolana(BuildContext context) =>
      _run(PlusActionKind.solanaSubscribe, () async {
        await ref.read(solanaSubscribeFlowProvider).subscribe(context: context);
        _reloadEntitlement();
        return null;
      });

  /// Re-reads the entitlement after a checkout or webhook.
  Future<bool> refreshEntitlement() => _run(PlusActionKind.refresh, () async {
    ref.invalidate(plusEntitlementProvider);
    await ref.read(plusEntitlementProvider.future);
    return null;
  });

  /// Clears the last failure after the screen has shown its message.
  void clearFailure() {
    if (state.failure == null) return;
    state = state.copyWith(failure: null);
  }

  Future<bool> _run(
    PlusActionKind kind,
    Future<PlusActionFailure?> Function() action,
  ) async {
    if (state.isBusy) return false;
    state = PlusActionState(isBusy: true, running: kind);
    try {
      final failure = await action();
      if (ref.mounted) {
        state = PlusActionState(failure: failure);
      }
      return failure == null;
    } on SolanaSubscribeException catch (error) {
      final failure = switch (error.failure) {
        SolanaSubscribeFailure.walletUnavailable =>
          PlusActionFailure.unavailable,
        SolanaSubscribeFailure.walletRejected => PlusActionFailure.rejected,
        SolanaSubscribeFailure.failed => PlusActionFailure.failed,
      };
      if (ref.mounted) state = PlusActionState(failure: failure);
      return false;
    } on BillingRailUnavailableException {
      // The server has this payment method switched off.
      if (ref.mounted) {
        state = const PlusActionState(failure: PlusActionFailure.unavailable);
      }
      return false;
    } on Object catch (error, stackTrace) {
      _log.warning(
        'action.failed kind=${kind.name} error=${error.runtimeType}',
        error,
        stackTrace,
      );
      if (ref.mounted) {
        state = const PlusActionState(failure: PlusActionFailure.failed);
      }
      return false;
    }
  }

  Future<PlusActionFailure?> _open(Uri url) async {
    final opened = await ref.read(plusUrlLauncherProvider).open(url);
    return opened ? null : PlusActionFailure.failed;
  }

  PlusActionFailure? _failureForStore(StorePurchaseOutcome outcome) =>
      switch (outcome) {
        StorePurchaseOutcome.purchased => null,
        StorePurchaseOutcome.cancelled => PlusActionFailure.cancelled,
        StorePurchaseOutcome.unavailable => PlusActionFailure.unavailable,
        StorePurchaseOutcome.failed => PlusActionFailure.failed,
      };

  void _reloadEntitlement() => ref.invalidate(plusEntitlementProvider);
}
