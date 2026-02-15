import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
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
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));
    final summaryAsync = ref.watch(budgetSummaryProvider(budgetId));

    final envelopeItems = <DropdownMenuItem<dynamic>>[
      DropdownMenuItem<String>(
        value: '',
        child: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(l10n.transactionUnassigned),
        ),
      ),
    ];

    if (summaryAsync.hasValue) {
      for (final catEnv in summaryAsync.value!.categories) {
        for (final envelope in catEnv.envelopes) {
          envelopeItems.add(
            DropdownMenuItem<String>(
              value: envelope.id?.toString() ?? '',
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text('${catEnv.category.name} / ${envelope.name}'),
              ),
            ),
          );
        }
      }
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
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: WiredCard(
              height: 420,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.transactionAddExpense,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    WiredInput(
                      controller: descriptionController,
                      hintText: l10n.transactionDescriptionLabel,
                    ),
                    const SizedBox(height: 16),
                    WiredInput(
                      controller: amountController,
                      hintText: l10n.transactionAmountLabel,
                    ),
                    const SizedBox(height: 16),
                    WiredCombo(
                      value: selectedEnvelopeId.value ?? '',
                      items: envelopeItems,
                      onChanged: (value) {
                        final envId = value as String? ?? '';
                        selectedEnvelopeId.value = envId.isEmpty ? null : envId;

                        if (envId.isNotEmpty && summaryAsync.hasValue) {
                          for (final catEnv in summaryAsync.value!.categories) {
                            for (final envelope in catEnv.envelopes) {
                              if (envelope.id?.toString() == envId) {
                                selectedCategoryId.value = catEnv.category.id
                                    ?.toString();
                              }
                            }
                          }
                        } else {
                          selectedCategoryId.value = null;
                        }
                        return true;
                      },
                    ),
                    const SizedBox(height: 24),
                    WiredButton(
                      onPressed: isSubmitting.value
                          ? () {}
                          : () async {
                              final description = descriptionController.text
                                  .trim();
                              final amountText = amountController.text.trim();
                              final amount = double.tryParse(amountText) ?? 0;
                              if (description.isEmpty || amount <= 0) return;

                              final budget = budgetAsync.value;
                              if (budget == null) return;

                              final currency = CurrencyCode.values.firstWhere(
                                (c) => c.code == budget.currencyCode,
                                orElse: () => CurrencyCode.usd,
                              );
                              final amountCents =
                                  (amount * _pow10(currency.decimals)).round();

                              isSubmitting.value = true;
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
                                    );
                                if (context.mounted) {
                                  context.go('/budgets/$budgetId');
                                }
                              } on Exception catch (_) {
                                isSubmitting.value = false;
                              }
                            },
                      child: Text(
                        isSubmitting.value
                            ? l10n.transactionSubmitting
                            : l10n.transactionSave,
                      ),
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
