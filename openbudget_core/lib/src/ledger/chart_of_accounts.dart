import 'package:openbudget_core/src/ledger/ledger_account_type.dart';
import 'package:openbudget_core/src/ledger/ledger_system_role.dart';
import 'package:openbudget_core/src/tax/tax_model.dart';

/// One starter account inside a [LedgerChartTemplate].
class ChartAccountTemplate {
  const ChartAccountTemplate({
    required this.code,
    required this.name,
    required this.type,
    this.systemRole,
  });

  /// Illustrative account code within the template's numbering scheme.
  final String code;

  /// Short account name.
  final String name;

  final LedgerAccountType type;

  /// The stable internal role, when this is a system account.
  final LedgerSystemRole? systemRole;

  /// True when the account is structural: system accounts cannot be deleted
  /// or change type.
  bool get isSystem => systemRole != null;
}

/// A starter chart of accounts for one jurisdiction and entity kind.
///
/// Templates are data, not code: every account maps onto a stable
/// [LedgerSystemRole] where the ledger machinery needs one, so users can
/// renumber or rename freely. Codes are illustrative; no jurisdiction
/// prescribes a chart.
class LedgerChartTemplate {
  const LedgerChartTemplate({
    required this.jurisdiction,
    required this.entityKind,
    required this.accounts,
  });

  final TaxJurisdiction jurisdiction;

  final EntityKind entityKind;

  final List<ChartAccountTemplate> accounts;

  /// Returns the template for a set of books, or null when the books have
  /// no starter chart.
  ///
  /// Personal books never get a ledger. Business books in a jurisdiction
  /// with a chart of their own get it; business books in any other country
  /// get the country-neutral [generic] chart, so ledger mode works in
  /// every country.
  static LedgerChartTemplate? forBooks({
    required TaxJurisdiction jurisdiction,
    required EntityKind entityKind,
  }) =>
      _templates[(jurisdiction, entityKind)] ??
      generic(jurisdiction: jurisdiction, entityKind: entityKind);

  /// The country-neutral starter chart, for countries without a rule pack
  /// or a chart of their own.
  ///
  /// Names follow IFRS wording and carry no country's tax vocabulary
  /// beyond the generic indirect-tax control account; [jurisdiction] is
  /// stamped on the template so the books keep their country. Returns
  /// null for personal books, which never carry a ledger.
  static LedgerChartTemplate? generic({
    required TaxJurisdiction jurisdiction,
    required EntityKind entityKind,
  }) {
    if (entityKind == EntityKind.individual) {
      return null;
    }
    return LedgerChartTemplate(
      jurisdiction: jurisdiction,
      entityKind: entityKind,
      accounts: entityKind == EntityKind.company
          ? _genericCompanyAccounts()
          : _genericSoleTraderAccounts(),
    );
  }
}

/// All starter charts, keyed by (jurisdiction, entity kind).
final Map<(TaxJurisdiction, EntityKind), LedgerChartTemplate> _templates = {
  (TaxJurisdiction.gb, EntityKind.company): _gbCompany(),
  (TaxJurisdiction.gb, EntityKind.soleTrader): _gbSoleTrader(),
  (TaxJurisdiction.us, EntityKind.company): _usCompany(),
  (TaxJurisdiction.us, EntityKind.soleTrader): _usSoleTrader(),
  (TaxJurisdiction.ng, EntityKind.company): _ngCompany(),
  (TaxJurisdiction.ng, EntityKind.soleTrader): _ngSoleTrader(),
  (TaxJurisdiction.de, EntityKind.company): _deCompany(),
  (TaxJurisdiction.de, EntityKind.soleTrader): _deSoleTrader(),
};

// -- Shared role accounts ---------------------------------------------------

ChartAccountTemplate _bank(String code, String name) => ChartAccountTemplate(
  code: code,
  name: name,
  type: LedgerAccountType.asset,
  systemRole: LedgerSystemRole.bank,
);

ChartAccountTemplate _ar(String code, String name) => ChartAccountTemplate(
  code: code,
  name: name,
  type: LedgerAccountType.asset,
  systemRole: LedgerSystemRole.accountsReceivable,
);

