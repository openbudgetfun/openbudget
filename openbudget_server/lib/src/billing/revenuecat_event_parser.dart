import 'package:openbudget_server/src/billing/billing_json.dart';
import 'package:openbudget_server/src/billing/billing_subscription_update.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;

/// Parses RevenueCat subscription events into entitlement updates.
abstract final class RevenueCatEventParser {
  /// Returns the update encoded by [event], or null when the event does not
  /// grant or change an OpenBudget entitlement.
  static BillingSubscriptionUpdate? parse(Map<String, Object?> event) {
    final type = asJsonString(event['type']);
    final store = asJsonString(event['store']);
    if (type == null || store == null) return null;
    if (type == 'TEST') return null;

    final source = sourceForStore(store);
    if (source == null) return null;

    final status = statusForType(type);
    if (status == null) return null;

    final userIdValue = asJsonString(event['app_user_id']);
    if (!isUuid(userIdValue)) return null;

    final externalId = asJsonString(event['original_transaction_id']);
    final purchasedAt = asJsonInt(event['purchased_at_ms']);
    final expirationAt = asJsonInt(event['expiration_at_ms']);
    if (externalId == null || purchasedAt == null || expirationAt == null) {
      return null;
    }

    final start = DateTime.fromMillisecondsSinceEpoch(
      purchasedAt,
      isUtc: true,
    );
    final end = DateTime.fromMillisecondsSinceEpoch(expirationAt, isUtc: true);
    if (!end.isAfter(start)) return null;

    return BillingSubscriptionUpdate(
      userId: UuidValue.fromString(userIdValue!),
      source: source,
      externalId: externalId,
      status: status,
      currentPeriodStart: start,
      currentPeriodEnd: end,
    );
  }

  /// Maps a RevenueCat store to the entitlement source, or null when the
  /// store is billed by another rail.
  static EntitlementSource? sourceForStore(String store) {
    switch (store) {
      case 'APP_STORE':
        return EntitlementSource.appStore;
      case 'PLAY_STORE':
        return EntitlementSource.playStore;
      default:
        return null;
    }
  }

  /// Maps a RevenueCat event type to an entitlement status.
  static EntitlementStatus? statusForType(String type) {
    switch (type) {
      case 'INITIAL_PURCHASE':
      case 'RENEWAL':
      case 'UNCANCELLATION':
      case 'PRODUCT_CHANGE':
        return EntitlementStatus.active;
      case 'CANCELLATION':
        return EntitlementStatus.canceled;
      case 'BILLING_ISSUE':
        return EntitlementStatus.pastDue;
      case 'EXPIRATION':
        return EntitlementStatus.expired;
      default:
        return null;
    }
  }
}
