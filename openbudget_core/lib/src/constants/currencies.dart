// GENERATED CODE - DO NOT MODIFY BY HAND.
// Regenerate with: dart run tool/generate_currencies.dart
//
// Currencies: ISO 4217 List One: Currency codes, published by
// SIX Financial Information AG, ISO 4217 maintenance agency on 2026-09-17.
// https://www.six-group.com/dam/download/financial-information/data-center/iso-currrency/lists/list-one.xml
//
// Symbols: Unicode CLDR 49.0.0, en, currency symbols.
// A currency CLDR gives no distinct symbol keeps its code followed by a
// non-breaking space. The currencies OpenBudget shipped before this
// list keep their existing names and symbols, and BTC is not an ISO
// 4217 code.
//
// Not offered, because ISO 4217 publishes no minor unit for them:
// XAG, XAU, XBA, XBB, XBC, XBD, XDR, XPD, XPT, XSU, XTS, XUA, XXX

/// Standard currency codes supported by OpenBudget.
enum CurrencyCode {
  /// US Dollar
  usd('USD', 'US Dollar', r'$', 2),

  /// Euro
  eur('EUR', 'Euro', '\u20AC', 2),

  /// British Pound
  gbp('GBP', 'British Pound', '\u00A3', 2),

  /// Japanese Yen
  jpy('JPY', 'Japanese Yen', '\u00A5', 0),

  /// Nigerian Naira
  ngn('NGN', 'Nigerian Naira', '\u20A6', 2),

  /// Canadian Dollar
  cad('CAD', 'Canadian Dollar', r'CA$', 2),

  /// Australian Dollar
  aud('AUD', 'Australian Dollar', r'A$', 2),

  /// New Zealand Dollar
  nzd('NZD', 'New Zealand Dollar', r'NZ$', 2),

  /// Swiss Franc
  chf('CHF', 'Swiss Franc', 'CHF\u00A0', 2),

  /// Swedish Krona
  sek('SEK', 'Swedish Krona', 'kr\u00A0', 2),

  /// Norwegian Krone
  nok('NOK', 'Norwegian Krone', 'kr\u00A0', 2),

  /// Danish Krone
  dkk('DKK', 'Danish Krone', 'kr\u00A0', 2),

  /// Polish Zloty
  pln('PLN', 'Polish Zloty', 'z\u0142\u00A0', 2),

  /// Chinese Yuan
  cny('CNY', 'Chinese Yuan', 'CN\u00A5', 2),

  /// Hong Kong Dollar
  hkd('HKD', 'Hong Kong Dollar', r'HK$', 2),

  /// Singapore Dollar
  sgd('SGD', 'Singapore Dollar', r'S$', 2),

  /// South Korean Won
  krw('KRW', 'South Korean Won', '\u20A9', 0),

  /// Indian Rupee
  inr('INR', 'Indian Rupee', '\u20B9', 2),

  /// UAE Dirham
  aed('AED', 'UAE Dirham', 'AED\u00A0', 2),

  /// South African Rand
  zar('ZAR', 'South African Rand', 'R\u00A0', 2),

  /// Kenyan Shilling
  kes('KES', 'Kenyan Shilling', 'KSh\u00A0', 2),

  /// Ghanaian Cedi
  ghs('GHS', 'Ghanaian Cedi', 'GH\u20B5', 2),

  /// Brazilian Real
  brl('BRL', 'Brazilian Real', r'R$', 2),

  /// Mexican Peso
  mxn('MXN', 'Mexican Peso', r'MX$', 2),

  /// Kuwaiti Dinar
  kwd('KWD', 'Kuwaiti Dinar', 'KWD ', 3),

  /// Bahraini Dinar
  bhd('BHD', 'Bahraini Dinar', 'BHD ', 3),

  /// Afghani
  afn('AFN', 'Afghani', 'AFN\u00A0', 2),

  /// Lek
  all('ALL', 'Lek', 'ALL\u00A0', 2),

  /// Armenian Dram
  amd('AMD', 'Armenian Dram', 'AMD\u00A0', 2),

