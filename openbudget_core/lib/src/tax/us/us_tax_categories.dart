import 'package:openbudget_core/src/tax/tax_model.dart';

const Set<TaxEntityKind> _individualOnly = {TaxEntityKind.individual};
const Set<TaxEntityKind> _soleTraderOnly = {TaxEntityKind.soleTrader};
const Set<TaxEntityKind> _companyOnly = {TaxEntityKind.company};

/// Categories that appear on an individual's Form 1040 and its schedules.
///
/// The order follows the return: income, adjustments, itemized deductions,
/// then payments.
const List<TaxCategory> usIndividualCategories = [
  TaxCategory(
    code: 'us.ind.wages',
    label: 'Wages, salaries, tips',
    kind: TaxCategoryKind.income,
    entityKinds: _individualOnly,
    reportReference: 'Form 1040, line 1a',
  ),
  TaxCategory(
    code: 'us.ind.tax_exempt_interest',
    label: 'Tax-exempt interest',
    kind: TaxCategoryKind.outOfScope,
    entityKinds: _individualOnly,
    reportReference: 'Form 1040, line 2a',
    description:
        'Not included in taxable income, but it is added to modified adjusted '
        'gross income for the net investment income tax.',
  ),
  TaxCategory(
    code: 'us.ind.taxable_interest',
    label: 'Taxable interest',
    kind: TaxCategoryKind.income,
    entityKinds: _individualOnly,
    reportReference: 'Form 1040, line 2b',
  ),
  TaxCategory(
    code: 'us.ind.qualified_dividends',
    label: 'Qualified dividends',
    kind: TaxCategoryKind.income,
    entityKinds: _individualOnly,
    reportReference: 'Form 1040, line 3a',
    description:
        'Taxed at long-term capital gains rates. Do not also include these '
        'amounts in ordinary dividends.',
  ),
  TaxCategory(
    code: 'us.ind.dividends',
    label: 'Ordinary dividends (not qualified)',
    kind: TaxCategoryKind.income,
    entityKinds: _individualOnly,
    reportReference: 'Form 1040, line 3b',
    description:
        'Only the non-qualified part. Qualified dividends belong in '
        'us.ind.qualified_dividends so they are not taxed twice.',
  ),
  TaxCategory(
    code: 'us.ind.capital_gain_distributions',
    label: 'Capital gain distributions',
    kind: TaxCategoryKind.income,
    entityKinds: _individualOnly,
    reportReference: 'Form 1040, line 7a',
  ),
  TaxCategory(
    code: 'us.ind.short_term_capital_gains',
    label: 'Short-term capital gains',
    kind: TaxCategoryKind.income,
    entityKinds: _individualOnly,
    reportReference: 'Schedule D (Form 1040), line 7',
  ),
  TaxCategory(
    code: 'us.ind.long_term_capital_gains',
    label: 'Long-term capital gains',
    kind: TaxCategoryKind.income,
    entityKinds: _individualOnly,
    reportReference: 'Schedule D (Form 1040), line 15',
  ),
  TaxCategory(
    code: 'us.ind.capital_losses',
    label: 'Capital losses',
    kind: TaxCategoryKind.expense,
    entityKinds: _individualOnly,
    reportReference: 'Schedule D (Form 1040), line 21',
    description: r'Net capital loss. It offsets short-term gains first, then long-term gains. Excess loss is allowed against ordinary income up to $3,000 ($1,500 if married filing separately); carryforwards are not tracked.',
  ),
  TaxCategory(
    code: 'us.ind.other_income',
    label: 'Other income',
    kind: TaxCategoryKind.income,
    entityKinds: _individualOnly,
    reportReference: 'Schedule 1 (Form 1040), line 8z',
  ),
  TaxCategory(
    code: 'us.ind.hsa_contribution',
    label: 'Health savings account deduction',
    kind: TaxCategoryKind.relief,
    entityKinds: _individualOnly,
    reportReference: 'Schedule 1 (Form 1040), line 13',
    description:
        'Taken as entered. Eligibility requires high-deductible health plan '
        'coverage and the annual contribution limit is not verified here.',
  ),
  TaxCategory(
    code: 'us.ind.ira_contribution',
    label: 'Traditional IRA deduction',
    kind: TaxCategoryKind.relief,
    entityKinds: _individualOnly,
    reportReference: 'Schedule 1 (Form 1040), line 20',
    description:
        'Taken as entered. Deductibility depends on workplace retirement plan '
        'coverage and income; the pack does not verify the phase-out.',
  ),
  TaxCategory(
    code: 'us.ind.self_employed_retirement',
    label: 'Self-employed SEP, SIMPLE, and qualified plans',
    kind: TaxCategoryKind.relief,
    entityKinds: _individualOnly,
    reportReference: 'Schedule 1 (Form 1040), line 16',
    description:
        'Taken as entered. The pack does not test the contribution against the '
        'annual addition or compensation limits.',
  ),
  TaxCategory(
    code: 'us.ind.itemized_deductions',
    label: 'Itemized deductions',
    kind: TaxCategoryKind.relief,
    entityKinds: _individualOnly,
    reportReference: 'Schedule A (Form 1040), line 17',
    description:
        'A single user-entered total. The pack compares it with the standard '
        'deduction and does not recompute the individual Schedule A lines.',
  ),
  TaxCategory(
    code: 'us.ind.federal_withholding',
    label: 'Federal income tax withheld',
    kind: TaxCategoryKind.taxPaid,
    entityKinds: _individualOnly,
    reportReference: 'Form 1040, line 25a',
  ),
  TaxCategory(
    code: 'us.ind.estimated_tax_payments',
    label: 'Estimated tax payments',
    kind: TaxCategoryKind.taxPaid,
    entityKinds: _individualOnly,
    reportReference: 'Form 1040, line 26',
  ),
];

