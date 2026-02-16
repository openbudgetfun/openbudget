import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_last_envelope_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AddExpenseScreen extends HookConsumerWidget {
  const AddExpenseScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final descriptionController = useTextEditingController();
    final amountController = useTextEditingController();
    final isSubmitting = useState(false);
    final selectedEnvelopeId = useState<String?>(null);
    final selectedCategoryId = useState<String?>(null);
    final selectedPayeeId = useState<String?>(null);
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));
    final summaryAsync = ref.watch(budgetSummaryProvider(budgetId));
    final payeesAsync = ref.watch(payeeListProvider(budgetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Build payee dropdown items.
    final payeeItems = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(value: '', child: Text(l10n.payeeNone)),
    ];
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

    // Build envelope dropdown items.
    final envelopeItems = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(
        value: '',
        child: Text(l10n.transactionUnassigned),
      ),
    ];
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

    // Helper to update selectedCategoryId when envelope changes.
    void updateCategoryForEnvelope(String envId) {
      if (envId.isNotEmpty && summaryAsync.hasValue) {
        for (final catEnv in summaryAsync.value!.categories) {
          for (final envelope in catEnv.envelopes) {
            if (envelope.id?.toString() == envId) {
              selectedCategoryId.value = catEnv.category.id?.toString();
              return;
            }
          }
        }
      }
      selectedCategoryId.value = null;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/budgets/$budgetId'),
        ),
        title: Text(l10n.transactionAddExpense),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: ColorTokens.error.withAlpha(30),
                          borderRadius: BorderRadius.circular(RadiusTokens.md),
                        ),
                        child: const Icon(
                          Icons.arrow_upward_rounded,
                          color: ColorTokens.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      l10n.transactionAddExpense,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n.transactionDescriptionLabel,
                        prefixIcon: const Icon(Icons.description_outlined),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    TextField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: l10n.transactionAmountLabel,
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPayeeId.value ?? '',
                      items: payeeItems,
                      onChanged: (value) async {
                        final payId = value ?? '';
                        selectedPayeeId.value = payId.isEmpty ? null : payId;

                        // Auto-suggest last-used envelope for this payee.
                        if (payId.isNotEmpty) {
                          final lastEnvelope = await ref.read(
                            payeeLastEnvelopeProvider(payId, budgetId).future,
                          );
                          if (lastEnvelope != null) {
                            selectedEnvelopeId.value = lastEnvelope;
                            updateCategoryForEnvelope(lastEnvelope);
                          }
                        }
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.store_rounded),
                        labelText: l10n.payeeLabel,
                      ),
                      isExpanded: true,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    DropdownButtonFormField<String>(
                      initialValue: selectedEnvelopeId.value ?? '',
                      items: envelopeItems,
                      onChanged: (value) {
                        final envId = value ?? '';
                        selectedEnvelopeId.value = envId.isEmpty ? null : envId;
                        updateCategoryForEnvelope(envId);
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.mail_outlined),
                        labelText: l10n.transactionUnassigned,
                      ),
                      isExpanded: true,
                    ),
                    if (selectedPayeeId.value != null &&
                        selectedEnvelopeId.value != null)
                      Padding(
                        padding: const EdgeInsets.only(top: SpacingTokens.xs),
                        child: Text(
                          l10n.payeeAutoEnvelopeHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    const SizedBox(height: SpacingTokens.lg),
                    FilledButton(
                      onPressed: isSubmitting.value
                          ? null
                          : () async {
                              final description = descriptionController.text
                                  .trim();
                              final amountText = amountController.text.trim();
                              final amount = double.tryParse(amountText) ?? 0;
                              if (description.isEmpty || amount <= 0) {
                                return;
                              }

                              final budget = budgetAsync.value;
                              if (budget == null) return;

                              final currency = CurrencyCode.values.firstWhere(
                                (c) => c.code == budget.currencyCode,
                                orElse: () => CurrencyCode.usd,
                              );
                              final amountCents =
                                  (amount * _pow10(currency.decimals)).round();

                              isSubmitting.value = true;
                              final messenger = ScaffoldMessenger.of(context);
                              final router = GoRouter.of(context);
                              try {
                                await ref
                                    .read(transactionActionsProvider.notifier)
                                    .addExpense(
                                      description: description,
                                      amountCents: amountCents,
                                      currencyCode: budget.currencyCode,
                                      budgetId: budgetId,
                                      date: DateTime.now(),
                                      envelopeId: selectedEnvelopeId.value,
                                      categoryId: selectedCategoryId.value,
                                      payeeId: selectedPayeeId.value,
                                    );
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.transactionSuccess),
                                  ),
                                );
                                router.go('/budgets/$budgetId');
                              } on Exception catch (_) {
                                isSubmitting.value = false;
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.transactionError),
                                    backgroundColor: colorScheme.error,
                                  ),
                                );
                              }
                            },
                      child: isSubmitting.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.transactionSave),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double _pow10(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
