import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/home/providers/budget_actions_provider.dart';
import 'package:openbudget_app/src/features/home/providers/budget_list_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final budgets = ref.watch(budgetListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const SkribbleIcon(data: OpenBudgetIcons.logout),
            tooltip: l10n.homeLogout,
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: budgets.when(
        loading: () => ObLoadingPanel(label: l10n.homeLoadingBudgets),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: ObStatePanel.problem(
            title: l10n.homeLoadError,
            action: ObStateAction(
              label: l10n.homeRetry,
              onPressed: () => ref.invalidate(budgetListProvider),
            ),
          ),
        ),
        data: (budgetList) {
          if (budgetList.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(SpacingTokens.xl),
              child: Center(
                child: SingleChildScrollView(
                  child: ObStatePanel.empty(
                    title: l10n.homeNoBudgets,
                    message: l10n.homeNoBudgetsHint,
                    action: ObStateAction(
                      label: l10n.homeCreateBudget,
                      onPressed: () =>
                          unawaited(context.pushNamed(createBudgetRoute)),
                    ),
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(budgetListProvider),
            child: ListView(
              padding: const EdgeInsets.all(SpacingTokens.md),
              children: [
                _NetWorthSummary(
                  budgetIds: budgetList
                      .map((b) => b.id?.toString() ?? '')
                      .where((id) => id.isNotEmpty)
                      .toList(),
                ),
                const SizedBox(height: SpacingTokens.md),
                for (final budget in budgetList)
                  _BudgetCard(
                    budgetId: budget.id?.toString() ?? '',
                    budgetName: budget.name,
                    currencyCode: budget.currencyCode,
                    onTap: () {
                      final id = budget.id?.toString();
                      if (id == null || id.isEmpty) return;
                      unawaited(
                        context.pushNamed(
                          planRoute,
                          pathParameters: {'id': id},
                        ),
                      );
                    },
                    onLongPress: () => _confirmDeleteBudget(
                      context,
                      ref,
                      budget.id?.toString() ?? '',
                      budget.name,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: budgets.maybeWhen(
        data: (list) => list.isNotEmpty
            ? FloatingActionButton(
                tooltip: l10n.homeCreateBudget,
                onPressed: () =>
                    unawaited(context.pushNamed(createBudgetRoute)),
                child: const SkribbleIcon(data: OpenBudgetIcons.add),
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
    final palette = Theme.of(context).ob;
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
              backgroundColor: palette.overspentWash,
              foregroundColor: palette.overspent,
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
        showAppToast(
          context,
          message: l10n.budgetDeleteSuccess,
          variant: AppToastVariant.success,
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.budgetDeleteError,
          variant: AppToastVariant.error,
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
    final palette = theme.ob;
    final accountsAsync = ref.watch(accountListProvider(budgetId));
    final summaryAsync = ref.watch(budgetSummaryProvider(budgetId));
    final converter = ref
        .watch(displayCurrencyConverterProvider(budgetId))
        .asData
        ?.value;

    return Card(
      margin: const EdgeInsets.only(bottom: SpacingTokens.md),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: ObRoughDecoration(
                      color: palette.wash(ObTone.brand),
                      outline: palette.quietPen,
                      seed: 17,
                    ),
                    child: SkribbleIcon(
                      data: OpenBudgetIcons.wallet,
                      color: palette.hue(ObTone.brand),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(budgetName, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 2),
                        ObToneChip(label: currencyCode),
                      ],
                    ),
                  ),
                  SkribbleIcon(
                    data: OpenBudgetIcons.chevronRight,
                    size: 20,
                    color: palette.mutedInk,
                  ),
                ],
              ),
              accountsAsync.whenOrNull(
                    data: (accounts) {
                      if (accounts.isEmpty) return null;

                      final activeAccounts = accounts
                          .where((a) => !a.isClosed)
                          .toList();
                      final totalsByCurrency = aggregateCentsByCurrency(
                        activeAccounts,
                        currencyCodeOf: (account) => account.currencyCode,
                        amountCentsOf: (account) => account.balanceCents,
                      );
                      final hasSingleCurrency = totalsByCurrency.length <= 1;
                      final singleCurrency = hasSingleCurrency
                          ? (totalsByCurrency.keys.firstOrNull ?? currencyCode)
                          : currencyCode;
                      final singleTotal = hasSingleCurrency
                          ? (totalsByCurrency.values.firstOrNull ?? 0)
                          : 0;
                      final convertedTotal = converter?.convertTotalsToDisplay(
                        totalsByCurrency,
                      );
                      final totalLabel = convertedTotal != null
                          ? formatCents(
                              convertedTotal,
                              converter!.displayCurrency!,
                            )
                          : hasSingleCurrency
                          ? formatCentsForCode(singleTotal, singleCurrency)
                          : formatCurrencyBreakdown(totalsByCurrency);
                      final totalForColor = convertedTotal ?? singleTotal;
                      final totalTone =
                          (hasSingleCurrency || convertedTotal != null)
                          ? totalForColor >= 0
                                ? ObTone.funded
                                : ObTone.overspent
                          : ObTone.neutral;

                      return Padding(
                        padding: const EdgeInsets.only(top: SpacingTokens.md),
                        child: Row(
                          children: [
                            Expanded(
                              child: _SummaryChip(
                                icon: OpenBudgetIcons.bank,
                                label: l10n.homeBudgetAccounts(
                                  activeAccounts.length,
                                ),
                                color: palette.mutedInk,
                              ),
                            ),
                            const SizedBox(width: SpacingTokens.sm),
                            Flexible(
                              child: ObAmount(
                                totalLabel,
                                tone: totalTone,
                                textAlign: TextAlign.end,
                                style: theme.textTheme.titleSmall,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ) ??
                  const SizedBox.shrink(),
              summaryAsync.whenOrNull(
                    data: (summary) {
                      final readyToAssign = summary.readyToAssignCents;
                      var overspentCount = 0;
                      for (final cat in summary.categories) {
                        for (final env in cat.envelopes) {
                          final idx = cat.envelopes.indexOf(env);
                          final available = idx < cat.monthlyEnvelopes.length
                              ? cat.monthlyEnvelopes[idx].availableCents
                              : (env.budgetedAmountCents -
                                    env.spentAmountCents);
                          if (available < 0) overspentCount++;
                        }
                      }
                      final readyTone = readyToAssign > 0
                          ? ObTone.funded
                          : readyToAssign < 0
                          ? ObTone.overspent
                          : ObTone.neutral;
                      final readyLabel = Text(
                        l10n.homeBudgetReadyToAssign(
                          converter?.formatAmount(
                                amountCents: readyToAssign,
                                currencyCode: currencyCode,
                              ) ??
                              formatCentsForCode(readyToAssign, currencyCode),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.hue(readyTone),
                          fontWeight: FontWeight.w600,
                        ),
                      );

                      return Padding(
                        padding: const EdgeInsets.only(top: SpacingTokens.sm),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  SkribbleIcon(
                                    data: OpenBudgetIcons.autoAssign,
                                    size: 16,
                                    color: palette.hue(readyTone),
                                  ),
                                  const SizedBox(width: SpacingTokens.xs),
                                  Flexible(
                                    child: readyToAssign > 0
                                        ? ObHighlighter(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 3,
                                            ),
                                            child: readyLabel,
                                          )
                                        : readyLabel,
                                  ),
                                ],
                              ),
                            ),
                            if (overspentCount > 0)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SkribbleIcon(
                                    data: OpenBudgetIcons.warning,
                                    size: 16,
                                    color: palette.overspent,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    l10n.homeBudgetOverspent(overspentCount),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: palette.overspent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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

class _NetWorthSummary extends HookConsumerWidget {
  const _NetWorthSummary({required this.budgetIds});

  final List<String> budgetIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    final totalsByCurrency = <String, int>{};
    var totalAccounts = 0;
    var loaded = false;

    for (final budgetId in budgetIds) {
      final accountsAsync = ref.watch(accountListProvider(budgetId));
      if (accountsAsync.hasValue) {
        loaded = true;
        final active = accountsAsync.value!.where((a) => !a.isClosed);
        for (final account in active) {
          final currency = normalizeCurrencyCode(account.currencyCode);
          totalsByCurrency[currency] =
              (totalsByCurrency[currency] ?? 0) + account.balanceCents;
          totalAccounts++;
        }
      }
    }

    if (!loaded) return const SizedBox.shrink();

    final isSingleCurrency = totalsByCurrency.length <= 1;
    final singleTotal = isSingleCurrency
        ? (totalsByCurrency.values.firstOrNull ?? 0)
        : 0;
    final isPositive = !isSingleCurrency || singleTotal >= 0;
    final tone = isPositive ? ObTone.funded : ObTone.overspent;
    final totalLabel = isSingleCurrency
        ? formatCentsForCode(
            singleTotal,
            totalsByCurrency.keys.firstOrNull ?? '',
          )
        : formatCurrencyBreakdown(totalsByCurrency);

    return ObCard(
      tone: tone,
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        children: [
          Row(
            children: [
              SkribbleIcon(
                data: OpenBudgetIcons.wallet,
                size: 18,
                color: palette.hue(tone),
              ),
              const SizedBox(width: SpacingTokens.xs),
              Text(
                l10n.homeNetWorthLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: palette.ink,
                ),
              ),
              const Spacer(),
              Text(
                l10n.homeNetWorthAccounts(totalAccounts),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          ObAmount(
            totalLabel,
            tone: tone,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
        ],
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

  final WiredSvgIconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkribbleIcon(data: icon, size: 16, color: color),
        const SizedBox(width: SpacingTokens.xs),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: color)),
      ],
    );
  }
}
