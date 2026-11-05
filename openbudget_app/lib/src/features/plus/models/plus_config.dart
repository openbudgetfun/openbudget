/// Compile-time configuration for OpenBudget Plus.
///
/// Public SDK keys never live in the repository. Builds pass them with
/// `--dart-define`; an empty value leaves that rail unavailable instead of
/// failing at runtime.
abstract final class PlusConfig {
  /// RevenueCat public SDK key for iOS.
  static const String revenueCatIosKey = String.fromEnvironment(
    'REVENUECAT_IOS_KEY',
  );

  /// RevenueCat public SDK key for Android.
  static const String revenueCatAndroidKey = String.fromEnvironment(
    'REVENUECAT_ANDROID_KEY',
  );

  /// JSON-RPC endpoint used to read the subscription plan and send the
  /// subscribe transaction.
  static const String solanaRpcUrl = String.fromEnvironment(
    'SOLANA_RPC_URL',
    defaultValue: 'https://api.mainnet-beta.solana.com',
  );

  /// Wallet Standard chain identifier.
  static const String solanaChain = String.fromEnvironment(
    'SOLANA_CHAIN',
    defaultValue: 'solana:mainnet',
  );

  /// Public app address used for checkout return links on desktop.
  static const String appUrl = String.fromEnvironment(
    'OPENBUDGET_APP_URL',
    defaultValue: 'https://openbudget.app',
  );

  /// Wallet Standard application identity shown by wallet pickers.
  static const String appName = 'OpenBudget';
}
