import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class BudgetHeader extends HookConsumerWidget {
  const BudgetHeader({
    required this.readyToAssignCents,
    required this.currencyCode,
    super.key,
  });

  final int readyToAssignCents;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final color = readyToAssignCents > 0
        ? ColorTokens.secondary
        : readyToAssignCents < 0
            ? ColorTokens.error
            : ColorTokens.tertiary;
    final bgColor = readyToAssignCents > 0
        ? ColorTokens.secondary.withAlpha(20)
        : readyToAssignCents < 0
            ? ColorTokens.error.withAlpha(20)
            : ColorTokens.tertiary.withAlpha(20);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(80)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.budgetReadyToAssign,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color.withAlpha(200),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            formatCents(readyToAssignCents, currencyCode),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
