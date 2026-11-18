import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/recurring_transactions/recurring_transaction_service.dart';
import 'package:serverpod/serverpod.dart';

/// Posts every due recurring occurrence for every entity every hour.
///
/// The call runs with Serverpod's unauthenticated [FutureCallSession]. For
/// each entity it reads the persisted owner through [EntityAccess] and passes
/// that explicit principal to the service; no endpoint parameter, mutable
/// global actor or fake user session is involved. A failure in one schedule or
/// entity is logged and the sweep continues, leaving the failed occurrence
/// due for the next run.
class RecurringPostFutureCall extends FutureCall {
  static final _log = ObLogger('RecurringPostFutureCall');

  /// The stable identifier that deduplicates the hourly registration.
  static const identifier = 'recurring-post-hourly';

  /// The generated future-call dispatch name.
  static const dispatchName = 'RecurringPostPostDueFutureCall';

  /// The sweep interval.
  static const interval = Duration(hours: 1);

  /// Posts all due schedules across every non-archived entity.
  Future<void> postDue(Session session) async {
    final entities = await Entity.db.find(
      session,
      where: (t) => t.archivedAt.equals(null),
      orderBy: (t) => t.id,
    );

    var posted = 0;
    var failed = 0;
    var failedEntities = 0;
    for (final entity in entities) {
      try {
        final owner = await EntityAccess.systemOwnerFor(session, entity.id!);
        final report = await RecurringTransactionService.postDueForSystemJob(
          session,
          entityId: entity.id!,
          systemOwner: owner,
        );
        posted += report.posted;
        failed += report.failed;
      } on Object catch (error, stackTrace) {
        failedEntities++;
        _log.severe(
          'Recurring sweep failed for entity ${entity.id}; continuing',
          error,
          stackTrace,
        );
      }
    }

    _log.info(
      'Recurring sweep posted $posted occurrence(s); '
      '$failed schedule failure(s), $failedEntities entity failure(s)',
    );
  }
}
