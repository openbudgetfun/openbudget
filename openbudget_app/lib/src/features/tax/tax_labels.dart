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
      UsFilingStatus.qualifyingSurvivingSpouse =>
        l10n.taxUsFilingQualifyingSurvivingSpouse,
    };

/// The label for the Schedule C home office method.
String taxHomeOfficeMethodLabel(
  AppLocalizations l10n,
  UsHomeOfficeMethod method,
) => switch (method) {
  UsHomeOfficeMethod.simplified => l10n.taxUsHomeOfficeSimplified,
  UsHomeOfficeMethod.regular => l10n.taxUsHomeOfficeRegular,
};

/// The name of a German Land, as the dropdown of church-tax rates shows it.
String taxDeBundeslandLabel(AppLocalizations l10n, DeBundesland state) =>
    switch (state) {
      DeBundesland.badenWuerttemberg => l10n.taxDeBundeslandBw,
      DeBundesland.bayern => l10n.taxDeBundeslandBy,
      DeBundesland.berlin => l10n.taxDeBundeslandBe,
      DeBundesland.brandenburg => l10n.taxDeBundeslandBb,
      DeBundesland.bremen => l10n.taxDeBundeslandHb,
      DeBundesland.hamburg => l10n.taxDeBundeslandHh,
      DeBundesland.hessen => l10n.taxDeBundeslandHe,
      DeBundesland.mecklenburgVorpommern => l10n.taxDeBundeslandMv,
      DeBundesland.niedersachsen => l10n.taxDeBundeslandNi,
      DeBundesland.nordrheinWestfalen => l10n.taxDeBundeslandNw,
      DeBundesland.rheinlandPfalz => l10n.taxDeBundeslandRp,
      DeBundesland.saarland => l10n.taxDeBundeslandSl,
      DeBundesland.sachsen => l10n.taxDeBundeslandSn,
      DeBundesland.sachsenAnhalt => l10n.taxDeBundeslandSt,
      DeBundesland.schleswigHolstein => l10n.taxDeBundeslandSh,
      DeBundesland.thueringen => l10n.taxDeBundeslandTh,
    };

/// The label for a German sole trader's Einkunftsart.
String taxDeEinkunftsArtLabel(AppLocalizations l10n, DeEinkunftsArt art) =>
    switch (art) {
      DeEinkunftsArt.freiberuflich => l10n.taxDeEinkunftsArtFreiberuflich,
      DeEinkunftsArt.gewerblich => l10n.taxDeEinkunftsArtGewerblich,
    };
