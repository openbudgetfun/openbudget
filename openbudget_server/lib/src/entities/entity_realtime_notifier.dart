import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Publishes committed mutations through Serverpod's cross-instance bus.
abstract final class EntityRealtimeNotifier {
  /// Call only after the writing database transaction has committed.
  static Future<void> notify(
    Session session,
    UuidValue entityId,
    ChangeScope scope, {
    int? month,
    UuidValue? accountId,
  }) async {
    await session.messages.postMessage(
      'entity:$entityId',
      EntityChangedEvent(
        entityId: entityId,
        scope: scope,
        month: month,
        accountId: accountId,
      ),
      scope: MessageScope.global,
    );
  }
}