  /// Kwanza
  aoa('AOA', 'Kwanza', 'AOA\u00A0', 2),

  /// Argentine Peso
  ars('ARS', 'Argentine Peso', 'ARS\u00A0', 2),

  /// Aruban Florin
  awg('AWG', 'Aruban Florin', 'AWG\u00A0', 2),

  /// Azerbaijan Manat
  azn('AZN', 'Azerbaijan Manat', 'AZN\u00A0', 2),

  /// Convertible Mark
  bam('BAM', 'Convertible Mark', 'BAM\u00A0', 2),

  /// Barbados Dollar
  bbd('BBD', 'Barbados Dollar', 'BBD\u00A0', 2),

  /// Taka
  bdt('BDT', 'Taka', 'BDT\u00A0', 2),

  /// Burundi Franc
  bif('BIF', 'Burundi Franc', 'BIF\u00A0', 0),

  /// Bermudian Dollar
  bmd('BMD', 'Bermudian Dollar', 'BMD\u00A0', 2),

  /// Brunei Dollar
  bnd('BND', 'Brunei Dollar', 'BND\u00A0', 2),

  /// Boliviano
  bob('BOB', 'Boliviano', 'BOB\u00A0', 2),

  /// Mvdol
  bov('BOV', 'Mvdol', 'BOV\u00A0', 2),

  /// Bahamian Dollar
  bsd('BSD', 'Bahamian Dollar', 'BSD\u00A0', 2),

  /// Ngultrum
  btn('BTN', 'Ngultrum', 'BTN\u00A0', 2),

  /// Pula
  bwp('BWP', 'Pula', 'BWP\u00A0', 2),

  /// Belarusian Ruble
  byn('BYN', 'Belarusian Ruble', 'BYN\u00A0', 2),

  /// Belize Dollar
  bzd('BZD', 'Belize Dollar', 'BZD\u00A0', 2),

  /// Congolese Franc
  cdf('CDF', 'Congolese Franc', 'CDF\u00A0', 2),

  /// WIR Euro
  che('CHE', 'WIR Euro', 'CHE\u00A0', 2),

  /// WIR Franc
  chw('CHW', 'WIR Franc', 'CHW\u00A0', 2),

  /// Unidad de Fomento
  clf('CLF', 'Unidad de Fomento', 'CLF\u00A0', 4),

  /// Chilean Peso
  clp('CLP', 'Chilean Peso', 'CLP\u00A0', 0),

  /// Colombian Peso
  cop('COP', 'Colombian Peso', 'COP\u00A0', 2),

  /// Unidad de Valor Real
  cou('COU', 'Unidad de Valor Real', 'COU\u00A0', 2),

  /// Costa Rican Colon
  crc('CRC', 'Costa Rican Colon', 'CRC\u00A0', 2),

  /// Cuban Peso
  cup('CUP', 'Cuban Peso', 'CUP\u00A0', 2),

  /// Cabo Verde Escudo
  cve('CVE', 'Cabo Verde Escudo', 'CVE\u00A0', 2),

  /// Czech Koruna
  czk('CZK', 'Czech Koruna', 'CZK\u00A0', 2),

  /// Djibouti Franc
  djf('DJF', 'Djibouti Franc', 'DJF\u00A0', 0),

  /// Dominican Peso
  dop('DOP', 'Dominican Peso', 'DOP\u00A0', 2),

  /// Algerian Dinar
  dzd('DZD', 'Algerian Dinar', 'DZD\u00A0', 2),

  /// Egyptian Pound
  egp('EGP', 'Egyptian Pound', 'EGP\u00A0', 2),

  /// Nakfa
  ern('ERN', 'Nakfa', 'ERN\u00A0', 2),

  /// Ethiopian Birr
  etb('ETB', 'Ethiopian Birr', 'ETB\u00A0', 2),

  /// Fiji Dollar
  fjd('FJD', 'Fiji Dollar', 'FJD\u00A0', 2),

  /// Falkland Islands Pound
  fkp('FKP', 'Falkland Islands Pound', 'FKP\u00A0', 2),

  /// Lari
  gel('GEL', 'Lari', 'GEL\u00A0', 2),

