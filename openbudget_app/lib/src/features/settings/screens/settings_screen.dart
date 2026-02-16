import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/auth/providers/auth_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/settings/providers/budget_export_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/providers/theme_mode_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: budgetAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            l10n.settingsLoadError,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ),
        data: (budget) => ListView(
          padding: const EdgeInsets.all(SpacingTokens.md),
          children: [
            _SectionTitle(title: l10n.settingsBudgetSection),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: Text(l10n.settingsBudgetName),
                    subtitle: Text(budget.name),
                    onTap: () => _showRenameBudgetDialog(context, ref, budget),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.attach_money_rounded),
                    title: Text(l10n.settingsCurrency),
                    subtitle: Text(budget.currencyCode),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            _SectionTitle(title: l10n.settingsNavigationSection),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.repeat_rounded),
                    title: Text(l10n.recurringListTitle),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed('/budgets/$budgetId/recurring'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            _SectionTitle(title: l10n.themeTitle),
            const _ThemeSelector(),
            const SizedBox(height: SpacingTokens.lg),
            _SectionTitle(title: l10n.settingsDataSection),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.download_rounded),
                    title: Text(l10n.settingsExportData),
                    subtitle: Text(l10n.settingsExportDataHint),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _exportBudgetData(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            _SectionTitle(title: l10n.settingsAccountSection),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.logout_rounded,
                      color: colorScheme.error,
                    ),
                    title: Text(
                      l10n.homeLogout,
                      style: TextStyle(color: colorScheme.error),
                    ),
                    onTap: () => _confirmLogout(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.xl),
            Center(
              child: Text(
                l10n.settingsVersion,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRenameBudgetDialog(
    BuildContext context,
    WidgetRef ref,
    Budget budget,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: budget.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.settingsRenameBudget),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.createBudgetNameLabel,
            prefixIcon: const Icon(Icons.label_outlined),
          ),
          autofocus: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => Navigator.of(ctx).pop(true),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.dialogSave),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final name = controller.text.trim();
    controller.dispose();
    if (name.isEmpty || name == budget.name) return;

    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    try {
      final client = ref.read(serverpodClientProvider);
      await client.budget.update(
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(budgetId),
        name: name,
      );
      ref.invalidate(budgetDetailProvider(budgetId));
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsRenameSuccess)),
      );
    } on Exception catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.settingsRenameError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  Future<void> _exportBudgetData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    try {
      final json = await ref
          .read(budgetExportProvider.notifier)
          .exportBudget(budgetId);
      await Clipboard.setData(ClipboardData(text: json));
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.settingsExportSuccess)),
        );
      }
    } on Exception catch (_) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.settingsExportError),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.homeLogout),
        content: Text(l10n.settingsLogoutConfirm),
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
            child: Text(l10n.homeLogout),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(authProvider.notifier).logout();
  }
}

class _ThemeSelector extends HookConsumerWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentMode = ref.watch(themeModeProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette_outlined),
                const SizedBox(width: SpacingTokens.sm),
                Text(
                  l10n.themeTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    label: Text(l10n.themeSystem),
                    icon: const Icon(Icons.brightness_auto_rounded),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    label: Text(l10n.themeLight),
                    icon: const Icon(Icons.light_mode_rounded),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    label: Text(l10n.themeDark),
                    icon: const Icon(Icons.dark_mode_rounded),
                  ),
                ],
                selected: {currentMode},
                onSelectionChanged: (selected) => ref
                    .read(themeModeProvider.notifier)
                    .setThemeMode(selected.first),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends HookWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: SpacingTokens.sm,
        bottom: SpacingTokens.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
