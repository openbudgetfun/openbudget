import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_url_launcher_provider.dart';
import 'package:openbudget_app/src/features/tax/tax_formatting.dart';
import 'package:openbudget_app/src/features/tax/tax_labels.dart';
import 'package:openbudget_app/src/features/tax/widgets/tax_caveat_card.dart';
import 'package:openbudget_app/src/features/tax/widgets/tax_disclaimer_bar.dart';
import 'package:openbudget_app/src/features/tax/widgets/tax_export_card.dart';
import 'package:openbudget_app/src/features/tax/widgets/tax_year_switcher.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The widest the two-column layout gets on a desktop window.
const double _panelMaxWidth = 1040;

/// The window width from which the panel sets its sections in two columns.
const double _twoColumnWidth = 760;

/// What the tax overview shows for a country with no tax rule pack.
///
/// The app cannot work out a tax bill there, so the panel shows what it does
/// know: the tax year, the country's VAT or sales tax rates with where each
/// comes from, a link to the tax authority, a running summary of the person's
/// own records, and a button to download that summary for an accountant. The
/// country facts come straight from the core dataset; only the summary and the
/// export call the server.
class UniversalTaxPanel extends HookConsumerWidget {
  const UniversalTaxPanel({
    required this.entityId,
    required this.entity,
    super.key,
  });

  final String entityId;
  final Entity entity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final country = Countries.byCode(entity.countryCode);
    if (country == null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: ObStatePanel.problem(
            title: l10n.taxOverviewLoadError,
            message: entity.countryCode,
          ),
        ),
      );
    }

    final selectedYear = useState<int?>(null);
    final summaryAsync = ref.watch(
      taxSummaryProvider(entityId, selectedYear.value),
    );
    final summary = summaryAsync.value;
    final lastDay = summary?.yearEnd.subtract(const Duration(days: 1));
    final dateFormat = DateFormat.yMMMd();
    final largeText = _isLargeText(context);
    final disclaimer = TaxDisclaimerBar(
      text: summary == null
          ? l10n.taxSummaryDisclaimer
          : taxSummaryDisclaimerText(l10n, summary.disclaimerKey),
    );

    return Column(
      children: [
        TaxYearSwitcher(
          label: summary == null
              ? l10n.taxUniversalYearLoading
              : l10n.taxUniversalYearLabel(summary.yearLabel),
          subtitle: summary == null
              ? null
              : l10n.taxUniversalYearPeriod(
                  dateFormat.format(summary.yearStart),
                  dateFormat.format(lastDay!),
                ),
          onPrevious: summary == null
              ? null
              : () => selectedYear.value = summary.startYear - 1,
          onNext: summary == null
              ? null
              : () => selectedYear.value = summary.startYear + 1,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final primary = [
                _IntroCard(country: country),
                const SizedBox(height: SpacingTokens.sm),
                _ChipRow(country: country, kind: entity.kind),
                _SummarySection(
                  entityId: entityId,
                  selectedYear: selectedYear.value,
                  summaryAsync: summaryAsync,
                  taxName: _taxName(l10n, country),
                ),
                const SizedBox(height: SpacingTokens.md),
                TaxExportCard(
                  entityId: entityId,
                  startYear: summary?.startYear ?? selectedYear.value,
                ),
              ];
              final secondary = [
                _RatesSection(country: country, on: _ratesDate(lastDay)),
                _AuthorityCard(country: country),
                _CaveatsSection(country: country),
              ];
              final twoColumns = constraints.maxWidth >= _twoColumnWidth;

              return ObReadableWidth(
                maxWidth: _panelMaxWidth,
                padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.md,
                  SpacingTokens.xs,
                  SpacingTokens.md,
                  SpacingTokens.xl,
                ),
                builder: (context, padding) => RefreshIndicator(
                  onRefresh: () async => ref.invalidate(
                    taxSummaryProvider(entityId, selectedYear.value),
                  ),
                  child: ListView(
                    padding: padding,
                    children: [
                      if (twoColumns)
                        _Sections(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: _Column(children: primary)),
                              const SizedBox(width: SpacingTokens.lg),
                              Expanded(child: _Column(children: secondary)),
                            ],
                          ),
                        )
                      else
                        for (final section in [...primary, ...secondary])
                          _Sections(child: section),
                      if (largeText) ...[
                        const SizedBox(height: SpacingTokens.md),
                        disclaimer,
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // At large text sizes a pinned bar would take most of the screen, so
        // the disclaimer scrolls with the page instead.
        if (!largeText) disclaimer,
      ],
    );
  }
}

