import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/add_transaction_sheet.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/features/transactions/screens/edit_transaction_dialog.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum TransactionFilter { all, income, expense }

enum TransactionStatusFilter { all, cleared, uncleared, reconciled }

enum TransactionSort { dateDesc, dateAsc, amountDesc, amountAsc, description }

/// The key on the empty state shown when the ledger has no rows to draw.
const transactionListEmptyKey = Key('transaction-list-empty');

class TransactionListScreen extends HookConsumerWidget {
  const TransactionListScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final transactionsAsync = ref.watch(transactionListProvider(entityId));
    final theme = Theme.of(context);

    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final filter = useState(TransactionFilter.all);
    final dateRangeStart = useState<DateTime?>(null);
    final dateRangeEnd = useState<DateTime?>(null);
    final sortOrder = useState(TransactionSort.dateDesc);
    final flagFilter = useState<String?>(null);
    final statusFilter = useState(TransactionStatusFilter.all);
    final selectionMode = useState(false);
    final selectedIds = useState(<String>{});

    useEffect(() {
      void listener() => searchQuery.value = searchController.text;
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    return Scaffold(
      appBar: selectionMode.value
          ? AppBar(
              leading: IconButton(
                icon: const SkribbleIcon(data: OpenBudgetIcons.close),
                tooltip: l10n.dialogCancel,
                onPressed: () {
                  selectionMode.value = false;
                  selectedIds.value = {};
                },
              ),
              title: Text(l10n.bulkSelectedCount(selectedIds.value.length)),
              actions: [
                IconButton(
                  icon: const SkribbleIcon(data: OpenBudgetIcons.selectAll),
                  tooltip: l10n.bulkSelectAll,
                  onPressed: () {
                    final allIds =
                        transactionsAsync.whenOrNull(
                          data: (txs) => txs
                              .where((tx) => tx.parentTransactionId == null)
                              .map((tx) => tx.id?.toString() ?? '')
                              .where((id) => id.isNotEmpty)
                              .toSet(),
                        ) ??
                        <String>{};
                    selectedIds.value = allIds;
                  },
                ),
                IconButton(
                  icon: const SkribbleIcon(data: OpenBudgetIcons.deselect),
                  tooltip: l10n.bulkDeselectAll,
                  onPressed: () => selectedIds.value = {},
                ),
              ],
            )
          : AppBar(
              leading: IconButton(
                icon: const SkribbleIcon(data: OpenBudgetIcons.back),
                tooltip: l10n.transactionsBack,
                onPressed: () => context.goNamed(
                  planRoute,
                  pathParameters: {'entityId': entityId},
                ),
              ),
              title: Text(l10n.transactionListTitle),
              actions: [
                transactionsAsync.whenOrNull(
                      data: (txs) => txs.isNotEmpty
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const SkribbleIcon(
                                    data: OpenBudgetIcons.sort,
                                  ),
                                  tooltip: l10n.transactionSortTitle,
                                  onPressed: () =>
                                      _showSortMenu(context, sortOrder),
                                ),
                                IconButton(
                                  icon: const SkribbleIcon(
                                    data: OpenBudgetIcons.checkAll,
                                  ),
                                  tooltip: l10n.bulkAssignEnvelope,
                                  onPressed: () => selectionMode.value = true,
                                ),
                                IconButton(
                                  icon: const SkribbleIcon(
                                    data: OpenBudgetIcons.copy,
                                  ),
                                  tooltip: l10n.transactionExportCsv,
                                  onPressed: () => _exportToCsv(context, txs),
                                ),
                              ],
                            )
                          : null,
                    ) ??
                    const SizedBox.shrink(),
              ],
            ),
      body: transactionsAsync.when(
        loading: () => Center(
          child: ObLoadingPanel(label: l10n.transactionsLoading),
        ),
        error: (error, _) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: ObStatePanel.problem(
              title: l10n.transactionLoadError,
              message: error.toString(),
              action: ObStateAction(
                label: l10n.homeRetry,
                onPressed: () =>
                    ref.invalidate(transactionListProvider(entityId)),
              ),
            ),
          ),
        ),
        data: (transactions) {
          // Build payee, envelope, and account name lookup maps.
          final payeeAsync = ref.watch(payeeListProvider(entityId));
          final summaryAsync = ref.watch(budgetSummaryProvider(entityId));
          final accountsAsync = ref.watch(accountListProvider(entityId));
          final payeeMap = <String, String>{};
          if (payeeAsync.hasValue) {
            for (final payee in payeeAsync.value!) {
              final id = payee.id?.toString();
              if (id != null) payeeMap[id] = payee.name;
            }
          }
          final envelopeMap = <String, String>{};
          if (summaryAsync.hasValue && summaryAsync.value != null) {
            for (final cat in summaryAsync.value!.categories) {
              for (final env in cat.envelopes) {
                final id = env.id?.toString();
                if (id != null) envelopeMap[id] = env.name;
              }
            }
          }
          final accountMap = <String, String>{};
          if (accountsAsync.hasValue) {
            for (final account in accountsAsync.value!) {
              final id = account.id?.toString();
              if (id != null) accountMap[id] = account.name;
            }
          }

          // Filter out child split transactions (they have parentTransactionId).
          final childParentIds = transactions
              .where((tx) => tx.parentTransactionId != null)
              .map((tx) => tx.parentTransactionId.toString())
              .toSet();
          final topLevel = transactions
              .where((tx) => tx.parentTransactionId == null)
              .toList();
          final sorted = List.of(topLevel)
            ..sort(
              (a, b) => switch (sortOrder.value) {
                TransactionSort.dateDesc => b.transactionDate.compareTo(
                  a.transactionDate,
                ),
                TransactionSort.dateAsc => a.transactionDate.compareTo(
                  b.transactionDate,
                ),
                TransactionSort.amountDesc => b.amountMinor.abs().compareTo(
                  a.amountMinor.abs(),
                ),
                TransactionSort.amountAsc => a.amountMinor.abs().compareTo(
                  b.amountMinor.abs(),
                ),
                TransactionSort.description =>
                  a.description.toLowerCase().compareTo(
                    b.description.toLowerCase(),
                  ),
              },
            );

          final query = searchQuery.value.toLowerCase();
          final filtered = sorted.where((tx) {
            if (filter.value == TransactionFilter.income &&
                tx.amountMinor <= 0) {
              return false;
            }
            if (filter.value == TransactionFilter.expense &&
                tx.amountMinor >= 0) {
              return false;
            }
            if (flagFilter.value != null && tx.flagColor != flagFilter.value) {
              return false;
            }
            if (statusFilter.value == TransactionStatusFilter.cleared &&
                !tx.cleared) {
              return false;
            }
            if (statusFilter.value == TransactionStatusFilter.uncleared &&
                (tx.cleared || tx.reconciled)) {
              return false;
            }
            if (statusFilter.value == TransactionStatusFilter.reconciled &&
                !tx.reconciled) {
              return false;
            }
            if (query.isNotEmpty &&
                !tx.description.toLowerCase().contains(query) &&
                !(tx.memo?.toLowerCase().contains(query) ?? false)) {
              return false;
            }
            if (dateRangeStart.value != null) {
              final txDate = DateTime(
                tx.transactionDate.year,
                tx.transactionDate.month,
                tx.transactionDate.day,
              );
              if (txDate.isBefore(dateRangeStart.value!)) return false;
            }
            if (dateRangeEnd.value != null) {
              final txDate = DateTime(
                tx.transactionDate.year,
                tx.transactionDate.month,
                tx.transactionDate.day,
              );
              if (txDate.isAfter(dateRangeEnd.value!)) return false;
            }
            return true;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.md,
                  SpacingTokens.sm,
                  SpacingTokens.md,
                  0,
                ),
                child: ObTextField(
                  controller: searchController,
                  hintText: l10n.transactionSearchHint,
                  prefixIcon: const ObFieldIcon(data: OpenBudgetIcons.search),
                  suffixIcon: searchQuery.value.isNotEmpty
                      ? IconButton(
                          key: const Key('transaction-search-clear'),
                          icon: const SkribbleIcon(
                            data: OpenBudgetIcons.close,
                          ),
                          tooltip: l10n.transactionsSearchClear,
                          onPressed: () {
                            searchController.clear();
                            searchQuery.value = '';
                          },
                        )
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _FilterChip(
                            label: l10n.transactionFilterAll,
                            icon: OpenBudgetIcons.list,
                            selected: filter.value == TransactionFilter.all,
                            onSelected: () =>
                                filter.value = TransactionFilter.all,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          _FilterChip(
                            label: l10n.transactionFilterIncome,
                            icon: OpenBudgetIcons.inflow,
                            selected: filter.value == TransactionFilter.income,
                            onSelected: () =>
                                filter.value = TransactionFilter.income,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          _FilterChip(
                            label: l10n.transactionFilterExpense,
                            icon: OpenBudgetIcons.outflow,
                            selected: filter.value == TransactionFilter.expense,
                            onSelected: () =>
                                filter.value = TransactionFilter.expense,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          _FilterChip(
                            label: dateRangeStart.value != null
                                ? _formatShortDate(dateRangeStart.value!)
                                : l10n.transactionDateRangeFilter,
                            icon: OpenBudgetIcons.calendar,
                            selected: dateRangeStart.value != null,
                            onSelected: () => _pickDateRange(
                              context,
                              dateRangeStart,
                              dateRangeEnd,
                              transactions,
                            ),
                          ),
                          if (dateRangeStart.value != null)
                            IconButton(
                              icon: const SkribbleIcon(
                                data: OpenBudgetIcons.close,
                                size: 20,
                              ),
                              tooltip: l10n.transactionDateRangeClear,
                              onPressed: () {
                                dateRangeStart.value = null;
                                dateRangeEnd.value = null;
                              },
                            ),
                          const SizedBox(width: SpacingTokens.sm),
                          _FlagFilterChip(
                            selectedFlag: flagFilter.value,
                            onSelected: (flag) => flagFilter.value = flag,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          _StatusFilterChip(
                            value: statusFilter.value,
                            onSelected: (v) => statusFilter.value = v,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        l10n.transactionResultCount(filtered.length),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.mutedInk,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (filtered.isEmpty)
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      child: ObStatePanel.empty(
                        key: transactionListEmptyKey,
                        title: transactions.isEmpty
                            ? l10n.transactionEmpty
                            : l10n.transactionNoResults,
                        doodle: transactions.isEmpty
                            ? WiredDoodleKind.leaf
                            : WiredDoodleKind.cloud,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(transactionListProvider(entityId)),
                    child: _GroupedTransactionList(
                      transactions: filtered,
                      childParentIds: childParentIds,
                      entityId: entityId,
                      payeeMap: payeeMap,
                      envelopeMap: envelopeMap,
                      accountMap: accountMap,
                      selectionMode: selectionMode.value,
                      selectedIds: selectedIds.value,
                      onToggleSelection: (id) {
                        final current = Set<String>.of(selectedIds.value);
                        if (current.contains(id)) {
                          current.remove(id);
                        } else {
                          current.add(id);
                        }
                        selectedIds.value = current;
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addTransactionSheetTitle,
        onPressed: () async {
          final action = await showModalBottomSheet<AddTransactionAction>(
            context: context,
            isScrollControlled: true,
            showDragHandle: false,
            builder: (_) => AddTransactionSheet(entityId: entityId),
          );
          if (!context.mounted || action == null) return;
          switch (action) {
            case AddTransactionAction.income:
              context.goNamed(addIncomeRoute, pathParameters: {'entityId': entityId});
            case AddTransactionAction.expense:
              context.goNamed(
                addExpenseRoute,
                pathParameters: {'entityId': entityId},
              );
            case AddTransactionAction.transfer:
              await context.pushNamed(
                createTransferRoute,
                pathParameters: {'entityId': entityId},
              );
          }
        },
        child: const SkribbleIcon(data: OpenBudgetIcons.add),
      ),
      bottomNavigationBar: selectionMode.value && selectedIds.value.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: ObCard(
                  padding: const EdgeInsets.all(SpacingTokens.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: ObFilledButton(
                          onPressed: () => _showEnvelopePicker(
                            context,
                            ref,
                            selectedIds.value,
                            selectionMode,
                            selectedIds,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SkribbleIcon(
                                data: OpenBudgetIcons.envelope,
                                size: 18,
                              ),
                              const SizedBox(width: SpacingTokens.xs),
                              Flexible(
                                child: Text(l10n.bulkAssignEnvelope),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      IconButton(
                        key: const Key('bulk-flag-button'),
                        onPressed: () => _showBulkFlagMenu(
                          context,
                          ref,
                          selectedIds.value,
                          selectionMode,
                          selectedIds,
                        ),
                        icon: const SkribbleIcon(data: OpenBudgetIcons.flag),
                        tooltip: l10n.bulkSetFlag,
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      IconButton(
                        key: const Key('bulk-clear-button'),
                        onPressed: () => _bulkMarkCleared(
                          context,
                          ref,
                          transactionsAsync,
                          selectedIds.value,
                          selectionMode,
                          selectedIds,
                        ),
                        icon: const SkribbleIcon(
                          data: OpenBudgetIcons.checkCircle,
                        ),
                        tooltip: l10n.bulkMarkCleared,
                      ),
                      const SizedBox(width: SpacingTokens.sm),
                      IconButton(
                        key: const Key('bulk-delete-button'),
                        onPressed: () => _confirmBulkDelete(
                          context,
                          ref,
                          selectedIds.value,
                          selectionMode,
                          selectedIds,
                        ),
                        icon: const SkribbleIcon(data: OpenBudgetIcons.delete),
                        color: palette.overspent,
                        tooltip: l10n.bulkDeleteTitle,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _showEnvelopePicker(
    BuildContext context,
    WidgetRef ref,
    Set<String> ids,
    ValueNotifier<bool> selectionMode,
    ValueNotifier<Set<String>> selectedIds,
  ) async {
    final l10n = AppLocalizations.of(context);
    final summaryAsync = ref.read(budgetSummaryProvider(entityId));
    if (!summaryAsync.hasValue) return;

    final summary = summaryAsync.value!;
    final envelopeItems = <(String, String)>[];
    for (final catEnv in summary.categories) {
      for (final envelope in catEnv.envelopes) {
        final id = envelope.id?.toString() ?? '';
        if (id.isNotEmpty) {
          envelopeItems.add((id, '${catEnv.category.name} / ${envelope.name}'));
        }
      }
    }

    final selectedEnvelope = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: Text(
                l10n.bulkSelectEnvelope,
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: envelopeItems.length,
                itemBuilder: (ctx, index) {
                  final (id, label) = envelopeItems[index];
                  return ListTile(
                    leading: const SkribbleIcon(
                      data: OpenBudgetIcons.envelope,
                    ),
                    title: Text(label),
                    onTap: () => Navigator.of(ctx).pop(id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selectedEnvelope == null || !context.mounted) return;

    try {
      final count = await ref
          .read(transactionActionsProvider.notifier)
          .bulkAssignEnvelope(
            transactionIds: ids.toList(),
            envelopeId: selectedEnvelope,
            entityId: entityId,
          );
      selectionMode.value = false;
      selectedIds.value = {};
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.bulkAssignSuccess(count),
          variant: AppToastVariant.success,
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.bulkAssignError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  void _showBulkFlagMenu(
    BuildContext context,
    WidgetRef ref,
    Set<String> ids,
    ValueNotifier<bool> selectionMode,
    ValueNotifier<Set<String>> selectedIds,
  ) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final flags = _flagOptions(l10n);

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: Text(
                  l10n.bulkSetFlag,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              Wrap(
                spacing: SpacingTokens.md,
                runSpacing: SpacingTokens.sm,
                alignment: WrapAlignment.center,
                children: [
                  for (final (value, label, tone) in flags)
                    ActionChip(
                      avatar: SkribbleIcon(
                        data: OpenBudgetIcons.flag,
                        color: palette.hue(tone),
                        size: 18,
                      ),
                      label: Text(label),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        unawaited(
                          _applyBulkFlag(
                            context,
                            ref,
                            ids,
                            selectionMode,
                            selectedIds,
                            flagColor: value,
                          ),
                        );
                      },
                    ),
                ],
              ),
              const Divider(),
              ListTile(
                leading: const SkribbleIcon(data: OpenBudgetIcons.flag),
                title: Text(l10n.bulkClearFlag),
                onTap: () {
                  Navigator.of(ctx).pop();
                  unawaited(
                    _applyBulkFlag(
                      context,
                      ref,
                      ids,
                      selectionMode,
                      selectedIds,
                    ),
                  );
                },
              ),
              const SizedBox(height: SpacingTokens.sm),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyBulkFlag(
    BuildContext context,
    WidgetRef ref,
    Set<String> ids,
    ValueNotifier<bool> selectionMode,
    ValueNotifier<Set<String>> selectedIds, {
    String? flagColor,
  }) async {
    final l10n = AppLocalizations.of(context);
    try {
      final count = await ref
          .read(transactionActionsProvider.notifier)
          .bulkSetFlag(
            transactionIds: ids.toList(),
            entityId: entityId,
            flagColor: flagColor,
          );
      selectionMode.value = false;
      selectedIds.value = {};
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.bulkFlagSuccess(count),
          variant: AppToastVariant.success,
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.bulkFlagError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<void> _bulkMarkCleared(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Transaction>> transactionsAsync,
    Set<String> ids,
    ValueNotifier<bool> selectionMode,
    ValueNotifier<Set<String>> selectedIds,
  ) async {
    final l10n = AppLocalizations.of(context);

    // Only toggle uncleared, non-reconciled transactions to "cleared".
    final unclearedIds = <String>[];
    if (transactionsAsync.hasValue) {
      for (final tx in transactionsAsync.value!) {
        final txId = tx.id?.toString() ?? '';
        if (ids.contains(txId) && !tx.cleared && !tx.reconciled) {
          unclearedIds.add(txId);
        }
      }
    }

    if (unclearedIds.isEmpty) {
      // All selected are already cleared — toggle them to uncleared instead.
      final clearedIds = <String>[];
      if (transactionsAsync.hasValue) {
        for (final tx in transactionsAsync.value!) {
          final txId = tx.id?.toString() ?? '';
          if (ids.contains(txId) && tx.cleared && !tx.reconciled) {
            clearedIds.add(txId);
          }
        }
      }
      if (clearedIds.isEmpty) return;

      try {
        final count = await ref
            .read(transactionActionsProvider.notifier)
            .bulkToggleCleared(transactionIds: clearedIds, entityId: entityId);
        selectionMode.value = false;
        selectedIds.value = {};
        if (context.mounted) {
          showAppToast(
            context,
            message: l10n.bulkClearSuccess(count),
            variant: AppToastVariant.success,
          );
        }
      } on Exception catch (_) {
        if (context.mounted) {
          showAppToast(
            context,
            message: l10n.bulkClearError,
            variant: AppToastVariant.error,
          );
        }
      }
      return;
    }

    try {
      final count = await ref
          .read(transactionActionsProvider.notifier)
          .bulkToggleCleared(transactionIds: unclearedIds, entityId: entityId);
      selectionMode.value = false;
      selectedIds.value = {};
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.bulkClearSuccess(count),
          variant: AppToastVariant.success,
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.bulkClearError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<void> _confirmBulkDelete(
    BuildContext context,
    WidgetRef ref,
    Set<String> ids,
    ValueNotifier<bool> selectionMode,
    ValueNotifier<Set<String>> selectedIds,
  ) async {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.bulkDeleteTitle),
        content: Text(l10n.bulkDeleteConfirm(ids.length)),
        actions: [
          ObTextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: palette.overspent,
              foregroundColor: palette.onAction,
            ),
            child: Text(l10n.deleteConfirmButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      final count = await ref
          .read(transactionActionsProvider.notifier)
          .bulkDelete(transactionIds: ids.toList(), entityId: entityId);
      selectionMode.value = false;
      selectedIds.value = {};
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.bulkDeleteSuccess(count),
          variant: AppToastVariant.success,
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.bulkDeleteError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  void _exportToCsv(BuildContext context, List<Transaction> transactions) {
    final l10n = AppLocalizations.of(context);
    final buffer = StringBuffer()
      ..writeln('Date,Description,Amount,Memo,Status');

    final topLevel =
        transactions.where((tx) => tx.parentTransactionId == null).toList()
          ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    for (final tx in topLevel) {
      final date = _formatDateIso(tx.transactionDate);
      final desc = _escapeCsv(tx.description);
      final amount = formatMinorForCode(tx.amountMinor, tx.currencyCode);
      final memo = _escapeCsv(tx.memo ?? '');
      final status = tx.reconciled
          ? 'Reconciled'
          : tx.cleared
          ? 'Cleared'
          : 'Uncleared';
      buffer.writeln('$date,$desc,$amount,$memo,$status');
    }

    unawaited(Clipboard.setData(ClipboardData(text: buffer.toString())));
    showAppToast(
      context,
      message: l10n.transactionExportSuccess(topLevel.length),
      variant: AppToastVariant.success,
    );
  }

  static String _formatDateIso(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  Future<void> _pickDateRange(
    BuildContext context,
    ValueNotifier<DateTime?> dateRangeStart,
    ValueNotifier<DateTime?> dateRangeEnd,
    List<Transaction> transactions,
  ) async {
    final now = DateTime.now();
    final earliest = transactions.isNotEmpty
        ? transactions
              .map((tx) => tx.transactionDate)
              .reduce((a, b) => a.isBefore(b) ? a : b)
        : DateTime(now.year - 1);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(earliest.year, earliest.month, earliest.day),
      lastDate: now,
      initialDateRange: dateRangeStart.value != null
          ? DateTimeRange(
              start: dateRangeStart.value!,
              end: dateRangeEnd.value ?? now,
            )
          : null,
    );

    if (picked != null) {
      dateRangeStart.value = picked.start;
      dateRangeEnd.value = picked.end;
    }
  }

  static String _formatShortDate(DateTime date) => '${date.month}/${date.day}';

  void _showSortMenu(
    BuildContext context,
    ValueNotifier<TransactionSort> sortOrder,
  ) {
    final l10n = AppLocalizations.of(context);
    final sortOptions = <(TransactionSort, String, WiredSvgIconData)>[
      (
        TransactionSort.dateDesc,
        l10n.transactionSortDateDesc,
        OpenBudgetIcons.chevronDown,
      ),
      (
        TransactionSort.dateAsc,
        l10n.transactionSortDateAsc,
        OpenBudgetIcons.chevronUp,
      ),
      (
        TransactionSort.amountDesc,
        l10n.transactionSortAmountDesc,
        OpenBudgetIcons.chevronDown,
      ),
      (
        TransactionSort.amountAsc,
        l10n.transactionSortAmountAsc,
        OpenBudgetIcons.chevronUp,
      ),
      (
        TransactionSort.description,
        l10n.transactionSortDescription,
        OpenBudgetIcons.sortAlphabetical,
      ),
    ];

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: Text(
                  l10n.transactionSortTitle,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1),
              for (final (value, label, icon) in sortOptions)
                ListTile(
                  leading: SkribbleIcon(data: icon),
                  title: Text(label),
                  trailing: sortOrder.value == value
                      ? const SkribbleIcon(data: OpenBudgetIcons.check)
                      : null,
                  onTap: () {
                    sortOrder.value = value;
                    Navigator.of(ctx).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

List<(String, String, ObTone)> _flagOptions(AppLocalizations l10n) => [
  ('red', l10n.transactionFlagRed, ObTone.overspent),
  ('orange', l10n.transactionFlagOrange, ObTone.underfunded),
  ('yellow', l10n.transactionFlagYellow, ObTone.underfunded),
  ('green', l10n.transactionFlagGreen, ObTone.funded),
  ('blue', l10n.transactionFlagBlue, ObTone.brand),
  ('purple', l10n.transactionFlagPurple, ObTone.review),
];

String? _flagLabel(String? flagColor, AppLocalizations l10n) =>
    switch (flagColor) {
      'red' => l10n.transactionFlagRed,
      'orange' => l10n.transactionFlagOrange,
      'yellow' => l10n.transactionFlagYellow,
      'green' => l10n.transactionFlagGreen,
      'blue' => l10n.transactionFlagBlue,
      'purple' => l10n.transactionFlagPurple,
      _ => null,
    };

class _FilterChip extends HookWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final WiredSvgIconData icon;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    return FilterChip(
      avatar: SkribbleIcon(
        data: icon,
        size: 18,
        color: selected ? palette.ink : palette.mutedInk,
      ),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _FlagFilterChip extends HookWidget {
  const _FlagFilterChip({required this.selectedFlag, required this.onSelected});

  final String? selectedFlag;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final flagTone = _flagToneFromString(selectedFlag);
    final isActive = flagTone != null;

    return FilterChip(
      avatar: SkribbleIcon(
        data: OpenBudgetIcons.flag,
        size: 18,
        color: flagTone == null ? palette.mutedInk : palette.hue(flagTone),
      ),
      label: Text(l10n.transactionFilterFlagged),
      selected: isActive,
      onSelected: (_) => _showFlagPicker(context, l10n),
    );
  }

  void _showFlagPicker(BuildContext context, AppLocalizations l10n) {
    final palette = Theme.of(context).ob;
    final flags = _flagOptions(l10n);

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: Text(
                  l10n.transactionFilterFlagged,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              Wrap(
                spacing: SpacingTokens.md,
                runSpacing: SpacingTokens.sm,
                alignment: WrapAlignment.center,
                children: [
                  for (final (value, label, tone) in flags)
                    ActionChip(
                      avatar: SkribbleIcon(
                        data: OpenBudgetIcons.flag,
                        color: palette.hue(tone),
                        size: 18,
                      ),
                      label: Text(label),
                      side: selectedFlag == value
                          ? BorderSide(color: palette.ink, width: 2)
                          : null,
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        onSelected(selectedFlag == value ? null : value);
                      },
                    ),
                ],
              ),
              if (selectedFlag != null) ...[
                const Divider(),
                ListTile(
                  leading: const SkribbleIcon(data: OpenBudgetIcons.close),
                  title: Text(l10n.transactionFlagClear),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onSelected(null);
                  },
                ),
              ],
              const SizedBox(height: SpacingTokens.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusFilterChip extends HookWidget {
  const _StatusFilterChip({required this.value, required this.onSelected});

  final TransactionStatusFilter value;
  final ValueChanged<TransactionStatusFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final isActive = value != TransactionStatusFilter.all;
    final label = switch (value) {
      TransactionStatusFilter.all => l10n.transactionFilterStatus,
      TransactionStatusFilter.cleared => l10n.transactionFilterCleared,
      TransactionStatusFilter.uncleared => l10n.transactionFilterUncleared,
      TransactionStatusFilter.reconciled => l10n.transactionFilterReconciled,
    };

    return FilterChip(
      avatar: SkribbleIcon(
        data: isActive ? OpenBudgetIcons.checkCircle : OpenBudgetIcons.circle,
        size: 18,
        color: isActive ? palette.ink : palette.mutedInk,
      ),
      label: Text(label),
      selected: isActive,
      onSelected: (_) => _showStatusPicker(context, l10n),
    );
  }

  void _showStatusPicker(BuildContext context, AppLocalizations l10n) {
    final options = <(TransactionStatusFilter, String, WiredSvgIconData)>[
      (
        TransactionStatusFilter.all,
        l10n.transactionFilterAll,
        OpenBudgetIcons.list,
      ),
      (
        TransactionStatusFilter.cleared,
        l10n.transactionFilterCleared,
        OpenBudgetIcons.checkCircle,
      ),
      (
        TransactionStatusFilter.uncleared,
        l10n.transactionFilterUncleared,
        OpenBudgetIcons.circle,
      ),
      (
        TransactionStatusFilter.reconciled,
        l10n.transactionFilterReconciled,
        OpenBudgetIcons.lock,
      ),
    ];

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: Text(
                  l10n.transactionFilterStatus,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1),
              for (final (filterValue, label, icon) in options)
                ListTile(
                  leading: SkribbleIcon(data: icon),
                  title: Text(label),
                  trailing: value == filterValue
                      ? const SkribbleIcon(data: OpenBudgetIcons.check)
                      : null,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onSelected(filterValue);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

ObTone? _flagToneFromString(String? flagColor) => switch (flagColor) {
  'red' => ObTone.overspent,
  'orange' => ObTone.underfunded,
  'yellow' => ObTone.underfunded,
  'green' => ObTone.funded,
  'blue' => ObTone.brand,
  'purple' => ObTone.review,
  _ => null,
};

class _TransactionTile extends HookConsumerWidget {
  const _TransactionTile({
    required this.transaction,
    required this.entityId,
    this.isSplit = false,
    this.payeeName,
    this.envelopeName,
    this.accountName,
    this.selectionMode = false,
    this.isSelected = false,
    this.onToggleSelection,
  });

  final Transaction transaction;
  final String entityId;
  final bool isSplit;
  final String? payeeName;
  final String? envelopeName;
  final String? accountName;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback? onToggleSelection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final isIncome = transaction.amountMinor > 0;
    final tone = isIncome ? ObTone.funded : ObTone.neutral;

    final statusIcon = transaction.reconciled
        ? OpenBudgetIcons.lock
        : transaction.cleared
        ? OpenBudgetIcons.checkCircle
        : OpenBudgetIcons.circle;
    final statusColor = transaction.reconciled
        ? palette.brand
        : transaction.cleared
        ? palette.funded
        : palette.mutedInk;
    final statusTone = transaction.reconciled
        ? ObTone.brand
        : transaction.cleared
        ? ObTone.funded
        : ObTone.neutral;
    final statusLabel = transaction.reconciled
        ? l10n.transactionReconciled
        : transaction.cleared
        ? l10n.transactionCleared
        : l10n.transactionUncleared;

    final flagTone = _flagToneFromString(transaction.flagColor);
    final flagLabel = _flagLabel(transaction.flagColor, l10n);

    final card = GestureDetector(
      onLongPress: selectionMode
          ? null
          : () => _showFlagMenu(context, ref, l10n),
      child: ObCard(
        margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
        tone: isSelected ? ObTone.brand : null,
        onTap: selectionMode
            ? onToggleSelection
            : () => _showEditDialog(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.xs,
            SpacingTokens.sm,
            SpacingTokens.md,
            SpacingTokens.sm,
          ),
          child: Row(
            children: [
              if (selectionMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onToggleSelection?.call(),
                )
              else
                Tooltip(
                  message: statusLabel,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: transaction.reconciled
                        ? null
                        : () => _toggleCleared(context, ref, l10n),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child: SkribbleIcon(
                          data: statusIcon,
                          size: 22,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: SpacingTokens.xs),
              Container(
                width: 36,
                height: 36,
                decoration: ObRoughDecoration(
                  color: palette.wash(tone),
                  outline: palette.quietPen,
                  radius: 18,
                  strokeWidth: 1.6,
                  seed: 11,
                ),
                child: Center(
                  child: SkribbleIcon(
                    data: isIncome
                        ? OpenBudgetIcons.inflow
                        : OpenBudgetIcons.outflow,
                    size: 20,
                    color: palette.hue(tone),
                    semanticLabel: isIncome
                        ? l10n.transactionAddIncome
                        : l10n.transactionAddExpense,
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      transaction.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: palette.ink,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    _buildMeta(theme, palette),
                    Padding(
                      padding: const EdgeInsets.only(top: SpacingTokens.xs),
                      child: Wrap(
                        spacing: SpacingTokens.xs,
                        runSpacing: SpacingTokens.xs,
                        children: [
                          if (isSplit)
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 180,
                              ),
                              child: ObToneChip(
                                label: l10n.splitLabel,
                                tone: ObTone.review,
                                icon: const SkribbleIcon(
                                  data: OpenBudgetIcons.split,
                                  size: 14,
                                ),
                              ),
                            ),
                          if (!isIncome && (envelopeName?.isEmpty ?? true))
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 180,
                              ),
                              child: ObToneChip(
                                label: l10n.transactionUnassigned,
                                tone: ObTone.review,
                                icon: const SkribbleIcon(
                                  data: OpenBudgetIcons.envelope,
                                  size: 14,
                                ),
                              ),
                            ),
                          if (flagTone != null && flagLabel != null)
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: 180,
                              ),
                              child: ObToneChip(
                                label: flagLabel,
                                tone: flagTone,
                                icon: const SkribbleIcon(
                                  data: OpenBudgetIcons.flag,
                                  size: 14,
                                ),
                              ),
                            ),
                          ObToneChip(label: statusLabel, tone: statusTone),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 132),
                child: ObAmount(
                  formatMinorForCode(
                    transaction.amountMinor,
                    transaction.currencyCode,
                  ),
                  tone: tone,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selectionMode) return card;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: SpacingTokens.lg),
        margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
        decoration: ObRoughDecoration(
          color: palette.overspent,
          outline: palette.overspent,
          seed: 23,
        ),
        child: SkribbleIcon(
          data: OpenBudgetIcons.delete,
          color: palette.onAction,
        ),
      ),
      confirmDismiss: (_) => _confirmDelete(context, l10n),
      onDismissed: (_) => _deleteTransaction(context, ref, l10n),
      child: card,
    );
  }

  Widget _buildMeta(ThemeData theme, ObPalette palette) {
    final hasMemo = transaction.memo != null && transaction.memo!.isNotEmpty;
    final hasEnvelope = envelopeName != null && envelopeName!.isNotEmpty;
    final hasAccount = accountName != null && accountName!.isNotEmpty;
    final hasPayee = payeeName != null && payeeName!.isNotEmpty;
    if (!hasMemo && !hasEnvelope && !hasAccount && !hasPayee) {
      return const SizedBox.shrink();
    }

    final contextParts = [
      if (hasEnvelope) envelopeName!,
      if (hasAccount) accountName!,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasPayee)
          Text(
            payeeName!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.mutedInk,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (contextParts.isNotEmpty)
          Text(
            contextParts.join(' \u2022 '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (hasMemo)
          Text(
            transaction.memo!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }

  Future<void> _toggleCleared(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    try {
      await ref
          .read(transactionActionsProvider.notifier)
          .toggleCleared(
            transactionId: transaction.id?.toString() ?? '',
            entityId: entityId,
          );
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.transactionEditError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final palette = Theme.of(context).ob;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(
          '${l10n.deleteConfirmMessage}\n\n"${transaction.description}"',
        ),
        actions: [
          ObTextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: palette.overspent,
              foregroundColor: palette.onAction,
            ),
            child: Text(l10n.deleteConfirmButton),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    try {
      final deleted = await ref
          .read(transactionActionsProvider.notifier)
          .deleteTransaction(
            transactionId: transaction.id?.toString() ?? '',
            entityId: entityId,
          );
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.deleteSuccess,
          variant: AppToastVariant.success,
          actionLabel: l10n.undoAction,
          onAction: () => _undoDelete(context, ref, deleted, l10n),
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.deleteError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<void> _undoDelete(
    BuildContext context,
    WidgetRef ref,
    Transaction deleted,
    AppLocalizations l10n,
  ) async {
    try {
      await ref
          .read(transactionActionsProvider.notifier)
          .undoDeleteTransaction(
            deletedTransaction: deleted,
            entityId: entityId,
          );
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.undoDeleteSuccess,
          variant: AppToastVariant.success,
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.undoDeleteError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  void _showFlagMenu(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final flags = _flagOptions(l10n);

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: Text(
                  l10n.transactionFlagTitle,
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
              ),
              Wrap(
                spacing: SpacingTokens.md,
                runSpacing: SpacingTokens.sm,
                alignment: WrapAlignment.center,
                children: [
                  for (final (value, label, tone) in flags)
                    _FlagChip(
                      label: label,
                      tone: tone,
                      selected: transaction.flagColor == value,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        unawaited(
                          _setFlag(context, ref, l10n, flagColor: value),
                        );
                      },
                    ),
                ],
              ),
              if (transaction.flagColor != null) ...[
                const Divider(),
                ListTile(
                  leading: const SkribbleIcon(data: OpenBudgetIcons.flag),
                  title: Text(l10n.transactionFlagClear),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    unawaited(_setFlag(context, ref, l10n));
                  },
                ),
              ],
              const SizedBox(height: SpacingTokens.sm),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _setFlag(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n, {
    String? flagColor,
  }) async {
    try {
      await ref
          .read(transactionActionsProvider.notifier)
          .setFlag(
            transactionId: transaction.id?.toString() ?? '',
            entityId: entityId,
            flagColor: flagColor,
          );
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.transactionEditError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  void _showEditDialog(BuildContext context) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (_) => EditTransactionDialog(
          transaction: transaction,
          entityId: entityId,
          currencyCode: transaction.currencyCode,
        ),
      ),
    );
  }
}

class _FlagChip extends HookWidget {
  const _FlagChip({
    required this.label,
    required this.tone,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final ObTone tone;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    return ActionChip(
      avatar: SkribbleIcon(
        data: OpenBudgetIcons.flag,
        color: palette.hue(tone),
        size: 18,
      ),
      label: Text(label),
      side: selected ? BorderSide(color: palette.ink, width: 2) : null,
      onPressed: onTap,
    );
  }
}

class _GroupedTransactionList extends HookWidget {
  const _GroupedTransactionList({
    required this.transactions,
    required this.childParentIds,
    required this.entityId,
    this.payeeMap = const {},
    this.envelopeMap = const {},
    this.accountMap = const {},
    this.selectionMode = false,
    this.selectedIds = const {},
    this.onToggleSelection,
  });

  final List<Transaction> transactions;
  final Set<String> childParentIds;
  final String entityId;
  final Map<String, String> payeeMap;
  final Map<String, String> envelopeMap;
  final Map<String, String> accountMap;
  final bool selectionMode;
  final Set<String> selectedIds;
  final ValueChanged<String>? onToggleSelection;

  @override
  Widget build(BuildContext context) {
    final groups = useMemoized(() {
      final map = <String, List<Transaction>>{};
      for (final tx in transactions) {
        final key = _dateKey(tx.transactionDate);
        (map[key] ??= []).add(tx);
      }
      return map;
    }, [transactions]);

    final dateKeys = groups.keys.toList();
    final items = <_ListItem>[];

    for (final key in dateKeys) {
      final txList = groups[key]!;
      items.add(_ListItem.header(date: txList.first.transactionDate));
      for (final tx in txList) {
        items.add(_ListItem.transaction(transaction: tx));
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item.isHeader) {
          return _DateHeader(date: item.date!);
        }
        final tx = item.transaction!;
        final txId = tx.id?.toString() ?? '';
        final isSplit = childParentIds.contains(txId);
        final payeeName = tx.payeeId != null
            ? payeeMap[tx.payeeId.toString()]
            : null;
        final envelopeName = tx.envelopeId != null
            ? envelopeMap[tx.envelopeId.toString()]
            : null;
        final accountName = tx.accountId != null
            ? accountMap[tx.accountId.toString()]
            : null;
        return _TransactionTile(
          transaction: tx,
          entityId: entityId,
          isSplit: isSplit,
          payeeName: payeeName,
          envelopeName: envelopeName,
          accountName: accountName,
          selectionMode: selectionMode,
          isSelected: selectedIds.contains(txId),
          onToggleSelection: txId.isNotEmpty
              ? () => onToggleSelection?.call(txId)
              : null,
        );
      },
    );
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _ListItem {
  _ListItem.header({required this.date}) : isHeader = true, transaction = null;

  _ListItem.transaction({required this.transaction})
    : isHeader = false,
      date = null;

  final bool isHeader;
  final DateTime? date;
  final Transaction? transaction;
}

class _DateHeader extends HookWidget {
  const _DateHeader({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    final label = switch (difference) {
      0 => l10n.transactionDateToday,
      1 => l10n.transactionDateYesterday,
      _ => _formatFullDate(date, l10n),
    };

    return ObSectionHeader(
      title: label,
      padding: const EdgeInsets.only(
        top: SpacingTokens.md,
        bottom: SpacingTokens.xs,
      ),
    );
  }

  String _formatFullDate(DateTime date, AppLocalizations l10n) {
    final monthNames = [
      l10n.budgetMonthJanuary,
      l10n.budgetMonthFebruary,
      l10n.budgetMonthMarch,
      l10n.budgetMonthApril,
      l10n.budgetMonthMay,
      l10n.budgetMonthJune,
      l10n.budgetMonthJuly,
      l10n.budgetMonthAugust,
      l10n.budgetMonthSeptember,
      l10n.budgetMonthOctober,
      l10n.budgetMonthNovember,
      l10n.budgetMonthDecember,
    ];
    return '${monthNames[date.month - 1]} ${date.day}, ${date.year}';
  }
}
