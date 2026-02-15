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

  /// Bitcoin
  btc('BTC', 'Bitcoin', '\u20BF', 8);

  const CurrencyCode(this.code, this.displayName, this.symbol, this.decimals);

  /// ISO 4217 currency code (or crypto equivalent).
  final String code;

  /// Human-readable name.
  final String displayName;

  /// Currency symbol for display.
  final String symbol;

  /// Number of decimal places used by this currency.
  final int decimals;
}
