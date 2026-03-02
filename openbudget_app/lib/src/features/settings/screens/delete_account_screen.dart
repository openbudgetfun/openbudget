import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class DeleteAccountScreen extends HookWidget {
  const DeleteAccountScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: OpenBudgetPalette.bgPrimaryFor(theme),
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(theme),
        title: Text(l10n.accountDeleteTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: ListView(
          children: [
            Text(
              l10n.accountDeleteTitle,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            Container(
              padding: const EdgeInsets.all(SpacingTokens.md),
              decoration: BoxDecoration(
                color: OpenBudgetPalette.bgSecondaryFor(theme),
                borderRadius: BorderRadius.circular(RadiusTokens.md),
                border: Border.all(color: theme.colorScheme.errorContainer),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: SpacingTokens.sm),
                  Expanded(
                    child: Text(
                      l10n.deleteAccountUnavailableNotice,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            Text(l10n.settingsAccountEmail, style: theme.textTheme.titleMedium),
            const SizedBox(height: SpacingTokens.md),
            Text(
              l10n.deleteAccountUnavailableHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: OpenBudgetPalette.fgSecondaryFor(theme),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: null,
              child: Text(l10n.deleteAccountUnavailableButton),
            ),
          ],
        ),
      ),
    );
  }
}
