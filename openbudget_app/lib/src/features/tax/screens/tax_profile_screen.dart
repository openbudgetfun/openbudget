import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_app/src/features/home/providers/budget_list_provider.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_actions_provider.dart';
import 'package:openbudget_app/src/features/tax/providers/tax_providers.dart';
import 'package:openbudget_app/src/features/tax/tax_formatting.dart';
import 'package:openbudget_app/src/features/tax/tax_labels.dart';
import 'package:openbudget_app/src/widgets/app_toast.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_ui/openbudget_ui.dart';

/// Asks the questions that change how a budget's figures are taxed.
class TaxProfileScreen extends HookConsumerWidget {
  const TaxProfileScreen({required this.budgetId, super.key});

  final String budgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final profileAsync = ref.watch(taxProfileProvider(budgetId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.taxProfileTitle)),
      body: profileAsync.when(
        loading: () => Center(
          child: ObLoadingPanel(label: l10n.taxProfileLoading),
        ),
        error: (error, _) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: ObStatePanel.problem(
              title: l10n.taxProfileLoadError,
              message: taxErrorMessage(error, l10n.taxProfileLoadError),
              action: ObStateAction(
                label: l10n.taxCategoryLoadRetry,
                onPressed: () => ref.invalidate(taxProfileProvider(budgetId)),
              ),
            ),
          ),
        ),
        data: (record) => _TaxProfileForm(
          key: ValueKey(
            record?.updatedAt.microsecondsSinceEpoch ?? record?.id?.toString(),
          ),
          budgetId: budgetId,
          existing: record == null
              ? null
              : parseTaxProfileJson(record.profileJson),
          existingLinkedBudgetId: record?.linkedBudgetId?.toString(),
        ),
      ),
    );
  }
}

class _TaxProfileForm extends HookConsumerWidget {
  const _TaxProfileForm({
    required this.budgetId,
    required this.existing,
    required this.existingLinkedBudgetId,
    super.key,
  });

  final String budgetId;
  final TaxProfile? existing;
  final String? existingLinkedBudgetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = theme.ob;
    final budgetsAsync = ref.watch(budgetListProvider);
    final budgets = budgetsAsync.value ?? const <Budget>[];
    final currentBudget = _budgetWithId(budgets, budgetId);

    final profile = existing;
    final gb = profile is GbTaxProfile ? profile : null;
    final us = profile is UsTaxProfile ? profile : null;
    final ng = profile is NgTaxProfile ? profile : null;
    final de = profile is DeTaxProfile ? profile : null;

    final country = useState(
      existing?.jurisdiction ??
          _jurisdictionForCurrency(currentBudget?.currencyCode),
    );
    final entityKind = useState(
      existing?.entityKind ?? TaxEntityKind.individual,
    );
    final salesTaxRegistered = useState(
      existing?.salesTaxRegistered ?? false,
    );
    final scottishTaxpayer = useState(gb?.scottishTaxpayer ?? false);
    final studentLoanPlan = useState<GbStudentLoanPlan?>(gb?.studentLoanPlan);
    final filingStatus = useState(
      us?.filingStatus ?? UsFilingStatus.single,
    );
    final annualRentController = useTextEditingController(
      text: ng == null
          ? ''
          : minorToPlainText(ng.annualRentMinor, CurrencyCode.ngn.decimals),
    );
    final jointAssessment = useState(de?.jointAssessment ?? false);
    final churchTax = useState(de?.churchTax ?? false);
    final smallBusinessExemption = useState(
      de?.smallBusinessExemption ?? true,
    );
    final linkedBudgetId = useState<String?>(existingLinkedBudgetId);
    final rentError = useState<String?>(null);
    final formError = useState<String?>(null);
    final isSaving = useState(false);

    final linkedBudgets = budgets
        .whereType<Budget>()
        .where(
          (budget) =>
              budget.id?.toString() != budgetId &&
              budget.id?.toString() != null,
        )
        .toList();

    TaxProfile buildProfile() => switch (country.value) {
      TaxJurisdiction.gb => GbTaxProfile(
        entityKind: entityKind.value,
        salesTaxRegistered: salesTaxRegistered.value,
        scottishTaxpayer: scottishTaxpayer.value,
        studentLoanPlan: studentLoanPlan.value,
      ),
      TaxJurisdiction.us => UsTaxProfile(
        entityKind: entityKind.value,
        salesTaxRegistered: salesTaxRegistered.value,
        filingStatus: filingStatus.value,
      ),
      TaxJurisdiction.ng => NgTaxProfile(
        entityKind: entityKind.value,
        salesTaxRegistered: salesTaxRegistered.value,
        annualRentMinor:
            parsePlainMinor(
              annualRentController.text,
              CurrencyCode.ngn.decimals,
            ) ??
            0,
      ),
      TaxJurisdiction.de => DeTaxProfile(
        entityKind: entityKind.value,
        salesTaxRegistered: salesTaxRegistered.value,
        jointAssessment: jointAssessment.value,
        churchTax: churchTax.value,
        smallBusinessExemption: smallBusinessExemption.value,
      ),
    };

