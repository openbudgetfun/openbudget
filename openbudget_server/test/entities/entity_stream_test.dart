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

    setUp(() {
      authedSession = createAuthenticatedSession(sessionBuilder);
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
        final iterator = StreamIterator(updates);

        final published = EntityRealtimeNotifier.notify(
          rawSession,
          entity.id!,
          ChangeScope.entity,
        );
        final hasNext = await iterator.moveNext().timeout(
          const Duration(seconds: 2),
        );
        await published;

        expect(hasNext, isTrue);
        expect(iterator.current.entityId, entity.id);
        expect(iterator.current.scope, ChangeScope.entity);

        await iterator.cancel();
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
