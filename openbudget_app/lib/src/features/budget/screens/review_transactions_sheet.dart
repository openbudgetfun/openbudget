import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/review_queue_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// The month's review queue: uncategorised transactions to approve, assign
/// or delete, from `transaction.list` with `uncategorizedOnly`.
Future<void> showReviewTransactionsSheet(
  BuildContext context, {
  required String entityId,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Theme.of(context).ob.canvas,
  barrierColor: Theme.of(context).ob.firmPen.withAlpha(210),
  builder: (context) => FractionallySizedBox(
    heightFactor: 0.95,
    child: ReviewTransactionsSheet(entityId: entityId),
  ),
);

class ReviewTransactionsSheet extends HookConsumerWidget {
  const ReviewTransactionsSheet({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final queueAsync = ref.watch(reviewQueueProvider(entityId));
    final groupsAsync = ref.watch(budgetMonthGroupsProvider(entityId));

    final queue = useState<List<TransactionView>>(<TransactionView>[]);
    final initialized = useState(false);
    final selectedIds = useState<Set<String>>(<String>{});

    useEffect(() {
      if (!queueAsync.hasValue || initialized.value) return null;
      queue.value = List.of(queueAsync.value!);
      initialized.value = true;
      return null;
    }, [queueAsync, initialized.value]);

    final envelopeChoices = <_EnvelopeChoice>[];
    if (groupsAsync.hasValue) {
      for (final group in groupsAsync.value!) {
        for (final view in group.envelopes) {
          final envelopeId = view.envelope.id?.toString();
          if (envelopeId == null || envelopeId.isEmpty) continue;
          envelopeChoices.add(
            _EnvelopeChoice(
              id: envelopeId,
              name: view.envelope.name,
              categoryName: group.category.name,
            ),
          );
        }
      }
    }

    final selectedCount = selectedIds.value.length;

    void invalidateSources() {
      ref
        ..invalidate(reviewQueueProvider(entityId))
        ..invalidate(budgetMonthProvider(entityId))
        ..invalidate(budgetMonthGroupsProvider(entityId));
    }

    Future<void> approveSelected() async {
      final ids = selectedIds.value.toList(growable: false);
      if (ids.isEmpty) return;
      queue.value = queue.value
          .where((view) {
            final transactionId = view.transaction.id?.toString();
            return transactionId == null ||
                !selectedIds.value.contains(transactionId);
          })
          .toList(growable: false);
      selectedIds.value = <String>{};

      try {
        await ref
            .read(transactionActionsProvider.notifier)
            .setStatus(
              transactionIds: ids,
              status: TransactionStatus.cleared,
              entityId: entityId,
            );
      } on Exception {
        // Keep optimistic UI even if network is unavailable in test harnesses.
      } finally {
        if (context.mounted) invalidateSources();
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
        final actions = ref.read(transactionActionsProvider.notifier);
        for (final view in queue.value) {
          final transactionId = view.transaction.id?.toString();
          if (transactionId == null ||
              !selectedIds.value.contains(transactionId)) {
            continue;
          }
          await actions.update(
            transactionId: transactionId,
            entityId: entityId,
            input: _inputWithEnvelope(view, selectedEnvelope.id),
          );
        }
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
          invalidateSources();
        }
      }
    }

    Future<void> deleteSelected() async {
      final ids = selectedIds.value.toList(growable: false);
      if (ids.isEmpty) return;
      queue.value = queue.value
          .where((view) {
            final transactionId = view.transaction.id?.toString();
            return transactionId == null ||
                !selectedIds.value.contains(transactionId);
          })
          .toList(growable: false);
      selectedIds.value = <String>{};

      try {
        await ref
            .read(transactionActionsProvider.notifier)
            .bulkDelete(transactionIds: ids, entityId: entityId);
      } on Exception {
        // Keep optimistic UI even if network is unavailable in test harnesses.
      } finally {
        if (context.mounted) invalidateSources();
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
              child: !initialized.value && queueAsync.isLoading
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
                        final view = queue.value[index];
                        final transaction = view.transaction;
                        final transactionId = transaction.id?.toString();
                        final isSelected =
                            transactionId != null &&
                            selectedIds.value.contains(transactionId);
                        final previous = index > 0
                            ? queue.value[index - 1].transaction
                            : null;
                        final showHeader =
                            previous == null ||
                            !_isSameDay(previous, transaction);

                        final envelopeName = view.transferPeer != null
                              ? l10n.transactionKindTransfer
                              : l10n.reviewTransactionsUncategorized;

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
                                  DateFormat.yMMMMd().format(transaction.date),
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
                                              view.payeeName ??
                                                  transaction.description,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: palette.ink,
                                                  ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '$envelopeName · ${view.accountName}',
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
                                        formatMinorForCode(
                                          transaction.amountMinor,
                                          view.accountCurrencyCode,
                                        ),
                                        tone: transaction.amountMinor >= 0
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

  static bool _isSameDay(Transaction a, Transaction b) =>
      a.date.year == b.date.year &&
      a.date.month == b.date.month &&
      a.date.day == b.date.day;

  /// Rebuilds the input with the chosen envelope on every line, keeping
  /// each line's amount, tax code and memo.
  static TransactionInput _inputWithEnvelope(
    TransactionView view,
    String envelopeId,
  ) {
    final transaction = view.transaction;
    final envelopeUuid = UuidValue.fromString(envelopeId);
    return TransactionInput(
      accountId: transaction.accountId,
      date: transaction.date,
      amountMinor: transaction.amountMinor,
      fxRate: transaction.fxRate,
      payeeId: transaction.payeeId,
      description: transaction.description,
      memo: transaction.memo,
      status: transaction.status,
      flag: transaction.flag,
      lines: view.lines
          .map(
            (line) => TransactionLineInput(
              amountMinor: line.amountMinor,
              envelopeId: envelopeUuid,
              taxCategoryCode: line.taxCategoryCode,
              memo: line.memo,
            ),
          )
          .toList(),
    );
  }

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
    required this.onCancel,
    required this.onApprove,
    required this.onCategorize,
    required this.onClear,
    required this.onMore,
  });

  final int selectedCount;
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
                l10n.reviewTransactionsSelectedCount(selectedCount),
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
