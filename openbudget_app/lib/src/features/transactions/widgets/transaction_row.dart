import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// One transaction in a list: status glyph, description, payee and
/// envelope, the amount in the account's currency plus the base amount
/// when the two differ.
class TransactionRow extends HookWidget {
  const TransactionRow({
    required this.view,
    required this.currencyCode,
    this.baseCurrencyCode,
    this.detailLine,
    this.dateLabel,
    this.onOpen,
    super.key,
  });

  final TransactionView view;
  final String currencyCode;

  /// The entity's base currency; when it differs from [currencyCode] the
  /// row shows the server-computed base amount under the native one.
  final String? baseCurrencyCode;
  final String? detailLine;
  final String? dateLabel;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final transaction = view.transaction;
    final amount = transaction.amountMinor;
    final isInflow = amount > 0;
    final status = transaction.status;
    final statusIcon = switch (status) {
      TransactionStatus.reconciled => OpenBudgetIcons.lock,
      TransactionStatus.cleared => OpenBudgetIcons.checkCircle,
      TransactionStatus.uncleared => OpenBudgetIcons.circle,
    };
    final statusTone = switch (status) {
      TransactionStatus.reconciled => ObTone.brand,
      TransactionStatus.cleared => ObTone.funded,
      TransactionStatus.uncleared => ObTone.neutral,
    };
    final detail = detailLine ?? view.payeeName ?? '';
    final showBase =
        baseCurrencyCode != null &&
        baseCurrencyCode != currencyCode &&
        transaction.baseAmountMinor != amount;

    return ObCard(
      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
      onTap: onOpen,
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      child: Row(
        children: [
          SkribbleIcon(
            data: statusIcon,
            size: 18,
            color: palette.hue(statusTone),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: palette.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.mutedInk,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  dateLabel ?? _formatDate(transaction.date, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
                if (view.transferPeer != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SkribbleIcon(
                        data: OpenBudgetIcons.transfer,
                        size: 12,
                        color: palette.mutedInk,
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                      Flexible(
                        child: Text(
                          l10n.transactionTransferPeer(
                            view.transferPeer!.accountName,
                          ),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.mutedInk,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (showBase) ...[
                  const SizedBox(height: 2),
                  Text(
                    l10n.transactionBaseAmount(
                      formatMinorForCode(
                        transaction.baseAmountMinor,
                        baseCurrencyCode!,
                      ),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          ObAmount(
            formatMinorForCode(amount, currencyCode),
            tone: isInflow ? ObTone.funded : ObTone.overspent,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date, AppLocalizations l10n) =>
      l10n.transactionDateLabel(
        date.year,
        date.month,
        date.day,
      );
}
