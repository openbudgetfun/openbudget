import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/plus/models/plus_action_state.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_actions_provider.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_entitlement_provider.dart';
import 'package:openbudget_app/src/features/plus/providers/plus_platform_provider.dart';
import 'package:openbudget_app/src/features/plus/providers/store_purchases_provider.dart';
import 'package:openbudget_app/src/features/plus/widgets/plus_benefits.dart';
import 'package:openbudget_app/src/features/plus/widgets/plus_hero.dart';
import 'package:openbudget_app/src/features/plus/widgets/plus_plan_card.dart';
import 'package:openbudget_app/src/features/plus/widgets/plus_rail_actions.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// OpenBudget Plus: the pitch, the payment rails, and the plan a person owns.
class PlusScreen extends HookConsumerWidget {
  const PlusScreen({this.status, super.key});

  /// Stripe returns to `/plus?status=success` or `/plus?status=cancel`.
  final String? status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final platform = ref.watch(plusPlatformProvider);
    final entitlementAsync = ref.watch(plusEntitlementProvider);
    final actionState = ref.watch(plusActionsProvider);
    final store = ref.watch(storePurchasesProvider);
    final actions = ref.read(plusActionsProvider.notifier);
    final failure = actionState.failure;

    useEffect(() {
      if (failure == null) return null;
      final message = _failureMessage(l10n, failure);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        showAppToast(
          context,
          message: message,
          variant: AppToastVariant.error,
        );
        actions.clearFailure();
      });
      return null;
    }, [failure]);

    useEffect(() {
      if (status == null) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        if (status == 'success') {
          showAppToast(
            context,
            message: l10n.plusCheckoutSuccess,
            variant: AppToastVariant.success,
          );
          unawaited(actions.refreshEntitlement());
        } else if (status == 'cancel') {
          showAppToast(
            context,
            message: l10n.plusCheckoutCancelled,
            variant: AppToastVariant.warning,
          );
        }
      });
      return null;
    }, [status]);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) {
              navigator.pop();
            } else {
              context.go(homePath);
            }
          },
          icon: const SkribbleIcon(data: OpenBudgetIcons.back),
        ),
        title: Text(l10n.plusTitle),
      ),
      body: entitlementAsync.when(
        loading: () => Center(child: ObLoadingPanel(label: l10n.plusLoading)),
        error: (_, _) => ListView(
          padding: const EdgeInsets.all(SpacingTokens.md),
          children: [
            ObStatePanel.problem(
              title: l10n.plusLoadError,
              message: l10n.plusLoadErrorBody,
              action: ObStateAction(
                label: l10n.plusRetry,
                onPressed: () => ref.invalidate(plusEntitlementProvider),
              ),
            ),
          ],
        ),
        data: (entitlement) => ListView(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.md,
            SpacingTokens.sm,
            SpacingTokens.md,
            SpacingTokens.xl,
          ),
          children: [
            if (entitlement == null) ...[
              const PlusHero(),
              const PlusBenefits(),
              PlusRailActions(
                platform: platform,
                storeAvailable: store.isAvailable,
                actionState: actionState,
                onStripe: () => unawaited(actions.startStripeCheckout()),
                onSolana: () => unawaited(actions.subscribeWithSolana(context)),
                onStore: () => unawaited(_purchase(context, ref)),
                onRestore: () => unawaited(_restore(context, ref)),
                onRefresh: () => unawaited(actions.refreshEntitlement()),
              ),
            ] else ...[
              PlusPlanCard(
                entitlement: entitlement,
                actionState: actionState,
                onManage: () {
                  if (entitlement.source == EntitlementSource.stripe) {
                    unawaited(actions.openStripePortal());
                  } else {
                    unawaited(actions.openStoreManagement());
                  }
                },
                onRefresh: () => unawaited(actions.refreshEntitlement()),
              ),
              const PlusBenefits(),
            ],
            const SizedBox(height: SpacingTokens.xl),
            Text(
              l10n.plusPriceCurrencyNote,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.ob.mutedInk,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final purchased = await ref
        .read(plusActionsProvider.notifier)
        .purchaseMonthly();
    if (!purchased || !context.mounted) return;
    showAppToast(
      context,
      message: l10n.plusPurchaseSuccess,
      variant: AppToastVariant.success,
    );
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final restored = await ref
        .read(plusActionsProvider.notifier)
        .restorePurchases();
    if (!restored || !context.mounted) return;
    showAppToast(
      context,
      message: l10n.plusRestoreSuccess,
      variant: AppToastVariant.success,
    );
  }

  String _failureMessage(AppLocalizations l10n, PlusActionFailure failure) =>
      switch (failure) {
        PlusActionFailure.cancelled => l10n.plusFailureCancelled,
        PlusActionFailure.rejected => l10n.plusFailureRejected,
        PlusActionFailure.unavailable => l10n.plusFailureUnavailable,
        PlusActionFailure.failed => l10n.plusFailureFailed,
      };
}
