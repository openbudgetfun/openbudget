import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/age_of_money_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/auto_assign_dialog.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class BudgetHeader extends HookConsumerWidget {
  const BudgetHeader({
    required this.readyToAssignMinor,
    required this.currencyCode,
    required this.entityId,
    required this.year,
    required this.month,
    this.totalOverspentMinor = 0,
    this.totalIncomeMinor = 0,
    this.totalBudgetedMinor = 0,
    this.totalActivityMinor = 0,
    this.onCopyLastMonth,
    super.key,
  });

  final int readyToAssignMinor;
  final String currencyCode;
  final String entityId;
  final int year;
  final int month;
  final int totalOverspentMinor;
  final int totalIncomeMinor;
  final int totalBudgetedMinor;
  final int totalActivityMinor;
  final VoidCallback? onCopyLastMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final ageOfMoneyAsync = ref.watch(ageOfMoneyProvider(entityId));
    final hideAmounts = ref.watch(hideAmountsProvider);
    final now = DateTime.now();
    final isCurrentMonth = year == now.year && month == now.month;
    final isOverspent = readyToAssignMinor < 0;
    final materialLocalizations = MaterialLocalizations.of(context);

    return ObCard(
      // The month's header is the screen's one sticker.
      raised: true,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: ObRoughDecoration(
              color: palette.highlight,
              radius: 10,
              seed: 23,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.xs,
              vertical: SpacingTokens.xs,
            ),
            child: Row(
              children: [
                IconButton(
                  key: const Key('budget-month-previous'),
                  icon: SkribbleIcon(
                    data: OpenBudgetIcons.chevronLeft,
                    color: palette.ink,
                  ),
                  tooltip: materialLocalizations.previousMonthTooltip,
                  onPressed: () => ref
                      .read(selectedMonthProvider(entityId).notifier)
                      .goToPreviousMonth(),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: isCurrentMonth
                        ? null
                        : () => ref
                              .read(selectedMonthProvider(entityId).notifier)
                              .setMonth(now.year, now.month),
                    onLongPress: () => _showMonthPicker(context, ref, l10n),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.xs,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              '${_localizedMonth(l10n, month)} $year',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: palette.ink,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          if (!isCurrentMonth)
                            Text(
                              l10n.budgetGoToToday,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: palette.brand,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('budget-month-next'),
                  icon: SkribbleIcon(
                    data: OpenBudgetIcons.chevronRight,
                    color: palette.ink,
                  ),
                  tooltip: materialLocalizations.nextMonthTooltip,
                  onPressed: () => ref
                      .read(selectedMonthProvider(entityId).notifier)
                      .goToNextMonth(),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.budgetReadyToAssign,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.mutedInk,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                ObAmount(
                  hideAmounts
                      ? hiddenAmountPlaceholder
                      : formatMinorForCode(readyToAssignMinor, currencyCode),
                  highlighted: !isOverspent,
                  tone: isOverspent ? ObTone.overspent : ObTone.neutral,
                  style: theme.textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          if (totalIncomeMinor != 0 ||
              totalBudgetedMinor != 0 ||
              totalActivityMinor != 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.sm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SummaryColumn(
                      label: l10n.budgetTotalIncome,
                      value: hideAmounts
                          ? hiddenAmountPlaceholder
                          : formatMinorForCode(totalIncomeMinor, currencyCode),
                      tone: ObTone.funded,
                    ),
                  ),
                  Expanded(
                    child: _SummaryColumn(
                      label: l10n.budgetTotalBudgeted,
                      value: hideAmounts
                          ? hiddenAmountPlaceholder
                          : formatMinorForCode(
                              totalBudgetedMinor,
                              currencyCode,
                            ),
                    ),
                  ),
                  Expanded(
                    child: _SummaryColumn(
                      label: l10n.budgetTotalActivity,
                      value: hideAmounts
                          ? hiddenAmountPlaceholder
                          : formatMinorForCode(
                              -totalActivityMinor,
                              currencyCode,
                            ),
                      tone: totalActivityMinor > 0
                          ? ObTone.overspent
                          : ObTone.funded,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (totalOverspentMinor > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                SpacingTokens.xs,
                SpacingTokens.md,
                0,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.sm,
                  vertical: SpacingTokens.xs,
                ),
                decoration: ObRoughDecoration(
                  color: palette.overspentWash,
                  radius: 10,
                  seed: 29,
                ),
                child: Row(
                  children: [
                    SkribbleIcon(
                      data: OpenBudgetIcons.warning,
                      size: 16,
                      color: palette.overspent,
                    ),
                    const SizedBox(width: SpacingTokens.xs),
                    Flexible(
                      child: Text(
                        l10n.budgetOverspentWarning(
                          hideAmounts
                              ? hiddenAmountPlaceholder
                              : formatMinorForCode(
                                  totalOverspentMinor,
                                  currencyCode,
                                ),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.sm,
              SpacingTokens.md,
              SpacingTokens.sm,
            ),
            child: Wrap(
              spacing: SpacingTokens.sm,
              runSpacing: SpacingTokens.xs,
              children: [
                if (readyToAssignMinor > 0)
                  FilledButton.icon(
                    onPressed: () => _showAutoAssignDialog(context),
                    icon: SkribbleIcon(
                      data: OpenBudgetIcons.autoAssign,
                      size: 18,
                      color: palette.onAction,
                    ),
                    label: Text(l10n.budgetAssignMoney),
                  ),
                if (onCopyLastMonth != null)
                  OutlinedButton.icon(
                    onPressed: onCopyLastMonth,
                    icon: SkribbleIcon(
                      data: OpenBudgetIcons.copy,
                      size: 18,
                      color: palette.brand,
                    ),
                    label: Text(l10n.budgetCopyLastMonth),
                  ),
              ],
            ),
          ),
          if (ageOfMoneyAsync.hasValue && ageOfMoneyAsync.value != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                0,
                SpacingTokens.md,
                SpacingTokens.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkribbleIcon(
                    data: OpenBudgetIcons.ageOfMoney,
                    size: 16,
                    color: palette.mutedInk,
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Text(
                    l10n.ageOfMoneyLabel(ageOfMoneyAsync.value!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                ],
              ),
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
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) =>
            AutoAssignDialog(entityId: entityId, currencyCode: currencyCode),
      ),
    );
  }

  void _showMonthPicker(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final now = DateTime.now();
    unawaited(
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
                .read(selectedMonthProvider(entityId).notifier)
                .setMonth(selectedYear, selectedMonth);
            Navigator.of(ctx).pop();
          },
        ),
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
    final palette = theme.ob;
    final materialLocalizations = MaterialLocalizations.of(context);
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
                  key: const Key('budget-month-picker-previous'),
                  icon: SkribbleIcon(
                    data: OpenBudgetIcons.chevronLeft,
                    color: palette.ink,
                  ),
                  tooltip: materialLocalizations.previousMonthTooltip,
                  onPressed: () => displayYear.value--,
                ),
                Text(
                  '${displayYear.value}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: palette.ink,
                  ),
                ),
                IconButton(
                  key: const Key('budget-month-picker-next'),
                  icon: SkribbleIcon(
                    data: OpenBudgetIcons.chevronRight,
                    color: palette.ink,
                  ),
                  tooltip: materialLocalizations.nextMonthTooltip,
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

                return Semantics(
                  selected: isSelected,
                  button: true,
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onSelect(displayYear.value, m),
                      child: DecoratedBox(
                        decoration: ObRoughDecoration(
                          color: isSelected || isToday
                              ? palette.highlight
                              : null,
                          outline: isSelected
                              ? palette.brand
                              : isToday
                              ? palette.quietPen
                              : palette.line,
                          radius: 8,
                          strokeWidth: 1.4,
                          seed: 37,
                        ),
                        child: Center(
                          child: Text(
                            months[index].substring(0, 3),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: palette.ink,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
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
    this.tone = ObTone.neutral,
  });

  final String label;
  final String value;
  final ObTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: palette.mutedInk,
          ),
        ),
        const SizedBox(height: 2),
        ObAmount(
          value,
          tone: tone,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
