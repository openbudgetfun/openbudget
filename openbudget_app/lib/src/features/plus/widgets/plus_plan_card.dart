import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/plus/models/plus_action_state.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The plan the person already owns.
///
/// The status word carries the meaning and the tone only reinforces it. The
/// manage action matches the rail: a Stripe portal, the store's own page, or
/// a plain explanation that a Solana subscription lives in the wallet.
class PlusPlanCard extends HookWidget {
  const PlusPlanCard({
    required this.entitlement,
    required this.actionState,
    required this.onManage,
    required this.onRefresh,
    super.key,
  });

  final Entitlement entitlement;
  final PlusActionState actionState;
  final VoidCallback onManage;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final status = entitlement.status;
    final source = entitlement.source;
    final isSolana = source == EntitlementSource.solana;
    final isManaging =
        actionState.isBusy &&
        (actionState.running == PlusActionKind.stripePortal ||
            actionState.running == PlusActionKind.storeManage);

    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: ObRoughDecoration(
                  color: palette.wash(_statusTone(status)),
                  outline: palette.quietPen,
                  seed: 41,
                ),
                child: SkribbleIcon(
                  data: OpenBudgetIcons.sparkle,
                  size: 24,
                  color: palette.hue(_statusTone(status)),
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.plusPlanTitle,
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.plusSource(_sourceLabel(l10n, source)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              ObToneChip(
                label: _statusLabel(l10n, status),
                tone: _statusTone(status),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            _dateLabel(l10n, status, entitlement.currentPeriodEnd),
            style: theme.textTheme.titleMedium?.copyWith(color: palette.ink),
          ),
          if (isSolana) ...[
            const SizedBox(height: SpacingTokens.sm),
            Text(
              l10n.plusManageSolanaBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.mutedInk,
              ),
            ),
          ],
          const SizedBox(height: SpacingTokens.lg),
          Wrap(
            spacing: SpacingTokens.sm,
            runSpacing: SpacingTokens.sm,
            children: [
              if (!isSolana)
                ObFilledButton(
                  onPressed: actionState.isBusy ? null : onManage,
                  isLoading: isManaging,
                  loadingLabel: l10n.plusLoading,
                  child: Text(l10n.plusManage),
                ),
              ObOutlinedButton(
                onPressed: actionState.isBusy ? null : onRefresh,
                child: Text(l10n.plusRefreshButton),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ObTone _statusTone(EntitlementStatus status) => switch (status) {
    EntitlementStatus.active => ObTone.funded,
    EntitlementStatus.pastDue => ObTone.underfunded,
    EntitlementStatus.canceled => ObTone.review,
    EntitlementStatus.expired => ObTone.overspent,
  };

  String _statusLabel(AppLocalizations l10n, EntitlementStatus status) =>
      switch (status) {
        EntitlementStatus.active => l10n.plusStatusActive,
        EntitlementStatus.pastDue => l10n.plusStatusPastDue,
        EntitlementStatus.canceled => l10n.plusStatusCanceled,
        EntitlementStatus.expired => l10n.plusStatusExpired,
      };

  String _sourceLabel(AppLocalizations l10n, EntitlementSource source) =>
      switch (source) {
        EntitlementSource.stripe => l10n.plusSourceStripe,
        EntitlementSource.appStore => l10n.plusSourceAppStore,
        EntitlementSource.playStore => l10n.plusSourcePlayStore,
        EntitlementSource.solana => l10n.plusSourceSolana,
      };

  String _dateLabel(
    AppLocalizations l10n,
    EntitlementStatus status,
    DateTime periodEnd,
  ) {
    final date = DateFormat.yMMMMd().format(periodEnd.toLocal());
    return switch (status) {
      EntitlementStatus.active => l10n.plusRenewsOn(date),
      EntitlementStatus.pastDue => l10n.plusRenewsOn(date),
      EntitlementStatus.canceled => l10n.plusEndsOn(date),
      EntitlementStatus.expired => l10n.plusEndedOn(date),
    };
  }
}
