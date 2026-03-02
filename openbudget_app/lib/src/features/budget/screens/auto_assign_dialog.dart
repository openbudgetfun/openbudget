import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/auto_assign_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AutoAssignDialog extends HookConsumerWidget {
  const AutoAssignDialog({
    required this.budgetId,
    required this.currencyCode,
    super.key,
  });

  final String budgetId;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final proposalAsync = ref.watch(autoAssignProposalProvider(budgetId));
    final isAssigning = useState(false);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      constraints: const BoxConstraints(maxWidth: 560),
      title: Row(
        children: [
          const Icon(
            Icons.auto_fix_high_rounded,
            color: ColorTokens.primary,
            size: 24,
          ),
          const SizedBox(width: SpacingTokens.sm),
          Expanded(child: Text(l10n.autoAssignTitle)),
        ],
      ),
      content: proposalAsync.when(
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => Text(l10n.autoAssignError),
        data: (proposal) {
          if (proposal.items.isEmpty) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 48,
                  color: ColorTokens.secondary,
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  l10n.autoAssignNothingToAssign,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          }

          return SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(SpacingTokens.sm),
                  decoration: BoxDecoration(
                    color: ColorTokens.secondary.withAlpha(20),
                    borderRadius: BorderRadius.circular(RadiusTokens.sm),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.autoAssignDistributing,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        formatCents(proposal.totalAssignedCents, currencyCode),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ColorTokens.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  l10n.autoAssignEnvelopeCount(proposal.items.length),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: proposal.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = proposal.items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: SpacingTokens.sm,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.envelopeName,
                                style: theme.textTheme.bodyMedium,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: SpacingTokens.sm),
                            Text(
                              '+${formatCents(item.addedCents, currencyCode)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: ColorTokens.secondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: isAssigning.value
              ? null
              : () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        if (proposalAsync.hasValue && proposalAsync.value!.items.isNotEmpty)
          FilledButton.icon(
            onPressed: isAssigning.value
                ? null
                : () => _executeAssign(
                    context,
                    ref,
                    proposalAsync.value!,
                    isAssigning,
                  ),
            icon: isAssigning.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_fix_high_rounded, size: 18),
            label: Text(
              isAssigning.value
                  ? l10n.autoAssignAssigning
                  : l10n.autoAssignButton,
            ),
          ),
      ],
    );
  }

  Future<void> _executeAssign(
    BuildContext context,
    WidgetRef ref,
    AutoAssignProposal proposal,
    ValueNotifier<bool> isAssigning,
  ) async {
    final l10n = AppLocalizations.of(context);

    isAssigning.value = true;
    try {
      final count = await ref
          .read(autoAssignActionsProvider.notifier)
          .execute(budgetId: budgetId, items: proposal.items);
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.autoAssignSuccess(count),
          variant: AppToastVariant.success,
        );
        Navigator.of(context).pop();
      }
    } on Exception catch (_) {
      isAssigning.value = false;
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.autoAssignError,
          variant: AppToastVariant.error,
        );
      }
    }
  }
}
