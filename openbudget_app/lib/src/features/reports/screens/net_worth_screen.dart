import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class NetWorthScreen extends HookConsumerWidget {
  const NetWorthScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dataAsync = ref.watch(netWorthProvider(budgetId));
    final converter = ref
        .watch(displayCurrencyConverterProvider(budgetId))
        .asData
        ?.value;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.netWorthTitle)),
      body: dataAsync.when(
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
                l10n.netWorthLoadError,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        data: (data) {
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
          final convertedAssets = converter?.convertTotalsToDisplay(
            assetsByCurrency,
          );
          final convertedLiabilities = converter?.convertTotalsToDisplay(
            liabilitiesByCurrency,
          );
          final useConverted =
              convertedNetWorth != null &&
              convertedAssets != null &&
              convertedLiabilities != null;
          final primaryBreakdown = data.currencyBreakdown.firstOrNull;
          final primaryCurrency = useConverted
              ? converter!.displayCurrency
              : (primaryBreakdown?.currency ?? CurrencyCode.usd);
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
          final netWorthColor = hasMultipleDisplayCurrencies
              ? colorScheme.primary
              : primaryNetWorth >= 0
              ? ColorTokens.secondary
              : ColorTokens.error;
          final heroAmountLabel = hasMultipleDisplayCurrencies
              ? formatCurrencyBreakdown({
                  for (final breakdown in data.currencyBreakdown)
                    breakdown.currency: breakdown.netWorth,
                })
              : formatCents(primaryNetWorth, primaryCurrency);

          return ListView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            children: [
              // Net worth hero card
              Container(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                decoration: BoxDecoration(
                  color: netWorthColor.withAlpha(15),
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                  border: Border.all(color: netWorthColor.withAlpha(60)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Current',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: netWorthColor.withAlpha(200),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      heroAmountLabel,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: netWorthColor,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${l10n.netWorthAssets} ${formatCents(primaryAssets, primaryCurrency)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: ColorTokens.secondary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '${l10n.netWorthLiabilities} ${formatCents(primaryLiabilities, primaryCurrency)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: ColorTokens.error,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.md),

              // Assets vs liabilities summary rows.
              if (!hasMultipleDisplayCurrencies)
                Row(
                  children: [
                    Expanded(
                      child: _SummaryChip(
                        label: l10n.netWorthAssets,
                        amount: formatCents(primaryAssets, primaryCurrency),
                        color: ColorTokens.secondary,
                      ),
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: _SummaryChip(
                        label: l10n.netWorthLiabilities,
                        amount: formatCents(
                          primaryLiabilities,
                          primaryCurrency,
                        ),
                        color: ColorTokens.error,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    for (final breakdown in data.currencyBreakdown) ...[
                      _CurrencySummaryRow(
                        currency: breakdown.currency,
                        assets: breakdown.totalAssets,
                        liabilities: breakdown.totalLiabilities,
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                    ],
                  ],
                ),
              const SizedBox(height: SpacingTokens.lg),

              // Asset accounts
              if (data.assetAccounts.isNotEmpty) ...[
                Text(
                  l10n.netWorthAssets,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < data.assetAccounts.length; i++) ...[
                        _AccountTile(account: data.assetAccounts[i]),
                        if (i < data.assetAccounts.length - 1)
                          const Divider(height: 1),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
              ],

              // Liability accounts
              if (data.liabilityAccounts.isNotEmpty) ...[
                Text(
                  l10n.netWorthLiabilities,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                Card(
                  child: Column(
                    children: [
                      for (
                        var i = 0;
                        i < data.liabilityAccounts.length;
                        i++
                      ) ...[
                        _AccountTile(account: data.liabilityAccounts[i]),
                        if (i < data.liabilityAccounts.length - 1)
                          const Divider(height: 1),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
              ],

              // Empty state
              if (data.assetAccounts.isEmpty && data.liabilityAccounts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: SpacingTokens.xl,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 48,
                          color: colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        Text(
                          l10n.netWorthEmptyTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: SpacingTokens.sm),
                        Text(
                          l10n.netWorthEmptySubtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              if (data.assetAccounts.isNotEmpty ||
                  data.liabilityAccounts.isNotEmpty) ...[
                Text(
                  'Understanding Net Worth',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: Text(
                      'Net worth summarizes all active accounts in your plan. '
                      'Use it as a simple snapshot of where you stand today: '
                      'assets minus liabilities.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SummaryChip extends HookWidget {
  const _SummaryChip({
    required this.label,
    required this.amount,
    required this.color,
  });

  final String label;
  final String amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color.withAlpha(180),
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            amount,
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencySummaryRow extends HookWidget {
  const _CurrencySummaryRow({
    required this.currency,
    required this.assets,
    required this.liabilities,
  });

  final CurrencyCode currency;
  final int assets;
  final int liabilities;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.sm,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                currency.code,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                formatCents(assets + liabilities, currency),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: assets + liabilities >= 0
                      ? ColorTokens.secondary
                      : ColorTokens.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.netWorthAssets}: ${formatCents(assets, currency)}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Text(
                  '${l10n.netWorthLiabilities}: ${formatCents(liabilities, currency)}',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.end,
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
    final theme = Theme.of(context);
    final currency = parseCurrencyCode(account.currencyCode);
    final balanceColor = account.balanceCents >= 0
        ? ColorTokens.secondary
        : ColorTokens.error;

    return ListTile(
      leading: Icon(
        _accountIcon(account.accountType),
        color: theme.colorScheme.primary,
      ),
      title: Text(account.name),
      subtitle: Text(
        _accountTypeLabel(account.accountType),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        formatCents(account.balanceCents, currency),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: balanceColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _accountIcon(String type) {
    return switch (type) {
      'checking' => Icons.account_balance_rounded,
      'savings' => Icons.savings_rounded,
      'creditCard' => Icons.credit_card_rounded,
      'cash' => Icons.money_rounded,
      'investment' => Icons.trending_up_rounded,
      'cryptoWallet' => Icons.currency_bitcoin_rounded,
      _ => Icons.account_balance_wallet_rounded,
    };
  }

  String _accountTypeLabel(String type) {
    return switch (type) {
      'checking' => 'Checking',
      'savings' => 'Savings',
      'creditCard' => 'Credit Card',
      'cash' => 'Cash',
      'investment' => 'Investment',
      'cryptoWallet' => 'Solana Wallet',
      _ => 'Other',
    };
  }
}