  /// Gibraltar Pound
  gip('GIP', 'Gibraltar Pound', 'GIP\u00A0', 2),

  /// Dalasi
  gmd('GMD', 'Dalasi', 'GMD\u00A0', 2),

  /// Guinean Franc
  gnf('GNF', 'Guinean Franc', 'GNF\u00A0', 0),

  /// Quetzal
  gtq('GTQ', 'Quetzal', 'GTQ\u00A0', 2),

  /// Guyana Dollar
  gyd('GYD', 'Guyana Dollar', 'GYD\u00A0', 2),

  /// Lempira
  hnl('HNL', 'Lempira', 'HNL\u00A0', 2),

  /// Gourde
  htg('HTG', 'Gourde', 'HTG\u00A0', 2),

  /// Forint
  huf('HUF', 'Forint', 'HUF\u00A0', 2),

  /// Rupiah
  idr('IDR', 'Rupiah', 'IDR\u00A0', 2),

  /// New Israeli Sheqel
  ils('ILS', 'New Israeli Sheqel', '\u20AA', 2),

  /// Iraqi Dinar
  iqd('IQD', 'Iraqi Dinar', 'IQD\u00A0', 3),

  /// Iranian Rial
  irr('IRR', 'Iranian Rial', 'IRR\u00A0', 2),

  /// Iceland Krona
  isk('ISK', 'Iceland Krona', 'ISK\u00A0', 0),

  /// Jamaican Dollar
  jmd('JMD', 'Jamaican Dollar', 'JMD\u00A0', 2),

  /// Jordanian Dinar
  jod('JOD', 'Jordanian Dinar', 'JOD\u00A0', 3),

  /// Som
  kgs('KGS', 'Som', 'KGS\u00A0', 2),

  /// Riel
  khr('KHR', 'Riel', 'KHR\u00A0', 2),

  /// Comorian Franc
  kmf('KMF', 'Comorian Franc', 'KMF\u00A0', 0),

  /// North Korean Won
  kpw('KPW', 'North Korean Won', 'KPW\u00A0', 2),

  /// Cayman Islands Dollar
  kyd('KYD', 'Cayman Islands Dollar', 'KYD\u00A0', 2),

  /// Tenge
  kzt('KZT', 'Tenge', 'KZT\u00A0', 2),

  /// Lao Kip
  lak('LAK', 'Lao Kip', 'LAK\u00A0', 2),

  /// Lebanese Pound
  lbp('LBP', 'Lebanese Pound', 'LBP\u00A0', 2),

  /// Sri Lanka Rupee
  lkr('LKR', 'Sri Lanka Rupee', 'LKR\u00A0', 2),

  /// Liberian Dollar
  lrd('LRD', 'Liberian Dollar', 'LRD\u00A0', 2),

  /// Loti
  lsl('LSL', 'Loti', 'LSL\u00A0', 2),

  /// Libyan Dinar
  lyd('LYD', 'Libyan Dinar', 'LYD\u00A0', 3),

  /// Moroccan Dirham
  mad('MAD', 'Moroccan Dirham', 'MAD\u00A0', 2),

  /// Moldovan Leu
  mdl('MDL', 'Moldovan Leu', 'MDL\u00A0', 2),

  /// Malagasy Ariary
  mga('MGA', 'Malagasy Ariary', 'MGA\u00A0', 2),

  /// Denar
  mkd('MKD', 'Denar', 'MKD\u00A0', 2),

  /// Kyat
  mmk('MMK', 'Kyat', 'MMK\u00A0', 2),

  /// Tugrik
  mnt('MNT', 'Tugrik', 'MNT\u00A0', 2),

  /// Pataca
  mop('MOP', 'Pataca', 'MOP\u00A0', 2),

  /// Ouguiya
  mru('MRU', 'Ouguiya', 'MRU\u00A0', 2),

  /// Mauritius Rupee
  mur('MUR', 'Mauritius Rupee', 'MUR\u00A0', 2),

  /// Rufiyaa
  mvr('MVR', 'Rufiyaa', 'MVR\u00A0', 2),

