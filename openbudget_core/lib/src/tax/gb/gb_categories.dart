import 'package:openbudget_core/src/tax/tax_model.dart';
import 'package:openbudget_core/src/tax/tax_rule_pack.dart';

/// Every category the United Kingdom pack knows, in return order.
///
/// The codes are stable: an envelope or transaction keeps its category when
/// rates change, so a book can be re-reported for a new year unchanged.
const List<TaxCategory> gbCategories = <TaxCategory>[
  // ── Individuals: SA100 ────────────────────────────────────────────────
  TaxCategory(
    code: 'gb.ind.employment',
    label: 'Employment income',
    kind: TaxCategoryKind.income,
    entityKinds: {EntityKind.individual},
    description:
        'Pay, bonuses, commission and taxable benefits from employment, '
        'before tax and National Insurance.',
  ),
  TaxCategory(
    code: 'gb.ind.self_employment',
    label: 'Self-employment profit',
    kind: TaxCategoryKind.income,
    entityKinds: {EntityKind.individual},
    description:
        'Taxable profit from sole trades whose books are not linked to this '
        'individual, after allowable expenses and capital allowances.',
  ),
  TaxCategory(
    code: 'gb.ind.property',
    label: 'Property income',
    kind: TaxCategoryKind.income,
    entityKinds: {EntityKind.individual},
    description:
        'Profit from land or property, after allowable expenses. The '
        'property allowance and finance cost relief are not modelled.',
  ),
  TaxCategory(
    code: 'gb.ind.other_income',
    label: 'Other taxable income',
    kind: TaxCategoryKind.income,
    entityKinds: {EntityKind.individual},
    description:
        'Taxable income with no more specific category, such as '
        'pensions in payment and taxable state benefits.',
  ),
  TaxCategory(
    code: 'gb.ind.savings',
    label: 'Savings interest',
    kind: TaxCategoryKind.income,
    entityKinds: {EntityKind.individual},
    description:
        'Interest from bank and building society accounts outside an ISA, '
        'before tax.',
  ),
  TaxCategory(
    code: 'gb.ind.dividends',
    label: 'Dividends',
    kind: TaxCategoryKind.income,
    entityKinds: {EntityKind.individual},
    description: 'Dividends from companies outside an ISA or pension.',
  ),
  TaxCategory(
    code: 'gb.ind.pension_contributions',
    label: 'Pension contributions',
    kind: TaxCategoryKind.relief,
    entityKinds: {EntityKind.individual},
    description:
        'Gross personal pension contributions, including basic rate relief. '
        'Reported but not deducted; the pension opportunity estimates the '
        'saving instead.',
  ),
  TaxCategory(
    code: 'gb.ind.gift_aid',
    label: 'Gift Aid donations',
    kind: TaxCategoryKind.relief,
    entityKinds: {EntityKind.individual},
    description:
        'Gross Gift Aid donations. Reported but not deducted; Gift Aid is '
        'not modelled.',
  ),
  TaxCategory(
    code: 'gb.ind.capital_gains_proceeds',
    label: 'Disposal proceeds',
    kind: TaxCategoryKind.disposalProceeds,
    entityKinds: {EntityKind.individual},
    description: 'Sale proceeds of chargeable assets.',
  ),
  TaxCategory(
    code: 'gb.ind.capital_gains_cost',
    label: 'Acquisition cost',
    kind: TaxCategoryKind.disposalCost,
    entityKinds: {EntityKind.individual},
    description: 'Allowable acquisition cost of the assets disposed of.',
  ),
  TaxCategory(
    code: 'gb.ind.tax_paid',
    label: 'Tax already paid',
    kind: TaxCategoryKind.taxPaid,
    entityKinds: {EntityKind.individual},
    description: 'PAYE, payments on account and tax withheld for the year.',
  ),
  TaxCategory(
    code: 'gb.ind.out_of_scope',
    label: 'Out of scope',
    kind: TaxCategoryKind.outOfScope,
    entityKinds: {EntityKind.individual},
    description: 'Transfers, loans and gifts received: never taxable.',
  ),

  // ── Sole traders: SA103F ──────────────────────────────────────────────
  TaxCategory(
    code: 'gb.se.turnover',
    label: 'Turnover',
    kind: TaxCategoryKind.income,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 15',
    description: 'Takings, fees, sales or money earned by the business.',
  ),
  TaxCategory(
    code: 'gb.se.other_income',
    label: 'Any other business income',
    kind: TaxCategoryKind.income,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 16',
    description: 'Business income not included in turnover.',
  ),
  TaxCategory(
    code: 'gb.se.cost_of_goods',
    label: 'Cost of goods bought for resale or goods used',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 17',
  ),
  TaxCategory(
    code: 'gb.se.subcontractors',
    label: 'Construction industry – payments to subcontractors',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 18',
  ),
  TaxCategory(
    code: 'gb.se.wages',
    label: 'Wages, salaries and other staff costs',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 19',
  ),
  TaxCategory(
    code: 'gb.se.car_van_travel',
    label: 'Car, van and travel expenses',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 20',
  ),
  TaxCategory(
    code: 'gb.se.rent_rates_power',
    label: 'Rent, rates, power and insurance costs',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 21',
  ),
  TaxCategory(
    code: 'gb.se.repairs',
    label: 'Repairs and maintenance of property and equipment',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 22',
  ),
  TaxCategory(
    code: 'gb.se.phone_office',
    label: 'Phone, fax, stationery and other office costs',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 23',
  ),
  TaxCategory(
    code: 'gb.se.advertising',
    label: 'Advertising and business entertainment costs',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 24',
  ),
  TaxCategory(
    code: 'gb.se.loan_interest',
    label: 'Interest on bank and other loans',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 25',
    description:
        'Interest on loans used for the business, not overdraft '
        'charges or mortgage interest on a home.',
  ),
  TaxCategory(
    code: 'gb.se.bank_charges',
    label: 'Bank, credit card and other financial charges',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 26',
  ),
  TaxCategory(
    code: 'gb.se.bad_debts',
    label: 'Irrecoverable debts written off',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 27',
    description:
        'Debts included in turnover that are now irrecoverable. '
        'General bad debts and fixed asset debts are disallowable.',
  ),
  TaxCategory(
    code: 'gb.se.professional_fees',
    label: 'Accountancy, legal and other professional fees',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 28',
  ),
  TaxCategory(
    code: 'gb.se.depreciation',
    label: 'Depreciation and loss or profit on sale of assets',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 29',
    description:
        'Disallowable. Depreciation and losses on asset sales are added back '
        'and relieved through capital allowances instead.',
  ),
  TaxCategory(
    code: 'gb.se.other_expenses',
    label: 'Other business expenses',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 30',
  ),
  TaxCategory(
    code: 'gb.se.capital_allowances',
    label: 'Annual Investment Allowance',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.soleTrader},
    reportReference: 'SA103F box 49',
    description:
        'Plant and machinery bought for the business, relieved at 100% under '
        'the Annual Investment Allowance. Writing-down allowances are not '
        'modelled.',
  ),
  TaxCategory(
    code: 'gb.se.tax_paid',
    label: 'Tax already paid',
    kind: TaxCategoryKind.taxPaid,
    entityKinds: {EntityKind.soleTrader},
    description: 'Tax paid through Self Assessment or withheld.',
  ),
  TaxCategory(
    code: 'gb.se.out_of_scope',
    label: 'Out of scope',
    kind: TaxCategoryKind.outOfScope,
    entityKinds: {EntityKind.soleTrader},
    description: 'Owner drawings, loans and transfers: never taxable.',
  ),

  // ── Companies: CT600 ──────────────────────────────────────────────────
  TaxCategory(
    code: 'gb.co.turnover',
    label: 'Total turnover from trade',
    kind: TaxCategoryKind.income,
    entityKinds: {EntityKind.company},
    reportReference: 'CT600 box 145',
  ),
  TaxCategory(
    code: 'gb.co.other_income',
    label: 'Income not falling under any other heading',
    kind: TaxCategoryKind.income,
    entityKinds: {EntityKind.company},
    reportReference: 'CT600 box 205',
  ),
  TaxCategory(
    code: 'gb.co.interest_received',
    label: 'Bank, building society or other interest',
    kind: TaxCategoryKind.income,
    entityKinds: {EntityKind.company},
    reportReference: 'CT600 box 170',
  ),
  TaxCategory(
    code: 'gb.co.cost_of_sales',
    label: 'Cost of sales',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.company},
  ),
  TaxCategory(
    code: 'gb.co.wages',
    label: 'Wages, salaries and other staff costs',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.company},
  ),
  TaxCategory(
    code: 'gb.co.rent_rates_power',
    label: 'Rent, rates, power and insurance',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.company},
  ),
  TaxCategory(
    code: 'gb.co.repairs',
    label: 'Repairs and maintenance',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.company},
  ),
  TaxCategory(
    code: 'gb.co.car_van_travel',
    label: 'Car, van and travel expenses',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.company},
  ),
  TaxCategory(
    code: 'gb.co.phone_office',
    label: 'Phone, office and administration',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.company},
  ),
  TaxCategory(
    code: 'gb.co.advertising',
    label: 'Advertising and marketing',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.company},
  ),
  TaxCategory(
    code: 'gb.co.professional_fees',
    label: 'Accountancy, legal and professional fees',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.company},
  ),
  TaxCategory(
    code: 'gb.co.insurance',
    label: 'Insurance',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.company},
  ),
  TaxCategory(
    code: 'gb.co.bank_charges',
    label: 'Bank, credit card and other financial charges',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.company},
  ),
  TaxCategory(
    code: 'gb.co.depreciation',
    label: 'Depreciation and loss or profit on sale of assets',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.company},
    description:
        'Disallowable. Depreciation is added back and relieved through '
        'capital allowances instead.',
  ),
  TaxCategory(
    code: 'gb.co.other_expenses',
    label: 'Other business expenses',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.company},
  ),
  TaxCategory(
    code: 'gb.co.capital_allowances',
    label: 'Annual Investment Allowance',
    kind: TaxCategoryKind.expense,
    entityKinds: {EntityKind.company},
    description:
        'Qualifying plant and machinery claimed at 100%, capped at the '
        'Annual Investment Allowance maximum (cars never qualify). '
        'Writing-down allowances are not modelled.',
  ),
  TaxCategory(
    code: 'gb.co.tax_paid',
    label: 'Corporation Tax already paid',
    kind: TaxCategoryKind.taxPaid,
    entityKinds: {EntityKind.company},
  ),
  TaxCategory(
    code: 'gb.co.out_of_scope',
    label: 'Out of scope',
    kind: TaxCategoryKind.outOfScope,
    entityKinds: {EntityKind.company},
    description: 'Dividends paid to shareholders, loans and transfers.',
  ),

  // ── VAT ───────────────────────────────────────────────────────────────
  TaxCategory(
    code: 'gb.vat.output',
    label: 'VAT charged on sales (output VAT)',
    kind: TaxCategoryKind.salesTaxCollected,
    entityKinds: {EntityKind.soleTrader, EntityKind.company},
    description:
        'VAT charged to customers. If the sale itself is recorded, put the '
        'VAT in the entry’s sales tax field instead of a separate line.',
  ),
  TaxCategory(
    code: 'gb.vat.input',
    label: 'VAT paid on purchases (input VAT)',
    kind: TaxCategoryKind.salesTaxPaid,
    entityKinds: {EntityKind.soleTrader, EntityKind.company},
    description:
        'VAT paid on business purchases and reclaimable on the VAT return.',
  ),
];

