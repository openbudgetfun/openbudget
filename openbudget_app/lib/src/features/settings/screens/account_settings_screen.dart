import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AccountSettingsScreen extends HookWidget {
  const AccountSettingsScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final unavailableHint = l10n.accountSettingsUnavailableHint;

    return Scaffold(
      backgroundColor: OpenBudgetPalette.bgPrimaryFor(theme),
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.bgPrimaryFor(theme),
        title: Text(l10n.settingsAccountSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: [
          Text(
            l10n.settingsAccountSettings,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Container(
            padding: const EdgeInsets.all(SpacingTokens.md),
            decoration: BoxDecoration(
              color: OpenBudgetPalette.bgSecondaryFor(theme),
              borderRadius: BorderRadius.circular(RadiusTokens.md),
              border: Border.all(
                color: OpenBudgetPalette.borderSubtleFor(theme),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 20),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: Text(
                    l10n.accountSettingsReadOnlyNotice,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            l10n.accountSettingsProfile,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            l10n.accountSettingsFirstName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          TextField(
            enabled: false,
            decoration: InputDecoration(
              hintText: l10n.accountSettingsUnavailableFieldHint,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(l10n.settingsAccountEmail, style: theme.textTheme.titleMedium),
          const SizedBox(height: SpacingTokens.sm),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: null,
              child: Text(l10n.accountSettingsSaveUnavailable),
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            unavailableHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: OpenBudgetPalette.fgSecondaryFor(theme),
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            l10n.accountSettingsLoginMethods,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            l10n.accountSettingsEmailPassword,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(l10n.settingsAccountEmail, style: theme.textTheme.bodyMedium),
          const SizedBox(height: SpacingTokens.sm),
          FilledButton.tonal(
            onPressed: null,
            child: Text(l10n.accountSettingsChangeEmailPassword),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            unavailableHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: OpenBudgetPalette.fgSecondaryFor(theme),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            l10n.accountSettingsSocialLoginUnavailable,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            l10n.accountSettingsTwoStepVerification,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            l10n.accountSettingsTwoStepHint,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: SpacingTokens.sm),
          FilledButton.tonal(
            onPressed: null,
            child: Text(l10n.accountSettingsSetUp),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            unavailableHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: OpenBudgetPalette.fgSecondaryFor(theme),
            ),
          ),
          const SizedBox(height: SpacingTokens.xl),
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            l10n.accountDeleteTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            l10n.accountSettingsDeleteSectionHint,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: SpacingTokens.md),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.errorContainer,
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: () => context.goNamed(
              deleteAccountRoute,
              pathParameters: {'id': budgetId},
            ),
            child: Text(l10n.accountDeleteTitle),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            l10n.accountSettingsDeleteUnavailableHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: OpenBudgetPalette.fgSecondaryFor(theme),
            ),
          ),
        ],
      ),
    );
  }
}
