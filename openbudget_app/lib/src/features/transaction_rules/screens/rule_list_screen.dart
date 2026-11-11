import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transaction_rules/providers/rule_actions_provider.dart';
import 'package:openbudget_app/src/features/transaction_rules/providers/rule_list_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

enum RuleViewFilter { all, enabled, disabled }

/// The key on the empty state shown when no rules exist yet.
const ruleListEmptyKey = Key('rule-list-empty');

class RuleListScreen extends HookConsumerWidget {
  const RuleListScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final viewFilter = useState(RuleViewFilter.all);
    final rulesAsync = ref.watch(ruleListProvider(entityId));
    final payeesAsync = ref.watch(payeeListProvider(entityId));
    final summaryAsync = ref.watch(budgetSummaryProvider(entityId));

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
      appBar: AppBar(
        leading: IconButton(
          icon: const SkribbleIcon(data: OpenBudgetIcons.back),
          tooltip: l10n.transactionsBack,
          onPressed: () =>
              context.goNamed(moreRoute, pathParameters: {'entityId': entityId}),
        ),
        title: Text(l10n.transactionRulesTitle),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRuleDialog(context, ref),
        tooltip: l10n.transactionRulesAddButton,
        child: const SkribbleIcon(data: OpenBudgetIcons.add),
      ),
      body: rulesAsync.when(
        loading: () => Center(
          child: ObLoadingPanel(label: l10n.rulesLoading),
        ),
        error: (error, _) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            child: ObStatePanel.problem(
              title: l10n.transactionRulesLoadError,
              message: error.toString(),
              action: ObStateAction(
                label: l10n.homeRetry,
                onPressed: () => ref.invalidate(ruleListProvider(entityId)),
              ),
            ),
          ),
        ),
        data: (rules) {
          if (rules.isEmpty) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SpacingTokens.md),
                child: ObStatePanel.empty(
                  key: ruleListEmptyKey,
                  title: l10n.transactionRulesEmptyTitle,
                  message: l10n.transactionRulesEmptySubtitle,
                  doodle: WiredDoodleKind.sparkle,
                  tone: ObTone.review,
                ),
              ),
            );
          }

          final enabledCount = rules.where((rule) => rule.enabled).length;
          final disabledCount = rules.length - enabledCount;
          final filteredRules = rules
              .where(
                (rule) => switch (viewFilter.value) {
                  RuleViewFilter.all => true,
                  RuleViewFilter.enabled => rule.enabled,
                  RuleViewFilter.disabled => !rule.enabled,
                },
              )
              .toList();

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
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _RuleFilterChip(
                      label: l10n.transactionFilterAll,
                      icon: OpenBudgetIcons.list,
                      selected: viewFilter.value == RuleViewFilter.all,
                      onTap: () => viewFilter.value = RuleViewFilter.all,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    _RuleFilterChip(
                      label: l10n.transactionRulesEnabled,
                      icon: OpenBudgetIcons.checkCircle,
                      selected: viewFilter.value == RuleViewFilter.enabled,
                      onTap: () => viewFilter.value = RuleViewFilter.enabled,
                    ),
                    const SizedBox(width: SpacingTokens.sm),
                    _RuleFilterChip(
                      label: l10n.transactionRulesDisabled,
                      icon: OpenBudgetIcons.circle,
                      selected: viewFilter.value == RuleViewFilter.disabled,
                      onTap: () => viewFilter.value = RuleViewFilter.disabled,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              if (filteredRules.isEmpty)
                ObStatePanel.empty(
                  title: l10n.transactionNoResults,
                  doodle: WiredDoodleKind.cloud,
                  tone: ObTone.review,
                ),
              ...filteredRules.map((rule) {
                final ruleId = rule.id?.toString() ?? '';
                final payeeName =
                    payeeNames[rule.payeeId.toString()] ??
                    l10n.transactionsUnknownPayee;
                final envelopeName =
                    envelopeNames[rule.targetEnvelopeId.toString()] ??
                    l10n.transactionsUnknownEnvelope;
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
    try {
      await ref
          .read(ruleActionsProvider.notifier)
          .toggleRule(ruleId: ruleId, enabled: enabled, entityId: entityId);
    } on Exception catch (_) {
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.transactionRulesToggleError,
        variant: AppToastVariant.error,
      );
    }
  }

  Future<void> _deleteRule(
    BuildContext context,
    WidgetRef ref, {
    required String ruleId,
  }) async {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteConfirmTitle),
        content: Text(l10n.deleteConfirmMessage),
        actions: [
          ObTextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.dialogCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: palette.overspent,
              foregroundColor: palette.onAction,
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
          .deleteRule(ruleId: ruleId, entityId: entityId);
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.transactionRulesDeleteSuccess,
        variant: AppToastVariant.success,
      );
    } on Exception catch (_) {
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.transactionRulesDeleteError,
        variant: AppToastVariant.error,
      );
    }
  }

  Future<void> _showAddRuleDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<_AddRuleResult>(
      context: context,
      builder: (ctx) => _AddRuleDialog(entityId: entityId),
    );

    if (result == null || !context.mounted) return;

    final l10n = AppLocalizations.of(context);

    try {
      await ref
          .read(ruleActionsProvider.notifier)
          .createRule(
            entityId: entityId,
            payeeId: result.payeeId,
            targetEnvelopeId: result.envelopeId,
          );
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.transactionRulesCreateSuccess,
        variant: AppToastVariant.success,
      );
    } on Exception catch (_) {
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.transactionRulesCreateError,
        variant: AppToastVariant.error,
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
    final palette = theme.ob;
    return ObCard(
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: ObRoughDecoration(
                  color: palette.wash(ObTone.review),
                  outline: palette.quietPen,
                  radius: 20,
                  strokeWidth: 1.6,
                  seed: 17,
                ),
                child: Center(
                  child: SkribbleIcon(
                    data: OpenBudgetIcons.rule,
                    size: 20,
                    color: palette.review,
                  ),
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.transactionRulesTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      l10n.transactionRulesTotalCount(totalRules),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          Row(
            children: [
              Expanded(
                child: _RuleMetric(
                  label: l10n.transactionRulesEnabled,
                  value: '$enabledRules',
                  tone: ObTone.funded,
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Expanded(
                child: _RuleMetric(
                  label: l10n.transactionRulesDisabled,
                  value: '$disabledRules',
                  tone: ObTone.overspent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RuleMetric extends HookWidget {
  const _RuleMetric({
    required this.label,
    required this.value,
    required this.tone,
  });

  final String label;
  final String value;
  final ObTone tone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.sm,
        vertical: SpacingTokens.sm,
      ),
      decoration: ObRoughDecoration(
        color: palette.wash(tone),
        outline: palette.quietPen,
        radius: RadiusTokens.sm,
        strokeWidth: 1.6,
        seed: 19,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(color: palette.ink),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              color: palette.hue(tone),
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
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final WiredSvgIconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = Theme.of(context).ob;
    return ChoiceChip(
      avatar: SkribbleIcon(
        data: icon,
        size: 18,
        color: selected ? palette.ink : palette.mutedInk,
      ),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
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
    final palette = theme.ob;
    return ObCard(
      margin: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.xs,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: ObRoughDecoration(
            color: palette.wash(enabled ? ObTone.brand : ObTone.neutral),
            outline: palette.quietPen,
            radius: 20,
            strokeWidth: 1.6,
            seed: 29,
          ),
          child: Center(
            child: SkribbleIcon(
              data: OpenBudgetIcons.rule,
              size: 20,
              color: enabled ? palette.brand : palette.mutedInk,
            ),
          ),
        ),
        title: Text(payeeName, style: theme.textTheme.titleSmall),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              envelopeName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.mutedInk,
              ),
            ),
            const SizedBox(height: SpacingTokens.xs),
            ObToneChip(
              label: enabled
                  ? l10n.transactionRulesEnabled
                  : l10n.transactionRulesDisabled,
              tone: enabled ? ObTone.funded : ObTone.overspent,
              icon: SkribbleIcon(
                data: enabled
                    ? OpenBudgetIcons.checkCircle
                    : OpenBudgetIcons.circle,
                size: 14,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch.adaptive(value: enabled, onChanged: onToggle),
            IconButton(
              icon: const SkribbleIcon(data: OpenBudgetIcons.delete),
              color: palette.overspent,
              tooltip: l10n.deleteConfirmButton,
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
  const _AddRuleDialog({required this.entityId});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final payeesAsync = ref.watch(payeeListProvider(entityId));
    final summaryAsync = ref.watch(budgetSummaryProvider(entityId));
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
            Row(
              children: [
                SkribbleIcon(
                  data: OpenBudgetIcons.store,
                  size: 20,
                  color: palette.brand,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: ObDropdown<String>(
                    value: selectedPayeeId.value,
                    labelText: l10n.transactionRulesPayeeLabel,
                    items: payeeItems,
                    onChanged: (value) => selectedPayeeId.value =
                        (value?.isEmpty ?? true) ? null : value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.md),
            Row(
              children: [
                SkribbleIcon(
                  data: OpenBudgetIcons.envelope,
                  size: 20,
                  color: palette.brand,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: ObDropdown<String>(
                    value: selectedEnvelopeId.value,
                    labelText: l10n.transactionRulesEnvelopeLabel,
                    items: envelopeItems,
                    onChanged: (value) => selectedEnvelopeId.value =
                        (value?.isEmpty ?? true) ? null : value,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        ObTextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.dialogCancel),
        ),
        ObFilledButton(
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
