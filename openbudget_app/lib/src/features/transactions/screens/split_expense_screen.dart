import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_summary_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/split_transaction_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/utils/money_input.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class SplitExpenseScreen extends HookConsumerWidget {
  const SplitExpenseScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final descriptionController = useTextEditingController();
    final totalAmountController = useTextEditingController();
    final isSubmitting = useState(false);
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));
    final summaryAsync = ref.watch(budgetSummaryProvider(budgetId));
    final theme = Theme.of(context);
    final palette = theme.ob;
    final budgetCurrency =
        budgetAsync.whenOrNull(
          data: (budget) => normalizeCurrencyCode(budget.currencyCode),
        ) ??
        '';

    // Dynamic list of splits
    final splitControllers = useState<List<_SplitData>>([
      _SplitData(),
      _SplitData(),
    ]);

    final envelopeOptions = <_EnvelopeOption>[];
    if (summaryAsync.hasValue) {
      for (final catEnv in summaryAsync.value!.categories) {
        for (final envelope in catEnv.envelopes) {
          envelopeOptions.add(
            _EnvelopeOption(
              id: envelope.id?.toString() ?? '',
              label: '${catEnv.category.name} / ${envelope.name}',
            ),
          );
        }
      }
    }

    // Compute remaining amount
    final currencyDecimals = currencyDecimalsForCode(budgetCurrency);
    final previewTotalCents =
        parseMoneyInput(
          totalAmountController.text,
          decimals: currencyDecimals,
        ) ??
        0;
    final totalError = moneyInputError(
      totalAmountController.text,
      decimals: currencyDecimals,
      message: l10n.amountInvalidFormat(currencyDecimals),
    );
    final previewSplitTotalCents = splitControllers.value.fold<int>(
      0,
      (sum, split) =>
          sum +
          (parseMoneyInput(
                split.amountController.text,
                decimals: currencyDecimals,
              ) ??
              0),
    );
    final remainingCents = previewTotalCents - previewSplitTotalCents;
    final isBalanced = remainingCents == 0;
    final remainingTone = isBalanced ? ObTone.funded : ObTone.underfunded;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const SkribbleIcon(data: OpenBudgetIcons.back),
          tooltip: l10n.transactionsBack,
          onPressed: () =>
              context.goNamed(planRoute, pathParameters: {'id': budgetId}),
        ),
        title: Text(l10n.splitTransactionTitle),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SpacingTokens.md),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: ObCard(
              padding: const EdgeInsets.all(SpacingTokens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: ObRoughDecoration(
                        color: palette.wash(ObTone.review),
                        outline: palette.quietPen,
                        seed: 41,
                      ),
                      child: Center(
                        child: SkribbleIcon(
                          data: OpenBudgetIcons.split,
                          color: palette.review,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  Text(
                    l10n.splitTransactionTitle,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  ObTextField(
                    controller: descriptionController,
                    labelText: l10n.transactionDescriptionLabel,
                    prefixIcon: const SkribbleIcon(
                      data: OpenBudgetIcons.document,
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  ObTextField(
                    controller: totalAmountController,
                    labelText: l10n.transactionAmountLabel,
                    errorText: totalError,
                    prefixIcon: const SkribbleIcon(
                      data: OpenBudgetIcons.money,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) {
                      // Force rebuild to update remaining
                      splitControllers.value = [...splitControllers.value];
                    },
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  // Remaining to assign indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpacingTokens.md,
                      vertical: SpacingTokens.sm,
                    ),
                    decoration: ObRoughDecoration(
                      color: palette.wash(remainingTone),
                      outline: palette.quietPen,
                      radius: RadiusTokens.sm,
                      strokeWidth: 1.6,
                      seed: 43,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.splitRemainingLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: palette.ink,
                          ),
                        ),
                        ObAmount(
                          formatCentsForCode(remainingCents, budgetCurrency),
                          tone: remainingTone,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  // Split rows
                  ...splitControllers.value.asMap().entries.map(
                    (entry) => _SplitRow(
                      key: ValueKey(entry.value.key),
                      index: entry.key,
                      splitData: entry.value,
                      currencyDecimals: currencyDecimals,
                      envelopeOptions: envelopeOptions,
                      canRemove: splitControllers.value.length > 2,
                      onRemove: () {
                        final list = [...splitControllers.value];
                        list[entry.key].dispose();
                        list.removeAt(entry.key);
                        splitControllers.value = list;
                      },
                      onAmountChanged: () {
                        splitControllers.value = [...splitControllers.value];
                      },
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.xs),
                  OutlinedButton(
                    onPressed: () {
                      splitControllers.value = [
                        ...splitControllers.value,
                        _SplitData(),
                      ];
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SkribbleIcon(
                          data: OpenBudgetIcons.add,
                          size: 18,
                        ),
                        const SizedBox(width: SpacingTokens.xs),
                        Text(l10n.splitAddSplit),
                      ],
                    ),
                  ),
                  const SizedBox(height: SpacingTokens.lg),
                  ObFilledButton(
                    onPressed: isSubmitting.value
                        ? null
                        : () async {
                            final description = descriptionController.text
                                .trim();
                            if (description.isEmpty) return;

                            final budget = budgetAsync.value;
                            if (budget == null) return;

                            final currency = normalizeCurrencyCode(
                              budget.currencyCode,
                            );
                            final currencyDecimals = currencyDecimalsForCode(
                              currency,
                            );
                            final totalCents = parseMoneyInput(
                              totalAmountController.text,
                              decimals: currencyDecimals,
                            );
                            if (totalCents == null || totalCents <= 0) return;

                            // Validate splits
                            final splits = splitControllers.value;
                            if (splits.length < 2) {
                              showAppToast(
                                context,
                                message: l10n.splitMinimumError,
                                variant: AppToastVariant.warning,
                              );
                              return;
                            }

                            final splitItems = <SplitItem>[];
                            for (final split in splits) {
                              final splitCents = parseMoneyInput(
                                split.amountController.text,
                                decimals: currencyDecimals,
                              );
                              if (splitCents == null || splitCents <= 0) return;

                              final envId = split.selectedEnvelopeId;
                              final memo = split.memoController.text.trim();

                              splitItems.add(
                                SplitItem(
                                  amountCents: splitCents,
                                  envelopeId: envId != null && envId.isNotEmpty
                                      // UuidValue.fromString is experimental.
                                      ? UuidValue.fromString(envId)
                                      : null,
                                  memo: memo.isNotEmpty ? memo : null,
                                ),
                              );
                            }

                            // Validate amounts match
                            final splitSum = splitItems.fold<int>(
                              0,
                              (sum, s) => sum + s.amountCents,
                            );
                            if (splitSum != totalCents) {
                              showAppToast(
                                context,
                                message: l10n.splitMismatchError,
                                variant: AppToastVariant.warning,
                              );
                              return;
                            }

                            isSubmitting.value = true;
                            final router = GoRouter.of(context);

                            try {
                              await ref
                                  .read(
                                    splitTransactionActionsProvider.notifier,
                                  )
                                  .createSplit(
                                    description: description,
                                    totalAmountCents: -totalCents.abs(),
                                    currencyCode: currency,
                                    budgetId: budgetId,
                                    date: DateTime.now(),
                                    splits: splitItems,
                                  );
                              if (!context.mounted) return;
                              showAppToast(
                                context,
                                message: l10n.splitSaveSuccess,
                                variant: AppToastVariant.success,
                              );
                              router.goNamed(
                                planRoute,
                                pathParameters: {'id': budgetId},
                              );
                            } on Exception catch (_) {
                              isSubmitting.value = false;
                              if (!context.mounted) return;
                              showAppToast(
                                context,
                                message: l10n.splitSaveError,
                                variant: AppToastVariant.error,
                              );
                            }
                          },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSubmitting.value)
                          WiredLoadingIndicator(
                            size: 18,
                            color: palette.mutedInk,
                          )
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
      ),
    );
  }
}

class _SplitData {
  _SplitData()
    : key = UniqueKey(),
      amountController = TextEditingController(),
      memoController = TextEditingController();

  final Key key;
  final TextEditingController amountController;
  final TextEditingController memoController;
  String? selectedEnvelopeId;

  void dispose() {
    amountController.dispose();
    memoController.dispose();
  }
}

class _EnvelopeOption {
  const _EnvelopeOption({required this.id, required this.label});

  final String id;
  final String label;
}

class _SplitRow extends HookWidget {
  const _SplitRow({
    required this.index,
    required this.splitData,
    required this.currencyDecimals,
    required this.envelopeOptions,
    required this.canRemove,
    required this.onRemove,
    required this.onAmountChanged,
    super.key,
  });

  final int index;
  final _SplitData splitData;
  final int currencyDecimals;
  final List<_EnvelopeOption> envelopeOptions;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onAmountChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final selectedId = useState(splitData.selectedEnvelopeId);

    return ObCard(
      margin: const EdgeInsets.only(bottom: SpacingTokens.md),
      padding: const EdgeInsets.all(SpacingTokens.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${l10n.splitLabel} ${index + 1}',
                  style: theme.textTheme.titleSmall,
                ),
              ),
              if (canRemove)
                ObTextButton(
                  onPressed: onRemove,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SkribbleIcon(
                        data: OpenBudgetIcons.removeCircle,
                        size: 18,
                        color: palette.overspent,
                      ),
                      const SizedBox(width: SpacingTokens.xs),
                      Text(
                        l10n.splitRemoveSplit,
                        style: TextStyle(color: palette.overspent),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
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
                  value: selectedId.value,
                  items: [
                    DropdownMenuItem<String>(
                      value: '',
                      child: Text(l10n.transactionUnassigned),
                    ),
                    ...envelopeOptions.map(
                      (opt) => DropdownMenuItem<String>(
                        value: opt.id,
                        child: Text(opt.label),
                      ),
                    ),
                  ],
                  labelText: l10n.splitEnvelopeLabel,
                  onChanged: (value) {
                    selectedId.value = value;
                    splitData.selectedEnvelopeId = value;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          ObTextField(
            controller: splitData.amountController,
            labelText: l10n.splitAmountLabel,
            errorText: moneyInputError(
              splitData.amountController.text,
              decimals: currencyDecimals,
              message: l10n.amountInvalidFormat(currencyDecimals),
            ),
            prefixIcon: const SkribbleIcon(data: OpenBudgetIcons.money),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => onAmountChanged(),
          ),
          const SizedBox(height: SpacingTokens.sm),
          ObTextField(
            controller: splitData.memoController,
            labelText: l10n.splitMemoLabel,
            prefixIcon: const SkribbleIcon(data: OpenBudgetIcons.note),
          ),
        ],
      ),
    );
  }
}
