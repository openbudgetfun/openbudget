import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/age_of_money_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/auto_assign_dialog.dart';
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
    this.totalOverspentCents = 0,
    this.totalIncomeCents = 0,
    this.totalBudgetedCents = 0,
    this.totalActivityCents = 0,
    this.onCopyLastMonth,
    super.key,
  });

  final int readyToAssignCents;
  final CurrencyCode currencyCode;
  final String budgetId;
  final int year;
  final int month;
  final int totalOverspentCents;
  final int totalIncomeCents;
  final int totalBudgetedCents;
  final int totalActivityCents;
  final VoidCallback? onCopyLastMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ageOfMoneyAsync = ref.watch(ageOfMoneyProvider(budgetId));
    final now = DateTime.now();
    final isCurrentMonth = year == now.year && month == now.month;
    final color = readyToAssignCents > 0
        ? ColorTokens.secondary
        : readyToAssignCents < 0
        ? ColorTokens.error
        : ColorTokens.tertiary;
    final bgColor = readyToAssignCents > 0
        ? ColorTokens.secondary.withAlpha(30)
        : readyToAssignCents < 0
        ? ColorTokens.error.withAlpha(20)
        : ColorTokens.tertiary.withAlpha(20);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(RadiusTokens.xl),
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
              GestureDetector(
                onTap: isCurrentMonth
                    ? null
                    : () => ref
                          .read(selectedMonthProvider(budgetId).notifier)
                          .setMonth(now.year, now.month),
                onLongPress: () => _showMonthPicker(context, ref, l10n),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.sm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_localizedMonth(l10n, month)} $year',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!isCurrentMonth)
                        Text(
                          l10n.budgetGoToToday,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
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
            style: theme.textTheme.headlineLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (totalIncomeCents != 0 ||
              totalBudgetedCents != 0 ||
              totalActivityCents != 0) ...[
            const SizedBox(height: SpacingTokens.sm),
            Divider(color: color.withAlpha(40), height: 1),
            const SizedBox(height: SpacingTokens.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SummaryColumn(
                  label: l10n.budgetTotalIncome,
                  value: formatCents(totalIncomeCents, currencyCode),
                  valueColor: ColorTokens.secondary,
                  theme: theme,
                ),
                _SummaryColumn(
                  label: l10n.budgetTotalBudgeted,
                  value: formatCents(totalBudgetedCents, currencyCode),
                  theme: theme,
                ),
                _SummaryColumn(
                  label: l10n.budgetTotalActivity,
                  value: formatCents(-totalActivityCents, currencyCode),
                  valueColor: totalActivityCents > 0 ? ColorTokens.error : null,
                  theme: theme,
                ),
              ],
            ),
          ],
          if (totalOverspentCents > 0) ...[
            const SizedBox(height: SpacingTokens.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.sm,
                vertical: SpacingTokens.xs,
              ),
              decoration: BoxDecoration(
                color: ColorTokens.error.withAlpha(20),
                borderRadius: BorderRadius.circular(RadiusTokens.sm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: ColorTokens.error,
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Text(
                    l10n.budgetOverspentWarning(
                      formatCents(totalOverspentCents, currencyCode),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ColorTokens.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (readyToAssignCents > 0) ...[
            const SizedBox(height: SpacingTokens.md),
            FilledButton.icon(
              onPressed: () => _showAutoAssignDialog(context),
              icon: const Icon(Icons.auto_fix_high_rounded, size: 18),
              label: Text(l10n.budgetAssignMoney),
              style: FilledButton.styleFrom(
                backgroundColor: ColorTokens.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.lg,
                  vertical: SpacingTokens.sm,
                ),
                textStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          if (onCopyLastMonth != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            OutlinedButton.icon(
              onPressed: onCopyLastMonth,
              icon: const Icon(Icons.content_copy_rounded, size: 16),
              label: Text(l10n.budgetCopyLastMonth),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.xs,
                ),
                minimumSize: Size.zero,
                textStyle: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (ageOfMoneyAsync.hasValue && ageOfMoneyAsync.value != null) ...[
            const SizedBox(height: SpacingTokens.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_bottom_rounded,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: SpacingTokens.xs),
                Text(
                  l10n.ageOfMoneyLabel(ageOfMoneyAsync.value!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _localizedMonth(AppLocalizations l10n, int month) => switch (month) {
    1 => l10n.budgetMonthJanuary,
    2 => l10n.budgetMonthFebruary,
    3 => l10n.budgetMonthMarch,
    4 => l10n.budgetMonthApril,
    5 => l10n.budgetMonthMay,
    6 => l10n.budgetMonthJune,
    7 => l10n.budgetMonthJuly,
    8 => l10n.budgetMonthAugust,
    9 => l10n.budgetMonthSeptember,
    10 => l10n.budgetMonthOctober,
    11 => l10n.budgetMonthNovember,
    12 => l10n.budgetMonthDecember,
    _ => '',
  };

  void _showAutoAssignDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) =>
          AutoAssignDialog(budgetId: budgetId, currencyCode: currencyCode),
    );
  }

  void _showMonthPicker(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    showDialog<void>(
      context: context,
      builder: (ctx) => _MonthPickerDialog(
        currentYear: year,
        currentMonth: month,
        todayYear: now.year,
        todayMonth: now.month,
        l10n: l10n,
        onSelect: (selectedYear, selectedMonth) {
          ref
              .read(selectedMonthProvider(budgetId).notifier)
              .setMonth(selectedYear, selectedMonth);
          Navigator.of(ctx).pop();
        },
      ),
    );
  }
}

class _MonthPickerDialog extends HookWidget {
  const _MonthPickerDialog({
    required this.currentYear,
    required this.currentMonth,
    required this.todayYear,
    required this.todayMonth,
    required this.l10n,
    required this.onSelect,
  });

  final int currentYear;
  final int currentMonth;
  final int todayYear;
  final int todayMonth;
  final AppLocalizations l10n;
  final void Function(int year, int month) onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayYear = useState(currentYear);

    final months = [
      l10n.budgetMonthJanuary,
      l10n.budgetMonthFebruary,
      l10n.budgetMonthMarch,
      l10n.budgetMonthApril,
      l10n.budgetMonthMay,
      l10n.budgetMonthJune,
      l10n.budgetMonthJuly,
      l10n.budgetMonthAugust,
      l10n.budgetMonthSeptember,
      l10n.budgetMonthOctober,
      l10n.budgetMonthNovember,
      l10n.budgetMonthDecember,
    ];

    return AlertDialog(
      title: Text(l10n.budgetMonthPickerTitle),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => displayYear.value--,
                ),
                Text(
                  '${displayYear.value}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => displayYear.value++,
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.2,
                crossAxisSpacing: SpacingTokens.xs,
                mainAxisSpacing: SpacingTokens.xs,
              ),
              itemCount: 12,
              itemBuilder: (ctx, index) {
                final m = index + 1;
                final isSelected =
                    displayYear.value == currentYear && m == currentMonth;
                final isToday =
                    displayYear.value == todayYear && m == todayMonth;

                return Material(
                  color: isSelected
                      ? colorScheme.primary
                      : isToday
                      ? colorScheme.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(RadiusTokens.sm),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(RadiusTokens.sm),
                    onTap: () => onSelect(displayYear.value, m),
                    child: Center(
                      child: Text(
                        months[index].substring(0, 3),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : isToday
                              ? colorScheme.primary
                              : null,
                          fontWeight: isSelected || isToday
                              ? FontWeight.w600
                              : null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
      ],
    );
  }
}

class _SummaryColumn extends HookWidget {
  const _SummaryColumn({
    required this.label,
    required this.value,
    required this.theme,
    this.valueColor,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
