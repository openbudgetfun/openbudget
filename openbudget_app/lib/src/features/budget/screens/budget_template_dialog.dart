import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_template_provider.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class BudgetTemplateDialog extends HookConsumerWidget {
  const BudgetTemplateDialog({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final templatesAsync = ref.watch(budgetTemplateListProvider(budgetId));
    final nameController = useTextEditingController();
    final isSaving = useState(false);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.templateTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: SpacingTokens.lg),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l10n.templateNameLabel,
                        hintText: l10n.templateNameHint,
                        isDense: true,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) =>
                          _save(context, ref, nameController, isSaving),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  FilledButton(
                    onPressed: isSaving.value
                        ? null
                        : () => _save(context, ref, nameController, isSaving),
                    child: isSaving.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.templateSaveButton),
                  ),
                ],
              ),
              const SizedBox(height: SpacingTokens.lg),
              const Divider(),
              const SizedBox(height: SpacingTokens.sm),
              Flexible(
                child: templatesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                    child: Text(
                      l10n.templateSaveError,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
                  data: (templates) {
                    if (templates.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bookmark_border_rounded,
                              size: 40,
                              color: colorScheme.outlineVariant,
                            ),
                            const SizedBox(height: SpacingTokens.sm),
                            Text(
                              l10n.templateEmptyTitle,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: SpacingTokens.xs),
                            Text(
                              l10n.templateEmptySubtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: templates.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: SpacingTokens.xs),
                      itemBuilder: (context, index) {
                        final template = templates[index];
                        return _TemplateTile(
                          name: template.name,
                          onApply: () =>
                              _apply(context, ref, template.id.toString()),
                          onDelete: () =>
                              _delete(context, ref, template.id.toString()),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.dialogCancel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    WidgetRef ref,
    TextEditingController nameController,
    ValueNotifier<bool> isSaving,
  ) async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    isSaving.value = true;

    try {
      await ref
          .read(budgetTemplateActionsProvider.notifier)
          .saveFromCurrentMonth(budgetId: budgetId, name: name);
      nameController.clear();
      messenger.showSnackBar(SnackBar(content: Text(l10n.templateSaveSuccess)));
    } on Exception catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.templateSaveError),
          backgroundColor: colorScheme.error,
        ),
      );
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _apply(
    BuildContext context,
    WidgetRef ref,
    String templateId,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    try {
      await ref
          .read(budgetTemplateActionsProvider.notifier)
          .applyTemplate(templateId: templateId, budgetId: budgetId);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.templateApplySuccess)),
      );
      navigator.pop();
    } on Exception catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.templateApplyError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    String templateId,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    try {
      await ref
          .read(budgetTemplateActionsProvider.notifier)
          .deleteTemplate(templateId: templateId, budgetId: budgetId);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.templateDeleteSuccess)),
      );
    } on Exception catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.templateDeleteError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }
}

class _TemplateTile extends HookWidget {
  const _TemplateTile({
    required this.name,
    required this.onApply,
    required this.onDelete,
  });

  final String name;
  final VoidCallback onApply;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.bookmark_rounded),
        title: Text(
          name,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FilledButton.tonal(
              onPressed: onApply,
              child: Text(l10n.templateApplyButton),
            ),
            const SizedBox(width: SpacingTokens.xs),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: theme.colorScheme.error,
              ),
              onPressed: onDelete,
              iconSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
