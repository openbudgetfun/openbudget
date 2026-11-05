import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/tax/widgets/tax_category_row.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class EditTransactionDialog extends HookConsumerWidget {
  const EditTransactionDialog({
    required this.transaction,
    required this.budgetId,
    required this.currencyCode,
    super.key,
  });

  final Transaction transaction;
  final String budgetId;
  final CurrencyCode currencyCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final descriptionController = useTextEditingController(
      text: transaction.description,
    );
    final amountController = useTextEditingController(
      text: (transaction.amountCents.abs() / _pow10(currencyCode.decimals))
          .toStringAsFixed(currencyCode.decimals),
    );
    final memoController = useTextEditingController(
      text: transaction.memo ?? '',
    );
    final selectedDate = useState(transaction.transactionDate);
    final selectedPayeeId = useState<String?>(transaction.payeeId?.toString());
    final selectedEnvelopeId = useState<String?>(
      transaction.envelopeId?.toString(),
    );
    final isSubmitting = useState(false);
    final isIncome = transaction.amountCents > 0;

    final payeesAsync = ref.watch(payeeListProvider(budgetId));
    final summaryAsync = ref.watch(budgetSummaryProvider(budgetId));

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

    return AlertDialog(
      title: Text(l10n.transactionEditTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ObTextField(
              controller: descriptionController,
              labelText: l10n.transactionDescriptionLabel,
              prefixIcon: const SkribbleIcon(
                data: OpenBudgetIcons.document,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            ObTextField(
              controller: amountController,
              labelText: l10n.transactionAmountLabel,
              prefixIcon: const SkribbleIcon(data: OpenBudgetIcons.money),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const SkribbleIcon(data: OpenBudgetIcons.calendar),
              title: Text(
                '${selectedDate.value.year}-'
                '${selectedDate.value.month.toString().padLeft(2, '0')}-'
                '${selectedDate.value.day.toString().padLeft(2, '0')}',
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate.value,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  selectedDate.value = picked;
                }
              },
            ),
            const SizedBox(height: SpacingTokens.md),
            Row(
              children: [
                SkribbleIcon(
                  data: OpenBudgetIcons.person,
                  size: 20,
                  color: palette.brand,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Expanded(
                  child: ObDropdown<String>(
                    value: selectedPayeeId.value ?? '',
                    items: payeeItems,
                    labelText: l10n.payeeLabel,
                    onChanged: (value) {
                      selectedPayeeId.value =
                          (value != null && value.isNotEmpty) ? value : null;
                    },
                  ),
                ),
              ],
            ),
            if (!isIncome) ...[
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
                      value: selectedEnvelopeId.value ?? '',
                      items: envelopeItems,
                      labelText: l10n.splitEnvelopeLabel,
                      onChanged: (value) {
                        selectedEnvelopeId.value =
                            (value != null && value.isNotEmpty) ? value : null;
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: SpacingTokens.md),
            TextField(
              controller: memoController,
              decoration: InputDecoration(
                labelText: l10n.transactionMemoLabel,
                hintText: l10n.transactionMemoHint,
                prefixIcon: const SkribbleIcon(data: OpenBudgetIcons.note),
              ),
              maxLines: 2,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: SpacingTokens.sm),
            TransactionTaxCategoryRow(
              budgetId: budgetId,
              transaction: transaction,
              currencyCode: currencyCode.code,
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
          isLoading: isSubmitting.value,
          loadingLabel: l10n.dialogSave,
          onPressed: () async {
            final description = descriptionController.text.trim();
            final amountText = amountController.text.trim();
            final amount = double.tryParse(amountText) ?? 0;
            if (description.isEmpty || amount <= 0) return;

            final amountCents = (amount * _pow10(currencyCode.decimals))
                .round();
            final signedAmount = isIncome ? amountCents : -amountCents;
            final memo = memoController.text.trim();

            isSubmitting.value = true;
            final navigator = Navigator.of(context);
            try {
              await ref
                  .read(transactionActionsProvider.notifier)
                  .updateTransaction(
                    transactionId: transaction.id?.toString() ?? '',
                    budgetId: budgetId,
                    description: description,
                    amountCents: signedAmount,
                    transactionDate: selectedDate.value,
                    payeeId: selectedPayeeId.value,
                    envelopeId: selectedEnvelopeId.value,
                    memo: memo.isNotEmpty ? memo : null,
                  );
              if (!context.mounted) return;
              showAppToast(
                context,
                message: l10n.transactionEditSuccess,
                variant: AppToastVariant.success,
              );
              navigator.pop();
            } on Exception catch (_) {
              isSubmitting.value = false;
              if (!context.mounted) return;
              showAppToast(
                context,
                message: l10n.transactionEditError,
                variant: AppToastVariant.error,
              );
            }
          },
          child: Text(l10n.dialogSave),
        ),
      ],
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
