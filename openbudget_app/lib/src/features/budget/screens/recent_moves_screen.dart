import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/recent_moves_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_options_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum _RecentMovesTab { all, moved, assigned }

class RecentMovesScreen extends HookConsumerWidget {
  const RecentMovesScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final selectedTab = useState(_RecentMovesTab.all);
    final summaryAsync = ref.watch(budgetMonthlySummaryProvider(budgetId));
    final allEvents = ref.watch(recentMovesForBudgetProvider(budgetId));
    final introSeen = ref.watch(recentMovesIntroSeenProvider(budgetId));
    final hideAmounts = ref.watch(hideAmountsProvider);

    useEffect(() {
      if (introSeen || allEvents.isEmpty) return null;

      Future.microtask(() async {
        if (!context.mounted) return;
        ref.read(recentMovesIntroSeenSetProvider.notifier).markSeen(budgetId);
        await showDialog<void>(
          context: context,
          builder: (_) => const _RecentMovesIntroDialog(),
        );
      });

      return null;
    }, [introSeen, allEvents.isEmpty]);

    return Scaffold(
      backgroundColor: OpenBudgetPalette.bgPrimaryFor(theme),
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(theme),
        surfaceTintColor: OpenBudgetPalette.transparentFor(theme),
        automaticallyImplyLeading: false,
        title: Text(
          l10n.recentMovesTitle,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              l10n.dialogDone,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            l10n.reportsLoadError,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        data: (summary) {
          final currencyCode = CurrencyCode.values.firstWhere(
            (code) => code.code == summary.budget.currencyCode,
            orElse: () => CurrencyCode.usd,
          );

          final envelopeNames = _buildEnvelopeNameMap(summary.categories);
          final events = _filteredEvents(selectedTab.value, allEvents);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.md,
                  SpacingTokens.sm,
                  SpacingTokens.md,
                  SpacingTokens.xs,
                ),
                child: _RecentMovesTabs(
                  selected: selectedTab.value,
                  onSelected: (tab) => selectedTab.value = tab,
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: events.isEmpty
                    ? const _EmptyMovesState()
                    : _RecentMovesList(
                        events: events,
                        envelopeNames: envelopeNames,
                        currencyCode: currencyCode,
                        hideAmounts: hideAmounts,
                        onEnvelopeTap: (envelopeId) => context.pushNamed(
                          envelopeMovesRoute,
                          pathParameters: {
                            'id': budgetId,
                            'envelopeId': envelopeId,
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<RecentMoveEvent> _filteredEvents(
    _RecentMovesTab tab,
    List<RecentMoveEvent> events,
  ) {
    final filtered = switch (tab) {
      _RecentMovesTab.all => [...events],
      _RecentMovesTab.moved =>
        events.where((event) => event.type == RecentMoveType.moved).toList(),
      _RecentMovesTab.assigned =>
        events.where((event) => event.type == RecentMoveType.assigned).toList(),
    };

    return filtered..sort(_sortByOccurredAt);
  }

  int _sortByOccurredAt(RecentMoveEvent a, RecentMoveEvent b) =>
      b.occurredAt.compareTo(a.occurredAt);

  Map<String, String> _buildEnvelopeNameMap(
    List<CategoryWithEnvelopes> groups,
  ) {
    final map = <String, String>{};
    for (final group in groups) {
      for (final envelope in group.envelopes) {
        final id = envelope.id?.toString();
        if (id != null && id.isNotEmpty) {
          map[id] = envelope.name;
        }
      }
    }
    return map;
  }
}

class _RecentMovesIntroDialog extends HookWidget {
  const _RecentMovesIntroDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.lg),
              decoration: BoxDecoration(
                color: OpenBudgetPalette.bgBrandFor(theme).withAlpha(34),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(RadiusTokens.lg),
                ),
              ),
              child: Icon(
                Icons.savings_rounded,
                size: 48,
                color: OpenBudgetPalette.bgBrandFor(theme),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Column(
                children: [
                  Text(
                    l10n.recentMovesCoachTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    l10n.recentMovesCoachBody,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    l10n.recentMovesCoachHint,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child: Text(l10n.recentMovesCoachGotIt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EnvelopeMovesScreen extends HookConsumerWidget {
  const EnvelopeMovesScreen({
    required this.budgetId,
    required this.envelopeId,
    super.key,
  });

  final String budgetId;
  final String envelopeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(budgetMonthlySummaryProvider(budgetId));
    final allEvents = ref.watch(recentMovesForBudgetProvider(budgetId));
    final hideAmounts = ref.watch(hideAmountsProvider);

    return Scaffold(
      backgroundColor: OpenBudgetPalette.bgPrimaryFor(theme),
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(theme),
        surfaceTintColor: OpenBudgetPalette.transparentFor(theme),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          l10n.recentMovesDetailTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              l10n.dialogDone,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            l10n.reportsLoadError,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ),
        data: (summary) {
          final currencyCode = CurrencyCode.values.firstWhere(
            (code) => code.code == summary.budget.currencyCode,
            orElse: () => CurrencyCode.usd,
          );
          final envelopeNames = <String, String>{};
          for (final group in summary.categories) {
            for (final envelope in group.envelopes) {
              final id = envelope.id?.toString();
              if (id != null && id.isNotEmpty) {
                envelopeNames[id] = envelope.name;
              }
            }
          }

          final events =
              allEvents
                  .where(
                    (event) =>
                        event.toEnvelopeId == envelopeId ||
                        event.fromEnvelopeId == envelopeId,
                  )
                  .toList()
                ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

          if (events.isEmpty) {
            return _EmptyMovesState(
              title: l10n.recentMovesNoEnvelopeHistory(
                envelopeNames[envelopeId] ?? l10n.recentMovesUnnamedEnvelope,
              ),
              subtitle: l10n.recentMovesNoEnvelopeHistoryHint,
            );
          }

          final groupedByDay = <DateTime, List<RecentMoveEvent>>{};
          for (final event in events) {
            final day = DateTime(
              event.occurredAt.year,
              event.occurredAt.month,
              event.occurredAt.day,
            );
            groupedByDay.putIfAbsent(day, () => []).add(event);
          }
          final sortedDays = groupedByDay.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView(
            padding: const EdgeInsets.only(bottom: SpacingTokens.md),
            children: [
              for (final day in sortedDays) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.md,
                    vertical: SpacingTokens.sm,
                  ),
                  color: OpenBudgetPalette.bgTertiaryFor(theme),
                  child: Text(
                    _formatLongDate(l10n, day),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                for (final event in groupedByDay[day]!)
                  _EnvelopeMoveRow(
                    event: event,
                    envelopeId: envelopeId,
                    envelopeNames: envelopeNames,
                    currencyCode: currencyCode,
                    hideAmounts: hideAmounts,
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _formatLongDate(AppLocalizations l10n, DateTime date) {
    final monthName = switch (date.month) {
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
    return '$monthName ${date.day}, ${date.year}';
  }
}

class _RecentMovesTabs extends HookWidget {
  const _RecentMovesTabs({required this.selected, required this.onSelected});

  final _RecentMovesTab selected;
  final ValueChanged<_RecentMovesTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: OpenBudgetPalette.bgSecondaryFor(theme),
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        border: Border.all(color: OpenBudgetPalette.borderSubtleFor(theme)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _RecentMovesTabButton(
              label: l10n.recentMovesTabAll,
              selected: selected == _RecentMovesTab.all,
              onTap: () => onSelected(_RecentMovesTab.all),
              theme: theme,
            ),
          ),
          Expanded(
            child: _RecentMovesTabButton(
              label: l10n.recentMovesTabMoved,
              selected: selected == _RecentMovesTab.moved,
              onTap: () => onSelected(_RecentMovesTab.moved),
              theme: theme,
            ),
          ),
          Expanded(
            child: _RecentMovesTabButton(
              label: l10n.recentMovesTabAssigned,
              selected: selected == _RecentMovesTab.assigned,
              onTap: () => onSelected(_RecentMovesTab.assigned),
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentMovesTabButton extends HookWidget {
  const _RecentMovesTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) => Material(
      color: OpenBudgetPalette.transparentFor(theme),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
          decoration: BoxDecoration(
            color: selected
                ? OpenBudgetPalette.bgBrandFor(
                    theme,
                  ).withAlpha(theme.brightness == Brightness.dark ? 62 : 28)
                : OpenBudgetPalette.transparentFor(theme),
            borderRadius: BorderRadius.circular(RadiusTokens.sm),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? OpenBudgetPalette.bgBrandFor(theme)
                  : OpenBudgetPalette.fgSecondaryFor(theme),
            ),
          ),
        ),
      ),
    );
}

class _RecentMovesList extends HookWidget {
  const _RecentMovesList({
    required this.events,
    required this.envelopeNames,
    required this.currencyCode,
    required this.hideAmounts,
    required this.onEnvelopeTap,
  });

  final List<RecentMoveEvent> events;
  final Map<String, String> envelopeNames;
  final CurrencyCode currencyCode;
  final bool hideAmounts;
  final ValueChanged<String> onEnvelopeTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final grouped = <DateTime, List<RecentMoveEvent>>{};

    for (final event in events) {
      final day = DateTime(
        event.occurredAt.year,
        event.occurredAt.month,
        event.occurredAt.day,
      );
      grouped.putIfAbsent(day, () => []).add(event);
    }

    final sortedDays = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
      children: [
        for (final day in sortedDays) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.xs,
            ),
            child: _buildDayHeading(context, l10n, day),
          ),
          for (
            var eventIndex = 0;
            eventIndex < grouped[day]!.length;
            eventIndex++
          )
            _RecentMoveRow(
              event: grouped[day]![eventIndex],
              envelopeNames: envelopeNames,
              currencyCode: currencyCode,
              hideAmounts: hideAmounts,
              onEnvelopeTap: onEnvelopeTap,
              showDivider: eventIndex < grouped[day]!.length - 1,
            ),
        ],
      ],
    );
  }

  Widget _buildDayHeading(
    BuildContext context,
    AppLocalizations l10n,
    DateTime day,
  ) {
    final theme = Theme.of(context);
    final heading = _dayHeading(l10n, day);
    if (heading.relativeLabel == null) {
      return Text(
        heading.dateLabel,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading.relativeLabel!,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: OpenBudgetPalette.fgSecondaryFor(theme),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          heading.dateLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  _DayHeadingData _dayHeading(AppLocalizations l10n, DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (day == today) {
      return _DayHeadingData(
        relativeLabel: l10n.transactionDateToday,
        dateLabel: _formatDate(l10n, day),
      );
    }
    if (day == yesterday) {
      return _DayHeadingData(
        relativeLabel: l10n.transactionDateYesterday,
        dateLabel: _formatDate(l10n, day),
      );
    }
    return _DayHeadingData(dateLabel: _formatDate(l10n, day));
  }

  String _formatDate(AppLocalizations l10n, DateTime day) {
    final monthName = switch (day.month) {
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
    final dayPart = day.day.toString().padLeft(2, '0');
    return '$monthName $dayPart, ${day.year}';
  }
}

class _RecentMoveRow extends HookWidget {
  const _RecentMoveRow({
    required this.event,
    required this.envelopeNames,
    required this.currencyCode,
    required this.hideAmounts,
    required this.onEnvelopeTap,
    required this.showDivider,
  });

  final RecentMoveEvent event;
  final Map<String, String> envelopeNames;
  final CurrencyCode currencyCode;
  final bool hideAmounts;
  final ValueChanged<String> onEnvelopeTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final amountText = hideAmounts
        ? hiddenAmountPlaceholder
        : formatCents(event.amountCents, currencyCode);

    final toName =
        envelopeNames[event.toEnvelopeId] ?? l10n.recentMovesUnnamedEnvelope;
    final sourceEnvelopeId = event.fromEnvelopeId;
    final fromName = sourceEnvelopeId != null
        ? envelopeNames[sourceEnvelopeId] ?? l10n.recentMovesUnnamedEnvelope
        : l10n.recentMovesReadyToAssign;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        SpacingTokens.md,
        showDivider ? 0 : SpacingTokens.xs,
        SpacingTokens.md,
        showDivider ? SpacingTokens.xs : SpacingTokens.md,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: OpenBudgetPalette.bgSecondaryFor(theme),
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          border: Border.all(color: OpenBudgetPalette.borderSubtleFor(theme)),
          boxShadow: [
            BoxShadow(
              color: OpenBudgetPalette.overlayScrimFor(
                theme,
              ).withAlpha(theme.brightness == Brightness.dark ? 54 : 12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.md,
            SpacingTokens.sm,
            SpacingTokens.md,
            SpacingTokens.sm,
          ),
          child: Row(
            children: [
              _MoveChip(
                label: fromName,
                accent: sourceEnvelopeId != null,
                onTap: sourceEnvelopeId != null
                    ? () => onEnvelopeTap(sourceEnvelopeId)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.xs,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: OpenBudgetPalette.fgSecondaryFor(theme),
                ),
              ),
              _MoveChip(
                label: toName,
                accent: true,
                onTap: () => onEnvelopeTap(event.toEnvelopeId),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  amountText,
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnvelopeMoveRow extends HookWidget {
  const _EnvelopeMoveRow({
    required this.event,
    required this.envelopeId,
    required this.envelopeNames,
    required this.currencyCode,
    required this.hideAmounts,
  });

  final RecentMoveEvent event;
  final String envelopeId;
  final Map<String, String> envelopeNames;
  final CurrencyCode currencyCode;
  final bool hideAmounts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final fromName = event.fromEnvelopeId != null
        ? envelopeNames[event.fromEnvelopeId!] ??
              l10n.recentMovesUnnamedEnvelope
        : l10n.recentMovesReadyToAssign;
    final toName =
        envelopeNames[event.toEnvelopeId] ?? l10n.recentMovesUnnamedEnvelope;

    final signedAmount = switch (event.type) {
      RecentMoveType.assigned => event.amountCents,
      RecentMoveType.moved =>
        event.toEnvelopeId == envelopeId
            ? event.amountCents
            : -event.amountCents,
    };
    final amountText = hideAmounts
        ? hiddenAmountPlaceholder
        : formatCents(signedAmount, currencyCode);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.xs,
        SpacingTokens.md,
        SpacingTokens.xs,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: OpenBudgetPalette.bgSecondaryFor(theme),
          borderRadius: BorderRadius.circular(RadiusTokens.md),
          border: Border.all(color: OpenBudgetPalette.borderSubtleFor(theme)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.md,
            SpacingTokens.md,
            SpacingTokens.md,
            SpacingTokens.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: fromName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: OpenBudgetPalette.fgSecondaryFor(theme),
                          ),
                        ),
                      ),
                      TextSpan(
                        text: toName,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Text(
                amountText,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: signedAmount >= 0
                      ? OpenBudgetPalette.fgSuccessFor(theme)
                      : OpenBudgetPalette.fgErrorFor(theme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoveChip extends HookWidget {
  const _MoveChip({required this.label, this.accent = false, this.onTap});

  final String label;
  final bool accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentFill = theme.brightness == Brightness.dark
        ? OpenBudgetPalette.bgBrandFor(theme).withAlpha(38)
        : OpenBudgetPalette.bgBrandFor(theme).withAlpha(24);
    final chip = Container(
      constraints: const BoxConstraints(maxWidth: 152),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: accent ? accentFill : OpenBudgetPalette.bgTertiaryFor(theme),
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        border: Border.all(
          color: accent
              ? OpenBudgetPalette.bgBrandFor(theme).withAlpha(100)
              : OpenBudgetPalette.borderSubtleFor(theme),
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: accent ? OpenBudgetPalette.bgBrandFor(theme) : null,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (onTap == null) return chip;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RadiusTokens.sm),
      child: chip,
    );
  }
}

@immutable
class _DayHeadingData {
  const _DayHeadingData({required this.dateLabel, this.relativeLabel});

  final String dateLabel;
  final String? relativeLabel;
}

class _EmptyMovesState extends HookWidget {
  const _EmptyMovesState({this.title, this.subtitle});

  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.swap_horiz_rounded,
              size: 40,
              color: OpenBudgetPalette.fgSecondaryFor(theme),
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(
              title ?? l10n.recentMovesEmptyTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              subtitle ?? l10n.recentMovesEmptySubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: OpenBudgetPalette.fgSecondaryFor(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
