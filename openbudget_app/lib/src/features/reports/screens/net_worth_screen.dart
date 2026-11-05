import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/reports/widgets/report_figures.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Every active account, written down as one net worth statement.
class NetWorthScreen extends HookConsumerWidget {
  const NetWorthScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dataAsync = ref.watch(netWorthProvider(budgetId));
    final converter = ref
        .watch(displayCurrencyConverterProvider(budgetId))
        .asData
        ?.value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.netWorthTitle)),
      body: dataAsync.when(
        loading: () =>
            Center(child: ObLoadingPanel(label: l10n.reportsLoading)),
        error: (error, _) => ListView(
          padding: const EdgeInsets.all(SpacingTokens.md),
          children: [
            ObStatePanel.problem(
              title: l10n.netWorthLoadError,
              message: error.toString(),
            ),
          ],
        ),
        data: (data) => _NetWorthStatement(data: data, converter: converter),
      ),
    );
  }
}

class _NetWorthStatement extends HookWidget {
  const _NetWorthStatement({required this.data, required this.converter});

  final NetWorthData data;
  final DisplayCurrencyConverter? converter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
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
    final primaryBreakdown = data.currencyBreakdown.firstOrNull;
    final primaryCurrency = useConverted
        ? converter!.displayCurrency!.code
        : (primaryBreakdown?.currency ?? '');
    final primaryNetWorth = useConverted
        ? convertedNetWorth
        : (primaryBreakdown?.netWorth ?? 0);
    final primaryAssets = useConverted
        ? convertedAssets
        : (primaryBreakdown?.totalAssets ?? 0);
    final primaryLiabilities = useConverted
        ? convertedLiabilities
        : (primaryBreakdown?.totalLiabilities ?? 0);
    final hasMultipleDisplayCurrencies =
        !useConverted && data.hasMultipleCurrencies;
    final netWorthTone = hasMultipleDisplayCurrencies
        ? ObTone.brand
        : primaryNetWorth >= 0
        ? ObTone.funded
        : ObTone.overspent;
    final heroAmountLabel = hasMultipleDisplayCurrencies
        ? formatCurrencyBreakdown({
            for (final breakdown in data.currencyBreakdown)
              breakdown.currency: breakdown.netWorth,
          })
        : formatCentsForCode(primaryNetWorth, primaryCurrency);
    final hasAccounts =
        data.assetAccounts.isNotEmpty || data.liabilityAccounts.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.sm,
        SpacingTokens.md,
        SpacingTokens.xl,
      ),
      children: [
        ObCard(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SkribbleIcon(
                    data: OpenBudgetIcons.scale,
                    size: 20,
                    color: palette.brand,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Text(
                    l10n.reportsNetWorthCurrent,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: palette.mutedInk,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              ObAmount(
                heroAmountLabel,
                tone: netWorthTone,
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: SpacingTokens.md),
              Row(
                children: [
                  Expanded(
                    child: ReportFigure(
                      label: l10n.netWorthAssets,
                      amount: formatCentsForCode(
                        primaryAssets,
                        primaryCurrency,
                      ),
                      tone: ObTone.funded,
                    ),
                  ),
                  Expanded(
                    child: ReportFigure(
                      label: l10n.netWorthLiabilities,
                      amount: formatCentsForCode(
                        primaryLiabilities,
                        primaryCurrency,
                      ),
                      tone: ObTone.overspent,
                      alignEnd: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (hasMultipleDisplayCurrencies) ...[
          const SizedBox(height: SpacingTokens.md),
          ObCard(
            child: Column(
              children: [
                for (final (index, breakdown)
                    in data.currencyBreakdown.indexed) ...[
                  _CurrencySummaryRow(currency: breakdown),
                  if (index < data.currencyBreakdown.length - 1)
                    Divider(height: 1, color: palette.line),
                ],
              ],
            ),
          ),
        ],
        if (data.assetAccounts.isNotEmpty) ...[
          ObSectionHeader(
            title: l10n.netWorthAssets,
            padding: const EdgeInsets.fromLTRB(
              0,
              SpacingTokens.lg,
              0,
              SpacingTokens.sm,
            ),
          ),
          ObCard(
            child: Column(
              children: [
                for (final (index, account) in data.assetAccounts.indexed) ...[
                  _AccountTile(account: account),
                  if (index < data.assetAccounts.length - 1)
                    Divider(height: 1, color: palette.line),
                ],
              ],
            ),
          ),
        ],
        if (data.liabilityAccounts.isNotEmpty) ...[
          ObSectionHeader(
            title: l10n.netWorthLiabilities,
            padding: const EdgeInsets.fromLTRB(
              0,
              SpacingTokens.lg,
              0,
              SpacingTokens.sm,
            ),
          ),
          ObCard(
            child: Column(
              children: [
                for (final (index, account)
                    in data.liabilityAccounts.indexed) ...[
                  _AccountTile(account: account),
                  if (index < data.liabilityAccounts.length - 1)
                    Divider(height: 1, color: palette.line),
                ],
              ],
            ),
          ),
        ],
        if (!hasAccounts) ...[
          const SizedBox(height: SpacingTokens.lg),
          ObStatePanel.empty(
            title: l10n.netWorthEmptyTitle,
            message: l10n.netWorthEmptySubtitle,
            doodle: WiredDoodleKind.balloon,
          ),
        ],
        if (hasAccounts) ...[
          ObSectionHeader(
            title: l10n.reportsNetWorthExplainerTitle,
            padding: const EdgeInsets.fromLTRB(
              0,
              SpacingTokens.lg,
              0,
              SpacingTokens.sm,
            ),
          ),
          ObCard(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkribbleIcon(
                  data: OpenBudgetIcons.insight,
                  size: 20,
                  color: palette.review,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    l10n.reportsNetWorthExplainerBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.mutedInk,
                    ),
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

class _CurrencySummaryRow extends HookWidget {
  const _CurrencySummaryRow({required this.currency});

  final CurrencyNetWorthData currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final total = currency.totalAssets + currency.totalLiabilities;
    final tone = total >= 0 ? ObTone.funded : ObTone.overspent;

    return Padding(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                normalizeCurrencyCode(currency.currency),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: palette.ink,
                ),
              ),
              const Spacer(),
              ObAmount(
                formatCentsForCode(total, currency.currency),
                tone: tone,
                style: theme.textTheme.titleSmall,
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          Row(
            children: [
              Expanded(
                child: ReportFigure(
                  label: l10n.netWorthAssets,
                  amount: formatCentsForCode(
                    currency.totalAssets,
                    currency.currency,
                  ),
                  tone: ObTone.funded,
                ),
              ),
              Expanded(
                child: ReportFigure(
                  label: l10n.netWorthLiabilities,
                  amount: formatCentsForCode(
                    currency.totalLiabilities,
                    currency.currency,
                  ),
                  tone: ObTone.overspent,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends HookWidget {
  const _AccountTile({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final tone = account.balanceCents >= 0 ? ObTone.funded : ObTone.overspent;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.xs,
      ),
      leading: SizedBox.square(
        dimension: 40,
        child: DecoratedBox(
          decoration: ObRoughDecoration(
            color: palette.highlight,
            outline: palette.quietPen,
            radius: 10,
            strokeWidth: 1.6,
            seed: 57,
          ),
          child: Center(
            child: SkribbleIcon(
              data: _accountIcon(account.accountType),
              size: 20,
              color: palette.brand,
            ),
          ),
        ),
      ),
      title: Text(account.name),
      subtitle: Text(
        _accountTypeLabel(l10n, account.accountType),
        style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedInk),
      ),
      trailing: ObAmount(
        formatCentsForCode(account.balanceCents, account.currencyCode),
        tone: tone,
        style: theme.textTheme.bodyLarge,
      ),
    );
  }

  WiredSvgIconData _accountIcon(String type) => switch (type) {
    'checking' => OpenBudgetIcons.bank,
    'savings' => OpenBudgetIcons.savings,
    'creditCard' => OpenBudgetIcons.creditCard,
    'cash' => OpenBudgetIcons.cash,
    'investment' => OpenBudgetIcons.trendingUp,
    'cryptoWallet' => OpenBudgetIcons.solana,
    _ => OpenBudgetIcons.wallet,
  };

  String _accountTypeLabel(AppLocalizations l10n, String type) =>
      switch (type) {
        'checking' => l10n.accountTypeChecking,
        'savings' => l10n.accountTypeSavings,
        'creditCard' => l10n.accountTypeCreditCard,
        'cash' => l10n.accountTypeCash,
        'investment' => l10n.accountTypeInvestment,
        'cryptoWallet' => l10n.accountTypeCryptoWallet,
        _ => l10n.accountTypeOther,
      };
}