ChartAccountTemplate _ap(String code, String name) => ChartAccountTemplate(
  code: code,
  name: name,
  type: LedgerAccountType.liability,
  systemRole: LedgerSystemRole.accountsPayable,
);

ChartAccountTemplate _vatControl(String code, String name) =>
    ChartAccountTemplate(
      code: code,
      name: name,
      type: LedgerAccountType.liability,
      systemRole: LedgerSystemRole.vatControl,
    );

ChartAccountTemplate _payroll(String code, String name) => ChartAccountTemplate(
  code: code,
  name: name,
  type: LedgerAccountType.liability,
  systemRole: LedgerSystemRole.payrollLiabilities,
);

ChartAccountTemplate _retainedEarnings(String code, String name) =>
    ChartAccountTemplate(
      code: code,
      name: name,
      type: LedgerAccountType.equity,
      systemRole: LedgerSystemRole.retainedEarnings,
    );

ChartAccountTemplate _openingBalanceEquity(String code, String name) =>
    ChartAccountTemplate(
      code: code,
      name: name,
      type: LedgerAccountType.equity,
      systemRole: LedgerSystemRole.openingBalanceEquity,
    );

ChartAccountTemplate _suspense(String code, String name) =>
    ChartAccountTemplate(
      code: code,
      name: name,
      type: LedgerAccountType.liability,
      systemRole: LedgerSystemRole.suspense,
    );

ChartAccountTemplate _rounding(String code, String name) =>
    ChartAccountTemplate(
      code: code,
      name: name,
      type: LedgerAccountType.expense,
      systemRole: LedgerSystemRole.rounding,
    );

ChartAccountTemplate _realisedFx(String code, String name) =>
    ChartAccountTemplate(
      code: code,
      name: name,
      type: LedgerAccountType.expense,
      systemRole: LedgerSystemRole.realisedFx,
    );

ChartAccountTemplate _unrealisedFx(String code, String name) =>
    ChartAccountTemplate(
      code: code,
      name: name,
      type: LedgerAccountType.expense,
      systemRole: LedgerSystemRole.unrealisedFx,
    );

ChartAccountTemplate _plain(
  String code,
  String name,
  LedgerAccountType type,
) => ChartAccountTemplate(code: code, name: name, type: type);

// -- Templates ---------------------------------------------------------------

/// UK limited company. Layout follows FRS 102 1A / FRS 105 groups loosely;
/// codes are illustrative.
LedgerChartTemplate _gbCompany() => LedgerChartTemplate(
  jurisdiction: TaxJurisdiction.gb,
  entityKind: EntityKind.company,
  accounts: [
    const ChartAccountTemplate(
      code: '1099',
      name: 'Bank clearing',
      type: LedgerAccountType.asset,
      systemRole: LedgerSystemRole.bankClearing,
    ),
    _bank('1000', 'Bank current account'),
    _ar('1100', 'Trade debtors'),
    _ap('2100', 'Trade creditors'),
    _vatControl('2200', 'VAT control'),
    _payroll('2300', 'PAYE, NIC and pension liabilities'),
    _plain('2400', 'Corporation tax liability', LedgerAccountType.liability),
    const ChartAccountTemplate(
      code: '2500',
      name: "Directors' loan account",
      type: LedgerAccountType.asset,
      systemRole: LedgerSystemRole.directorsLoan,
    ),
    _plain('3000', 'Share capital', LedgerAccountType.equity),
    _retainedEarnings('3100', 'Retained earnings'),
    _openingBalanceEquity('3200', 'Opening balance equity'),
    _plain('3300', 'Dividends declared', LedgerAccountType.equity),
    _plain('4000', 'Sales', LedgerAccountType.income),
    _plain('4100', 'Other income', LedgerAccountType.income),
    _plain('5000', 'Cost of sales', LedgerAccountType.expense),
    _plain('5100', 'Wages and salaries', LedgerAccountType.expense),
    _plain('5200', 'Employer NIC and pension costs', LedgerAccountType.expense),
    _plain('5300', 'Rent and utilities', LedgerAccountType.expense),
    _plain('5400', 'Software subscriptions', LedgerAccountType.expense),
    _plain('5500', 'Professional fees', LedgerAccountType.expense),
    _plain('5600', 'Bank charges', LedgerAccountType.expense),
    _realisedFx('5800', 'Realised exchange differences'),
    _unrealisedFx('5810', 'Unrealised exchange differences'),
    _rounding('9900', 'Rounding'),
    _suspense('9990', 'Suspense'),
  ],
);

