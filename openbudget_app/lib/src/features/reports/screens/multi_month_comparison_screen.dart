import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/multi_month_comparison_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class MultiMonthComparisonScreen extends HookConsumerWidget {
  const MultiMonthComparisonScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final monthCount = useState(3);

    final comparisonAsync = ref.watch(
      multiMonthComparisonProvider(budgetId, monthCount: monthCount.value),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.comparisonTitle),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.tune_rounded),
            tooltip: l10n.comparisonMonthRange,
            onSelected: (value) => monthCount.value = value,
            itemBuilder: (_) => [
              for (final count in [3, 6, 12])
                PopupMenuItem(
                  value: count,
                  child: Text(l10n.comparisonMonths(count)),
                ),
            ],
          ),
        ],
      ),
      body: comparisonAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
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
                l10n.comparisonLoadError,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        data: (comparison) {
          final currency = CurrencyCode.values.firstWhere(
            (c) => c.code == comparison.budget.currencyCode,
            orElse: () => CurrencyCode.usd,
          );

          if (comparison.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.compare_arrows_rounded,
                    size: 48,
                    color: colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    l10n.comparisonEmptyTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    l10n.comparisonEmptySubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return _ComparisonTable(comparison: comparison, currency: currency);
        },
      ),
    );
  }
}

class _ComparisonTable extends HookWidget {
  const _ComparisonTable({required this.comparison, required this.currency});

  final MultiMonthComparison comparison;
  final CurrencyCode currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final scrollController = useScrollController();

    final months = comparison.months;
    final monthKeys = months.map((m) => '${m.year}-${m.month}').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpacingTokens.sm),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with month names.
            _buildHeaderRow(l10n, theme, months),
            const SizedBox(height: SpacingTokens.xs),
            // Totals row.
            _buildTotalRow(l10n, theme, colorScheme, months, monthKeys),
            const Divider(),
            // Category/envelope rows.
            for (final cat in comparison.categories) ...[
              _buildCategoryRow(theme, colorScheme, cat, monthKeys),
              for (final env in cat.envelopes)
                _buildEnvelopeRow(theme, colorScheme, env, monthKeys),
              const SizedBox(height: SpacingTokens.sm),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(
    AppLocalizations l10n,
    ThemeData theme,
    List<MonthColumn> months,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 160,
          child: Text(
            l10n.comparisonCategoryLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        for (final m in months)
          SizedBox(
            width: 120,
            child: Text(
              _shortMonthName(l10n, m.month, m.year),
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
      ],
    );
  }

  Widget _buildTotalRow(
    AppLocalizations l10n,
    ThemeData theme,
    ColorScheme colorScheme,
    List<MonthColumn> months,
    List<String> monthKeys,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(40),
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Padding(
              padding: const EdgeInsets.only(left: SpacingTokens.xs),
              child: Text(
                l10n.comparisonTotalLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          for (final m in months)
            SizedBox(
              width: 120,
              child: Text(
                formatCents(m.totalSpentCents, currency),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ColorTokens.error,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
    ThemeData theme,
    ColorScheme colorScheme,
    CategoryComparison cat,
    List<String> monthKeys,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(60),
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Padding(
              padding: const EdgeInsets.only(left: SpacingTokens.xs),
              child: Text(
                cat.category.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          for (final key in monthKeys)
            SizedBox(
              width: 120,
              child: Text(
                formatCents(cat.monthTotals[key]?[1] ?? 0, currency),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEnvelopeRow(
    ThemeData theme,
    ColorScheme colorScheme,
    EnvelopeComparison env,
    List<String> monthKeys,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: Padding(
              padding: const EdgeInsets.only(left: SpacingTokens.lg),
              child: Text(
                env.envelope.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          for (final key in monthKeys)
            SizedBox(
              width: 120,
              child: Text(
                formatCents(env.monthData[key]?[1] ?? 0, currency),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.right,
              ),
            ),
        ],
      ),
    );
  }

  String _shortMonthName(AppLocalizations l10n, int month, int year) {
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
    // Abbreviate to first 3 chars.
    final short = name.length > 3 ? name.substring(0, 3) : name;
    return "$short '${(year % 100).toString().padLeft(2, '0')}";
  }
}
