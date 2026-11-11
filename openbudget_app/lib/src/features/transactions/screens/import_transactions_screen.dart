import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/accounts/providers/account_list_provider.dart';
import 'package:openbudget_app/src/features/transactions/providers/import_transactions_provider.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_code_utils.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

class ImportTransactionsScreen extends HookConsumerWidget {
  const ImportTransactionsScreen({required this.entityId, super.key});

  final String entityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final csvController = useTextEditingController();
    final parsedRows = useState<List<ImportRow>>([]);
    final isSubmitting = useState(false);
    final accountsAsync = ref.watch(accountListProvider(entityId));
    final selectedAccountId = useState<String?>(null);

    final accounts = accountsAsync.value ?? const <Account>[];
    final openAccounts = accounts
        .where((a) => a.closedAt == null)
        .toList(growable: false);
    final selectedAccount = openAccounts
        .where((a) => a.id?.toString() == selectedAccountId.value)
        .firstOrNull;
    final currencyCode = selectedAccount?.currencyCode ?? '';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const SkribbleIcon(data: OpenBudgetIcons.back),
          tooltip: l10n.transactionsBack,
          onPressed: () =>
              context.goNamed(moreRoute, pathParameters: {'entityId': entityId}),
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
                ObCard(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ObDropdown<String>(
                        value: selectedAccountId.value ?? '',
                        items: [
                          for (final account in openAccounts)
                            DropdownMenuItem<String>(
                              value: account.id?.toString() ?? '',
                              child: Text(
                                '${account.name} (${account.currencyCode})',
                              ),
                            ),
                        ],
                        labelText: l10n.importTargetAccount,
                        onChanged: (value) =>
                            selectedAccountId.value = value,
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      Center(
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: ObRoughDecoration(
                            color: palette.wash(ObTone.brand),
                            outline: palette.quietPen,
                            seed: 37,
                          ),
                          child: Center(
                            child: SkribbleIcon(
                              data: OpenBudgetIcons.importFile,
                              color: palette.brand,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: SpacingTokens.md),
                      Text(
                        l10n.importTitle,
                        style: theme.textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        l10n.importInstructions,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.mutedInk,
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
                      ObOutlinedButton(
                        onPressed: () {
                          final text = csvController.text.trim();
                          if (text.isEmpty) return;
                          parsedRows.value = parseCsvText(text, currencyCode);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SkribbleIcon(
                              data: OpenBudgetIcons.preview,
                              size: 18,
                            ),
                            const SizedBox(width: SpacingTokens.xs),
                            Text(l10n.importPreview),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (parsedRows.value.isNotEmpty) ...[
                  const SizedBox(height: SpacingTokens.md),
                  ObCard(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          l10n.importPreviewCount(parsedRows.value.length),
                          style: theme.textTheme.titleMedium,
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
                                        _formatDate(row.date),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                              color: palette.mutedInk,
                                            ),
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
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: ObAmount(
                                          _formatAmount(
                                            row.amountMinor,
                                            currencyCode,
                                          ),
                                          tone: row.amountMinor >= 0
                                              ? ObTone.funded
                                              : ObTone.neutral,
                                          style: theme.textTheme.bodySmall,
                                          textAlign: TextAlign.end,
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
                              color: palette.mutedInk,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: SpacingTokens.md),
                        ObFilledButton(
                          onPressed: isSubmitting.value ||
                                  selectedAccountId.value == null ||
                                  selectedAccountId.value!.isEmpty
                              ? null
                              : () => _import(
                                  context,
                                  ref,
                                  parsedRows.value,
                                  selectedAccountId.value!,
                                  currencyCode,
                                  isSubmitting,
                                ),
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
                                  data: OpenBudgetIcons.fileDone,
                                  size: 18,
                                ),
                              const SizedBox(width: SpacingTokens.xs),
                              Text(
                                isSubmitting.value
                                    ? l10n.importImporting
                                    : l10n.importButton(
                                        parsedRows.value.length,
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
    String accountId,
    String currencyCode,
    ValueNotifier<bool> isSubmitting,
  ) async {
    final l10n = AppLocalizations.of(context);
    isSubmitting.value = true;
    final router = GoRouter.of(context);
    try {
      final result = await ref
          .read(importTransactionsProvider.notifier)
          .importRows(
            accountId: accountId,
            currencyCode: normalizeCurrencyCode(currencyCode),
            rows: rows,
          );
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.importSuccess(result.insertedCount),
        variant: result.errors.isEmpty
            ? AppToastVariant.success
            : AppToastVariant.warning,
      );
      router.goNamed(transactionListRoute, pathParameters: {'entityId': entityId});
    } on Exception catch (_) {
      isSubmitting.value = false;
      if (!context.mounted) return;
      showAppToast(
        context,
        message: l10n.importError,
        variant: AppToastVariant.error,
      );
    }
  }

  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static String _formatAmount(int cents, String currencyCode) =>
      formatMinorForCode(cents, currencyCode);
}
