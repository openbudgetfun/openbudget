import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_actions_provider.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/features/tax/tax_formatting.dart';
import 'package:openbudget_app/src/features/tax/tax_labels.dart';
import 'package:openbudget_app/src/routing/route_names.dart';
import 'package:openbudget_app/src/utils/currency_formatter.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// What a person chose in a tax category sheet.
typedef TaxSelection = ({
  String? code,
  int? businessUsePercent,
  int? salesTaxCents,
});

/// Opens the category picker for an envelope's default tax category.
Future<TaxSelection?> showEnvelopeTaxCategorySheet(
  BuildContext context, {
  required String budgetId,
  required String envelopeId,
  required String subject,
  String? currentCode,
}) => showModalBottomSheet<TaxSelection>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _TaxCategorySheet(
    budgetId: budgetId,
    subject: subject,
    envelopeId: envelopeId,
    currentCode: currentCode,
  ),
);

/// Opens the category picker plus business-use and sales-tax fields for a
/// transaction.
Future<TaxSelection?> showTransactionTaxCategorySheet(
  BuildContext context, {
  required String budgetId,
  required String transactionId,
  required String subject,
  required String currencyCode,
  String? currentCode,
  int? businessUsePercent,
  int? salesTaxCents,
}) => showModalBottomSheet<TaxSelection>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _TaxCategorySheet(
    budgetId: budgetId,
    subject: subject,
    transactionId: transactionId,
    currencyCode: currencyCode,
    currentCode: currentCode,
    businessUsePercent: businessUsePercent,
    salesTaxCents: salesTaxCents,
  ),
);

class _TaxCategorySheet extends HookConsumerWidget {
  const _TaxCategorySheet({
    required this.budgetId,
    required this.subject,
    this.envelopeId,
    this.transactionId,
    this.currencyCode,
    this.currentCode,
    this.businessUsePercent,
    this.salesTaxCents,
  });

  final String budgetId;
  final String subject;
  final String? envelopeId;
  final String? transactionId;
  final String? currencyCode;
  final String? currentCode;
  final int? businessUsePercent;
  final int? salesTaxCents;

  bool get _isTransaction => transactionId != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final categoriesAsync = ref.watch(taxCategoriesProvider(budgetId));
    final searchController = useTextEditingController();
    final search = useState('');
    final selectedCode = useState<String?>(currentCode);
    final initialBusinessUse = businessUsePercent ?? 100;
    final businessUse = useState<int>(
      initialBusinessUse < 0
          ? 0
          : initialBusinessUse > 100
          ? 100
          : initialBusinessUse,
    );
    final currency = currencyCode ?? '';
    final currencyDecimals = currencyDecimalsForCode(currency);
    final salesTaxController = useTextEditingController(
      text: salesTaxCents == null
          ? ''
          : minorToPlainText(salesTaxCents!, currencyDecimals),
    );
    final salesTaxError = useState<String?>(null);
    final saveError = useState<String?>(null);
    final isSaving = useState(false);

