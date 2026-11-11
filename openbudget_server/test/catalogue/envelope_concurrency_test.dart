import 'package:openbudget_server/src/categories/category_endpoint.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/envelopes/envelope_endpoint.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';
import 'catalogue_helpers.dart';

void main() {
  late PgTestServer server;
  late CategoryEndpoint categoryEndpoint;
  late EnvelopeEndpoint envelopeEndpoint;
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
    categoryEndpoint = CategoryEndpoint();
    envelopeEndpoint = EnvelopeEndpoint();
  });

  tearDown(() {
    events.reset();
  });

  Future<BudgetTestBook> newBook() =>
      BudgetTestBook.create(server.anonymousSession());

  Future<Object?> attempt(Future<void> future) async {
    try {
      await future;
      return null;
    } on Object catch (error) {
      return error;
    }
  }

  test('concurrent category creates get distinct positions', () async {
    final book = await newBook();
    final secondSession = server.authenticatedSession(book.userId);

    final created = await Future.wait([
      categoryEndpoint.create(book.session, book.entity.id!, 'First'),
      categoryEndpoint.create(secondSession, book.entity.id!, 'Second'),
    ]);

    expect(created.map((row) => row.sortOrder).toSet(), {0, 1});
    final stored = await categoryEndpoint.list(book.session, book.entity.id!);
    expect(stored.map((row) => row.sortOrder), [0, 1]);
  });

  test('concurrent envelope creates get distinct positions', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final secondSession = server.authenticatedSession(book.userId);

    final created = await Future.wait([
      envelopeEndpoint.create(book.session, category.id!, 'First'),
      envelopeEndpoint.create(secondSession, category.id!, 'Second'),
    ]);

    expect(created.map((row) => row.sortOrder).toSet(), {0, 1});
    final stored = await envelopeEndpoint.list(book.session, book.entity.id!);
    expect(stored.map((row) => row.sortOrder), [0, 1]);
  });

  test('concurrent reorders leave one exact permutation', () async {
    final book = await newBook();
    final first = await book.addCategory(name: 'First');
    final second = await book.addCategory(name: 'Second', sortOrder: 1);
    final third = await book.addCategory(name: 'Third', sortOrder: 2);
    final secondSession = server.authenticatedSession(book.userId);

    final outcomes = await Future.wait([
      attempt(
        categoryEndpoint.reorder(book.session, book.entity.id!, [
          first.id!,
          second.id!,
          third.id!,
        ]),
      ),
      attempt(
        categoryEndpoint.reorder(secondSession, book.entity.id!, [
          third.id!,
          second.id!,
          first.id!,
        ]),
      ),
    ]);

    expect(outcomes.whereType<Object>(), isEmpty);
    final stored = await categoryEndpoint.list(book.session, book.entity.id!);
    expect(stored.map((row) => row.sortOrder), [0, 1, 2]);
    expect(stored.map((row) => row.id).toSet(), {
      first.id,
      second.id,
      third.id,
    });
  });

  test('concurrent reassignment leaves one coherent destination', () async {
    final book = await newBook();
    final account = await book.addAccount();
    final category = await book.addCategory();
    final source = await book.addEnvelopeIn(category, name: 'Source');
    final firstDestination = await book.addEnvelopeIn(
      await book.addCategory(),
      name: 'First destination',
    );
    final secondDestination = await book.addEnvelopeIn(
      await book.addCategory(),
      name: 'Second destination',
    );
    await book.addAllocation(source, month: 202611, allocatedMinor: 1000);
    final view = await TransactionWriter.create(
      book.session,
      TransactionInput(
        accountId: account.id!,
        date: EntityClock.today(book.entity),
        amountMinor: -500,
        lines: [
          TransactionLineInput(amountMinor: -500, envelopeId: source.id),
        ],
      ),
    );
    final secondSession = server.authenticatedSession(book.userId);
    events.events.clear();

    final outcomes = await Future.wait([
      attempt(
        envelopeEndpoint.delete(
          book.session,
          source.id!,
          reassignToEnvelopeId: firstDestination.id,
        ),
      ),
      attempt(
        envelopeEndpoint.delete(
          secondSession,
          source.id!,
          reassignToEnvelopeId: secondDestination.id,
        ),
      ),
    ]);

    expect(outcomes.whereType<Object>(), hasLength(1));
    expect(await Envelope.db.findById(book.session, source.id!), isNull);

    final lines = await TransactionLine.db.find(
      book.session,
      where: (t) => t.transactionId.equals(view.transaction.id),
    );
    expect(lines.single.envelopeId, isNot(source.id));
    expect(
      {firstDestination.id, secondDestination.id},
      contains(lines.single.envelopeId),
    );

    final allocations = await MonthlyAllocation.db.find(
      book.session,
      where: (t) => t.entityId.equals(book.entity.id),
    );
    expect(allocations, hasLength(1));
    expect(allocations.single.envelopeId, lines.single.envelopeId);
    expect(allocations.single.allocatedMinor, 1000);
  });

  test(
    'a line write racing a reassignment settles without dangling rows',
    () async {
      final book = await newBook();
      final account = await book.addAccount();
      final secondAccount = await book.addAccount(name: 'Second');
      final source = await book.addEnvelopeIn(await book.addCategory());
      final destination = await book.addEnvelopeIn(await book.addCategory());
      final existing = await TransactionWriter.create(
        book.session,
        TransactionInput(
          accountId: account.id!,
          date: EntityClock.today(book.entity),
          amountMinor: -500,
          lines: [
            TransactionLineInput(amountMinor: -500, envelopeId: source.id),
          ],
        ),
      );
      final secondSession = server.authenticatedSession(book.userId);
      events.events.clear();

      final outcomes = await Future.wait([
        attempt(
          envelopeEndpoint.delete(
            book.session,
            source.id!,
            reassignToEnvelopeId: destination.id,
          ),
        ),
        attempt(
          TransactionWriter.create(
            secondSession,
            TransactionInput(
              accountId: secondAccount.id!,
              date: EntityClock.today(book.entity),
              amountMinor: -700,
              lines: [
                TransactionLineInput(amountMinor: -700, envelopeId: source.id),
              ],
            ),
          ).then((_) {}),
        ),
      ]);

      if (outcomes.first != null) {
        expect(outcomes.first, isA<ValidationException>());
        expect(await Envelope.db.findById(book.session, source.id!), isNotNull);
        await envelopeEndpoint.delete(
          book.session,
          source.id!,
          reassignToEnvelopeId: destination.id,
        );
      }

      expect(await Envelope.db.findById(book.session, source.id!), isNull);
      expect(
        await TransactionLine.db.count(
          book.session,
          where: (t) => t.envelopeId.equals(source.id),
        ),
        0,
      );

      final moved = await TransactionLine.db.find(
        book.session,
        where: (t) => t.transactionId.equals(existing.transaction.id),
      );
      expect(moved.single.envelopeId, destination.id);
      expect(events.planMonths, isNotEmpty);
    },
  );

  test('concurrent category delete and envelope create never orphan', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final secondSession = server.authenticatedSession(book.userId);

    final outcomes = await Future.wait([
      attempt(categoryEndpoint.delete(book.session, category.id!)),
      attempt(
        envelopeEndpoint.create(
          secondSession,
          category.id!,
          'Racing envelope',
        ),
      ),
    ]);

    expect(outcomes.whereType<Object>(), hasLength(1));
    final storedCategory = await Category.db.findById(
      book.session,
      category.id!,
    );
    final envelopes = await Envelope.db.find(
      book.session,
      where: (t) => t.categoryId.equals(category.id),
    );
    if (storedCategory == null) {
      expect(envelopes, isEmpty);
    } else {
      expect(envelopes, hasLength(1));
    }
  });
}