/// Keeps the parts of [child] as separate stops for a screen reader.
///
/// A scrolling list reads each of its items as one phrase, which would fuse
/// a section's heading, figures and links into a single unreadable stop.
class _Sections extends HookWidget {
  const _Sections({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Semantics(explicitChildNodes: true, child: child);
}

/// A column of sections that fills the width it is given.
class _Column extends HookWidget {
  const _Column({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [for (final child in children) _Sections(child: child)],
  );
}

/// Whether the person has asked for text well above the default size.
bool _isLargeText(BuildContext context) =>
    MediaQuery.textScalerOf(context).scale(14) > 20;

/// The name of the country's indirect tax, such as "VAT".
String _taxName(AppLocalizations l10n, CountryInfo country) {
  final tax = country.indirectTax;
  return tax == null
      ? l10n.taxIndirectKindNone
      : taxIndirectKindLabel(l10n, tax.kind);
}

/// The day the shown rates should apply on: today, or the last day of the
/// tax year being looked at when that is already over.
DateTime _ratesDate(DateTime? lastDayOfYear) {
  final now = DateTime.now();
  final today = DateTime.utc(now.year, now.month, now.day);
  if (lastDayOfYear == null || lastDayOfYear.isAfter(today)) {
    return today;
  }
  return lastDayOfYear;
}

/// Opens [url] outside the app, telling the person in plain words when the
/// device has nothing to open it with.
Future<void> _openLink(BuildContext context, WidgetRef ref, Uri url) async {
  final message = AppLocalizations.of(context).taxLinkOpenFailed;
  var opened = false;
  try {
    opened = await ref.read(taxUrlLauncherProvider).openPage(url);
  } on Exception {
    opened = false;
  }
  if (!opened && context.mounted) {
    showAppToast(context, message: message, variant: AppToastVariant.error);
  }
}

/// "In plain words": why this panel looks different from a pack country's.
class _IntroCard extends HookWidget {
  const _IntroCard({required this.country});

  final CountryInfo country;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ObCard(
      key: const Key('tax-universal-intro'),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ObSpotDoodle(
            kind: WiredDoodleKind.sprout,
            spot: palette.highlighter,
            size: 64,
            seed: 11,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    l10n.taxUniversalIntroTitle(country.displayName),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  l10n.taxUniversalIntroMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipRow extends HookWidget {
  const _ChipRow({required this.country, required this.kind});

  final CountryInfo country;
  final EntityKind kind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
      child: Wrap(
        spacing: SpacingTokens.xs,
        runSpacing: SpacingTokens.xs,
        children: [
          ObToneChip(label: country.displayName, tone: ObTone.brand),
          ObToneChip(
            label: taxEntityKindLabel(l10n, kind),
            tone: ObTone.review,
          ),
        ],
      ),
    );
  }
}

/// The running totals from the person's own records.
class _SummarySection extends HookConsumerWidget {
  const _SummarySection({
    required this.entityId,
    required this.selectedYear,
    required this.summaryAsync,
    required this.taxName,
  });

  final String entityId;
  final int? selectedYear;
  final AsyncValue<TaxSummaryView> summaryAsync;
  final String taxName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ObSectionHeader(
          title: l10n.taxSummaryTitle,
          padding: const EdgeInsets.fromLTRB(
            0,
            SpacingTokens.sm,
            0,
            SpacingTokens.xs,
          ),
        ),
        summaryAsync.when(
          loading: () => Padding(
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.lg),
            child: Center(
              child: ObLoadingPanel(label: l10n.taxOverviewLoading),
            ),
          ),
          error: (error, _) => ObStatePanel.problem(
            title: l10n.taxSummaryLoadError,
            message: switch (error) {
              ValidationException(:final message) when message.isNotEmpty =>
                message,
              _ => null,
            },
            action: ObStateAction(
              label: l10n.taxCategoryLoadRetry,
              onPressed: () =>
                  ref.invalidate(taxSummaryProvider(entityId, selectedYear)),
            ),
          ),
          data: (summary) => _SummaryTotals(summary: summary, taxName: taxName),
        ),
      ],
    );
  }
}

