import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/envelope_goals/envelope_goal_endpoint.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';
import 'catalogue_helpers.dart';

void main() {
  late PgTestServer server;
  late EnvelopeGoalEndpoint endpoint;
  late EventLog events;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() {
    events = EventLog()..install();
    endpoint = EnvelopeGoalEndpoint();
  });

  tearDown(() {
    events.reset();
  });

  Future<BudgetTestBook> newBook() =>
      BudgetTestBook.create(server.anonymousSession());

  test('upsert creates, updates and lists one goal per envelope', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final envelope = await book.addEnvelopeIn(category);

    final created = await endpoint.upsert(
      book.session,
      envelope.id!,
      EnvelopeGoalKind.monthlyFunding,
      25000,
    );
    expect(created.entityId, book.entity.id);
    expect(created.envelopeId, envelope.id);
    expect(created.kind, EnvelopeGoalKind.monthlyFunding);
    expect(created.amountMinor, 25000);
    expect(created.targetDate, isNull);
    expect(events.events.last.scope, ChangeScope.plan);

    final updated = await endpoint.upsert(
      book.session,
      envelope.id!,
      EnvelopeGoalKind.targetByDate,
      90000,
      targetDate: DateTime.utc(2027, 4),
    );
    expect(updated.id, created.id);
    expect(updated.kind, EnvelopeGoalKind.targetByDate);
    expect(updated.amountMinor, 90000);
    expect(updated.targetDate, DateTime.utc(2027, 4));

    final cleared = await endpoint.upsert(
      book.session,
      envelope.id!,
      EnvelopeGoalKind.monthlyFunding,
      30000,
    );
    expect(cleared.id, created.id);
    expect(cleared.kind, EnvelopeGoalKind.monthlyFunding);
    expect(cleared.amountMinor, 30000);
    expect(cleared.targetDate, isNull);

    final listed = await endpoint.list(book.session, book.entity.id!);
    expect(listed, hasLength(1));
    expect(listed.single.id, created.id);
  });

  test('upsert validates amountMinor', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final envelope = await book.addEnvelopeIn(category);

    await expectLater(
      endpoint.upsert(
        book.session,
        envelope.id!,
        EnvelopeGoalKind.monthlyFunding,
        0,
      ),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.upsert(
        book.session,
        envelope.id!,
        EnvelopeGoalKind.monthlyFunding,
        -1,
      ),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.upsert(
        book.session,
        envelope.id!,
        EnvelopeGoalKind.monthlyFunding,
        maxSafeMinor + 1,
      ),
      throwsA(isA<ValidationException>()),
    );
    expect(
      await EnvelopeGoal.db.count(
        book.session,
        where: (t) => t.entityId.equals(book.entity.id),
      ),
      0,
    );
  });

  test('upsert applies the targetDate rules by kind', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final envelope = await book.addEnvelopeIn(category);

    await expectLater(
      endpoint.upsert(
        book.session,
        envelope.id!,
        EnvelopeGoalKind.targetByDate,
        1000,
      ),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.upsert(
        book.session,
        envelope.id!,
        EnvelopeGoalKind.monthlyFunding,
        1000,
        targetDate: DateTime.utc(2027),
      ),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.upsert(
        book.session,
        envelope.id!,
        EnvelopeGoalKind.targetByDate,
        1000,
        targetDate: DateTime.utc(2027, 1, 1, 12),
      ),
      throwsA(isA<ValidationException>()),
    );

    final accepted = await endpoint.upsert(
      book.session,
      envelope.id!,
      EnvelopeGoalKind.targetByDate,
      1000,
      targetDate: DateTime.utc(2020),
    );
    expect(accepted.targetDate, DateTime.utc(2020));
  });

  test(
    'every goal operation rejects foreign ids and archived writes',
    () async {
      final book = await newBook();
      final other = await BudgetTestBook.create(server.anonymousSession());
      final otherCategory = await other.addCategory(name: 'Private');
      final otherEnvelope = await other.addEnvelopeIn(otherCategory);
      final otherGoal = await other.addGoal(otherEnvelope);
      final archived = await book.addEntity(
        archivedAt: DateTime.utc(2026, 11),
      );
      final archivedCategory = await book.addCategory(
        name: 'Old',
        entity: archived,
      );
      final archivedEnvelope = await book.addEnvelopeIn(archivedCategory);
      final archivedGoal = await book.addGoal(archivedEnvelope);

      await expectLater(
        endpoint.upsert(
          book.session,
          otherEnvelope.id!,
          EnvelopeGoalKind.monthlyFunding,
          1000,
        ),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.list(book.session, other.entity.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.delete(book.session, otherGoal.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.upsert(
          book.session,
          archivedEnvelope.id!,
          EnvelopeGoalKind.monthlyFunding,
          1000,
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.delete(book.session, archivedGoal.id!),
        throwsA(isA<ValidationException>()),
      );
      expect(
        await endpoint.list(book.session, archived.id!),
        hasLength(1),
      );
    },
  );

  test('delete removes the goal and publishes after commit', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final envelope = await book.addEnvelopeIn(category);
    final goal = await book.addGoal(envelope, amountMinor: 5000);
    events.events.clear();

    await endpoint.delete(book.session, goal.id!);

    expect(await EnvelopeGoal.db.findById(book.session, goal.id!), isNull);
    expect(events.events.single.scope, ChangeScope.plan);
  });

  test('list returns only the entity goals', () async {
    final book = await newBook();
    final other = await BudgetTestBook.create(server.anonymousSession());
    final category = await book.addCategory();
    final first = await book.addEnvelopeIn(category, name: 'First');
    final second = await book.addEnvelopeIn(category, name: 'Second');
    await book.addGoal(first);
    await book.addGoal(second, amountMinor: 2000);
    await other.addGoal(await other.addEnvelopeIn(await other.addCategory()));

    final listed = await endpoint.list(book.session, book.entity.id!);

    expect(listed, hasLength(2));
    expect(
      listed.map((goal) => goal.envelopeId).toSet(),
      {first.id, second.id},
    );
  });

  test('unauthenticated calls fail before any write', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final envelope = await book.addEnvelopeIn(category);
    final goal = await book.addGoal(envelope);
    final anonymous = server.anonymousSession();

    await expectLater(
      endpoint.list(anonymous, book.entity.id!),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    await expectLater(
      endpoint.upsert(
        anonymous,
        envelope.id!,
        EnvelopeGoalKind.monthlyFunding,
        1000,
      ),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    await expectLater(
      endpoint.delete(anonymous, goal.id!),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    expect(await EnvelopeGoal.db.findById(book.session, goal.id!), isNotNull);
  });
}
