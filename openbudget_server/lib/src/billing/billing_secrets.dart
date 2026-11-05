import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:serverpod/serverpod.dart';

/// Names of the passwords used to configure the billing rails.
abstract final class BillingSecretKeys {
  static const stripeSecretKey = 'stripeSecretKey';
  static const stripeWebhookSecret = 'stripeWebhookSecret';
  static const stripePriceId = 'stripePriceId';
  static const revenueCatWebhookAuthorization =
      'revenueCatWebhookAuthorization';
  static const solanaCollectorSecretKey = 'solanaCollectorSecretKey';
  static const solanaRpcUrl = 'solanaRpcUrl';
  static const solanaSubscriptionPlanAddress = 'solanaSubscriptionPlanAddress';
  static const solanaUsdcMint = 'solanaUsdcMint';
}

/// Reads billing credentials from the server's password store.
abstract final class BillingSecrets {
  /// Returns the trimmed value of [key], or null when unset or blank.
  static String? read(Session session, String key) {
    final value = session.passwords[key]?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  /// Returns [key], throwing [BillingRailUnavailableException] when unset.
  static String require(Session session, String key) {
    final value = read(session, key);
    if (value == null) {
      throw BillingRailUnavailableException('$key is not configured');
    }
    return value;
  }
}
