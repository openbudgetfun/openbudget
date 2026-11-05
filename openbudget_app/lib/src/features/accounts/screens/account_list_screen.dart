import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/edit_account_dialog.dart';
import 'package:openbudget_app/src/features/settings/providers/display_currency_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
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
    final showNotificationBanner = useState(true);
    final converter = ref
        .watch(displayCurrencyConverterProvider(budgetId))
        .asData
        ?.value;
    void navigateAfterMenuClose(VoidCallback callback) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        callback();
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.accountListTitle),
        actions: [
          IconButton(
            key: const Key('account-list-add-button'),
            icon: const SkribbleIcon(data: OpenBudgetIcons.addCircle),
            tooltip: l10n.accountAddButton,
            onPressed: () => context.goNamed(
              addAccountRoute,
              pathParameters: {'id': budgetId},
            ),
          ),
          PopupMenuButton<String>(
            key: const Key('account-list-more-button'),
            icon: const SkribbleIcon(data: OpenBudgetIcons.more),
            tooltip: l10n.accountsMoreActions,
            onSelected: (value) {
              switch (value) {
                case 'transfer':
                  navigateAfterMenuClose(() {
                    unawaited(
                      context.pushNamed(
                        createTransferRoute,
                        pathParameters: {'id': budgetId},
                      ),
                    );
                  });
                case 'settings':
                  navigateAfterMenuClose(() {
                    context.goNamed(
                      settingsRoute,
                      pathParameters: {'id': budgetId},
                    );
                  });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'transfer',
                child: Row(
                  children: [
                    const SkribbleIcon(
                      data: OpenBudgetIcons.transfer,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.transferTitle),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    const SkribbleIcon(
                      data: OpenBudgetIcons.settings,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.moreSettings),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: accounts.when(
        loading: () => Center(
          child: ObLoadingPanel(label: l10n.loadingTitle),
        ),
        error: (error, _) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: ObStatePanel.problem(
              title: l10n.accountLoadError,
              action: ObStateAction(
                label: l10n.homeRetry,
                onPressed: () => ref.invalidate(accountListProvider(budgetId)),
              ),
            ),
          ),
        ),
        data: (accountList) {
          if (accountList.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                child: ObStatePanel.empty(
                  title: l10n.accountEmptyTitle,
                  message: l10n.accountEmptySubtitle,
                  action: ObStateAction(
                    label: l10n.accountAddButton,
                    onPressed: () => context.goNamed(
                      addAccountRoute,
                      pathParameters: {'id': budgetId},
                    ),
                  ),
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
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                SpacingTokens.md,
                SpacingTokens.md,
                SpacingTokens.xl,
              ),
              children: [
                if (showNotificationBanner.value) ...[
                  _NotificationBanner(
                    onClose: () => showNotificationBanner.value = false,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
                ObCard(
                  margin: const EdgeInsets.only(bottom: SpacingTokens.md),
                  child: ListTile(
                    leading: const SkribbleIcon(
                      data: OpenBudgetIcons.receipt,
                    ),
                    title: Text(l10n.accountListAllTransactions),
                    trailing: const SkribbleIcon(
                      data: OpenBudgetIcons.chevronRight,
                      size: 20,
                    ),
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
                  ObSectionHeader(
                    title: l10n.accountOnBudget,
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: _SectionTotal(
                        totalsByCurrency: onBudgetTotals,
                        converter: converter,
                      ),
                    ),
                  ),
                  ...onBudget.map(
                    (account) =>
                        _AccountTile(account: account, budgetId: budgetId),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
                if (offBudget.isNotEmpty) ...[
                  ObSectionHeader(
                    title: l10n.accountOffBudget,
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: _SectionTotal(
                        totalsByCurrency: offBudgetTotals,
                        converter: converter,
                      ),
                    ),
                  ),
                  ...offBudget.map(
                    (account) =>
                        _AccountTile(account: account, budgetId: budgetId),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
                if (closed.isNotEmpty) ...[
                  ObSectionHeader(
                    title: l10n.accountClosed,
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                    trailing: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: _SectionTotal(
                        totalsByCurrency: closedTotals,
                        converter: converter,
                      ),
                    ),
                  ),
                  ...closed.map(
                    (account) =>
                        _AccountTile(account: account, budgetId: budgetId),
                  ),
                ],
                const SizedBox(height: SpacingTokens.lg),
                OutlinedButton.icon(
                  onPressed: () => context.goNamed(
                    addAccountRoute,
                    pathParameters: {'id': budgetId},
                  ),
                  icon: const SkribbleIcon(data: OpenBudgetIcons.add),
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ObCard(
      tone: ObTone.review,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.md,
          SpacingTokens.md,
          SpacingTokens.xs,
          SpacingTokens.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkribbleIcon(
              data: OpenBudgetIcons.notification,
              color: palette.hue(ObTone.review),
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.accountListNotificationsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: palette.ink,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    l10n.accountListNotificationsMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.ink,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.accountsDismissNotification,
              onPressed: onClose,
              icon: const SkribbleIcon(data: OpenBudgetIcons.close),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTotal extends HookWidget {
  const _SectionTotal({
    required this.totalsByCurrency,
    required this.converter,
  });

  final Map<CurrencyCode, int> totalsByCurrency;
  final DisplayCurrencyConverter? converter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final convertedTotal = converter?.convertTotalsToDisplay(totalsByCurrency);
    final hasSingleCurrency =
        totalsByCurrency.length == 1 || convertedTotal != null;

    if (!hasSingleCurrency) {
      return Text(
        formatCurrencyBreakdown(totalsByCurrency),
        style: theme.textTheme.titleSmall?.copyWith(color: palette.mutedInk),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.end,
      );
    }

    final singleTotal =
        convertedTotal ??
        (totalsByCurrency.isEmpty ? 0 : totalsByCurrency.values.first);
    return ObAmount(
      convertedTotal != null
          ? formatCents(convertedTotal, converter!.displayCurrency)
          : formatCents(singleTotal, totalsByCurrency.keys.first),
      tone: singleTotal >= 0 ? ObTone.funded : ObTone.overspent,
      style: theme.textTheme.titleSmall,
    );
  }
}

class _AccountTile extends HookWidget {
  const _AccountTile({required this.account, required this.budgetId});

  final Account account;
  final String budgetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final icon = _iconForType(account.accountType);
    final currency = parseCurrencyCode(account.currencyCode);
    final accountId = account.id?.toString();
    final balanceTone = account.balanceCents > 0
        ? ObTone.funded
        : account.balanceCents < 0
        ? ObTone.overspent
        : ObTone.neutral;

    return ObCard(
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
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: ObRoughDecoration(
            color: palette.wash(ObTone.brand),
            outline: palette.quietPen,
            seed: 11,
          ),
          child: SkribbleIcon(
            data: icon,
            color: palette.hue(ObTone.brand),
            size: 20,
          ),
        ),
        title: Text(
          account.name,
          style: theme.textTheme.titleMedium?.copyWith(color: palette.ink),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  _labelForType(account.accountType, l10n),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_statusChip(context, account) case final chip?) ...[
                const SizedBox(width: SpacingTokens.xs),
                chip,
              ],
            ],
          ),
        ),
        trailing: ObAmount(
          formatCents(account.balanceCents, currency),
          tone: balanceTone,
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }

  static Widget? _statusChip(BuildContext context, Account account) {
    final l10n = AppLocalizations.of(context);
    if (account.isClosed) {
      return ObToneChip(
        label: l10n.accountsClosedBadge,
        icon: const SkribbleIcon(data: OpenBudgetIcons.lock, size: 16),
      );
    }
    return switch (account.syncStatus?.toLowerCase()) {
      'success' || 'synced' => ObToneChip(
        label: l10n.accountsSynced,
        tone: ObTone.funded,
        icon: const SkribbleIcon(data: OpenBudgetIcons.verified, size: 16),
      ),
      'error' || 'failed' => ObToneChip(
        label: l10n.accountsNeedsAttention,
        tone: ObTone.overspent,
        icon: const SkribbleIcon(data: OpenBudgetIcons.warning, size: 16),
      ),
      'pending' || 'syncing' => ObToneChip(
        label: l10n.accountDetailWalletSyncing,
        tone: ObTone.underfunded,
        icon: const SkribbleIcon(data: OpenBudgetIcons.sync, size: 16),
      ),
      _ => null,
    };
  }

  static WiredSvgIconData _iconForType(String type) => switch (type) {
    'checking' => OpenBudgetIcons.bank,
    'savings' => OpenBudgetIcons.savings,
    'creditCard' => OpenBudgetIcons.creditCard,
    'cash' => OpenBudgetIcons.cash,
    'investment' => OpenBudgetIcons.trendingUp,
    'cryptoWallet' => OpenBudgetIcons.solana,
    _ => OpenBudgetIcons.wallet,
  };

  static String _labelForType(String type, AppLocalizations l10n) =>
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
    final palette = theme.ob;
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

    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SkribbleIcon(
                data: OpenBudgetIcons.scale,
                size: 20,
                color: palette.mutedInk,
              ),
              const SizedBox(width: SpacingTokens.xs),
              Text(
                l10n.accountNetWorth,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: palette.mutedInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          ObAmount(
            overallLabel,
            tone: isSingleCurrency && primaryNetWorth < 0
                ? ObTone.overspent
                : ObTone.neutral,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.sm),
          if (showConverted)
            Row(
              children: [
                Expanded(
                  child: _NetWorthMetric(
                    label: l10n.accountTotalAssets,
                    amount: convertedAssets,
                    currencyCode: converter!.displayCurrency,
                    tone: ObTone.funded,
                  ),
                ),
                const SizedBox(
                  height: 32,
                  child: VerticalDivider(width: 16),
                ),
                Expanded(
                  child: _NetWorthMetric(
                    label: l10n.accountTotalLiabilities,
                    amount: convertedLiabilities,
                    currencyCode: converter!.displayCurrency,
                    tone: ObTone.overspent,
                  ),
                ),
              ],
            )
          else if (isSingleCurrency)
            Row(
              children: [
                Expanded(
                  child: _NetWorthMetric(
                    label: l10n.accountTotalAssets,
                    amount: totalsByCurrency.first.assets,
                    currencyCode: totalsByCurrency.first.currency,
                    tone: ObTone.funded,
                  ),
                ),
                const SizedBox(
                  height: 32,
                  child: VerticalDivider(width: 16),
                ),
                Expanded(
                  child: _NetWorthMetric(
                    label: l10n.accountTotalLiabilities,
                    amount: totalsByCurrency.first.liabilities,
                    currencyCode: totalsByCurrency.first.currency,
                    tone: ObTone.overspent,
                  ),
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
    );
  }
}

class _NetWorthCurrencyRow extends HookWidget {
  const _NetWorthCurrencyRow({required this.totals});

  final _NetWorthTotals totals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final l10n = AppLocalizations.of(context);
    final netTone = totals.netWorth >= 0 ? ObTone.funded : ObTone.overspent;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      decoration: ObRoughDecoration(
        color: palette.highlight,
        outline: palette.quietPen,
        radius: RadiusTokens.sm,
        seed: 43,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                totals.currency.code,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: palette.ink,
                ),
              ),
              const Spacer(),
              ObAmount(
                formatCents(totals.netWorth, totals.currency),
                tone: netTone,
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.accountTotalAssets}: '
                  '${formatCents(totals.assets, totals.currency)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.ink,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '${l10n.accountTotalLiabilities}: '
                  '${formatCents(totals.liabilities, totals.currency)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.ink,
                  ),
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
    required this.tone,
  });

  final String label;
  final int amount;
  final CurrencyCode currencyCode;
  final ObTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: palette.mutedInk),
        ),
        const SizedBox(height: 2),
        ObAmount(
          formatCents(amount, currencyCode),
          tone: tone,
          style: theme.textTheme.titleSmall,
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
