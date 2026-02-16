import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
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
          final currency = CurrencyCode.values.firstWhere(
            (c) => c.code == data.currencyCode,
            orElse: () => CurrencyCode.usd,
          );
          final netWorthColor = data.netWorth >= 0
              ? ColorTokens.secondary
              : ColorTokens.error;

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
                      l10n.netWorthTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: netWorthColor.withAlpha(200),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(
                      formatCents(data.netWorth, currency),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: netWorthColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.md),

              // Assets vs Liabilities summary row
              Row(
                children: [
                  Expanded(
                    child: _SummaryChip(
                      label: l10n.netWorthAssets,
                      amount: formatCents(data.totalAssets, currency),
                      color: ColorTokens.secondary,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: _SummaryChip(
                      label: l10n.netWorthLiabilities,
                      amount: formatCents(data.totalLiabilities, currency),
                      color: ColorTokens.error,
                    ),
                  ),
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
                        _AccountTile(
                          account: data.assetAccounts[i],
                          currency: currency,
                        ),
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
                        _AccountTile(
                          account: data.liabilityAccounts[i],
                          currency: currency,
                        ),
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

class _AccountTile extends HookWidget {
  const _AccountTile({required this.account, required this.currency});

  final Account account;
  final CurrencyCode currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
      _ => 'Other',
    };
  }
}
