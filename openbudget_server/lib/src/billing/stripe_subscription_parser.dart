import 'package:openbudget_server/src/billing/billing_json.dart';
import 'package:openbudget_server/src/billing/billing_subscription_update.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;

/// Parses the Stripe subscription payloads the billing webhook understands.
abstract final class StripeSubscriptionParser {
  /// Returns the update encoded by a subscription object, or null when the
  /// event is not one OpenBudget records.
  static BillingSubscriptionUpdate? parse(
    Map<String, Object?> subscription, {
    DateTime? now,
  }) {
    final metadata = asJsonMap(subscription['metadata']);
    final userIdValue = asJsonString(metadata?['user_id']);
    if (!isUuid(userIdValue)) return null;

    final externalId = asJsonString(subscription['id']);
    final stripeStatus = asJsonString(subscription['status']);
    final (periodStart, periodEnd) = _period(subscription);
    if (externalId == null ||
        stripeStatus == null ||
        periodStart == null ||
        periodEnd == null) {
      return null;
    }
    if (!periodEnd.isAfter(periodStart)) return null;

    final at = (now ?? DateTime.now()).toUtc();
    final status = mapStatus(stripeStatus, periodEnd: periodEnd, now: at);
    if (status == null) return null;

    return BillingSubscriptionUpdate(
      userId: UuidValue.fromString(userIdValue!),
      source: EntitlementSource.stripe,
      externalId: externalId,
      status: status,
      currentPeriodStart: periodStart,
      currentPeriodEnd: periodEnd,
    );
  }

  /// Maps a Stripe subscription status to an entitlement status.
  ///
  /// Stripe reports `canceled` immediately in some flows, so access is kept
  /// until the paid period actually ends.
  static EntitlementStatus? mapStatus(
    String stripeStatus, {
    required DateTime periodEnd,
    required DateTime now,
  }) {
    switch (stripeStatus) {
      case 'active':
      case 'trialing':
        return EntitlementStatus.active;
      case 'past_due':
      case 'unpaid':
        return EntitlementStatus.pastDue;
      case 'canceled':
        return periodEnd.isAfter(now)
            ? EntitlementStatus.canceled
            : EntitlementStatus.expired;
      case 'incomplete_expired':
        return EntitlementStatus.expired;
      case 'incomplete':
      case 'paused':
      default:
        return null;
    }
  }

  static (DateTime?, DateTime?) _period(Map<String, Object?> subscription) {
    var start = asUnixDateTime(subscription['current_period_start']);
    var end = asUnixDateTime(subscription['current_period_end']);
    if (start != null && end != null) return (start, end);

    final items = asJsonMap(subscription['items']);
    final data = items?['data'];
    if (data is List && data.isNotEmpty) {
      final first = asJsonMap(data.first);
      start ??= asUnixDateTime(first?['current_period_start']);
      end ??= asUnixDateTime(first?['current_period_end']);
    }
    return (start, end);
  }
}
