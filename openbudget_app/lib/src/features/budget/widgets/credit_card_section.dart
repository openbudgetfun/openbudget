import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class CreditCardSection extends HookWidget {
  const CreditCardSection({
    required this.payments,
    required this.currencyCode,
    super.key,
  });

  final List<CreditCardPaymentInfo> payments;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    if (payments.isEmpty) return const SizedBox.shrink();

    final totalPayment = payments.fold<int>(
      0,
      (sum, p) => sum + p.paymentCents,
    );

    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkribbleIcon(
                data: OpenBudgetIcons.creditCard,
                size: 20,
                color: palette.review,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  l10n.creditCardPaymentsTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: palette.ink,
                  ),
                ),
              ),
              ObAmount(
                formatCentsForCode(totalPayment, currencyCode),
                tone: ObTone.review,
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          ...payments.map(
            (payment) => Padding(
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
              child: Row(
                children: [
                  SkribbleIcon(
                    data: OpenBudgetIcons.payment,
                    size: 16,
                    color: palette.mutedInk,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Text(
                      payment.account.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.ink,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ObAmount(
                        formatCentsForCode(payment.paymentCents, currencyCode),
                        tone: ObTone.review,
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '${l10n.creditCardSpentThisMonth}: '
                        '${formatCentsForCode(payment.spentCents, currencyCode)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.mutedInk,
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
    );
  }
}