/// The catalog above, indexed by [TaxCategory.code].
final Map<String, TaxCategory> gbCategoriesByCode = Map.unmodifiable({
  for (final category in gbCategories) category.code: category,
});

/// The universal catalogue mapped onto GB codes, per book kind
/// (`docs/tax-jurisdictions.md` sections 4.7 and 8.6). An absent code is a
/// deliberate gap, not an oversight: the entry counts as uncategorised
/// rather than land in a box its GB rules may not allow.
///
/// Notable gaps: capital gains and digital-asset entries for sole traders
/// and companies (SA103F and CT600 carry no proceeds box), business
/// expenses for individuals, digital-asset rules (not built yet), and
/// meals everywhere (client hospitality is disallowable and staff
/// entertainment is capped, so a generic meals tag cannot be placed).
const Map<EntityKind, Map<String, String>> gbUniversalCategoryMap = {
  EntityKind.individual: {
    'universal.income.employment': 'gb.ind.employment',
    'universal.income.interest': 'gb.ind.savings',
    'universal.income.dividends': 'gb.ind.dividends',
    'universal.income.rent': 'gb.ind.property',
    'universal.income.pension': 'gb.ind.other_income',
    'universal.income.capital_gains_proceeds': 'gb.ind.capital_gains_proceeds',
    'universal.income.capital_gains_cost': 'gb.ind.capital_gains_cost',
    'universal.income.other': 'gb.ind.other_income',
    'universal.relief.pension': 'gb.ind.pension_contributions',
    'universal.relief.charitable': 'gb.ind.gift_aid',
    'universal.tax.income_tax_withheld': 'gb.ind.tax_paid',
    'universal.tax.instalments': 'gb.ind.tax_paid',
    'universal.out_of_scope.transfers': 'gb.ind.out_of_scope',
    'universal.out_of_scope.loans': 'gb.ind.out_of_scope',
    'universal.out_of_scope.gifts_received': 'gb.ind.out_of_scope',
  },
  EntityKind.soleTrader: {
    'universal.income.self_employment': 'gb.se.turnover',
    'universal.income.other': 'gb.se.other_income',
    'universal.expense.cost_of_goods': 'gb.se.cost_of_goods',
    'universal.expense.wages': 'gb.se.wages',
    'universal.expense.travel': 'gb.se.car_van_travel',
    'universal.expense.vehicle': 'gb.se.car_van_travel',
    'universal.expense.rent': 'gb.se.rent_rates_power',
    'universal.expense.utilities': 'gb.se.rent_rates_power',
    'universal.expense.insurance': 'gb.se.rent_rates_power',
    'universal.expense.office': 'gb.se.phone_office',
    'universal.expense.phone_and_internet': 'gb.se.phone_office',
    'universal.expense.software': 'gb.se.phone_office',
    'universal.expense.professional_fees': 'gb.se.professional_fees',
    'universal.expense.bank_fees': 'gb.se.bank_charges',
    'universal.expense.marketing': 'gb.se.advertising',
    'universal.expense.training': 'gb.se.other_expenses',
    'universal.expense.other': 'gb.se.other_expenses',
    // Plant and machinery bought for the business is relieved at 100%
    // through the Annual Investment Allowance.
    'universal.expense.equipment': 'gb.se.capital_allowances',
    'universal.tax.income_tax_withheld': 'gb.se.tax_paid',
    'universal.tax.instalments': 'gb.se.tax_paid',
    'universal.tax.sales_tax_collected': 'gb.vat.output',
    'universal.tax.sales_tax_paid': 'gb.vat.input',
    'universal.out_of_scope.transfers': 'gb.se.out_of_scope',
    'universal.out_of_scope.loans': 'gb.se.out_of_scope',
    'universal.out_of_scope.gifts_received': 'gb.se.out_of_scope',
    'universal.out_of_scope.owner_capital_and_drawings': 'gb.se.out_of_scope',
  },
  EntityKind.company: {
    'universal.income.self_employment': 'gb.co.turnover',
    'universal.income.interest': 'gb.co.interest_received',
    'universal.income.other': 'gb.co.other_income',
    'universal.expense.cost_of_goods': 'gb.co.cost_of_sales',
    'universal.expense.wages': 'gb.co.wages',
    'universal.expense.travel': 'gb.co.car_van_travel',
    'universal.expense.vehicle': 'gb.co.car_van_travel',
    'universal.expense.rent': 'gb.co.rent_rates_power',
    'universal.expense.utilities': 'gb.co.rent_rates_power',
    'universal.expense.insurance': 'gb.co.insurance',
    'universal.expense.office': 'gb.co.phone_office',
    'universal.expense.phone_and_internet': 'gb.co.phone_office',
    'universal.expense.software': 'gb.co.phone_office',
    'universal.expense.professional_fees': 'gb.co.professional_fees',
    'universal.expense.bank_fees': 'gb.co.bank_charges',
    'universal.expense.marketing': 'gb.co.advertising',
    'universal.expense.training': 'gb.co.other_expenses',
    'universal.expense.other': 'gb.co.other_expenses',
    'universal.expense.equipment': 'gb.co.capital_allowances',
    'universal.tax.income_tax_withheld': 'gb.co.tax_paid',
    'universal.tax.instalments': 'gb.co.tax_paid',
    'universal.tax.sales_tax_collected': 'gb.vat.output',
    'universal.tax.sales_tax_paid': 'gb.vat.input',
    'universal.out_of_scope.transfers': 'gb.co.out_of_scope',
    'universal.out_of_scope.loans': 'gb.co.out_of_scope',
    'universal.out_of_scope.gifts_received': 'gb.co.out_of_scope',
    'universal.out_of_scope.owner_capital_and_drawings': 'gb.co.out_of_scope',
  },
};

/// [TaxRulePack.mapUniversalCategory] for the GB pack.
String? gbMapUniversalCategory(String universalCode, EntityKind kind) =>
    gbUniversalCategoryMap[kind]?[universalCode];
