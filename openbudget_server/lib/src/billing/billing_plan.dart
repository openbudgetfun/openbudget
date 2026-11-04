/// The one paid plan OpenBudget sells.
///
/// The price is the same on every rail. Stores may show a local equivalent,
/// but the server meters the agent allowance in US dollars.
abstract final class BillingPlan {
  /// Identifier used by every rail's product or price configuration.
  static const String id = 'openbudget_plus_monthly';

  /// Monthly price in US cents.
  static const int monthlyPriceUsdCents = 1000;

  /// Built-in agent usage included in each billing period, in micro-dollars
  /// (one millionth of a US dollar). $1.00.
  static const int includedAgentUsageMicroUsd = 1000000;
}
