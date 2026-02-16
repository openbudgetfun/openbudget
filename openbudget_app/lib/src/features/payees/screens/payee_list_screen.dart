import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_actions_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class PayeeListScreen extends HookConsumerWidget {
  const PayeeListScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final payeesAsync = ref.watch(payeeListProvider(budgetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    useEffect(() {
      void listener() => searchQuery.value = searchController.text;
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/budgets/$budgetId'),
        ),
        title: Text(l10n.payeeListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.payeeAddButton,
            onPressed: () => _showAddPayeeDialog(context, ref),
          ),
        ],
      ),
      body: payeesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: colorScheme.error,
              ),
              const SizedBox(height: SpacingTokens.md),
              Text(
                l10n.payeeLoadError,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
        data: (payees) {
          if (payees.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.store_rounded,
                    size: 48,
                    color: colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    l10n.payeeEmptyTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                  Text(
                    l10n.payeeEmptySubtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  FilledButton.icon(
                    onPressed: () => _showAddPayeeDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.payeeAddButton),
                  ),
                ],
              ),
            );
          }

          final query = searchQuery.value.toLowerCase();
          final filtered = query.isEmpty
              ? payees
              : payees
                    .where((p) => p.name.toLowerCase().contains(query))
                    .toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(payeeListProvider(budgetId)),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.md,
                    SpacingTokens.md,
                    SpacingTokens.md,
                    SpacingTokens.sm,
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: l10n.payeeSearchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: searchController.clear,
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(RadiusTokens.md),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.md,
                        vertical: SpacingTokens.sm,
                      ),
                    ),
                  ),
                ),
                if (query.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.payeeSearchResultCount(filtered.length),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            l10n.payeeSearchNoResults,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(SpacingTokens.md),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final payee = filtered[index];
                            return _PayeeTile(payee: payee, budgetId: budgetId);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddPayeeDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => _AddPayeeDialog(budgetId: budgetId),
    );
  }
}

class _PayeeTile extends HookConsumerWidget {
  const _PayeeTile({required this.payee, required this.budgetId});

  final Payee payee;
  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: ValueKey(payee.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: SpacingTokens.lg),
        margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
        child: Icon(Icons.delete_rounded, color: colorScheme.onError),
      ),
      confirmDismiss: (_) => _confirmDelete(context, l10n, colorScheme),
      onDismissed: (_) => _deletePayee(context, ref, l10n, colorScheme),
      child: Card(
        margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
        child: ListTile(
          onTap: () => _showEditDialog(context),
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Icon(
              Icons.store_rounded,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          title: Text(payee.name, style: theme.textTheme.bodyMedium),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text('${l10n.deleteConfirmMessage}\n\n"${payee.name}"'),
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
  }

  Future<void> _deletePayee(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) async {
    try {
      await ref
          .read(payeeActionsProvider.notifier)
          .deletePayee(payeeId: payee.id?.toString() ?? '', budgetId: budgetId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.deleteSuccess)));
      }
    } on Exception catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.deleteError),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  void _showEditDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => _EditPayeeDialog(payee: payee, budgetId: budgetId),
    );
  }
}

class _AddPayeeDialog extends HookConsumerWidget {
  const _AddPayeeDialog({required this.budgetId});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final nameController = useTextEditingController();
    final isSubmitting = useState(false);

    return AlertDialog(
      title: Text(l10n.payeeAddButton),
      content: TextField(
        controller: nameController,
        decoration: InputDecoration(
          labelText: l10n.payeeNameLabel,
          prefixIcon: const Icon(Icons.store_outlined),
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
          .read(payeeActionsProvider.notifier)
          .createPayee(name: name, budgetId: budgetId);
      messenger.showSnackBar(SnackBar(content: Text(l10n.payeeCreateSuccess)));
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.payeeCreateError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }
}

class _EditPayeeDialog extends HookConsumerWidget {
  const _EditPayeeDialog({required this.payee, required this.budgetId});

  final Payee payee;
  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final nameController = useTextEditingController(text: payee.name);
    final isSubmitting = useState(false);

    return AlertDialog(
      title: Text(l10n.payeeEditTitle),
      content: TextField(
        controller: nameController,
        decoration: InputDecoration(
          labelText: l10n.payeeNameLabel,
          prefixIcon: const Icon(Icons.store_outlined),
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
          .read(payeeActionsProvider.notifier)
          .updatePayee(
            payeeId: payee.id?.toString() ?? '',
            budgetId: budgetId,
            name: name,
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.payeeEditSuccess)));
      navigator.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.payeeEditError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }
}
