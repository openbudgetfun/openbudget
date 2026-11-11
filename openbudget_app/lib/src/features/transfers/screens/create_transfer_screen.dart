import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_month_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/transaction_actions_provider.dart';
import 'package:openbudget_app/src/features/transactions/widgets/fx_rate_line.dart';
import 'package:openbudget_app/src/providers/fx_rate_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/utils/money_input.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Cross-currency and cross-entity transfers: From and To pickers list every
/// account in every entity; different currencies get Sent and Received
/// fields with a live implied rate and "Use today's rate". An envelope
/// appears only when the money leaves the envelope plan.
class CreateTransferScreen extends HookConsumerWidget {
  const CreateTransferScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final accountsAsync = ref.watch(accountListAllProvider);
    final groupsAsync = ref.watch(budgetMonthGroupsProvider(entityId));

    final descController = useTextEditingController(
      text: l10n.transferDefaultDescription,
    );
    final fromAmountController = useTextEditingController();
    final toAmountController = useTextEditingController();
    final fromAccountId = useState<String?>(null);
    final toAccountId = useState<String?>(null);
    final selectedDate = useState(DateTime.now());
    final selectedEnvelopeId = useState<String?>(null);
    final isSubmitting = useState(false);

    useListenable(fromAmountController);
    useListenable(toAmountController);

    final allAccounts = accountsAsync.value ?? const <Account>[];
    final fromAccount = allAccounts
        .where((a) => a.id?.toString() == fromAccountId.value)
        .firstOrNull;
    final toAccount = allAccounts
        .where((a) => a.id?.toString() == toAccountId.value)
        .firstOrNull;
    final isCrossCurrency =
        fromAccount != null &&
        toAccount != null &&
        fromAccount.currencyCode != toAccount.currencyCode;
    final leavesThePlan =
        fromAccount != null &&
        toAccount != null &&
        (fromAccount.onBudget &&
            (!toAccount.onBudget ||
                toAccount.entityId != fromAccount.entityId));
    final sameAccount = fromAccountId.value != null &&
        fromAccountId.value == toAccountId.value;

    final fromDecimals = currencyDecimalsForCode(
      fromAccount?.currencyCode ?? '',
    );
    final toDecimals = currencyDecimalsForCode(toAccount?.currencyCode ?? '');
    final fromMinor = parseMoneyInput(
      fromAmountController.text,
      decimals: fromDecimals,
    );
    final toMinor = isCrossCurrency
        ? parseMoneyInput(toAmountController.text, decimals: toDecimals)
        : fromMinor;
    final fromError = moneyInputError(
      fromAmountController.text,
      decimals: fromDecimals,
      message: l10n.amountInvalidFormat(fromDecimals),
    );
    final toError = isCrossCurrency
        ? moneyInputError(
            toAmountController.text,
            decimals: toDecimals,
            message: l10n.amountInvalidFormat(toDecimals),
          )
        : null;

    final canSubmit =
        fromAccount != null &&
        toAccount != null &&
        !sameAccount &&
        fromMinor != null &&
        fromMinor > 0 &&
        toMinor != null && toMinor > 0;

    Future<void> useMarketRate() async {
      // "Use today's rate": quote the market rate and fill Received. The
      // server re-prices from its own stored rate when the field is empty.
      final from = fromAccount;
      final to = toAccount;
      if (from == null || to == null) return;
      if (fromMinor == null || fromMinor <= 0) return;
      try {
        final quote = await ref.read(
          fxQuoteProvider(
            from.currencyCode,
            to.currencyCode,
            selectedDate.value,
          ).future,
        );
        final rate = ExactDecimal.tryParse(quote.rate);
        if (rate == null) return;
        final converted = convertMinorUnits(
          amountMinor: fromMinor,
          exchangeRate: rate,
          transactionExponent: fromDecimals,
          functionalExponent: toDecimals,
        );
        toAmountController.text = formatMinorUnits(converted, toDecimals);
      } on Exception {
        // The FX line shows the server's explanation.
      }
    }

