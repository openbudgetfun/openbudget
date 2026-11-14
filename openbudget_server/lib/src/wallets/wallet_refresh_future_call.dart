import 'package:meta/meta.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/wallets/prices/price_service.dart';
import 'package:openbudget_server/src/wallets/wallet_service.dart';
import 'package:openbudget_server/src/wallets/wallet_vendor_request_counter.dart';
import 'package:serverpod/serverpod.dart';

/// A summary of one hourly wallet refresh run.
class WalletRefreshReport {
  const WalletRefreshReport({
    required this.reads,
    required this.revaluations,
    required this.processed,
    required this.skipped,
  });

  final int reads;
  final int revaluations;
  final int processed;
  final int skipped;
}

/// Hourly refresh of wallet holdings: due reads by plan, then a revaluation
/// of every wallet that was not read this run.
class WalletRefreshFutureCall extends FutureCall {
  static final _log = ObLogger('WalletRefreshFutureCall');

  /// Stable identifier for the recurring schedule.
  static const identifier = 'wallet-refresh-hourly';

  /// The sweep interval.
  static const interval = Duration(hours: 1);

  /// Read cadence for a free plan.
  static const freeReadInterval = Duration(hours: 24);

  /// Read cadence for a Plus plan.
  static const plusReadInterval = Duration(hours: 6);

  /// Maximum number of wallets read in one run.
  @visibleForTesting
  static int readCap = 500;

  /// Runs one refresh pass over every wallet.
  Future<void> refresh(Session session) async {
    await run(session);
  }

  /// Internal implementation returning the report.
  @visibleForTesting
  static Future<WalletRefreshReport> run(Session session) =>
      WalletVendorRequestCounter.track(() => _run(session));

  static Future<WalletRefreshReport> _run(Session session) async {
    final now = WalletService.clock();

    final wallets = await Wallet.db.find(
      session,
      orderBy: (t) => t.lastSyncedAt,
    );

    // Load the entities for all wallets in one query.
    final entityIds = wallets.map((w) => w.entityId).toSet();
    final entities = entityIds.isEmpty
        ? const <Entity>[]
        : await Entity.db.find(
            session,
            where: (t) => t.id.inSet(entityIds),
          );
    final entityById = <UuidValue, Entity>{
      for (final entity in entities) entity.id!: entity,
    };

    // Resolve entitlements per distinct owner once.
    final ownerIds = entities.map((e) => e.ownerId).toSet();
    final entitlementByOwner = <UuidValue, Entitlement?>{};
    for (final ownerId in ownerIds) {
      entitlementByOwner[ownerId] = await EntitlementService.activeFor(
        session,
        ownerId,
        now: now,
      );
    }

    final due = <Wallet>[];
    for (final wallet in wallets) {
      final entity = entityById[wallet.entityId];
      if (entity == null || entity.archivedAt != null) continue;
      final entitlement = entitlementByOwner[entity.ownerId];
      final readInterval = entitlement == null
          ? freeReadInterval
          : plusReadInterval;
      final last = wallet.lastSyncedAt;
      final isDue = last == null || now.difference(last) >= readInterval;
      if (isDue) due.add(wallet);
    }

    final toRead = due.take(readCap).map((w) => w.id).toSet();

    // Price sweep: distinct (network, assetId) keys of priced holdings across
    // the wallets being revalued. Resolved once for the whole run.
    final revaluedWalletIds = wallets
        .where((w) => !toRead.contains(w.id))
        .map((w) => w.id!)
        .toSet();
    final sweepHoldings = revaluedWalletIds.isEmpty
        ? const <WalletHolding>[]
        : await WalletHolding.db.find(
            session,
            where: (t) => t.walletId.inSet(revaluedWalletIds),
          );
    final sweepKeys = <(WalletNetwork, String)>{
      for (final holding in sweepHoldings) (holding.network, holding.assetId),
    };
    final prices = sweepKeys.isEmpty
        ? const <(WalletNetwork, String), AssetPrice?>{}
        : await PriceService.resolve(session, sweepKeys, now: now);

    var reads = 0;
    var revaluations = 0;
    var processed = 0;
    var skipped = 0;

    for (final wallet in wallets) {
      final entity = entityById[wallet.entityId];
      if (entity == null || entity.archivedAt != null) {
        skipped++;
        continue;
      }

      SystemEntityOwner owner;
      try {
        owner = EntityAccess.systemOwnerFromEntity(entity);
      } on Object catch (error, stackTrace) {
        _log.warning(
          'Wallet refresh could not resolve owner for ${wallet.id}: '
          '${error.runtimeType}',
          stackTrace,
        );
        skipped++;
        continue;
      }

      try {
        if (toRead.contains(wallet.id)) {
          await WalletService.sync(
            session,
            wallet.id!,
            force: true,
            systemOwner: owner,
          );
          reads++;
        } else {
          await WalletService.revalue(
            session,
            wallet.id!,
            systemOwner: owner,
            prices: prices,
          );
          revaluations++;
        }
        processed++;
      } on Object catch (error, stackTrace) {
        _log.warning(
          'Wallet refresh failed for ${wallet.id}: ${error.runtimeType}',
          stackTrace,
        );
        skipped++;
      }
    }

    _log.info(
      'Wallet refresh: $reads read(s), $revaluations revaluation(s), '
      '$processed processed, $skipped skipped.',
    );

    return WalletRefreshReport(
      reads: reads,
      revaluations: revaluations,
      processed: processed,
      skipped: skipped,
    );
  }
}
