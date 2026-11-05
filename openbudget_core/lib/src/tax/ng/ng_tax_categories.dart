part of 'ng_tax_rules.dart';

const Set<TaxEntityKind> _individualKinds = {TaxEntityKind.individual};
const Set<TaxEntityKind> _soleTraderKinds = {TaxEntityKind.soleTrader};
const Set<TaxEntityKind> _companyKinds = {TaxEntityKind.company};

const String _vatOutputDescription =
    'Use this for a standalone VAT entry. Otherwise record the VAT in the '
    'sales tax field of the sale, not both.';

const String _vatInputDescription =
    'Use this for a standalone VAT entry. Otherwise record the VAT in the '
    'sales tax field of the purchase, not both.';

/// The Nigeria category catalog.
///
/// Codes are stable and prefixed by jurisdiction and entity:
/// `ng.ind.*` for individuals, `ng.biz.*` for sole traders and `ng.co.*` for
/// companies.
abstract final class _NgTaxCategories {
  static const List<TaxCategory> individual = [
    TaxCategory(
      code: 'ng.ind.employment.salary',
      label: 'Salaries, wages, fees and allowances',
      kind: TaxCategoryKind.income,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.4(2)(a)',
      description: 'Employment income for the year of assessment.',
    ),
    TaxCategory(
      code: 'ng.ind.employment.benefits_in_kind',
      label: 'Benefits in kind and perquisites',
      kind: TaxCategoryKind.income,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.4(2)(a), s.14',
      description: 'The taxable value of benefits in kind and perquisites.',
    ),
    TaxCategory(
      code: 'ng.ind.employment.bonus',
      label: 'Bonuses, premiums and commissions',
      kind: TaxCategoryKind.income,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.4(2)(a)',
      description: 'One-off or periodic employment payments.',
    ),
    TaxCategory(
      code: 'ng.ind.employment.pension',
      label: 'Pension and annuity income',
      kind: TaxCategoryKind.income,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.4(2)(b)',
      description: 'Pension, annuity and similar retirement income.',
    ),
    TaxCategory(
      code: 'ng.ind.investment.interest',
      label: 'Interest',
      kind: TaxCategoryKind.income,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.4(1)(b), s.4(6)',
      description: 'Interest and similar returns, before any final tax.',
    ),
    TaxCategory(
      code: 'ng.ind.investment.rent',
      label: 'Rent',
      kind: TaxCategoryKind.income,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.4(1)(b)',
      description: 'Rent from land or buildings.',
    ),
    TaxCategory(
      code: 'ng.ind.investment.royalty',
      label: 'Royalties',
      kind: TaxCategoryKind.income,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.4(1)(b)',
    ),
    TaxCategory(
      code: 'ng.ind.investment.dividend_foreign',
      label: 'Foreign dividend brought in through approved channels',
      kind: TaxCategoryKind.outOfScope,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.163(1)(s)',
      description:
          'Exempt when brought into Nigeria through approved channels '
          '(NTA s.163(1)(s)). Record a foreign dividend that is not brought '
          'in through approved channels as other income instead.',
    ),
    TaxCategory(
      code: 'ng.ind.investment.interest_foreign',
      label: 'Foreign interest brought in through approved channels',
      kind: TaxCategoryKind.outOfScope,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.163(1)(s)',
      description:
          'Exempt when brought into Nigeria through approved channels '
          '(NTA s.163(1)(s)). Record foreign interest taxed at source as a '
          'final tax under the interest categories instead.',
    ),
    TaxCategory(
      code: 'ng.ind.investment.rent_foreign',
      label: 'Foreign rent brought in through approved channels',
      kind: TaxCategoryKind.outOfScope,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.163(1)(s)',
      description:
          'Exempt when brought into Nigeria through approved channels '
          '(NTA s.163(1)(s)). Record foreign rent that is not brought in '
          'through approved channels under rent instead.',
    ),
    TaxCategory(
      code: 'ng.ind.investment.royalty_foreign',
      label: 'Foreign royalty brought in through approved channels',
      kind: TaxCategoryKind.outOfScope,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.163(1)(s)',
      description:
          'Exempt when brought into Nigeria through approved channels '
          '(NTA s.163(1)(s)). Record a foreign royalty that is not brought '
          'in through approved channels under royalties instead.',
    ),
    TaxCategory(
      code: 'ng.ind.investment.dividend_ng',
      label: 'Dividend from a Nigerian company (franked investment income)',
      kind: TaxCategoryKind.outOfScope,
      entityKinds: _individualKinds,
      reportReference: 'NTAA 2025 s.51(3)',
      description:
          'Tax deducted at source is the final tax; the dividend is not '
          'charged to further tax.',
    ),
    TaxCategory(
      code: 'ng.ind.investment.interest_final',
      label: 'Interest on short-term securities and corporate bonds',
      kind: TaxCategoryKind.outOfScope,
      entityKinds: _individualKinds,
      reportReference: 'NTAA 2025 s.51(5)',
      description:
          'Interest earned by an individual after deduction of tax at source '
          'is not charged to further tax.',
    ),
    TaxCategory(
      code: 'ng.ind.other_income',
      label: 'Other income, profit or gain',
      kind: TaxCategoryKind.income,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.4(1)(k), s.4(5)',
    ),
    TaxCategory(
      code: 'ng.ind.gain.proceeds',
      label: 'Consideration for disposal of a chargeable asset',
      kind: TaxCategoryKind.disposalProceeds,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.33',
      description: 'Disposal proceeds, including any sales tax charged.',
    ),
    TaxCategory(
      code: 'ng.ind.gain.cost',
      label: 'Acquisition cost of a chargeable asset',
      kind: TaxCategoryKind.disposalCost,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.33, s.39',
      description: 'Cost of acquisition and incidental disposal costs.',
    ),
    TaxCategory(
      code: 'ng.ind.relief.pension',
      label: "The individual's contributions under the Pension Reform Act",
      kind: TaxCategoryKind.relief,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.30(2)(a)(iii)',
      description:
          "The individual's own contributions to an approved pension scheme.",
    ),
    TaxCategory(
      code: 'ng.ind.relief.nhf',
      label: "The individual's contributions under the National Housing Fund",
      kind: TaxCategoryKind.relief,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.30(2)(a)(i)',
    ),
    TaxCategory(
      code: 'ng.ind.relief.nhis',
      label: "The individual's contributions under the National Health Insurance Scheme",
      kind: TaxCategoryKind.relief,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.30(2)(a)(ii)',
    ),
    TaxCategory(
      code: 'ng.ind.relief.housing_loan_interest',
      label: 'Interest on loans for developing an owner-occupied residential house',
      kind: TaxCategoryKind.relief,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.30(2)(a)(iv)',
      description: 'Interest on a loan used to develop an owner-occupied home.',
    ),
    TaxCategory(
      code: 'ng.ind.relief.life_insurance',
      label: 'Annuity or premium on life insurance',
      kind: TaxCategoryKind.relief,
      entityKinds: _individualKinds,
      reportReference: 'NTA 2025 s.30(2)(a)(v)',
      description:
          'Premium on a policy on the individual or their spouse, or a '
          'deferred annuity.',
    ),
    TaxCategory(
      code: 'ng.ind.tax.paye',
      label: 'Pay As You Earn deducted by an employer',
      kind: TaxCategoryKind.taxPaid,
      entityKinds: _individualKinds,
      reportReference: 'NTAA 2025 s.51(6)',
      description: 'PAYE is a credit against the income tax payable.',
    ),
    TaxCategory(
      code: 'ng.ind.tax.wht',
      label: 'Withholding tax credit note',
      kind: TaxCategoryKind.taxPaid,
      entityKinds: _individualKinds,
      reportReference: 'NTAA 2025 s.51(1)',
      description:
          'Withholding tax that is a credit, not the final tax, on this '
          'income.',
    ),
    TaxCategory(
      code: 'ng.ind.tax.final_wht',
      label: 'Withholding tax that is the final tax',
      kind: TaxCategoryKind.outOfScope,
      entityKinds: _individualKinds,
      reportReference: 'NTAA 2025 s.51(3), s.51(5)',
      description:
          'Deducted at source from franked dividends or final-tax interest; '
          'it is not a credit against other income.',
    ),
    TaxCategory(
      code: 'ng.ind.out_of_scope',
      label: 'Gifts, loans and transfers',
      kind: TaxCategoryKind.outOfScope,
      entityKinds: _individualKinds,
      description: 'Money outside the income tax computation.',
    ),
  ];

