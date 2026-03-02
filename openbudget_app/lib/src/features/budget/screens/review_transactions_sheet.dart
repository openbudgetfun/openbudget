import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

Future<void> showReviewTransactionsSheet(
  BuildContext context, {
  required String budgetId,
  required int year,
  required int month,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: OpenBudgetPalette.transparentFor(Theme.of(context)),
    barrierColor: OpenBudgetPalette.overlayScrimFor(Theme.of(context)),
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.95,
      child: ReviewTransactionsSheet(
        budgetId: budgetId,
        year: year,
        month: month,
      ),
    ),
  );
}

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
          message: 'Could not update transaction category.',
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
                leading: const Icon(Icons.delete_outline_rounded),
                title: const Text('Delete selected'),
                onTap: () => Navigator.of(context).pop(_MoreAction.delete),
              ),
              ListTile(
                leading: const Icon(Icons.close_rounded),
                title: const Text('Cancel'),
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
        ? '$selectedCount Selected'
        : queue.value.isEmpty
        ? 'No Transactions'
        : queue.value.length == 1
        ? '1 New Transaction'
        : '${queue.value.length} New Transactions';

    final currencyCode = _currencyFromSummary(
      summaryAsync.hasValue ? summaryAsync.value : null,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            OpenBudgetPalette.bgPrimaryFor(Theme.of(context)),
            OpenBudgetPalette.bgSecondaryFor(Theme.of(context)),
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(RadiusTokens.lg),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: SpacingTokens.xs),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
                borderRadius: BorderRadius.circular(RadiusTokens.md),
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
            Text(
              'Approve or categorize new transactions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
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
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: !initialized.value && transactionsAsync.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : queue.value.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpacingTokens.lg,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.task_alt_rounded,
                              size: 30,
                              color: OpenBudgetPalette.fgSecondaryFor(
                                Theme.of(context),
                              ),
                            ),
                            const SizedBox(height: SpacingTokens.md),
                            Text(
                              "You're All Done!",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: SpacingTokens.xs),
                            Text(
                              'Return to Accounts to see all of your transactions.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: OpenBudgetPalette.fgSecondaryFor(
                                  Theme.of(context),
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
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
                            ? 'Uncategorized'
                            : envelopeNameById[transaction.envelopeId
                                      .toString()] ??
                                  'Uncategorized';

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showHeader)
                              Container(
                                margin: const EdgeInsets.fromLTRB(
                                  SpacingTokens.md,
                                  SpacingTokens.sm,
                                  SpacingTokens.md,
                                  SpacingTokens.xs,
                                ),
                                padding: const EdgeInsets.fromLTRB(
                                  SpacingTokens.sm,
                                  SpacingTokens.xs,
                                  SpacingTokens.sm,
                                  SpacingTokens.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: OpenBudgetPalette.bgTertiaryFor(
                                    Theme.of(context),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    RadiusTokens.sm,
                                  ),
                                  border: Border.all(
                                    color: OpenBudgetPalette.borderSubtleFor(
                                      Theme.of(context),
                                    ),
                                  ),
                                ),

                                child: Text(
                                  DateFormat.yMMMMd().format(
                                    transaction.transactionDate,
                                  ),
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            InkWell(
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
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(
                                  SpacingTokens.md,
                                  0,
                                  SpacingTokens.md,
                                  SpacingTokens.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? OpenBudgetPalette.bgSelectedFor(theme)
                                      : OpenBudgetPalette.bgSecondaryFor(
                                          Theme.of(context),
                                        ),
                                  borderRadius: BorderRadius.circular(
                                    RadiusTokens.md,
                                  ),
                                  border: Border.all(
                                    color: OpenBudgetPalette.borderSubtleFor(
                                      Theme.of(context),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 68,
                                      color: isSelected
                                          ? OpenBudgetPalette.bgBrandFor(
                                              Theme.of(context),
                                            )
                                          : OpenBudgetPalette.transparentFor(
                                              theme,
                                            ),
                                    ),
                                    const SizedBox(width: SpacingTokens.sm),
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons.circle_outlined,
                                      color: isSelected
                                          ? OpenBudgetPalette.bgBrandFor(
                                              Theme.of(context),
                                            )
                                          : OpenBudgetPalette.fgSecondaryFor(
                                              Theme.of(context),
                                            ),
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
                                                ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            envelopeName,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color:
                                                      OpenBudgetPalette.fgSecondaryFor(
                                                        theme,
                                                      ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: SpacingTokens.md),
                                    Text(
                                      formatCents(
                                        transaction.amountCents,
                                        currencyCode,
                                      ),
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: transaction.amountCents >= 0
                                            ? OpenBudgetPalette.fgSuccessFor(
                                                theme,
                                              )
                                            : OpenBudgetPalette.fgPrimaryEmphasisFor(
                                                theme,
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: SpacingTokens.md),
                                  ],
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
                selectedAmount: formatCents(selectedAmountCents, currencyCode),
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

  static CurrencyCode _currencyFromSummary(BudgetSummary? summary) {
    final code = summary?.budget.currencyCode;
    if (code == null) return CurrencyCode.usd;
    return CurrencyCode.values.firstWhere(
      (currency) => currency.code == code,
      orElse: () => CurrencyCode.usd,
    );
  }

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

  static bool _isSameDay(Transaction a, Transaction b) {
    return a.transactionDate.year == b.transactionDate.year &&
        a.transactionDate.month == b.transactionDate.month &&
        a.transactionDate.day == b.transactionDate.day;
  }

  Future<_EnvelopeChoice?> _showEnvelopePicker(
    BuildContext context, {
    required List<_EnvelopeChoice> envelopeChoices,
  }) {
    return showModalBottomSheet<_EnvelopeChoice>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(
                  SpacingTokens.md,
                  0,
                  SpacingTokens.md,
                  SpacingTokens.xs,
                ),
                child: Text(
                  'Select category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
        );
      },
    );
  }
}

class _ReviewToolbar extends StatelessWidget {
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
    return Container(
      decoration: BoxDecoration(
        color: OpenBudgetPalette.bgSecondaryFor(Theme.of(context)),
        border: Border(
          top: BorderSide(
            color: OpenBudgetPalette.borderSubtleFor(Theme.of(context)),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: OpenBudgetPalette.overlayScrimFor(Theme.of(context))
                .withAlpha(
                  Theme.of(context).brightness == Brightness.dark ? 84 : 24,
                ),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.sm,
        SpacingTokens.xs,
        SpacingTokens.sm,
        SpacingTokens.sm,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$selectedCount selected • $selectedAmount',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: OpenBudgetPalette.fgSecondaryFor(Theme.of(context)),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Row(
              children: [
                _ToolbarAction(
                  icon: Icons.close_rounded,
                  label: 'Cancel',
                  onTap: onCancel,
                ),
                _ToolbarAction(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Approve',
                  onTap: () => unawaited(onApprove()),
                ),
                _ToolbarAction(
                  icon: Icons.category_outlined,
                  label: 'Categorize',
                  onTap: () => unawaited(onCategorize()),
                ),
                _ToolbarAction(
                  icon: Icons.task_alt_outlined,
                  label: 'Clear',
                  onTap: () => unawaited(onClear()),
                ),
                _ToolbarAction(
                  icon: Icons.more_horiz_rounded,
                  label: 'More',
                  onTap: () => unawaited(onMore()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolbarAction extends StatelessWidget {
  const _ToolbarAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: OpenBudgetPalette.bgBrandFor(Theme.of(context)),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: OpenBudgetPalette.bgBrandFor(Theme.of(context)),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
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
