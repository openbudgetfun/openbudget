import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/selected_month_provider.dart';
import 'package:openbudget_app/src/features/budget/screens/auto_assign_dialog.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The plan's month header: month navigation, Ready to Assign with a
/// breakdown sheet, the month's totals and the assign actions. Every figure
/// comes from the server's [BudgetMonthSummary].
class BudgetHeader extends HookConsumerWidget {
  const BudgetHeader({
    required this.summary,
    required this.currencyCode,
    required this.entityId,
    required this.month,
    this.totalOverspentMinor = 0,
    this.onCopyLastMonth,
    super.key,
  });

  final BudgetMonthSummary summary;
  final String currencyCode;
  final String entityId;

  /// The month being shown, as yyyymm.
  final int month;

  /// This month's overspent total, computed from the envelope groups.
  final int totalOverspentMinor;
  final VoidCallback? onCopyLastMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final hideAmounts = ref.watch(hideAmountsProvider);
    final year = month ~/ 100;
    final calendarMonth = month % 100;
    final now = DateTime.now();
    final isCurrentMonth = month == MonthKey.fromDate(now);
    final readyToAssign = summary.readyToAssignMinor;
    final isOverspent = readyToAssign < 0;
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
                              .setMonth(MonthKey.fromDate(now)),
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
                              '${_localizedMonth(l10n, calendarMonth)} $year',
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
                InkWell(
                  onTap: () => _showBreakdownSheet(context, hideAmounts),
                  borderRadius: BorderRadius.circular(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: ObAmount(
                          hideAmounts
                              ? hiddenAmountPlaceholder
                              : formatMinorForCode(readyToAssign, currencyCode),
                          highlighted: !isOverspent,
                          tone: isOverspent ? ObTone.overspent : ObTone.neutral,
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                      SkribbleIcon(
                        data: OpenBudgetIcons.chevronRight,
                        size: 18,
                        color: palette.mutedInk,
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  child: Text(
                    l10n.budgetBreakdownHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (summary.incomeMinor != 0 ||
              summary.allocatedMinor != 0 ||
              summary.activityMinor != 0) ...[
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
                          : formatMinorForCode(
                              summary.incomeMinor,
                              currencyCode,
                            ),
                      tone: ObTone.funded,
                    ),
                  ),
                  Expanded(
                    child: _SummaryColumn(
                      label: l10n.budgetTotalBudgeted,
                      value: hideAmounts
                          ? hiddenAmountPlaceholder
                          : formatMinorForCode(
                              summary.allocatedMinor,
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
                              -summary.activityMinor,
                              currencyCode,
                            ),
                      tone: summary.activityMinor > 0
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
                if (readyToAssign > 0)
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
        ],
      ),
    );
  }

  /// The Ready to Assign breakdown: every field of the month summary.
  /// "Exchange-rate difference" only appears when it is non-zero.
  void _showBreakdownSheet(BuildContext context, bool hideAmounts) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    String amount(int minor) => hideAmounts
        ? hiddenAmountPlaceholder
        : formatMinorForCode(minor, currencyCode);

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              0,
              SpacingTokens.md,
              SpacingTokens.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.budgetBreakdownTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: palette.ink,
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                _BreakdownRow(
                  label: l10n.budgetTotalIncome,
                  value: amount(summary.incomeMinor),
                  tone: ObTone.funded,
                ),
                _BreakdownRow(
                  label: l10n.budgetBreakdownUncategorised,
                  value: amount(-summary.uncategorizedMinor),
                  tone: summary.uncategorizedMinor != 0
                      ? ObTone.underfunded
                      : ObTone.neutral,
                ),
                if (summary.fxDifferenceMinor != 0)
                  _BreakdownRow(
                    label: l10n.budgetBreakdownFxDifference,
                    value: amount(summary.fxDifferenceMinor),
                  ),
                _BreakdownRow(
                  label: l10n.budgetTotalBudgeted,
                  value: amount(-summary.allocatedMinor),
                ),
                _BreakdownRow(
                  label: l10n.budgetTotalActivity,
                  value: amount(-summary.activityMinor),
                ),
                _BreakdownRow(
                  label: l10n.budgetBreakdownOverspentLastMonth,
                  value: amount(-summary.overspentLastMonthMinor),
                  tone: summary.overspentLastMonthMinor > 0
                      ? ObTone.overspent
                      : ObTone.neutral,
                ),
                _BreakdownRow(
                  label: l10n.budgetBreakdownAssignedInFuture,
                  value: amount(-summary.assignedInFutureMinor),
                ),
                const Divider(),
                _BreakdownRow(
                  label: l10n.budgetBreakdownAvailable,
                  value: amount(summary.availableMinor),
                ),
                _BreakdownRow(
                  label: l10n.budgetReadyToAssign,
                  value: amount(summary.readyToAssignMinor),
                  tone: summary.readyToAssignMinor < 0
                      ? ObTone.overspent
                      : ObTone.funded,
                  emphasized: true,
                ),
              ],
            ),
          ),
        ),
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
          currentMonth: month,
          todayMonth: MonthKey.fromDate(now),
          l10n: l10n,
          onSelect: (selectedMonth) {
            ref
                .read(selectedMonthProvider(entityId).notifier)
                .setMonth(selectedMonth);
            Navigator.of(ctx).pop();
          },
        ),
      ),
    );
  }
}

class _MonthPickerDialog extends HookWidget {
  const _MonthPickerDialog({
    required this.currentMonth,
    required this.todayMonth,
    required this.l10n,
    required this.onSelect,
  });

  final int currentMonth;
  final int todayMonth;
  final AppLocalizations l10n;
  final void Function(int month) onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final materialLocalizations = MaterialLocalizations.of(context);
    final displayYear = useState(currentMonth ~/ 100);

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
                final m = MonthKey.fromDate(
                  DateTime.utc(displayYear.value, index + 1),
                );
                final isSelected = m == currentMonth;
                final isToday = m == todayMonth;

                return Semantics(
                  selected: isSelected,
                  button: true,
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => onSelect(m),
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

class _BreakdownRow extends HookWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    this.tone = ObTone.neutral,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final ObTone tone;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: emphasized ? palette.ink : palette.mutedInk,
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          ObAmount(
            value,
            tone: tone,
            style: emphasized
                ? theme.textTheme.titleMedium
                : theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
