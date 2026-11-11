import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/home/providers/entity_detail_provider.dart';
import 'package:openbudget_app/src/features/payees/providers/payee_list_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/duplicate_check_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/utils/money_input.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class AddIncomeScreen extends HookConsumerWidget {
  const AddIncomeScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final descriptionController = useTextEditingController();
    final amountController = useTextEditingController();
    final memoController = useTextEditingController();
    final isSubmitting = useState(false);
    final selectedDate = useState(DateTime.now());
    final selectedPayeeId = useState<String?>(null);
    final duplicateCount = useState(0);
    final entityAsync = ref.watch(entityDetailProvider(entityId));
    final accountsAsync = ref.watch(accountListProvider(entityId));
    final payeesAsync = ref.watch(payeeListProvider(entityId));
    final theme = Theme.of(context);
    final palette = theme.ob;
    final baseCurrency = entityAsync.value?.baseCurrencyCode ?? '';
    final accounts = accountsAsync.value ?? const <Account>[];
    final onBudgetAccounts = accounts
        .where((a) => a.onBudget && a.closedAt == null)
        .toList(growable: false);
    final allAccounts = accounts
        .where((a) => a.closedAt == null)
        .toList(growable: false);
    final defaultAccountId = useState(
      onBudgetAccounts.firstOrNull?.id?.toString() ??
          allAccounts.firstOrNull?.id?.toString() ??
          '',
    );
    final selectedAccount = allAccounts
        .where((a) => a.id?.toString() == defaultAccountId.value)
        .firstOrNull;
    final budgetCurrency =
        selectedAccount?.currencyCode ?? baseCurrency;

    useValueListenable(amountController);

    Future<void> checkDuplicates() async {
      if (defaultAccountId.value.isEmpty) return;
      final amountMinor = parseMoneyInput(
        amountController.text,
        decimals: currencyDecimalsForCode(budgetCurrency),
      );
      if (amountMinor == null || amountMinor <= 0) {
        duplicateCount.value = 0;
        return;
      }
      try {
        final duplicates = await ref.read(
          duplicateCheckProvider(
            defaultAccountId.value,
            amountMinor,
            selectedDate.value,
          ).future,
        );
        duplicateCount.value = duplicates.length;
      } on Exception catch (_) {
        duplicateCount.value = 0;
      }
    }

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

    final amountDecimals = currencyDecimalsForCode(budgetCurrency);
    final amountText = amountController.text.trim();
    final amountMinor = parseMoneyInput(amountText, decimals: amountDecimals);
    final amountError = moneyInputError(
      amountText,
      decimals: amountDecimals,
      message: l10n.amountInvalidFormat(amountDecimals),
    );
    final formattedAmount = amountMinor == null || amountMinor == 0
        ? formatMinorForCode(0, budgetCurrency)
        : formatMinorForCode(amountMinor, budgetCurrency);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 88,
        leading: Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () =>
                context.goNamed(planRoute, pathParameters: {'entityId': entityId}),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n.dialogCancel),
          ),
        ),
        title: Text(l10n.addTransactionSheetTitle),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            SpacingTokens.md,
            SpacingTokens.sm,
            SpacingTokens.md,
            SpacingTokens.xl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ObCard(
                  tone: ObTone.funded,
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ModeChip(
                              label: l10n.addTransactionExpense,
                              icon: OpenBudgetIcons.outflow,
                              selected: false,
                              tone: ObTone.overspent,
                              onTap: () => context.goNamed(
                                addExpenseRoute,
                                pathParameters: {'entityId': entityId},
                              ),
                            ),
                          ),
                          Expanded(
                            child: _ModeChip(
                              label: l10n.addTransactionIncome,
                              icon: OpenBudgetIcons.inflow,
                              selected: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      Focus(
                        onFocusChange: (hasFocus) {
                          if (!hasFocus) {
                            unawaited(checkDuplicates());
                          }
                        },
                        child: TextField(
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textAlign: TextAlign.center,
                          style:
                              ObTextStyles.amount(
                                theme.textTheme.displaySmall,
                              ).copyWith(
                                color: palette.funded,
                                fontWeight: FontWeight.w800,
                              ),
                          decoration: InputDecoration(
                            labelText: l10n.transactionAmountLabel,
                            errorText: amountError,
                            prefixIcon: const ObFieldIcon(
                              data: OpenBudgetIcons.money,
                            ),
                            border: InputBorder.none,
                            filled: false,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: formatMinorForCode(0, budgetCurrency),
                            hintStyle:
                                ObTextStyles.amount(
                                  theme.textTheme.displaySmall,
                                ).copyWith(
                                  color: palette.funded,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        l10n.transactionAddIncome,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: palette.ink,
                        ),
                      ),
                      if (amountText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: ObAmount(
                            formattedAmount,
                            tone: ObTone.funded,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                ObCard(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                                    (value != null && value.isNotEmpty)
                                    ? value
                                    : null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      _ReadOnlyRow(
                        icon: OpenBudgetIcons.savings,
                        label: l10n.transactionCategoryLabel,
                        value: l10n.budgetReadyToAssign,
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      _AccountPickerRow(
                        accounts: allAccounts,
                        selectedAccountId: defaultAccountId.value,
                        onChanged: (value) => defaultAccountId.value = value,
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const SkribbleIcon(
                          data: OpenBudgetIcons.calendar,
                        ),
                        title: Text(l10n.transactionDateLabel),
                        subtitle: Text(_formatDate(selectedDate.value)),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate.value,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            selectedDate.value = picked;
                            await checkDuplicates();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SpacingTokens.md),
                ObCard(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ObTextField(
                        controller: descriptionController,
                        labelText: l10n.transactionDescriptionLabel,
                        prefixIcon: const ObFieldIcon(
                          data: OpenBudgetIcons.document,
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.sm),
                      TextField(
                        controller: memoController,
                        decoration: InputDecoration(
                          labelText: l10n.transactionMemoLabel,
                          prefixIcon: const ObFieldIcon(
                            data: OpenBudgetIcons.note,
                          ),
                          hintText: l10n.transactionMemoHint,
                        ),
                        maxLines: 2,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
                if (duplicateCount.value > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: SpacingTokens.sm),
                    child: ObCard(
                      tone: ObTone.overspent,
                      padding: const EdgeInsets.all(SpacingTokens.sm),
                      child: Row(
                        children: [
                          SkribbleIcon(
                            data: OpenBudgetIcons.warning,
                            color: palette.overspent,
                            size: 20,
                          ),
                          const SizedBox(width: SpacingTokens.sm),
                          Expanded(
                            child: Text(
                              l10n.duplicateWarning(duplicateCount.value),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: palette.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: SpacingTokens.md),
                ObFilledButton(
                  onPressed: isSubmitting.value
                      ? null
                      : () async {
                          final description = descriptionController.text.trim();
                          final amountText = amountController.text.trim();
                          if (defaultAccountId.value.isEmpty) return;
                          final amountMinor = parseMoneyInput(
                            amountText,
                            decimals: currencyDecimalsForCode(budgetCurrency),
                          );
                          if (description.isEmpty ||
                              amountMinor == null ||
                              amountMinor <= 0) {
                            return;
                          }

                          isSubmitting.value = true;
                          final router = GoRouter.of(context);
                          try {
                            final memoText = memoController.text.trim();
                            await ref
                                .read(transactionActionsProvider.notifier)
                                .create(
                                  entityId: entityId,
                                  input: TransactionInput(
                                    accountId: UuidValue.fromString(
                                      defaultAccountId.value,
                                    ),
                                    date: DateTime.utc(
                                      selectedDate.value.year,
                                      selectedDate.value.month,
                                      selectedDate.value.day,
                                    ),
                                    amountMinor: amountMinor,
                                    description: description,
                                    memo: memoText.isEmpty ? null : memoText,
                                    lines: const [],
                                  ),
                                );
                            if (!context.mounted) return;
                            showAppToast(
                              context,
                              message: l10n.transactionSuccess,
                              variant: AppToastVariant.success,
                            );
                            router.goNamed(
                              planRoute,
                              pathParameters: {'entityId': entityId},
                            );
                          } on Exception catch (_) {
                            isSubmitting.value = false;
                            if (!context.mounted) return;
                            showAppToast(
                              context,
                              message: l10n.transactionError,
                              variant: AppToastVariant.error,
                            );
                          }
                        },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSubmitting.value)
                        WiredLoadingIndicator(size: 18, color: palette.mutedInk)
                      else
                        const SkribbleIcon(
                          data: OpenBudgetIcons.checkCircle,
                          size: 18,
                        ),
                      const SizedBox(width: SpacingTokens.xs),
                      Text(l10n.transactionSave),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class _ModeChip extends HookWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.selected,
    this.tone = ObTone.neutral,
    this.onTap,
  });

  final String label;
  final WiredSvgIconData icon;
  final bool selected;
  final ObTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    final foreground = selected ? palette.onAction : palette.hue(tone);

    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          customBorder: const ObRoughBorder(),
          child: Container(
            margin: const EdgeInsets.all(2),
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
            decoration: ObRoughDecoration(
              color: selected ? palette.action : null,
              outline: palette.quietPen,
              radius: RadiusTokens.sm,
              strokeWidth: 1.6,
              seed: 31,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SkribbleIcon(data: icon, size: 18, color: foreground),
                const SizedBox(width: SpacingTokens.xs),
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: foreground,
                    ),
                    overflow: TextOverflow.ellipsis,
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

class _ReadOnlyRow extends HookWidget {
  const _ReadOnlyRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final WiredSvgIconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Row(
      children: [
        SkribbleIcon(data: icon, size: 20, color: palette.brand),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: palette.mutedInk,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The account picker row for income: any open account, its currency shown.
class _AccountPickerRow extends HookWidget {
  const _AccountPickerRow({
    required this.accounts,
    required this.selectedAccountId,
    required this.onChanged,
  });

  final List<Account> accounts;
  final String selectedAccountId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Row(
      children: [
        SkribbleIcon(data: OpenBudgetIcons.bank, size: 20, color: palette.brand),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: ObDropdown<String>(
            value: selectedAccountId,
            items: [
              for (final account in accounts)
                DropdownMenuItem<String>(
                  value: account.id?.toString() ?? '',
                  child: Text('${account.name} (${account.currencyCode})'),
                ),
            ],
            labelText: AppLocalizations.of(context).transactionAccountLabel,
            onChanged: (value) {
              if (value != null && value.isNotEmpty) onChanged(value);
            },
          ),
        ),
      ],
    );
  }
}
