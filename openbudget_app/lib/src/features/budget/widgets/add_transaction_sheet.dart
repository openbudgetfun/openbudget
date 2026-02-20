import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/theme/ynab_palette.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AddTransactionSheet extends HookWidget {
  const AddTransactionSheet({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: YnabPalette.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              l10n.addTransactionSheetTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            _ActionTile(
              icon: Icons.arrow_downward_rounded,
              label: l10n.addTransactionIncome,
              color: YnabPalette.progressGreen,
              onTap: () {
                Navigator.of(context).pop();
                context.goNamed(
                  addIncomeRoute,
                  pathParameters: {'id': budgetId},
                );
              },
            ),
            const SizedBox(height: SpacingTokens.sm),
            _ActionTile(
              icon: Icons.arrow_upward_rounded,
              label: l10n.addTransactionExpense,
              color: YnabPalette.negative,
              onTap: () {
                Navigator.of(context).pop();
                context.goNamed(
                  addExpenseRoute,
                  pathParameters: {'id': budgetId},
                );
              },
            ),
            const SizedBox(height: SpacingTokens.sm),
            _ActionTile(
              icon: Icons.swap_horiz_rounded,
              label: l10n.addTransactionTransfer,
              color: YnabPalette.accentBlue,
              onTap: () {
                Navigator.of(context).pop();
                context.goNamed(
                  createTransferRoute,
                  pathParameters: {'id': budgetId},
                );
              },
            ),
            const SizedBox(height: SpacingTokens.md),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends HookWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      color: YnabPalette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        side: const BorderSide(color: YnabPalette.divider),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(18),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: YnabPalette.mutedText,
        ),
      ),
    );
  }
}
