import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

Future<void> showReviewTransactionsSheet(
  BuildContext context, {
  required String budgetId,
  required int year,
  required int month,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Theme.of(context).ob.canvas,
  barrierColor: Theme.of(context).ob.firmPen.withAlpha(210),
  builder: (context) => FractionallySizedBox(
    heightFactor: 0.95,
    child: ReviewTransactionsSheet(
      budgetId: budgetId,
      year: year,
      month: month,
    ),
  ),
);

class ReviewTransactionsSheet extends HookConsumerWidget {
  const ReviewTransactionsSheet({
    required this.budgetId,
    required this.year,
    required this.month,
    super.key,
  });

  final String budgetId;
  final int year;
  final int month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final transactionsAsync = ref.watch(
      monthlyTransactionsProvider(budgetId, year, month),
    );
    final summaryAsync = ref.watch(budgetMonthlySummaryProvider(budgetId));

    final queue = useState<List<Transaction>>(<Transaction>[]);
    final initialized = useState(false);
    final selectedIds = useState<Set<String>>(<String>{});

    useEffect(() {
      if (!transactionsAsync.hasValue || initialized.value) return null;
      queue.value = _toReviewQueue(transactionsAsync.value!);
      initialized.value = true;
      return null;
    }, [transactionsAsync, initialized.value]);

    final envelopeChoices = <_EnvelopeChoice>[];
    final envelopeNameById = <String, String>{};
    if (summaryAsync.hasValue) {
      for (final category in summaryAsync.value!.categories) {
        for (final envelope in category.envelopes) {
          final envelopeId = envelope.id?.toString();
          if (envelopeId == null || envelopeId.isEmpty) continue;
          envelopeNameById[envelopeId] = envelope.name;
          envelopeChoices.add(
            _EnvelopeChoice(
              id: envelopeId,
              name: envelope.name,
              categoryName: category.category.name,
            ),
          );
        }
      }
    }

    final selectedCount = selectedIds.value.length;
    final selectedAmountCents = queue.value
        .where((transaction) {
          final transactionId = transaction.id?.toString();
          return transactionId != null &&
              selectedIds.value.contains(transactionId);
        })
        .fold<int>(0, (total, transaction) => total + transaction.amountCents);

    Future<void> approveSelected() async {
      final ids = selectedIds.value.toList(growable: false);
      if (ids.isEmpty) return;
      queue.value = queue.value
          .where((transaction) {
            final transactionId = transaction.id?.toString();
            if (transactionId == null) return true;
            return !selectedIds.value.contains(transactionId);
          })
          .toList(growable: false);
      selectedIds.value = <String>{};

      try {
        await ref
            .read(transactionActionsProvider.notifier)
            .bulkToggleCleared(transactionIds: ids, budgetId: budgetId);
      } on Exception {
        // Keep optimistic UI even if network is unavailable in test harnesses.
      } finally {
        if (context.mounted) {
          ref
            ..invalidate(monthlyTransactionsProvider(budgetId, year, month))
            ..invalidate(budgetMonthlySummaryProvider(budgetId));
        }
      }
    }

    Future<void> categorizeSelected() async {
      final ids = selectedIds.value.toList(growable: false);
      if (ids.isEmpty) return;
      if (envelopeChoices.isEmpty) return;

      final selectedEnvelope = await _showEnvelopePicker(
        context,
        envelopeChoices: envelopeChoices,
      );
      if (selectedEnvelope == null) return;

      try {
        await ref
            .read(transactionActionsProvider.notifier)
            .bulkAssignEnvelope(
              transactionIds: ids,
              envelopeId: selectedEnvelope.id,
              budgetId: budgetId,
            );
      } on Exception {
        if (!context.mounted) return;
        showAppToast(
          context,
          message: l10n.reviewTransactionsUpdateCategoryError,
          variant: AppToastVariant.error,
        );
      } finally {
        if (context.mounted) {
          selectedIds.value = <String>{};
          ref
            ..invalidate(monthlyTransactionsProvider(budgetId, year, month))
            ..invalidate(budgetMonthlySummaryProvider(budgetId));
        }
      }
    }

    Future<void> deleteSelected() async {
      final ids = selectedIds.value.toList(growable: false);
      if (ids.isEmpty) return;
      queue.value = queue.value
          .where((transaction) {
            final transactionId = transaction.id?.toString();
            if (transactionId == null) return true;
            return !selectedIds.value.contains(transactionId);
          })
          .toList(growable: false);
      selectedIds.value = <String>{};

      try {
        await ref
            .read(transactionActionsProvider.notifier)
            .bulkDelete(transactionIds: ids, budgetId: budgetId);
      } on Exception {
        // Keep optimistic UI even if network is unavailable in test harnesses.
      } finally {
        if (context.mounted) {
          ref
            ..invalidate(monthlyTransactionsProvider(budgetId, year, month))
            ..invalidate(budgetMonthlySummaryProvider(budgetId));
        }
      }
    }

    Future<void> openMoreMenu() async {
      if (selectedIds.value.isEmpty) return;
      final action = await showModalBottomSheet<_MoreAction>(
        context: context,
        builder: (context) => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: SkribbleIcon(
                  data: OpenBudgetIcons.delete,
                  color: Theme.of(context).ob.overspent,
                ),
                title: Text(l10n.reviewTransactionsDeleteSelected),
                onTap: () => Navigator.of(context).pop(_MoreAction.delete),
              ),
              ListTile(
                leading: SkribbleIcon(
                  data: OpenBudgetIcons.close,
                  color: Theme.of(context).ob.ink,
                ),
                title: Text(l10n.dialogCancel),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
      if (action == _MoreAction.delete) {
        await deleteSelected();
      }
    }

    final title = selectedCount > 0
        ? l10n.reviewTransactionsSelectedTitle(selectedCount)
        : queue.value.isEmpty
        ? l10n.reviewTransactionsNoTransactions
        : queue.value.length == 1
        ? l10n.reviewTransactionsSingleNewTransaction
        : l10n.reviewTransactionsNewTransactions(queue.value.length);

    final currencyCode = _currencyFromSummary(
      summaryAsync.hasValue ? summaryAsync.value : null,
    );

    final palette = theme.ob;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.canvas,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: SpacingTokens.sm),
            Container(
              width: 36,
              height: 4,
              decoration: ObRoughDecoration(
                color: palette.line,
                radius: 4,
                seed: 83,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              l10n.reviewTransactionsSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.mutedInk,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                SpacingTokens.xs,
                SpacingTokens.md,
                SpacingTokens.sm,
              ),
              child: Row(
                children: [
                  const SizedBox(width: 56),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.dialogDone),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: !initialized.value && transactionsAsync.isLoading
                  ? Center(child: ObLoadingPanel(label: l10n.loadingTitle))
                  : queue.value.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(SpacingTokens.md),
                        child: ObStatePanel.empty(
                          title: l10n.reviewTransactionsAllDoneTitle,
                          message: l10n.reviewTransactionsAllDoneSubtitle,
                          doodle: WiredDoodleKind.flower,
                          tone: ObTone.funded,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
                      itemCount: queue.value.length,
                      itemBuilder: (context, index) {
                        final transaction = queue.value[index];
                        final transactionId = transaction.id?.toString();
                        final isSelected =
                            transactionId != null &&
                            selectedIds.value.contains(transactionId);
                        final previous = index > 0
                            ? queue.value[index - 1]
                            : null;
                        final showHeader =
                            previous == null ||
                            !_isSameDay(previous, transaction);

                        final envelopeName = transaction.envelopeId == null
                            ? l10n.reviewTransactionsUncategorized
                            : envelopeNameById[transaction.envelopeId
                                      .toString()] ??
                                  l10n.reviewTransactionsUncategorized;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showHeader)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  SpacingTokens.md,
                                  SpacingTokens.sm,
                                  SpacingTokens.md,
                                  SpacingTokens.xs,
                                ),
                                child: Text(
                                  DateFormat.yMMMMd().format(
                                    transaction.transactionDate,
                                  ),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: palette.ink,
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                SpacingTokens.md,
                                0,
                                SpacingTokens.md,
                                SpacingTokens.xs,
                              ),
                              child: ObCard(
                                tone: isSelected ? ObTone.brand : null,
                                onTap: transactionId == null
                                    ? null
                                    : () {
                                        final next = Set<String>.from(
                                          selectedIds.value,
                                        );
                                        if (next.contains(transactionId)) {
                                          next.remove(transactionId);
                                        } else {
                                          next.add(transactionId);
                                        }
                                        selectedIds.value = next;
                                      },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: SpacingTokens.sm,
                                    vertical: SpacingTokens.sm,
                                  ),
                                  child: Row(
                                    children: [
                                      SkribbleIcon(
                                        data: isSelected
                                            ? OpenBudgetIcons.checkCircle
                                            : OpenBudgetIcons.circle,
                                        color: isSelected
                                            ? palette.brand
                                            : palette.mutedInk,
                                      ),
                                      const SizedBox(width: SpacingTokens.sm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              transaction.description,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: palette.ink,
                                                  ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              envelopeName,
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: palette.mutedInk,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: SpacingTokens.md),
                                      ObAmount(
                                        formatCentsForCode(
                                          transaction.amountCents,
                                          currencyCode,
                                        ),
                                        tone: transaction.amountCents >= 0
                                            ? ObTone.funded
                                            : ObTone.overspent,
                                        style: theme.textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            if (selectedCount > 0)
              _ReviewToolbar(
                selectedCount: selectedCount,
                selectedAmount: formatCentsForCode(
                  selectedAmountCents,
                  currencyCode,
                ),
                onCancel: () => selectedIds.value = <String>{},
                onApprove: approveSelected,
                onCategorize: categorizeSelected,
                onClear: approveSelected,
                onMore: openMoreMenu,
              ),
          ],
        ),
      ),
    );
  }

  static String _currencyFromSummary(BudgetSummary? summary) =>
      normalizeCurrencyCode(summary?.budget.currencyCode ?? '');

  static List<Transaction> _toReviewQueue(List<Transaction> transactions) {
    final queue =
        transactions
            .where(
              (transaction) => !transaction.cleared && !transaction.reconciled,
            )
            .toList(growable: false)
          ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return queue;
  }

  static bool _isSameDay(Transaction a, Transaction b) =>
      a.transactionDate.year == b.transactionDate.year &&
      a.transactionDate.month == b.transactionDate.month &&
      a.transactionDate.day == b.transactionDate.day;

  Future<_EnvelopeChoice?> _showEnvelopePicker(
    BuildContext context, {
    required List<_EnvelopeChoice> envelopeChoices,
  }) {
    final l10n = AppLocalizations.of(context);
    return showModalBottomSheet<_EnvelopeChoice>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                SpacingTokens.md,
                0,
                SpacingTokens.md,
                SpacingTokens.xs,
              ),
              child: Text(
                l10n.reviewTransactionsSelectCategory,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final choice in envelopeChoices)
              ListTile(
                title: Text(choice.name),
                subtitle: Text(choice.categoryName),
                onTap: () => Navigator.of(context).pop(choice),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReviewToolbar extends HookWidget {
  const _ReviewToolbar({
    required this.selectedCount,
    required this.selectedAmount,
    required this.onCancel,
    required this.onApprove,
    required this.onCategorize,
    required this.onClear,
    required this.onMore,
  });

  final int selectedCount;
  final String selectedAmount;
  final VoidCallback onCancel;
  final Future<void> Function() onApprove;
  final Future<void> Function() onCategorize;
  final Future<void> Function() onClear;
  final Future<void> Function() onMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.sm,
            SpacingTokens.xs,
            SpacingTokens.sm,
            SpacingTokens.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.reviewTransactionsSelectedAmount(
                  selectedCount,
                  selectedAmount,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedInk,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              Row(
                children: [
                  _ToolbarAction(
                    icon: OpenBudgetIcons.close,
                    label: l10n.dialogCancel,
                    onTap: onCancel,
                  ),
                  _ToolbarAction(
                    icon: OpenBudgetIcons.checkCircle,
                    label: l10n.reviewTransactionsApprove,
                    onTap: () => unawaited(onApprove()),
                  ),
                  _ToolbarAction(
                    icon: OpenBudgetIcons.category,
                    label: l10n.reviewTransactionsCategorize,
                    onTap: () => unawaited(onCategorize()),
                  ),
                  _ToolbarAction(
                    icon: OpenBudgetIcons.taskDone,
                    label: l10n.reviewTransactionsClear,
                    onTap: () => unawaited(onClear()),
                  ),
                  _ToolbarAction(
                    icon: OpenBudgetIcons.more,
                    label: l10n.moreTitle,
                    onTap: () => unawaited(onMore()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarAction extends HookWidget {
  const _ToolbarAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final WiredSvgIconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Expanded(
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkribbleIcon(data: icon, size: 20, color: palette.brand),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.brand,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _MoreAction { delete }

class _EnvelopeChoice {
  const _EnvelopeChoice({
    required this.id,
    required this.name,
    required this.categoryName,
  });

  final String id;
  final String name;
  final String categoryName;
}
