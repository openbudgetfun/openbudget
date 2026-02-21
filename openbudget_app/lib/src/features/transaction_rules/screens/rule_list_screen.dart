import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transaction_rules/providers/rule_actions_provider.dart';
import 'package:openbudget_app/src/features/transaction_rules/providers/rule_list_provider.dart';
import 'package:openbudget_app/src/theme/openbudget_palette.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum RuleViewFilter { all, enabled, disabled }

class RuleListScreen extends HookConsumerWidget {
  const RuleListScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewFilter = useState(RuleViewFilter.all);
    final rulesAsync = ref.watch(ruleListProvider(budgetId));
    final payeesAsync = ref.watch(payeeListProvider(budgetId));
    final summaryAsync = ref.watch(budgetSummaryProvider(budgetId));

    // Build lookup maps.
    final payeeNames = <String, String>{};
    if (payeesAsync.hasValue) {
      for (final payee in payeesAsync.value!) {
        final id = payee.id?.toString();
        if (id != null) payeeNames[id] = payee.name;
      }
    }

    final envelopeNames = <String, String>{};
    if (summaryAsync.hasValue) {
      for (final catEnv in summaryAsync.value!.categories) {
        for (final envelope in catEnv.envelopes) {
          final id = envelope.id?.toString();
          if (id != null) {
            envelopeNames[id] = '${catEnv.category.name} / ${envelope.name}';
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: OpenBudgetPalette.appBackground,
      appBar: AppBar(
        backgroundColor: OpenBudgetPalette.appBackground,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(l10n.transactionRulesTitle),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRuleDialog(context, ref),
        backgroundColor: OpenBudgetPalette.accentBlue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: rulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Text(
            l10n.transactionRulesLoadError,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.error,
            ),
          ),
        ),
        data: (rules) {
          if (rules.isEmpty) {
            return Center(
              child: Card(
                margin: const EdgeInsets.all(SpacingTokens.lg),
                color: OpenBudgetPalette.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(RadiusTokens.md),
                  side: const BorderSide(color: OpenBudgetPalette.divider),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.rule_rounded,
                        size: 64,
                        color: colorScheme.onSurfaceVariant.withAlpha(100),
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      Text(
                        l10n.transactionRulesEmptyTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        l10n.transactionRulesEmptySubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final enabledCount = rules.where((rule) => rule.enabled).length;
          final disabledCount = rules.length - enabledCount;
          final filteredRules = rules.where((rule) {
            return switch (viewFilter.value) {
              RuleViewFilter.all => true,
              RuleViewFilter.enabled => rule.enabled,
              RuleViewFilter.disabled => !rule.enabled,
            };
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            children: [
              _RuleSummaryCard(
                totalRules: rules.length,
                enabledRules: enabledCount,
                disabledRules: disabledCount,
              ),
              const SizedBox(height: SpacingTokens.md),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _RuleFilterChip(
                      label: l10n.transactionFilterAll,
                      selected: viewFilter.value == RuleViewFilter.all,
                      onTap: () => viewFilter.value = RuleViewFilter.all,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    _RuleFilterChip(
                      label: l10n.transactionRulesEnabled,
                      selected: viewFilter.value == RuleViewFilter.enabled,
                      onTap: () => viewFilter.value = RuleViewFilter.enabled,
                      color: OpenBudgetPalette.progressGreen,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    _RuleFilterChip(
                      label: l10n.transactionRulesDisabled,
                      selected: viewFilter.value == RuleViewFilter.disabled,
                      onTap: () => viewFilter.value = RuleViewFilter.disabled,
                      color: OpenBudgetPalette.negative,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              if (filteredRules.isEmpty)
                Card(
                  margin: EdgeInsets.zero,
                  color: OpenBudgetPalette.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RadiusTokens.md),
                    side: const BorderSide(color: OpenBudgetPalette.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: Text(
                      l10n.transactionNoResults,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: OpenBudgetPalette.mutedText,
                      ),
                    ),
                  ),
                ),
              ...filteredRules.map((rule) {
                final ruleId = rule.id?.toString() ?? '';
                final payeeName =
                    payeeNames[rule.payeeId.toString()] ?? 'Unknown';
                final envelopeName =
                    envelopeNames[rule.targetEnvelopeId.toString()] ??
                    'Unknown';
                return _RuleTile(
                  payeeName: payeeName,
                  envelopeName: envelopeName,
                  enabled: rule.enabled,
                  onToggle: (enabled) => _toggleRule(
                    context,
                    ref,
                    ruleId: ruleId,
                    enabled: enabled,
                  ),
                  onDelete: () => _deleteRule(context, ref, ruleId: ruleId),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleRule(
    BuildContext context,
    WidgetRef ref, {
    required String ruleId,
    required bool enabled,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    try {
      await ref
          .read(ruleActionsProvider.notifier)
          .toggleRule(ruleId: ruleId, enabled: enabled, budgetId: budgetId);
    } on Exception catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.transactionRulesToggleError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  Future<void> _deleteRule(
    BuildContext context,
    WidgetRef ref, {
    required String ruleId,
  }) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
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
            child: Text(l10n.deleteConfirmButton),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(ruleActionsProvider.notifier)
          .deleteRule(ruleId: ruleId, budgetId: budgetId);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.transactionRulesDeleteSuccess)),
      );
    } on Exception catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.transactionRulesDeleteError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  Future<void> _showAddRuleDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<_AddRuleResult>(
      context: context,
      builder: (ctx) => _AddRuleDialog(budgetId: budgetId),
    );

    if (result == null || !context.mounted) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    try {
      await ref
          .read(ruleActionsProvider.notifier)
          .createRule(
            budgetId: budgetId,
            payeeId: result.payeeId,
            targetEnvelopeId: result.envelopeId,
          );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.transactionRulesCreateSuccess)),
      );
    } on Exception catch (_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.transactionRulesCreateError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }
}

class _RuleSummaryCard extends HookWidget {
  const _RuleSummaryCard({
    required this.totalRules,
    required this.enabledRules,
    required this.disabledRules,
  });

  final int totalRules;
  final int enabledRules;
  final int disabledRules;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: OpenBudgetPalette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        side: const BorderSide(color: OpenBudgetPalette.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(SpacingTokens.md),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SpacingTokens.md),
              decoration: BoxDecoration(
                color: OpenBudgetPalette.accentPurple,
                borderRadius: BorderRadius.circular(RadiusTokens.md),
              ),
              child: Column(
                children: [
                  Text(
                    l10n.transactionRulesTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    l10n.transactionRulesTotalCount(totalRules),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: OpenBudgetPalette.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            Row(
              children: [
                Expanded(
                  child: _RuleMetric(
                    label: l10n.transactionRulesEnabled,
                    value: '$enabledRules',
                    color: OpenBudgetPalette.progressGreen,
                  ),
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: _RuleMetric(
                    label: l10n.transactionRulesDisabled,
                    value: '$disabledRules',
                    color: OpenBudgetPalette.negative,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleMetric extends HookWidget {
  const _RuleMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: OpenBudgetPalette.mutedText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleFilterChip extends HookWidget {
  const _RuleFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chipColor = color ?? OpenBudgetPalette.accentBlue;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: OpenBudgetPalette.surface,
      selectedColor: chipColor.withAlpha(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.sm),
        side: BorderSide(
          color: selected
              ? chipColor.withAlpha(130)
              : OpenBudgetPalette.divider,
        ),
      ),
      labelStyle: theme.textTheme.labelMedium?.copyWith(
        color: selected ? chipColor : OpenBudgetPalette.mutedText,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _RuleTile extends HookWidget {
  const _RuleTile({
    required this.payeeName,
    required this.envelopeName,
    required this.enabled,
    required this.onToggle,
    required this.onDelete,
  });

  final String payeeName;
  final String envelopeName;
  final bool enabled;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
      color: OpenBudgetPalette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        side: const BorderSide(color: OpenBudgetPalette.divider),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.xs,
        ),
        leading: CircleAvatar(
          backgroundColor: enabled
              ? OpenBudgetPalette.accentPurple.withAlpha(90)
              : OpenBudgetPalette.surfaceMuted,
          child: Icon(
            Icons.rule_rounded,
            color: enabled
                ? OpenBudgetPalette.accentBlue
                : OpenBudgetPalette.mutedText,
            size: 18,
          ),
        ),
        title: Text(payeeName, style: theme.textTheme.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              envelopeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: OpenBudgetPalette.mutedText,
              ),
            ),
            if (!enabled)
              Text(
                l10n.transactionRulesDisabled,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: OpenBudgetPalette.negative,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch.adaptive(
              value: enabled,
              onChanged: onToggle,
              activeTrackColor: OpenBudgetPalette.accentBlue,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: OpenBudgetPalette.negative,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddRuleResult {
  const _AddRuleResult({required this.payeeId, required this.envelopeId});
  final String payeeId;
  final String envelopeId;
}

class _AddRuleDialog extends HookConsumerWidget {
  const _AddRuleDialog({required this.budgetId});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final payeesAsync = ref.watch(payeeListProvider(budgetId));
    final summaryAsync = ref.watch(budgetSummaryProvider(budgetId));
    final selectedPayeeId = useState<String?>(null);
    final selectedEnvelopeId = useState<String?>(null);

    // Build payee items.
    final payeeItems = <DropdownMenuItem<String>>[];
    if (payeesAsync.hasValue) {
      for (final payee in payeesAsync.value!) {
        payeeItems.add(
          DropdownMenuItem<String>(
            value: payee.id?.toString() ?? '',
            child: Text(payee.name),
          ),
        );
      }
    }

    // Build envelope items.
    final envelopeItems = <DropdownMenuItem<String>>[];
    if (summaryAsync.hasValue) {
      for (final catEnv in summaryAsync.value!.categories) {
        for (final envelope in catEnv.envelopes) {
          envelopeItems.add(
            DropdownMenuItem<String>(
              value: envelope.id?.toString() ?? '',
              child: Text('${catEnv.category.name} / ${envelope.name}'),
            ),
          );
        }
      }
    }

    final canSave =
        selectedPayeeId.value != null &&
        selectedPayeeId.value!.isNotEmpty &&
        selectedEnvelopeId.value != null &&
        selectedEnvelopeId.value!.isNotEmpty;

    return AlertDialog(
      title: Text(l10n.transactionRulesAddButton),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              items: payeeItems,
              onChanged: (value) => selectedPayeeId.value =
                  (value?.isEmpty ?? true) ? null : value,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.store_rounded),
                labelText: l10n.transactionRulesPayeeLabel,
              ),
              isExpanded: true,
            ),
            const SizedBox(height: SpacingTokens.md),
            DropdownButtonFormField<String>(
              items: envelopeItems,
              onChanged: (value) => selectedEnvelopeId.value =
                  (value?.isEmpty ?? true) ? null : value,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.mail_outlined),
                labelText: l10n.transactionRulesEnvelopeLabel,
              ),
              isExpanded: true,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        FilledButton(
          onPressed: canSave
              ? () => Navigator.of(context).pop(
                  _AddRuleResult(
                    payeeId: selectedPayeeId.value!,
                    envelopeId: selectedEnvelopeId.value!,
                  ),
                )
              : null,
          child: Text(l10n.dialogSave),
        ),
      ],
    );
  }
}
