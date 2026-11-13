import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';

/// The prefix of every universal category code.
const String universalCategoryPrefix = 'universal.';

/// Whether [code] belongs to the country-neutral catalogue.
bool isUniversalCategoryCode(String code) =>
    code.startsWith(universalCategoryPrefix);

const Set<EntityKind> _allKinds = {
  EntityKind.individual,
  EntityKind.soleTrader,
  EntityKind.company,
};

const Set<EntityKind> _individual = {EntityKind.individual};

const Set<EntityKind> _individualAndCompany = {
  EntityKind.individual,
  EntityKind.company,
};

const Set<EntityKind> _businesses = {EntityKind.soleTrader, EntityKind.company};

const Set<EntityKind> _individualAndSoleTrader = {
  EntityKind.individual,
  EntityKind.soleTrader,
};

/// The country-neutral tax category catalogue, from
/// `docs/tax-jurisdictions.md` section 8.6.
///
/// Every servable country accepts these codes, so books in a country with
/// no rule pack can still be tagged, exported and later re-reported when a
/// pack arrives: each pack maps universal codes onto its own
/// ([TaxRulePack.mapUniversalCategory]). [TaxCategory.labelKey] names the
/// `app_en.arb` entry that shows the category in the app;
/// [TaxCategory.label] is the plain-English fallback.
const List<TaxCategory> universalCategories = <TaxCategory>[
  // ── Income ────────────────────────────────────────────────────────────
  TaxCategory(
    code: 'universal.income.employment',
    label: 'Employment income',
    labelKey: 'universalCategoryIncomeEmployment',
    kind: TaxCategoryKind.income,
    entityKinds: _individual,
    description: 'Salary, wages, bonuses and taxable benefits from a job.',
  ),
  TaxCategory(
    code: 'universal.income.self_employment',
    label: 'Business turnover',
    labelKey: 'universalCategoryIncomeSelfEmployment',
    kind: TaxCategoryKind.income,
    entityKinds: {EntityKind.soleTrader},
    description: 'Takings, fees and sales of the business itself.',
  ),
  TaxCategory(
    code: 'universal.income.interest',
    label: 'Interest',
    labelKey: 'universalCategoryIncomeInterest',
    kind: TaxCategoryKind.income,
    entityKinds: _allKinds,
    description: 'Interest from bank accounts and lending.',
  ),
  TaxCategory(
    code: 'universal.income.dividends',
    label: 'Dividends',
    labelKey: 'universalCategoryIncomeDividends',
    kind: TaxCategoryKind.income,
    entityKinds: _individualAndCompany,
    description: 'Dividends from shares held.',
  ),
  TaxCategory(
    code: 'universal.income.rent',
    label: 'Rent',
    labelKey: 'universalCategoryIncomeRent',
    kind: TaxCategoryKind.income,
    entityKinds: _individualAndCompany,
    description: 'Rent from land or buildings.',
  ),
  TaxCategory(
    code: 'universal.income.pension',
    label: 'Pension income',
    labelKey: 'universalCategoryIncomePension',
    kind: TaxCategoryKind.income,
    entityKinds: _individual,
    description: 'Pension and annuity payments received.',
  ),
  TaxCategory(
    code: 'universal.income.capital_gains_proceeds',
    label: 'Asset sale proceeds',
    labelKey: 'universalCategoryIncomeCapitalGainsProceeds',
    kind: TaxCategoryKind.disposalProceeds,
    entityKinds: _individualAndCompany,
    description: 'Sale proceeds of chargeable assets.',
  ),
  TaxCategory(
    code: 'universal.income.capital_gains_cost',
    label: 'Asset acquisition cost',
    labelKey: 'universalCategoryIncomeCapitalGainsCost',
    kind: TaxCategoryKind.disposalCost,
    entityKinds: _individualAndCompany,
    description: 'Acquisition cost of the assets disposed of.',
  ),
  TaxCategory(
    code: 'universal.income.digital_asset_proceeds',
    label: 'Digital asset sale proceeds',
    labelKey: 'universalCategoryIncomeDigitalAssetProceeds',
    kind: TaxCategoryKind.disposalProceeds,
    entityKinds: _allKinds,
    description: 'Proceeds of selling crypto or other digital assets.',
  ),
  TaxCategory(
    code: 'universal.income.digital_asset_cost',
    label: 'Digital asset acquisition cost',
    labelKey: 'universalCategoryIncomeDigitalAssetCost',
    kind: TaxCategoryKind.disposalCost,
    entityKinds: _allKinds,
    description: 'Cost of the digital assets disposed of.',
  ),
  TaxCategory(
    code: 'universal.income.digital_asset_income',
    label: 'Digital asset income',
    labelKey: 'universalCategoryIncomeDigitalAssetIncome',
    kind: TaxCategoryKind.income,
    entityKinds: _allKinds,
    description: 'Staking rewards, mining income and airdrops.',
  ),
  TaxCategory(
    code: 'universal.income.other',
    label: 'Other income',
    labelKey: 'universalCategoryIncomeOther',
    kind: TaxCategoryKind.income,
    entityKinds: _allKinds,
    description: 'Taxable income with no more specific category.',
  ),

  // ── Business expenses ─────────────────────────────────────────────────
  TaxCategory(
    code: 'universal.expense.cost_of_goods',
    label: 'Cost of goods',
    labelKey: 'universalCategoryExpenseCostOfGoods',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Goods bought for resale and materials used.',
  ),
  TaxCategory(
    code: 'universal.expense.office',
    label: 'Office supplies',
    labelKey: 'universalCategoryExpenseOffice',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Stationery, printing and other office supplies.',
  ),
  TaxCategory(
    code: 'universal.expense.rent',
    label: 'Rent',
    labelKey: 'universalCategoryExpenseRent',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Rent for business premises.',
  ),
  TaxCategory(
    code: 'universal.expense.utilities',
    label: 'Utilities',
    labelKey: 'universalCategoryExpenseUtilities',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Electricity, gas, water and other utilities.',
  ),
  TaxCategory(
    code: 'universal.expense.phone_and_internet',
    label: 'Phone and internet',
    labelKey: 'universalCategoryExpensePhoneAndInternet',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Phone, internet and communication costs.',
  ),
  TaxCategory(
    code: 'universal.expense.software',
    label: 'Software',
    labelKey: 'universalCategoryExpenseSoftware',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Software subscriptions and licences.',
  ),
  TaxCategory(
    code: 'universal.expense.travel',
    label: 'Travel',
    labelKey: 'universalCategoryExpenseTravel',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Business travel away from the usual workplace.',
  ),
  TaxCategory(
    code: 'universal.expense.vehicle',
    label: 'Vehicle',
    labelKey: 'universalCategoryExpenseVehicle',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Running costs of business vehicles.',
  ),
  TaxCategory(
    code: 'universal.expense.meals',
    label: 'Meals and entertainment',
    labelKey: 'universalCategoryExpenseMeals',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Business meals and entertainment.',
  ),
  TaxCategory(
    code: 'universal.expense.professional_fees',
    label: 'Professional fees',
    labelKey: 'universalCategoryExpenseProfessionalFees',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Accountants, lawyers and other professional services.',
  ),
  TaxCategory(
    code: 'universal.expense.insurance',
    label: 'Insurance',
    labelKey: 'universalCategoryExpenseInsurance',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Business insurance premiums.',
  ),
  TaxCategory(
    code: 'universal.expense.equipment',
    label: 'Equipment',
    labelKey: 'universalCategoryExpenseEquipment',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Equipment and machinery bought for the business.',
  ),
  TaxCategory(
    code: 'universal.expense.wages',
    label: 'Staff costs',
    labelKey: 'universalCategoryExpenseWages',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Salaries, wages and other staff costs.',
  ),
  TaxCategory(
    code: 'universal.expense.bank_fees',
    label: 'Bank fees',
    labelKey: 'universalCategoryExpenseBankFees',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Bank charges and payment-processing fees.',
  ),
  TaxCategory(
    code: 'universal.expense.marketing',
    label: 'Marketing',
    labelKey: 'universalCategoryExpenseMarketing',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Advertising, marketing and promotion.',
  ),
  TaxCategory(
    code: 'universal.expense.training',
    label: 'Training',
    labelKey: 'universalCategoryExpenseTraining',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Courses and training for the business.',
  ),
  TaxCategory(
    code: 'universal.expense.other',
    label: 'Other business expenses',
    labelKey: 'universalCategoryExpenseOther',
    kind: TaxCategoryKind.expense,
    entityKinds: _businesses,
    description: 'Business expense with no more specific category.',
  ),

  // ── Reliefs and contributions ─────────────────────────────────────────
  TaxCategory(
    code: 'universal.relief.pension',
    label: 'Pension contributions',
    labelKey: 'universalCategoryReliefPension',
    kind: TaxCategoryKind.relief,
    entityKinds: _individual,
    description: 'Contributions to a recognised pension scheme.',
  ),
  TaxCategory(
    code: 'universal.relief.charitable',
    label: 'Charitable gifts',
    labelKey: 'universalCategoryReliefCharitable',
    kind: TaxCategoryKind.relief,
    entityKinds: _individualAndCompany,
    description: 'Gifts to eligible charities.',
  ),
  TaxCategory(
    code: 'universal.relief.medical',
    label: 'Medical',
    labelKey: 'universalCategoryReliefMedical',
    kind: TaxCategoryKind.relief,
    entityKinds: _individual,
    description: 'Medical costs or health contributions that earn relief.',
  ),
  TaxCategory(
    code: 'universal.relief.education',
    label: 'Education',
    labelKey: 'universalCategoryReliefEducation',
    kind: TaxCategoryKind.relief,
    entityKinds: _individual,
    description: 'Education costs that earn relief.',
  ),
  TaxCategory(
    code: 'universal.relief.childcare',
    label: 'Childcare',
    labelKey: 'universalCategoryReliefChildcare',
    kind: TaxCategoryKind.relief,
    entityKinds: _individual,
    description: 'Childcare costs that earn relief.',
  ),
  TaxCategory(
    code: 'universal.relief.mortgage_interest',
    label: 'Mortgage interest',
    labelKey: 'universalCategoryReliefMortgageInterest',
    kind: TaxCategoryKind.relief,
    entityKinds: _individual,
    description: 'Home-loan interest that earns relief.',
  ),
  TaxCategory(
    code: 'universal.relief.social_contributions',
    label: 'Social contributions',
    labelKey: 'universalCategoryReliefSocialContributions',
    kind: TaxCategoryKind.relief,
    entityKinds: _individualAndSoleTrader,
    description: 'Social security or national insurance contributions.',
  ),

  // ── Tax paid ──────────────────────────────────────────────────────────
  TaxCategory(
    code: 'universal.tax.income_tax_withheld',
    label: 'Income tax withheld',
    labelKey: 'universalCategoryTaxIncomeTaxWithheld',
    kind: TaxCategoryKind.taxPaid,
    entityKinds: _individualAndCompany,
    description: 'Income tax withheld at source from income.',
  ),
  TaxCategory(
    code: 'universal.tax.instalments',
    label: 'Tax instalments',
    labelKey: 'universalCategoryTaxInstalments',
    kind: TaxCategoryKind.taxPaid,
    entityKinds: _allKinds,
    description: 'Advance or instalment payments of the year’s tax.',
  ),
  TaxCategory(
    code: 'universal.tax.sales_tax_paid',
    label: 'Sales tax paid on purchases',
    labelKey: 'universalCategoryTaxSalesTaxPaid',
    kind: TaxCategoryKind.salesTaxPaid,
    entityKinds: _businesses,
    description: 'VAT, GST or sales tax paid on business purchases.',
  ),
  TaxCategory(
    code: 'universal.tax.sales_tax_collected',
    label: 'Sales tax collected on sales',
    labelKey: 'universalCategoryTaxSalesTaxCollected',
    kind: TaxCategoryKind.salesTaxCollected,
    entityKinds: _businesses,
    description: 'VAT, GST or sales tax charged to customers.',
  ),

  // ── Out of scope ──────────────────────────────────────────────────────
  TaxCategory(
    code: 'universal.out_of_scope.transfers',
    label: 'Transfers',
    labelKey: 'universalCategoryOutOfScopeTransfers',
    kind: TaxCategoryKind.outOfScope,
    entityKinds: _allKinds,
    description: 'Movements between your own accounts.',
  ),
  TaxCategory(
    code: 'universal.out_of_scope.loans',
    label: 'Loans',
    labelKey: 'universalCategoryOutOfScopeLoans',
    kind: TaxCategoryKind.outOfScope,
    entityKinds: _allKinds,
    description: 'Money borrowed or lent.',
  ),
  TaxCategory(
    code: 'universal.out_of_scope.gifts_received',
    label: 'Gifts received',
    labelKey: 'universalCategoryOutOfScopeGiftsReceived',
    kind: TaxCategoryKind.outOfScope,
    entityKinds: _allKinds,
    description: 'Gifts received, outside tax.',
  ),
  TaxCategory(
    code: 'universal.out_of_scope.owner_capital_and_drawings',
    label: 'Owner capital and drawings',
    labelKey: 'universalCategoryOutOfScopeOwnerCapitalAndDrawings',
    kind: TaxCategoryKind.outOfScope,
    entityKinds: _businesses,
    description: 'Money the owner puts in or takes out of the business.',
  ),
];

/// The catalogue above, indexed by [TaxCategory.code].
final Map<String, TaxCategory> universalCategoriesByCode = Map.unmodifiable({
  for (final category in universalCategories) category.code: category,
});

/// The country-neutral tax catalogue: lookups and per-kind views over
/// [universalCategories].
abstract final class UniversalTaxCategories {
  /// Whether [code] is a universal catalogue code.
  static bool isUniversalCode(String code) => isUniversalCategoryCode(code);

  /// The universal category with [code], or null when the catalogue does
  /// not know it.
  static TaxCategory? category(String code) => universalCategoriesByCode[code];

  /// Universal categories that may appear in books of [kind], catalogue
  /// order.
  static List<TaxCategory> categoriesFor(EntityKind kind) => List.unmodifiable(
    universalCategories.where(
      (category) => category.entityKinds.contains(kind),
    ),
  );
}
