import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_actions_provider.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class EditAccountDialog extends HookConsumerWidget {
  const EditAccountDialog({
    required this.account,
    required this.budgetId,
    this.onDeleted,
    super.key,
  });

  final Account account;
  final String budgetId;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final nameController = useTextEditingController(text: account.name);
    final notesController = useTextEditingController();
    final onBudget = useState(account.onBudget);
    final isSubmitting = useState(false);
    final currencyCode = parseCurrencyCode(account.currencyCode);
    final factor = _pow10(currencyCode.decimals);

    final accountTypes = [
      'checking',
      'savings',
      'creditCard',
      'cash',
      'investment',
      'cryptoWallet',
      'other',
    ];
    final selectedType = useState(account.accountType);
    final balanceIsPositive = useState(account.balanceCents >= 0);
    final balanceController = useTextEditingController(
      text: _formatInitialAmount(
        cents: account.balanceCents.abs(),
        decimals: currencyCode.decimals,
      ),
    );

    useListenable(nameController);
    useListenable(balanceController);

    String typeLabel(String type) => switch (type) {
      'checking' => l10n.accountTypeChecking,
      'savings' => l10n.accountTypeSavings,
      'creditCard' => l10n.accountTypeCreditCard,
      'cash' => l10n.accountTypeCash,
      'investment' => l10n.accountTypeInvestment,
      'cryptoWallet' => 'Solana Wallet',
      _ => l10n.accountTypeOther,
    };

    final parsedBalance = double.tryParse(balanceController.text.trim());
    final canSave =
        nameController.text.trim().isNotEmpty &&
        parsedBalance != null &&
        parsedBalance >= 0;

    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(theme),
        appBar: AppBar(
          backgroundColor: OpenBudgetPalette.bgPrimaryFor(theme),
          surfaceTintColor: OpenBudgetPalette.transparentFor(theme),
          scrolledUnderElevation: 0,
          leadingWidth: 92,
          leading: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.dialogCancel),
          ),
          title: Text(
            l10n.accountEditTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: canSave && !isSubmitting.value
                  ? () async {
                      final name = nameController.text.trim();
                      final balance = parsedBalance;
                      if (name.isEmpty) return;

                      var balanceCents = (balance * factor).round();
                      if (!balanceIsPositive.value && balanceCents > 0) {
                        balanceCents = -balanceCents;
                      }

                      isSubmitting.value = true;
                      final navigator = Navigator.of(context);

                      try {
                        await ref
                            .read(accountActionsProvider.notifier)
                            .updateAccount(
                              accountId: account.id?.toString() ?? '',
                              budgetId: budgetId,
                              name: name,
                              accountType: selectedType.value,
                              balanceCents: balanceCents,
                              onBudget: onBudget.value,
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
            ),
            const SizedBox(height: SpacingTokens.md),
            _SectionLabel(text: l10n.accountDetailBalance),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.sm,
                vertical: SpacingTokens.xs,
              ),
              decoration: BoxDecoration(
                color: OpenBudgetPalette.bgSecondaryFor(theme),
                borderRadius: BorderRadius.circular(RadiusTokens.md),
                border: Border.all(
                  color: OpenBudgetPalette.borderSubtleFor(theme),
                ),
              ),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(RadiusTokens.sm),
                    onTap: () =>
                        balanceIsPositive.value = !balanceIsPositive.value,
                    child: Container(
                      width: 44,
                      height: 36,
                      decoration: BoxDecoration(
                        color: balanceIsPositive.value
                            ? OpenBudgetPalette.fgSuccessFor(theme)
                            : OpenBudgetPalette.fgErrorFor(theme),
                        borderRadius: BorderRadius.circular(RadiusTokens.sm),
                      ),
                      child: Icon(
                        balanceIsPositive.value
                            ? Icons.add_rounded
                            : Icons.remove_rounded,
                        color: OpenBudgetPalette.fgOnBrandFor(theme),
                      ),
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Text(
                    currencyCode.symbol,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: SpacingTokens.xs),
                  Expanded(
                    child: TextField(
                      controller: balanceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.end,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              l10n.accountEditAdjustmentHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: OpenBudgetPalette.fgSecondaryFor(theme),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            _SectionLabel(text: l10n.accountEditBankConnection),
            OutlinedButton(
              onPressed: null,
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingTokens.md,
                  vertical: SpacingTokens.sm,
                ),
              ),
              child: Text(l10n.accountEditLinkAccountUnavailable),
            ),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              l10n.accountEditLinkAccountUnavailableHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: OpenBudgetPalette.fgSecondaryFor(theme),
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            if (!account.isClosed)
              OutlinedButton(
                onPressed: isSubmitting.value
                    ? null
                    : () => _closeAccount(context, ref),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error.withAlpha(80)),
                ),
                child: Text(l10n.accountCloseButton),
              ),
            if (account.isClosed) ...[
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
                foregroundColor: colorScheme.error,
                backgroundColor: colorScheme.errorContainer.withAlpha(120),
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
    try {
      await ref
          .read(accountActionsProvider.notifier)
          .updateAccount(
            accountId: account.id?.toString() ?? '',
            budgetId: budgetId,
            isClosed: true,
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
          .updateAccount(
            accountId: account.id?.toString() ?? '',
            budgetId: budgetId,
            isClosed: false,
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
    final colorScheme = Theme.of(context).colorScheme;
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
    var deleted = account;
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
      deleted = await ref
          .read(accountActionsProvider.notifier)
          .deleteAccount(accountId: accountId, budgetId: budgetId);
    } on Object catch (_) {
      // If the server deleted the row but the client failed to decode/handle the
      // delete response, treat this as success by verifying the account no longer
      // exists in the latest list.
      var deletedOnServer = false;
      try {
        final accounts = await ref.read(accountListProvider(budgetId).future);
        deletedOnServer = !accounts.any(
          (item) => item.id?.toString() == accountId,
        );
      } on Object {
        deletedOnServer = false;
      }

      if (deletedOnServer) {
        deleted = account;
      } else {
        if (context.mounted) {
          showAppToast(
            context,
            message: l10n.accountDeleteError,
            variant: AppToastVariant.error,
          );
        }
        return;
      }
    }

    if (!context.mounted) return;

    showAppToast(
      context,
      message: l10n.accountDeleteSuccess,
      variant: AppToastVariant.success,
      actionLabel: l10n.undoAction,
      onAction: () => _undoDelete(context, ref, deleted, l10n),
    );

    navigator.pop();
    if (onDeleted != null) {
      try {
        onDeleted!.call();
      } on Object {
        // Ignore navigation callback errors. The delete already succeeded.
      }
    }
  }

  void _undoDelete(
    BuildContext context,
    WidgetRef ref,
    Account deleted,
    AppLocalizations l10n,
  ) {
    ref
        .read(accountActionsProvider.notifier)
        .undoDeleteAccount(deletedAccount: deleted, budgetId: budgetId)
        .then((_) {
          if (!context.mounted) return;
          showAppToast(
            context,
            message: l10n.undoDeleteSuccess,
            variant: AppToastVariant.success,
          );
        })
        .catchError((_) {
          if (!context.mounted) return;
          showAppToast(
            context,
            message: l10n.undoDeleteError,
            variant: AppToastVariant.error,
          );
        });
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

String _formatInitialAmount({required int cents, required int decimals}) {
  final divisor = _pow10(decimals);
  final amount = cents / divisor;
  if (decimals == 0) return amount.toStringAsFixed(0);

  final fixed = amount.toStringAsFixed(decimals);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}

double _pow10(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