  static const List<TaxCategory> soleTrader = [
    TaxCategory(
      code: 'ng.biz.revenue.sales',
      label: 'Turnover from the sale of goods',
      kind: TaxCategoryKind.income,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.4(1)(a)',
    ),
    TaxCategory(
      code: 'ng.biz.revenue.services',
      label: 'Turnover from services',
      kind: TaxCategoryKind.income,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.4(1)(d)',
    ),
    TaxCategory(
      code: 'ng.biz.revenue.professional_services',
      label: 'Professional services',
      kind: TaxCategoryKind.income,
      entityKinds: _soleTraderKinds,
      reportReference:
          'NTAA 2025 small business definition (section '
          'unverified)',
      description:
          'A business providing professional services is not a small business '
          'for VAT.',
    ),
    TaxCategory(
      code: 'ng.biz.revenue.other',
      label: 'Other business income',
      kind: TaxCategoryKind.income,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.4(1)(k)',
    ),
    TaxCategory(
      code: 'ng.biz.revenue.zero_rated',
      label: 'Zero-rated supplies (VAT)',
      kind: TaxCategoryKind.income,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.187',
      description:
          'Supplies charged to VAT at 0%, such as exported goods and '
          'services, basic food, medicines, medical services and equipment, '
          'and tuition. Input VAT stays recoverable and they remain taxable '
          'income.',
    ),
    TaxCategory(
      code: 'ng.biz.revenue.exempt',
      label: 'Exempt supplies (VAT)',
      kind: TaxCategoryKind.income,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.186',
      description:
          'Supplies exempt from VAT, such as land and buildings: no output '
          'VAT is charged and input VAT on them is not recoverable. They '
          'remain taxable income. Medical services are not exempt; they are '
          'zero-rated under section 187.',
    ),
    TaxCategory(
      code: 'ng.biz.expense.cost_of_sales',
      label: 'Cost of goods sold',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.20',
    ),
    TaxCategory(
      code: 'ng.biz.expense.salaries',
      label: 'Salaries, wages and other remuneration',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.20(1)(c)',
    ),
    TaxCategory(
      code: 'ng.biz.expense.rent',
      label: 'Rent and premiums on business premises',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.20(1)(b)',
    ),
    TaxCategory(
      code: 'ng.biz.expense.utilities',
      label: 'Utilities',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.20',
    ),
    TaxCategory(
      code: 'ng.biz.expense.professional_fees',
      label: 'Professional and consultancy fees',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.20',
    ),
    TaxCategory(
      code: 'ng.biz.expense.repairs',
      label: 'Repairs of premises, plant and machinery',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.20(1)(d)',
    ),
    TaxCategory(
      code: 'ng.biz.expense.insurance',
      label: 'Insurance',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.20',
    ),
    TaxCategory(
      code: 'ng.biz.expense.transport',
      label: 'Transport and travel',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.20',
    ),
    TaxCategory(
      code: 'ng.biz.expense.advertising',
      label: 'Advertising and promotion',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.20',
    ),
    TaxCategory(
      code: 'ng.biz.expense.bank_charges',
      label: 'Bank charges and interest on business loans',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.20(1)(a)',
    ),
    TaxCategory(
      code: 'ng.biz.expense.bad_debts',
      label: 'Bad or doubtful debts',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.20(1)(h)',
    ),
    TaxCategory(
      code: 'ng.biz.expense.other',
      label: 'Other expenses wholly and exclusively incurred',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.20(1)(j)',
    ),
    TaxCategory(
      code: 'ng.biz.capital.building',
      label: 'Buildings and structures (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 10% a year.',
    ),
    TaxCategory(
      code: 'ng.biz.capital.plant',
      label: 'Plant and machinery (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 20% a year.',
    ),
    TaxCategory(
      code: 'ng.biz.capital.furniture',
      label: 'Furniture and fittings (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 20% a year.',
    ),
    TaxCategory(
      code: 'ng.biz.capital.motor_vehicle',
      label: 'Motor vehicles (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 25% a year.',
    ),
    TaxCategory(
      code: 'ng.biz.capital.software',
      label: 'Software (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 25% a year.',
    ),
    TaxCategory(
      code: 'ng.biz.capital.intangible',
      label: 'Intangible assets (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 10% a year.',
    ),
    TaxCategory(
      code: 'ng.biz.capital.heavy_transport',
      label: 'Heavy transport assets (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Aircraft, vessels, pipelines and rail assets; 10% a year.',
    ),
    TaxCategory(
      code: 'ng.biz.capital.agricultural',
      label: 'Agricultural expenditure (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 10% a year.',
    ),
    TaxCategory(
      code: 'ng.biz.capital.agricultural_equipment',
      label: 'Agricultural equipment (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 20% a year.',
    ),
    TaxCategory(
      code: 'ng.biz.capital.mast',
      label: 'Masts (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 10% a year.',
    ),
    TaxCategory(
      code: 'ng.biz.capital.mining',
      label: 'Mining expenditure (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 20% a year.',
    ),
    TaxCategory(
      code: 'ng.biz.capital.other_equipment',
      label: 'Other equipment (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 20% a year.',
    ),
    TaxCategory(
      code: 'ng.biz.capital.other',
      label: 'Other capital expenditure',
      kind: TaxCategoryKind.expense,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 25% a year.',
    ),
    TaxCategory(
      code: 'ng.biz.tax.wht',
      label: 'Withholding tax credit note',
      kind: TaxCategoryKind.taxPaid,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTAA 2025 s.51(1)',
      description: 'Credited on the owner personal return.',
    ),
    TaxCategory(
      code: 'ng.biz.vat.output',
      label: 'VAT charged on taxable supplies (output tax)',
      kind: TaxCategoryKind.salesTaxCollected,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.148',
      description: _vatOutputDescription,
    ),
    TaxCategory(
      code: 'ng.biz.vat.input',
      label: 'VAT paid on taxable purchases (input tax)',
      kind: TaxCategoryKind.salesTaxPaid,
      entityKinds: _soleTraderKinds,
      reportReference: 'NTA 2025 s.156',
      description: _vatInputDescription,
    ),
    TaxCategory(
      code: 'ng.biz.out_of_scope',
      label: 'Owner drawings, transfers and loans',
      kind: TaxCategoryKind.outOfScope,
      entityKinds: _soleTraderKinds,
      description: 'Money outside the business profit computation.',
    ),
  ];