/// UK sole trader: owner's capital and drawings replace share capital;
/// no corporation tax or directors' loan account.
LedgerChartTemplate _gbSoleTrader() => LedgerChartTemplate(
  jurisdiction: TaxJurisdiction.gb,
  entityKind: EntityKind.soleTrader,
  accounts: [
    const ChartAccountTemplate(
      code: '1099',
      name: 'Bank clearing',
      type: LedgerAccountType.asset,
      systemRole: LedgerSystemRole.bankClearing,
    ),
    _bank('1000', 'Business bank account'),
    _ar('1100', 'Trade debtors'),
    _ap('2100', 'Trade creditors'),
    _vatControl('2200', 'VAT control'),
    _payroll('2300', 'Staff PAYE, NIC and pension liabilities'),
    _plain('3000', "Owner's capital", LedgerAccountType.equity),
    _retainedEarnings('3100', 'Retained earnings'),
    _openingBalanceEquity('3200', 'Opening balance equity'),
    const ChartAccountTemplate(
      code: '3300',
      name: "Owner's drawings",
      type: LedgerAccountType.equity,
      systemRole: LedgerSystemRole.ownerDrawings,
    ),
    _plain('4000', 'Sales', LedgerAccountType.income),
    _plain('4100', 'Other income', LedgerAccountType.income),
    _plain('5000', 'Cost of sales', LedgerAccountType.expense),
    _plain('5100', 'Wages', LedgerAccountType.expense),
    _plain('5200', 'Rent and utilities', LedgerAccountType.expense),
    _plain('5300', 'Software subscriptions', LedgerAccountType.expense),
    _plain('5400', 'Professional fees', LedgerAccountType.expense),
    _plain('5500', 'Bank charges', LedgerAccountType.expense),
    _realisedFx('5800', 'Realised exchange differences'),
    _unrealisedFx('5810', 'Unrealised exchange differences'),
    _rounding('9900', 'Rounding'),
    _suspense('9990', 'Suspense'),
  ],
);

/// US company (LLC or S-corp): sales tax replaces VAT and distributions
/// replace dividends. Per-state sales tax and officer/payroll splits come
/// later; US chart guidance was not researched, so codes stay illustrative.
LedgerChartTemplate _usCompany() => LedgerChartTemplate(
  jurisdiction: TaxJurisdiction.us,
  entityKind: EntityKind.company,
  accounts: [
    const ChartAccountTemplate(
      code: '1099',
      name: 'Bank clearing',
      type: LedgerAccountType.asset,
      systemRole: LedgerSystemRole.bankClearing,
    ),
    _bank('1000', 'Operating bank account'),
    _ar('1100', 'Accounts receivable'),
    _ap('2100', 'Accounts payable'),
    _vatControl('2200', 'Sales tax payable'),
    _payroll('2300', 'Payroll liabilities (withholding, FICA)'),
    const ChartAccountTemplate(
      code: '2500',
      name: 'Shareholder loan account',
      type: LedgerAccountType.asset,
      systemRole: LedgerSystemRole.directorsLoan,
    ),
    _plain('3000', 'Common stock', LedgerAccountType.equity),
    _retainedEarnings('3100', 'Retained earnings'),
    _openingBalanceEquity('3200', 'Opening balance equity'),
    _plain('3300', 'Shareholder distributions', LedgerAccountType.equity),
    _plain('4000', 'Sales revenue', LedgerAccountType.income),
    _plain('4100', 'Other income', LedgerAccountType.income),
    _plain('5000', 'Cost of sales', LedgerAccountType.expense),
    _plain('5100', 'Officer compensation', LedgerAccountType.expense),
    _plain('5200', 'Payroll wages', LedgerAccountType.expense),
    _plain('5300', 'Rent and utilities', LedgerAccountType.expense),
    _plain('5400', 'Software subscriptions', LedgerAccountType.expense),
    _plain('5500', 'Professional fees', LedgerAccountType.expense),
    _plain('5600', 'Bank charges', LedgerAccountType.expense),
    _realisedFx('5800', 'Realised exchange gain or loss'),
    _unrealisedFx('5810', 'Unrealised exchange gain or loss'),
    _rounding('9900', 'Rounding'),
    _suspense('9990', 'Suspense'),
  ],
);

