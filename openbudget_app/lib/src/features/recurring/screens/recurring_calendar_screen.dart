import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_calendar_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class RecurringCalendarScreen extends HookConsumerWidget {
  const RecurringCalendarScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final now = DateTime.now();
    final selectedYear = useState(now.year);
    final selectedMonth = useState(now.month);
    final selectedDay = useState<int?>(null);

    final calendarAsync = ref.watch(
      recurringCalendarProvider(
        budgetId,
        selectedYear.value,
        selectedMonth.value,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.scheduledCalendarTitle)),
      body: Column(
        children: [
          // Month navigation.
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md,
              vertical: SpacingTokens.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (selectedMonth.value == 1) {
                      selectedMonth.value = 12;
                      selectedYear.value--;
                    } else {
                      selectedMonth.value--;
                    }
                    selectedDay.value = null;
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  _monthName(l10n, selectedMonth.value, selectedYear.value),
                  style: theme.textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: () {
                    if (selectedMonth.value == 12) {
                      selectedMonth.value = 1;
                      selectedYear.value++;
                    } else {
                      selectedMonth.value++;
                    }
                    selectedDay.value = null;
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
          // Calendar grid.
          calendarAsync.when(
            loading: () => const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      l10n.scheduledCalendarLoadError,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (dayMap) => Expanded(
              child: Column(
                children: [
                  _CalendarGrid(
                    year: selectedYear.value,
                    month: selectedMonth.value,
                    dayMap: dayMap,
                    selectedDay: selectedDay.value,
                    onDaySelected: (day) => selectedDay.value = day,
                  ),
                  const Divider(),
                  Expanded(
                    child:
                        selectedDay.value != null &&
                            dayMap.containsKey(selectedDay.value)
                        ? _DayDetail(
                            occurrences: dayMap[selectedDay.value]!,
                            budgetId: budgetId,
                          )
                        : Center(
                            child: Text(
                              selectedDay.value != null
                                  ? l10n.scheduledCalendarNoEvents
                                  : l10n.scheduledCalendarSelectDay,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
}

class _CalendarGrid extends HookWidget {
  const _CalendarGrid({
    required this.year,
    required this.month,
    required this.dayMap,
    required this.selectedDay,
    required this.onDaySelected,
  });

  final int year;
  final int month;
  final Map<int, List<ScheduledOccurrence>> dayMap;
  final int? selectedDay;
  final ValueChanged<int> onDaySelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final firstDay = DateTime(year, month);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // Monday = 1, Sunday = 7.
    final startWeekday = firstDay.weekday;

    final dayLabels = [
      l10n.scheduledCalendarMon,
      l10n.scheduledCalendarTue,
      l10n.scheduledCalendarWed,
      l10n.scheduledCalendarThu,
      l10n.scheduledCalendarFri,
      l10n.scheduledCalendarSat,
      l10n.scheduledCalendarSun,
    ];

    final now = DateTime.now();
    final isCurrentMonth = now.year == year && now.month == month;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      child: Column(
        children: [
          // Day of week headers.
          Row(
            children: [
              for (final label in dayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          // Calendar days.
          ...List.generate(6, (week) => Row(
              children: List.generate(7, (weekday) {
                final dayIndex = week * 7 + weekday - (startWeekday - 1);
                if (dayIndex < 1 || dayIndex > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 44));
                }

                final hasEvents = dayMap.containsKey(dayIndex);
                final hasDue = dayMap[dayIndex]?.any((o) => o.isDue) ?? false;
                final isSelected = selectedDay == dayIndex;
                final isToday = isCurrentMonth && now.day == dayIndex;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDaySelected(dayIndex),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary.withAlpha(30)
                            : null,
                        borderRadius: BorderRadius.circular(RadiusTokens.sm),
                        border: isToday
                            ? Border.all(color: colorScheme.primary, width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayIndex',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: isToday
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                            ),
                          ),
                          if (hasEvents)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: hasDue
                                        ? ColorTokens.error
                                        : colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            )),
        ],
      ),
    );
  }
}

class _DayDetail extends HookConsumerWidget {
  const _DayDetail({required this.occurrences, required this.budgetId});

  final List<ScheduledOccurrence> occurrences;
  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
      itemCount: occurrences.length,
      itemBuilder: (context, index) {
        final occurrence = occurrences[index];
        final recurring = occurrence.recurring;
        final isIncome = recurring.amountCents > 0;
        final color = isIncome ? ColorTokens.secondary : ColorTokens.error;
        final currency = CurrencyCode.values.firstWhere(
          (c) => c.code == recurring.currencyCode,
          orElse: () => CurrencyCode.usd,
        );

        final freqLabel = switch (recurring.frequency) {
          'daily' => l10n.recurringFreqDaily,
          'weekly' => l10n.recurringFreqWeekly,
          'biweekly' => l10n.recurringFreqBiweekly,
          'monthly' => l10n.recurringFreqMonthly,
          'yearly' => l10n.recurringFreqYearly,
          _ => recurring.frequency,
        };

        return Card(
          margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: color.withAlpha(25),
              child: Icon(
                isIncome
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: color,
                size: 20,
              ),
            ),
            title: Text(
              recurring.description,
              style: theme.textTheme.bodyMedium,
            ),
            subtitle: Row(
              children: [
                Text(
                  freqLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (occurrence.isDue) ...[
                  const SizedBox(width: SpacingTokens.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: ColorTokens.error.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      l10n.recurringDueLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: ColorTokens.error,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            trailing: Text(
              formatCents(recurring.amountCents, currency),
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
