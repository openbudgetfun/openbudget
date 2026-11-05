/// Standard currency codes supported by OpenBudget.
enum CurrencyCode {
  /// United States Dollar
  usd('USD', 'US Dollar', r'$', 2),

  /// Euro
  eur('EUR', 'Euro', '\u20AC', 2),

  /// British Pound Sterling
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