/// Categories that appear on Schedule C (Form 1040).
///
/// Line references follow the 2026 form, whose line numbers match recent
/// years.
const List<TaxCategory> usScheduleCCategories = [
  TaxCategory(
    code: 'us.sch_c.gross_receipts',
    label: 'Gross receipts or sales',
    kind: TaxCategoryKind.income,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 1',
  ),
  TaxCategory(
    code: 'us.sch_c.returns_and_allowances',
    label: 'Returns and allowances',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 2',
  ),
  TaxCategory(
    code: 'us.sch_c.cost_of_goods_sold',
    label: 'Cost of goods sold',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 4',
    description:
        'Taken as entered from the inventory worksheet; the pack does not '
        'recompute inventory accounting.',
  ),
  TaxCategory(
    code: 'us.sch_c.other_income',
    label: 'Other income',
    kind: TaxCategoryKind.income,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 6',
  ),
  TaxCategory(
    code: 'us.sch_c.advertising',
    label: 'Advertising',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 8',
  ),
  TaxCategory(
    code: 'us.sch_c.car_and_truck',
    label: 'Car and truck expenses',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 9',
  ),
  TaxCategory(
    code: 'us.sch_c.commissions_and_fees',
    label: 'Commissions and fees',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 10',
  ),
  TaxCategory(
    code: 'us.sch_c.contract_labor',
    label: 'Contract labor',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 11',
  ),
  TaxCategory(
    code: 'us.sch_c.depreciation',
    label: 'Depreciation and section 179 expense deduction',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 13',
    description:
        'Taken as entered. The pack does not apply the annual section 179 '
        'limits or recompute a depreciation schedule.',
  ),
  TaxCategory(
    code: 'us.sch_c.employee_benefit_programs',
    label: 'Employee benefit programs',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 14',
  ),
  TaxCategory(
    code: 'us.sch_c.insurance',
    label: 'Insurance (other than health)',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 15',
  ),
  TaxCategory(
    code: 'us.sch_c.mortgage_interest',
    label: 'Mortgage interest',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 16a',
  ),
  TaxCategory(
    code: 'us.sch_c.vehicle_loan_interest',
    label: 'Vehicle loan interest',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 16b',
  ),
  TaxCategory(
    code: 'us.sch_c.other_interest',
    label: 'Other interest',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 16c',
  ),
  TaxCategory(
    code: 'us.sch_c.legal_and_professional',
    label: 'Legal and professional services',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 17',
  ),
  TaxCategory(
    code: 'us.sch_c.office_expense',
    label: 'Office expense',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 18',
  ),
  TaxCategory(
    code: 'us.sch_c.pension_and_profit_sharing',
    label: 'Pension and profit-sharing plans',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 19',
  ),
  TaxCategory(
    code: 'us.sch_c.vehicle_rent',
    label: 'Rent or lease: vehicles, machinery, and equipment',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 20a',
  ),
  TaxCategory(
    code: 'us.sch_c.rent',
    label: 'Rent or lease: other business property',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 20b',
  ),
  TaxCategory(
    code: 'us.sch_c.repairs',
    label: 'Repairs and maintenance',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 21',
  ),
  TaxCategory(
    code: 'us.sch_c.supplies',
    label: 'Supplies',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 22',
  ),
  TaxCategory(
    code: 'us.sch_c.taxes_and_licenses',
    label: 'Taxes and licenses',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 23',
  ),
  TaxCategory(
    code: 'us.sch_c.travel',
    label: 'Travel',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 24a',
  ),
  TaxCategory(
    code: 'us.sch_c.meals',
    label: 'Deductible meals',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 24b',
    description:
        'Enter the full business-use meal cost. The pack applies the 50% '
        'business meal limit.',
  ),
  TaxCategory(
    code: 'us.sch_c.utilities',
    label: 'Utilities',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 25',
  ),
  TaxCategory(
    code: 'us.sch_c.wages',
    label: 'Wages (less employment credits)',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 26',
  ),
  TaxCategory(
    code: 'us.sch_c.other_expenses',
    label: 'Other expenses',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 27b',
  ),
  TaxCategory(
    code: 'us.sch_c.home_office',
    label: 'Expenses for business use of your home (simplified method)',
    kind: TaxCategoryKind.expense,
    entityKinds: _soleTraderOnly,
    reportReference: 'Schedule C (Form 1040), line 30',
    description: r'Simplified method only. Capped at $1,500: $5 per square foot for up to 300 square feet.',
  ),
];

