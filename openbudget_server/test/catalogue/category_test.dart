import 'package:openbudget_server/src/categories/category_endpoint.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';
import 'catalogue_helpers.dart';

void main() {
  late PgTestServer server;
  late CategoryEndpoint endpoint;
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
    endpoint = CategoryEndpoint();
  });

  tearDown(() {
    events.reset();
  });

  Future<BudgetTestBook> newBook() =>
      BudgetTestBook.create(server.anonymousSession());

  test('create trims the name and appends the next position', () async {
    final book = await newBook();

    final first = await endpoint.create(
      book.session,
      book.entity.id!,
      '  Food  ',
    );
    final second = await endpoint.create(
      book.session,
      book.entity.id!,
      'Transport',
    );

    expect(first.name, 'Food');
    expect(first.entityId, book.entity.id);
    expect(first.sortOrder, 0);
    expect(first.isHidden, isFalse);
    expect(second.sortOrder, 1);
    expect(events.events, isNotEmpty);
    expect(
      events.events.every((event) => event.scope == ChangeScope.plan),
      isTrue,
    );
  });

  test('create rejects an empty name and archived writes', () async {
    final book = await newBook();
    final archived = await book.addEntity(
      archivedAt: DateTime.utc(2026, 11),
    );
    final archivedCategory = await book.addCategory(
      name: 'Old',
      entity: archived,
    );

    await expectLater(
      endpoint.create(book.session, book.entity.id!, '   '),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.create(book.session, archived.id!, 'Food'),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.update(book.session, archivedCategory.id!, name: 'Changed'),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.reorder(book.session, archived.id!, [archivedCategory.id!]),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.delete(book.session, archivedCategory.id!),
      throwsA(isA<ValidationException>()),
    );
    expect(
      await Category.db.count(
        book.session,
        where: (t) => t.entityId.equals(book.entity.id),
      ),
      0,
    );
    expect(
      await Category.db.count(
        book.session,
        where: (t) => t.entityId.equals(archived.id),
      ),
      1,
    );
  });

  test('list and get include hidden categories', () async {
    final book = await newBook();
    final visible = await book.addCategory(name: 'Visible');
    final hidden = await book.addCategory(
      name: 'Hidden',
      sortOrder: 1,
      isHidden: true,
    );

    final listed = await endpoint.list(book.session, book.entity.id!);
    final loaded = await endpoint.get(book.session, hidden.id!);

    expect(listed.map((row) => row.id), [visible.id, hidden.id]);
    expect(loaded.isHidden, isTrue);
    expect(loaded.name, 'Hidden');

    final reordered = await endpoint.reorder(book.session, book.entity.id!, [
      hidden.id!,
      visible.id!,
    ]);
    expect(reordered.map((row) => row.id), [hidden.id, visible.id]);
  });

  test('update renames and hides a category', () async {
    final book = await newBook();
    final category = await book.addCategory(name: 'Food');

    final updated = await endpoint.update(
      book.session,
      category.id!,
      name: '  Dining  ',
      isHidden: true,
    );

    expect(updated.name, 'Dining');
    expect(updated.isHidden, isTrue);
    expect(updated.sortOrder, category.sortOrder);
    expect(events.events.single.scope, ChangeScope.plan);
  });

  test('reorder writes the exact order and rolls back a bad list', () async {
    final book = await newBook();
    final first = await book.addCategory(name: 'First');
    final second = await book.addCategory(name: 'Second', sortOrder: 1);
    final third = await book.addCategory(name: 'Third', sortOrder: 2);

    final reordered = await endpoint.reorder(book.session, book.entity.id!, [
      third.id!,
      first.id!,
      second.id!,
    ]);
    expect(reordered.map((row) => row.id), [third.id, first.id, second.id]);
    expect(reordered.map((row) => row.sortOrder), [0, 1, 2]);

    await expectLater(
      endpoint.reorder(book.session, book.entity.id!, [
        first.id!,
        first.id!,
      ]),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.reorder(book.session, book.entity.id!, [
        first.id!,
        second.id!,
      ]),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.reorder(book.session, book.entity.id!, [
        first.id!,
        second.id!,
        third.id!,
        const Uuid().v7obj(),
      ]),
      throwsA(isA<ValidationException>()),
    );

    final stored = await endpoint.list(book.session, book.entity.id!);
    expect(stored.map((row) => row.id), [third.id, first.id, second.id]);
  });

  test('delete rejects a category with a hidden envelope', () async {
    final book = await newBook();
    final category = await book.addCategory();
    await book.addEnvelopeIn(category, name: 'Hidden pot', isHidden: true);

    await expectLater(
      endpoint.delete(book.session, category.id!),
      throwsA(isA<ValidationException>()),
    );

    expect(
      await Category.db.findById(book.session, category.id!),
      isNotNull,
    );
    expect(
      await Envelope.db.count(
        book.session,
        where: (t) => t.categoryId.equals(category.id),
      ),
      1,
    );
  });

  test('delete removes an empty category and publishes after commit', () async {
    final book = await newBook();
    final category = await book.addCategory();

    await endpoint.delete(book.session, category.id!);

    expect(await Category.db.findById(book.session, category.id!), isNull);
    expect(events.events.single.scope, ChangeScope.plan);
  });

  test('every category operation rejects a foreign entity or id', () async {
    final book = await newBook();
    final other = await BudgetTestBook.create(server.anonymousSession());
    final otherCategory = await other.addCategory(name: 'Private');
    final own = await book.addCategory(name: 'Mine');

    await expectLater(
      endpoint.create(book.session, other.entity.id!, 'Nope'),
      throwsA(isA<ForbiddenException>()),
    );
    await expectLater(
      endpoint.list(book.session, other.entity.id!),
      throwsA(isA<ForbiddenException>()),
    );
    await expectLater(
      endpoint.get(book.session, otherCategory.id!),
      throwsA(isA<ForbiddenException>()),
    );
    await expectLater(
      endpoint.update(book.session, otherCategory.id!, name: 'Steal'),
      throwsA(isA<ForbiddenException>()),
    );
    await expectLater(
      endpoint.reorder(book.session, other.entity.id!, const []),
      throwsA(isA<ForbiddenException>()),
    );
    await expectLater(
      endpoint.delete(book.session, otherCategory.id!),
      throwsA(isA<ForbiddenException>()),
    );
    final reordered = await endpoint.reorder(book.session, book.entity.id!, [
      own.id!,
    ]);
    expect(reordered.single.id, own.id);
  });

  test('unauthenticated calls fail before any write', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final anonymous = server.anonymousSession();

    await expectLater(
      endpoint.list(anonymous, book.entity.id!),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    await expectLater(
      endpoint.get(anonymous, category.id!),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    await expectLater(
      endpoint.create(anonymous, book.entity.id!, 'Nope'),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    await expectLater(
      endpoint.update(anonymous, category.id!, name: 'Nope'),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    await expectLater(
      endpoint.reorder(anonymous, book.entity.id!, [category.id!]),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    await expectLater(
      endpoint.delete(anonymous, category.id!),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    expect(
      await Category.db.count(
        book.session,
        where: (t) => t.entityId.equals(book.entity.id),
      ),
      1,
    );
  });
}
