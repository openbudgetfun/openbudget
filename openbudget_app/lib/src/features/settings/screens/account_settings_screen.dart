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
    const unavailableHint = 'Currently unavailable in this build.';

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
                    'Account settings are read-only in this build. '
                    'Profile, login method, and security updates are unavailable.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            'Profile',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            'First Name',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          const TextField(
            enabled: false,
            decoration: InputDecoration(hintText: 'Unavailable in this build'),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(l10n.settingsAccountEmail, style: theme.textTheme.titleMedium),
          const SizedBox(height: SpacingTokens.sm),
          const Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: null,
              child: Text('Save (Unavailable)'),
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
            'Login Methods',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(
            'Email & Password',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(l10n.settingsAccountEmail, style: theme.textTheme.bodyMedium),
          const SizedBox(height: SpacingTokens.sm),
          const FilledButton.tonal(
            onPressed: null,
            child: Text('Change Email & Password'),
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
            'Apple and Google login method changes are unavailable in this build.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            'Two-Step Verification',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'Increase your OpenBudget login security by adding a second method of login.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: SpacingTokens.sm),
          const FilledButton.tonal(onPressed: null, child: Text('Set Up')),
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
            'Delete Account',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'Account deletion is currently unavailable in this build. '
            'Open this page to review status and availability.',
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
            child: const Text('Delete Account'),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'No account data can be removed from this app yet.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: OpenBudgetPalette.fgSecondaryFor(theme),
            ),
          ),
        ],
      ),
    );
  }
}