    Future<void> save() async {
      rentError.value = null;
      formError.value = null;

      if (country.value == TaxJurisdiction.ng) {
        final rentText = annualRentController.text.trim();
        if (rentText.isNotEmpty &&
            parsePlainMinor(rentText, CurrencyCode.ngn.decimals) == null) {
          rentError.value = l10n.taxNgAnnualRentError;
          return;
        }
      }
      if (entityKind.value != TaxEntityKind.individual &&
          linkedBudgetId.value == budgetId) {
        formError.value = l10n.taxLinkedBudgetError;
        return;
      }

      final profile = buildProfile();
      final isIndividual = entityKind.value == TaxEntityKind.individual;
      isSaving.value = true;
      try {
        await ref
            .read(taxActionsProvider.notifier)
            .saveProfile(
              budgetId: budgetId,
              jurisdiction: profile.jurisdiction.countryCode,
              entityKind: profile.entityKind.name,
              profileJson: jsonEncode(profile.toJson()),
              linkedBudgetId: isIndividual ? null : linkedBudgetId.value,
            );
        if (!context.mounted) return;
        showAppToast(
          context,
          message: l10n.taxProfileSaved,
          variant: AppToastVariant.success,
        );
        if (context.canPop()) {
          context.pop();
        } else {
          isSaving.value = false;
        }
      } on Exception catch (error) {
        isSaving.value = false;
        if (!context.mounted) return;
        formError.value = taxErrorMessage(error, l10n.taxProfileSaveError);
      }
    }

    String? linkedBudgetError() {
      if (entityKind.value == TaxEntityKind.individual) return null;
      if (linkedBudgetId.value == budgetId) {
        return l10n.taxLinkedBudgetError;
      }
      return null;
    }

