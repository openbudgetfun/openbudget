import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/providers/serverpod_client_provider.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

@visibleForTesting
Account? findTransferAccountById(List<Account> accounts, String? accountId) =>
    accounts
        .where((account) => account.id?.toString() == accountId)
        .firstOrNull;

@visibleForTesting
List<Account> transferDestinationAccounts(
  List<Account> accounts, {
  required String? fromAccountId,
}) {
  final fromAccount = findTransferAccountById(accounts, fromAccountId);
  if (fromAccount == null) return accounts;

  return accounts
      .where(
        (account) =>
            account.currencyCode == fromAccount.currencyCode &&
            account.id != fromAccount.id,
      )
      .toList();
}

@visibleForTesting
String transferCurrency(
  List<Account> accounts, {
  required String? fromAccountId,
}) {
  final fromAccount = findTransferAccountById(accounts, fromAccountId);
  return normalizeCurrencyCode(fromAccount?.currencyCode ?? '');
}

@visibleForTesting
int parseTransferAmountCents(String amountText, String currencyCode) {
  final amount = double.tryParse(amountText.trim()) ?? 0;
  return (amount * _pow10(currencyDecimalsForCode(currencyCode))).round();
}

class CreateTransferScreen extends HookConsumerWidget {
  const CreateTransferScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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
        loading: () => Center(
          child: ObLoadingPanel(label: l10n.loadingTitle),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: ObStatePanel.problem(title: l10n.accountLoadError),
          ),
        ),
        data: (accounts) {
          final selectedCurrency = transferCurrency(
            accounts,
            fromAccountId: fromAccountId.value,
          );
          final zeroAmountHint = formatCentsForCode(0, selectedCurrency);

          final toAccountOptions = transferDestinationAccounts(
            accounts,
            fromAccountId: fromAccountId.value,
          );

          if (accounts.length < 2) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(SpacingTokens.lg),
                child: ObStatePanel.empty(
                  title: l10n.transferNeedTwoAccounts,
                  doodle: WiredDoodleKind.balloon,
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
                  prefixIcon: const SkribbleIcon(
                    data: OpenBudgetIcons.outflow,
                  ),
                ),
                items: accounts
                    .map(
                      (a) => DropdownMenuItem(
                        value: a.id?.toString(),
                        child: Text('${a.name} (${a.currencyCode})'),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  fromAccountId.value = v;
                  final from = findTransferAccountById(accounts, v);
                  final currentTo = findTransferAccountById(
                    accounts,
                    toAccountId.value,
                  );
                  if (from != null &&
                      currentTo != null &&
                      (from.id == currentTo.id ||
                          from.currencyCode != currentTo.currencyCode)) {
                    toAccountId.value = null;
                  }
                },
              ),
              const SizedBox(height: SpacingTokens.md),
              DropdownButtonFormField<String>(
                initialValue: toAccountId.value,
                decoration: InputDecoration(
                  labelText: l10n.transferToAccount,
                  prefixIcon: const SkribbleIcon(data: OpenBudgetIcons.inflow),
                ),
                items: toAccountOptions
                    .map(
                      (a) => DropdownMenuItem(
                        value: a.id?.toString(),
                        child: Text('${a.name} (${a.currencyCode})'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => toAccountId.value = v,
              ),
              const SizedBox(height: SpacingTokens.md),
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText:
                      '${l10n.transactionAmountLabel} (${normalizeCurrencyCode(selectedCurrency)})',
                  prefixText: '${currencySymbolForCode(selectedCurrency)} ',
                  hintText: zeroAmountHint,
                  prefixIcon: const SkribbleIcon(
                    data: OpenBudgetIcons.coins,
                  ),
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
                  prefixIcon: const SkribbleIcon(
                    data: OpenBudgetIcons.note,
                  ),
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: SpacingTokens.md),
              ObCard(
                child: ListTile(
                  leading: const SkribbleIcon(
                    data: OpenBudgetIcons.calendar,
                  ),
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
                        accounts,
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
                    : const SkribbleIcon(data: OpenBudgetIcons.transfer),
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
    List<Account> accounts,
    ValueNotifier<String?> fromAccountId,
    ValueNotifier<String?> toAccountId,
    ValueNotifier<DateTime> selectedDate,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);

    if (fromAccountId.value == null || toAccountId.value == null) return;
    final fromAccount = findTransferAccountById(accounts, fromAccountId.value);
    final toAccount = findTransferAccountById(accounts, toAccountId.value);
    if (fromAccount == null || toAccount == null) return;
    if (fromAccountId.value == toAccountId.value) {
      showAppToast(
        context,
        message: l10n.transferSameAccountError,
        variant: AppToastVariant.error,
      );
      return;
    }

    if (fromAccount.currencyCode != toAccount.currencyCode) {
      showAppToast(
        context,
        message:
            '${l10n.transferError} (${fromAccount.currencyCode} -> ${toAccount.currencyCode})',
        variant: AppToastVariant.error,
      );
      return;
    }

    final currencyCode = normalizeCurrencyCode(fromAccount.currencyCode);
    final amountCents = parseTransferAmountCents(
      amountController.text,
      currencyCode,
    );
    if (amountCents <= 0) return;
    isSubmitting.value = true;

    try {
      final client = ref.read(serverpodClientProvider);
      await client.transaction.transfer(
        descController.text.trim(),
        amountCents,
        currencyCode,
        UuidValue.fromString(budgetId),
        UuidValue.fromString(fromAccountId.value!),
        UuidValue.fromString(toAccountId.value!),
        selectedDate.value,
      );
      ref.invalidate(accountListProvider(budgetId));
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.transferSuccess,
        variant: AppToastVariant.success,
      );
      if (context.mounted) context.pop();
    } on Exception catch (_) {
      isSubmitting.value = false;
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.transferError,
        variant: AppToastVariant.error,
      );
    }
  }
}

double _pow10(int exponent) {
  var result = 1.0;
  for (var i = 0; i < exponent; i++) {
    result *= 10;
  }
  return result;
}