  static const List<TaxCategory> company = [
    TaxCategory(
      code: 'ng.co.revenue.sales',
      label: 'Turnover from the sale of goods',
      kind: TaxCategoryKind.income,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.4(1)(a)',
    ),
    TaxCategory(
      code: 'ng.co.revenue.services',
      label: 'Turnover from services',
      kind: TaxCategoryKind.income,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.4(1)(d)',
    ),
    TaxCategory(
      code: 'ng.co.revenue.professional_services',
      label: 'Professional services',
      kind: TaxCategoryKind.income,
      entityKinds: _companyKinds,
      reportReference:
          'NTA 2025 small company definition (section '
          'unverified)',
      description:
          'A company providing professional services cannot be a small '
          'company.',
    ),
    TaxCategory(
      code: 'ng.co.revenue.other',
      label: 'Other business income',
      kind: TaxCategoryKind.income,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.4(1)(k)',
    ),
    TaxCategory(
      code: 'ng.co.revenue.zero_rated',
      label: 'Zero-rated supplies (VAT)',
      kind: TaxCategoryKind.income,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.187',
      description:
          'Supplies charged to VAT at 0%, such as exported goods and '
          'services, basic food, medicines, medical services and equipment, '
          'and tuition. Input VAT stays recoverable and they remain taxable '
          'income.',
    ),
    TaxCategory(
      code: 'ng.co.revenue.exempt',
      label: 'Exempt supplies (VAT)',
      kind: TaxCategoryKind.income,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.186',
      description:
          'Supplies exempt from VAT, such as land and buildings: no output '
          'VAT is charged and input VAT on them is not recoverable. They '
          'remain taxable income. Medical services are not exempt; they are '
          'zero-rated under section 187.',
    ),
    TaxCategory(
      code: 'ng.co.revenue.dividend_ng',
      label: 'Dividend from a Nigerian company (franked investment income)',
      kind: TaxCategoryKind.outOfScope,
      entityKinds: _companyKinds,
      reportReference: 'NTAA 2025 s.51(3)',
      description:
          'Tax deducted at source is the final tax; the dividend is not '
          'charged to further tax.',
    ),
    TaxCategory(
      code: 'ng.co.gain.proceeds',
      label: 'Consideration for disposal of a chargeable asset',
      kind: TaxCategoryKind.disposalProceeds,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.27, s.33',
    ),
    TaxCategory(
      code: 'ng.co.gain.cost',
      label: 'Acquisition cost of a chargeable asset',
      kind: TaxCategoryKind.disposalCost,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.33, s.39',
    ),
    TaxCategory(
      code: 'ng.co.expense.cost_of_sales',
      label: 'Cost of goods sold',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.20',
    ),
    TaxCategory(
      code: 'ng.co.expense.salaries',
      label: 'Salaries, wages and other remuneration',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.20(1)(c)',
    ),
    TaxCategory(
      code: 'ng.co.expense.rent',
      label: 'Rent and premiums on business premises',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.20(1)(b)',
    ),
    TaxCategory(
      code: 'ng.co.expense.utilities',
      label: 'Utilities',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.20',
    ),
    TaxCategory(
      code: 'ng.co.expense.professional_fees',
      label: 'Professional and consultancy fees',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.20',
    ),
    TaxCategory(
      code: 'ng.co.expense.repairs',
      label: 'Repairs of premises, plant and machinery',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.20(1)(d)',
    ),
    TaxCategory(
      code: 'ng.co.expense.insurance',
      label: 'Insurance',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.20',
    ),
    TaxCategory(
      code: 'ng.co.expense.transport',
      label: 'Transport and travel',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.20',
    ),
    TaxCategory(
      code: 'ng.co.expense.advertising',
      label: 'Advertising and promotion',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.20',
    ),
    TaxCategory(
      code: 'ng.co.expense.bank_charges',
      label: 'Bank charges and interest on business loans',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.20(1)(a)',
    ),
    TaxCategory(
      code: 'ng.co.expense.bad_debts',
      label: 'Bad or doubtful debts',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.20(1)(h)',
    ),
    TaxCategory(
      code: 'ng.co.expense.other',
      label: 'Other expenses wholly and exclusively incurred',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.20(1)(j)',
    ),
    TaxCategory(
      code: 'ng.co.capital.building',
      label: 'Buildings and structures (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 10% a year.',
    ),
    TaxCategory(
      code: 'ng.co.capital.plant',
      label: 'Plant and machinery (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 20% a year.',
    ),
    TaxCategory(
      code: 'ng.co.capital.furniture',
      label: 'Furniture and fittings (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 20% a year.',
    ),
    TaxCategory(
      code: 'ng.co.capital.motor_vehicle',
      label: 'Motor vehicles (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 25% a year.',
    ),
    TaxCategory(
      code: 'ng.co.capital.software',
      label: 'Software (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 25% a year.',
    ),
    TaxCategory(
      code: 'ng.co.capital.intangible',
      label: 'Intangible assets (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 10% a year.',
    ),
    TaxCategory(
      code: 'ng.co.capital.heavy_transport',
      label: 'Heavy transport assets (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Aircraft, vessels, pipelines and rail assets; 10% a year.',
    ),
    TaxCategory(
      code: 'ng.co.capital.agricultural',
      label: 'Agricultural expenditure (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 10% a year.',
    ),
    TaxCategory(
      code: 'ng.co.capital.agricultural_equipment',
      label: 'Agricultural equipment (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 20% a year.',
    ),
    TaxCategory(
      code: 'ng.co.capital.mast',
      label: 'Masts (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 10% a year.',
    ),
    TaxCategory(
      code: 'ng.co.capital.mining',
      label: 'Mining expenditure (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 20% a year.',
    ),
    TaxCategory(
      code: 'ng.co.capital.other_equipment',
      label: 'Other equipment (capital)',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 20% a year.',
    ),
    TaxCategory(
      code: 'ng.co.capital.other',
      label: 'Other capital expenditure',
      kind: TaxCategoryKind.expense,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 First Schedule Table I',
      description: 'Capital allowance at 25% a year.',
    ),
    TaxCategory(
      code: 'ng.co.tax.wht',
      label: 'Withholding tax credit note',
      kind: TaxCategoryKind.taxPaid,
      entityKinds: _companyKinds,
      reportReference: 'NTAA 2025 s.51(1)',
    ),
    TaxCategory(
      code: 'ng.co.tax.instalment',
      label: 'Companies income tax paid by instalment',
      kind: TaxCategoryKind.taxPaid,
      entityKinds: _companyKinds,
      reportReference: 'NTAA 2025 s.50',
    ),
    TaxCategory(
      code: 'ng.co.vat.output',
      label: 'VAT charged on taxable supplies (output tax)',
      kind: TaxCategoryKind.salesTaxCollected,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.148',
      description: _vatOutputDescription,
    ),
    TaxCategory(
      code: 'ng.co.vat.input',
      label: 'VAT paid on taxable purchases (input tax)',
      kind: TaxCategoryKind.salesTaxPaid,
      entityKinds: _companyKinds,
      reportReference: 'NTA 2025 s.156',
      description: _vatInputDescription,
    ),
    TaxCategory(
      code: 'ng.co.out_of_scope',
      label: 'Dividends, transfers and loans',
      kind: TaxCategoryKind.outOfScope,
      entityKinds: _companyKinds,
      description: 'Money outside the company profit computation.',
    ),
  ];

