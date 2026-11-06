import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
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
    final postgraduateLoan = useState(gb?.postgraduateLoan ?? false);
    final accountingPeriodEndMonth = useState(
      gb?.accountingPeriodEndMonth ?? 3,
    );
    final accountingPeriodEndDay = useState(gb?.accountingPeriodEndDay ?? 31);
    final associatedCompaniesController = useTextEditingController(
      text: gb == null || gb.associatedCompanies == 0
          ? ''
          : gb.associatedCompanies.toString(),
    );
    final filingStatus = useState(
      us?.filingStatus ?? UsFilingStatus.single,
    );
    final homeOfficeMethod = useState(
      us?.homeOfficeMethod ?? UsHomeOfficeMethod.simplified,
    );
    final specifiedServiceTrade = useState(
      us?.specifiedServiceTrade ?? false,
    );
    final foreignExclusionController = useTextEditingController(
      text: us == null
          ? ''
          : formatMinorUnits(us.foreignEarnedIncomeExclusionMinor, 2),
    );
    final dependentsUnder17Controller = useTextEditingController(
      text: us == null
          ? ''
          : '${us.dependents.where((dependent) => dependent.underSeventeen).length}',
    );
    final dependents17OrOlderController = useTextEditingController(
      text: us == null
          ? ''
          : '${us.dependents.where((dependent) => !dependent.underSeventeen).length}',
    );
    final dependentsHaveSsn = useState(
      us != null &&
          us.dependents.isNotEmpty &&
          us.dependents.every((dependent) => dependent.hasValidSsn),
    );
    final taxpayer65OrOlder = useState(us?.taxpayer65OrOlder ?? false);
    final spouse65OrOlder = useState(us?.spouse65OrOlder ?? false);
    final taxpayerHasSsn = useState(us?.taxpayerHasSsn ?? true);
    final spouseHasSsn = useState(us?.spouseHasSsn ?? true);
    final annualRentController = useTextEditingController(
      text: ng == null
          ? ''
          : formatMinorUnits(ng.annualRentMinor, CurrencyCode.ngn.decimals),
    );
    final smallCompanyCeiling = useState(
      ng?.smallCompanyCeiling ?? NgSmallCompanyCeiling.ntaGazette,
    );
    final mneGroupMember = useState(ng?.mneGroupMember ?? false);
    final jointAssessment = useState(de?.jointAssessment ?? false);
    final spouseEmployed = useState(de?.spouseEmployed ?? false);
    final churchTax = useState(de?.churchTax ?? false);
    final churchState = useState<DeBundesland?>(de?.churchTaxState);
    final smallBusinessExemption = useState(
      de?.smallBusinessExemption ?? true,
    );
    final einkunftsArt = useState(
      de?.einkunftsArt ?? DeEinkunftsArt.gewerblich,
    );
    final childrenController = useTextEditingController(
      text: de == null || de.children == 0 ? '' : '${de.children}',
    );
    final pensionController = useTextEditingController(
      text: de == null
          ? ''
          : formatMinorUnits(
              de.statutoryPensionMinor,
              CurrencyCode.eur.decimals,
            ),
    );
    final priorTurnoverController = useTextEditingController(
      text: de == null || de.previousYearTurnoverMinor == 0
          ? ''
          : formatMinorUnits(
              de.previousYearTurnoverMinor,
              CurrencyCode.eur.decimals,
            ),
    );
    final commuteKmController = useTextEditingController(
      text: de == null || de.commuteKmOneWay == 0
          ? ''
          : '${de.commuteKmOneWay}',
    );
    final commuteDaysController = useTextEditingController(
      text: de == null || de.commuteDays == 0 ? '' : '${de.commuteDays}',
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

    // The associated companies field as a whole number of zero or more, or
    // null when it does not parse. Empty means none.
    int? associatedCompaniesValue() {
      final text = associatedCompaniesController.text.trim();
      if (text.isEmpty) return 0;
      final value = int.tryParse(text);
      return value != null && value >= 0 ? value : null;
    }

    TaxProfile buildProfile() => switch (country.value) {
      TaxJurisdiction.gb => GbTaxProfile(
        entityKind: entityKind.value,
        salesTaxRegistered: salesTaxRegistered.value,
        scottishTaxpayer: scottishTaxpayer.value,
        studentLoanPlan: studentLoanPlan.value,
        postgraduateLoan: postgraduateLoan.value,
        accountingPeriodEndMonth: accountingPeriodEndMonth.value,
        accountingPeriodEndDay: accountingPeriodEndDay.value,
        associatedCompanies: associatedCompaniesValue() ?? 0,
      ),
      TaxJurisdiction.us => UsTaxProfile(
        entityKind: entityKind.value,
        salesTaxRegistered: salesTaxRegistered.value,
        filingStatus: filingStatus.value,
        homeOfficeMethod: homeOfficeMethod.value,
        specifiedServiceTrade: specifiedServiceTrade.value,
        foreignEarnedIncomeExclusionMinor:
            parseMinorUnits(foreignExclusionController.text, 2) ?? 0,
        taxpayer65OrOlder: taxpayer65OrOlder.value,
        spouse65OrOlder: spouse65OrOlder.value,
        taxpayerHasSsn: taxpayerHasSsn.value,
        spouseHasSsn: spouseHasSsn.value,
        dependents: [
          for (var i = 0; i < _countOf(dependentsUnder17Controller); i++)
            UsDependent(
              underSeventeen: true,
              hasValidSsn: dependentsHaveSsn.value,
            ),
          for (var i = 0; i < _countOf(dependents17OrOlderController); i++)
            UsDependent(
              underSeventeen: false,
              hasValidSsn: dependentsHaveSsn.value,
            ),
        ],
      ),
      TaxJurisdiction.ng => NgTaxProfile(
        entityKind: entityKind.value,
        salesTaxRegistered: salesTaxRegistered.value,
        annualRentMinor:
            parseMinorUnits(
              annualRentController.text,
              CurrencyCode.ngn.decimals,
            ) ??
            0,
        smallCompanyCeiling: smallCompanyCeiling.value,
        mneGroupMember: mneGroupMember.value,
      ),
      TaxJurisdiction.de => DeTaxProfile(
        entityKind: entityKind.value,
        salesTaxRegistered: salesTaxRegistered.value,
        jointAssessment: jointAssessment.value,
        churchTax: churchTax.value,
        churchTaxState: churchState.value,
        smallBusinessExemption: smallBusinessExemption.value,
        einkunftsArt: einkunftsArt.value,
        children: _wholeCount(childrenController.text) ?? 0,
        spouseEmployed: spouseEmployed.value,
        statutoryPensionMinor:
            parseMinorUnits(
              pensionController.text,
              CurrencyCode.eur.decimals,
            ) ??
            0,
        previousYearTurnoverMinor:
            parseMinorUnits(
              priorTurnoverController.text,
              CurrencyCode.eur.decimals,
            ) ??
            0,
        commuteKmOneWay: _wholeCount(commuteKmController.text) ?? 0,
        commuteDays: _wholeCount(commuteDaysController.text) ?? 0,
      ),
    };

    Future<void> save() async {
      rentError.value = null;
      formError.value = null;

      if (country.value == TaxJurisdiction.ng) {
        final rentText = annualRentController.text.trim();
        if (rentText.isNotEmpty &&
            parseMinorUnits(rentText, CurrencyCode.ngn.decimals) == null) {
          rentError.value = l10n.taxNgAnnualRentError;
          return;
        }
      }
      if (country.value == TaxJurisdiction.gb &&
          entityKind.value == TaxEntityKind.company &&
          associatedCompaniesValue() == null) {
        formError.value = l10n.taxGbAssociatedCompaniesError;
        return;
      }
      if (country.value == TaxJurisdiction.de) {
        final countTexts = [
          childrenController.text,
          commuteKmController.text,
          commuteDaysController.text,
        ];
        if (countTexts.any(
          (text) => text.trim().isNotEmpty && _wholeCount(text) == null,
        )) {
          formError.value = l10n.taxDeNumberError;
          return;
        }
        final euroTexts = [
          pensionController.text,
          priorTurnoverController.text,
        ];
        if (euroTexts.any(
          (text) =>
              text.trim().isNotEmpty &&
              parseMinorUnits(text, CurrencyCode.eur.decimals) == null,
        )) {
          formError.value = l10n.taxDeAmountError;
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
                      // The undergraduate plans. A postgraduate loan runs
                      // alongside any of them and has its own switch.
                      for (final plan in GbStudentLoanPlan.values.where(
                        (plan) => plan != GbStudentLoanPlan.postgraduate,
                      ))
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
                const Divider(height: 1),
                SwitchListTile(
                  value: postgraduateLoan.value,
                  onChanged: (value) => postgraduateLoan.value = value,
                  title: Text(l10n.taxGbStudentLoanPostgraduate),
                  subtitle: Text(l10n.taxGbPostgraduateLoanHint),
                  secondary: SkribbleIcon(
                    data: OpenBudgetIcons.insight,
                    color: palette.ink,
                  ),
                ),
                if (entityKind.value == TaxEntityKind.company) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.taxGbAccountingPeriodEnd,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.mutedInk,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.xs),
                        Row(
                          children: [
                            Expanded(
                              child: ObDropdown<int>(
                                value: accountingPeriodEndMonth.value,
                                labelText: l10n.taxGbAccountingPeriodMonth,
                                items: [
                                  for (var month = 1; month <= 12; month++)
                                    DropdownMenuItem(
                                      value: month,
                                      child: Text(
                                        DateFormat.MMMM().format(
                                          DateTime(2024, month),
                                        ),
                                      ),
                                    ),
                                ],
                                onChanged: (month) {
                                  if (month == null) return;
                                  accountingPeriodEndMonth.value = month;
                                  // Keep the day inside the chosen month.
                                  final lastDay = _daysInMonth(
                                    month: month,
                                    leap: true,
                                  );
                                  if (accountingPeriodEndDay.value > lastDay) {
                                    accountingPeriodEndDay.value = lastDay;
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: SpacingTokens.md),
                            Expanded(
                              child: ObDropdown<int>(
                                value: accountingPeriodEndDay.value,
                                labelText: l10n.taxGbAccountingPeriodDay,
                                items: [
                                  for (
                                    var day = 1;
                                    day <=
                                        _daysInMonth(
                                          month: accountingPeriodEndMonth.value,
                                          leap: true,
                                        );
                                    day++
                                  )
                                    DropdownMenuItem(
                                      value: day,
                                      child: Text('$day'),
                                    ),
                                ],
                                onChanged: (day) {
                                  if (day != null) {
                                    accountingPeriodEndDay.value = day;
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: SpacingTokens.xs),
                        Text(
                          l10n.taxGbAccountingPeriodEndHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: palette.mutedInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: ObTextField(
                      controller: associatedCompaniesController,
                      labelText: l10n.taxGbAssociatedCompanies,
                      hintText: l10n.taxGbAssociatedCompaniesHint,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
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
                if (entity == TaxEntityKind.individual) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    value: taxpayerHasSsn.value,
                    onChanged: (value) => taxpayerHasSsn.value = value,
                    title: Text(l10n.taxUsTaxpayerHasSsn),
                    subtitle: Text(l10n.taxUsSsnHint),
                    secondary: SkribbleIcon(
                      data: OpenBudgetIcons.document,
                      color: palette.ink,
                    ),
                  ),
                  if (filingStatus.value ==
                      UsFilingStatus.marriedFilingJointly) ...[
                    const Divider(height: 1),
                    SwitchListTile(
                      value: spouseHasSsn.value,
                      onChanged: (value) => spouseHasSsn.value = value,
                      title: Text(l10n.taxUsSpouseHasSsn),
                      subtitle: Text(l10n.taxUsSsnHint),
                      secondary: SkribbleIcon(
                        data: OpenBudgetIcons.people,
                        color: palette.ink,
                      ),
                    ),
                  ],
                  const Divider(height: 1),
                  SwitchListTile(
                    value: taxpayer65OrOlder.value,
                    onChanged: (value) => taxpayer65OrOlder.value = value,
                    title: Text(l10n.taxUsTaxpayer65OrOlder),
                    secondary: SkribbleIcon(
                      data: OpenBudgetIcons.nature,
                      color: palette.ink,
                    ),
                  ),
                  if (filingStatus.value ==
                      UsFilingStatus.marriedFilingJointly) ...[
                    const Divider(height: 1),
                    SwitchListTile(
                      value: spouse65OrOlder.value,
                      onChanged: (value) => spouse65OrOlder.value = value,
                      title: Text(l10n.taxUsSpouse65OrOlder),
                      secondary: SkribbleIcon(
                        data: OpenBudgetIcons.nature,
                        color: palette.ink,
                      ),
                    ),
                  ],
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ObTextField(
                          controller: dependentsUnder17Controller,
                          labelText: l10n.taxUsDependentsUnder17,
                          hintText: l10n.taxUsDependentsCountHint,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        ObTextField(
                          controller: dependents17OrOlderController,
                          labelText: l10n.taxUsDependents17OrOlder,
                          hintText: l10n.taxUsDependentsCountHint,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    value: dependentsHaveSsn.value,
                    onChanged: (value) => dependentsHaveSsn.value = value,
                    title: Text(l10n.taxUsDependentsSsn),
                    subtitle: Text(l10n.taxUsDependentsSsnHint),
                    secondary: SkribbleIcon(
                      data: OpenBudgetIcons.document,
                      color: palette.ink,
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: ObTextField(
                      controller: foreignExclusionController,
                      labelText: l10n.taxUsForeignEarnedIncomeExclusion,
                      hintText: l10n.taxUsForeignEarnedIncomeExclusionHint,
                      prefixText: CurrencyCode.usd.symbol,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
                if (entity == TaxEntityKind.soleTrader) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    value: specifiedServiceTrade.value,
                    onChanged: (value) => specifiedServiceTrade.value = value,
                    title: Text(l10n.taxUsSpecifiedServiceTrade),
                    subtitle: Text(l10n.taxUsSpecifiedServiceTradeHint),
                    secondary: SkribbleIcon(
                      data: OpenBudgetIcons.store,
                      color: palette.ink,
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: ObDropdown<UsHomeOfficeMethod>(
                      value: homeOfficeMethod.value,
                      labelText: l10n.taxUsHomeOfficeMethod,
                      items: [
                        for (final method in UsHomeOfficeMethod.values)
                          DropdownMenuItem(
                            value: method,
                            child: Text(
                              taxHomeOfficeMethodLabel(l10n, method),
                            ),
                          ),
                      ],
                      onChanged: (method) {
                        if (method != null) homeOfficeMethod.value = method;
                      },
                    ),
                  ),
                ],
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
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(SpacingTokens.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ObDropdown<NgSmallCompanyCeiling>(
                        value: smallCompanyCeiling.value,
                        labelText: l10n.taxNgSmallCompanyCeiling,
                        items: [
                          DropdownMenuItem(
                            value: NgSmallCompanyCeiling.ntaGazette,
                            child: Text(l10n.taxNgSmallCompanyCeilingGazette),
                          ),
                          DropdownMenuItem(
                            value: NgSmallCompanyCeiling.ntaaIntended,
                            child: Text(
                              l10n.taxNgSmallCompanyCeilingIntended,
                            ),
                          ),
                        ],
                        onChanged: (ceiling) {
                          if (ceiling != null) {
                            smallCompanyCeiling.value = ceiling;
                          }
                        },
                      ),
                      const SizedBox(height: SpacingTokens.xs),
                      Text(
                        l10n.taxNgSmallCompanyCeilingHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: palette.mutedInk,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: mneGroupMember.value,
                  onChanged: (value) => mneGroupMember.value = value,
                  title: Text(l10n.taxNgMneGroupMember),
                  subtitle: Text(l10n.taxNgMneGroupMemberHint),
                  secondary: SkribbleIcon(
                    data: OpenBudgetIcons.network,
                    color: palette.ink,
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
                if (jointAssessment.value &&
                    entity == TaxEntityKind.individual) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    value: spouseEmployed.value,
                    onChanged: (value) => spouseEmployed.value = value,
                    title: Text(l10n.taxDeSpouseEmployed),
                    subtitle: Text(l10n.taxDeSpouseEmployedHint),
                    secondary: SkribbleIcon(
                      data: OpenBudgetIcons.people,
                      color: palette.ink,
                    ),
                  ),
                ],
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
                if (churchTax.value)
                  Padding(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: ObDropdown<String>(
                      value: churchState.value?.name ?? 'none',
                      labelText: l10n.taxDeChurchState,
                      hintText: l10n.taxDeChurchStateHint,
                      items: [
                        DropdownMenuItem(
                          value: 'none',
                          child: Text(l10n.taxDeChurchStateNone),
                        ),
                        for (final state in DeBundesland.values)
                          DropdownMenuItem(
                            value: state.name,
                            child: Text(taxDeBundeslandLabel(l10n, state)),
                          ),
                      ],
                      onChanged: (value) {
                        churchState.value = value == null || value == 'none'
                            ? null
                            : _bundesland(value);
                      },
                    ),
                  ),
                if (entity == TaxEntityKind.soleTrader) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: ObDropdown<DeEinkunftsArt>(
                      value: einkunftsArt.value,
                      labelText: l10n.taxDeEinkunftsArt,
                      hintText: l10n.taxDeEinkunftsArtHint,
                      items: [
                        for (final art in DeEinkunftsArt.values)
                          DropdownMenuItem(
                            value: art,
                            child: Text(taxDeEinkunftsArtLabel(l10n, art)),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) einkunftsArt.value = value;
                      },
                    ),
                  ),
                ],
                if (entity == TaxEntityKind.individual) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ObTextField(
                          controller: childrenController,
                          labelText: l10n.taxDeChildren,
                          hintText: l10n.taxDeChildrenHint,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        ObTextField(
                          controller: pensionController,
                          labelText: l10n.taxDeStatutoryPension,
                          hintText: l10n.taxDeStatutoryPensionHint,
                          prefixText: CurrencyCode.eur.symbol,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        ObTextField(
                          controller: commuteKmController,
                          labelText: l10n.taxDeCommuteKm,
                          hintText: l10n.taxDeCommuteKmHint,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: SpacingTokens.md),
                        ObTextField(
                          controller: commuteDaysController,
                          labelText: l10n.taxDeCommuteDays,
                          hintText: l10n.taxDeCommuteDaysHint,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
                if (entity != TaxEntityKind.individual) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(SpacingTokens.md),
                    child: ObTextField(
                      controller: priorTurnoverController,
                      labelText: l10n.taxDePriorTurnover,
                      hintText: l10n.taxDePriorTurnoverHint,
                      prefixText: CurrencyCode.eur.symbol,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                ],
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

/// The days an accounting period may end on for [month], allowing 29
/// February: a year end that has no leap day is treated as 28 February by
/// the rule pack.
int _daysInMonth({required int month, required bool leap}) => switch (month) {
  2 => leap ? 29 : 28,
  4 || 6 || 9 || 11 => 30,
  _ => 31,
};

/// Parses a whole count such as children, kilometres or days, or null when
/// the text is not a non-negative whole number.
int? _wholeCount(String text) {
  final normalized = text.trim();
  if (normalized.isEmpty) return 0;
  return int.tryParse(normalized);
}

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

/// A dependent count field value, or zero when it is not a whole number.
int _countOf(TextEditingController controller) =>
    int.tryParse(controller.text.trim()) ?? 0;

/// Resolves the dropdown value, which is always a known Bundesland name.
DeBundesland _bundesland(String name) => DeBundesland.values.byName(name);
