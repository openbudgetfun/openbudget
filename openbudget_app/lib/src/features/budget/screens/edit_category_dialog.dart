import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/category_actions_provider.dart';

class EditCategoryDialog extends HookConsumerWidget {
  const EditCategoryDialog({
    required this.categoryId,
    required this.budgetId,
    required this.currentName,
    super.key,
  });

  final String categoryId;
  final String budgetId;
  final String currentName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final nameController = useTextEditingController(text: currentName);
    final isSubmitting = useState(false);

    return AlertDialog(
      title: Text(l10n.budgetEditCategoryTitle),
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
    if (name.isEmpty || name == currentName) return;
    isSubmitting.value = true;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    try {
      await ref
          .read(categoryActionsProvider.notifier)
          .updateCategory(
            categoryId: categoryId,
            budgetId: budgetId,
            name: name,
          );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.budgetEditCategorySuccess)),
      );
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.budgetEditCategoryError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }
}
