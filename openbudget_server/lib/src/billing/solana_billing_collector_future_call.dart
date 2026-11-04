import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/billing/billing_secrets.dart';
import 'package:openbudget_server/src/billing/solana_billing_collector.dart';
import 'package:serverpod/serverpod.dart';

/// Hourly collection sweep for Solana subscriptions.
class SolanaBillingCollectorFutureCall extends FutureCall {
  static final _log = ObLogger('SolanaBillingCollectorFutureCall');

  static const List<String> _requiredKeys = [
    BillingSecretKeys.solanaCollectorSecretKey,
    BillingSecretKeys.solanaRpcUrl,
    BillingSecretKeys.solanaSubscriptionPlanAddress,
    BillingSecretKeys.solanaUsdcMint,
  ];

  Future<void> collect(Session session) async {
    // A deployment without Solana billing configured has no subscriptions to
    // collect; skip the sweep instead of failing every hour.
    final missing = [
      for (final key in _requiredKeys)
        if (BillingSecrets.read(session, key) == null) key,
    ];
    if (missing.isNotEmpty) {
      _log.info('Solana billing is not configured; skipping collection');
      return;
    }
    await SolanaBillingCollector.fromSession(session).run(session);
  }
}
