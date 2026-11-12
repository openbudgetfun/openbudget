import 'package:meta/meta.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Publishes one committed change through Serverpod's cross-instance bus.
typedef EntityEventPublisher = Future<void> Function(
  Session session,
  UuidValue entityId,
  ChangeScope scope, {
  int? month,
  UuidValue? accountId,
});

/// Publishes committed mutations through Serverpod's cross-instance bus.
abstract final class EntityRealtimeNotifier {
  static EntityEventPublisher _publisher = _post;

  /// Replaces how committed events are delivered. Tests use this to observe
  /// notifications without opening a WebSocket.
  @visibleForTesting
  static EntityEventPublisher get debugPublisher => _publisher;

  @visibleForTesting
  static set debugPublisher(EntityEventPublisher publisher) {
    _publisher = publisher;
  }

  /// Restores the production message bus after a test replacement.
  @visibleForTesting
  static void resetForTests() {
    _publisher = _post;
  }

  /// Call only after the writing database transaction has committed.
  static Future<void> notify(
    Session session,
    UuidValue entityId,
    ChangeScope scope, {
    int? month,
    UuidValue? accountId,
  }) =>
      _publisher(session, entityId, scope, month: month, accountId: accountId);

  static Future<void> _post(
    Session session,
    UuidValue entityId,
    ChangeScope scope, {
    int? month,
    UuidValue? accountId,
  }) => session.messages.postMessage(
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
