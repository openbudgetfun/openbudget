import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class CreditCardSection extends HookWidget {
  const CreditCardSection({
    required this.payments,
    required this.currencyCode,
    super.key,
  });

  final List<CreditCardPaymentInfo> payments;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (payments.isEmpty) return const SizedBox.shrink();

    final totalPayment = payments.fold<int>(
      0,
      (sum, p) => sum + p.paymentCents,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.credit_card_rounded,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    l10n.creditCardPaymentsTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  formatCents(totalPayment, currencyCode),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            ...payments.map(
              (payment) => Padding(
                padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
                child: Row(
                  children: [
                    const SizedBox(width: SpacingTokens.lg),
                    Expanded(
                      child: Text(
                        payment.account.name,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          formatCents(payment.paymentCents, currencyCode),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.error,
                          ),
                        ),
                        Text(
                          '${l10n.creditCardSpentThisMonth}: ${formatCents(payment.spentCents, currencyCode)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
