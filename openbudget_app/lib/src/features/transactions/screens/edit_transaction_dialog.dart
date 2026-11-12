import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/tax/widgets/tax_category_row.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/utils/money_input.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Edits one transaction: description, amount in the account's currency,
/// date, payee and memo. The envelope is edited on the single line; a
/// multi-line transaction keeps its lines and is edited line by line in
/// the tax sheet. A reconciled transaction rejects money edits on the
/// server.
class EditTransactionDialog extends HookConsumerWidget {
  const EditTransactionDialog({
    required this.view,
    required this.entityId,
    super.key,
  });

  final TransactionView view;
  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final palette = Theme.of(context).ob;
    final transaction = view.transaction;
    final currencyCode = view.accountCurrencyCode;
    final currencyDecimals = currencyDecimalsForCode(currencyCode);
    final descriptionController = useTextEditingController(
      text: transaction.description,
    );
    final amountController = useTextEditingController(
      text: formatMinorUnits(transaction.amountMinor.abs(), currencyDecimals),
    );
    final memoController = useTextEditingController(
      text: transaction.memo ?? '',
    );
    final selectedDate = useState(transaction.date);
    final selectedPayeeId = useState<String?>(transaction.payeeId?.toString());
    final firstLine = view.lines.isEmpty ? null : view.lines.first;
    final selectedEnvelopeId = useState<String?>(
      firstLine?.envelopeId?.toString(),
    );
    final isSubmitting = useState(false);
    final isIncome = transaction.amountMinor > 0;

    useValueListenable(amountController);
    final amountMinor = parseMoneyInput(
      amountController.text,
      decimals: currencyDecimals,
    );
    final amountError = moneyInputError(
      amountController.text,
      decimals: currencyDecimals,
      message: l10n.amountInvalidFormat(currencyDecimals),
    );

    final payeesAsync = ref.watch(payeeListProvider(entityId));
    final groupsAsync = ref.watch(budgetMonthGroupsProvider(entityId));

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

    final envelopeItems = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(
        value: '',
        child: Text(l10n.transactionUnassigned),
      ),
    ];
    if (groupsAsync.hasValue) {
      for (final group in groupsAsync.value!) {
        for (final envelope in group.envelopes) {
          final id = envelope.envelope.id?.toString() ?? '';
          if (id.isEmpty) continue;
          envelopeItems.add(
            DropdownMenuItem<String>(
              value: id,
              child: Text('${group.category.name} / ${envelope.envelope.name}'),
            ),
          );
        }
      }
    }

    // The stored selection stays selected while its list is still loading
    // (or when the envelope or payee has since been deleted).
    final storedPayeeId = selectedPayeeId.value;
    if (storedPayeeId != null &&
        !payeeItems.any((item) => item.value == storedPayeeId)) {
      payeeItems.add(
        DropdownMenuItem<String>(
          value: storedPayeeId,
          child: Text(l10n.transactionsUnknownPayee),
        ),
      );
    }
    final storedEnvelopeId = selectedEnvelopeId.value;
    if (storedEnvelopeId != null &&
        !envelopeItems.any((item) => item.value == storedEnvelopeId)) {
      envelopeItems.add(
        DropdownMenuItem<String>(
          value: storedEnvelopeId,
          child: Text(l10n.transactionsUnknownEnvelope),
        ),
      );
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
              prefixIcon: const ObFieldIcon(
                data: OpenBudgetIcons.document,
              ),
            ),
            const SizedBox(height: SpacingTokens.md),
            ObTextField(
              controller: amountController,
              labelText: l10n.transactionAmountLabel,
              errorText: amountError,
              prefixIcon: const ObFieldIcon(data: OpenBudgetIcons.money),
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
                  selectedDate.value = DateTime.utc(
                    picked.year,
                    picked.month,
                    picked.day,
                  );
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
            if (!isIncome && view.lines.length <= 1) ...[
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
                prefixIcon: const ObFieldIcon(data: OpenBudgetIcons.note),
              ),
              maxLines: 2,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: SpacingTokens.sm),
            for (final line in view.lines)
              TransactionTaxCategoryRow(
                entityId: entityId,
                transactionLineId: line.id?.toString() ?? '',
                currencyCode: currencyCode,
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
            if (description.isEmpty ||
                amountMinor == null ||
                amountMinor <= 0) {
              return;
            }

            final signedAmount = isIncome ? amountMinor : -amountMinor;
            final memo = memoController.text.trim();

            isSubmitting.value = true;
            final navigator = Navigator.of(context);
            try {
              final lines = view.lines.isEmpty
                  ? <TransactionLineInput>[
                      TransactionLineInput(amountMinor: signedAmount),
                    ]
                  : [
                      for (final line in view.lines)
                        TransactionLineInput(
                          amountMinor: line.amountMinor,
                          envelopeId: selectedEnvelopeId.value == null
                              ? null
                              : UuidValue.fromString(
                                  selectedEnvelopeId.value!,
                                ),
                          taxCategoryCode: line.taxCategoryCode,
                          businessUsePercent: line.businessUsePercent,
                          salesTaxMinor: line.salesTaxMinor,
                          memo: line.memo,
                        ),
                    ];
              await ref
                  .read(transactionActionsProvider.notifier)
                  .update(
                    transactionId: transaction.id?.toString() ?? '',
                    entityId: entityId,
                    input: TransactionInput(
                      accountId: transaction.accountId,
                      date: selectedDate.value,
                      amountMinor: signedAmount,
                      fxRate: transaction.fxRate,
                      payeeId: selectedPayeeId.value == null
                          ? null
                          : UuidValue.fromString(selectedPayeeId.value!),
                      description: description,
                      memo: memo.isNotEmpty ? memo : null,
                      lines: lines,
                    ),
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
