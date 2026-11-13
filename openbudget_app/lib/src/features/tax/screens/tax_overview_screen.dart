import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/features/tax/tax_formatting.dart';
import 'package:openbudget_app/src/features/tax/tax_labels.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The budget's tax position for a chosen year, with the workings behind it.
class TaxOverviewScreen extends HookConsumerWidget {
  const TaxOverviewScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final profileAsync = ref.watch(taxProfileProvider(entityId));
    final hasProfile = profileAsync.hasValue && profileAsync.value != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.taxOverviewTitle),
        actions: [
          if (hasProfile)
            IconButton(
              tooltip: l10n.taxProfileTitle,
              icon: const SkribbleIcon(data: OpenBudgetIcons.edit),
              onPressed: () => context.pushNamed(
                taxProfileRoute,
                pathParameters: {'entityId': entityId},
              ),
            ),
        ],
      ),
      body: profileAsync.when(
        loading: () => Center(
          child: ObLoadingPanel(label: l10n.taxOverviewLoading),
        ),
        error: (error, _) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: ObStatePanel.problem(
              title: l10n.taxProfileLoadError,
              message: taxErrorMessage(error, l10n.taxProfileLoadError),
              action: ObStateAction(
                label: l10n.taxCategoryLoadRetry,
                onPressed: () => ref.invalidate(taxProfileProvider(entityId)),
              ),
            ),
          ),
        ),
        data: (record) => record == null
            ? Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(SpacingTokens.lg),
                  child: ObStatePanel.empty(
                    title: l10n.taxSetupTitle,
                    message: l10n.taxSetupMessage,
                    action: ObStateAction(
                      label: l10n.taxSetupAction,
                      onPressed: () => context.pushNamed(
                        taxProfileRoute,
                        pathParameters: {'entityId': entityId},
                      ),
                    ),
                  ),
                ),
              )
            : _TaxReportBody(
                key: ValueKey(
                  '${record.updatedAt.microsecondsSinceEpoch}-'
                  '${record.profileJson.hashCode}',
                ),
                entityId: entityId,
                record: record,
              ),
      ),
      bottomNavigationBar: hasProfile
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: palette.surface,
                border: Border(top: BorderSide(color: palette.line)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.md,
                    SpacingTokens.sm,
                    SpacingTokens.md,
                    SpacingTokens.sm,
                  ),
                  child: Text(
                    l10n.taxDisclaimer,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _TaxReportBody extends HookConsumerWidget {
  const _TaxReportBody({
    required this.entityId,
    required this.record,
    super.key,
  });

  final String entityId;
  final TaxProfileRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entityAsync = ref.watch(entityDetailProvider(entityId));
    final entity = entityAsync.value;
    final jurisdiction = entity == null
        ? null
        : TaxJurisdiction.fromCountryCode(entity.countryCode);
    if (jurisdiction == null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: ObStatePanel.problem(
            title: l10n.taxOverviewLoadError,
            message: entity?.countryCode ?? '',
          ),
        ),
      );
    }

    final selectedYear = useState<int?>(null);
    final startYear = selectedYear.value ?? currentTaxYearStart(jurisdiction);
    final reportAsync = ref.watch(taxReportProvider(entityId, startYear));
    final report = reportAsync.value;
    final entityKind = entity?.kind;

    return Column(
      children: [
        _YearSwitcher(
          label: l10n.taxYearLabel(report?.startYear ?? startYear),
          onPrevious: () => selectedYear.value = startYear - 1,
          onNext: () => selectedYear.value = startYear + 1,
        ),
        Expanded(
          child: reportAsync.when(
            loading: () => Center(
              child: ObLoadingPanel(label: l10n.taxOverviewLoading),
            ),
            error: (error, _) => Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                child: ObStatePanel.problem(
                  title: _isRulesUnavailable(error)
                      ? l10n.taxRulesUnavailableTitle
                      : l10n.taxOverviewLoadError,
                  message: _isRulesUnavailable(error)
                      ? l10n.taxRulesUnavailableMessage
                      : taxErrorMessage(error, l10n.taxOverviewLoadError),
                  action: ObStateAction(
                    label: l10n.taxCategoryLoadRetry,
                    onPressed: () => ref.invalidate(
                      taxReportProvider(entityId, startYear),
                    ),
                  ),
                ),
              ),
            ),
            data: (report) => RefreshIndicator(
              onRefresh: () async =>
                  ref.invalidate(taxReportProvider(entityId, startYear)),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.md,
                  SpacingTokens.xs,
                  SpacingTokens.md,
                  SpacingTokens.xl,
                ),
                children: [
                  if (report.maturity == TaxPackMaturity.preview.name) ...[
                    const _PreviewBanner(),
                    const SizedBox(height: SpacingTokens.sm),
                  ],
                  Wrap(
                    spacing: SpacingTokens.xs,
                    runSpacing: SpacingTokens.xs,
                    children: [
                      ObToneChip(
                        label: taxJurisdictionLabel(l10n, jurisdiction),
                        tone: ObTone.brand,
                      ),
                      if (entityKind != null)
                        ObToneChip(
                          label: taxEntityKindLabel(l10n, entityKind),
                          tone: ObTone.review,
                        ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  _BalanceHero(report: report),
                  if (report.uncategorizedCount > 0) ...[
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
                            pathParameters: {'entityId': entityId},
                          ),
                          child: ObToneChip(
                            label: l10n.taxUncategorizedCount(
                              report.uncategorizedCount,
                            ),
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).ob.mutedInk,
                        ),
                      ),
                    ),
                  ],
                  if (report.convertedEntryCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: SpacingTokens.xs),
                      child: Text(
                        l10n.taxConvertedEntries(report.convertedEntryCount),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).ob.mutedInk,
                        ),
                      ),
                    ),
                  ObSectionHeader(
                    title: l10n.taxLiabilitiesTitle,
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      SpacingTokens.lg,
                      0,
                      SpacingTokens.xs,
                    ),
                  ),
                  if (report.liabilities.isEmpty)
                    Text(
                      l10n.taxLiabilitiesEmpty,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).ob.mutedInk,
                      ),
                    )
                  else
                    for (final liability in report.liabilities)
                      _LiabilityCard(
                        liability: liability,
                        currency: report.currencyCode,
                      ),
                  ObSectionHeader(
                    title: l10n.taxReportLinesTitle,
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      SpacingTokens.lg,
                      0,
                      SpacingTokens.xs,
                    ),
                  ),
                  _ReportLinesCard(report: report),
                  if (report.opportunities.isNotEmpty) ...[
                    ObSectionHeader(
                      title: l10n.taxOpportunitiesTitle,
                      padding: const EdgeInsets.fromLTRB(
                        0,
                        SpacingTokens.lg,
                        0,
                        SpacingTokens.xs,
                      ),
                    ),
                    for (final opportunity in report.opportunities)
                      _OpportunityCard(
                        opportunity: opportunity,
                        currency: report.currencyCode,
                      ),
                  ],
                  const SizedBox(height: SpacingTokens.md),
                  _HowWorkedOutCard(report: report),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _YearSwitcher extends HookWidget {
  const _YearSwitcher({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
      child: Row(
        children: [
          IconButton(
            key: const Key('tax-year-previous'),
            tooltip: l10n.taxPreviousYear,
            onPressed: onPrevious,
            icon: const SkribbleIcon(data: OpenBudgetIcons.chevronLeft),
          ),
          Expanded(
            child: Text(
              label,
              key: const Key('tax-year-label'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          IconButton(
            key: const Key('tax-year-next'),
            tooltip: l10n.taxNextYear,
            onPressed: onNext,
            icon: const SkribbleIcon(data: OpenBudgetIcons.chevronRight),
          ),
        ],
      ),
    );
  }
}

/// The preview warning shown while a country pack awaits review.
class _PreviewBanner extends HookWidget {
  const _PreviewBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ObCard(
      key: const Key('tax-preview-banner'),
      tone: ObTone.review,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkribbleIcon(
            data: OpenBudgetIcons.warning,
            size: 20,
            color: palette.hue(ObTone.review),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(
            child: Text(
              l10n.taxPreviewBanner,
              style: theme.textTheme.bodyMedium?.copyWith(color: palette.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceHero extends HookWidget {
  const _BalanceHero({required this.report});

  final TaxReportView report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final currency = report.currencyCode;
    final balance = report.balanceDueMinor;
    final isRefund = balance < 0;
    final label = balance > 0
        ? l10n.taxBalanceDue
        : isRefund
        ? l10n.taxRefundDue
        : l10n.taxNothingToPay;
    final amount = formatMinorForCode(balance.abs(), currency);

    return ObCard(
      tone: isRefund
          ? ObTone.funded
          : balance > 0
          ? ObTone.underfunded
          : null,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: palette.mutedInk,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          ObAmount(
            amount,
            highlighted: true,
            style: theme.textTheme.headlineMedium,
            semanticsLabel: '$label $amount',
          ),
          const SizedBox(height: SpacingTokens.md),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: l10n.taxTotalLiability,
                  amount: formatMinorForCode(
                    report.totalLiabilityMinor,
                    currency,
                  ),
                ),
              ),
              const SizedBox(
                height: 32,
                child: VerticalDivider(width: 16),
              ),
              Expanded(
                child: _Metric(
                  label: l10n.taxAlreadyPaid,
                  amount: formatMinorForCode(report.alreadyPaidMinor, currency),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends HookWidget {
  const _Metric({required this.label, required this.amount});

  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.ob.mutedInk,
          ),
        ),
        const SizedBox(height: 2),
        ObAmount(amount, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

class _LiabilityCard extends HookWidget {
  const _LiabilityCard({required this.liability, required this.currency});

  final TaxLiabilityView liability;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final expanded = useState(false);
    final hasBands = liability.bands.isNotEmpty;

    return ObCard(
      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: hasBands ? () => expanded.value = !expanded.value : null,
            borderRadius: BorderRadius.circular(RadiusTokens.md),
            child: Semantics(
              button: hasBands,
              expanded: hasBands ? expanded.value : null,
              hint: hasBands
                  ? expanded.value
                        ? l10n.taxBandsHide
                        : l10n.taxBandsShow
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: Row(
                  children: [
                    SkribbleIcon(
                      data: OpenBudgetIcons.scale,
                      size: 20,
                      color: palette.mutedInk,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: Text(
                        liability.label,
                        style: theme.textTheme.titleSmall,
                      ),
                    ),
                    ObAmount(
                      formatMinorForCode(liability.amountMinor, currency),
                      style: theme.textTheme.titleSmall,
                    ),
                    if (hasBands) ...[
                      const SizedBox(width: SpacingTokens.xs),
                      SkribbleIcon(
                        data: expanded.value
                            ? OpenBudgetIcons.chevronUp
                            : OpenBudgetIcons.chevronDown,
                        size: 18,
                        color: palette.mutedInk,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (expanded.value)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                0,
                SpacingTokens.md,
                SpacingTokens.md,
              ),
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: SpacingTokens.xs),
                  for (final (index, band) in liability.bands.indexed) ...[
                    if (index > 0) const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: SpacingTokens.xs,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  band.label,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  l10n.taxBandRate(
                                    formatRateBasisPoints(
                                      band.rateBasisPoints,
                                    ),
                                  ),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: palette.mutedInk,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  l10n.taxBandBaseColumn,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: palette.mutedInk,
                                  ),
                                ),
                                ObAmount(
                                  formatMinorForCode(band.baseMinor, currency),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  l10n.taxBandTaxColumn,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: palette.mutedInk,
                                  ),
                                ),
                                ObAmount(
                                  formatMinorForCode(band.taxMinor, currency),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ReportLinesCard extends HookWidget {
  const _ReportLinesCard({required this.report});

  final TaxReportView report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final currency = report.currencyCode;

    return ObCard(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      child: report.lines.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
              child: Text(
                l10n.taxReportLinesEmpty,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: palette.mutedInk,
                ),
              ),
            )
          : Column(
              children: [
                for (final (index, line) in report.lines.indexed) ...[
                  if (index > 0) const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: SpacingTokens.sm,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                line.label,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: palette.ink,
                                ),
                              ),
                              if (line.reportReference case final reference?)
                                Text(
                                  reference,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: palette.mutedInk,
                                  ),
                                ),
                              if (line.entryCount > 0)
                                Text(
                                  l10n.taxEntryCount(line.entryCount),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: palette.mutedInk,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        ObAmount(
                          formatMinorForCode(line.amountMinor, currency),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _OpportunityCard extends HookWidget {
  const _OpportunityCard({required this.opportunity, required this.currency});

  final TaxOpportunityView opportunity;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final saving = opportunity.estimatedSavingMinor;
    final deadline = opportunity.deadline;

    return ObCard(
      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            opportunity.title,
            style: theme.textTheme.titleSmall?.copyWith(color: palette.ink),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            opportunity.explanation,
            style: theme.textTheme.bodyMedium?.copyWith(color: palette.ink),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Wrap(
            spacing: SpacingTokens.xs,
            runSpacing: SpacingTokens.xs,
            children: [
              if (saving != null)
                ObToneChip(
                  label: l10n.taxOpportunitySaving(
                    formatMinorForCode(saving, currency),
                  ),
                  tone: ObTone.funded,
                  icon: const SkribbleIcon(
                    data: OpenBudgetIcons.savings,
                    size: 16,
                  ),
                ),
              if (deadline != null)
                ObToneChip(
                  label: l10n.taxOpportunityDeadline(
                    DateFormat.yMMMd().format(deadline.toLocal()),
                  ),
                  tone: ObTone.underfunded,
                  icon: const SkribbleIcon(
                    data: OpenBudgetIcons.schedule,
                    size: 16,
                  ),
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            l10n.taxOpportunitySource,
            style: theme.textTheme.labelSmall?.copyWith(
              color: palette.mutedInk,
            ),
          ),
          SelectableText(
            opportunity.source,
            style: theme.textTheme.bodySmall?.copyWith(color: palette.brand),
          ),
        ],
      ),
    );
  }
}

class _HowWorkedOutCard extends HookWidget {
  const _HowWorkedOutCard({required this.report});

  final TaxReportView report;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ObCard(
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
          l10n.taxHowWorkedOutTitle,
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Text(
          l10n.taxRulesVerifiedOn(
            DateFormat.yMMMd().format(report.rulesVerifiedOn.toLocal()),
          ),
          style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedInk),
        ),
        leading: SkribbleIcon(
          data: OpenBudgetIcons.insight,
          color: palette.mutedInk,
        ),
        children: [
          if (report.assumptions.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.taxAssumptionsTitle,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: palette.mutedInk,
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            for (final assumption in report.assumptions)
              Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExcludeSemantics(
                      child: Text('• ', style: theme.textTheme.bodyMedium),
                    ),
                    Expanded(
                      child: Text(
                        assumption,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: palette.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (report.sources.isNotEmpty) ...[
            const SizedBox(height: SpacingTokens.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.taxSourcesTitle,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: palette.mutedInk,
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            for (final source in report.sources)
              Padding(
                padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
                child: SelectableText(
                  source,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.brand,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

bool _isRulesUnavailable(Object error) => error is TaxRulesUnavailableException;
