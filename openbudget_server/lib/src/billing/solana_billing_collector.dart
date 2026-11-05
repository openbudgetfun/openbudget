import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/billing/billing_secrets.dart';
import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/billing/solana_billing_chain.dart';
import 'package:openbudget_server/src/billing/solana_billing_plan.dart';
import 'package:openbudget_server/src/billing/solana_rpc_billing_chain.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Counts for one collector sweep.
class SolanaCollectionReport {
  const SolanaCollectionReport({
    required this.processed,
    required this.collected,
    required this.failed,
  });

  final int processed;
  final int collected;
  final int failed;
}

/// Charges due Solana subscriptions and advances or expires their periods.
class SolanaBillingCollector {
  SolanaBillingCollector({
    required this.chain,
    required this.planAddress,
    required this.usdcMint,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  factory SolanaBillingCollector.fromSession(Session session) =>
      SolanaBillingCollector(
        chain: SolanaRpcBillingChain.fromSession(session),
        planAddress: BillingSecrets.require(
          session,
          BillingSecretKeys.solanaSubscriptionPlanAddress,
        ),
        usdcMint: BillingSecrets.require(
          session,
          BillingSecretKeys.solanaUsdcMint,
        ),
      );

  static final _log = ObLogger('SolanaBillingCollector');

  static const _lookAhead = Duration(hours: 24);
  static const _gracePeriod = Duration(days: 3);
  static const Set<EntitlementStatus> _grantingStatuses = {
    EntitlementStatus.active,
    EntitlementStatus.pastDue,
  };

  final SolanaBillingChain chain;
  final String planAddress;
  final String usdcMint;
  final DateTime Function() _clock;

  /// Collects every subscription whose period ends within the next 24 hours.
  Future<SolanaCollectionReport> run(Session session, {DateTime? now}) async {
    final at = (now ?? _clock()).toUtc();
    final due = await Entitlement.db.find(
      session,
      where: (t) =>
          t.source.equals(EntitlementSource.solana) &
          t.status.inSet(_grantingStatuses) &
          (t.currentPeriodEnd <= at.add(_lookAhead)),
      orderBy: (t) => t.currentPeriodEnd.asc(),
    );

    var collected = 0;
    var failed = 0;
    for (final entitlement in due) {
      if (await _collect(session, entitlement, at)) {
        collected += 1;
      } else {
        failed += 1;
      }
    }
    return SolanaCollectionReport(
      processed: due.length,
      collected: collected,
      failed: failed,
    );
  }

  Future<bool> _collect(
    Session session,
    Entitlement entitlement,
    DateTime now,
  ) async {
    SolanaSubscriptionSnapshot? snapshot;
    try {
      snapshot = await chain.fetchSubscription(entitlement.externalId);
    } on Object catch (error) {
      _log.warning(
        'Unable to read Solana subscription '
        '${entitlement.externalId}: ${error.runtimeType}',
      );
    }

    final valid =
        snapshot != null &&
        snapshot.subscriptionAddress == entitlement.externalId &&
        snapshot.planActive &&
        snapshot.subscriptionActive &&
        snapshot.planAddress == planAddress &&
        snapshot.amountBaseUnits == SolanaBillingPlan.amountBaseUnits &&
        snapshot.periodSeconds == SolanaBillingPlan.periodSeconds;

    if (!valid) {
      await _markFailed(session, entitlement, now);
      return false;
    }

    try {
      await chain.transferSubscription(
        subscriptionAddress: entitlement.externalId,
        planAddress: planAddress,
        subscriberAddress: snapshot.subscriberAddress,
        mintAddress: usdcMint,
        amountBaseUnits: SolanaBillingPlan.amountBaseUnits,
      );
    } on Object catch (error) {
      _log.warning(
        'Solana collection failed for ${entitlement.externalId}: '
        '${error.runtimeType}',
      );
      await _markFailed(session, entitlement, now);
      return false;
    }

    final base = entitlement.currentPeriodEnd.isAfter(now)
        ? entitlement.currentPeriodEnd
        : now;
    await EntitlementService.record(
      session,
      userId: entitlement.userId,
      source: EntitlementSource.solana,
      externalId: entitlement.externalId,
      status: EntitlementStatus.active,
      currentPeriodStart: base,
      currentPeriodEnd: base.add(
        const Duration(seconds: SolanaBillingPlan.periodSeconds),
      ),
    );
    return true;
  }

  Future<void> _markFailed(
    Session session,
    Entitlement entitlement,
    DateTime now,
  ) async {
    final expired = now.isAfter(
      entitlement.currentPeriodEnd.add(_gracePeriod),
    );
    await EntitlementService.record(
      session,
      userId: entitlement.userId,
      source: EntitlementSource.solana,
      externalId: entitlement.externalId,
      status: expired ? EntitlementStatus.expired : EntitlementStatus.pastDue,
      currentPeriodStart: entitlement.currentPeriodStart,
      currentPeriodEnd: entitlement.currentPeriodEnd,
    );
  }
}
