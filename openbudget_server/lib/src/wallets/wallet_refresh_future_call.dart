import 'package:meta/meta.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/wallets/wallet_service.dart';
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

  int get readCount => reads;
  int get revaluationCount => revaluations;
  int get walletsRead => reads;
  int get walletsRevalued => revaluations;
}

/// Backwards-compatible alias.
typedef WalletRefreshResult = WalletRefreshReport;
typedef WalletRefreshSummary = WalletRefreshReport;

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

  /// The report from the most recent [refresh] run.
  static WalletRefreshReport? lastReport;

  /// Runs one refresh pass over every wallet.
  Future<void> refresh(Session session) async {
    lastReport = await _run(session);
  }

  /// Internal implementation returning the report.
  static Future<WalletRefreshReport> _run(Session session) async {
    final now = WalletService.clock();

    final wallets = await Wallet.db.find(
      session,
      orderBy: (t) => t.lastSyncedAt,
    );
    wallets.sort((a, b) {
      final aTime = a.lastSyncedAt;
      final bTime = b.lastSyncedAt;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return -1;
      if (bTime == null) return 1;
      return aTime.compareTo(bTime);
    });

    final due = <Wallet>[];
    for (final wallet in wallets) {
      final entity = await Entity.db.findById(session, wallet.entityId);
      if (entity == null || entity.archivedAt != null) continue;
      final entitlement = await EntitlementService.activeFor(
        session,
        entity.ownerId,
        now: now,
      );
      final readInterval = entitlement == null
          ? freeReadInterval
          : plusReadInterval;
      final last = wallet.lastSyncedAt;
      final isDue = last == null || now.difference(last) >= readInterval;
      if (isDue) due.add(wallet);
    }

    final toRead = due.take(readCap).map((w) => w.id).toSet();

    var reads = 0;
    var revaluations = 0;
    var processed = 0;
    var skipped = 0;

    for (final wallet in wallets) {
      final entity = await Entity.db.findById(session, wallet.entityId);
      if (entity == null || entity.archivedAt != null) {
        skipped++;
        continue;
      }

      SystemEntityOwner owner;
      try {
        owner = await EntityAccess.systemOwnerFor(session, entity.id!);
      } on Object catch (error, stackTrace) {
        _log.warning(
          'Wallet refresh could not resolve owner for ${wallet.id}: $error',
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
          );
          revaluations++;
        }
        processed++;
      } on Object catch (error, stackTrace) {
        _log.warning(
          'Wallet refresh failed for ${wallet.id}: $error',
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
