import 'package:openbudget_server/src/billing/solana_billing_collector.dart';
import 'package:serverpod/serverpod.dart';

/// Hourly collection sweep for Solana subscriptions.
class SolanaBillingCollectorFutureCall extends FutureCall {
  Future<void> collect(Session session) async {
    await SolanaBillingCollector.fromSession(session).run(session);
  }
}
