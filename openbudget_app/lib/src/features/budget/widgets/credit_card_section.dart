import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/credit_card_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The plan screen's credit-card section: each card's month spending and
/// what it owes, each in the card's own currency — no cross-currency total,
/// because the app never converts.
class CreditCardSection extends HookWidget {
  const CreditCardSection({required this.payments, super.key});

  final List<CreditCardPaymentInfo> payments;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    if (payments.isEmpty) return const SizedBox.shrink();

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment.account.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: palette.ink,
                          ),
                        ),
                        Text(
                          l10n.creditCardOwes(
                            formatMinorForCode(
                              payment.balanceMinor,
                              payment.account.currencyCode,
                            ),
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.mutedInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ObAmount(
                        formatMinorForCode(
                          payment.spentMinor,
                          payment.account.currencyCode,
                        ),
                        tone: ObTone.review,
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        l10n.creditCardSpentThisMonth,
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
