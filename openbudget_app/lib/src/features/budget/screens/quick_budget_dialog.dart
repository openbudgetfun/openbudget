import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/monthly_allocation_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/quick_budget_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class QuickBudgetDialog extends HookConsumerWidget {
  const QuickBudgetDialog({
    required this.budgetId,
    required this.envelopeId,
    required this.envelopeName,
    required this.currencyCode,
    required this.year,
    required this.month,
    super.key,
  });

  final String budgetId;
  final String envelopeId;
  final String envelopeName;
  final String currencyCode;
  final int year;
  final int month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final suggestion = ref.watch(
      quickBudgetSuggestionProvider(budgetId, envelopeId, year, month),
    );

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      constraints: const BoxConstraints(maxWidth: 560),
      title: Text(l10n.quickBudgetTitle),
      content: suggestion.when(
        loading: () => SizedBox(
          height: 100,
          child: Center(child: ObLoadingPanel(label: l10n.loadingTitle)),
        ),
        error: (_, _) => Text(l10n.quickBudgetError),
        data: (data) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              envelopeName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            _QuickBudgetOption(
              label: l10n.quickBudgetLastMonth,
              amount: formatCentsForCode(data.budgetedLastMonth, currencyCode),
              onTap: () => _apply(context, ref, data.budgetedLastMonth),
            ),
            _QuickBudgetOption(
              label: l10n.quickBudgetSpentLastMonth,
              amount: formatCentsForCode(data.spentLastMonth, currencyCode),
              onTap: () => _apply(context, ref, data.spentLastMonth),
            ),
            _QuickBudgetOption(
              label: l10n.quickBudgetAverageBudgeted,
              amount: formatCentsForCode(data.averageBudgeted, currencyCode),
              onTap: () => _apply(context, ref, data.averageBudgeted),
            ),
            _QuickBudgetOption(
              label: l10n.quickBudgetAverageSpent,
              amount: formatCentsForCode(data.averageSpent, currencyCode),
              onTap: () => _apply(context, ref, data.averageSpent),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
      ],
    );
  }

  Future<void> _apply(BuildContext context, WidgetRef ref, int cents) async {
    final l10n = AppLocalizations.of(context);

    try {
      await ref
          .read(monthlyAllocationActionsProvider.notifier)
          .upsertAllocation(
            envelopeId: envelopeId,
            budgetId: budgetId,
            year: year,
            month: month,
            allocatedCents: cents,
          );
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.budgetAllocationUpdated,
        variant: AppToastVariant.success,
      );
      if (context.mounted) Navigator.of(context).pop();
    } on Exception catch (_) {
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.budgetAllocationError,
        variant: AppToastVariant.error,
      );
    }
  }
}

class _QuickBudgetOption extends HookWidget {
  const _QuickBudgetOption({
    required this.label,
    required this.amount,
    required this.onTap,
  });

  final String label;
  final String amount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(
          vertical: SpacingTokens.sm,
          horizontal: SpacingTokens.sm,
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
            ObAmount(amount, style: theme.textTheme.bodyMedium),
            const SizedBox(width: SpacingTokens.xs),
            SkribbleIcon(
              data: OpenBudgetIcons.chevronRight,
              size: 16,
              color: Theme.of(context).ob.mutedInk,
            ),
          ],
        ),
      ),
    );
  }
}
