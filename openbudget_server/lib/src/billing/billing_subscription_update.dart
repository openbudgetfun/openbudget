import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart' show UuidValue;

/// One rail's parsed subscription state, ready for
/// `EntitlementService.record`.
class BillingSubscriptionUpdate {
  const BillingSubscriptionUpdate({
    required this.userId,
    required this.source,
    required this.externalId,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
  });

  final UuidValue userId;
  final EntitlementSource source;
  final String externalId;
  final EntitlementStatus status;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
}
