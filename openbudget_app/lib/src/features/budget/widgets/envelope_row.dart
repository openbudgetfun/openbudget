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
    super.key,
  });

  final Envelope envelope;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final available = envelope.budgetedAmountCents - envelope.spentAmountCents;
    final availableColor = available > 0
        ? ColorTokens.secondary
        : available < 0
        ? ColorTokens.error
        : ColorTokens.tertiary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              envelope.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatCents(envelope.budgetedAmountCents, currencyCode),
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatCents(envelope.spentAmountCents, currencyCode),
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              formatCents(available, currencyCode),
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: availableColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
