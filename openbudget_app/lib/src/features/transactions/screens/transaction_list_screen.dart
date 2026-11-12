import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/widgets/add_transaction_sheet.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_pages_provider.dart';
import 'package:openbudget_app/src/features/transactions/screens/edit_transaction_dialog.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum TransactionTypeFilter { all, income, expense }

enum TransactionStatusFilter { all, cleared, uncleared, reconciled }

enum TransactionSort { dateDesc, dateAsc, amountDesc, amountAsc, description }

/// The key on the empty state shown when the ledger has no rows to draw.
const transactionListEmptyKey = Key('transaction-list-empty');

/// The transaction list: pages `transaction.list(TransactionQuery)` with
/// server-side search, status and date filters, and client-side type and
/// flag filters over the loaded pages. Rows show the account's currency,
/// plus the base amount when the server converted.
class TransactionListScreen extends HookConsumerWidget {
  const TransactionListScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final pagesAsync = ref.watch(transactionPagesProvider(entityId));
    final theme = Theme.of(context);

    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final typeFilter = useState(TransactionTypeFilter.all);
    final dateRangeStart = useState<DateTime?>(null);
    final dateRangeEnd = useState<DateTime?>(null);
    final sortOrder = useState(TransactionSort.dateDesc);
    final flagFilter = useState<TransactionFlag?>(null);
    final statusFilter = useState(TransactionStatusFilter.all);
    final selectionMode = useState(false);
    final selectedIds = useState(<String>{});
    final applyDebounce = useRef<Timer?>(null);