    final entity = entityKind.value;
    final linkedError = linkedBudgetError();
    final selectedLinkedBudget = linkedBudgetId.value;
    final linkedBudgetIsKnown =
        selectedLinkedBudget == null ||
        linkedBudgets.any(
          (budget) => budget.id?.toString() == selectedLinkedBudget,
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.md,
        SpacingTokens.sm,
        SpacingTokens.md,
        SpacingTokens.xl,
      ),
      children: [
        Text(
          l10n.taxSetupMessage,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: palette.mutedInk,
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        ObDropdown<TaxJurisdiction>(
          value: country.value,
          labelText: l10n.taxCountryLabel,
          items: [
            for (final jurisdiction in TaxJurisdiction.values)
              DropdownMenuItem(
                value: jurisdiction,
                child: Text(taxJurisdictionLabel(l10n, jurisdiction)),
              ),
          ],
          onChanged: (jurisdiction) {
            if (jurisdiction != null) country.value = jurisdiction;
          },
        ),
        const SizedBox(height: SpacingTokens.md),
        ObDropdown<TaxEntityKind>(
          value: entityKind.value,
          labelText: l10n.taxEntityKindLabel,
          items: [
            for (final kind in TaxEntityKind.values)
              DropdownMenuItem(
                value: kind,
                child: Text(taxEntityKindLabel(l10n, kind)),
              ),
          ],
          onChanged: (kind) {
            if (kind == null) return;
            entityKind.value = kind;
            if (kind == TaxEntityKind.individual) {
              linkedBudgetId.value = null;
            }
          },
        ),
        if (entity != TaxEntityKind.individual) ...[
          const SizedBox(height: SpacingTokens.md),
          ObDropdown<String>(
            value: selectedLinkedBudget ?? '',
            labelText: l10n.taxLinkedBudget,
            items: [
              DropdownMenuItem(
                value: '',
                child: Text(l10n.taxLinkedBudgetNone),
              ),
              if (selectedLinkedBudget != null && !linkedBudgetIsKnown)
                DropdownMenuItem(
                  value: selectedLinkedBudget,
                  child: Text(l10n.taxLinkedBudget),
                ),
              for (final budget in linkedBudgets)
                DropdownMenuItem(
                  value: budget.id.toString(),
                  child: Text(budget.name),
                ),
            ],
            onChanged: (value) {
              linkedBudgetId.value = value == null || value.isEmpty
                  ? null
                  : value;
            },
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            l10n.taxLinkedBudgetHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: palette.mutedInk,
            ),
          ),
          if (linkedError != null) ...[
            const SizedBox(height: SpacingTokens.xs),
            Text(
              linkedError,
              style: theme.textTheme.bodySmall?.copyWith(
                color: palette.overspent,
              ),
            ),
          ],
        ],
        ObSectionHeader(
          title: taxJurisdictionLabel(l10n, country.value),
          padding: const EdgeInsets.fromLTRB(
            0,
            SpacingTokens.lg,
            0,
            SpacingTokens.xs,
          ),
        ),
        ObCard(
          child: Column(
            children: [
              SwitchListTile(
                value: salesTaxRegistered.value,
                onChanged: (value) => salesTaxRegistered.value = value,
                title: Text(l10n.taxSalesTaxRegistered),
                subtitle: Text(l10n.taxSalesTaxRegisteredHint),
                secondary: SkribbleIcon(
                  data: OpenBudgetIcons.receipt,
                  color: palette.ink,
                ),
              ),
              if (country.value == TaxJurisdiction.gb) ...[
                const Divider(height: 1),
                SwitchListTile(
                  value: scottishTaxpayer.value,
                  onChanged: (value) => scottishTaxpayer.value = value,
                  title: Text(l10n.taxGbScottishTaxpayer),
                  subtitle: Text(l10n.taxGbScottishTaxpayerHint),
                  secondary: SkribbleIcon(
                    data: OpenBudgetIcons.nature,
                    color: palette.ink,
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: ObDropdown<String>(
                    value: studentLoanPlan.value?.name ?? 'none',
                    labelText: l10n.taxGbStudentLoanPlan,
                    items: [
                      DropdownMenuItem(
                        value: 'none',
                        child: Text(l10n.taxGbStudentLoanNone),
                      ),
                      for (final plan in GbStudentLoanPlan.values)
                        DropdownMenuItem(
                          value: plan.name,
                          child: Text(taxStudentLoanPlanLabel(l10n, plan)),
                        ),
                    ],
                    onChanged: (value) {
                      studentLoanPlan.value = value == null || value == 'none'
                          ? null
                          : _studentLoanPlan(value);
                    },
                  ),
                ),
              ],
              if (country.value == TaxJurisdiction.us) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: ObDropdown<UsFilingStatus>(
                    value: filingStatus.value,
                    labelText: l10n.taxUsFilingStatus,
                    items: [
                      for (final status in UsFilingStatus.values)
                        DropdownMenuItem(
                          value: status,
                          child: Text(taxFilingStatusLabel(l10n, status)),
                        ),
                    ],
                    onChanged: (status) {
                      if (status != null) filingStatus.value = status;
                    },
                  ),
                ),
              ],
              if (country.value == TaxJurisdiction.ng) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ObTextField(
                        controller: annualRentController,
                        labelText: l10n.taxNgAnnualRent,
                        hintText: l10n.taxNgAnnualRentHint,
                        prefixText: CurrencyCode.ngn.symbol,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => rentError.value = null,
                      ),
                      if (rentError.value case final message?)
                        Padding(
                          padding: const EdgeInsets.only(
                            top: SpacingTokens.xs,
                          ),
                          child: Text(
                            message,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: palette.overspent,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (country.value == TaxJurisdiction.de) ...[
                const Divider(height: 1),
                SwitchListTile(
                  value: jointAssessment.value,
                  onChanged: (value) => jointAssessment.value = value,
                  title: Text(l10n.taxDeJointAssessment),
                  subtitle: Text(l10n.taxDeJointAssessmentHint),
                  secondary: SkribbleIcon(
                    data: OpenBudgetIcons.people,
                    color: palette.ink,
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: churchTax.value,
                  onChanged: (value) => churchTax.value = value,
                  title: Text(l10n.taxDeChurchTax),
                  subtitle: Text(l10n.taxDeChurchTaxHint),
                  secondary: SkribbleIcon(
                    data: OpenBudgetIcons.document,
                    color: palette.ink,
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: smallBusinessExemption.value,
                  onChanged: (value) => smallBusinessExemption.value = value,
                  title: Text(l10n.taxDeSmallBusinessExemption),
                  subtitle: Text(l10n.taxDeSmallBusinessExemptionHint),
                  secondary: SkribbleIcon(
                    data: OpenBudgetIcons.store,
                    color: palette.ink,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (formError.value case final message?) ...[
          const SizedBox(height: SpacingTokens.md),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: palette.overspent,
            ),
          ),
        ],
        const SizedBox(height: SpacingTokens.lg),
        ObFilledButton(
          onPressed: isSaving.value ? null : save,
          isLoading: isSaving.value,
          loadingLabel: l10n.taxProfileSave,
          child: Text(l10n.taxProfileSave),
        ),
        const SizedBox(height: SpacingTokens.md),
        Text(
          l10n.taxDisclaimer,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: palette.mutedInk),
        ),
      ],
    );
  }
}

TaxJurisdiction _jurisdictionForCurrency(String? currencyCode) =>
    switch (currencyCode?.toUpperCase()) {
      'GBP' => TaxJurisdiction.gb,
      'USD' => TaxJurisdiction.us,
      'NGN' => TaxJurisdiction.ng,
      'EUR' => TaxJurisdiction.de,
      _ => TaxJurisdiction.gb,
    };

Budget? _budgetWithId(Iterable<Budget> budgets, String id) {
  for (final budget in budgets) {
    if (budget.id?.toString() == id) return budget;
  }
  return null;
}

GbStudentLoanPlan _studentLoanPlan(String name) {
  for (final plan in GbStudentLoanPlan.values) {
    if (plan.name == name) return plan;
  }
  return GbStudentLoanPlan.plan2;
}
