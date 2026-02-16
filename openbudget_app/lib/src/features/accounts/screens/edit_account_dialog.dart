import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_actions_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class EditAccountDialog extends HookConsumerWidget {
  const EditAccountDialog({
    required this.account,
    required this.budgetId,
    super.key,
  });

  final Account account;
  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final nameController = useTextEditingController(text: account.name);
    final onBudget = useState(account.onBudget);
    final isSubmitting = useState(false);

    final accountTypes = [
      'checking',
      'savings',
      'creditCard',
      'cash',
      'investment',
      'other',
    ];
    final selectedType = useState(account.accountType);

    String typeLabel(String type) => switch (type) {
      'checking' => l10n.accountTypeChecking,
      'savings' => l10n.accountTypeSavings,
      'creditCard' => l10n.accountTypeCreditCard,
      'cash' => l10n.accountTypeCash,
      'investment' => l10n.accountTypeInvestment,
      _ => l10n.accountTypeOther,
    };

    return AlertDialog(
      title: Text(l10n.accountEditTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.accountNameLabel,
                prefixIcon: const Icon(Icons.label_outlined),
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: SpacingTokens.md),
            DropdownButtonFormField<String>(
              initialValue: selectedType.value,
              items: accountTypes
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(typeLabel(type)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) selectedType.value = value;
              },
              decoration: InputDecoration(
                labelText: l10n.accountTypeLabel,
                prefixIcon: const Icon(Icons.account_balance_rounded),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            SwitchListTile(
              value: onBudget.value,
              onChanged: (value) => onBudget.value = value,
              title: Text(l10n.accountOnBudgetLabel),
              subtitle: Text(l10n.accountOnBudgetHint),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        if (!account.isClosed)
          TextButton(
            onPressed: isSubmitting.value
                ? null
                : () => _closeAccount(context, ref),
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: Text(l10n.accountCloseButton),
          ),
        if (account.isClosed) ...[
          TextButton(
            onPressed: isSubmitting.value
                ? null
                : () => _deleteAccountPermanently(context, ref),
            style: TextButton.styleFrom(foregroundColor: colorScheme.error),
            child: Text(l10n.accountDeleteButton),
          ),
          TextButton(
            onPressed: isSubmitting.value
                ? null
                : () => _reopenAccount(context, ref),
            child: Text(l10n.accountReopenButton),
          ),
        ],
        FilledButton(
          onPressed: isSubmitting.value
              ? null
              : () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) return;

                  isSubmitting.value = true;
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    await ref
                        .read(accountActionsProvider.notifier)
                        .updateAccount(
                          accountId: account.id?.toString() ?? '',
                          budgetId: budgetId,
                          name: name,
                          accountType: selectedType.value,
                          onBudget: onBudget.value,
                        );
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.accountEditSuccess)),
                    );
                    navigator.pop();
                  } on Exception catch (_) {
                    isSubmitting.value = false;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(l10n.accountEditError),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                  }
                },
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

  Future<void> _closeAccount(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.accountCloseButton),
        content: Text(l10n.accountCloseConfirm),
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
            child: Text(l10n.accountCloseButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(accountActionsProvider.notifier)
          .updateAccount(
            accountId: account.id?.toString() ?? '',
            budgetId: budgetId,
            isClosed: true,
          );
      messenger.showSnackBar(SnackBar(content: Text(l10n.accountCloseSuccess)));
      navigator.pop();
    } on Exception catch (_) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.accountEditError),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _reopenAccount(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(accountActionsProvider.notifier)
          .updateAccount(
            accountId: account.id?.toString() ?? '',
            budgetId: budgetId,
            isClosed: false,
          );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.accountReopenSuccess)),
      );
      navigator.pop();
    } on Exception catch (_) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.accountEditError),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteAccountPermanently(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.accountDeleteTitle),
        content: Text(l10n.accountDeleteConfirm),
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
            child: Text(l10n.accountDeleteButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final deleted = await ref
          .read(accountActionsProvider.notifier)
          .deleteAccount(
            accountId: account.id?.toString() ?? '',
            budgetId: budgetId,
          );
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.accountDeleteSuccess),
          action: SnackBarAction(
            label: l10n.undoAction,
            onPressed: () => _undoDelete(messenger, ref, deleted, l10n),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      navigator.pop();
    } on Exception catch (_) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.accountDeleteError),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  void _undoDelete(
    ScaffoldMessengerState messenger,
    WidgetRef ref,
    Account deleted,
    AppLocalizations l10n,
  ) {
    ref
        .read(accountActionsProvider.notifier)
        .undoDeleteAccount(deletedAccount: deleted, budgetId: budgetId)
        .then((_) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.undoDeleteSuccess)),
          );
        })
        .catchError((_) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.undoDeleteError)));
        });
  }
}
