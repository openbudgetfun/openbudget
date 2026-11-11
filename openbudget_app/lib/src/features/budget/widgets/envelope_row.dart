import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_goals_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// One envelope row of the plan list. Every figure comes from the server's
/// [EnvelopeMonthView]; the envelope itself only supplies identity.
class EnvelopeRow extends HookConsumerWidget {
  const EnvelopeRow({
    required this.monthEnvelope,
    required this.currencyCode,
    required this.onTap,
    required this.onLongPress,
    this.onQuickBudget,
    this.hideAmounts = false,
    this.hideProgressBars = false,
    this.isSelected = false,
    super.key,
  });

  final EnvelopeMonthView monthEnvelope;
  final String currencyCode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onQuickBudget;
  final bool hideAmounts;
  final bool hideProgressBars;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final theme = Theme.of(context);
    final envelope = monthEnvelope.envelope;

    final allocated = monthEnvelope.allocatedMinor;
    final spent = monthEnvelope.activityMinor.abs();
    final available = monthEnvelope.availableMinor;
    final carryover = monthEnvelope.carryoverMinor;
    final goal = monthEnvelope.goal;
    final balanceStyle = ref.watch(balanceStyleProvider);
    final isOverspent = available < 0;
    final amountTone = isOverspent
        ? ObTone.overspent
        : available > 0
        ? ObTone.funded
        : ObTone.neutral;
    final shouldDifferentiateWithoutColor =
        balanceStyle == BalanceStyle.differentiateWithoutColor &&
        available != 0;

    final presentation = goalPresentation(monthEnvelope: monthEnvelope);
    final fraction = goal != null
        ? presentation.progress
        : allocated <= 0
        ? 0.0
        : (spent / allocated).clamp(0.0, 1.0);
    final progressPercent = (fraction * 100).round();
    final underfunded = presentation.underfundedMinor;
    final (statusLabel, statusTone) = isOverspent
        ? (l10n.budgetStatusOverspent, ObTone.overspent)
        : goal != null && underfunded > 0
        ? (l10n.budgetStatusUnderfunded, ObTone.underfunded)
        : (l10n.budgetStatusFunded, ObTone.funded);

    return DecoratedBox(
      decoration: ObRoughDecoration(
        color: isSelected ? palette.highlight : null,
        outline: isSelected ? palette.brand : null,
        radius: 10,
        seed: 13,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.sm,
              vertical: SpacingTokens.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!hideProgressBars)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: ObEnvelopeGauge(
                      fraction: fraction,
                      semanticLabel: l10n.budgetEnvelopeProgress(
                        progressPercent,
                      ),
                      overspent: isOverspent,
                      width: 38,
                      seed: envelope.sortOrder + 1,
                    ),
                  ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              envelope.name,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: envelope.isHidden
                                    ? palette.mutedInk
                                    : palette.ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (carryover != 0) ...[
                            const SizedBox(width: SpacingTokens.xs),
                            Tooltip(
                              message: l10n.envelopeCarryover(
                                hideAmounts
                                    ? hiddenAmountPlaceholder
                                    : formatMinorForCode(
                                        carryover,
                                        currencyCode,
                                      ),
                              ),
                              child: SkribbleIcon(
                                data: carryover > 0
                                    ? OpenBudgetIcons.inflow
                                    : OpenBudgetIcons.outflow,
                                size: 14,
                                color: carryover > 0
                                    ? palette.funded
                                    : palette.overspent,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (envelope.note != null &&
                          envelope.note!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            SkribbleIcon(
                              data: OpenBudgetIcons.note,
                              size: 13,
                              color: palette.mutedInk,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                envelope.note!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: palette.mutedInk,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (!hideProgressBars && goal != null) ...[
                        const SizedBox(height: 4),
                        if (underfunded > 0)
                          Row(
                            children: [
                              SkribbleIcon(
                                data: OpenBudgetIcons.warning,
                                size: 14,
                                color: palette.underfunded,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  l10n.envelopeUnderfunded(
                                    hideAmounts
                                        ? hiddenAmountPlaceholder
                                        : formatMinorForCode(
                                            underfunded,
                                            currencyCode,
                                          ),
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: palette.underfunded,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          ObToneChip(
                            label: l10n.categoryDetailTargetMet,
                            tone: ObTone.funded,
                            icon: SkribbleIcon(
                              data: OpenBudgetIcons.check,
                              size: 14,
                              color: palette.funded,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (shouldDifferentiateWithoutColor) ...[
                          SkribbleIcon(
                            data: isOverspent
                                ? OpenBudgetIcons.remove
                                : OpenBudgetIcons.add,
                            size: 14,
                            color: palette.hue(amountTone),
                          ),
                          const SizedBox(width: 2),
                        ],
                        ObAmount(
                          hideAmounts
                              ? hiddenAmountPlaceholder
                              : formatMinorForCode(available, currencyCode),
                          tone: amountTone,
                          style: theme.textTheme.titleSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ObToneChip(label: statusLabel, tone: statusTone),
                  ],
                ),
                if (onQuickBudget != null) ...[
                  const SizedBox(width: 2),
                  IconButton(
                    onPressed: onQuickBudget,
                    tooltip: l10n.quickBudgetTitle,
                    icon: SkribbleIcon(
                      data: OpenBudgetIcons.quick,
                      size: 20,
                      color: palette.brand,
                    ),
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
