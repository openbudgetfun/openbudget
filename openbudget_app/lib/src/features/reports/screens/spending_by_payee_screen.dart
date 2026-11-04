import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:openbudget_app/src/features/reports/utils/report_month_label.dart';
import 'package:openbudget_app/src/features/reports/widgets/report_charts.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// A month or a range of months, split across the envelopes it was spent in.
class SpendingByPayeeScreen extends HookConsumerWidget {
  const SpendingByPayeeScreen({
    required this.budgetId,
    this.initialUsePreset = false,
    this.initialYear,
    this.initialMonth,
    super.key,
  });

  /// Moves the statement back one month.
  static const Key previousMonthKey = ValueKey(
    'spendingByPayee.previousMonth',
  );

  /// Moves the statement forward one month.
  static const Key nextMonthKey = ValueKey('spendingByPayee.nextMonth');

  final String budgetId;
  final bool initialUsePreset;
  final int? initialYear;
  final int? initialMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final now = DateTime.now();
    final selectedYear = useState(initialYear ?? now.year);
    final normalizedInitialMonth = initialMonth?.clamp(1, 12) ?? now.month;
    final selectedMonth = useState(normalizedInitialMonth);
    final presetMonths = useState(3);
    final usePreset = useState(initialUsePreset);
    final converter = ref
        .watch(displayCurrencyConverterProvider(budgetId))
        .asData
        ?.value;

    final reportAsync = usePreset.value
        ? ref.watch(
            spendingReportPresetProvider(
              budgetId,
              selectedYear.value,
              selectedMonth.value,
              presetMonths.value,
            ),
          )
        : ref.watch(
            spendingReportProvider(
              budgetId,
              selectedYear.value,
              selectedMonth.value,
            ),
          );