    useEffect(() {
      void listener() => search.value = searchController.text;
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    Future<void> save() async {
      final salesTaxText = salesTaxController.text.trim();
      int? parsedSalesTax;
      salesTaxError.value = null;
      if (_isTransaction && salesTaxText.isNotEmpty) {
        final parsed = parsePlainMinor(salesTaxText, currencyDecimals);
        if (parsed == null) {
          salesTaxError.value = l10n.taxTransactionSalesTaxError;
          return;
        }
        parsedSalesTax = parsed;
      }

      isSaving.value = true;
      saveError.value = null;
      try {
        final actions = ref.read(taxActionsProvider.notifier);
        if (envelopeId case final id?) {
          await actions.setEnvelopeTaxCategory(
            budgetId: budgetId,
            envelopeId: id,
            code: selectedCode.value,
          );
        } else if (transactionId case final id?) {
          await actions.setTransactionTax(
            budgetId: budgetId,
            transactionId: id,
            code: selectedCode.value,
            businessUsePercent: businessUse.value,
            salesTaxCents: parsedSalesTax,
          );
        }
        if (!context.mounted) return;
        Navigator.of(context).pop<TaxSelection>((
          code: selectedCode.value,
          businessUsePercent: _isTransaction ? businessUse.value : null,
          salesTaxCents: parsedSalesTax,
        ));
      } on Exception catch (error) {
        isSaving.value = false;
        if (!context.mounted) return;
        saveError.value = taxErrorMessage(
          error,
          l10n.taxCategorySheetError,
        );
      }
    }

    final viewInsets = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = (MediaQuery.sizeOf(context).height * 0.82 - viewInsets)
        .clamp(0.0, double.infinity);

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.md,
                  0,
                  SpacingTokens.md,
                  SpacingTokens.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.taxCategorySheetTitle,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                    const SizedBox(height: SpacingTokens.sm),
                    ObTextField(
                      controller: searchController,
                      hintText: l10n.taxCategorySheetSearch,
                      prefixIcon: const SkribbleIcon(
                        data: OpenBudgetIcons.search,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: categoriesAsync.when(
                  loading: () =>
                      ObLoadingPanel(label: l10n.taxCategorySheetLoading),
                  error: (error, _) {
                    final notSetUp = error.toString().toLowerCase().contains(
                      'tax profile not found',
                    );
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(SpacingTokens.md),
                      child: notSetUp
                          ? ObStatePanel.empty(
                              title: l10n.taxSetupTitle,
                              message: l10n.taxCategorySheetEmpty,
                              action: ObStateAction(
                                label: l10n.taxCategorySheetSetupAction,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  unawaited(
                                    context.pushNamed(
                                      taxProfileRoute,
                                      pathParameters: {'id': budgetId},
                                    ),
                                  );
                                },
                              ),
                            )
                          : ObStatePanel.problem(
                              title: l10n.taxCategorySheetLoadError,
                              message: taxErrorMessage(
                                error,
                                l10n.taxCategorySheetLoadError,
                              ),
                              action: ObStateAction(
                                label: l10n.taxCategoryLoadRetry,
                                onPressed: () => ref.invalidate(
                                  taxCategoriesProvider(budgetId),
                                ),
                              ),
                            ),
                    );
                  },
                  data: (categories) {
                    final query = search.value.trim().toLowerCase();
                    final filtered = query.isEmpty
                        ? categories
                        : categories
                              .where(
                                (category) =>
                                    category.label.toLowerCase().contains(
                                      query,
                                    ) ||
                                    category.code.toLowerCase().contains(
                                      query,
                                    ) ||
                                    (category.reportReference
                                            ?.toLowerCase()
                                            .contains(query) ??
                                        false),
                              )
                              .toList();
                    final grouped = <TaxCategoryKind, List<TaxCategoryView>>{};
                    for (final category in filtered) {
                      final kind = _kindOf(category.kind);
                      if (kind == null) continue;
                      grouped.putIfAbsent(kind, () => []).add(category);
                    }

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(
                        SpacingTokens.md,
                        SpacingTokens.sm,
                        SpacingTokens.md,
                        SpacingTokens.md,
                      ),
                      children: [
                        _CategoryTile(
                          label: l10n.taxCategoryNone,
                          detail: l10n.taxCategoryNoneHint,
                          selected: selectedCode.value == null,
                          onTap: () => selectedCode.value = null,
                        ),
                        if (filtered.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: SpacingTokens.lg,
                            ),
                            child: Text(
                              l10n.taxCategorySearchEmpty(
                                search.value.trim(),
                              ),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: palette.mutedInk,
                              ),
                            ),
                          ),
                        for (final entry in grouped.entries) ...[
                          ObSectionHeader(
                            title: taxCategoryKindLabel(l10n, entry.key),
                            padding: const EdgeInsets.fromLTRB(0, 16, 0, 4),
                          ),
                          for (final category in entry.value)
                            _CategoryTile(
                              label: category.label,
                              detail: category.reportReference,
                              selected: selectedCode.value == category.code,
                              onTap: () => selectedCode.value = category.code,
                            ),
                        ],
                        if (_isTransaction) ...[
                          const SizedBox(height: SpacingTokens.md),
                          ObCard(
                            padding: const EdgeInsets.all(SpacingTokens.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        l10n.taxTransactionBusinessUse,
                                        style: theme.textTheme.titleSmall,
                                      ),
                                    ),
                                    ObAmount(
                                      l10n.taxTransactionBusinessUseValue(
                                        businessUse.value,
                                      ),
                                      style: theme.textTheme.titleSmall,
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: businessUse.value.toDouble(),
                                  max: 100,
                                  divisions: 100,
                                  label: l10n.taxTransactionBusinessUseValue(
                                    businessUse.value,
                                  ),
                                  onChanged: (value) =>
                                      businessUse.value = value.round(),
                                ),
                                const SizedBox(height: SpacingTokens.xs),
                                ObTextField(
                                  controller: salesTaxController,
                                  labelText: l10n.taxTransactionSalesTax,
                                  hintText: l10n.taxTransactionSalesTaxHint,
                                  prefixText: currencySymbolForCode(currency),
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                                if (salesTaxError.value case final message?)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: SpacingTokens.xs,
                                    ),
                                    child: Text(
                                      message,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: palette.overspent),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              if (saveError.value case final message?)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SpacingTokens.md,
                    0,
                    SpacingTokens.md,
                    SpacingTokens.xs,
                  ),
                  child: Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: palette.overspent,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.md,
                  SpacingTokens.xs,
                  SpacingTokens.md,
                  SpacingTokens.sm,
                ),
                child: ObFilledButton(
                  onPressed: isSaving.value ? null : save,
                  isLoading: isSaving.value,
                  loadingLabel: l10n.taxCategorySheetSaved,
                  child: Text(l10n.taxCategorySheetSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends HookWidget {
  const _CategoryTile({
    required this.label,
    required this.detail,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? detail;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = theme.ob;
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.xs),
      child: ObCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm,
          vertical: SpacingTokens.xs,
        ),
        child: Row(
          children: [
            SkribbleIcon(
              data: selected
                  ? OpenBudgetIcons.checkCircle
                  : OpenBudgetIcons.circle,
              color: selected ? palette.brand : palette.mutedInk,
              size: 20,
            ),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.ink,
                      fontWeight: selected ? FontWeight.w700 : null,
                    ),
                  ),
                  if (detail case final text?)
                    Text(
                      text,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: palette.mutedInk,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TaxCategoryKind? _kindOf(String raw) {
  for (final kind in TaxCategoryKind.values) {
    if (kind.name == raw) return kind;
  }
  return null;
}