/// US sole proprietor: owner's equity, contributions and drawings replace
/// corporate equity; no shareholder loans.
LedgerChartTemplate _usSoleTrader() => LedgerChartTemplate(
  jurisdiction: TaxJurisdiction.us,
  entityKind: EntityKind.soleTrader,
  accounts: [
    const ChartAccountTemplate(
      code: '1099',
      name: 'Bank clearing',
      type: LedgerAccountType.asset,
      systemRole: LedgerSystemRole.bankClearing,
    ),
    _bank('1000', 'Business bank account'),
    _ar('1100', 'Accounts receivable'),
    _ap('2100', 'Accounts payable'),
    _vatControl('2200', 'Sales tax payable'),
    _payroll('2300', 'Payroll liabilities (withholding, FICA)'),
    _plain('3000', "Owner's equity", LedgerAccountType.equity),
    _retainedEarnings('3100', 'Retained earnings'),
    _openingBalanceEquity('3200', 'Opening balance equity'),
    const ChartAccountTemplate(
      code: '3300',
      name: 'Owner distributions',
      type: LedgerAccountType.equity,
      systemRole: LedgerSystemRole.ownerDrawings,
    ),
    _plain('4000', 'Sales revenue', LedgerAccountType.income),
    _plain('4100', 'Other income', LedgerAccountType.income),
    _plain('5000', 'Cost of sales', LedgerAccountType.expense),
    _plain('5100', 'Wages', LedgerAccountType.expense),
    _plain('5200', 'Rent and utilities', LedgerAccountType.expense),
    _plain('5300', 'Software subscriptions', LedgerAccountType.expense),
    _plain('5400', 'Professional fees', LedgerAccountType.expense),
    _plain('5500', 'Bank charges', LedgerAccountType.expense),
    _realisedFx('5800', 'Realised exchange gain or loss'),
    _unrealisedFx('5810', 'Unrealised exchange gain or loss'),
    _rounding('9900', 'Rounding'),
    _suspense('9990', 'Suspense'),
  ],
);

/// Nigerian company: 7.5% VAT control, withholding tax on both sides,
/// company income tax, PenCom/NSITF inside payroll liabilities.
LedgerChartTemplate _ngCompany() => LedgerChartTemplate(
  jurisdiction: TaxJurisdiction.ng,
  entityKind: EntityKind.company,
  accounts: [
    const ChartAccountTemplate(
      code: '1099',
      name: 'Bank clearing',
      type: LedgerAccountType.asset,
      systemRole: LedgerSystemRole.bankClearing,
    ),
    _bank('1000', 'Bank current account'),
    _ar('1100', 'Trade debtors'),
    _plain('1150', 'Withholding tax receivable', LedgerAccountType.asset),
    _ap('2100', 'Trade creditors'),
    _plain('2150', 'Withholding tax payable', LedgerAccountType.liability),
    _vatControl('2200', 'VAT control (7.5%)'),
    _payroll('2300', 'PAYE, pension (PenCom) and NSITF liabilities'),
    _plain('2400', 'Company income tax liability', LedgerAccountType.liability),
    const ChartAccountTemplate(
      code: '2500',
      name: 'Directors loan account',
      type: LedgerAccountType.asset,
      systemRole: LedgerSystemRole.directorsLoan,
    ),
    _plain('3000', 'Share capital', LedgerAccountType.equity),
    _retainedEarnings('3100', 'Retained earnings'),
    _openingBalanceEquity('3200', 'Opening balance equity'),
    _plain('4000', 'Sales', LedgerAccountType.income),
    _plain('4100', 'Other income', LedgerAccountType.income),
    _plain('5000', 'Cost of sales', LedgerAccountType.expense),
    _plain('5100', 'Wages and salaries', LedgerAccountType.expense),
    _plain('5200', 'Rent and utilities', LedgerAccountType.expense),
    _plain('5300', 'Software subscriptions', LedgerAccountType.expense),
    _plain('5400', 'Professional fees', LedgerAccountType.expense),
    _plain('5500', 'Bank charges', LedgerAccountType.expense),
    _realisedFx('5800', 'Realised exchange differences'),
    _unrealisedFx('5810', 'Unrealised exchange differences'),
    _rounding('9900', 'Rounding'),
    _suspense('9990', 'Suspense'),
  ],
);

