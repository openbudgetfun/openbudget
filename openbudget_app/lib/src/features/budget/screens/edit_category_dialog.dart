import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/category_actions_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class EditCategoryDialog extends HookConsumerWidget {
  const EditCategoryDialog({
    required this.categoryId,
    required this.budgetId,
    required this.currentName,
    required this.envelopeCount,
    required this.totalAllocatedCents,
    required this.currencyCode,
    super.key,
  });

  final String categoryId;
  final String budgetId;
  final String currentName;
  final int envelopeCount;
  final int totalAllocatedCents;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final nameController = useTextEditingController(text: currentName);
    final isSubmitting = useState(false);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      constraints: const BoxConstraints(maxWidth: 560),
      title: Text(
        l10n.budgetEditCategoryTitle,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: TextField(
        controller: nameController,
        decoration: InputDecoration(
          labelText: l10n.budgetCategoryNameLabel,
          prefixIcon: const Icon(Icons.category_outlined),
        ),
        autofocus: true,
        textInputAction: TextInputAction.done,
        onSubmitted: isSubmitting.value
            ? null
            : (_) => _submit(context, ref, nameController, isSubmitting),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting.value
              ? null
              : () => _delete(context, ref, isSubmitting),
          child: Text(
            l10n.deleteConfirmButton,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(
          onPressed: isSubmitting.value
              ? null
              : () => _submit(context, ref, nameController, isSubmitting),
          child: isSubmitting.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.dialogSave),
        ),
      ],
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final envelopeSummary = envelopeCount == 1
        ? '1 envelope'
        : '$envelopeCount envelopes';
    final allocated = formatCents(totalAllocatedCents, currencyCode);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(
          '${l10n.deleteConfirmMessage}\n\n'
          '"$currentName"\n\n'
          '$envelopeSummary\n'
          '$allocated allocated',
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

    if (confirmed != true || !context.mounted) return;

    isSubmitting.value = true;
    try {
      await ref
          .read(categoryActionsProvider.notifier)
          .deleteCategory(categoryId: categoryId, budgetId: budgetId);
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.deleteSuccess,
        variant: AppToastVariant.success,
      );
      if (context.mounted) Navigator.of(context).pop();
    } on Exception {
      isSubmitting.value = false;
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.deleteError,
        variant: AppToastVariant.error,
      );
    }
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    TextEditingController nameController,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = nameController.text.trim();
    if (name.isEmpty || name == currentName) return;
    isSubmitting.value = true;
    final navigator = Navigator.of(context);
    try {
      await ref
          .read(categoryActionsProvider.notifier)
          .updateCategory(
            categoryId: categoryId,
            budgetId: budgetId,
            name: name,
          );
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.budgetEditCategorySuccess,
        variant: AppToastVariant.success,
      );
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.budgetEditCategoryError,
        variant: AppToastVariant.error,
      );
    }
  }
}
