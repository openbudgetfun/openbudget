import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/category_trends_provider.dart';
import 'package:openbudget_app/src/features/reports/utils/report_month_label.dart';
import 'package:openbudget_app/src/features/reports/widgets/report_charts.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// One line per category, one drawn bar per month.
class CategoryTrendsScreen extends HookConsumerWidget {
  const CategoryTrendsScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final trendsAsync = ref.watch(categoryTrendsProvider(entityId));
    final converter = ref
        .watch(displayCurrencyConverterProvider(entityId))
        .asData
        ?.value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.categoryTrendsTitle)),
      body: trendsAsync.when(
        loading: () =>
            Center(child: ObLoadingPanel(label: l10n.reportsLoading)),
        error: (error, _) => ListView(
          padding: const EdgeInsets.all(SpacingTokens.md),
          children: [
            ObStatePanel.problem(
              title: l10n.categoryTrendsLoadError,
              message: error.toString(),
            ),
          ],
        ),
        data: (data) {
          if (data.categories.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(SpacingTokens.md),
              children: [
                ObStatePanel.empty(
                  title: l10n.categoryTrendsEmptyTitle,
                  message: l10n.categoryTrendsEmptySubtitle,
                  doodle: WiredDoodleKind.sparkle,
                  tone: ObTone.review,
                ),
              ],
            );
          }

          final sourceCurrency = data.currencyCode;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.sm,
              SpacingTokens.md,
              SpacingTokens.xl,
            ),
            children: [
              ObSectionHeader(
                title: l10n.reportsSpendingByCategory,
                subtitle: l10n.spendingTrendsMonthly,
                padding: const EdgeInsets.fromLTRB(
                  0,
                  0,
                  0,
                  SpacingTokens.sm,
                ),
              ),
              for (final category in data.categories)
                Padding(
                  padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
                  child: _CategoryTrendCard(
                    category: category,
                    months: data.months,
                    sourceCurrency: sourceCurrency,
                    converter: converter,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryTrendCard extends HookWidget {
  const _CategoryTrendCard({
    required this.category,
    required this.months,
    required this.sourceCurrency,
    required this.converter,
  });

  final CategoryTrendLine category;
  final List<MonthLabel> months;
  final String sourceCurrency;
  final DisplayCurrencyConverter? converter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final maxMinor = category.monthlyMinor.fold<int>(
      0,
      (max, v) => v > max ? v : max,
    );
    String format(int cents) =>
        converter?.formatAmount(
          amountMinor: cents,
          currencyCode: sourceCurrency,
        ) ??
        formatMinorForCode(cents, sourceCurrency);

    return Semantics(
      container: true,
      label: reportChartSummary(
        l10n,
        title: category.categoryName,
        entries: [
          for (final (index, month) in months.indexed)
            (
              reportMonthLabel(l10n, month.month, month.year),
              format(category.monthlyMinor[index]),
            ),
        ],
      ),
      child: ExcludeSemantics(
        child: ObCard(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      category.categoryName,
                      style: theme.textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  ObAmount(
                    format(category.totalMinor),
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              for (final (index, month) in months.indexed) ...[
                if (index > 0) const SizedBox(height: SpacingTokens.xs),
                Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: Text(
                        reportMonthAxisLabel(l10n, month.month),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.ob.mutedInk,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ReportTrackBar(
                        fraction: maxMinor > 0
                            ? category.monthlyMinor[index] / maxMinor
                            : 0,
                        tone: ObTone.brand,
                        height: 12,
                        seed: 91 + index,
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    SizedBox(
                      width: 88,
                      child: ObAmount(
                        format(category.monthlyMinor[index]),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
