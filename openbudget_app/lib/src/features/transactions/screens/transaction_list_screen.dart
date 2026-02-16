import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/features/transactions/screens/edit_transaction_dialog.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum TransactionFilter { all, income, expense }

class TransactionListScreen extends HookConsumerWidget {
  const TransactionListScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transactionsAsync = ref.watch(transactionListProvider(budgetId));
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final searchController = useTextEditingController();
    final searchQuery = useState('');
    final filter = useState(TransactionFilter.all);
    final dateRangeStart = useState<DateTime?>(null);
    final dateRangeEnd = useState<DateTime?>(null);
    final selectionMode = useState(false);
    final selectedIds = useState(<String>{});

    useEffect(() {
      void listener() => searchQuery.value = searchController.text;
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    final currency =
        budgetAsync.whenOrNull(
          data: (budget) => CurrencyCode.values.firstWhere(
            (c) => c.code == budget.currencyCode,
            orElse: () => CurrencyCode.usd,
          ),
        ) ??
        CurrencyCode.usd;

    return Scaffold(
      appBar: selectionMode.value
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  selectionMode.value = false;
                  selectedIds.value = {};
                },
              ),
              title: Text(l10n.bulkSelectedCount(selectedIds.value.length)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.select_all_rounded),
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
                  icon: const Icon(Icons.deselect_rounded),
                  tooltip: l10n.bulkDeselectAll,
                  onPressed: () => selectedIds.value = {},
                ),
              ],
            )
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/budgets/$budgetId'),
              ),
              title: Text(l10n.transactionListTitle),
              actions: [
                transactionsAsync.whenOrNull(
                      data: (txs) => txs.isNotEmpty
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.checklist_rounded),
                                  tooltip: l10n.bulkAssignEnvelope,
                                  onPressed: () => selectionMode.value = true,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded),
                                  tooltip: l10n.transactionExportCsv,
                                  onPressed: () =>
                                      _exportToCsv(context, txs, currency),
                                ),
                              ],
                            )
                          : null,
                    ) ??
                    const SizedBox.shrink(),
              ],
            ),
      body: transactionsAsync.when(
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
                l10n.transactionLoadError,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        data: (transactions) {
          // Filter out child split transactions (they have parentTransactionId).
          final childParentIds = transactions
              .where((tx) => tx.parentTransactionId != null)
              .map((tx) => tx.parentTransactionId.toString())
              .toSet();
          final topLevel = transactions
              .where((tx) => tx.parentTransactionId == null)
              .toList();
          final sorted = List.of(topLevel)
            ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

          final query = searchQuery.value.toLowerCase();
          final filtered = sorted.where((tx) {
            if (filter.value == TransactionFilter.income &&
                tx.amountCents <= 0) {
              return false;
            }
            if (filter.value == TransactionFilter.expense &&
                tx.amountCents >= 0) {
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
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: l10n.transactionSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              searchController.clear();
                              searchQuery.value = '';
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(RadiusTokens.md),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.sm,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.sm,
                ),
                child: Row(
                  children: [
                    _FilterChip(
                      label: l10n.transactionFilterAll,
                      selected: filter.value == TransactionFilter.all,
                      onSelected: () => filter.value = TransactionFilter.all,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    _FilterChip(
                      label: l10n.transactionFilterIncome,
                      selected: filter.value == TransactionFilter.income,
                      onSelected: () => filter.value = TransactionFilter.income,
                      color: ColorTokens.secondary,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    _FilterChip(
                      label: l10n.transactionFilterExpense,
                      selected: filter.value == TransactionFilter.expense,
                      onSelected: () =>
                          filter.value = TransactionFilter.expense,
                      color: ColorTokens.error,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    _FilterChip(
                      label: dateRangeStart.value != null
                          ? _formatShortDate(dateRangeStart.value!)
                          : l10n.transactionDateRangeFilter,
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
                        icon: const Icon(Icons.clear, size: 16),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                        tooltip: l10n.transactionDateRangeClear,
                        onPressed: () {
                          dateRangeStart.value = null;
                          dateRangeEnd.value = null;
                        },
                      ),
                    const Spacer(),
                    Text(
                      l10n.transactionResultCount(filtered.length),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (filtered.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 48,
                          color: colorScheme.outlineVariant,
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        Text(
                          transactions.isEmpty
                              ? l10n.transactionEmpty
                              : l10n.transactionNoResults,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        ref.invalidate(transactionListProvider(budgetId)),
                    child: _GroupedTransactionList(
                      transactions: filtered,
                      childParentIds: childParentIds,
                      budgetId: budgetId,
                      currencyCode: currency,
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
      bottomNavigationBar: selectionMode.value && selectedIds.value.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: FilledButton.icon(
                  onPressed: () => _showEnvelopePicker(
                    context,
                    ref,
                    selectedIds.value,
                    selectionMode,
                    selectedIds,
                  ),
                  icon: const Icon(Icons.mail_outlined),
                  label: Text(l10n.bulkAssignEnvelope),
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
    final summaryAsync = ref.read(budgetSummaryProvider(budgetId));
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
                    leading: const Icon(Icons.mail_outlined),
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

    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    try {
      final count = await ref
          .read(transactionActionsProvider.notifier)
          .bulkAssignEnvelope(
            transactionIds: ids.toList(),
            envelopeId: selectedEnvelope,
            budgetId: budgetId,
          );
      selectionMode.value = false;
      selectedIds.value = {};
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.bulkAssignSuccess(count))),
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.bulkAssignError),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  void _exportToCsv(
    BuildContext context,
    List<Transaction> transactions,
    CurrencyCode currency,
  ) {
    final l10n = AppLocalizations.of(context);
    final buffer = StringBuffer()
      ..writeln('Date,Description,Amount,Memo,Status');

    final topLevel =
        transactions.where((tx) => tx.parentTransactionId == null).toList()
          ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    for (final tx in topLevel) {
      final date = _formatDateIso(tx.transactionDate);
      final desc = _escapeCsv(tx.description);
      final amount = formatCents(tx.amountCents, currency);
      final memo = _escapeCsv(tx.memo ?? '');
      final status = tx.reconciled
          ? 'Reconciled'
          : tx.cleared
          ? 'Cleared'
          : 'Uncleared';
      buffer.writeln('$date,$desc,$amount,$memo,$status');
    }

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.transactionExportSuccess(topLevel.length))),
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
}

class _FilterChip extends HookWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.primary;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: chipColor.withAlpha(30),
      checkmarkColor: chipColor,
      labelStyle: TextStyle(
        color: selected ? chipColor : theme.colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }
}

Color? _flagColorFromString(String? flagColor) {
  return switch (flagColor) {
    'red' => Colors.red,
    'orange' => Colors.orange,
    'yellow' => Colors.amber,
    'green' => Colors.green,
    'blue' => Colors.blue,
    'purple' => Colors.purple,
    _ => null,
  };
}

class _TransactionTile extends HookConsumerWidget {
  const _TransactionTile({
    required this.transaction,
    required this.budgetId,
    required this.currencyCode,
    this.isSplit = false,
    this.selectionMode = false,
    this.isSelected = false,
    this.onToggleSelection,
  });

  final Transaction transaction;
  final String budgetId;
  final CurrencyCode currencyCode;
  final bool isSplit;
  final bool selectionMode;
  final bool isSelected;
  final VoidCallback? onToggleSelection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isIncome = transaction.amountCents > 0;
    final color = isIncome ? ColorTokens.secondary : ColorTokens.error;
    final icon = isIncome
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    final statusIcon = transaction.reconciled
        ? Icons.lock_outline_rounded
        : transaction.cleared
        ? Icons.check_circle_outline
        : Icons.circle_outlined;
    final statusColor = transaction.reconciled
        ? colorScheme.primary
        : transaction.cleared
        ? ColorTokens.secondary
        : colorScheme.outline;
    final statusTooltip = transaction.reconciled
        ? l10n.transactionReconciled
        : transaction.cleared
        ? l10n.transactionCleared
        : l10n.transactionUncleared;

    final flagColor = _flagColorFromString(transaction.flagColor);

    final card = Card(
      margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
      color: isSelected ? colorScheme.primaryContainer.withAlpha(80) : null,
      child: ListTile(
        onTap: selectionMode
            ? onToggleSelection
            : () => _showEditDialog(context),
        onLongPress: selectionMode
            ? null
            : () => _showFlagMenu(context, ref, l10n),
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selectionMode)
              Checkbox(
                value: isSelected,
                onChanged: (_) => onToggleSelection?.call(),
              )
            else ...[
              if (flagColor != null)
                Container(
                  width: 4,
                  height: 36,
                  margin: const EdgeInsets.only(right: SpacingTokens.xs),
                  decoration: BoxDecoration(
                    color: flagColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              Tooltip(
                message: statusTooltip,
                child: InkWell(
                  borderRadius: BorderRadius.circular(RadiusTokens.xl),
                  onTap: transaction.reconciled
                      ? null
                      : () => _toggleCleared(context, ref, l10n),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(statusIcon, size: 20, color: statusColor),
                  ),
                ),
              ),
            ],
            const SizedBox(width: SpacingTokens.xs),
            CircleAvatar(
              backgroundColor: color.withAlpha(25),
              child: Icon(icon, color: color, size: 20),
            ),
          ],
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                transaction.description,
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isSplit) ...[
              const SizedBox(width: SpacingTokens.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  l10n.splitLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: transaction.memo != null && transaction.memo!.isNotEmpty
            ? Text(
                transaction.memo!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Text(
          formatCents(transaction.amountCents, currencyCode),
          style: theme.textTheme.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
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
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
        child: Icon(Icons.delete_rounded, color: colorScheme.onError),
      ),
      confirmDismiss: (_) => _confirmDelete(context, l10n, colorScheme),
      onDismissed: (_) => _deleteTransaction(context, ref, l10n, colorScheme),
      child: card,
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
            budgetId: budgetId,
          );
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.transactionEditError)));
      }
    }
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(
          '${l10n.deleteConfirmMessage}\n\n"${transaction.description}"',
        ),
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
    ColorScheme colorScheme,
  ) async {
    try {
      final deleted = await ref
          .read(transactionActionsProvider.notifier)
          .deleteTransaction(
            transactionId: transaction.id?.toString() ?? '',
            budgetId: budgetId,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deleteSuccess),
            action: SnackBarAction(
              label: l10n.undoAction,
              onPressed: () => _undoDelete(context, ref, deleted, l10n),
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deleteError),
            backgroundColor: colorScheme.error,
          ),
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
            budgetId: budgetId,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.undoDeleteSuccess)));
      }
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.undoDeleteError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showFlagMenu(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    final flags = <(String, String, Color)>[
      ('red', l10n.transactionFlagRed, Colors.red),
      ('orange', l10n.transactionFlagOrange, Colors.orange),
      ('yellow', l10n.transactionFlagYellow, Colors.amber),
      ('green', l10n.transactionFlagGreen, Colors.green),
      ('blue', l10n.transactionFlagBlue, Colors.blue),
      ('purple', l10n.transactionFlagPurple, Colors.purple),
    ];

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
                for (final (value, label, color) in flags)
                  _FlagChip(
                    label: label,
                    color: color,
                    selected: transaction.flagColor == value,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _setFlag(context, ref, l10n, flagColor: value);
                    },
                  ),
              ],
            ),
            if (transaction.flagColor != null) ...[
              const Divider(),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: Text(l10n.transactionFlagClear),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _setFlag(context, ref, l10n);
                },
              ),
            ],
            const SizedBox(height: SpacingTokens.sm),
          ],
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
            budgetId: budgetId,
            flagColor: flagColor,
          );
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.transactionEditError)));
      }
    }
  }

  void _showEditDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => EditTransactionDialog(
        transaction: transaction,
        budgetId: budgetId,
        currencyCode: currencyCode,
      ),
    );
  }
}

class _FlagChip extends HookWidget {
  const _FlagChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(
        selected ? Icons.flag_rounded : Icons.flag_outlined,
        color: color,
        size: 18,
      ),
      label: Text(label),
      side: selected ? BorderSide(color: color, width: 2) : null,
      onPressed: onTap,
    );
  }
}

class _GroupedTransactionList extends HookWidget {
  const _GroupedTransactionList({
    required this.transactions,
    required this.childParentIds,
    required this.budgetId,
    required this.currencyCode,
    this.selectionMode = false,
    this.selectedIds = const {},
    this.onToggleSelection,
  });

  final List<Transaction> transactions;
  final Set<String> childParentIds;
  final String budgetId;
  final CurrencyCode currencyCode;
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
        return _TransactionTile(
          transaction: tx,
          budgetId: budgetId,
          currencyCode: currencyCode,
          isSplit: isSplit,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    final label = switch (difference) {
      0 => l10n.transactionDateToday,
      1 => l10n.transactionDateYesterday,
      _ => _formatFullDate(date, l10n),
    };

    return Padding(
      padding: const EdgeInsets.only(
        top: SpacingTokens.md,
        bottom: SpacingTokens.xs,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
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