/// Categories that appear on the Form 1120 of a C corporation.
const List<TaxCategory> usCompanyCategories = [
  TaxCategory(
    code: 'us.co.gross_receipts',
    label: 'Gross receipts or sales',
    kind: TaxCategoryKind.income,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 1a',
  ),
  TaxCategory(
    code: 'us.co.returns_and_allowances',
    label: 'Returns and allowances',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 1b',
  ),
  TaxCategory(
    code: 'us.co.cost_of_goods_sold',
    label: 'Cost of goods sold',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 2',
    description:
        'Taken as entered from Form 1125-A; the pack does not recompute '
        'inventory accounting.',
  ),
  TaxCategory(
    code: 'us.co.dividends',
    label: 'Dividends and inclusions',
    kind: TaxCategoryKind.income,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 4',
  ),
  TaxCategory(
    code: 'us.co.interest',
    label: 'Interest',
    kind: TaxCategoryKind.income,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 5',
  ),
  TaxCategory(
    code: 'us.co.gross_rents',
    label: 'Gross rents',
    kind: TaxCategoryKind.income,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 6',
  ),
  TaxCategory(
    code: 'us.co.gross_royalties',
    label: 'Gross royalties',
    kind: TaxCategoryKind.income,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 7',
  ),
  TaxCategory(
    code: 'us.co.capital_gain_net_income',
    label: 'Capital gain net income',
    kind: TaxCategoryKind.income,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 8',
  ),
  TaxCategory(
    code: 'us.co.capital_loss',
    label: 'Capital loss (net)',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 8',
    description:
        'Enter a net capital loss as a positive amount. It reduces total '
        'income rather than being a deduction on line 27.',
  ),
  TaxCategory(
    code: 'us.co.net_gain',
    label: 'Net gain from Form 4797',
    kind: TaxCategoryKind.income,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 9',
  ),
  TaxCategory(
    code: 'us.co.net_loss',
    label: 'Net loss from Form 4797',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 9',
    description:
        'Enter a net loss as a positive amount. It reduces total income '
        'rather than being a deduction on line 27.',
  ),
  TaxCategory(
    code: 'us.co.other_income',
    label: 'Other income',
    kind: TaxCategoryKind.income,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 10',
  ),
  TaxCategory(
    code: 'us.co.officer_compensation',
    label: 'Compensation of officers',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 12',
  ),
  TaxCategory(
    code: 'us.co.salaries_and_wages',
    label: 'Salaries and wages',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 13',
  ),
  TaxCategory(
    code: 'us.co.repairs',
    label: 'Repairs and maintenance',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 14',
  ),
  TaxCategory(
    code: 'us.co.bad_debts',
    label: 'Bad debts',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 15',
  ),
  TaxCategory(
    code: 'us.co.rents',
    label: 'Rents',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 16',
  ),
  TaxCategory(
    code: 'us.co.taxes_and_licenses',
    label: 'Taxes and licenses',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 17',
  ),
  TaxCategory(
    code: 'us.co.interest_expense',
    label: 'Interest',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 18',
  ),
  TaxCategory(
    code: 'us.co.charitable_contributions',
    label: 'Charitable contributions',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 19',
  ),
  TaxCategory(
    code: 'us.co.depreciation',
    label: 'Depreciation',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 20',
    description: 'Taken as entered. The pack does not recompute a depreciation schedule.',
  ),
  TaxCategory(
    code: 'us.co.depletion',
    label: 'Depletion',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 21',
  ),
  TaxCategory(
    code: 'us.co.advertising',
    label: 'Advertising',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 22',
  ),
  TaxCategory(
    code: 'us.co.pension_and_profit_sharing',
    label: 'Pension, profit-sharing, etc., plans',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 23',
  ),
  TaxCategory(
    code: 'us.co.employee_benefit_programs',
    label: 'Employee benefit programs',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 24',
  ),
  TaxCategory(
    code: 'us.co.other_deductions',
    label: 'Other deductions',
    kind: TaxCategoryKind.expense,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 26',
  ),
  TaxCategory(
    code: 'us.co.estimated_tax_payments',
    label: 'Estimated tax payments',
    kind: TaxCategoryKind.taxPaid,
    entityKinds: _companyOnly,
    reportReference: 'Form 1120, line 33',
  ),
];

/// Every category this pack knows, across all entity kinds.
const List<TaxCategory> allUsTaxCategories = [
  ...usIndividualCategories,
  ...usScheduleCCategories,
  ...usCompanyCategories,
];
