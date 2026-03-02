import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/category_actions_provider.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AddCategoryDialog extends HookConsumerWidget {
  const AddCategoryDialog({
    required this.budgetId,
    required this.nextSortOrder,
    super.key,
  });

  final String budgetId;
  final int nextSortOrder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final nameController = useTextEditingController();
    final isSubmitting = useState(false);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: SpacingTokens.md),
      title: Text(
        l10n.budgetAddCategory,
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

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    TextEditingController nameController,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = nameController.text.trim();
    if (name.isEmpty) return;
    isSubmitting.value = true;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    try {
      await ref
          .read(categoryActionsProvider.notifier)
          .createCategory(
            name: name,
            budgetId: budgetId,
            sortOrder: nextSortOrder,
          );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.budgetCategoryCreated)),
      );
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.budgetCategoryCreateError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }
}
