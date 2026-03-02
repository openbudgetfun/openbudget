import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/edit_account_dialog.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AccountListScreen extends HookConsumerWidget {
  const AccountListScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accounts = ref.watch(accountListProvider(budgetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final showNotificationBanner = useState(true);
    final converter = ref
        .watch(displayCurrencyConverterProvider(budgetId))
        .asData
        ?.value;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.accountListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: l10n.accountAddButton,
            onPressed: () => context.goNamed(
              addAccountRoute,
              pathParameters: {'id': budgetId},
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded),
            onSelected: (value) {
              switch (value) {
                case 'transfer':
                  context.goNamed(
                    createTransferRoute,
                    pathParameters: {'id': budgetId},
                  );
                case 'settings':
                  context.goNamed(
                    settingsRoute,
                    pathParameters: {'id': budgetId},
                  );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'transfer',
                child: Text(l10n.transferTitle),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Text(l10n.moreSettings),
              ),
            ],
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
                      onPressed: () => context.goNamed(
                        addAccountRoute,
                        pathParameters: {'id': budgetId},
                      ),
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

          final allOpen = accountList.where((a) => !a.isClosed).toList();
          final netWorthByCurrency = _computeNetWorthByCurrency(allOpen);
          final onBudgetTotals = _sumBalancesByCurrency(onBudget);
          final offBudgetTotals = _sumBalancesByCurrency(offBudget);
          final closedTotals = _sumBalancesByCurrency(closed);

          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(accountListProvider(budgetId)),
            child: ListView(
              padding: const EdgeInsets.all(SpacingTokens.md),
              children: [
                if (showNotificationBanner.value) ...[
                  _NotificationBanner(
                    onClose: () => showNotificationBanner.value = false,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
                Card(
                  margin: const EdgeInsets.only(bottom: SpacingTokens.md),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text('All transactions'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.goNamed(
                      transactionListRoute,
                      pathParameters: {'id': budgetId},
                    ),
                  ),
                ),
                _NetWorthCard(
                  totalsByCurrency: netWorthByCurrency,
                  converter: converter,
                ),
                const SizedBox(height: SpacingTokens.md),
                if (onBudget.isNotEmpty) ...[
                  _SectionHeader(
                    title: l10n.accountOnBudget,
                    totalsByCurrency: onBudgetTotals,
                    converter: converter,
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
                    totalsByCurrency: offBudgetTotals,
                    converter: converter,
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
                    totalsByCurrency: closedTotals,
                    converter: converter,
                  ),
                  ...closed.map(
                    (account) =>
                        _AccountTile(account: account, budgetId: budgetId),
                  ),
                ],
                const SizedBox(height: SpacingTokens.md),
                OutlinedButton.icon(
                  onPressed: () => context.goNamed(
                    addAccountRoute,
                    pathParameters: {'id': budgetId},
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.accountAddButton),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationBanner extends HookWidget {
  const _NotificationBanner({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.md,
        SpacingTokens.sm,
        SpacingTokens.md,
      ),
      decoration: BoxDecoration(
        color: OpenBudgetPalette.bgBadgeFor(theme),
        borderRadius: BorderRadius.circular(RadiusTokens.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  'OpenBudget will notify you when you have new '
                  'transactions or overspending.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          IconButton(onPressed: onClose, icon: const Icon(Icons.close_rounded)),
        ],
      ),
    );
  }
}

class _SectionHeader extends HookWidget {
  const _SectionHeader({
    required this.title,
    required this.totalsByCurrency,
    required this.converter,
  });

  final String title;
  final Map<CurrencyCode, int> totalsByCurrency;
  final DisplayCurrencyConverter? converter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final convertedTotal = converter?.convertTotalsToDisplay(totalsByCurrency);
    final hasSingleCurrency =
        totalsByCurrency.length == 1 || convertedTotal != null;
    final singleTotal =
        convertedTotal ??
        (totalsByCurrency.length == 1 ? totalsByCurrency.values.first : 0);
    final totalLabel = convertedTotal != null
        ? formatCents(convertedTotal, converter!.displayCurrency)
        : formatCurrencyBreakdown(
            totalsByCurrency,
            includeCurrencyCode: !hasSingleCurrency,
          );
    final labelColor = hasSingleCurrency
        ? singleTotal >= 0
              ? colorScheme.primary
              : colorScheme.error
        : colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: SpacingTokens.sm),
          Flexible(
            child: Text(
              totalLabel,
              style: theme.textTheme.titleSmall?.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
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
    final currency = parseCurrencyCode(account.currencyCode);
    final accountId = account.id?.toString();

    return Card(
      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
      child: ListTile(
        onTap: accountId == null
            ? null
            : () => context.goNamed(
                accountDetailRoute,
                pathParameters: {'id': budgetId, 'accountId': accountId},
              ),
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
          _labelForType(account.accountType, AppLocalizations.of(context)),
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

  static String _labelForType(String type, AppLocalizations l10n) =>
      switch (type) {
        'checking' => l10n.accountTypeChecking,
        'savings' => l10n.accountTypeSavings,
        'creditCard' => l10n.accountTypeCreditCard,
        'cash' => l10n.accountTypeCash,
        'investment' => l10n.accountTypeInvestment,
        _ => l10n.accountTypeOther,
      };
}

class _NetWorthCard extends HookWidget {
  const _NetWorthCard({
    required this.totalsByCurrency,
    required this.converter,
  });

  final List<_NetWorthTotals> totalsByCurrency;
  final DisplayCurrencyConverter? converter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final netWorthByCurrency = {
      for (final totals in totalsByCurrency) totals.currency: totals.netWorth,
    };
    final assetsByCurrency = {
      for (final totals in totalsByCurrency) totals.currency: totals.assets,
    };
    final liabilitiesByCurrency = {
      for (final totals in totalsByCurrency)
        totals.currency: totals.liabilities,
    };

    final convertedNetWorth = converter?.convertTotalsToDisplay(
      netWorthByCurrency,
    );
    final convertedAssets = converter?.convertTotalsToDisplay(assetsByCurrency);
    final convertedLiabilities = converter?.convertTotalsToDisplay(
      liabilitiesByCurrency,
    );

    final showConverted =
        convertedNetWorth != null &&
        convertedAssets != null &&
        convertedLiabilities != null;
    final primaryNetWorth = showConverted
        ? convertedNetWorth
        : totalsByCurrency.first.netWorth;

    final isSingleCurrency = totalsByCurrency.length == 1 || showConverted;
    final overallLabel = showConverted
        ? formatCents(convertedNetWorth, converter!.displayCurrency)
        : totalsByCurrency.length == 1
        ? formatCents(
            totalsByCurrency.first.netWorth,
            totalsByCurrency.first.currency,
          )
        : formatCurrencyBreakdown(netWorthByCurrency);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.accountNetWorth,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              overallLabel,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSingleCurrency && primaryNetWorth < 0
                    ? colorScheme.error
                    : colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpacingTokens.sm),
            if (showConverted)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NetWorthMetric(
                    label: l10n.accountTotalAssets,
                    amount: convertedAssets,
                    currencyCode: converter!.displayCurrency,
                    color: ColorTokens.secondary,
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: colorScheme.outlineVariant,
                  ),
                  _NetWorthMetric(
                    label: l10n.accountTotalLiabilities,
                    amount: convertedLiabilities,
                    currencyCode: converter!.displayCurrency,
                    color: ColorTokens.error,
                  ),
                ],
              )
            else if (isSingleCurrency)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _NetWorthMetric(
                    label: l10n.accountTotalAssets,
                    amount: totalsByCurrency.first.assets,
                    currencyCode: totalsByCurrency.first.currency,
                    color: ColorTokens.secondary,
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: colorScheme.outlineVariant,
                  ),
                  _NetWorthMetric(
                    label: l10n.accountTotalLiabilities,
                    amount: totalsByCurrency.first.liabilities,
                    currencyCode: totalsByCurrency.first.currency,
                    color: ColorTokens.error,
                  ),
                ],
              )
            else
              Column(
                children: [
                  for (var i = 0; i < totalsByCurrency.length; i++) ...[
                    _NetWorthCurrencyRow(totals: totalsByCurrency[i]),
                    if (i < totalsByCurrency.length - 1)
                      const SizedBox(height: SpacingTokens.xs),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _NetWorthCurrencyRow extends HookWidget {
  const _NetWorthCurrencyRow({required this.totals});

  final _NetWorthTotals totals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final netColor = totals.netWorth >= 0
        ? ColorTokens.secondary
        : ColorTokens.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
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
                totals.currency.code,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                formatCents(totals.netWorth, totals.currency),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: netColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.accountTotalAssets}: ${formatCents(totals.assets, totals.currency)}',
                  style: theme.textTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Text(
                  '${l10n.accountTotalLiabilities}: ${formatCents(totals.liabilities, totals.currency)}',
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

class _NetWorthMetric extends HookWidget {
  const _NetWorthMetric({
    required this.label,
    required this.amount,
    required this.currencyCode,
    required this.color,
  });

  final String label;
  final int amount;
  final CurrencyCode currencyCode;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formatCents(amount, currencyCode),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _NetWorthTotals {
  const _NetWorthTotals({
    required this.currency,
    required this.assets,
    required this.liabilities,
  });

  final CurrencyCode currency;
  final int assets;
  final int liabilities;

  int get netWorth => assets + liabilities;
}

List<_NetWorthTotals> _computeNetWorthByCurrency(Iterable<Account> accounts) {
  final assets = <CurrencyCode, int>{};
  final liabilities = <CurrencyCode, int>{};

  for (final account in accounts) {
    final currency = parseCurrencyCode(account.currencyCode);
    if (account.balanceCents >= 0) {
      assets[currency] = (assets[currency] ?? 0) + account.balanceCents;
      continue;
    }
    liabilities[currency] = (liabilities[currency] ?? 0) + account.balanceCents;
  }

  final allCurrencies = {...assets.keys, ...liabilities.keys}.toList()
    ..sort((a, b) => a.code.compareTo(b.code));

  if (allCurrencies.isEmpty) {
    return const [
      _NetWorthTotals(currency: CurrencyCode.usd, assets: 0, liabilities: 0),
    ];
  }

  return allCurrencies
      .map(
        (currency) => _NetWorthTotals(
          currency: currency,
          assets: assets[currency] ?? 0,
          liabilities: liabilities[currency] ?? 0,
        ),
      )
      .toList();
}

Map<CurrencyCode, int> _sumBalancesByCurrency(Iterable<Account> accounts) {
  final totals = aggregateCentsByCurrency(
    accounts,
    currencyCodeOf: (account) => account.currencyCode,
    amountCentsOf: (account) => account.balanceCents,
  );
  final sorted = totals.entries.toList()
    ..sort((a, b) => a.key.code.compareTo(b.key.code));
  return {for (final entry in sorted) entry.key: entry.value};
}
