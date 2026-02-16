import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/edit_account_dialog.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

CurrencyCode _parseCurrency(String code) => CurrencyCode.values.firstWhere(
  (c) => c.code == code,
  orElse: () => CurrencyCode.usd,
);

class AccountListScreen extends HookConsumerWidget {
  const AccountListScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accounts = ref.watch(accountListProvider(budgetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/budgets/$budgetId'),
        ),
        title: Text(l10n.accountListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: l10n.transferTitle,
            onPressed: () => context.go('/budgets/$budgetId/transfer'),
          ),
        ],
      ),
      body: accounts.when(
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
                l10n.accountLoadError,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              FilledButton.icon(
                onPressed: () => ref.invalidate(accountListProvider(budgetId)),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.homeRetry),
              ),
            ],
          ),
        ),
        data: (accountList) {
          if (accountList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_rounded,
                      size: 64,
                      color: colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    Text(
                      l10n.accountEmptyTitle,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    Text(
                      l10n.accountEmptySubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    FilledButton.icon(
                      onPressed: () =>
                          context.go('/budgets/$budgetId/accounts/add'),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.accountAddButton),
                    ),
                  ],
                ),
              ),
            );
          }

          final onBudget = accountList
              .where((a) => a.onBudget && !a.isClosed)
              .toList();
          final offBudget = accountList
              .where((a) => !a.onBudget && !a.isClosed)
              .toList();
          final closed = accountList.where((a) => a.isClosed).toList();

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(accountListProvider(budgetId)),
            child: ListView(
              padding: const EdgeInsets.all(SpacingTokens.md),
              children: [
                if (onBudget.isNotEmpty) ...[
                  _SectionHeader(
                    title: l10n.accountOnBudget,
                    total: onBudget.fold<int>(
                      0,
                      (sum, a) => sum + a.balanceCents,
                    ),
                    currencyCode: onBudget.first.currencyCode,
                  ),
                  ...onBudget.map(
                    (account) =>
                        _AccountTile(account: account, budgetId: budgetId),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
                if (offBudget.isNotEmpty) ...[
                  _SectionHeader(
                    title: l10n.accountOffBudget,
                    total: offBudget.fold<int>(
                      0,
                      (sum, a) => sum + a.balanceCents,
                    ),
                    currencyCode: offBudget.first.currencyCode,
                  ),
                  ...offBudget.map(
                    (account) =>
                        _AccountTile(account: account, budgetId: budgetId),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
                if (closed.isNotEmpty) ...[
                  _SectionHeader(
                    title: l10n.accountClosed,
                    total: closed.fold<int>(
                      0,
                      (sum, a) => sum + a.balanceCents,
                    ),
                    currencyCode: closed.first.currencyCode,
                  ),
                  ...closed.map(
                    (account) =>
                        _AccountTile(account: account, budgetId: budgetId),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/budgets/$budgetId/accounts/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SectionHeader extends HookWidget {
  const _SectionHeader({
    required this.title,
    required this.total,
    required this.currencyCode,
  });

  final String title;
  final int total;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currency = _parseCurrency(currencyCode);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            formatCents(total, currency),
            style: theme.textTheme.titleSmall?.copyWith(
              color: total >= 0 ? colorScheme.primary : colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends HookWidget {
  const _AccountTile({required this.account, required this.budgetId});

  final Account account;
  final String budgetId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final icon = _iconForType(account.accountType);
    final currency = _parseCurrency(account.currencyCode);

    return Card(
      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
      child: ListTile(
        onTap: () => context.go('/budgets/$budgetId/accounts/${account.id}'),
        onLongPress: () => showDialog<void>(
          context: context,
          builder: (_) =>
              EditAccountDialog(account: account, budgetId: budgetId),
        ),
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          child: Icon(icon, color: colorScheme.onSecondaryContainer, size: 20),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(account.name, style: theme.textTheme.titleMedium),
            ),
            if (account.isClosed) ...[
              const SizedBox(width: SpacingTokens.xs),
              Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: colorScheme.outline,
              ),
            ],
          ],
        ),
        subtitle: Text(
          _labelForType(account.accountType),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatCents(account.balanceCents, currency),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: account.balanceCents >= 0
                    ? colorScheme.primary
                    : colorScheme.error,
              ),
            ),
            const SizedBox(width: SpacingTokens.xs),
            Icon(Icons.edit_outlined, size: 16, color: colorScheme.outline),
          ],
        ),
      ),
    );
  }

  static IconData _iconForType(String type) {
    switch (type) {
      case 'checking':
        return Icons.account_balance_rounded;
      case 'savings':
        return Icons.savings_rounded;
      case 'creditCard':
        return Icons.credit_card_rounded;
      case 'cash':
        return Icons.payments_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  static String _labelForType(String type) {
    switch (type) {
      case 'checking':
        return 'Checking';
      case 'savings':
        return 'Savings';
      case 'creditCard':
        return 'Credit Card';
      case 'cash':
        return 'Cash';
      case 'investment':
        return 'Investment';
      default:
        return 'Other';
    }
  }
}
