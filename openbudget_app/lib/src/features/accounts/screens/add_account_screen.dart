import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_actions_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AddAccountScreen extends HookConsumerWidget {
  const AddAccountScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final nameController = useTextEditingController();
    final balanceController = useTextEditingController(text: '0.00');
    final isSubmitting = useState(false);
    final selectedType = useState('checking');
    final onBudget = useState(true);
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));
    final theme = Theme.of(context);

    final accountTypes = [
      ('checking', l10n.accountTypeChecking, Icons.account_balance_rounded),
      ('savings', l10n.accountTypeSavings, Icons.savings_rounded),
      ('creditCard', l10n.accountTypeCreditCard, Icons.credit_card_rounded),
      ('cash', l10n.accountTypeCash, Icons.payments_rounded),
      ('investment', l10n.accountTypeInvestment, Icons.trending_up_rounded),
      ('other', l10n.accountTypeOther, Icons.account_balance_wallet_rounded),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/budgets/$budgetId/accounts'),
        ),
        title: Text(l10n.accountAddTitle),
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
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(RadiusTokens.md),
                        ),
                        child: Icon(
                          Icons.account_balance_rounded,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      l10n.accountAddTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: l10n.accountNameLabel,
                        prefixIcon: const Icon(Icons.label_outlined),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      l10n.accountTypeLabel,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: SpacingTokens.xs),
                    Wrap(
                      spacing: SpacingTokens.xs,
                      runSpacing: SpacingTokens.xs,
                      children: accountTypes.map((type) {
                        final isSelected = selectedType.value == type.$1;
                        return ChoiceChip(
                          label: Text(type.$2),
                          avatar: Icon(type.$3, size: 18),
                          selected: isSelected,
                          onSelected: (_) => selectedType.value = type.$1,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    TextField(
                      controller: balanceController,
                      decoration: InputDecoration(
                        labelText: l10n.accountBalanceLabel,
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    SwitchListTile(
                      title: Text(l10n.accountOnBudgetLabel),
                      subtitle: Text(l10n.accountOnBudgetHint),
                      value: onBudget.value,
                      onChanged: (v) => onBudget.value = v,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    FilledButton(
                      onPressed: isSubmitting.value
                          ? null
                          : () async {
                              final name = nameController.text.trim();
                              final balanceText = balanceController.text.trim();
                              final balance = double.tryParse(balanceText) ?? 0;
                              if (name.isEmpty) return;

                              final budget = budgetAsync.value;
                              if (budget == null) return;

                              final currency = CurrencyCode.values.firstWhere(
                                (c) => c.code == budget.currencyCode,
                                orElse: () => CurrencyCode.usd,
                              );
                              final balanceCents =
                                  (balance * _pow10(currency.decimals)).round();

                              isSubmitting.value = true;
                              final messenger = ScaffoldMessenger.of(context);
                              final router = GoRouter.of(context);
                              try {
                                await ref
                                    .read(accountActionsProvider.notifier)
                                    .createAccount(
                                      name: name,
                                      accountType: selectedType.value,
                                      balanceCents: balanceCents,
                                      currencyCode: budget.currencyCode,
                                      budgetId: budgetId,
                                      onBudget: onBudget.value,
                                      sortOrder: 0,
                                    );
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.accountCreateSuccess),
                                  ),
                                );
                                router.go('/budgets/$budgetId/accounts');
                              } on Exception catch (_) {
                                isSubmitting.value = false;
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.accountCreateError),
                                    backgroundColor: theme.colorScheme.error,
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
                          : Text(l10n.accountAddButton),
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
