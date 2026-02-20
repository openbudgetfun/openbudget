import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/budget/providers/budget_detail_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/import_transactions_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class ImportTransactionsScreen extends HookConsumerWidget {
  const ImportTransactionsScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final csvController = useTextEditingController();
    final parsedRows = useState<List<ImportRow>>([]);
    final isSubmitting = useState(false);
    final budgetAsync = ref.watch(budgetDetailProvider(budgetId));

    final currencyCode = budgetAsync.hasValue
        ? CurrencyCode.values.firstWhere(
            (c) => c.code == budgetAsync.value!.currencyCode,
            orElse: () => CurrencyCode.usd,
          )
        : CurrencyCode.usd;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.goNamed(moreRoute, pathParameters: {'id': budgetId}),
        ),
        title: Text(l10n.importTitle),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SpacingTokens.xl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
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
                              color: colorScheme.primaryContainer.withAlpha(80),
                              borderRadius: BorderRadius.circular(
                                RadiusTokens.md,
                              ),
                            ),
                            child: Icon(
                              Icons.upload_file_rounded,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        Text(
                          l10n.importTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: SpacingTokens.xs),
                        Text(
                          l10n.importInstructions,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: SpacingTokens.lg),
                        TextField(
                          controller: csvController,
                          decoration: InputDecoration(
                            labelText: l10n.importCsvLabel,
                            hintText: l10n.importCsvHint,
                            alignLabelWithHint: true,
                          ),
                          maxLines: 8,
                          textInputAction: TextInputAction.newline,
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        OutlinedButton.icon(
                          onPressed: () {
                            final text = csvController.text.trim();
                            if (text.isEmpty) return;
                            parsedRows.value = parseCsvText(text, currencyCode);
                          },
                          icon: const Icon(Icons.preview_rounded),
                          label: Text(l10n.importPreview),
                        ),
                      ],
                    ),
                  ),
                ),
                if (parsedRows.value.isNotEmpty) ...[
                  const SizedBox(height: SpacingTokens.md),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            l10n.importPreviewCount(parsedRows.value.length),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: SpacingTokens.sm),
                          const Divider(),
                          ...parsedRows.value
                              .take(20)
                              .map(
                                (row) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: SpacingTokens.xs,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          _formatDate(row.transactionDate),
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Text(
                                          row.description,
                                          style: theme.textTheme.bodySmall,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          _formatAmount(
                                            row.amountCents,
                                            currencyCode,
                                          ),
                                          textAlign: TextAlign.right,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: row.amountCents >= 0
                                                    ? ColorTokens.secondary
                                                    : colorScheme.error,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          if (parsedRows.value.length > 20) ...[
                            const Divider(),
                            Text(
                              l10n.importMoreRows(parsedRows.value.length - 20),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: SpacingTokens.md),
                          FilledButton.icon(
                            onPressed: isSubmitting.value
                                ? null
                                : () => _import(
                                    context,
                                    ref,
                                    parsedRows.value,
                                    currencyCode,
                                    isSubmitting,
                                  ),
                            icon: isSubmitting.value
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.file_download_done_rounded),
                            label: Text(
                              isSubmitting.value
                                  ? l10n.importImporting
                                  : l10n.importButton(parsedRows.value.length),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _import(
    BuildContext context,
    WidgetRef ref,
    List<ImportRow> rows,
    CurrencyCode currencyCode,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    isSubmitting.value = true;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final count = await ref
          .read(importTransactionsProvider.notifier)
          .importRows(
            budgetId: budgetId,
            currencyCode: currencyCode.code,
            rows: rows,
          );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.importSuccess(count))),
      );
      router.goNamed(planRoute, pathParameters: {'id': budgetId});
    } on Exception catch (_) {
      isSubmitting.value = false;
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.importError),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String _formatAmount(int cents, CurrencyCode currency) {
    final sign = cents < 0 ? '-' : '';
    final absCents = cents.abs();
    final decimals = currency.decimals;
    final divisor = _pow10(decimals);
    final whole = absCents ~/ divisor;
    final frac = (absCents % divisor).toString().padLeft(decimals, '0');
    return '$sign${currency.symbol}$whole.$frac';
  }

  static int _pow10(int exponent) {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }
}
