import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/settings/providers/account_deletion_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Lets a signed-in person permanently delete their account and data.
///
/// When the deletion succeeds the auth state becomes unauthenticated and the
/// router's redirect takes the person to the sign-in screen.
class DeleteAccountScreen extends HookConsumerWidget {
  const DeleteAccountScreen({required this.entityId, super.key});

  static const deleteButtonKey = Key('delete-account-button');
  static const confirmButtonKey = Key('delete-account-confirm-button');
  static const errorKey = Key('delete-account-error');

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final deletion = ref.watch(accountDeletionProvider);
    final error = deletion.error;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountDeleteTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.md,
          SpacingTokens.md,
          SpacingTokens.md,
          SpacingTokens.xl,
        ),
        children: [
          ObCard(
            tone: ObTone.overspent,
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkribbleIcon(
                  data: OpenBudgetIcons.info,
                  size: 20,
                  color: palette.hue(ObTone.overspent),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    l10n.deleteAccountNotice,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: palette.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            l10n.deleteAccountWhatIsDeletedTitle,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: SpacingTokens.sm),
          for (final line in [
            l10n.deleteAccountWhatIsDeletedPlans,
            l10n.deleteAccountWhatIsDeletedLinks,
            l10n.deleteAccountWhatIsDeletedProfile,
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
              child: Text(line, style: theme.textTheme.bodyMedium),
            ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            l10n.deleteAccountSubscriptionHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.mutedInk,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          if (error != null) ...[
            Text(
              switch (error) {
                ValidationException() => l10n.deleteAccountSubscriptionActive,
                _ => l10n.deleteAccountFailed,
              },
              key: errorKey,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: palette.overspent,
              ),
            ),
            const SizedBox(height: SpacingTokens.sm),
          ],
          FilledButton(
            key: deleteButtonKey,
            style: FilledButton.styleFrom(
              backgroundColor: palette.overspentWash,
              foregroundColor: palette.overspent,
            ),
            onPressed: deletion.isLoading
                ? null
                : () => _confirmAndDelete(context, ref),
            child: Text(l10n.deleteAccountButton),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAccountConfirmTitle),
        content: Text(l10n.deleteAccountConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            key: confirmButtonKey,
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: palette.overspentWash,
              foregroundColor: palette.overspent,
            ),
            child: Text(l10n.deleteAccountConfirmButton),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(accountDeletionProvider.notifier).deleteAccount();
  }
}
