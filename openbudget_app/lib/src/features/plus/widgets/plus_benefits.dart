import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The three things OpenBudget Plus adds, in plain language.
class PlusBenefits extends HookWidget {
  const PlusBenefits({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ObSectionHeader(
          title: l10n.plusBenefitsTitle,
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.xs,
            SpacingTokens.lg,
            SpacingTokens.xs,
            SpacingTokens.sm,
          ),
        ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _BenefitRow(
                icon: OpenBudgetIcons.receipt,
                tone: ObTone.funded,
                title: l10n.plusBenefitTaxTitle,
                body: l10n.plusBenefitTaxBody,
              ),
              const Divider(height: 1),
              _BenefitRow(
                icon: OpenBudgetIcons.brain,
                tone: ObTone.brand,
                title: l10n.plusBenefitAssistantTitle,
                body: l10n.plusBenefitAssistantBody,
              ),
              const Divider(height: 1),
              _BenefitRow(
                icon: OpenBudgetIcons.network,
                tone: ObTone.review,
                title: l10n.plusBenefitAgentTitle,
                body: l10n.plusBenefitAgentBody,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BenefitRow extends HookWidget {
  const _BenefitRow({
    required this.icon,
    required this.tone,
    required this.title,
    required this.body,
  });

  final WiredSvgIconData icon;
  final ObTone tone;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;

    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: ObRoughDecoration(
              color: palette.wash(tone),
              outline: palette.quietPen,
              seed: 31,
            ),
            child: SkribbleIcon(
              data: icon,
              size: 22,
              color: palette.hue(tone),
            ),
          ),
          const SizedBox(width: SpacingTokens.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
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