/// Nigerian sole trader: owner's capital and drawings replace share capital
/// and the directors' loan account.
LedgerChartTemplate _ngSoleTrader() => LedgerChartTemplate(
  jurisdiction: TaxJurisdiction.ng,
  entityKind: EntityKind.soleTrader,
  accounts: [
    const ChartAccountTemplate(
      code: '1099',
      name: 'Bank clearing',
      type: LedgerAccountType.asset,
      systemRole: LedgerSystemRole.bankClearing,
    ),
    _bank('1000', 'Business bank account'),
    _ar('1100', 'Trade debtors'),
    _plain('1150', 'Withholding tax receivable', LedgerAccountType.asset),
    _ap('2100', 'Trade creditors'),
    _plain('2150', 'Withholding tax payable', LedgerAccountType.liability),
    _vatControl('2200', 'VAT control (7.5%)'),
    _payroll('2300', 'PAYE, pension (PenCom) and NSITF liabilities'),
    _plain('3000', "Owner's capital", LedgerAccountType.equity),
    _retainedEarnings('3100', 'Retained earnings'),
    _openingBalanceEquity('3200', 'Opening balance equity'),
    const ChartAccountTemplate(
      code: '3300',
      name: "Owner's drawings",
      type: LedgerAccountType.equity,
      systemRole: LedgerSystemRole.ownerDrawings,
    ),
    _plain('4000', 'Sales', LedgerAccountType.income),
    _plain('4100', 'Other income', LedgerAccountType.income),
    _plain('5000', 'Cost of sales', LedgerAccountType.expense),
    _plain('5100', 'Wages', LedgerAccountType.expense),
    _plain('5200', 'Rent and utilities', LedgerAccountType.expense),
    _plain('5300', 'Software subscriptions', LedgerAccountType.expense),
    _plain('5400', 'Professional fees', LedgerAccountType.expense),
    _plain('5500', 'Bank charges', LedgerAccountType.expense),
    _realisedFx('5800', 'Realised exchange differences'),
    _unrealisedFx('5810', 'Unrealised exchange differences'),
    _rounding('9900', 'Rounding'),
    _suspense('9990', 'Suspense'),
  ],
);

// Germany uses SKR04-style numbering below. UNVERIFIED [K]: every SKR03 and
// SKR04 number in these templates comes from general knowledge, not from a
// primary DATEV list; the DATEV chart is licensed material. Re-check and
// build a verified mapping before shipping a DATEV export. See the
// `double-entry-ledger` skill, "SKR03 and SKR04".