  /// Every category, by code.
  static final Map<String, TaxCategory> byCode = Map.unmodifiable({
    for (final category in [...individual, ...soleTrader, ...company])
      category.code: category,
  });

  /// The First Schedule Table I rates, in basis points.
  static const Map<String, int> capitalAllowanceRates = {
    'ng.biz.capital.building': 1000,
    'ng.biz.capital.plant': 2000,
    'ng.biz.capital.furniture': 2000,
    'ng.biz.capital.motor_vehicle': 2500,
    'ng.biz.capital.software': 2500,
    'ng.biz.capital.intangible': 1000,
    'ng.biz.capital.heavy_transport': 1000,
    'ng.biz.capital.mast': 1000,
    'ng.biz.capital.mining': 2000,
    'ng.biz.capital.other_equipment': 2000,
    'ng.biz.capital.agricultural': 1000,
    'ng.biz.capital.agricultural_equipment': 2000,
    'ng.biz.capital.other': 2500,
    'ng.co.capital.building': 1000,
    'ng.co.capital.plant': 2000,
    'ng.co.capital.furniture': 2000,
    'ng.co.capital.motor_vehicle': 2500,
    'ng.co.capital.software': 2500,
    'ng.co.capital.intangible': 1000,
    'ng.co.capital.heavy_transport': 1000,
    'ng.co.capital.mast': 1000,
    'ng.co.capital.mining': 2000,
    'ng.co.capital.other_equipment': 2000,
    'ng.co.capital.agricultural': 1000,
    'ng.co.capital.agricultural_equipment': 2000,
    'ng.co.capital.other': 2500,
  };

  /// Whether [code] is a capital allowance category.
  static bool isCapital(String code) => capitalAllowanceRates.containsKey(code);
}