    useEffect(() {
      void listener() => searchQuery.value = searchController.text;
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    // Push search, status and dates to the server through TransactionQuery;
    // a change re-queries from the first page.
    Future<void> applyServerFilters({
      String? search,
      TransactionStatusFilter? status,
      DateTime? from,
      DateTime? to,
      bool clearDates = false,
    }) async {
      applyDebounce.value?.cancel();
      final completer = Completer<void>();
      applyDebounce.value = Timer(const Duration(milliseconds: 300), () {
        final current = ref.read(transactionPagesProvider(entityId)).value;
        final base = current?.filter ?? const TransactionFilter();
        unawaited(
          ref
              .read(transactionPagesProvider(entityId).notifier)
              .apply(
                base.copyWith(
                  search: search,
                  status: switch (status ?? statusFilter.value) {
                    TransactionStatusFilter.cleared =>
                      TransactionStatus.cleared,
                    TransactionStatusFilter.uncleared =>
                      TransactionStatus.uncleared,
                    TransactionStatusFilter.reconciled =>
                      TransactionStatus.reconciled,
                    TransactionStatusFilter.all => null,
                  },
                  fromDate: clearDates ? null : from,
                  toDate: clearDates ? null : to,
                  clearDates: clearDates,
                ),
              )
              .whenComplete(completer.complete),
        );
      });
      return completer.future;
    }

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
                        pagesAsync.whenOrNull(
                          data: (page) => page.items
                              .map(
                                (view) => view.transaction.id?.toString() ?? '',
                              )
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
                pagesAsync.whenOrNull(
                      data: (page) => page.items.isNotEmpty
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
                                  onPressed: () =>
                                      _exportToCsv(context, page.items),
                                ),
                              ],
                            )
                          : null,
                    ) ??
                    const SizedBox.shrink(),
              ],
            ),
      body: pagesAsync.when(
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
                    ref.invalidate(transactionPagesProvider(entityId)),
              ),
            ),
          ),
        ),
        data: (pageState) {
          final transactions = pageState.items;

          // Build payee, envelope, and account name lookup maps.
          final payeeAsync = ref.watch(payeeListProvider(entityId));
          final groupsAsync = ref.watch(budgetMonthGroupsProvider(entityId));
          final accountsAsync = ref.watch(accountListProvider(entityId));
          final payeeMap = <String, String>{};
          if (payeeAsync.hasValue) {
            for (final payee in payeeAsync.value!) {
              final id = payee.id?.toString();
              if (id != null) payeeMap[id] = payee.name;
            }
          }
          final envelopeMap = <String, String>{};
          if (groupsAsync.hasValue) {
            for (final group in groupsAsync.value!) {
              for (final envelopeView in group.envelopes) {
                final id = envelopeView.envelope.id?.toString();
                if (id != null) envelopeMap[id] = envelopeView.envelope.name;
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

          final sorted = List.of(transactions)
            ..sort(
              (a, b) => switch (sortOrder.value) {
                TransactionSort.dateDesc => b.transaction.date.compareTo(
                  a.transaction.date,
                ),
                TransactionSort.dateAsc => a.transaction.date.compareTo(
                  b.transaction.date,
                ),
                TransactionSort.amountDesc =>
                  b.transaction.amountMinor.abs().compareTo(
                    a.transaction.amountMinor.abs(),
                  ),
                TransactionSort.amountAsc =>
                  a.transaction.amountMinor.abs().compareTo(
                    b.transaction.amountMinor.abs(),
                  ),
                TransactionSort.description =>
                  a.transaction.description.toLowerCase().compareTo(
                    b.transaction.description.toLowerCase(),
                  ),
              },
            );

          final query = searchQuery.value.toLowerCase();
          final filtered = sorted.where((view) {
            final tx = view.transaction;
            if (typeFilter.value == TransactionTypeFilter.income &&
                tx.amountMinor <= 0) {
              return false;
            }
            if (typeFilter.value == TransactionTypeFilter.expense &&
                tx.amountMinor >= 0) {
              return false;
            }
            if (flagFilter.value != null && tx.flag != flagFilter.value) {
              return false;
            }
            if (statusFilter.value == TransactionStatusFilter.cleared &&
                tx.status != TransactionStatus.cleared) {
              return false;
            }
            if (statusFilter.value == TransactionStatusFilter.uncleared &&
                tx.status != TransactionStatus.uncleared) {
              return false;
            }
            if (statusFilter.value == TransactionStatusFilter.reconciled &&
                tx.status != TransactionStatus.reconciled) {
              return false;
            }
            if (query.isNotEmpty &&
                !tx.description.toLowerCase().contains(query) &&
                !(tx.memo?.toLowerCase().contains(query) ?? false)) {
              return false;
            }
            if (dateRangeStart.value != null) {
              final txDate = DateTime(
                tx.date.year,
                tx.date.month,
                tx.date.day,
              );
              if (txDate.isBefore(dateRangeStart.value!)) return false;
            }
            if (dateRangeEnd.value != null) {
              final txDate = DateTime(
                tx.date.year,
                tx.date.month,
                tx.date.day,
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
                  onChanged: (value) =>
                      unawaited(applyServerFilters(search: value)),
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
                            selected:
                                typeFilter.value == TransactionTypeFilter.all,
                            onSelected: () =>
                                typeFilter.value = TransactionTypeFilter.all,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          _FilterChip(
                            label: l10n.transactionFilterIncome,
                            icon: OpenBudgetIcons.inflow,
                            selected:
                                typeFilter.value ==
                                TransactionTypeFilter.income,
                            onSelected: () =>
                                typeFilter.value = TransactionTypeFilter.income,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          _FilterChip(
                            label: l10n.transactionFilterExpense,
                            icon: OpenBudgetIcons.outflow,
                            selected:
                                typeFilter.value ==
                                TransactionTypeFilter.expense,
                            onSelected: () => typeFilter.value =
                                TransactionTypeFilter.expense,
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
                                unawaited(
                                  applyServerFilters(clearDates: true),
                                );
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
                            onSelected: (v) {
                              statusFilter.value = v;
                              unawaited(applyServerFilters(status: v));
                            },
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
                        ref.invalidate(transactionPagesProvider(entityId)),
                    child: _GroupedTransactionList(
                      transactions: filtered,
                      entityId: entityId,
                      baseCurrencyCode: ref
                          .watch(budgetMonthProvider(entityId))
                          .value
                          ?.currencyCode,
                      payeeMap: payeeMap,
                      envelopeMap: envelopeMap,
                      accountMap: accountMap,
                      hasMore: pageState.hasMore,
                      isLoadingMore: pageState.isLoadingMore,
                      onLoadMore: () => ref
                          .read(transactionPagesProvider(entityId).notifier)
                          .loadMore(),
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
              context.goNamed(
                addIncomeRoute,
                pathParameters: {'entityId': entityId},
              );
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
                          pagesAsync,
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
    final groupsAsync = ref.read(budgetMonthGroupsProvider(entityId));
    if (!groupsAsync.hasValue) return;

    final envelopeItems = <(String, String)>[];
    for (final group in groupsAsync.value!) {
      for (final envelopeView in group.envelopes) {
        final id = envelopeView.envelope.id?.toString() ?? '';
        if (id.isNotEmpty) {
          envelopeItems.add(
            (id, '${group.category.name} / ${envelopeView.envelope.name}'),
          );
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
      final actions = ref.read(transactionActionsProvider.notifier);
      final views =
          ref.read(transactionPagesProvider(entityId)).value?.items.where((
            view,
          ) {
            final id = view.transaction.id?.toString() ?? '';
            return id.isNotEmpty && ids.contains(id);
          }).toList() ??
          const <TransactionView>[];
      for (final view in views) {
        await actions.update(
          transactionId: view.transaction.id?.toString() ?? '',
          entityId: entityId,
          input: transactionInputWithEnvelope(view, selectedEnvelope),
        );
      }
      selectionMode.value = false;
      selectedIds.value = {};
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.bulkAssignSuccess(views.length),
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
                            flag: value,
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
    TransactionFlag? flag,
  }) async {
    final l10n = AppLocalizations.of(context);
    try {
      final count = await ref
          .read(transactionActionsProvider.notifier)
          .setFlag(
            transactionIds: ids.toList(),
            entityId: entityId,
            flag: flag,
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
    AsyncValue<TransactionPageState> pagesAsync,
    Set<String> ids,
    ValueNotifier<bool> selectionMode,
    ValueNotifier<Set<String>> selectedIds,
  ) async {
    final l10n = AppLocalizations.of(context);

    // Only touch uncleared, non-reconciled transactions; when everything
    // selected is already cleared, send them back to uncleared.
    final byId = <String, TransactionStatus>{
      for (final view in pagesAsync.value?.items ?? const <TransactionView>[])
        if (view.transaction.id != null)
          view.transaction.id!.toString(): view.transaction.status,
    };
    final targetIds = <String>[];
    var anyCleared = false;
    for (final id in ids) {
      final status = byId[id];
      if (status == null || status == TransactionStatus.reconciled) continue;
      if (status == TransactionStatus.cleared) anyCleared = true;
      targetIds.add(id);
    }
    if (targetIds.isEmpty) return;
    final nextStatus = anyCleared
        ? TransactionStatus.uncleared
        : TransactionStatus.cleared;

    try {
      final count = await ref
          .read(transactionActionsProvider.notifier)
          .setStatus(
            transactionIds: targetIds,
            status: nextStatus,
            entityId: entityId,
          );
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
      await ref
          .read(transactionActionsProvider.notifier)
          .bulkDelete(transactionIds: ids.toList(), entityId: entityId);
      selectionMode.value = false;
      selectedIds.value = {};
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.bulkDeleteSuccess(ids.length),
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

  void _exportToCsv(BuildContext context, List<TransactionView> views) {
    final l10n = AppLocalizations.of(context);
    final buffer = StringBuffer()
      ..writeln('Date,Description,Amount,Memo,Status');

    final sorted = List.of(views)
      ..sort(
        (a, b) => b.transaction.date.compareTo(a.transaction.date),
      );

    for (final view in sorted) {
      final tx = view.transaction;
      final date = _formatDateIso(tx.date);
      final desc = _escapeCsv(view.payeeName ?? tx.description);
      final amount = formatMinorForCode(
        tx.amountMinor,
        view.accountCurrencyCode,
      );
      final memo = _escapeCsv(tx.memo ?? '');
      final status = switch (tx.status) {
        TransactionStatus.reconciled => 'Reconciled',
        TransactionStatus.cleared => 'Cleared',
        TransactionStatus.uncleared => 'Uncleared',
      };
      buffer.writeln('$date,$desc,$amount,$memo,$status');
    }

    unawaited(Clipboard.setData(ClipboardData(text: buffer.toString())));
    showAppToast(
      context,
      message: l10n.transactionExportSuccess(sorted.length),
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
    List<TransactionView> views,
  ) async {
    final now = DateTime.now();
    final earliest = views.isNotEmpty
        ? views
              .map((view) => view.transaction.date)
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

List<(TransactionFlag, String, ObTone)> _flagOptions(AppLocalizations l10n) => [
  (TransactionFlag.red, l10n.transactionFlagRed, ObTone.overspent),
  (TransactionFlag.orange, l10n.transactionFlagOrange, ObTone.underfunded),
  (TransactionFlag.yellow, l10n.transactionFlagYellow, ObTone.underfunded),
  (TransactionFlag.green, l10n.transactionFlagGreen, ObTone.funded),
  (TransactionFlag.blue, l10n.transactionFlagBlue, ObTone.brand),
  (TransactionFlag.purple, l10n.transactionFlagPurple, ObTone.review),
];

String? _flagLabel(TransactionFlag? flag, AppLocalizations l10n) =>
    switch (flag) {
      TransactionFlag.red => l10n.transactionFlagRed,
      TransactionFlag.orange => l10n.transactionFlagOrange,
      TransactionFlag.yellow => l10n.transactionFlagYellow,
      TransactionFlag.green => l10n.transactionFlagGreen,
      TransactionFlag.blue => l10n.transactionFlagBlue,
      TransactionFlag.purple => l10n.transactionFlagPurple,
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

  final TransactionFlag? selectedFlag;
  final ValueChanged<TransactionFlag?> onSelected;

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

ObTone? _flagToneFromString(TransactionFlag? flag) => switch (flag) {
  TransactionFlag.red => ObTone.overspent,
  TransactionFlag.orange => ObTone.underfunded,
  TransactionFlag.yellow => ObTone.underfunded,
  TransactionFlag.green => ObTone.funded,
  TransactionFlag.blue => ObTone.brand,
  TransactionFlag.purple => ObTone.review,
  _ => null,
};

class _TransactionTile extends HookConsumerWidget {
  const _TransactionTile({
    required this.view,
    required this.entityId,
    this.payeeName,
    this.envelopeName,
    this.accountName,
    this.baseCurrencyCode,
    this.selectionMode = false,
    this.isSelected = false,
    this.onToggleSelection,
  });

  final TransactionView view;
  final String entityId;
  final String? payeeName;
  final String? envelopeName;
  final String? accountName;

  /// The entity's base currency; shown as a converted line when it differs
  /// from the account's. The conversion itself came from the server.
  final String? baseCurrencyCode;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback? onToggleSelection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final transaction = view.transaction;
    final isIncome = transaction.amountMinor > 0;
    final tone = isIncome ? ObTone.funded : ObTone.neutral;

    final statusIcon = switch (transaction.status) {
      TransactionStatus.reconciled => OpenBudgetIcons.lock,
      TransactionStatus.cleared => OpenBudgetIcons.checkCircle,
      TransactionStatus.uncleared => OpenBudgetIcons.circle,
    };
    final statusColor = switch (transaction.status) {
      TransactionStatus.reconciled => palette.brand,
      TransactionStatus.cleared => palette.funded,
      TransactionStatus.uncleared => palette.mutedInk,
    };
    final statusTone = switch (transaction.status) {
      TransactionStatus.reconciled => ObTone.brand,
      TransactionStatus.cleared => ObTone.funded,
      TransactionStatus.uncleared => ObTone.neutral,
    };
    final statusLabel = switch (transaction.status) {
      TransactionStatus.reconciled => l10n.transactionReconciled,
      TransactionStatus.cleared => l10n.transactionCleared,
      TransactionStatus.uncleared => l10n.transactionUncleared,
    };

    final flagTone = _flagToneFromString(transaction.flag);
    final flagLabel = _flagLabel(transaction.flag, l10n);
    final showConverted =
        baseCurrencyCode != null &&
        baseCurrencyCode!.isNotEmpty &&
        baseCurrencyCode != view.accountCurrencyCode;

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
                    onTap: transaction.status == TransactionStatus.reconciled
                        ? null
                        : () => _toggleStatus(context, ref, l10n),
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
                      view.payeeName ?? transaction.description,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ObAmount(
                      formatMinorForCode(
                        transaction.amountMinor,
                        view.accountCurrencyCode,
                      ),
                      tone: tone,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (showConverted)
                      Text(
                        l10n.transactionBaseEquivalent(
                          formatMinorForCode(
                            transaction.baseAmountMinor,
                            baseCurrencyCode!,
                          ),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.mutedInk,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
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
    final hasMemo =
        view.transaction.memo != null && view.transaction.memo!.isNotEmpty;
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
            view.transaction.memo!,
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

  Future<void> _toggleStatus(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final transaction = view.transaction;
    final nextStatus = transaction.status == TransactionStatus.cleared
        ? TransactionStatus.uncleared
        : TransactionStatus.cleared;
    try {
      await ref
          .read(transactionActionsProvider.notifier)
          .setStatus(
            transactionIds: [transaction.id?.toString() ?? ''],
            status: nextStatus,
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
          '${l10n.deleteConfirmMessage}\n\n"${view.transaction.description}"',
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
      await ref
          .read(transactionActionsProvider.notifier)
          .delete(
            transactionId: view.transaction.id?.toString() ?? '',
            entityId: entityId,
          );
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.deleteSuccess,
          variant: AppToastVariant.success,
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
                      selected: view.transaction.flag == value,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        unawaited(
                          _setFlag(context, ref, l10n, flag: value),
                        );
                      },
                    ),
                ],
              ),
              if (view.transaction.flag != null) ...[
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
    TransactionFlag? flag,
  }) async {
    try {
      await ref
          .read(transactionActionsProvider.notifier)
          .setFlag(
            transactionIds: [view.transaction.id?.toString() ?? ''],
            entityId: entityId,
            flag: flag,
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
          view: view,
          entityId: entityId,
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
    required this.entityId,
    this.baseCurrencyCode,
    this.payeeMap = const {},
    this.envelopeMap = const {},
    this.accountMap = const {},
    this.hasMore = false,
    this.isLoadingMore = false,
    this.onLoadMore,
    this.selectionMode = false,
    this.selectedIds = const {},
    this.onToggleSelection,
  });

  final List<TransactionView> transactions;
  final String entityId;

  /// The entity's base currency, for the converted line on foreign rows.
  final String? baseCurrencyCode;
  final Map<String, String> payeeMap;
  final Map<String, String> envelopeMap;
  final Map<String, String> accountMap;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback? onLoadMore;
  final bool selectionMode;
  final Set<String> selectedIds;
  final ValueChanged<String>? onToggleSelection;

  @override
  Widget build(BuildContext context) {
    final groups = useMemoized(() {
      final map = <String, List<TransactionView>>{};
      for (final view in transactions) {
        final key = _dateKey(view.transaction.date);
        (map[key] ??= []).add(view);
      }
      return map;
    }, [transactions]);

    final dateKeys = groups.keys.toList();
    final items = <_ListItem>[];

    for (final key in dateKeys) {
      final viewList = groups[key]!;
      items.add(_ListItem.header(date: viewList.first.transaction.date));
      for (final view in viewList) {
        items.add(_ListItem.transaction(view: view));
      }
    }
    if (hasMore) {
      items.add(_ListItem.loadMore());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item.isHeader) {
          return _DateHeader(date: item.date!);
        }
        if (item.isLoadMore) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
            child: Center(
              child: OutlinedButton(
                onPressed: isLoadingMore ? null : onLoadMore,
                child: Text(
                  AppLocalizations.of(context).loadMoreButton,
                ),
              ),
            ),
          );
        }
        final view = item.view!;
        final tx = view.transaction;
        final txId = tx.id?.toString() ?? '';
        final payeeName =
            view.payeeName ??
            (tx.payeeId != null ? payeeMap[tx.payeeId.toString()] : null);
        final lineEnvelopeId = view.lines
            .map((line) => line.envelopeId?.toString())
            .firstWhere(
              (id) => id != null && id.isNotEmpty,
              orElse: () => null,
            );
        final envelopeName = lineEnvelopeId != null
            ? envelopeMap[lineEnvelopeId]
            : null;
        final accountName = accountMap[tx.accountId.toString()];
        return _TransactionTile(
          view: view,
          entityId: entityId,
          payeeName: payeeName,
          envelopeName: envelopeName,
          accountName: accountName,
          baseCurrencyCode: baseCurrencyCode,
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
  _ListItem.header({required this.date})
    : isHeader = true,
      view = null,
      isLoadMore = false;

  _ListItem.transaction({required this.view})
    : isHeader = false,
      date = null,
      isLoadMore = false;

  _ListItem.loadMore()
    : isHeader = false,
      date = null,
      view = null,
      isLoadMore = true;

  final bool isHeader;
  final bool isLoadMore;
  final DateTime? date;
  final TransactionView? view;
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
