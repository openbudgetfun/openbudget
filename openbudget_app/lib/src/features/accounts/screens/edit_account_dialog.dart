import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_actions_provider.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class EditAccountDialog extends HookConsumerWidget {
  const EditAccountDialog({
    required this.account,
    required this.entityId,
    this.onDeleted,
    super.key,
  });

  final Account account;
  final String entityId;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

    final nameController = useTextEditingController(text: account.name);
    final notesController = useTextEditingController(
      text: account.note ?? '',
    );
    final onBudget = useState(account.onBudget);
    final isSubmitting = useState(false);

    // A kind change stays within the same liability class and balance
    // source, so a loan never becomes a wallet and vice versa.
    final selectableKinds = AccountKind.values
        .where(
          (kind) =>
              kind.isLiability == account.kind.isLiability &&
              kind.allowedBalanceSources.contains(account.balanceSource),
        )
        .toList();
    final selectedKind = useState<AccountKind>(account.kind);

    useListenable(nameController);

    String kindLabel(AccountKind kind) => switch (kind) {
      AccountKind.checking => l10n.accountTypeChecking,
      AccountKind.savings => l10n.accountTypeSavings,
      AccountKind.creditCard => l10n.accountTypeCreditCard,
      AccountKind.cash => l10n.accountTypeCash,
      AccountKind.investment => l10n.accountTypeInvestment,
      AccountKind.crypto => l10n.accountTypeCryptoWallet,
      AccountKind.loan => l10n.addAccountTypePersonalLoan,
      AccountKind.mortgage => l10n.addAccountTypeMortgage,
      AccountKind.property => l10n.addAccountTypeProperty,
      AccountKind.vehicle => l10n.addAccountTypeVehicle,
      AccountKind.otherAsset => l10n.addAccountTypeOtherAsset,
      AccountKind.otherLiability => l10n.addAccountTypeOtherDebt,
    };

    final canSave = nameController.text.trim().isNotEmpty;

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 92,
          leading: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.dialogCancel),
          ),
          title: Text(
            l10n.accountEditTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: palette.ink,
            ),
          ),
          actions: [
            TextButton(
              onPressed: canSave && !isSubmitting.value
                  ? () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) return;

                      isSubmitting.value = true;
                      final navigator = Navigator.of(context);

                      try {
                        await ref
                            .read(accountActionsProvider.notifier)
                            .updateAccount(
                              accountId: account.id?.toString() ?? '',
                              entityId: entityId,
                              name: name,
                              kind: selectedKind.value,
                              onBudget: onBudget.value,
                              note: notesController.text.trim().isEmpty
                                  ? null
                                  : notesController.text.trim(),
                            );
                        if (!context.mounted) return;
                        showAppToast(
                          context,
                          message: l10n.accountEditSuccess,
                          variant: AppToastVariant.success,
                        );
                        navigator.pop();
                      } on Exception catch (_) {
                        isSubmitting.value = false;
                        if (!context.mounted) return;
                        showAppToast(
                          context,
                          message: l10n.accountEditError,
                          variant: AppToastVariant.error,
                        );
                      }
                    }
                  : null,
              child: isSubmitting.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.dialogSave),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.md,
            SpacingTokens.md,
            SpacingTokens.md,
            SpacingTokens.xl,
          ),
          children: [
            _SectionLabel(text: l10n.accountEditNicknameLabel),
            TextField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: l10n.accountEditNicknameHint,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            _SectionLabel(text: l10n.accountEditNotesLabel),
            TextField(
              controller: notesController,
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(hintText: l10n.accountEditNotesHint),
            ),
            const SizedBox(height: SpacingTokens.md),
            _SectionLabel(text: l10n.accountTypeLabel),
            DropdownButtonFormField<AccountKind>(
              initialValue: selectedKind.value,
              items: selectableKinds
                  .map(
                    (kind) => DropdownMenuItem(
                      value: kind,
                      child: Text(kindLabel(kind)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) selectedKind.value = value;
              },
            ),
            const SizedBox(height: SpacingTokens.md),
            _SectionLabel(text: l10n.accountEditBankConnection),
            OutlinedButton.icon(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.sm,
                ),
              ),
              icon: const SkribbleIcon(data: OpenBudgetIcons.link, size: 18),
              label: Text(l10n.accountEditLinkAccountUnavailable),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              l10n.accountEditLinkAccountUnavailableHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.mutedInk,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            if (account.closedAt == null)
              OutlinedButton(
                onPressed: isSubmitting.value
                    ? null
                    : () => _closeAccount(context, ref),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  foregroundColor: palette.hue(ObTone.overspent),
                  side: BorderSide(
                    color: palette.hue(ObTone.overspent).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(l10n.accountCloseButton),
              ),
            if (account.closedAt != null) ...[
              FilledButton.tonal(
                onPressed: isSubmitting.value
                    ? null
                    : () => _reopenAccount(context, ref),
                child: Text(l10n.accountReopenButton),
              ),
            ],
            const SizedBox(height: SpacingTokens.sm),
            FilledButton.tonal(
              onPressed: isSubmitting.value
                  ? null
                  : () => _deleteAccountPermanently(context, ref),
              style: FilledButton.styleFrom(
                foregroundColor: palette.hue(ObTone.overspent),
                backgroundColor: palette.wash(ObTone.overspent),
              ),
              child: Text(l10n.accountDeleteButton),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _closeAccount(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
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
              backgroundColor: palette.hue(ObTone.overspent),
              foregroundColor: palette.surface,
            ),
            child: Text(l10n.accountCloseButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    try {
      await ref
          .read(accountActionsProvider.notifier)
          .closeAccount(
            accountId: account.id?.toString() ?? '',
            entityId: entityId,
          );
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.accountCloseSuccess,
        variant: AppToastVariant.success,
      );
      navigator.pop();
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.accountEditError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<void> _reopenAccount(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final navigator = Navigator.of(context);
    try {
      await ref
          .read(accountActionsProvider.notifier)
          .reopenAccount(
            accountId: account.id?.toString() ?? '',
            entityId: entityId,
          );
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.accountReopenSuccess,
        variant: AppToastVariant.success,
      );
      navigator.pop();
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.accountEditError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

  Future<void> _deleteAccountPermanently(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.accountDeleteTitle),
        content: Text('${l10n.accountDeleteConfirm}\n\n"${account.name}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: palette.hue(ObTone.overspent),
              foregroundColor: palette.surface,
            ),
            child: Text(l10n.accountDeleteButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final navigator = Navigator.of(context);
    final accountId = account.id?.toString();
    if (accountId == null) {
      showAppToast(
        context,
        message: l10n.accountDeleteError,
        variant: AppToastVariant.error,
      );
      return;
    }

    try {
      await ref
          .read(accountActionsProvider.notifier)
          .deleteAccount(accountId: accountId, entityId: entityId);
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.accountDeleteSuccess,
        variant: AppToastVariant.success,
      );
      navigator.pop();
    } on Exception catch (_) {
      if (context.mounted) {
        showAppToast(
          context,
          message: l10n.accountDeleteError,
          variant: AppToastVariant.error,
        );
      }
    }
  }

}

class _SectionLabel extends HookWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: Theme.of(context).ob.ink,
      ),
    ),
  );
}