    return Scaffold(
      backgroundColor: palette.canvas,
      appBar: AppBar(title: Text(l10n.spendingByPayeeBreakdown)),
      body: reportAsync.when(
        loading: () =>
            Center(child: ObLoadingPanel(label: l10n.reportsLoading)),
        error: (error, _) => ListView(
          padding: const EdgeInsets.all(SpacingTokens.md),
          children: [
            ObStatePanel.problem(
              title: l10n.reportsLoadError,
              message: error.toString(),
            ),
          ],
        ),
        data: (report) {
          final sourceCurrency = parseCurrencyCode(report.currencyCode);
          final sortedEntries = report.categorySpending.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final totalSpent = report.totalExpenses;
          final series = reportSeriesColors(theme);
          String format(int cents) =>
              converter?.formatAmount(
                amountCents: cents,
                sourceCurrency: sourceCurrency,
              ) ??
              formatCents(cents, sourceCurrency);
          final topEntries = sortedEntries.take(series.length).toList();
          final listedTotal = topEntries.fold<int>(
            0,
            (sum, entry) => sum + entry.value,
          );
          final segments = [
            for (final (index, entry) in topEntries.indexed)
              ReportChartDatum(
                label: entry.key,
                amountLabel: format(entry.value),
                value: entry.value,
                color: series[index],
              ),
            if (totalSpent > listedTotal)
              ReportChartDatum(
                label: l10n.reportsOtherCategories,
                amountLabel: format(totalSpent - listedTotal),
                value: totalSpent - listedTotal,
                color: palette.mutedInk,
              ),
          ];
          final rangeLabel = _presetRangeLabel(
            l10n,
            selectedYear.value,
            selectedMonth.value,
            presetMonths.value,
          );
          final periodLabel = usePreset.value
              ? l10n.spendingByPayeeLastMonths(presetMonths.value)
              : reportMonthLabel(
                  l10n,
                  selectedMonth.value,
                  selectedYear.value,
                );

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.sm,
              SpacingTokens.md,
              SpacingTokens.xl,
            ),
            children: [
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(l10n.spendingByPayeeMonth),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(l10n.spendingByPayeePreset),
                  ),
                ],
                selected: {usePreset.value},
                onSelectionChanged: (selection) =>
                    usePreset.value = selection.first,
              ),
              if (usePreset.value) ...[
                const SizedBox(height: SpacingTokens.sm),
                ObDropdown<int>(
                  value: presetMonths.value,
                  labelText: l10n.spendingByPayeePresetRange,
                  items: [
                    for (final months in const [3, 6, 12])
                      DropdownMenuItem(
                        value: months,
                        child: Text(l10n.spendingByPayeeLastMonths(months)),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) presetMonths.value = value;
                  },
                ),
              ],
              const SizedBox(height: SpacingTokens.sm),
              _MonthSelector(
                label: reportMonthLabel(
                  l10n,
                  selectedMonth.value,
                  selectedYear.value,
                ),
                onPrevious: () {
                  if (selectedMonth.value == 1) {
                    selectedMonth.value = 12;
                    selectedYear.value--;
                  } else {
                    selectedMonth.value--;
                  }
                },
                onNext: () {
                  if (selectedMonth.value == 12) {
                    selectedMonth.value = 1;
                    selectedYear.value++;
                  } else {
                    selectedMonth.value++;
                  }
                },
              ),
              const SizedBox(height: SpacingTokens.sm),
              ObCard(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (usePreset.value) ...[
                      Text(periodLabel, style: theme.textTheme.titleMedium),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        rangeLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.mutedInk,
                        ),
                      ),
                    ],
                    const SizedBox(height: SpacingTokens.sm),
                    ObAmount(
                      format(totalSpent),
                      style: theme.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      l10n.spendingByPayeeTotalSpent,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                    if (segments.isEmpty) ...[
                      const SizedBox(height: SpacingTokens.sm),
                      ObStatePanel.empty(
                        title: l10n.spendingByPayeeEmptyTitle,
                        message: l10n.spendingByPayeeEmptySubtitle,
                        doodle: WiredDoodleKind.rainbow,
                      ),
                    ] else ...[
                      const SizedBox(height: SpacingTokens.md),
                      ReportShareBar(
                        segments: segments,
                        semanticsLabel: reportChartSummary(
                          l10n,
                          title: l10n.spendingByPayeeBreakdown,
                          entries: [
                            for (final segment in segments)
                              (segment.label, segment.amountLabel),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ObSectionHeader(
                title: l10n.reportsSpendingByCategory,
                padding: const EdgeInsets.fromLTRB(
                  0,
                  SpacingTokens.lg,
                  0,
                  SpacingTokens.sm,
                ),
              ),
              if (sortedEntries.isEmpty)
                ObStatePanel.empty(
                  title: l10n.spendingByPayeeEmptyTitle,
                  message: l10n.spendingByPayeeEmptySubtitle,
                  doodle: WiredDoodleKind.rainbow,
                )
              else
                ObCard(
                  child: Column(
                    children: [
                      for (final (index, entry) in sortedEntries.indexed) ...[
                        _CategoryRow(
                          categoryName: entry.key,
                          amountCents: entry.value,
                          totalCents: totalSpent,
                          sourceCurrency: sourceCurrency,
                          converter: converter,
                          color: series[index % series.length],
                          seed: 61 + index,
                        ),
                        if (index < sortedEntries.length - 1)
                          Divider(height: 1, color: palette.line),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: SpacingTokens.md),
              ObCard(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: Row(
                  children: [
                    SkribbleIcon(
                      data: OpenBudgetIcons.addChart,
                      size: 20,
                      color: palette.funded,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: Text(
                        l10n.reportsPositiveInflowTotal,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    ObAmount(
                      converter?.formatAmount(
                            amountCents: report.totalIncome,
                            sourceCurrency: sourceCurrency,
                          ) ??
                          formatCents(report.totalIncome, sourceCurrency),
                      tone: ObTone.funded,
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _presetRangeLabel(
    AppLocalizations l10n,
    int endYear,
    int endMonth,
    int monthCount,
  ) {
    final normalizedCount = monthCount < 1 ? 1 : monthCount;
    var startYear = endYear;
    var startMonth = endMonth;
    for (var index = 1; index < normalizedCount; index++) {
      if (startMonth == 1) {
        startMonth = 12;
        startYear -= 1;
      } else {
        startMonth -= 1;
      }
    }

    final startLabel = reportMonthLabel(l10n, startMonth, startYear);
    final endLabel = reportMonthLabel(l10n, endMonth, endYear);
    return '$startLabel\u2013$endLabel';
  }
}

class _MonthSelector extends HookWidget {
  const _MonthSelector({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          key: SpendingByPayeeScreen.previousMonthKey,
          onPressed: onPrevious,
          tooltip: l10n.reportsPreviousMonth,
          icon: const SkribbleIcon(data: OpenBudgetIcons.chevronLeft),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ),
        IconButton(
          key: SpendingByPayeeScreen.nextMonthKey,
          onPressed: onNext,
          tooltip: l10n.reportsNextMonth,
          icon: const SkribbleIcon(data: OpenBudgetIcons.chevronRight),
        ),
      ],
    );
  }
}

class _CategoryRow extends HookWidget {
  const _CategoryRow({
    required this.categoryName,
    required this.amountCents,
    required this.totalCents,
    required this.sourceCurrency,
    required this.converter,
    required this.color,
    required this.seed,
  });

  final String categoryName;
  final int amountCents;
  final int totalCents;
  final CurrencyCode sourceCurrency;
  final DisplayCurrencyConverter? converter;
  final Color color;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final percentage = totalCents > 0 ? (amountCents / totalCents) * 100 : 0.0;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      leading: SizedBox.square(
        dimension: 20,
        child: DecoratedBox(
          decoration: ObRoughDecoration(
            color: color,
            outline: palette.ink,
            radius: 4,
            strokeWidth: 1.6,
            seed: seed,
          ),
        ),
      ),
      title: Text(categoryName),
      subtitle: Text(
        '${percentage.toStringAsFixed(percentage >= 10 ? 0 : 1)}%',
        style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedInk),
      ),
      trailing: ObAmount(
        converter?.formatAmount(
              amountCents: amountCents,
              sourceCurrency: sourceCurrency,
            ) ??
            formatCents(amountCents, sourceCurrency),
        style: theme.textTheme.titleSmall,
      ),
    );
  }
}
