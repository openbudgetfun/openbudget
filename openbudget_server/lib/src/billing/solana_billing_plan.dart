/// Fixed terms for the OpenBudget Plus Solana subscription plan.
abstract final class SolanaBillingPlan {
  /// 20 USDC, expressed in the mint's six-decimal base units.
  static const int amountBaseUnits = 20000000;

  /// 30 days, in seconds.
  static const int periodSeconds = 30 * 24 * 60 * 60;

  /// 30 days, in hours.
  static const int periodHours = 30 * 24;
}
