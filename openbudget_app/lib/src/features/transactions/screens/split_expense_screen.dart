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
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
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
    final colorScheme = theme.colorScheme;
    final budgetCurrency =
        budgetAsync.whenOrNull(
          data: (budget) => parseCurrencyCode(budget.currencyCode),
        ) ??
        CurrencyCode.usd;

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
    final totalAmount = double.tryParse(totalAmountController.text.trim()) ?? 0;
    final splitTotal = splitControllers.value.fold<double>(0, (sum, split) => sum + (double.tryParse(split.amountController.text.trim()) ?? 0));
    final remaining = totalAmount - splitTotal;
    final remainingCents = (remaining * _pow10(budgetCurrency.decimals))
        .round();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.goNamed(planRoute, pathParameters: {'id': budgetId}),
        ),
        title: Text(l10n.splitTransactionTitle),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
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
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(RadiusTokens.md),
                        ),
                        child: Icon(
                          Icons.call_split_rounded,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    Text(
                      l10n.splitTransactionTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n.transactionDescriptionLabel,
                        prefixIcon: const Icon(Icons.description_outlined),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    TextField(
                      controller: totalAmountController,
                      decoration: InputDecoration(
                        labelText: l10n.transactionAmountLabel,
                        prefixIcon: const Icon(Icons.attach_money_rounded),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
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
                      decoration: BoxDecoration(
                        color: remaining.abs() < 0.005
                            ? ColorTokens.secondary.withAlpha(30)
                            : ColorTokens.tertiary.withAlpha(30),
                        borderRadius: BorderRadius.circular(RadiusTokens.sm),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.splitRemainingLabel,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            formatCents(remainingCents, budgetCurrency),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: remaining.abs() < 0.005
                                  ? ColorTokens.secondary
                                  : ColorTokens.tertiary,
                            ),
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
                    const SizedBox(height: SpacingTokens.sm),
                    OutlinedButton.icon(
                      onPressed: () {
                        splitControllers.value = [
                          ...splitControllers.value,
                          _SplitData(),
                        ];
                      },
                      icon: const Icon(Icons.add),
                      label: Text(l10n.splitAddSplit),
                    ),
                    const SizedBox(height: SpacingTokens.lg),
                    FilledButton(
                      onPressed: isSubmitting.value
                          ? null
                          : () async {
                              final description = descriptionController.text
                                  .trim();
                              final total =
                                  double.tryParse(
                                    totalAmountController.text.trim(),
                                  ) ??
                                  0;
                              if (description.isEmpty || total <= 0) return;

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

                              final budget = budgetAsync.value;
                              if (budget == null) return;

                              final currency = CurrencyCode.values.firstWhere(
                                (c) => c.code == budget.currencyCode,
                                orElse: () => CurrencyCode.usd,
                              );
                              final totalCents =
                                  (total * _pow10(currency.decimals)).round();

                              final splitItems = <SplitItem>[];
                              for (final split in splits) {
                                final splitAmount =
                                    double.tryParse(
                                      split.amountController.text.trim(),
                                    ) ??
                                    0;
                                if (splitAmount <= 0) return;

                                final splitCents =
                                    (splitAmount * _pow10(currency.decimals))
                                        .round();
                                final envId = split.selectedEnvelopeId;
                                final memo = split.memoController.text.trim();

                                splitItems.add(
                                  SplitItem(
                                    amountCents: splitCents,
                                    envelopeId:
                                        envId != null && envId.isNotEmpty
                                        // UuidValue.fromString is experimental.
                                        // ignore: experimental_member_use
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
                                      currencyCode: budget.currencyCode,
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
                      child: isSubmitting.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.transactionSave),
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
    required this.envelopeOptions,
    required this.canRemove,
    required this.onRemove,
    required this.onAmountChanged,
    super.key,
  });

  final int index;
  final _SplitData splitData;
  final List<_EnvelopeOption> envelopeOptions;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onAmountChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedId = useState(splitData.selectedEnvelopeId);

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.md),
      child: Container(
        padding: const EdgeInsets.all(SpacingTokens.md),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  '${l10n.splitLabel} ${index + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (canRemove)
                  TextButton.icon(
                    onPressed: onRemove,
                    icon: Icon(
                      Icons.remove_circle_outline,
                      size: 18,
                      color: colorScheme.error,
                    ),
                    label: Text(
                      l10n.splitRemoveSplit,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: SpacingTokens.sm),
            DropdownButtonFormField<String>(
              initialValue: selectedId.value,
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
              onChanged: (value) {
                selectedId.value = value;
                splitData.selectedEnvelopeId = value;
              },
              decoration: InputDecoration(
                labelText: l10n.splitEnvelopeLabel,
                prefixIcon: const Icon(Icons.mail_outlined),
                isDense: true,
              ),
              isExpanded: true,
            ),
            const SizedBox(height: SpacingTokens.sm),
            TextField(
              controller: splitData.amountController,
              decoration: InputDecoration(
                labelText: l10n.splitAmountLabel,
                prefixIcon: const Icon(Icons.attach_money_rounded),
                isDense: true,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => onAmountChanged(),
            ),
            const SizedBox(height: SpacingTokens.sm),
            TextField(
              controller: splitData.memoController,
              decoration: InputDecoration(
                labelText: l10n.splitMemoLabel,
                prefixIcon: const Icon(Icons.note_outlined),
                isDense: true,
              ),
            ),
          ],
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
