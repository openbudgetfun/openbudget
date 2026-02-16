import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transaction_rules/providers/rule_actions_provider.dart';
import 'package:openbudget_app/src/features/transaction_rules/providers/rule_list_provider.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class RuleListScreen extends HookConsumerWidget {
  const RuleListScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
      appBar: AppBar(title: Text(l10n.transactionRulesTitle)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRuleDialog(context, ref),
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
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.xl),
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
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(SpacingTokens.md),
            itemCount: rules.length,
            itemBuilder: (context, index) {
              final rule = rules[index];
              final ruleId = rule.id?.toString() ?? '';
              final payeeName =
                  payeeNames[rule.payeeId.toString()] ?? 'Unknown';
              final envelopeName =
                  envelopeNames[rule.targetEnvelopeId.toString()] ?? 'Unknown';

              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.rule_rounded,
                    color: rule.enabled
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  title: Text(payeeName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(envelopeName),
                      if (!rule.enabled)
                        Text(
                          l10n.transactionRulesDisabled,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.error,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: rule.enabled,
                        onChanged: (enabled) => _toggleRule(
                          context,
                          ref,
                          ruleId: ruleId,
                          enabled: enabled,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: colorScheme.error,
                        ),
                        onPressed: () =>
                            _deleteRule(context, ref, ruleId: ruleId),
                      ),
                    ],
                  ),
                  isThreeLine: !rule.enabled,
                ),
              );
            },
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
