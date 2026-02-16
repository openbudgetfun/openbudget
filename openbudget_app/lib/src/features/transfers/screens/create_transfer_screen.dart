import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class CreateTransferScreen extends HookConsumerWidget {
  const CreateTransferScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accountsAsync = ref.watch(accountListProvider(budgetId));

    final descController = useTextEditingController(
      text: l10n.transferDefaultDescription,
    );
    final amountController = useTextEditingController();
    final fromAccountId = useState<String?>(null);
    final toAccountId = useState<String?>(null);
    final selectedDate = useState(DateTime.now());
    final isSubmitting = useState(false);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.transferTitle)),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(
            l10n.accountLoadError,
            style: TextStyle(color: colorScheme.error),
          ),
        ),
        data: (accounts) {
          if (accounts.length < 2) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.swap_horiz_rounded,
                      size: 48,
                      color: colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      l10n.transferNeedTwoAccounts,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(SpacingTokens.md),
            children: [
              DropdownButtonFormField<String>(
                initialValue: fromAccountId.value,
                decoration: InputDecoration(
                  labelText: l10n.transferFromAccount,
                  prefixIcon: const Icon(Icons.arrow_upward_rounded),
                ),
                items: accounts
                    .map(
                      (a) => DropdownMenuItem(
                        value: a.id?.toString(),
                        child: Text(a.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => fromAccountId.value = v,
              ),
              const SizedBox(height: SpacingTokens.md),
              DropdownButtonFormField<String>(
                initialValue: toAccountId.value,
                decoration: InputDecoration(
                  labelText: l10n.transferToAccount,
                  prefixIcon: const Icon(Icons.arrow_downward_rounded),
                ),
                items: accounts
                    .map(
                      (a) => DropdownMenuItem(
                        value: a.id?.toString(),
                        child: Text(a.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => toAccountId.value = v,
              ),
              const SizedBox(height: SpacingTokens.md),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: l10n.transactionAmountLabel,
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: SpacingTokens.md),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: l10n.transactionDescriptionLabel,
                  prefixIcon: const Icon(Icons.description_outlined),
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: SpacingTokens.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(l10n.transferDate),
                subtitle: Text(
                  '${selectedDate.value.year}-${selectedDate.value.month.toString().padLeft(2, '0')}-${selectedDate.value.day.toString().padLeft(2, '0')}',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate.value,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) selectedDate.value = picked;
                },
              ),
              const SizedBox(height: SpacingTokens.lg),
              FilledButton.icon(
                onPressed: isSubmitting.value
                    ? null
                    : () => _submit(
                        context,
                        ref,
                        descController,
                        amountController,
                        fromAccountId,
                        toAccountId,
                        selectedDate,
                        isSubmitting,
                      ),
                icon: isSubmitting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.swap_horiz_rounded),
                label: Text(l10n.transferButton),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    TextEditingController descController,
    TextEditingController amountController,
    ValueNotifier<String?> fromAccountId,
    ValueNotifier<String?> toAccountId,
    ValueNotifier<DateTime> selectedDate,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (fromAccountId.value == null || toAccountId.value == null) return;
    if (fromAccountId.value == toAccountId.value) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.transferSameAccountError),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    if (amount <= 0) return;

    final amountCents = (amount * 100).round();
    isSubmitting.value = true;

    try {
      final client = ref.read(serverpodClientProvider);
      await client.transaction.transfer(
        descController.text.trim(),
        amountCents,
        'USD',
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(budgetId),
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(fromAccountId.value!),
        // Serverpod API requires UuidValue which is experimental in uuid package.
        // ignore: experimental_member_use
        UuidValue.fromString(toAccountId.value!),
        selectedDate.value,
      );
      ref.invalidate(accountListProvider(budgetId));
      messenger.showSnackBar(SnackBar(content: Text(l10n.transferSuccess)));
      if (context.mounted) context.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.transferError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }
}
