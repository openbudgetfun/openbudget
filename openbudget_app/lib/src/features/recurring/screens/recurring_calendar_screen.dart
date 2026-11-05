import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/recurring/providers/recurring_calendar_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// A month of scheduled money, pressed into a hand-ruled grid.
class RecurringCalendarScreen extends HookConsumerWidget {
  const RecurringCalendarScreen({required this.budgetId, super.key});

  /// Moves the calendar back one month.
  static const Key previousMonthKey = ValueKey('recurringCalendar.previous');

  /// Moves the calendar forward one month.
  static const Key nextMonthKey = ValueKey('recurringCalendar.next');

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md,
              vertical: SpacingTokens.xs,
            ),
            child: Row(
              children: [
                IconButton(
                  key: previousMonthKey,
                  tooltip: l10n.recurringPreviousMonth,
                  onPressed: () {
                    if (selectedMonth.value == 1) {
                      selectedMonth.value = 12;
                      selectedYear.value--;
                    } else {
                      selectedMonth.value--;
                    }
                    selectedDay.value = null;
                  },
                  icon: const SkribbleIcon(data: OpenBudgetIcons.chevronLeft),
                ),
                Expanded(
                  child: Text(
                    _monthName(
                      l10n,
                      selectedMonth.value,
                      selectedYear.value,
                    ),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  key: nextMonthKey,
                  tooltip: l10n.recurringNextMonth,
                  onPressed: () {
                    if (selectedMonth.value == 12) {
                      selectedMonth.value = 1;
                      selectedYear.value++;
                    } else {
                      selectedMonth.value++;
                    }
                    selectedDay.value = null;
                  },
                  icon: const SkribbleIcon(data: OpenBudgetIcons.chevronRight),
                ),
              ],
            ),
          ),
          calendarAsync.when(
            loading: () => Expanded(
              child: Center(
                child: ObLoadingPanel(label: l10n.recurringLoading),
              ),
            ),
            error: (error, _) => Expanded(
              child: ListView(
                padding: const EdgeInsets.all(SpacingTokens.md),
                children: [
                  ObStatePanel.problem(
                    title: l10n.scheduledCalendarLoadError,
                    message: error.toString(),
                  ),
                ],
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.sm,
                    ),
                    child: Divider(height: 1, color: palette.line),
                  ),
                  Expanded(
                    child:
                        selectedDay.value != null &&
                            dayMap.containsKey(selectedDay.value)
                        ? _DayDetail(
                            occurrences: dayMap[selectedDay.value]!,
                          )
                        : ListView(
                            padding: const EdgeInsets.all(SpacingTokens.md),
                            children: [
                              ObStatePanel.empty(
                                title: selectedDay.value != null
                                    ? l10n.scheduledCalendarNoEvents
                                    : l10n.scheduledCalendarSelectDay,
                                doodle: selectedDay.value != null
                                    ? WiredDoodleKind.moon
                                    : WiredDoodleKind.sun,
                                tone: ObTone.neutral,
                              ),
                            ],
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

/// What a scheduled occurrence means on the calendar.
enum _OccurrenceStatus { due, posted, scheduled }

/// How a scheduled occurrence reads today.
///
/// The server posts a due occurrence on its next date, so a date before today
/// has been posted and a date after today is still scheduled. When the next
/// date itself has arrived it is due. The data keeps no record of a skipped
/// occurrence, so the calendar never claims one.
_OccurrenceStatus _occurrenceStatus(ScheduledOccurrence occurrence) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final date = DateTime(
    occurrence.date.year,
    occurrence.date.month,
    occurrence.date.day,
  );
  if (!occurrence.isDue) {
    return _OccurrenceStatus.scheduled;
  }
  return date.isBefore(today)
      ? _OccurrenceStatus.posted
      : _OccurrenceStatus.due;
}

ObTone _occurrenceTone(ScheduledOccurrence occurrence) =>
    switch (_occurrenceStatus(occurrence)) {
      _OccurrenceStatus.posted => ObTone.funded,
      _OccurrenceStatus.due => ObTone.overspent,
      _OccurrenceStatus.scheduled => ObTone.brand,
    };

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
    final palette = theme.ob;

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
          Row(
            children: [
              for (final label in dayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          ...List.generate(
            6,
            (week) => Row(
              children: List.generate(7, (weekday) {
                final dayIndex = week * 7 + weekday - (startWeekday - 1);
                if (dayIndex < 1 || dayIndex > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 48));
                }

                final events = dayMap[dayIndex] ?? const [];
                final hasEvents = events.isNotEmpty;
                final hasDue = events.any((o) => o.isDue);
                final isSelected = selectedDay == dayIndex;
                final isToday = isCurrentMonth && now.day == dayIndex;

                return Expanded(
                  child: Semantics(
                    button: true,
                    selected: isSelected,
                    label: _daySemantics(
                      l10n,
                      dayIndex,
                      events.length,
                      hasDue,
                    ),
                    excludeSemantics: true,
                    child: GestureDetector(
                      onTap: () => onDaySelected(dayIndex),
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        height: 48,
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: DecoratedBox(
                            decoration: ObRoughDecoration(
                              color: isSelected
                                  ? palette.brandWash
                                  : palette.surface,
                              outline: isSelected
                                  ? palette.brand
                                  : isToday
                                  ? palette.firmPen
                                  : palette.quietPen,
                              radius: 8,
                              strokeWidth: isToday ? 2.2 : 1.8,
                              seed: 30 + dayIndex,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$dayIndex',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isSelected
                                        ? palette.brand
                                        : palette.ink,
                                    fontWeight: isToday
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                if (hasEvents)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      for (final (index, event)
                                          in events.take(3).indexed) ...[
                                        if (index > 0) const SizedBox(width: 2),
                                        SizedBox.square(
                                          dimension: 6,
                                          child: DecoratedBox(
                                            decoration: ObRoughDecoration(
                                              color: palette.hue(
                                                _occurrenceTone(event),
                                              ),
                                              outline: palette.ink,
                                              radius: 2,
                                              strokeWidth: 1,
                                              seed: 40 + dayIndex + index,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _daySemantics(
    AppLocalizations l10n,
    int day,
    int eventCount,
    bool hasDue,
  ) {
    final parts = <String>['$day'];
    if (eventCount > 0) {
      parts.add(l10n.recurringCalendarDayCount(eventCount));
    }
    if (hasDue) {
      parts.add(l10n.recurringDueLabel);
    }
    return parts.join(', ');
  }
}

class _DayDetail extends HookWidget {
  const _DayDetail({required this.occurrences});

  final List<ScheduledOccurrence> occurrences;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.xs,
        SpacingTokens.md,
        SpacingTokens.md,
      ),
      itemCount: occurrences.length,
      itemBuilder: (context, index) {
        final occurrence = occurrences[index];
        final recurring = occurrence.recurring;
        final isIncome = recurring.amountCents > 0;
        final tone = isIncome ? ObTone.funded : ObTone.overspent;
        final frequencyLabel = switch (recurring.frequency) {
          'daily' => l10n.recurringFreqDaily,
          'weekly' => l10n.recurringFreqWeekly,
          'biweekly' => l10n.recurringFreqBiweekly,
          'monthly' => l10n.recurringFreqMonthly,
          'yearly' => l10n.recurringFreqYearly,
          _ => recurring.frequency,
        };

        return Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: ObCard(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.xs,
              ),
              leading: SizedBox.square(
                dimension: 40,
                child: DecoratedBox(
                  decoration: ObRoughDecoration(
                    color: palette.wash(tone),
                    outline: palette.quietPen,
                    radius: 10,
                    strokeWidth: 1.6,
                    seed: 80 + index,
                  ),
                  child: Center(
                    child: SkribbleIcon(
                      data: isIncome
                          ? OpenBudgetIcons.inflow
                          : OpenBudgetIcons.outflow,
                      size: 20,
                      color: palette.hue(tone),
                    ),
                  ),
                ),
              ),
              title: Text(
                recurring.description,
                style: theme.textTheme.bodyLarge,
              ),
              subtitle: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: SpacingTokens.sm,
                runSpacing: SpacingTokens.xs,
                children: [
                  Text(
                    frequencyLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                  switch (_occurrenceStatus(occurrence)) {
                    _OccurrenceStatus.due => ObToneChip(
                      label: l10n.recurringDueLabel,
                      tone: ObTone.overspent,
                      icon: const SkribbleIcon(
                        data: OpenBudgetIcons.schedule,
                        size: 14,
                      ),
                    ),
                    _OccurrenceStatus.posted => ObToneChip(
                      label: l10n.recurringPostedLabel,
                      tone: ObTone.funded,
                      icon: const SkribbleIcon(
                        data: OpenBudgetIcons.history,
                        size: 14,
                      ),
                    ),
                    _OccurrenceStatus.scheduled => ObToneChip(
                      label: l10n.recurringScheduledLabel,
                      tone: ObTone.brand,
                      icon: const SkribbleIcon(
                        data: OpenBudgetIcons.calendar,
                        size: 14,
                      ),
                    ),
                  },
                ],
              ),
              trailing: ObAmount(
                isIncome
                    ? '+${formatCentsForCode(recurring.amountCents, recurring.currencyCode)}'
                    : formatCentsForCode(
                        recurring.amountCents,
                        recurring.currencyCode,
                      ),
                tone: tone,
                style: theme.textTheme.titleSmall,
              ),
            ),
          ),
        );
      },
    );
  }
}