  /// Malawi Kwacha
  mwk('MWK', 'Malawi Kwacha', 'MWK\u00A0', 2),

  /// Mexican Unidad de Inversion (UDI)
  mxv('MXV', 'Mexican Unidad de Inversion (UDI)', 'MXV\u00A0', 2),

  /// Malaysian Ringgit
  myr('MYR', 'Malaysian Ringgit', 'MYR\u00A0', 2),

  /// Mozambique Metical
  mzn('MZN', 'Mozambique Metical', 'MZN\u00A0', 2),

  /// Namibia Dollar
  nad('NAD', 'Namibia Dollar', 'NAD\u00A0', 2),

  /// Cordoba Oro
  nio('NIO', 'Cordoba Oro', 'NIO\u00A0', 2),

  /// Nepalese Rupee
  npr('NPR', 'Nepalese Rupee', 'NPR\u00A0', 2),

  /// Rial Omani
  omr('OMR', 'Rial Omani', 'OMR\u00A0', 3),

  /// Balboa
  pab('PAB', 'Balboa', 'PAB\u00A0', 2),

  /// Sol
  pen('PEN', 'Sol', 'PEN\u00A0', 2),

  /// Kina
  pgk('PGK', 'Kina', 'PGK\u00A0', 2),

  /// Philippine Peso
  php('PHP', 'Philippine Peso', '\u20B1', 2),

  /// Pakistan Rupee
  pkr('PKR', 'Pakistan Rupee', 'PKR\u00A0', 2),

  /// Guarani
  pyg('PYG', 'Guarani', 'PYG\u00A0', 0),

  /// Qatari Rial
  qar('QAR', 'Qatari Rial', 'QAR\u00A0', 2),

  /// Romanian Leu
  ron('RON', 'Romanian Leu', 'RON\u00A0', 2),

  /// Serbian Dinar
  rsd('RSD', 'Serbian Dinar', 'RSD\u00A0', 2),

  /// Russian Ruble
  rub('RUB', 'Russian Ruble', 'RUB\u00A0', 2),

  /// Rwanda Franc
  rwf('RWF', 'Rwanda Franc', 'RWF\u00A0', 0),

  /// Saudi Riyal
  sar('SAR', 'Saudi Riyal', 'SAR\u00A0', 2),

  /// Solomon Islands Dollar
  sbd('SBD', 'Solomon Islands Dollar', 'SBD\u00A0', 2),

  /// Seychelles Rupee
  scr('SCR', 'Seychelles Rupee', 'SCR\u00A0', 2),

  /// Sudanese Pound
  sdg('SDG', 'Sudanese Pound', 'SDG\u00A0', 2),

  /// Saint Helena Pound
  shp('SHP', 'Saint Helena Pound', 'SHP\u00A0', 2),

  /// Leone
  sle('SLE', 'Leone', 'SLE\u00A0', 2),

  /// Somali Shilling
  sos('SOS', 'Somali Shilling', 'SOS\u00A0', 2),

  /// Surinam Dollar
  srd('SRD', 'Surinam Dollar', 'SRD\u00A0', 2),

  /// South Sudanese Pound
  ssp('SSP', 'South Sudanese Pound', 'SSP\u00A0', 2),

  /// Dobra
  stn('STN', 'Dobra', 'STN\u00A0', 2),

  /// El Salvador Colon
  svc('SVC', 'El Salvador Colon', 'SVC\u00A0', 2),

  /// Syrian Pound
  syp('SYP', 'Syrian Pound', 'SYP\u00A0', 2),

  /// Lilangeni
  szl('SZL', 'Lilangeni', 'SZL\u00A0', 2),

  /// Baht
  thb('THB', 'Baht', 'THB\u00A0', 2),

  /// Somoni
  tjs('TJS', 'Somoni', 'TJS\u00A0', 2),

  /// Turkmenistan New Manat
  tmt('TMT', 'Turkmenistan New Manat', 'TMT\u00A0', 2),

  /// Tunisian Dinar
  tnd('TND', 'Tunisian Dinar', 'TND\u00A0', 3),

