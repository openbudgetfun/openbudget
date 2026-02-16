import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_provider.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class CreateBudgetScreen extends HookConsumerWidget {
  const CreateBudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final nameController = useTextEditingController();
    final selectedCurrency = useState(CurrencyCode.usd);
    final isSubmitting = useState(false);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.watch(createBudgetProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createBudgetTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(RadiusTokens.lg),
                  ),
                  child: Icon(
                    Icons.savings_rounded,
                    size: 32,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(
                  l10n.createBudgetTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SpacingTokens.lg),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: l10n.createBudgetNameLabel,
                            prefixIcon: const Icon(Icons.edit_outlined),
                          ),
                          textInputAction: TextInputAction.done,
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        DropdownButtonFormField<String>(
                          initialValue: selectedCurrency.value.code,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.currency_exchange),
                          ),
                          isExpanded: true,
                          items: CurrencyCode.values
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.code,
                                  child: Text('${c.symbol} ${c.displayName}'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            selectedCurrency.value = CurrencyCode.values
                                .firstWhere((c) => c.code == value);
                          },
                        ),
                        const SizedBox(height: SpacingTokens.lg),
                        FilledButton(
                          onPressed: isSubmitting.value
                              ? null
                              : () async {
                                  final name = nameController.text.trim();
                                  if (name.isEmpty) return;

                                  isSubmitting.value = true;
                                  try {
                                    final budgetId = await ref
                                        .read(createBudgetProvider.notifier)
                                        .create(
                                          name: name,
                                          currency: selectedCurrency.value,
                                        );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l10n.createBudgetSuccess,
                                          ),
                                        ),
                                      );
                                      context.go('/budgets/$budgetId');
                                    }
                                  } on Exception catch (_) {
                                    isSubmitting.value = false;
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.createBudgetError),
                                          backgroundColor: colorScheme.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                          child: isSubmitting.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.createBudgetButton),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
