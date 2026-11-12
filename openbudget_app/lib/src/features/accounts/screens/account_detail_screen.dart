import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_actions_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_detail_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/wallet_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_pages_provider.dart';
import 'package:openbudget_app/src/features/transactions/widgets/transaction_row.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/utils/money_input.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Account detail: balances and a reconcile flow for track-by-transactions
/// accounts, a value history for track-by-value accounts, and holdings for
/// wallet accounts. Every converted figure is the server's.
class AccountDetailScreen extends HookConsumerWidget {
  const AccountDetailScreen({
    required this.entityId,
    required this.accountId,
    super.key,
  });

  final String entityId;
  final String accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final accountAsync = ref.watch(accountDetailProvider(accountId));
    final balancesAsync = ref.watch(accountBalancesProvider(accountId));
    final valuationsAsync = ref.watch(accountValuationsProvider(accountId));
    final entityAsync = ref.watch(entityDetailProvider(entityId));
    final pagesAsync = ref.watch(transactionPagesProvider(entityId));
    final walletAsync = ref.watch(walletForAccountProvider(accountId));
    final walletId = walletAsync.value?.id?.toString();
    final netWorthAsync = ref.watch(netWorthForEntitiesProvider({entityId}));
    final convertedMinor = useMemoized(() {
      final view = netWorthAsync.value;
      for (final row in view?.accounts ?? const <NetWorthAccountRow>[]) {
        if (row.accountId.toString() == accountId) return row.convertedMinor;
      }
      return null;
    }, [netWorthAsync]);