  /// Pa’anga
  top('TOP', 'Pa\u2019anga', 'TOP\u00A0', 2),

  /// Turkish Lira
  try_('TRY', 'Turkish Lira', 'TRY\u00A0', 2),

  /// Trinidad and Tobago Dollar
  ttd('TTD', 'Trinidad and Tobago Dollar', 'TTD\u00A0', 2),

  /// New Taiwan Dollar
  twd('TWD', 'New Taiwan Dollar', r'NT$', 2),

  /// Tanzanian Shilling
  tzs('TZS', 'Tanzanian Shilling', 'TZS\u00A0', 2),

  /// Hryvnia
  uah('UAH', 'Hryvnia', 'UAH\u00A0', 2),

  /// Uganda Shilling
  ugx('UGX', 'Uganda Shilling', 'UGX\u00A0', 0),

  /// US Dollar (Next day)
  usn('USN', 'US Dollar (Next day)', 'USN\u00A0', 2),

  /// Uruguay Peso en Unidades Indexadas (UI)
  uyi('UYI', 'Uruguay Peso en Unidades Indexadas (UI)', 'UYI\u00A0', 0),

  /// Peso Uruguayo
  uyu('UYU', 'Peso Uruguayo', 'UYU\u00A0', 2),

  /// Unidad Previsional
  uyw('UYW', 'Unidad Previsional', 'UYW\u00A0', 4),

  /// Uzbekistan Sum
  uzs('UZS', 'Uzbekistan Sum', 'UZS\u00A0', 2),

  /// Bolívar Soberano
  ved('VED', 'Bol\u00EDvar Soberano', 'VED\u00A0', 2),

  /// Bolívar Soberano
  ves('VES', 'Bol\u00EDvar Soberano', 'VES\u00A0', 2),

  /// Dong
  vnd('VND', 'Dong', '\u20AB', 0),

  /// Vatu
  vuv('VUV', 'Vatu', 'VUV\u00A0', 0),

  /// Tala
  wst('WST', 'Tala', 'WST\u00A0', 2),

  /// Arab Accounting Dinar
  xad('XAD', 'Arab Accounting Dinar', 'XAD\u00A0', 2),

  /// CFA Franc BEAC
  xaf('XAF', 'CFA Franc BEAC', 'FCFA', 0),

  /// East Caribbean Dollar
  xcd('XCD', 'East Caribbean Dollar', r'EC$', 2),

  /// Caribbean Guilder
  xcg('XCG', 'Caribbean Guilder', 'Cg.', 2),

  /// CFA Franc BCEAO
  xof('XOF', 'CFA Franc BCEAO', 'F\u202FCFA', 0),

  /// CFP Franc
  xpf('XPF', 'CFP Franc', 'CFPF', 0),

  /// Yemeni Rial
  yer('YER', 'Yemeni Rial', 'YER\u00A0', 2),

  /// Zambian Kwacha
  zmw('ZMW', 'Zambian Kwacha', 'ZMW\u00A0', 2),

  /// Zimbabwe Gold
  zwg('ZWG', 'Zimbabwe Gold', 'ZWG\u00A0', 2),

  /// Bitcoin
  btc('BTC', 'Bitcoin', '\u20BF', 8);

  const CurrencyCode(this.code, this.displayName, this.symbol, this.decimals);

  /// ISO 4217 currency code (or crypto equivalent).
  final String code;

  /// Human-readable name.
  final String displayName;

  /// Currency symbol for display.
  final String symbol;

  /// Number of decimal places used by this currency: amounts are stored in
  /// its minor unit, so 100 USD minor units is one dollar and 100 JPY minor
  /// units is one hundred yen.
  final int decimals;

  /// The currency with ISO 4217 [code], or null when OpenBudget does not
  /// support it. [code] is trimmed and upper-cased before matching. Callers
  /// decide what an unknown code means; nothing guesses.
  static CurrencyCode? tryParse(String code) {
    final upper = code.trim().toUpperCase();
    for (final currency in values) {
      if (currency.code == upper) {
        return currency;
      }
    }
    return null;
  }
}
