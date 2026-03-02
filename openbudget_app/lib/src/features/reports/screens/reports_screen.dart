import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/age_of_money_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/spending_report_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class ReportsScreen extends HookConsumerWidget {
  const ReportsScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final selectedYear = useState(now.year);
    final selectedMonth = useState(now.month);

    final reportAsync = ref.watch(
      spendingReportProvider(budgetId, selectedYear.value, selectedMonth.value),
    );
    final netWorthAsync = ref.watch(netWorthProvider(budgetId));
    final ageOfMoneyAsync = ref.watch(ageOfMoneyProvider(budgetId));
    final converter = ref
        .watch(displayCurrencyConverterProvider(budgetId))
        .asData
        ?.value;

    return Scaffold(
      backgroundColor: OpenBudgetPalette.bgPrimaryFor(theme),
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(theme),
        surfaceTintColor: OpenBudgetPalette.transparentFor(theme),
        title: Text(l10n.tabReflect),
      ),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: [
          _ReflectCard(
            title: l10n.spendingByPayeeBreakdown,
            icon: Icons.pie_chart_rounded,
            onTap: () => context.pushNamed(
              spendingByPayeeRoute,
              pathParameters: {'id': budgetId},
            ),
            child: reportAsync.when(
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              data: (report) => _SpendingBreakdownPreview(
                report: report,
                monthLabel: _monthName(
                  l10n,
                  selectedMonth.value,
                  selectedYear.value,
                ),
                converter: converter,
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          _ReflectCard(
            title: l10n.netWorthTitle,
            icon: Icons.account_balance_rounded,
            onTap: () => context.pushNamed(
              netWorthRoute,
              pathParameters: {'id': budgetId},
            ),
            child: netWorthAsync.when(
              loading: () => const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              data: (data) =>
                  _NetWorthPreview(data: data, converter: converter),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          _ReflectCard(
            title: l10n.ageOfMoneyLabel(ageOfMoneyAsync.value ?? 0),
            icon: Icons.schedule_rounded,
            onTap: () => context.pushNamed(
              spendingTrendsRoute,
              pathParameters: {'id': budgetId},
            ),
            child: ageOfMoneyAsync.when(
              loading: () => const SizedBox(
                height: 88,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              data: (days) => _AgeOfMoneyPreview(days: days),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          TextButton.icon(
            onPressed: () => context.pushNamed(
              multiMonthComparisonRoute,
              pathParameters: {'id': budgetId},
            ),
            icon: const Icon(Icons.compare_arrows_rounded),
            label: Text(l10n.comparisonTitle),
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

class _ReflectCard extends StatelessWidget {
  const _ReflectCard({
    required this.title,
    required this.icon,
    required this.child,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: OpenBudgetPalette.bgSecondaryFor(theme),
      borderRadius: BorderRadius.circular(RadiusTokens.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: OpenBudgetPalette.bgBrandFor(theme),
                    size: 18,
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: OpenBudgetPalette.bgBrandFor(theme),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _SpendingBreakdownPreview extends StatelessWidget {
  const _SpendingBreakdownPreview({
    required this.report,
    required this.monthLabel,
    required this.converter,
  });

  final SpendingReport report;
  final String monthLabel;
  final DisplayCurrencyConverter? converter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColors = OpenBudgetPalette.chartSeriesFor(theme);
    final sortedEntries = report.categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final categories = sortedEntries.take(6).toList();
    final sourceCurrency = parseCurrencyCode(report.currencyCode);
    final totalCents = categories.fold<int>(0, (sum, item) => sum + item.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          monthLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: OpenBudgetPalette.fgSecondaryFor(theme),
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          converter?.formatAmount(
                amountCents: report.totalExpenses,
                sourceCurrency: sourceCurrency,
              ) ??
              formatCents(report.totalExpenses, sourceCurrency),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        if (categories.isEmpty) ...[
          const SizedBox(height: SpacingTokens.sm),
          Text(
            AppLocalizations.of(context).reportsEmptySubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: OpenBudgetPalette.fgSecondaryFor(theme),
            ),
          ),
        ] else ...[
          const SizedBox(height: SpacingTokens.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 18,
              child: Row(
                children: [
                  for (var index = 0; index < categories.length; index++)
                    Expanded(
                      flex: categories[index].value,
                      child: Container(color: barColors[index]),
                    ),
                  if (report.totalExpenses > totalCents)
                    Expanded(
                      flex: report.totalExpenses - totalCents,
                      child: Container(
                        color: OpenBudgetPalette.bgTertiaryFor(theme),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            AppLocalizations.of(context).reportsSpendingByCategory,
            style: theme.textTheme.labelLarge?.copyWith(
              color: OpenBudgetPalette.fgSecondaryFor(theme),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          for (var index = 0; index < categories.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: barColors[index],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Expanded(
                    child: Text(
                      categories[index].key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    converter?.formatAmount(
                          amountCents: categories[index].value,
                          sourceCurrency: sourceCurrency,
                        ) ??
                        formatCents(categories[index].value, sourceCurrency),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _NetWorthPreview extends StatelessWidget {
  const _NetWorthPreview({required this.data, required this.converter});

  final NetWorthData data;
  final DisplayCurrencyConverter? converter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netWorthByCurrency = {
      for (final breakdown in data.currencyBreakdown)
        breakdown.currency: breakdown.netWorth,
    };
    final assetsByCurrency = {
      for (final breakdown in data.currencyBreakdown)
        breakdown.currency: breakdown.totalAssets,
    };
    final liabilitiesByCurrency = {
      for (final breakdown in data.currencyBreakdown)
        breakdown.currency: breakdown.totalLiabilities,
    };
    final convertedNetWorth = converter?.convertTotalsToDisplay(
      netWorthByCurrency,
    );
    final convertedAssets = converter?.convertTotalsToDisplay(assetsByCurrency);
    final convertedLiabilities = converter?.convertTotalsToDisplay(
      liabilitiesByCurrency,
    );

    final useConverted =
        convertedNetWorth != null &&
        convertedAssets != null &&
        convertedLiabilities != null;
    final primary = data.currencyBreakdown.firstOrNull;
    final currency = useConverted
        ? converter!.displayCurrency
        : (primary?.currency ?? CurrencyCode.usd);
    final assets = useConverted ? convertedAssets : (primary?.totalAssets ?? 0);
    final liabilities = useConverted
        ? convertedLiabilities
        : (primary?.totalLiabilities ?? 0);
    final netWorth = useConverted
        ? convertedNetWorth
        : (primary?.netWorth ?? 0);
    final maxAbs = [
      assets.abs(),
      liabilities.abs(),
      netWorth.abs(),
    ].reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatCents(netWorth, currency),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                '${AppLocalizations.of(context).netWorthAssets} ${formatCents(assets, currency)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: OpenBudgetPalette.bgBrandFor(theme),
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${AppLocalizations.of(context).netWorthLiabilities} ${formatCents(liabilities, currency)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: OpenBudgetPalette.fgErrorFor(theme),
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: SpacingTokens.sm),
        SizedBox(
          height: 80,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _Bar(
                  fraction: maxAbs == 0 ? 0 : assets.abs() / maxAbs,
                  color: OpenBudgetPalette.bgBrandFor(theme),
                  label: AppLocalizations.of(context).netWorthAssets,
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: _Bar(
                  fraction: maxAbs == 0 ? 0 : liabilities.abs() / maxAbs,
                  color: OpenBudgetPalette.fgErrorFor(theme),
                  label: AppLocalizations.of(context).netWorthLiabilities,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.fraction,
    required this.color,
    required this.label,
  });

  final double fraction;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: fraction < 0.02
                  ? 0.02
                  : (fraction > 1 ? 1 : fraction),
              child: Container(
                decoration: BoxDecoration(
                  color: color.withAlpha(190),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: OpenBudgetPalette.fgSecondaryFor(theme),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _AgeOfMoneyPreview extends StatelessWidget {
  const _AgeOfMoneyPreview({required this.days});

  final int? days;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayDays = days ?? 0;
    final suffix = displayDays == 1 ? 'day' : 'days';
    return SizedBox(
      height: 88,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$displayDays $suffix',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            days == null
                ? AppLocalizations.of(context).reportsEmptySubtitle
                : AppLocalizations.of(context).ageOfMoneyLabel(displayDays),
            style: theme.textTheme.bodySmall?.copyWith(
              color: OpenBudgetPalette.fgSecondaryFor(theme),
            ),
          ),
        ],
      ),
    );
  }
}
