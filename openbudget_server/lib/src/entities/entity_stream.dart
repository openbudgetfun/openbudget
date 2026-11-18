import 'package:openbudget_server/src/entities/entity_access.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';

/// Streams scoped changes to the entity's owner.
class EntityStreamEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Ownership is checked before subscribing to the global channel.
  Stream<EntityChangedEvent> watch(Session session, UuidValue entityId) async* {
    await EntityAccess.requireOwned(session, entityId);
    yield* session.messages.createStream<EntityChangedEvent>(
      'entity:$entityId',
    );
  }
}
