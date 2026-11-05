import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class DeleteAccountScreen extends HookWidget {
  const DeleteAccountScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

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
                    l10n.deleteAccountUnavailableNotice,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: palette.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(l10n.settingsAccountEmail, style: theme.textTheme.titleSmall),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            l10n.deleteAccountUnavailableHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.mutedInk,
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: palette.overspentWash,
              foregroundColor: palette.overspent,
            ),
            onPressed: null,
            child: Text(l10n.deleteAccountUnavailableButton),
          ),
        ],
      ),
    );
  }
}
