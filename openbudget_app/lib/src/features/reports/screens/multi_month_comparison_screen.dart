import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/multi_month_comparison_provider.dart';
import 'package:openbudget_app/src/features/reports/utils/report_month_label.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Months side by side, written as one wide hand-ruled table.
class MultiMonthComparisonScreen extends HookConsumerWidget {
  const MultiMonthComparisonScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final monthCount = useState(3);

    final comparisonAsync = ref.watch(
      multiMonthComparisonProvider(entityId, monthCount: monthCount.value),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.comparisonTitle),
        actions: [
          PopupMenuButton<int>(
            icon: const SkribbleIcon(data: OpenBudgetIcons.tune),
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
        loading: () =>
            Center(child: ObLoadingPanel(label: l10n.reportsLoading)),
        error: (error, _) => ListView(
          padding: const EdgeInsets.all(SpacingTokens.md),
          children: [
            ObStatePanel.problem(
              title: l10n.comparisonLoadError,
              message: error.toString(),
            ),
          ],
        ),
        data: (comparison) {

          if (comparison.categories.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(SpacingTokens.md),
              children: [
                ObStatePanel.empty(
                  title: l10n.comparisonEmptyTitle,
                  message: l10n.comparisonEmptySubtitle,
                  doodle: WiredDoodleKind.comet,
                ),
              ],
            );
          }

          return _ComparisonTable(
            comparison: comparison,
            currencyCode: comparison.currencyCode,
          );
        },
      ),
    );
  }
}

const double _categoryColumnWidth = 170;
const double _monthColumnWidth = 112;

class _ComparisonTable extends HookWidget {
  const _ComparisonTable({
    required this.comparison,
    required this.currencyCode,
  });

  final MultiMonthComparison comparison;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final scrollController = useScrollController();
    final months = comparison.months;
    final monthKeys = months.map((m) => m.month).toList();
    String format(int minor) => formatMinorForCode(minor, currencyCode);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: scrollController,
        child: Container(
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: ObRoughDecoration(
            color: palette.surface,
            outline: palette.quietPen,
            seed: 11,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.sm,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: _categoryColumnWidth,
                      child: Text(
                        l10n.comparisonCategoryLabel,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: palette.mutedInk,
                        ),
                      ),
                    ),
                    for (final month in months)
                      SizedBox(
                        width: _monthColumnWidth,
                        child: Text(
                          _monthColumnLabel(l10n, month),
                          textAlign: TextAlign.end,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: palette.mutedInk,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.sm),
              DecoratedBox(
                decoration: ObRoughDecoration(
                  color: palette.highlight,
                  outline: palette.quietPen,
                  radius: RadiusTokens.sm,
                  strokeWidth: 1.6,
                  seed: 13,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.sm,
                    vertical: SpacingTokens.sm,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: _categoryColumnWidth - SpacingTokens.sm,
                        child: Text(
                          l10n.comparisonTotalLabel,
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      for (final month in months)
                        SizedBox(
                          width: _monthColumnWidth,
                          child: ObAmount(
                            format(month.totalActivityMinor.abs()),
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.end,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              for (final (index, category)
                  in comparison.categories.indexed) ...[
                if (index > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: SpacingTokens.sm,
                    ),
                    child: Divider(height: 1, color: palette.line),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.sm,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: _categoryColumnWidth,
                        child: Text(
                          category.category.name,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      for (final key in monthKeys)
                        SizedBox(
                          width: _monthColumnWidth,
                          child: ObAmount(
                            format(category.monthTotals[key]?[1] ?? 0),
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.end,
                          ),
                        ),
                    ],
                  ),
                ),
                for (final envelope in category.envelopes)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: SpacingTokens.xs,
                      left: SpacingTokens.sm,
                      right: SpacingTokens.sm,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: _categoryColumnWidth,
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: SpacingTokens.md,
                            ),
                            child: Text(
                              envelope.envelope.name,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: palette.mutedInk,
                              ),
                            ),
                          ),
                        ),
                        for (final key in monthKeys)
                          SizedBox(
                            width: _monthColumnWidth,
                            child: ObAmount(
                              format(envelope.monthData[key]?[1] ?? 0),
                              style: theme.textTheme.bodySmall,
                              textAlign: TextAlign.end,
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _monthColumnLabel(AppLocalizations l10n, MonthColumn month) {
    final name = reportYyyymmAxisLabel(l10n, month.month);
    final year = (monthKeyParts(month.month).year % 100).toString().padLeft(2, '0');
    return "$name '$year";
  }
}