/// German GmbH: internal simplified chart with SKR04-style numbers.
/// VAT input and output sit on one control account until the documents PR
/// splits them; the law requires proper books, not a specific chart.
LedgerChartTemplate _deCompany() => LedgerChartTemplate(
  jurisdiction: TaxJurisdiction.de,
  entityKind: EntityKind.company,
  accounts: [
    const ChartAccountTemplate(
      code: '1099',
      name: 'Bank clearing',
      type: LedgerAccountType.asset,
      systemRole: LedgerSystemRole.bankClearing,
    ),
    _bank('1800', 'Bank'),
    _ar('1200', 'Forderungen aus Lieferungen und Leistungen'),
    _ap('3300', 'Verbindlichkeiten aus Lieferungen und Leistungen'),
    _vatControl('3806', 'Umsatzsteuer-Kontrolle'),
    _payroll('0810', 'Lohnsteuer und Sozialabgaben'),
    const ChartAccountTemplate(
      code: '1500',
      name: 'Verbindlichkeiten gegenüber Gesellschaftern',
      type: LedgerAccountType.liability,
      systemRole: LedgerSystemRole.directorsLoan,
    ),
    _plain('2900', 'Stammkapital', LedgerAccountType.equity),
    _retainedEarnings('2925', 'Gewinnvortrag'),
    _openingBalanceEquity('9000', 'Eröffnungsbilanzkonto'),
    _plain('4400', 'Erlöse 19 %', LedgerAccountType.income),
    _plain('4300', 'Erlöse 7 %', LedgerAccountType.income),
    _plain('4100', 'Steuerfreie Umsätze §4 UStG', LedgerAccountType.income),
    _plain('6000', 'Löhne', LedgerAccountType.expense),
    _plain('6800', 'Gehälter', LedgerAccountType.expense),
    _plain('7250', 'Miete', LedgerAccountType.expense),
    _plain('6480', 'Software', LedgerAccountType.expense),
    _plain('6300', 'Rechts- und Steuerberatung', LedgerAccountType.expense),
    _plain('6560', 'Bankgebühren', LedgerAccountType.expense),
    _realisedFx('6860', 'Realisierte Kursdifferenzen'),
    _unrealisedFx('6865', 'Unrealisierte Kursdifferenzen'),
    _rounding('9995', 'Rundung'),
    _suspense('9990', 'Verrechnungskonto'),
  ],
);

/// German Einzelunternehmen: Privatentnahmen und Privateinlagen replace
/// corporate equity; no directors' loan account.
LedgerChartTemplate _deSoleTrader() => LedgerChartTemplate(
  jurisdiction: TaxJurisdiction.de,
  entityKind: EntityKind.soleTrader,
  accounts: [
    const ChartAccountTemplate(
      code: '1099',
      name: 'Bank clearing',
      type: LedgerAccountType.asset,
      systemRole: LedgerSystemRole.bankClearing,
    ),
    _bank('1800', 'Bank'),
    _ar('1200', 'Forderungen aus Lieferungen und Leistungen'),
    _ap('3300', 'Verbindlichkeiten aus Lieferungen und Leistungen'),
    _vatControl('3806', 'Umsatzsteuer-Kontrolle'),
    _payroll('0810', 'Lohnsteuer und Sozialabgaben'),
    _plain('1950', 'Privateinlagen', LedgerAccountType.equity),
    _retainedEarnings('2925', 'Gewinnvortrag'),
    _openingBalanceEquity('9000', 'Eröffnungsbilanzkonto'),
    const ChartAccountTemplate(
      code: '1900',
      name: 'Privatentnahmen',
      type: LedgerAccountType.equity,
      systemRole: LedgerSystemRole.ownerDrawings,
    ),
    _plain('4400', 'Erlöse 19 %', LedgerAccountType.income),
    _plain('4300', 'Erlöse 7 %', LedgerAccountType.income),
    _plain('4100', 'Steuerfreie Umsätze §4 UStG', LedgerAccountType.income),
    _plain('6000', 'Löhne', LedgerAccountType.expense),
    _plain('6800', 'Gehälter', LedgerAccountType.expense),
    _plain('7250', 'Miete', LedgerAccountType.expense),
    _plain('6480', 'Software', LedgerAccountType.expense),
    _plain('6300', 'Rechts- und Steuerberatung', LedgerAccountType.expense),
    _plain('6560', 'Bankgebühren', LedgerAccountType.expense),
    _realisedFx('6860', 'Realisierte Kursdifferenzen'),
    _unrealisedFx('6865', 'Unrealisierte Kursdifferenzen'),
    _rounding('9995', 'Rundung'),
    _suspense('9990', 'Verrechnungskonto'),
  ],
);

