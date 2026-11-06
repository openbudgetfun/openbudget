import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/ledger/widgets/books_entry_tile.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
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
        padding: const EdgeInsets.fromLTRB(
          SpacingTokens.md,
          SpacingTokens.md,
          SpacingTokens.md,
          SpacingTokens.xl,
        ),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _MoreTile(
                  icon: OpenBudgetIcons.sparkle,
                  label: l10n.assistantTitle,
                  onTap: () => context.pushNamed(
                    assistantRoute,
                    pathParameters: {'id': budgetId},
                  ),
                ),
                const Divider(height: 1),
                _MoreTile(
                  icon: OpenBudgetIcons.recurring,
                  label: l10n.moreRecurring,
                  onTap: () => context.goNamed(
                    recurringListRoute,
                    pathParameters: {'id': budgetId},
                  ),
                ),
                const Divider(height: 1),
                _MoreTile(
                  icon: OpenBudgetIcons.people,
                  label: l10n.morePayees,
                  onTap: () => context.goNamed(
                    payeeListRoute,
                    pathParameters: {'id': budgetId},
                  ),
                ),
                const Divider(height: 1),
                _MoreTile(
                  icon: OpenBudgetIcons.rule,
                  label: l10n.moreRules,
                  onTap: () => context.goNamed(
                    transactionRulesRoute,
                    pathParameters: {'id': budgetId},
                  ),
                ),
                const Divider(height: 1),
                _MoreTile(
                  icon: OpenBudgetIcons.upload,
                  label: l10n.moreImport,
                  onTap: () => context.goNamed(
                    importTransactionsRoute,
                    pathParameters: {'id': budgetId},
                  ),
                ),
                const Divider(height: 1),
                _MoreTile(
                  icon: OpenBudgetIcons.scale,
                  label: l10n.moreTaxes,
                  onTap: () => context.pushNamed(
                    taxOverviewRoute,
                    pathParameters: {'id': budgetId},
                  ),
                ),
                BooksEntryTile(budgetId: budgetId),
                const Divider(height: 1),
                _MoreTile(
                  icon: OpenBudgetIcons.settings,
                  label: l10n.moreSettings,
                  onTap: () => context.goNamed(
                    settingsRoute,
                    pathParameters: {'id': budgetId},
                  ),
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

  final WiredSvgIconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ListTile(
      leading: SkribbleIcon(data: icon, color: palette.ink),
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: SkribbleIcon(
        data: OpenBudgetIcons.chevronRight,
        size: 20,
        color: palette.mutedInk,
      ),
      onTap: onTap,
    );
  }
}
