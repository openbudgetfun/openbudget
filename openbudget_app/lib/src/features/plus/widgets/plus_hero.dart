import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The hand-drawn introduction on the free plan.
///
/// A doodled sparkle leads the eye, the price sits under a highlighter, and
/// the included assistant usage is stated in words as well as in the layout.
class PlusHero extends HookWidget {
  const PlusHero({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.plusTitle,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: palette.brand,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.plusHeroHeadline,
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              ExcludeSemantics(
                child: WiredDoodle(
                  kind: WiredDoodleKind.sparkle,
                  size: 68,
                  seed: 5,
                  color: palette.brand,
                  fillColor: palette.brandWash,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            l10n.plusHeroBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.mutedInk,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ObHighlighter(
                seed: 9,
                child: Text(
                  l10n.plusPriceAmount,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: palette.ink,
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  l10n.plusPricePeriod,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            l10n.plusPriceNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md,
              vertical: SpacingTokens.sm,
            ),
            decoration: ObRoughDecoration(
              color: palette.wash(ObTone.funded),
              outline: palette.quietPen,
              radius: RadiusTokens.lg,
              seed: 17,
            ),
            child: Row(
              children: [
                SkribbleIcon(
                  data: OpenBudgetIcons.sparkle,
                  size: 18,
                  color: palette.hue(ObTone.funded),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    l10n.plusIncludedUsage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
