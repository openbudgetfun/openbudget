import 'package:openbudget_app/l10n/generated/app_localizations.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// The country name shown for a tax jurisdiction.
String taxJurisdictionLabel(
  AppLocalizations l10n,
  TaxJurisdiction jurisdiction,
) => switch (jurisdiction) {
  TaxJurisdiction.gb => l10n.taxJurisdictionGb,
  TaxJurisdiction.us => l10n.taxJurisdictionUs,
  TaxJurisdiction.ng => l10n.taxJurisdictionNg,
  TaxJurisdiction.de => l10n.taxJurisdictionDe,
};

/// The kind of taxpayer shown for a tax entity.
String taxEntityKindLabel(AppLocalizations l10n, TaxEntityKind kind) =>
    switch (kind) {
      TaxEntityKind.individual => l10n.taxEntityIndividual,
      TaxEntityKind.soleTrader => l10n.taxEntitySoleTrader,
      TaxEntityKind.company => l10n.taxEntityCompany,
    };

/// The group heading for a catalog category kind.
String taxCategoryKindLabel(AppLocalizations l10n, TaxCategoryKind kind) =>
    switch (kind) {
      TaxCategoryKind.income => l10n.taxCategoryKindIncome,
      TaxCategoryKind.expense => l10n.taxCategoryKindExpense,
      TaxCategoryKind.disposalProceeds => l10n.taxCategoryKindDisposalProceeds,
      TaxCategoryKind.disposalCost => l10n.taxCategoryKindDisposalCost,
      TaxCategoryKind.relief => l10n.taxCategoryKindRelief,
      TaxCategoryKind.taxPaid => l10n.taxCategoryKindTaxPaid,
      TaxCategoryKind.salesTaxCollected =>
        l10n.taxCategoryKindSalesTaxCollected,
      TaxCategoryKind.salesTaxPaid => l10n.taxCategoryKindSalesTaxPaid,
      TaxCategoryKind.outOfScope => l10n.taxCategoryKindOutOfScope,
    };

/// The label for a UK student loan plan.
String taxStudentLoanPlanLabel(
  AppLocalizations l10n,
  GbStudentLoanPlan plan,
) => switch (plan) {
  GbStudentLoanPlan.plan1 => l10n.taxGbStudentLoanPlan1,
  GbStudentLoanPlan.plan2 => l10n.taxGbStudentLoanPlan2,
  GbStudentLoanPlan.plan4 => l10n.taxGbStudentLoanPlan4,
  GbStudentLoanPlan.plan5 => l10n.taxGbStudentLoanPlan5,
  GbStudentLoanPlan.postgraduate => l10n.taxGbStudentLoanPostgraduate,
};

/// The label for a US filing status.
String taxFilingStatusLabel(AppLocalizations l10n, UsFilingStatus status) =>
    switch (status) {
      UsFilingStatus.single => l10n.taxUsFilingSingle,
      UsFilingStatus.marriedFilingJointly => l10n.taxUsFilingMarriedJointly,
      UsFilingStatus.marriedFilingSeparately =>
        l10n.taxUsFilingMarriedSeparately,
      UsFilingStatus.headOfHousehold => l10n.taxUsFilingHeadOfHousehold,
    };