class _SummaryTotals extends HookWidget {
  const _SummaryTotals({required this.summary, required this.taxName});

  final TaxSummaryView summary;
  final String taxName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final currency = summary.currencyCode;
    final income = formatMinorForCode(summary.totalIncomeMinor, currency);
    final hasSalesTax =
        summary.salesTaxCollectedMinor != 0 || summary.salesTaxPaidMinor != 0;
    final metrics = <({String label, String amount})>[
      (
        label: l10n.taxSummaryExpenses,
        amount: formatMinorForCode(summary.totalExpenseMinor, currency),
      ),
      if (summary.totalReliefMinor != 0)
        (
          label: l10n.taxSummaryReliefs,
          amount: formatMinorForCode(summary.totalReliefMinor, currency),
        ),
      (
        label: l10n.taxSummaryTaxPaid,
        amount: formatMinorForCode(summary.totalTaxPaidMinor, currency),
      ),
      if (hasSalesTax) ...[
        (
          label: l10n.taxSummarySalesTaxCollected(taxName),
          amount: formatMinorForCode(summary.salesTaxCollectedMinor, currency),
        ),
        (
          label: l10n.taxSummarySalesTaxPaid(taxName),
          amount: formatMinorForCode(summary.salesTaxPaidMinor, currency),
        ),
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ObCard(
          key: const Key('tax-summary-hero'),
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.taxSummaryIncome,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                  ),
                  ObCurrencyStamp(currency),
                ],
              ),
              const SizedBox(height: SpacingTokens.xs),
              ObAmount(
                income,
                highlighted: true,
                style: theme.textTheme.headlineMedium,
                semanticsLabel: '${l10n.taxSummaryIncome} $income',
              ),
              const SizedBox(height: SpacingTokens.md),
              _MetricGrid(metrics: metrics),
            ],
          ),
        ),
        if (summary.uncategorizedCount > 0) ...[
          const SizedBox(height: SpacingTokens.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              button: true,
              child: InkWell(
                key: const Key('tax-uncategorized-chip'),
                borderRadius: BorderRadius.circular(RadiusTokens.md),
                onTap: () => context.pushNamed(
                  transactionListRoute,
                  pathParameters: {'entityId': summary.entityId.uuid},
                ),
                child: ObToneChip(
                  label: l10n.taxUncategorizedCount(summary.uncategorizedCount),
                  tone: ObTone.underfunded,
                  icon: const SkribbleIcon(
                    data: OpenBudgetIcons.warning,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: SpacingTokens.xs),
            child: Text(
              l10n.taxUncategorizedHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.mutedInk,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Labelled amounts in two or three columns, or one when the text is large.
class _MetricGrid extends HookWidget {
  const _MetricGrid({required this.metrics});

  final List<({String label, String amount})> metrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final largeText = _isLargeText(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = largeText ? 1 : (constraints.maxWidth >= 420 ? 3 : 2);
        const gap = SpacingTokens.md;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: SpacingTokens.sm,
          children: [
            for (final metric in metrics)
              SizedBox(
                width: width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.ob.mutedInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    ObAmount(metric.amount, style: theme.textTheme.titleSmall),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// The country's VAT or sales tax rates, each with where it comes from.
class _RatesSection extends HookConsumerWidget {
  const _RatesSection({required this.country, required this.on});

  final CountryInfo country;

  /// The day the rates should apply on.
  final DateTime on;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final tax = country.indirectTax;
    final hasTax = tax != null && tax.kind != IndirectTaxKind.none;
    final decimalSeparator = NumberFormat.decimalPattern(
      Localizations.localeOf(context).toString(),
    ).symbols.DECIMAL_SEP;
    final current = tax == null
        ? const <IndirectTaxRate>[]
        : ratesInForce(tax.rates, on);
    final localName = tax?.localName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ObSectionHeader(
          title: hasTax
              ? l10n.taxIndirectTitle(taxIndirectKindLabel(l10n, tax.kind))
              : l10n.taxIndirectKindNone,
          padding: const EdgeInsets.fromLTRB(
            0,
            SpacingTokens.lg,
            0,
            SpacingTokens.xs,
          ),
        ),
        if (tax == null)
          Text(
            l10n.taxIndirectUnknown,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.mutedInk,
            ),
          )
        else if (!hasTax)
          Text(
            l10n.taxIndirectNone(country.displayName),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.mutedInk,
            ),
          )
        else ...[
          if (localName != null &&
              localName.toLowerCase() !=
                  taxIndirectKindLabel(l10n, tax.kind).toLowerCase())
            Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
              child: Text(
                l10n.taxIndirectLocalName(localName),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedInk,
                ),
              ),
            ),
          if (current.isEmpty)
            Text(
              l10n.taxIndirectNoRateForYear,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.mutedInk,
              ),
            )
          else
            for (final rate in current)
              _RateCard(
                rate: rate,
                source: country.sources.elementAtOrNull(rate.source),
                decimalSeparator: decimalSeparator,
              ),
          if (tax.subdivisions.isNotEmpty)
            _RegionalRates(
              subdivisions: tax.subdivisions,
              on: on,
              decimalSeparator: decimalSeparator,
            ),
        ],
      ],
    );
  }
}

/// One rate: the figure, what it applies to, how sure we are, and the source.
class _RateCard extends HookConsumerWidget {
  const _RateCard({
    required this.rate,
    required this.source,
    required this.decimalSeparator,
  });

  final IndirectTaxRate rate;
  final SourceInfo? source;
  final String decimalSeparator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final figure = l10n.taxRatePercent(
      formatRatePerMillion(
        rate.ratePerMillion,
        decimalSeparator: decimalSeparator,
      ),
    );
    final grade = source?.grade;
    final sourceUrl = source == null ? null : webLink(source!.url);

    return ObCard(
      key: Key('tax-rate-${rate.label}-${rate.ratePerMillion}'),
      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MergeSemantics(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      figure,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: palette.ink,
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            toBeginningOfSentenceCase(rate.label),
                            style: theme.textTheme.titleSmall,
                          ),
                          if (rate.appliesTo case final scope?)
                            Text(
                              l10n.taxRateAppliesTo(scope),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: palette.mutedInk,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SpacingTokens.xs),
                Wrap(
                  spacing: SpacingTokens.xs,
                  runSpacing: SpacingTokens.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (grade != null)
                      ObToneChip(
                        key: grade == SourceGrade.secondary
                            ? const Key('tax-secondary-source-badge')
                            : null,
                        label: taxSourceGradeLabel(l10n, grade),
                        tone: switch (grade) {
                          SourceGrade.primary => ObTone.funded,
                          SourceGrade.secondary => ObTone.review,
                          SourceGrade.inferred => ObTone.underfunded,
                          SourceGrade.background => ObTone.neutral,
                        },
                      ),
                    Text(
                      l10n.taxRateSince(DateFormat.yMMMd().format(rate.from)),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (source case final cited?) ...[
            const SizedBox(height: SpacingTokens.xs),
            if (sourceUrl == null)
              Text(
                l10n.taxRateSource(cited.title),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedInk,
                ),
              )
            else
              Semantics(
                link: true,
                label: l10n.taxRateSourceOpen(cited.title),
                excludeSemantics: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(RadiusTokens.sm),
                  onTap: () => _openLink(context, ref, sourceUrl),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.taxRateSource(cited.title),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.brand,
                          decoration: TextDecoration.underline,
                          decorationColor: palette.brand,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Rates that differ by region, kept out of the way until asked for.
class _RegionalRates extends HookWidget {
  const _RegionalRates({
    required this.subdivisions,
    required this.on,
    required this.decimalSeparator,
  });

  final List<IndirectTaxSubdivision> subdivisions;
  final DateTime on;
  final String decimalSeparator;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ObCard(
      key: const Key('tax-regional-rates'),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
        childrenPadding: const EdgeInsets.fromLTRB(
          SpacingTokens.md,
          0,
          SpacingTokens.md,
          SpacingTokens.md,
        ),
        title: Text(
          l10n.taxRegionalRatesTitle,
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Text(
          l10n.taxRegionalRatesHint,
          style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedInk),
        ),
        children: [
          for (final subdivision in subdivisions)
            _regionRow(context, subdivision),
        ],
      ),
    );
  }

  Widget _regionRow(BuildContext context, IndirectTaxSubdivision subdivision) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final current = ratesInForce(subdivision.rates, on);
    if (current.isEmpty) {
      return const SizedBox.shrink();
    }
    final rates = [
      for (final rate in current)
        '${_rateName(rate.label)} ${l10n.taxRatePercent(
          formatRatePerMillion(
            rate.ratePerMillion,
            decimalSeparator: decimalSeparator,
          ),
        )}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
      child: MergeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 72,
              child: Text(subdivision.code, style: theme.textTheme.labelLarge),
            ),
            Expanded(child: Text(rates, style: theme.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }
}

/// A short rate label as written: `QST` for `qst`, `Standard` for `standard`.
String _rateName(String label) =>
    label.length <= 4 ? label.toUpperCase() : toBeginningOfSentenceCase(label);

/// The link to the country's tax authority.
class _AuthorityCard extends HookConsumerWidget {
  const _AuthorityCard({required this.country});

  final CountryInfo country;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authority = country.authority;
    if (authority == null) {
      return const SizedBox.shrink();
    }
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final url = webLink(authority.url);

    final content = Padding(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        children: [
          const ObIconBadge(
            icon: SkribbleIcon(data: OpenBudgetIcons.externalLink),
            spot: 4,
            seed: 5,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.taxAuthorityTitle,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
                Text(authority.name, style: theme.textTheme.titleSmall),
                if (url != null)
                  Text(
                    url.host,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.brand,
                      decoration: TextDecoration.underline,
                      decorationColor: palette.brand,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.sm),
      child: url == null
          ? ObCard(child: content)
          : Semantics(
              link: true,
              label: l10n.taxAuthorityOpen(authority.name),
              excludeSemantics: true,
              child: Tooltip(
                message: l10n.taxAuthorityOpen(authority.name),
                child: ObCard(
                  key: const Key('tax-authority-link'),
                  onTap: () => _openLink(context, ref, url),
                  child: content,
                ),
              ),
            ),
    );
  }
}

/// What the country data could not fully stand behind, and when it was last
/// checked.
class _CaveatsSection extends HookWidget {
  const _CaveatsSection({required this.country});

  final CountryInfo country;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final verifiedOn = country.verifiedOn;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (country.caveats.isNotEmpty) ...[
          ObSectionHeader(
            title: l10n.taxUnverifiedTitle,
            padding: const EdgeInsets.fromLTRB(
              0,
              SpacingTokens.lg,
              0,
              SpacingTokens.xs,
            ),
          ),
          for (final (index, caveat) in country.caveats.indexed)
            TaxCaveatCard(key: Key('tax-country-caveat-$index'), text: caveat),
        ],
        if (verifiedOn != null)
          Padding(
            padding: const EdgeInsets.only(top: SpacingTokens.sm),
            child: Text(
              l10n.taxUniversalVerifiedOn(
                DateFormat.yMMMd().format(verifiedOn),
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.ob.mutedInk,
              ),
            ),
          ),
      ],
    );
  }
}
