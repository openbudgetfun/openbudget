import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// One "what we could not verify" entry: a plain sentence about a figure the
/// data cannot fully stand behind.
class TaxCaveatCard extends HookWidget {
  const TaxCaveatCard({required this.text, this.announced = false, super.key});

  final String text;

  /// Whether the caveat is a change that is announced but not yet law.
  final bool announced;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ObCard(
      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkribbleIcon(
            data: OpenBudgetIcons.warning,
            size: 20,
            color: palette.mutedInk,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.ink,
                  ),
                ),
                if (announced) ...[
                  const SizedBox(height: SpacingTokens.xs),
                  ObToneChip(
                    key: const Key('tax-announced-badge'),
                    label: l10n.taxAnnouncedBadge,
                    tone: ObTone.review,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
