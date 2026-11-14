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
import 'package:openbudget_app/src/features/accounts/widgets/wallet_holdings_section.dart';
import 'package:openbudget_app/src/features/accounts/widgets/wallet_settings_sheet.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/reports/providers/net_worth_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_pages_provider.dart';
import 'package:openbudget_app/src/features/transactions/widgets/transaction_row.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/utils/date_labels.dart';
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
    // One stable Set instance per entity: a fresh equal set would make
    // the family re-query on every rebuild and never settle.
    final entityIds = useMemoized(() => {entityId}, [entityId]);
    final netWorthAsync = ref.watch(netWorthForEntitiesProvider(entityIds));
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

          return ObReadableWidth(
            padding: const EdgeInsets.fromLTRB(
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.md,
              SpacingTokens.xl,
            ),
            builder: (context, padding) => ListView(
              padding: padding,
              children: [
                _BalanceCard(
                  account: account,
                  balances: balances,
                  tone: balanceTone,
                  isValuation: isValuation,
                  baseEquivalent:
                      convertedMinor != null &&
                          isForeignAccountOf(account, baseCurrencyCode)
                      ? formatMinorForCode(convertedMinor, baseCurrencyCode!)
                      : null,
                  onReconcile: balances == null
                      ? null
                      : () => _openReconcileSheet(
                          context,
                          ref,
                          account: account,
                          balances: balances,
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
                if (walletId != null) ...[
                  const SizedBox(height: SpacingTokens.md),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: OutlinedButton.icon(
                      key: walletSettingsButtonKey,
                      onPressed: () => showWalletSettingsSheet(
                        context,
                        entityId: entityId,
                        accountId: accountId,
                      ),
                      icon: const SkribbleIcon(
                        data: OpenBudgetIcons.settings,
                        size: 18,
                      ),
                      label: Text(l10n.walletSettingsButton),
                    ),
                  ),
                  WalletHoldingsSection(
                    walletId: walletId,
                    fallbackCurrencyCode: currencyCode,
                  ),
                ],
                if (isValuation) ...[
                  const SizedBox(height: SpacingTokens.md),
                  ObSectionHeader(
                    title: l10n.accountDetailValuationsTitle,
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  ),
                  OutlinedButton.icon(
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
                    data: (valuations) => valuations.isEmpty
                        ? ObStatePanel.empty(
                            title: l10n.accountDetailValuationsTitle,
                            message: l10n.accountEditNotesHint,
                          )
                        : _ValuationList(
                            valuations: valuations,
                            currencyCode: currencyCode,
                          ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ] else ...[
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
                                .read(
                                  transactionPagesProvider(entityId).notifier,
                                )
                                .loadMore(),
                            child: Text(l10n.transactionLoadMore),
                          )
                        : const SizedBox.shrink(),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
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

DateTime _today() {
  final now = DateTime.now();
  return DateTime.utc(now.year, now.month, now.day);
}

/// The balance card: the figure as a hero with its currency, the server's
/// base-currency equivalent for a foreign account, the cleared and
/// uncleared split and the bank's own figure, and the reconcile action.
class _BalanceCard extends HookWidget {
  const _BalanceCard({
    required this.account,
    required this.balances,
    required this.tone,
    required this.isValuation,
    required this.baseEquivalent,
    required this.onReconcile,
  });

  final Account account;
  final AccountBalancesView? balances;
  final ObTone tone;
  final bool isValuation;

  /// The formatted base-currency figure, or null when the account is in
  /// the base currency or the server has no rate.
  final String? baseEquivalent;
  final VoidCallback? onReconcile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final currencyCode = account.currencyCode;
    final balances = this.balances;

    return ObCard(
      raised: true,
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.lg,
        SpacingTokens.md,
        SpacingTokens.lg,
        SpacingTokens.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isValuation
                      ? l10n.accountDetailValueEyebrow
                      : l10n.accountDetailBalanceEyebrow,
                  style: ObTextStyles.eyebrow(
                    theme.textTheme.labelSmall,
                  ).copyWith(color: palette.mutedInk),
                ),
              ),
              ObToneChip(label: currencyCode),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          ObHeroAmount(
            formatMinorForCode(account.balanceMinor, currencyCode),
            tone: tone,
            style: theme.textTheme.displaySmall,
          ),
          if (baseEquivalent case final equivalent?) ...[
            const SizedBox(height: SpacingTokens.xs),
            Text(
              l10n.accountBaseEquivalent(equivalent),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.brand,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          // Cleared and uncleared mean nothing for an account tracked by
          // its value, so only transaction accounts show them.
          if (!isValuation && balances != null) ...[
            const SizedBox(height: SpacingTokens.md),
            Divider(height: 1, thickness: 1.4, color: palette.line),
            const SizedBox(height: SpacingTokens.sm),
            Wrap(
              spacing: SpacingTokens.md,
              runSpacing: SpacingTokens.xs,
              children: [
                _BalanceFact(
                  icon: OpenBudgetIcons.checkCircle,
                  color: palette.funded,
                  text: l10n.accountDetailClearedLabel(
                    formatMinorForCode(balances.clearedMinor, currencyCode),
                  ),
                ),
                _BalanceFact(
                  icon: OpenBudgetIcons.circle,
                  color: palette.mutedInk,
                  text: l10n.accountDetailUnclearedLabel(
                    formatMinorForCode(balances.unclearedMinor, currencyCode),
                  ),
                ),
                if (balances.reportedBalanceMinor case final reported?)
                  _BalanceFact(
                    icon: OpenBudgetIcons.bank,
                    color: palette.mutedInk,
                    text: l10n.accountDetailReportedBalance(
                      formatMinorForCode(reported, currencyCode),
                    ),
                  ),
              ],
            ),
          ],
          if (!isValuation) ...[
            const SizedBox(height: SpacingTokens.md),
            FilledButton.icon(
              onPressed: onReconcile,
              icon: const SkribbleIcon(data: OpenBudgetIcons.checkAll),
              label: Text(l10n.accountDetailReconcile),
            ),
          ],
        ],
      ),
    );
  }
}

/// One fact under the balance: a small glyph and its line of text.
class _BalanceFact extends HookWidget {
  const _BalanceFact({
    required this.icon,
    required this.color,
    required this.text,
  });

  final WiredSvgIconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SkribbleIcon(data: icon, size: 14, color: color),
        const SizedBox(width: SpacingTokens.xs),
        Text(
          text,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.ob.mutedInk,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// The value history on one sheet: newest first, each valuation's date
/// against its figure and the change since the one before it. The change
/// is a subtraction in the account's own currency, never a conversion.
class _ValuationList extends HookWidget {
  const _ValuationList({required this.valuations, required this.currencyCode});

  final List<AccountValuation> valuations;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ObCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (index, valuation) in valuations.indexed) ...[
            if (index > 0)
              Divider(
                height: 1,
                indent: SpacingTokens.md,
                endIndent: SpacingTokens.md,
                color: palette.line,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md,
                vertical: SpacingTokens.sm,
              ),
              // The change sits under the date, so the date keeps the width
              // it needs and the value column holds only the value.
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: SkribbleIcon(
                      data: OpenBudgetIcons.calendar,
                      size: 16,
                      color: palette.mutedInk,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.accountDetailValuedOn(
                            DateLabels.full(context, valuation.valuationDate),
                          ),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: palette.ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (index + 1 < valuations.length)
                          _ValuationChange(
                            changeMinor:
                                valuation.valueMinor -
                                valuations[index + 1].valueMinor,
                            currencyCode: currencyCode,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  ObAmount(
                    formatMinorForCode(valuation.valueMinor, currencyCode),
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ValuationChange extends HookWidget {
  const _ValuationChange({
    required this.changeMinor,
    required this.currencyCode,
  });

  final int changeMinor;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final tone = changeMinor > 0
        ? ObTone.funded
        : changeMinor < 0
        ? ObTone.overspent
        : ObTone.neutral;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (changeMinor != 0) ...[
          SkribbleIcon(
            data: changeMinor > 0
                ? OpenBudgetIcons.trendingUp
                : OpenBudgetIcons.trendingDown,
            size: 12,
            color: palette.hue(tone),
          ),
          const SizedBox(width: 2),
        ],
        Flexible(
          child: Text(
            l10n.accountValuationChange(
              formatMinorForCode(changeMinor.abs(), currencyCode),
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.hue(tone),
            ),
          ),
        ),
      ],
    );
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

    // The controller alone does not rebuild the hook widget; without this
    // the difference line stays at the pre-filled value's difference.
    useListenable(statementController);

    final statementMinor = parseMoneyInput(
      statementController.text,
      decimals: decimals,
    );
    final differenceMinor = statementMinor == null
        ? null
        : statementMinor - balances.clearedMinor;

    final theme = Theme.of(context);
    final palette = theme.ob;
    final matches = differenceMinor == 0;

    return Padding(
      key: const Key('account-reconcile-sheet'),
      padding: EdgeInsets.only(
        left: SpacingTokens.lg,
        right: SpacingTokens.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const ObIconBadge(
                icon: SkribbleIcon(data: OpenBudgetIcons.checkAll),
                spot: 1,
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Text(
                  l10n.accountReconcileTitle(account.name),
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          TextField(
            controller: statementController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: ObTextStyles.amount(theme.textTheme.titleLarge),
            decoration: InputDecoration(
              labelText: l10n.accountReconcileStatementField,
              prefixIcon: const ObFieldIcon(data: OpenBudgetIcons.receipt),
              prefixText: '$currencyCode ',
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          ObCard(
            tone: matches ? ObTone.funded : ObTone.neutral,
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.accountReconcileClearedNow,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: palette.mutedInk,
                        ),
                      ),
                    ),
                    ObAmount(
                      formatMinorForCode(balances.clearedMinor, currencyCode),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
                if (differenceMinor != null) ...[
                  const SizedBox(height: SpacingTokens.sm),
                  // The difference gets the full width: beside a chip it
                  // broke mid-word at 360pt. A mismatch reads in the
                  // caution tone; a match earns the chip under it.
                  Text(
                    key: const Key('account-reconcile-difference'),
                    l10n.accountReconcileDifference(
                      formatMinorForCode(differenceMinor, currencyCode),
                    ),
                    style: ObTextStyles.amount(theme.textTheme.titleMedium)
                        .copyWith(
                          color: matches ? palette.ink : palette.underfunded,
                        ),
                  ),
                  if (matches) ...[
                    const SizedBox(height: SpacingTokens.xs),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: ObToneChip(
                        label: l10n.accountReconcileMatches,
                        tone: ObTone.funded,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          SwitchListTile(
            title: Text(
              l10n.accountReconcileCreateAdjustment,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: matches ? palette.mutedInk : palette.ink,
              ),
            ),
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
          const SizedBox(height: SpacingTokens.lg),
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
              Expanded(child: Text(DateLabels.full(context, date.value))),
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
