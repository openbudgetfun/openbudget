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

    ref.watch(createBudgetProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.createBudgetTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: WiredCard(
              height: 350,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.createBudgetTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    WiredInput(
                      controller: nameController,
                      hintText: l10n.createBudgetNameLabel,
                    ),
                    const SizedBox(height: 16),
                    WiredCombo(
                      value: selectedCurrency.value.code,
                      items: CurrencyCode.values
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.code,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text('${c.symbol} ${c.displayName}'),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        selectedCurrency.value = CurrencyCode.values.firstWhere(
                          (c) => c.code == value,
                        );
                        return true;
                      },
                    ),
                    const SizedBox(height: 24),
                    WiredButton(
                      onPressed: isSubmitting.value
                          ? () {}
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.createBudgetSuccess),
                                    ),
                                  );
                                  context.go('/budgets/$budgetId');
                                }
                              } on Exception catch (_) {
                                isSubmitting.value = false;
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.createBudgetError),
                                      backgroundColor: ColorTokens.error,
                                    ),
                                  );
                                }
                              }
                            },
                      child: Text(
                        isSubmitting.value
                            ? l10n.createBudgetCreating
                            : l10n.createBudgetButton,
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
