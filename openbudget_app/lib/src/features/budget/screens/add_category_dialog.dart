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
    final nameController = useTextEditingController();
    final isSubmitting = useState(false);

    return WiredDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.budgetAddCategory,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          WiredInput(
            controller: nameController,
            hintText: l10n.budgetCategoryNameLabel,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              WiredButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.dialogCancel),
              ),
              const SizedBox(width: 12),
              WiredButton(
                onPressed: isSubmitting.value
                    ? () {}
                    : () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        isSubmitting.value = true;
                        try {
                          await ref
                              .read(categoryActionsProvider.notifier)
                              .createCategory(
                                name: name,
                                budgetId: budgetId,
                                sortOrder: nextSortOrder,
                              );
                          if (context.mounted) Navigator.of(context).pop();
                        } on Exception catch (_) {
                          isSubmitting.value = false;
                        }
                      },
                child: Text(
                  isSubmitting.value ? l10n.dialogSaving : l10n.dialogSave,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
