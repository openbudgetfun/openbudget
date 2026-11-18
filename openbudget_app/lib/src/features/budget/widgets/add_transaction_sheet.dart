import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum AddTransactionAction { income, expense, transfer }

class AddTransactionSheet extends HookWidget {
  const AddTransactionSheet({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;

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
              decoration: ObRoughDecoration(
                color: palette.line,
                radius: 4,
                seed: 101,
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            Text(
              l10n.addTransactionSheetTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: palette.ink,
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            _ActionTile(
              icon: OpenBudgetIcons.inflow,
              label: l10n.addTransactionIncome,
              tone: ObTone.funded,
              onTap: () {
                Navigator.of(context).pop(AddTransactionAction.income);
              },
            ),
            const SizedBox(height: SpacingTokens.sm),
            _ActionTile(
              icon: OpenBudgetIcons.outflow,
              label: l10n.addTransactionExpense,
              tone: ObTone.overspent,
              onTap: () {
                Navigator.of(context).pop(AddTransactionAction.expense);
              },
            ),
            const SizedBox(height: SpacingTokens.sm),
            _ActionTile(
              icon: OpenBudgetIcons.transfer,
              label: l10n.addTransactionTransfer,
              tone: ObTone.brand,
              onTap: () {
                Navigator.of(context).pop(AddTransactionAction.transfer);
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
    required this.tone,
    required this.onTap,
  });

  final WiredSvgIconData icon;
  final String label;
  final ObTone tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;

    return ObCard(
      onTap: onTap,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: ObRoughDecoration(
            color: palette.wash(tone),
            radius: 10,
            strokeWidth: 1.4,
            seed: 103,
          ),
          child: SkribbleIcon(data: icon, color: palette.hue(tone)),
        ),
        title: Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: palette.ink,
          ),
        ),
        trailing: SkribbleIcon(
          data: OpenBudgetIcons.chevronRight,
          color: palette.mutedInk,
        ),
      ),
    );
  }
}
