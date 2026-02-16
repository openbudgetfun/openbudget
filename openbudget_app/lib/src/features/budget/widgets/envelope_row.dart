import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class EnvelopeRow extends HookConsumerWidget {
  const EnvelopeRow({
    required this.envelope,
    required this.currencyCode,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final Envelope envelope;
  final CurrencyCode currencyCode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = envelope.budgetedAmountCents - envelope.spentAmountCents;
    final availableColor = available > 0
        ? ColorTokens.secondary
        : available < 0
        ? ColorTokens.error
        : ColorTokens.tertiary;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm + SpacingTokens.xs,
          vertical: SpacingTokens.sm,
        ),
        child: Row(
          children: [
            const SizedBox(width: SpacingTokens.xs),
            Expanded(
              flex: 4,
              child: Text(
                envelope.name,
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                formatCents(envelope.budgetedAmountCents, currencyCode),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                formatCents(envelope.spentAmountCents, currencyCode),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: envelope.spentAmountCents > 0
                      ? ColorTokens.error
                      : null,
                ),
              ),
            ),
            const SizedBox(width: SpacingTokens.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: availableColor.withAlpha(25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                formatCents(available, currencyCode),
                maxLines: 1,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: availableColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
