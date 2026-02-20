import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class MoreScreen extends HookWidget {
  const MoreScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.moreScreenTitle)),
      body: ListView(
        padding: const EdgeInsets.all(SpacingTokens.md),
        children: [
          Card(
            child: Column(
              children: [
                _MoreTile(
                  icon: Icons.repeat_rounded,
                  label: l10n.moreRecurring,
                  onTap: () => context.go('/budgets/$budgetId/more/recurring'),
                ),
                const Divider(height: 1),
                _MoreTile(
                  icon: Icons.people_outline_rounded,
                  label: l10n.morePayees,
                  onTap: () => context.go('/budgets/$budgetId/more/payees'),
                ),
                const Divider(height: 1),
                _MoreTile(
                  icon: Icons.rule_rounded,
                  label: l10n.moreRules,
                  onTap: () => context.go('/budgets/$budgetId/more/rules'),
                ),
                const Divider(height: 1),
                _MoreTile(
                  icon: Icons.file_upload_outlined,
                  label: l10n.moreImport,
                  onTap: () => context.go('/budgets/$budgetId/more/import'),
                ),
                const Divider(height: 1),
                _MoreTile(
                  icon: Icons.settings_outlined,
                  label: l10n.moreSettings,
                  onTap: () => context.go('/budgets/$budgetId/more/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends HookWidget {
  const _MoreTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: Icon(icon, color: colorScheme.onSurfaceVariant),
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
