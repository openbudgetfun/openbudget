import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/home/providers/budget_actions_provider.dart';
import 'package:openbudget_app/src/features/home/providers/budget_list_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final budgets = ref.watch(budgetListProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: l10n.homeLogout,
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: budgets.when(
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
                l10n.homeLoadError,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              FilledButton.icon(
                onPressed: () => ref.invalidate(budgetListProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.homeRetry),
              ),
            ],
          ),
        ),
        data: (budgetList) {
          if (budgetList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.savings_rounded,
                      size: 64,
                      color: colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    Text(
                      l10n.homeNoBudgets,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    FilledButton.icon(
                      onPressed: () => context.go(createBudgetPath),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.homeCreateBudget),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(budgetListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(SpacingTokens.md),
              itemCount: budgetList.length,
              itemBuilder: (context, index) {
                final budget = budgetList[index];
                return _BudgetCard(
                  budgetId: budget.id?.toString() ?? '',
                  budgetName: budget.name,
                  currencyCode: budget.currencyCode,
                  onTap: () => context.go('/budgets/${budget.id}'),
                  onLongPress: () => _confirmDeleteBudget(
                    context,
                    ref,
                    budget.id?.toString() ?? '',
                    budget.name,
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: budgets.maybeWhen(
        data: (list) => list.isNotEmpty
            ? FloatingActionButton(
                onPressed: () => context.go(createBudgetPath),
                child: const Icon(Icons.add),
              )
            : null,
        orElse: () => null,
      ),
    );
  }

  Future<void> _confirmDeleteBudget(
    BuildContext context,
    WidgetRef ref,
    String budgetId,
    String budgetName,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.budgetDeleteTitle),
        content: Text(l10n.budgetDeleteConfirm(budgetName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: Text(l10n.budgetDeleteButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(budgetActionsProvider.notifier)
          .deleteBudget(budgetId: budgetId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.budgetDeleteSuccess)));
      }
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.budgetDeleteError),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }
}

class _BudgetCard extends HookConsumerWidget {
  const _BudgetCard({
    required this.budgetId,
    required this.budgetName,
    required this.currencyCode,
    required this.onTap,
    required this.onLongPress,
  });

  final String budgetId;
  final String budgetName;
  final String currencyCode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accountsAsync = ref.watch(accountListProvider(budgetId));

    final currency = CurrencyCode.values.firstWhere(
      (c) => c.code == currencyCode,
      orElse: () => CurrencyCode.usd,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: SpacingTokens.md),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: colorScheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(budgetName, style: theme.textTheme.titleMedium),
                        Text(
                          currencyCode,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              accountsAsync.whenOrNull(
                    data: (accounts) {
                      if (accounts.isEmpty) return null;

                      final activeAccounts = accounts
                          .where((a) => !a.isClosed)
                          .toList();
                      final totalBalance = activeAccounts.fold<int>(
                        0,
                        (sum, a) => sum + a.balanceCents,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(top: SpacingTokens.md),
                        child: Row(
                          children: [
                            Expanded(
                              child: _SummaryChip(
                                icon: Icons.account_balance_rounded,
                                label: l10n.homeBudgetAccounts(
                                  activeAccounts.length,
                                ),
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              formatCents(totalBalance, currency),
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: totalBalance >= 0
                                    ? ColorTokens.secondary
                                    : ColorTokens.error,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ) ??
                  const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends HookWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: SpacingTokens.xs),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}
