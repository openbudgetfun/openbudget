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
      backgroundColor: OpenBudgetPalette.appBackground,
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.appBackground,
        surfaceTintColor: Colors.transparent,
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
              _RecentMovesTabs(
                selected: selectedTab.value,
                onSelected: (tab) => selectedTab.value = tab,
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
                color: OpenBudgetPalette.accentBlue.withAlpha(34),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(RadiusTokens.lg),
                ),
              ),
              child: const Icon(
                Icons.savings_rounded,
                size: 48,
                color: OpenBudgetPalette.accentBlue,
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
      backgroundColor: OpenBudgetPalette.appBackground,
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.appBackground,
        surfaceTintColor: Colors.transparent,
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

          final envelopeName =
              envelopeNames[envelopeId] ?? l10n.recentMovesUnnamedEnvelope;
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
              title: l10n.recentMovesNoEnvelopeHistory(envelopeName),
              subtitle: l10n.recentMovesNoEnvelopeHistoryHint,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
            itemCount: events.length + 1,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.md,
                    SpacingTokens.sm,
                    SpacingTokens.md,
                    SpacingTokens.sm,
                  ),
                  child: Text(
                    envelopeName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }

              final event = events[index - 1];
              final fromName = event.fromEnvelopeId != null
                  ? envelopeNames[event.fromEnvelopeId!] ??
                        l10n.recentMovesUnnamedEnvelope
                  : l10n.recentMovesReadyToAssign;
              final toName =
                  envelopeNames[event.toEnvelopeId] ??
                  l10n.recentMovesUnnamedEnvelope;

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

              return ListTile(
                title: Text(
                  '$fromName ${l10n.recentMovesArrowLabel} $toName',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  _formatLongDate(l10n, event.occurredAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: OpenBudgetPalette.mutedText,
                  ),
                ),
                trailing: Text(
                  amountText,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: signedAmount >= 0
                        ? OpenBudgetPalette.progressGreen
                        : OpenBudgetPalette.negative,
                  ),
                ),
              );
            },
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

    return Row(
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
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.xs,
            vertical: SpacingTokens.sm,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? OpenBudgetPalette.accentBlue
                      : OpenBudgetPalette.mutedText,
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              Container(
                height: 2,
                color: selected
                    ? OpenBudgetPalette.accentBlue
                    : Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
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
            child: Text(
              _dayHeading(l10n, day),
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          for (final event in grouped[day]!)
            _RecentMoveRow(
              event: event,
              envelopeNames: envelopeNames,
              currencyCode: currencyCode,
              hideAmounts: hideAmounts,
              onEnvelopeTap: onEnvelopeTap,
            ),
        ],
      ],
    );
  }

  String _dayHeading(AppLocalizations l10n, DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (day == today) {
      return '${l10n.transactionDateToday}\n${_formatDate(l10n, day)}';
    }
    if (day == yesterday) {
      return '${l10n.transactionDateYesterday}\n${_formatDate(l10n, day)}';
    }
    return _formatDate(l10n, day);
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
  });

  final RecentMoveEvent event;
  final Map<String, String> envelopeNames;
  final CurrencyCode currencyCode;
  final bool hideAmounts;
  final ValueChanged<String> onEnvelopeTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final amountText = hideAmounts
        ? hiddenAmountPlaceholder
        : formatCents(event.amountCents, currencyCode);

    final toName =
        envelopeNames[event.toEnvelopeId] ?? l10n.recentMovesUnnamedEnvelope;
    final fromName = event.fromEnvelopeId != null
        ? envelopeNames[event.fromEnvelopeId!] ??
              l10n.recentMovesUnnamedEnvelope
        : l10n.recentMovesReadyToAssign;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.xs,
        SpacingTokens.md,
        SpacingTokens.xs,
      ),
      child: Row(
        children: [
          _MoveChip(label: fromName),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: SpacingTokens.xs),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: OpenBudgetPalette.mutedText,
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
    final chip = Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: accent
            ? OpenBudgetPalette.accentBlue.withAlpha(30)
            : OpenBudgetPalette.surfaceMuted,
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: accent ? OpenBudgetPalette.accentBlue : null,
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
            const Icon(
              Icons.swap_horiz_rounded,
              size: 40,
              color: OpenBudgetPalette.mutedText,
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
                color: OpenBudgetPalette.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
