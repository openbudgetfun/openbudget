import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AddIncomeScreen extends HookConsumerWidget {
  const AddIncomeScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final descriptionController = useTextEditingController();
    final amountController = useTextEditingController();
    final isSubmitting = useState(false);
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/budgets/$budgetId'),
        ),
        title: Text(l10n.transactionAddIncome),
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
                          color: ColorTokens.secondary.withAlpha(30),
                          borderRadius: BorderRadius.circular(RadiusTokens.md),
                        ),
                        child: const Icon(
                          Icons.arrow_downward_rounded,
                          color: ColorTokens.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      l10n.transactionAddIncome,
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
                      textInputAction: TextInputAction.done,
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
                                    .addIncome(
                                      description: description,
                                      amountCents: amountCents,
                                      currencyCode: budget.currencyCode,
                                      budgetId: budgetId,
                                      date: DateTime.now(),
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
