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
    final passwordController = useTextEditingController();
    final showPassword = useState(false);
    final deleted = useState(false);
    final passwordValue = useState('');

    final canDelete = passwordValue.value.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: OpenBudgetPalette.appBackground,
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.appBackground,
        title: const Text('Delete Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: deleted.value
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "We're sorry to see you go!",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    'Your account and data will be completely deleted shortly. '
                    'In rare cases this may take up to an hour.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    'If you change your mind, you can sign back up after the '
                    'deletion process completes.',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              )
            : ListView(
                children: [
                  Text(
                    "We're sorry to see you go!",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    'If you are sure you want to delete your OpenBudget account, '
                    'confirm your password below. Your account and plan data '
                    'will be permanently deleted.',
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    l10n.settingsAccountEmail,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    'Confirm Password',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  TextField(
                    controller: passwordController,
                    obscureText: !showPassword.value,
                    onChanged: (value) => passwordValue.value = value,
                    decoration: InputDecoration(
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: showPassword.value,
                            onChanged: (value) =>
                                showPassword.value = value ?? false,
                          ),
                          const Text('Show'),
                          const SizedBox(width: SpacingTokens.sm),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.error,
                    ),
                    onPressed: canDelete ? () => deleted.value = true : null,
                    child: const Text('Delete Account'),
                  ),
                ],
              ),
      ),
    );
  }
}
