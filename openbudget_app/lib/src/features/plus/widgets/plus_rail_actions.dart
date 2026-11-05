import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/plus/models/plus_action_state.dart';
import 'package:openbudget_app/src/features/plus/models/plus_platform.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The payment choices for the current platform.
///
/// Each rail is one full-width button with a plain-language note. A rail that
/// is not configured stays visible as a disabled button so the person knows
/// why it is missing, and the screen never crashes on an empty build key.
class PlusRailActions extends HookWidget {
  const PlusRailActions({
    required this.platform,
    required this.storeAvailable,
    required this.actionState,
    required this.onStripe,
    required this.onSolana,
    required this.onStore,
    required this.onRestore,
    required this.onRefresh,
    super.key,
  });

  final PlusPlatform platform;
  final bool storeAvailable;
  final PlusActionState actionState;
  final VoidCallback onStripe;
  final VoidCallback onSolana;
  final VoidCallback onStore;
  final VoidCallback onRestore;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final rails = plusRailsFor(platform);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ObSectionHeader(
          title: l10n.plusChooseRail,
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.xs,
            SpacingTokens.lg,
            SpacingTokens.xs,
            SpacingTokens.sm,
          ),
        ),
        ObCard(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final rail in rails) ...[
                _railButton(context, rail),
                if (rail != rails.last)
                  const SizedBox(height: SpacingTokens.sm),
              ],
              if (platform == PlusPlatform.ios ||
                  platform == PlusPlatform.android) ...[
                if (!storeAvailable) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    l10n.plusStoreUnavailable,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    l10n.plusStoreHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ObTextButton(
                      onPressed: actionState.isBusy ? null : onRestore,
                      child: Text(l10n.plusRestorePurchases),
                    ),
                  ),
                ],
              ],
              if (_isDesktop) ...[
                const SizedBox(height: SpacingTokens.md),
                SizedBox(
                  width: double.infinity,
                  child: ObOutlinedButton(
                    onPressed: actionState.isBusy ? null : onRefresh,
                    child: Text(l10n.plusRefreshButton),
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  l10n.plusRefreshNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  bool get _isDesktop =>
      platform == PlusPlatform.macos ||
      platform == PlusPlatform.windows ||
      platform == PlusPlatform.linux;

  Widget _railButton(BuildContext context, PlusRail rail) {
    final l10n = AppLocalizations.of(context);

    return switch (rail) {
      PlusRail.stripe => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _button(
            context,
            label: l10n.plusStripeButton,
            kind: PlusActionKind.stripeCheckout,
            onPressed: onStripe,
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            l10n.plusStripeNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).ob.mutedInk,
            ),
          ),
        ],
      ),
      PlusRail.solana => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _button(
            context,
            label: l10n.plusSolanaButton,
            kind: PlusActionKind.solanaSubscribe,
            onPressed: onSolana,
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            l10n.plusSolanaNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).ob.mutedInk,
            ),
          ),
        ],
      ),
      PlusRail.store => _button(
        context,
        label: platform == PlusPlatform.ios
            ? l10n.plusStoreAppleButton
            : l10n.plusStoreGoogleButton,
        kind: PlusActionKind.storePurchase,
        onPressed: storeAvailable ? onStore : null,
      ),
    };
  }

  Widget _button(
    BuildContext context, {
    required String label,
    required PlusActionKind kind,
    required VoidCallback? onPressed,
  }) => SizedBox(
    width: double.infinity,
    child: ObFilledButton(
      onPressed: actionState.isBusy ? null : onPressed,
      isLoading: actionState.isBusy && actionState.running == kind,
      loadingLabel: AppLocalizations.of(context).plusLoading,
      child: Text(label),
    ),
  );
}