    Future<void> submit() async {
      if (!canSubmit || isSubmitting.value) return;
      isSubmitting.value = true;
      final router = GoRouter.of(context);
      final messenger = ScaffoldMessenger.of(context);
      try {
        final fromId = fromAccount.id;
        final toId = toAccount.id;
        if (fromId == null || toId == null) return;
        final input = TransferInput(
          fromAccountId: fromId,
          toAccountId: toId,
          date: DateTime.utc(
            selectedDate.value.year,
            selectedDate.value.month,
            selectedDate.value.day,
          ),
          fromAmountMinor: fromMinor,
          toAmountMinor:
              isCrossCurrency && toAmountController.text.trim().isNotEmpty
              ? toMinor
              : null,
          useMarketRate:
              isCrossCurrency && toAmountController.text.trim().isEmpty,
          envelopeId: leavesThePlan && selectedEnvelopeId.value != null
              ? UuidValue.fromString(selectedEnvelopeId.value!)
              : null,
          memo: descController.text.trim().isEmpty
              ? null
              : descController.text.trim(),
        );
        await ref
            .read(transactionActionsProvider.notifier)
            .createTransfer(input: input, entityId: entityId);
        if (!context.mounted) return;
        showAppToast(
          context,
          message: l10n.transferSuccess,
          variant: AppToastVariant.success,
        );
        router.goNamed(
          accountListRoute,
          pathParameters: {'entityId': entityId},
        );
      } on Exception catch (_) {
        isSubmitting.value = false;
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.transferError)),
        );
      }
    }

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
        data: (_) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(SpacingTokens.md),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AccountPicker(
                      label: l10n.transferFrom,
                      accounts: allAccounts,
                      selectedAccountId: fromAccountId.value,
                      excludeAccountId: toAccountId.value,
                      onChanged: (value) => fromAccountId.value = value,
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    _AccountPicker(
                      label: l10n.transferTo,
                      accounts: allAccounts,
                      selectedAccountId: toAccountId.value,
                      excludeAccountId: fromAccountId.value,
                      onChanged: (value) => toAccountId.value = value,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    ObCard(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (!isCrossCurrency)
                            TextField(
                              controller: fromAmountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: l10n.transferAmountLabel,
                                errorText: fromError,
                                prefixText:
                                    '${fromAccount!.currencyCode} ',
                              ),
                            )
                          else ...[
                            TextField(
                              controller: fromAmountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: l10n.transferSentLabel,
                                errorText: fromError,
                                prefixText: '${fromAccount.currencyCode} ',
                              ),
                            ),
                            const SizedBox(height: SpacingTokens.sm),
                            TextField(
                              controller: toAmountController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: l10n.transferReceivedLabel,
                                errorText: toError,
                                prefixText: '${toAccount.currencyCode} ',
                              ),
                            ),
                            if (fromMinor != null && fromMinor > 0)
                              FxRateLine(
                                fromCurrencyCode: fromAccount.currencyCode,
                                toCurrencyCode: toAccount.currencyCode,
                                date: selectedDate.value,
                                amountMinor: fromMinor,
                                onSetRate: useMarketRate,
                              ),
                            TextButton(
                              onPressed: useMarketRate,
                              child: Text(l10n.transferUseTodayRate),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const SkribbleIcon(data: OpenBudgetIcons.calendar),
                      title: Text(l10n.transactionDateLabel),
                      subtitle: Text(
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
                    if (leavesThePlan) ...[
                      const SizedBox(height: SpacingTokens.sm),
                      ObDropdown<String>(
                        value: selectedEnvelopeId.value ?? '',
                        items: [
                          DropdownMenuItem<String>(
                            value: '',
                            child: Text(l10n.transactionUnassigned),
                          ),
                          if (groupsAsync.hasValue)
                            for (final group in groupsAsync.value!)
                              for (final envelope in group.envelopes)
                                DropdownMenuItem<String>(
                                  value:
                                      envelope.envelope.id?.toString() ?? '',
                                  child: Text(
                                    '${group.category.name} / '
                                    '${envelope.envelope.name}',
                                  ),
                                ),
                        ],
                        labelText: l10n.transferEnvelopeLeavesPlan,
                        onChanged: (value) =>
                            selectedEnvelopeId.value = value,
                      ),
                    ],
                    const SizedBox(height: SpacingTokens.md),
                    ObTextField(
                      controller: descController,
                      labelText: l10n.transactionDescriptionLabel,
                      prefixIcon: const ObFieldIcon(
                        data: OpenBudgetIcons.document,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    ObFilledButton(
                      onPressed: canSubmit && !isSubmitting.value
                          ? submit
                          : null,
                      child: Text(l10n.transferButton),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Row(
                      children: [
                        SkribbleIcon(
                          data: OpenBudgetIcons.info,
                          size: 14,
                          color: palette.mutedInk,
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Expanded(
                          child: Text(
                            l10n.transferCrossEntityHint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: palette.mutedInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// One account picker row listing every account in every entity; the
/// entity name shows as the subtitle for cross-entity transfers.
class _AccountPicker extends HookWidget {
  const _AccountPicker({
    required this.label,
    required this.accounts,
    required this.selectedAccountId,
    required this.excludeAccountId,
    required this.onChanged,
  });

  final String label;
  final List<Account> accounts;
  final String? selectedAccountId;
  final String? excludeAccountId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ObDropdown<String>(
      value: selectedAccountId ?? '',
      items: [
        for (final account in accounts)
          if (account.id?.toString() != excludeAccountId)
            DropdownMenuItem<String>(
              value: account.id?.toString() ?? '',
              child: Text(
                '${account.name} (${account.currencyCode})',
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
            ),
      ],
      labelText: label,
      onChanged: onChanged,
    );
  }
}
