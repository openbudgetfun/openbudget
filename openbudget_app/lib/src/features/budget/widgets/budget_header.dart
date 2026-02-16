import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class BudgetHeader extends HookConsumerWidget {
  const BudgetHeader({
    required this.readyToAssignCents,
    required this.currencyCode,
    required this.budgetId,
    required this.year,
    required this.month,
    super.key,
  });

  final int readyToAssignCents;
  final CurrencyCode currencyCode;
  final String budgetId;
  final int year;
  final int month;

  static const _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: color.withAlpha(80)),
      ),
      padding: const EdgeInsets.symmetric(
        vertical: SpacingTokens.lg - 4,
        horizontal: SpacingTokens.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => ref
                    .read(selectedMonthProvider(budgetId).notifier)
                    .goToPreviousMonth(),
                iconSize: 28,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.sm,
                ),
                child: Text(
                  '${_monthNames[month - 1]} $year',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => ref
                    .read(selectedMonthProvider(budgetId).notifier)
                    .goToNextMonth(),
                iconSize: 28,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            l10n.budgetReadyToAssign,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color.withAlpha(200),
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            formatCents(readyToAssignCents, currencyCode),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
