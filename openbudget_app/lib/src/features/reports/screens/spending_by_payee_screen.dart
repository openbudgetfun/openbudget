import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class SpendingByPayeeScreen extends HookConsumerWidget {
  const SpendingByPayeeScreen({
    required this.budgetId,
    this.initialUsePreset = false,
    this.initialYear,
    this.initialMonth,
    super.key,
  });

  final String budgetId;
  final bool initialUsePreset;
  final int? initialYear;
  final int? initialMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final chartColors = OpenBudgetPalette.chartSeriesFor(Theme.of(context));
    final colorScheme = theme.colorScheme;
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
    final presetRangeLabel = _presetRangeLabel(
      l10n,
      selectedYear.value,
      selectedMonth.value,
      presetMonths.value,
    );

    return Scaffold(
      backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
        surfaceTintColor: OpenBudgetPalette.transparentFor(Theme.of(context)),
        title: Text(l10n.spendingByPayeeBreakdown),
      ),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            error.toString(),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ),
        data: (report) {
          final sourceCurrency = parseCurrencyCode(report.currencyCode);
          final sortedEntries = report.categorySpending.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final totalSpent = report.totalExpenses;

          return ListView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            children: [
              _ModeToggle(
                usePreset: usePreset.value,
                onModeChanged: (value) => usePreset.value = value,
              ),
              const SizedBox(height: SpacingTokens.sm),
              if (usePreset.value) ...[
                _PresetSelector(
                  presetMonths: presetMonths.value,
                  onChanged: (value) => presetMonths.value = value,
                ),
                const SizedBox(height: SpacingTokens.xs),
              ],
              _MonthSelector(
                label: _monthName(
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    children: [
                      Text(
                        usePreset.value
                            ? _presetLabel(presetMonths.value)
                            : _monthName(
                                l10n,
                                selectedMonth.value,
                                selectedYear.value,
                              ),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: OpenBudgetPalette.bgBrandFor(
                            Theme.of(context),
                          ),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (usePreset.value) ...[
                        const SizedBox(height: SpacingTokens.xs),
                        Text(
                          presetRangeLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: OpenBudgetPalette.fgSecondaryFor(
                              Theme.of(context),
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: SpacingTokens.sm),
                      Text(
                        converter?.formatAmount(
                              amountCents: totalSpent,
                              sourceCurrency: sourceCurrency,
                            ) ??
                            formatCents(totalSpent, sourceCurrency),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        l10n.spendingByPayeeTotalSpent,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: OpenBudgetPalette.fgSecondaryFor(
                            Theme.of(context),
                          ),
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      _CategoryStrip(
                        categoryEntries: sortedEntries,
                        totalSpent: totalSpent,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              Text(
                l10n.reportsSpendingByCategory,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              if (sortedEntries.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.lg),
                    child: Text(
                      l10n.reportsEmptySubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: OpenBudgetPalette.fgSecondaryFor(
                          Theme.of(context),
                        ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (var index = 0; index < sortedEntries.length; index++)
                        _CategoryRow(
                          categoryName: sortedEntries[index].key,
                          amountCents: sortedEntries[index].value,
                          totalCents: totalSpent,
                          sourceCurrency: sourceCurrency,
                          converter: converter,
                          color: chartColors[index % chartColors.length],
                          showDivider: index < sortedEntries.length - 1,
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: SpacingTokens.md),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.add_chart_rounded),
                  title: Text(
                    'Positive Inflow Total',
                    style: theme.textTheme.titleSmall,
                  ),
                  trailing: Text(
                    converter?.formatAmount(
                          amountCents: report.totalIncome,
                          sourceCurrency: sourceCurrency,
                        ) ??
                        formatCents(report.totalIncome, sourceCurrency),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: OpenBudgetPalette.fgSuccessFor(Theme.of(context)),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _monthName(AppLocalizations l10n, int month, int year) {
    final name = switch (month) {
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
    return '$name $year';
  }

  String _presetLabel(int months) => switch (months) {
      3 => 'Last 3 Months',
      6 => 'Last 6 Months',
      12 => 'Last 12 Months',
      _ => 'Last $months Months',
    };

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

    final startLabel = _monthName(l10n, startMonth, startYear);
    final endLabel = _monthName(l10n, endMonth, endYear);
    return '$startLabel\u2013$endLabel';
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.usePreset, required this.onModeChanged});

  final bool usePreset;
  final ValueChanged<bool> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: OpenBudgetPalette.bgTertiaryFor(Theme.of(context)),
        borderRadius: BorderRadius.circular(RadiusTokens.md),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeButton(
              label: l10n.spendingByPayeeMonth,
              selected: !usePreset,
              onTap: () => onModeChanged(false),
            ),
          ),
          const SizedBox(width: SpacingTokens.xs),
          Expanded(
            child: _ModeButton(
              label: l10n.spendingByPayeePreset,
              selected: usePreset,
              onTap: () => onModeChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RadiusTokens.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
        decoration: BoxDecoration(
          color: selected
              ? OpenBudgetPalette.bgSecondaryFor(Theme.of(context))
              : OpenBudgetPalette.transparentFor(Theme.of(context)),
          borderRadius: BorderRadius.circular(RadiusTokens.sm),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
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
    final theme = Theme.of(context);
    return Row(
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}

class _PresetSelector extends StatelessWidget {
  const _PresetSelector({required this.presetMonths, required this.onChanged});

  final int presetMonths;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Text(
            l10n.spendingByPayeePresetRange,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        DropdownButton<int>(
          value: presetMonths,
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          items: [
            DropdownMenuItem(
              value: 3,
              child: Text(l10n.spendingByPayeeLastMonths(3)),
            ),
            DropdownMenuItem(
              value: 6,
              child: Text(l10n.spendingByPayeeLastMonths(6)),
            ),
            DropdownMenuItem(
              value: 12,
              child: Text(l10n.spendingByPayeeLastMonths(12)),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({
    required this.categoryEntries,
    required this.totalSpent,
  });

  final List<MapEntry<String, int>> categoryEntries;
  final int totalSpent;

  @override
  Widget build(BuildContext context) {
    final colors = OpenBudgetPalette.chartSeriesFor(Theme.of(context));
    final top = categoryEntries.take(colors.length).toList();
    if (top.isEmpty || totalSpent <= 0) {
      return Container(
        height: 16,
        decoration: BoxDecoration(
          color: OpenBudgetPalette.bgTertiaryFor(Theme.of(context)),
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    final segments = <Widget>[];
    var used = 0;
    for (var index = 0; index < top.length; index++) {
      final value = top[index].value < 1 ? 1 : top[index].value;
      segments.add(
        Expanded(
          flex: value,
          child: Container(color: colors[index]),
        ),
      );
      used += value;
    }

    if (totalSpent > used) {
      segments.add(
        Expanded(
          flex: totalSpent - used,
          child: Container(
            color: OpenBudgetPalette.bgTertiaryFor(Theme.of(context)),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(height: 16, child: Row(children: segments)),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.categoryName,
    required this.amountCents,
    required this.totalCents,
    required this.sourceCurrency,
    required this.converter,
    required this.color,
    required this.showDivider,
  });

  final String categoryName;
  final int amountCents;
  final int totalCents;
  final CurrencyCode sourceCurrency;
  final DisplayCurrencyConverter? converter;
  final Color color;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = totalCents > 0 ? (amountCents / totalCents) * 100 : 0.0;

    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          title: Text(categoryName),
          subtitle: Text(
            '${percentage.toStringAsFixed(percentage >= 10 ? 0 : 1)}%',
            style: theme.textTheme.bodySmall?.copyWith(
              color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                converter?.formatAmount(
                      amountCents: amountCents,
                      sourceCurrency: sourceCurrency,
                    ) ??
                    formatCents(amountCents, sourceCurrency),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: SpacingTokens.xs),
              const Icon(Icons.chevron_right_rounded, size: 18),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