// -- Generic template ---------------------------------------------------------
//
// Countries without a tax pack (every jurisdiction the later country
// batches add) share this chart. IFRS-style names, no country's tax
// accounts; codes follow the same numbering scheme as the country charts
// and stay illustrative.

/// Generic company: shareholder loans replace sole-trader drawings; the
/// indirect-tax control account stands in for every country's VAT, GST or
/// sales-tax control.
List<ChartAccountTemplate> _genericCompanyAccounts() => [
  const ChartAccountTemplate(
    code: '1099',
    name: 'Bank clearing',
    type: LedgerAccountType.asset,
    systemRole: LedgerSystemRole.bankClearing,
  ),
  _bank('1000', 'Bank account'),
  _ar('1100', 'Trade receivables'),
  _ap('2100', 'Trade payables'),
  _vatControl('2200', 'Indirect tax payable/receivable'),
  _payroll('2300', 'Payroll liabilities'),
  const ChartAccountTemplate(
    code: '2500',
    name: 'Shareholder loan account',
    type: LedgerAccountType.asset,
    systemRole: LedgerSystemRole.directorsLoan,
  ),
  _plain('3000', 'Share capital', LedgerAccountType.equity),
  _retainedEarnings('3100', 'Retained earnings'),
  _openingBalanceEquity('3200', 'Opening balance equity'),
  _plain('3300', 'Dividends declared', LedgerAccountType.equity),
  _plain('4000', 'Revenue', LedgerAccountType.income),
  _plain('4100', 'Other income', LedgerAccountType.income),
  _plain('5000', 'Cost of sales', LedgerAccountType.expense),
  _plain('5100', 'Salaries and wages', LedgerAccountType.expense),
  _plain('5200', 'Rent and utilities', LedgerAccountType.expense),
  _plain('5300', 'Software subscriptions', LedgerAccountType.expense),
  _plain('5400', 'Professional fees', LedgerAccountType.expense),
  _plain('5500', 'Bank charges', LedgerAccountType.expense),
  _realisedFx('5800', 'Realised exchange differences'),
  _unrealisedFx('5810', 'Unrealised exchange differences'),
  _rounding('9900', 'Rounding'),
  _suspense('9990', 'Suspense'),
];

/// Generic sole trader: owner's capital and drawings replace share capital
/// and the shareholder loan account.
List<ChartAccountTemplate> _genericSoleTraderAccounts() => [
  const ChartAccountTemplate(
    code: '1099',
    name: 'Bank clearing',
    type: LedgerAccountType.asset,
    systemRole: LedgerSystemRole.bankClearing,
  ),
  _bank('1000', 'Business bank account'),
  _ar('1100', 'Trade receivables'),
  _ap('2100', 'Trade payables'),
  _vatControl('2200', 'Indirect tax payable/receivable'),
  _payroll('2300', 'Payroll liabilities'),
  _plain('3000', "Owner's capital", LedgerAccountType.equity),
  _retainedEarnings('3100', 'Retained earnings'),
  _openingBalanceEquity('3200', 'Opening balance equity'),
  const ChartAccountTemplate(
    code: '3300',
    name: "Owner's drawings",
    type: LedgerAccountType.equity,
    systemRole: LedgerSystemRole.ownerDrawings,
  ),
  _plain('4000', 'Revenue', LedgerAccountType.income),
  _plain('4100', 'Other income', LedgerAccountType.income),
  _plain('5000', 'Cost of sales', LedgerAccountType.expense),
  _plain('5100', 'Salaries and wages', LedgerAccountType.expense),
  _plain('5200', 'Rent and utilities', LedgerAccountType.expense),
  _plain('5300', 'Software subscriptions', LedgerAccountType.expense),
  _plain('5400', 'Professional fees', LedgerAccountType.expense),
  _plain('5500', 'Bank charges', LedgerAccountType.expense),
  _realisedFx('5800', 'Realised exchange differences'),
  _unrealisedFx('5810', 'Unrealised exchange differences'),
  _rounding('9900', 'Rounding'),
  _suspense('9990', 'Suspense'),
];
