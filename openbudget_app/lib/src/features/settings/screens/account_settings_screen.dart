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
    final firstNameController = useTextEditingController(text: 'Alex');
    final hasChanges = useState(false);

    return Scaffold(
      backgroundColor: OpenBudgetPalette.appBackground,
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.appBackground,
        title: const Text('Account Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: [
          Text(
            'Account Settings',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(l10n.settingsAccountEmail, style: theme.textTheme.titleMedium),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            'First Name',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            'We use your first name to personalize your OpenBudget experience.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: SpacingTokens.sm),
          TextField(
            controller: firstNameController,
            decoration: const InputDecoration(hintText: 'First name'),
            onChanged: (value) => hasChanges.value = value.trim() != 'Alex',
          ),
          const SizedBox(height: SpacingTokens.sm),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: hasChanges.value
                  ? () {
                      hasChanges.value = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved account profile')),
                      );
                    }
                  : null,
              child: const Text('Save'),
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
          FilledButton.tonal(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email/password updates coming soon'),
              ),
            ),
            child: const Text('Change Email & Password'),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            'Use OpenBudget on desktop to modify Apple or Google login methods.',
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
          FilledButton.tonal(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Two-step setup coming soon')),
            ),
            child: const Text('Set Up'),
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
            'Delete your account if you no longer wish to use OpenBudget. '
            'This permanently removes account and plan data.',
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
        ],
      ),
    );
  }
}
