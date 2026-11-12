import 'dart:async';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../integration/helpers/auth_helper.dart';
import '../integration/test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Given EntityStreamEndpoint', (sessionBuilder, endpoints) {
    late TestSessionBuilder authedSession;
    late Session rawSession;

    setUp(() async {
      final owner = await createAuthenticatedUser(sessionBuilder);
      authedSession = owner.session;
      rawSession = sessionBuilder.build();
    });

    tearDown(EntityRealtimeNotifier.resetForTests);

    Future<Entity> createEntity([String name = 'Stream Entity']) =>
        endpoints.entity.create(
          authedSession,
          name,
          EntityKind.individual,
          'GB',
          'GBP',
          'Europe/London',
        );

    test(
      'when the entity changes then the watcher receives one event',
      () async {
        final entity = await createEntity();

        final updates = endpoints.entityStream.watch(authedSession, entity.id!);
        final received = Completer<EntityChangedEvent>();
        final subscription = updates.listen(
          received.complete,
          onError: received.completeError,
        );

        // A global message only reaches listeners that are already
        // subscribed, and the Redis subscription behind `createStream` comes
        // up asynchronously. Post until the watcher confirms one event.
        while (!received.isCompleted) {
          await flushEventQueue();
          await EntityRealtimeNotifier.notify(
            rawSession,
            entity.id!,
            ChangeScope.entity,
          );
          await Future.any<Object?>([
            received.future,
            Future<void>.delayed(const Duration(milliseconds: 500)),
          ]);
        }

        final event = await received.future;
        expect(event.entityId, entity.id);
        expect(event.scope, ChangeScope.entity);

        await subscription.cancel();
      },
    );

    test("when watching another user's entity then it is refused", () async {
      final entity = await createEntity();
      final otherSession = createAuthenticatedSession(sessionBuilder);

      await expectLater(
        endpoints.entityStream.watch(otherSession, entity.id!).drain<void>(),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('when the entity is unknown then it is not found', () async {
      await expectLater(
        endpoints.entityStream
            .watch(
              authedSession,
              UuidValue.fromString('01990000-0000-7000-8000-000000000000'),
            )
            .drain<void>(),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