    final account = accountAsync.value;
    final baseCurrencyCode = entityAsync.value?.baseCurrencyCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(account?.name ?? ''),
        actions: [
          if (account != null && account.closedAt == null)
            IconButton(
              icon: const SkribbleIcon(data: OpenBudgetIcons.edit),
              tooltip: l10n.accountEditTitle,
              onPressed: () => context.goNamed(
                addAccountRoute,
                pathParameters: {'entityId': entityId},
              ),
            ),
        ],
      ),
      body: accountAsync.when(
        loading: () => const Center(child: ObLoadingPanel(label: '')),
        error: (error, _) => Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: ObStatePanel.problem(
            title: l10n.accountLoadError,
            action: ObStateAction(
              label: l10n.homeRetry,
              onPressed: () => ref.invalidate(accountDetailProvider(accountId)),
            ),
          ),
        ),
        data: (account) {
          final currencyCode = account.currencyCode;
          final balanceTone = account.balanceMinor > 0
              ? ObTone.funded
              : account.balanceMinor < 0
              ? ObTone.overspent
              : ObTone.neutral;
          final balances = balancesAsync.value;
          final isValuation =
              account.balanceSource == AccountBalanceSource.valuations;
          final isClosed = account.closedAt != null;

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.xl,
            ),
            children: [
              ObCard(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ObAmount(
                          formatMinorForCode(
                            account.balanceMinor,
                            currencyCode,
                          ),
                          tone: balanceTone,
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(width: SpacingTokens.sm),
                        ObToneChip(label: currencyCode),
                      ],
                    ),
                    if (balances != null) ...[
                      const SizedBox(height: SpacingTokens.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.accountDetailClearedLabel(
                              formatMinorForCode(
                                balances.clearedMinor,
                                currencyCode,
                              ),
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: palette.mutedInk,
                            ),
                          ),
                          const SizedBox(width: SpacingTokens.md),
                          Text(
                            l10n.accountDetailUnclearedLabel(
                              formatMinorForCode(
                                balances.unclearedMinor,
                                currencyCode,
                              ),
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: palette.mutedInk,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (!isValuation &&
                        balances?.reportedBalanceMinor != null) ...[
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        l10n.accountDetailReportedBalance(
                          formatMinorForCode(
                            balances!.reportedBalanceMinor!,
                            currencyCode,
                          ),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.mutedInk,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    if (convertedMinor != null &&
                        isForeignAccountOf(account, baseCurrencyCode)) ...[
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        l10n.accountBaseEquivalent(
                          formatMinorForCode(convertedMinor, baseCurrencyCode!),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.mutedInk,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: SpacingTokens.md),
                    if (!isValuation)
                      FilledButton.icon(
                        onPressed: balances == null
                            ? null
                            : () => _openReconcileSheet(
                                context,
                                ref,
                                account: account,
                                balances: balances,
                              ),
                        icon: const SkribbleIcon(
                          data: OpenBudgetIcons.checkAll,
                        ),
                        label: Text(l10n.accountDetailReconcile),
                      ),
                  ],
                ),
              ),
              if (isClosed) ...[
                const SizedBox(height: SpacingTokens.md),
                ObCard(
                  tone: ObTone.neutral,
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Row(
                    children: [
                      SkribbleIcon(
                        data: OpenBudgetIcons.lock,
                        size: 18,
                        color: palette.mutedInk,
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      Expanded(
                        child: Text(
                          l10n.accountsClosedBadge,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: palette.mutedInk,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await ref
                              .read(accountActionsProvider.notifier)
                              .reopenAccount(
                                accountId: accountId,
                                entityId: entityId,
                              );
                        },
                        child: Text(l10n.accountReopenButton),
                      ),
                    ],
                  ),
                ),
              ],
              if (isValuation) ...[
                const SizedBox(height: SpacingTokens.md),
                ObSectionHeader(
                  title: l10n.accountDetailValuationsTitle,
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                ),
                FilledButton.icon(
                  onPressed: () => _openValuationSheet(
                    context,
                    ref,
                    account: account,
                  ),
                  icon: const SkribbleIcon(data: OpenBudgetIcons.priceChange),
                  label: Text(l10n.accountDetailUpdateValue),
                ),
                const SizedBox(height: SpacingTokens.sm),
                valuationsAsync.maybeWhen(
                  data: (valuations) => Column(
                    children: [
                      for (final valuation in valuations)
                        ObCard(
                          margin: const EdgeInsets.only(
                            bottom: SpacingTokens.xs,
                          ),
                          child: ListTile(
                            title: Text(
                              formatMinorForCode(
                                valuation.valueMinor,
                                currencyCode,
                              ),
                              style: theme.textTheme.titleMedium,
                            ),
                            subtitle: Text(
                              l10n.accountDetailValuedOn(
                                _dateLabel(valuation.valuationDate),
                              ),
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ),
                      if (valuations.isEmpty)
                        ObStatePanel.empty(
                          title: l10n.accountDetailValuationsTitle,
                          message: l10n.accountEditNotesHint,
                        ),
                    ],
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ] else ...[
                if (walletId != null) ...[
                  _WalletHoldingsSection(
                    walletId: walletId,
                    fallbackCurrencyCode: currencyCode,
                  ),
                ],
                const SizedBox(height: SpacingTokens.md),
                ObSectionHeader(
                  title: l10n.accountDetailTransactionsTitle,
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                ),
                ...pagesAsync.maybeWhen(
                  data: (state) => state.items
                      .map(
                        (view) => TransactionRow(
                          view: view,
                          currencyCode: currencyCode,
                          baseCurrencyCode: baseCurrencyCode,
                        ),
                      )
                      .toList(),
                  orElse: () => <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(SpacingTokens.lg),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ],
                ),
                pagesAsync.maybeWhen(
                  data: (state) => state.hasMore
                      ? TextButton(
                          onPressed: () => ref
                              .read(transactionPagesProvider(entityId).notifier)
                              .loadMore(),
                          child: Text(l10n.transactionLoadMore),
                        )
                      : const SizedBox.shrink(),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _openReconcileSheet(
    BuildContext context,
    WidgetRef ref, {
    required Account account,
    required AccountBalancesView balances,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _ReconcileSheet(
        account: account,
        balances: balances,
        accountId: accountId,
        entityId: entityId,
      ),
    );
  }

  Future<void> _openValuationSheet(
    BuildContext context,
    WidgetRef ref, {
    required Account account,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _ValuationSheet(
        account: account,
        accountId: accountId,
        entityId: entityId,
      ),
    );
  }
}

/// Whether the base currency differs from the account's own.
bool isForeignAccountOf(Account account, String? baseCurrencyCode) =>
    baseCurrencyCode != null &&
    baseCurrencyCode.isNotEmpty &&
    baseCurrencyCode != account.currencyCode;

String _dateLabel(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

DateTime _today() {
  final now = DateTime.now();
  return DateTime.utc(now.year, now.month, now.day);
}

/// One wallet holding: quantity in the asset's decimals, value and P&L in
/// the price currency. Unrealised P&L is `valueMinor − costBasisMinor`,
/// computed here in the view model from the sync's stored figures.
class _HoldingTile extends HookWidget {
  const _HoldingTile({
    required this.holding,
    required this.priceCurrencyCode,
  });

  final WalletHolding holding;
  final String priceCurrencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final quantity = _formatQuantity(holding);
    final valueMinor = holding.valueMinor;
    final costMinor = holding.costBasisMinor;
    final pnlMinor = valueMinor != null && costMinor != null
        ? valueMinor - costMinor
        : null;

    return ObCard(
      margin: const EdgeInsets.only(bottom: SpacingTokens.xs),
      child: ListTile(
        title: Text(
          holding.name ?? holding.symbol ?? holding.assetId,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.accountHoldingsQuantityLabel(quantity),
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.mutedInk,
              ),
            ),
            if (valueMinor != null)
              Text(
                l10n.accountHoldingsValueLabel(
                  formatMinorForCode(valueMinor, priceCurrencyCode),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedInk,
                ),
              ),
            if (pnlMinor != null)
              Text(
                l10n.accountHoldingsPnlLabel(
                  formatMinorForCode(pnlMinor, priceCurrencyCode),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: pnlMinor >= 0 ? palette.funded : palette.overspent,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Renders `quantityRaw` (a BigInt of base units) with the asset's
  /// decimals — no floating point touches the quantity.
  static String _formatQuantity(WalletHolding holding) {
    final decimals = holding.decimals;
    final raw = holding.quantityRaw.toString();
    if (decimals <= 0) return raw;
    final padded = raw.padLeft(decimals + 1, '0');
    final whole = padded.substring(0, padded.length - decimals);
    final fraction = padded.substring(padded.length - decimals);
    return '$whole.${fraction.replaceAll(RegExp(r'0+$'), '')}';
  }
}

/// The reconcile sheet: statement balance pre-filled from the bank's
/// reported figure, live difference, optional adjustment transaction.
class _ReconcileSheet extends HookConsumerWidget {
  const _ReconcileSheet({
    required this.account,
    required this.balances,
    required this.accountId,
    required this.entityId,
  });

  final Account account;
  final AccountBalancesView balances;
  final String accountId;
  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currencyCode = account.currencyCode;
    final decimals = currencyDecimalsForCode(currencyCode);
    final statementController = useTextEditingController(
      text: balances.reportedBalanceMinor == null
          ? ''
          : formatMinorUnits(balances.reportedBalanceMinor!, decimals),
    );
    final createAdjustment = useState(true);
    final isSubmitting = useState(false);

    final statementMinor = parseMoneyInput(
      statementController.text,
      decimals: decimals,
    );
    final differenceMinor = statementMinor == null
        ? null
        : statementMinor - balances.clearedMinor;

    return Padding(
      padding: EdgeInsets.only(
        left: SpacingTokens.md,
        right: SpacingTokens.md,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.accountReconcileTitle(account.name),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: SpacingTokens.md),
          TextField(
            controller: statementController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.accountReconcileStatementField,
              prefixText: '$currencyCode ',
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            differenceMinor == null
                ? ''
                : l10n.accountReconcileDifference(
                    formatMinorForCode(differenceMinor, currencyCode),
                  ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SwitchListTile(
            title: Text(l10n.accountReconcileCreateAdjustment),
            value: createAdjustment.value,
            onChanged: (value) => createAdjustment.value = value,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: SpacingTokens.sm),
          FilledButton(
            onPressed: statementMinor == null || isSubmitting.value
                ? null
                : () async {
                    isSubmitting.value = true;
                    final navigator = Navigator.of(context);
                    try {
                      final result = await ref
                          .read(transactionActionsProvider.notifier)
                          .reconcile(
                            accountId: accountId,
                            statementDate: _today(),
                            statementBalanceMinor: statementMinor,
                            createAdjustment: createAdjustment.value,
                          );
                      ref
                        ..invalidate(accountDetailProvider(accountId))
                        ..invalidate(accountBalancesProvider(accountId))
                        ..invalidate(accountListProvider(entityId))
                        ..invalidate(transactionPagesProvider(entityId));
                      if (!context.mounted) return;
                      navigator.pop();
                      showAppToast(
                        context,
                        message: result.reconciledCount == 0
                            ? l10n.accountReconcileNoDifference
                            : l10n.accountReconcileSuccess(
                                result.reconciledCount,
                              ),
                        variant: AppToastVariant.success,
                      );
                    } on Exception catch (_) {
                      isSubmitting.value = false;
                      if (context.mounted) {
                        showAppToast(
                          context,
                          message: l10n.accountReconcileFailed,
                          variant: AppToastVariant.error,
                        );
                      }
                    }
                  },
            child: Text(l10n.accountReconcileSubmit),
          ),
          const SizedBox(height: SpacingTokens.md),
        ],
      ),
    );
  }
}

/// The update-value sheet for track-by-value accounts.
class _ValuationSheet extends HookConsumerWidget {
  const _ValuationSheet({
    required this.account,
    required this.accountId,
    required this.entityId,
  });

  final Account account;
  final String accountId;
  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final decimals = currencyDecimalsForCode(account.currencyCode);
    final valueController = useTextEditingController();
    final date = useState(DateTime.now());
    final isSubmitting = useState(false);

    return Padding(
      padding: EdgeInsets.only(
        left: SpacingTokens.md,
        right: SpacingTokens.md,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.accountDetailUpdateValue,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: SpacingTokens.md),
          TextField(
            controller: valueController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.accountValuationValueField,
              prefixText: '${account.currencyCode} ',
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Row(
            children: [
              Expanded(child: Text(_dateLabel(date.value))),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: date.value,
                    firstDate: DateTime.utc(2000),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  if (picked != null) {
                    date.value = DateTime.utc(
                      picked.year,
                      picked.month,
                      picked.day,
                    );
                  }
                },
                child: Text(l10n.accountValuationDateField),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          FilledButton(
            onPressed: isSubmitting.value
                ? null
                : () async {
                    final valueMinor = parseMoneyInput(
                      valueController.text,
                      decimals: decimals,
                    );
                    if (valueMinor == null) return;
                    isSubmitting.value = true;
                    final navigator = Navigator.of(context);
                    try {
                      await ref
                          .read(accountActionsProvider.notifier)
                          .setValuation(
                            accountId: accountId,
                            entityId: entityId,
                            valuationDate: date.value,
                            valueMinor: valueMinor,
                          );
                      if (!context.mounted) return;
                      navigator.pop();
                      showAppToast(
                        context,
                        message: l10n.accountValuationSaved,
                        variant: AppToastVariant.success,
                      );
                    } on Exception catch (_) {
                      isSubmitting.value = false;
                    }
                  },
            child: Text(l10n.dialogSave),
          ),
          const SizedBox(height: SpacingTokens.md),
        ],
      ),
    );
  }
}

/// Holdings of the account's wallet, loaded directly from `client.wallet`.
class _WalletHoldingsSection extends HookWidget {
  const _WalletHoldingsSection({
    required this.walletId,
    required this.fallbackCurrencyCode,
  });

  final String walletId;
  final String fallbackCurrencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final holdings = useState<List<WalletHolding>?>(null);

    useEffect(() {
      var cancelled = false;
      Future<void> load() async {
        final container = ProviderScope.containerOf(context);
        final client = container.read(serverpodClientProvider);
        try {
          final list = await client.wallet.listHoldings(
            UuidValue.fromString(walletId),
          );
          if (!cancelled) holdings.value = list;
        } on Exception {
          if (!cancelled) holdings.value = const [];
        }
      }

      unawaited(load());
      return () => cancelled = true;
    }, [walletId]);

    final list = holdings.value;
    if (list == null || list.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ObSectionHeader(
          title: l10n.accountDetailHoldingsTitle,
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
        ),
        for (final holding in list)
          _HoldingTile(
            holding: holding,
            priceCurrencyCode:
                holding.priceCurrencyCode ?? fallbackCurrencyCode,
          ),
      ],
    );
  }
}
