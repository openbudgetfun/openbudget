import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/plaid_account_link_provider.dart';
import 'package:openbudget_app/src/features/accounts/screens/edit_account_dialog.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Accounts grouped Assets and Liabilities by kind, with every converted
/// figure coming from the server's net worth view.
class AccountListScreen extends HookConsumerWidget {
  const AccountListScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final accounts = ref.watch(accountListProvider(entityId));
    final netWorthAsync = ref.watch(
      netWorthForEntitiesProvider({entityId}),
    );
    final convertedById = useMemoized(() {
      final view = netWorthAsync.value;
      return <String, int>{
        for (final row in view?.accounts ?? const <NetWorthAccountRow>[])
          if (row.convertedMinor != null)
            row.accountId.toString(): row.convertedMinor!,
      };
    }, [netWorthAsync]);

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
              pathParameters: {'entityId': entityId},
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
                        pathParameters: {'entityId': entityId},
                      ),
                    );
                  });
                case 'settings':
                  navigateAfterMenuClose(() {
                    context.goNamed(
                      settingsRoute,
                      pathParameters: {'entityId': entityId},
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
                onPressed: () => ref.invalidate(accountListProvider(entityId)),
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
                      pathParameters: {'entityId': entityId},
                    ),
                  ),
                ),
              ),
            );
          }

          final open = accountList
              .where((a) => a.closedAt == null)
              .toList(growable: false);
          final closed = accountList
              .where((a) => a.closedAt != null)
              .toList(growable: false);
          final assets = open
              .where((a) => !a.kind.isLiability)
              .toList(growable: false);
          final liabilities = open
              .where((a) => a.kind.isLiability)
              .toList(growable: false);
          final netWorth = netWorthAsync.value;

          return RefreshIndicator(
            onRefresh: () async {
              ref
                ..invalidate(accountListProvider(entityId))
                ..invalidate(netWorthForEntitiesProvider({entityId}));
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                SpacingTokens.md,
                SpacingTokens.md,
                SpacingTokens.xl,
              ),
              children: [
                _NetWorthCard(view: netWorth),
                const SizedBox(height: SpacingTokens.md),
                if (assets.isNotEmpty) ...[
                  ObSectionHeader(
                    title: l10n.accountGroupAssets,
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                  ),
                  ...assets.map(
                    (account) => _AccountTile(
                      account: account,
                      entityId: entityId,
                      convertedMinor: convertedById[account.id?.toString()],
                      baseCurrencyCode:
                          netWorth?.currencyCode ?? account.currencyCode,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
                if (liabilities.isNotEmpty) ...[
                  ObSectionHeader(
                    title: l10n.accountGroupLiabilities,
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                  ),
                  ...liabilities.map(
                    (account) => _AccountTile(
                      account: account,
                      entityId: entityId,
                      convertedMinor: convertedById[account.id?.toString()],
                      baseCurrencyCode:
                          netWorth?.currencyCode ?? account.currencyCode,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                ],
                const SizedBox(height: SpacingTokens.lg),
                OutlinedButton.icon(
                  onPressed: () => context.goNamed(
                    addAccountRoute,
                    pathParameters: {'entityId': entityId},
                  ),
                  icon: const SkribbleIcon(data: OpenBudgetIcons.add),
                  label: Text(l10n.accountAddButton),
                ),
                _PlaidConnectionsSection(entityId: entityId),
                if (closed.isNotEmpty) ...[
                  ObSectionHeader(
                    title: l10n.accountClosed,
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                  ),
                  ...closed.map(
                    (account) => _AccountTile(
                      account: account,
                      entityId: entityId,
                      convertedMinor: convertedById[account.id?.toString()],
                      baseCurrencyCode:
                          netWorth?.currencyCode ?? account.currencyCode,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The entity's net worth in base currency, from the server. This is the
/// same function the home and net worth screens use, so the three screens
/// always agree.
class _NetWorthCard extends HookWidget {
  const _NetWorthCard({required this.view});

  final NetWorthView? view;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final v = view;
    if (v == null) return const SizedBox.shrink();

    final overallLabel = formatMinorForCode(v.netWorthMinor, v.currencyCode);
    final tone = v.netWorthMinor >= 0 ? ObTone.neutral : ObTone.overspent;

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
            tone: tone,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            children: [
              Expanded(
                child: _NetWorthMetric(
                  label: l10n.accountTotalAssets,
                  amountMinor: v.assetsMinor,
                  currencyCode: v.currencyCode,
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
                  amountMinor: v.liabilitiesMinor,
                  currencyCode: v.currencyCode,
                  tone: ObTone.overspent,
                ),
              ),
            ],
          ),
          if (!v.isComplete) ...[
            const SizedBox(height: SpacingTokens.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkribbleIcon(
                  data: OpenBudgetIcons.warning,
                  size: 14,
                  color: palette.hue(ObTone.overspent),
                ),
                const SizedBox(width: SpacingTokens.xs),
                Flexible(
                  child: Text(
                    l10n.netWorthMissingCurrencies(
                      v.missingCurrencyCodes.join(', '),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.hue(ObTone.overspent),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _NetWorthMetric extends HookWidget {
  const _NetWorthMetric({
    required this.label,
    required this.amountMinor,
    required this.currencyCode,
    required this.tone,
  });

  final String label;
  final int amountMinor;
  final String currencyCode;
  final ObTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: palette.mutedInk),
        ),
        ObAmount(
          formatMinorForCode(amountMinor, currencyCode),
          tone: tone,
          style: theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _AccountTile extends HookWidget {
  const _AccountTile({
    required this.account,
    required this.entityId,
    required this.convertedMinor,
    required this.baseCurrencyCode,
  });

  final Account account;
  final String entityId;

  /// The base-currency equivalent from the server's net worth rows; shown
  /// as a secondary line when the account is in a foreign currency.
  final int? convertedMinor;
  final String baseCurrencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final icon = _iconForKind(account.kind);
    final accountId = account.id?.toString();
    final balanceTone = account.balanceMinor > 0
        ? ObTone.funded
        : account.balanceMinor < 0
        ? ObTone.overspent
        : ObTone.neutral;
    final isForeign = account.currencyCode != baseCurrencyCode;
    final isClosed = account.closedAt != null;

    return ObCard(
      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
      child: ListTile(
        onTap: accountId == null
            ? null
            : () => context.goNamed(
                accountDetailRoute,
                pathParameters: {'entityId': entityId, 'accountId': accountId},
              ),
        onLongPress: () => showDialog<void>(
          context: context,
          builder: (_) =>
              EditAccountDialog(account: account, entityId: entityId),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _labelForKind(account.kind, l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isClosed) ...[
                    const SizedBox(width: SpacingTokens.xs),
                    ObToneChip(
                      label: l10n.accountsClosedBadge,
                      icon: const SkribbleIcon(
                        data: OpenBudgetIcons.lock,
                        size: 16,
                      ),
                    ),
                  ],
                ],
              ),
              if (isForeign && convertedMinor != null) ...[
                const SizedBox(height: 2),
                Text(
                  l10n.accountBaseEquivalent(
                    formatMinorForCode(convertedMinor!, baseCurrencyCode),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.mutedInk,
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: ObAmount(
          formatMinorForCode(account.balanceMinor, account.currencyCode),
          tone: balanceTone,
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }

  static WiredSvgIconData _iconForKind(AccountKind kind) => switch (kind) {
    AccountKind.checking => OpenBudgetIcons.bank,
    AccountKind.savings => OpenBudgetIcons.savings,
    AccountKind.creditCard => OpenBudgetIcons.creditCard,
    AccountKind.cash => OpenBudgetIcons.cash,
    AccountKind.investment => OpenBudgetIcons.trendingUp,
    AccountKind.crypto => OpenBudgetIcons.solana,
    AccountKind.property => OpenBudgetIcons.home,
    AccountKind.vehicle => OpenBudgetIcons.transport,
    _ => OpenBudgetIcons.wallet,
  };

  static String _labelForKind(AccountKind kind, AppLocalizations l10n) =>
      switch (kind) {
        AccountKind.checking => l10n.accountTypeChecking,
        AccountKind.savings => l10n.accountTypeSavings,
        AccountKind.creditCard => l10n.accountTypeCreditCard,
        AccountKind.cash => l10n.accountTypeCash,
        AccountKind.investment => l10n.accountTypeInvestment,
        AccountKind.crypto => l10n.accountTypeCryptoWallet,
        AccountKind.loan => l10n.addAccountTypePersonalLoan,
        AccountKind.mortgage => l10n.addAccountTypeMortgage,
        AccountKind.property => l10n.addAccountTypeProperty,
        AccountKind.vehicle => l10n.addAccountTypeVehicle,
        AccountKind.otherAsset => l10n.addAccountTypeOtherAsset,
        AccountKind.otherLiability => l10n.addAccountTypeOtherDebt,
      };
}

/// Bank connections: sync status, last error and Remove.
class _PlaidConnectionsSection extends HookConsumerWidget {
  const _PlaidConnectionsSection({required this.entityId});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final connectionsAsync = ref.watch(plaidConnectionsProvider(entityId));

    return connectionsAsync.maybeWhen(
      data: (connections) {
        if (connections.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ObSectionHeader(
              title: l10n.accountsConnectionsTitle,
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
            ),
            for (final connection in connections)
              ObCard(
                margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
                child: ListTile(
                  leading: SkribbleIcon(
                    data: OpenBudgetIcons.bank,
                    size: 20,
                    color: palette.hue(
                      connection.syncStatus == SyncStatus.failed
                          ? ObTone.overspent
                          : ObTone.brand,
                    ),
                  ),
                  title: Text(
                    connection.institutionName ?? connection.plaidItemId,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        switch (connection.syncStatus) {
                          SyncStatus.pending => l10n.accountsConnectionPending,
                          SyncStatus.synced => l10n.accountsConnectionSynced,
                          SyncStatus.failed => l10n.accountsConnectionFailed,
                        },
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: connection.syncStatus == SyncStatus.failed
                              ? palette.overspent
                              : palette.mutedInk,
                        ),
                      ),
                      if (connection.lastSyncError != null &&
                          connection.lastSyncError!.isNotEmpty)
                        Text(
                          connection.lastSyncError!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.overspent,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.accountsConnectionRemoveTitle),
                          content: Text(l10n.accountsConnectionRemoveMessage),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(l10n.dialogCancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: Text(l10n.accountsConnectionRemove),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true) return;
                      await ref
                          .read(plaidAccountLinkProvider.notifier)
                          .removeConnection(
                            connectionId: connection.id?.toString() ?? '',
                            entityId: entityId,
                          );
                    },
                    child: Text(l10n.accountsConnectionRemove),
                  ),
                ),
              ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
