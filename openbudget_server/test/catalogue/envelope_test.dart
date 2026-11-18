import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/envelopes/envelope_endpoint.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';
import 'catalogue_helpers.dart';

void main() {
  late PgTestServer server;
  late EnvelopeEndpoint endpoint;
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
    endpoint = EnvelopeEndpoint();
  });

  tearDown(() {
    events.reset();
  });

  Future<BudgetTestBook> newBook({
    AccountingMode accountingMode = AccountingMode.envelope,
  }) => BudgetTestBook.create(
    server.anonymousSession(),
    accountingMode: accountingMode,
  );

  Future<LedgerAccount> addLedgerAccount(
    BudgetTestBook book, {
    String code = '6100',
    String name = 'Office costs',
    LedgerAccountType type = LedgerAccountType.expense,
    LedgerSystemRole? systemRole,
    DateTime? archivedAt,
    Entity? entity,
  }) {
    final owner = entity ?? book.entity;
    return LedgerAccount.db.insertRow(
      book.session,
      LedgerAccount(
        entityId: owner.id!,
        code: code,
        name: name,
        type: type,
        systemRole: systemRole,
        archivedAt: archivedAt,
      ),
    );
  }

  test('create trims, stores metadata and appends per category', () async {
    final book = await newBook();
    final category = await book.addCategory();

    final first = await endpoint.create(
      book.session,
      category.id!,
      '  Groceries  ',
      note: '  weekly shop  ',
      taxCategoryCode: ' gb.ind.employment ',
    );
    final second = await endpoint.create(
      book.session,
      category.id!,
      'Dining',
    );

    expect(first.name, 'Groceries');
    expect(first.note, 'weekly shop');
    expect(first.taxCategoryCode, 'gb.ind.employment');
    expect(first.entityId, book.entity.id);
    expect(first.sortOrder, 0);
    expect(second.sortOrder, 1);
    expect(events.events.last.scope, ChangeScope.plan);
  });

  test('create validates name, tax code and archived entities', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final archived = await book.addEntity(
      archivedAt: DateTime.utc(2026, 11),
    );
    final archivedCategory = await book.addCategory(
      name: 'Old',
      entity: archived,
    );
    final archivedEnvelope = await book.addEnvelopeIn(
      archivedCategory,
      name: 'Old pot',
    );

    await expectLater(
      endpoint.create(book.session, category.id!, '   '),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.create(
        book.session,
        category.id!,
        'Bad code',
        taxCategoryCode: 'not.a.real.code',
      ),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.create(book.session, archivedCategory.id!, 'Old pot'),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.update(book.session, archivedEnvelope.id!, name: 'Changed'),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.reorder(book.session, archivedCategory.id!, [
        archivedEnvelope.id!,
      ]),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.delete(book.session, archivedEnvelope.id!),
      throwsA(isA<ValidationException>()),
    );
    expect(
      await Envelope.db.count(
        book.session,
        where: (t) => t.entityId.equals(book.entity.id),
      ),
      0,
    );
    expect(
      await Envelope.db.count(
        book.session,
        where: (t) => t.entityId.equals(archived.id),
      ),
      1,
    );
  });

  test('list returns every envelope in category then position order', () async {
    final book = await newBook();
    final firstCategory = await book.addCategory(name: 'First');
    final secondCategory = await book.addCategory(name: 'Second', sortOrder: 1);
    final late = await book.addEnvelopeIn(
      firstCategory,
      name: 'Late',
      sortOrder: 2,
    );
    final hidden = await book.addEnvelopeIn(
      firstCategory,
      name: 'Hidden',
      sortOrder: 1,
      isHidden: true,
    );
    final other = await book.addEnvelopeIn(
      secondCategory,
      name: 'Other',
    );

    final listed = await endpoint.list(book.session, book.entity.id!);

    expect(listed.map((row) => row.id), [hidden.id, late.id, other.id]);
    expect(listed.where((row) => row.isHidden), hasLength(1));

    final reordered = await endpoint.reorder(
      book.session,
      firstCategory.id!,
      [late.id!, hidden.id!],
    );
    expect(reordered.map((row) => row.id), [late.id, hidden.id]);
  });

  test('update moves a category and appends to its new list', () async {
    final book = await newBook();
    final firstCategory = await book.addCategory(name: 'First');
    final secondCategory = await book.addCategory(name: 'Second', sortOrder: 1);
    final envelope = await book.addEnvelopeIn(
      firstCategory,
      name: 'Move me',
      sortOrder: 4,
    );
    await book.addEnvelopeIn(secondCategory, name: 'Existing');

    final updated = await endpoint.update(
      book.session,
      envelope.id!,
      categoryId: secondCategory.id,
      name: 'Moved',
    );

    expect(updated.categoryId, secondCategory.id);
    expect(updated.sortOrder, 1);
    expect(updated.name, 'Moved');
    expect(updated.entityId, book.entity.id);
  });

  test('update rejects a foreign category', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final other = await BudgetTestBook.create(server.anonymousSession());
    final foreignCategory = await other.addCategory(name: 'Private');
    final envelope = await book.addEnvelopeIn(category);

    await expectLater(
      endpoint.update(
        book.session,
        envelope.id!,
        categoryId: foreignCategory.id,
      ),
      throwsA(isA<ForbiddenException>()),
    );
    final stored = await Envelope.db.findById(book.session, envelope.id!);
    expect(stored, isNotNull);
    expect(stored!.categoryId, category.id);
  });

  test('update handles note, tax code and ledger default clears', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final envelope = await book.addEnvelopeIn(category);
    final ledger = await addLedgerAccount(book);

    final coded = await endpoint.update(
      book.session,
      envelope.id!,
      note: '  keep this  ',
      taxCategoryCode: 'gb.ind.employment',
      defaultLedgerAccountId: ledger.id,
    );
    expect(coded.note, 'keep this');
    expect(coded.taxCategoryCode, 'gb.ind.employment');
    expect(coded.defaultLedgerAccountId, ledger.id);

    final cleared = await endpoint.update(
      book.session,
      envelope.id!,
      note: '   ',
      clearTaxCategoryCode: true,
      clearDefaultLedgerAccount: true,
    );
    expect(cleared.note, isNull);
    expect(cleared.taxCategoryCode, isNull);
    expect(cleared.defaultLedgerAccountId, isNull);
  });

  test('update rejects conflicting clear flags', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final envelope = await book.addEnvelopeIn(category);

    await expectLater(
      endpoint.update(
        book.session,
        envelope.id!,
        taxCategoryCode: 'gb.ind.employment',
        clearTaxCategoryCode: true,
      ),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.update(
        book.session,
        envelope.id!,
        defaultLedgerAccountId: const Uuid().v7obj(),
        clearDefaultLedgerAccount: true,
      ),
      throwsA(isA<ValidationException>()),
    );
  });

  test('ledger default must be active, same entity and not a bank', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final envelope = await book.addEnvelopeIn(category);
    final foreign = await book.addEntity(name: 'Foreign book');
    final foreignAccount = await addLedgerAccount(
      book,
      entity: foreign,
      code: '7000',
    );
    final archived = await addLedgerAccount(
      book,
      code: '7001',
      archivedAt: DateTime.utc(2026, 11),
    );
    final bank = await addLedgerAccount(
      book,
      code: '1000',
      name: 'Bank',
      type: LedgerAccountType.asset,
      systemRole: LedgerSystemRole.bank,
    );

    await expectLater(
      endpoint.update(
        book.session,
        envelope.id!,
        defaultLedgerAccountId: foreignAccount.id,
      ),
      throwsA(isA<ForbiddenException>()),
    );
    await expectLater(
      endpoint.update(
        book.session,
        envelope.id!,
        defaultLedgerAccountId: archived.id,
      ),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.update(
        book.session,
        envelope.id!,
        defaultLedgerAccountId: bank.id,
      ),
      throwsA(isA<ValidationException>()),
    );
  });

  test('reorder writes the exact order and rolls back a bad list', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final first = await book.addEnvelopeIn(category, name: 'First');
    final second = await book.addEnvelopeIn(
      category,
      name: 'Second',
      sortOrder: 1,
    );
    final third = await book.addEnvelopeIn(
      category,
      name: 'Third',
      sortOrder: 2,
    );

    final reordered = await endpoint.reorder(
      book.session,
      category.id!,
      [third.id!, first.id!, second.id!],
    );
    expect(reordered.map((row) => row.id), [third.id, first.id, second.id]);
    expect(reordered.map((row) => row.sortOrder), [0, 1, 2]);

    await expectLater(
      endpoint.reorder(book.session, category.id!, [first.id!, first.id!]),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      endpoint.reorder(book.session, category.id!, [first.id!, second.id!]),
      throwsA(isA<ValidationException>()),
    );

    final stored = await endpoint.list(book.session, book.entity.id!);
    expect(stored.map((row) => row.id), [third.id, first.id, second.id]);
  });

  test('delete removes an unused envelope', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final envelope = await book.addEnvelopeIn(category);

    await endpoint.delete(book.session, envelope.id!);

    expect(await Envelope.db.findById(book.session, envelope.id!), isNull);
    expect(events.events.single.scope, ChangeScope.plan);
  });

  test('delete rejects an envelope used by transaction lines', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final envelope = await book.addEnvelopeIn(category);
    final account = await book.addAccount();

    await TransactionWriter.create(
      book.session,
      TransactionInput(
        accountId: account.id!,
        date: EntityClock.today(book.entity),
        amountMinor: -1000,
        lines: [
          TransactionLineInput(amountMinor: -1000, envelopeId: envelope.id),
        ],
      ),
    );
    events.events.clear();

    await expectLater(
      endpoint.delete(book.session, envelope.id!),
      throwsA(isA<ValidationException>()),
    );

    expect(await Envelope.db.findById(book.session, envelope.id!), isNotNull);
    expect(events.events, isEmpty);
  });

  test('every envelope operation rejects a foreign entity or id', () async {
    final book = await newBook();
    final other = await BudgetTestBook.create(server.anonymousSession());
    final otherCategory = await other.addCategory(name: 'Private');
    final otherEnvelope = await other.addEnvelopeIn(otherCategory);
    final category = await book.addCategory();
    final own = await book.addEnvelopeIn(category);

    await expectLater(
      endpoint.create(book.session, otherCategory.id!, 'Nope'),
      throwsA(isA<ForbiddenException>()),
    );
    await expectLater(
      endpoint.list(book.session, other.entity.id!),
      throwsA(isA<ForbiddenException>()),
    );
    await expectLater(
      endpoint.get(book.session, otherEnvelope.id!),
      throwsA(isA<ForbiddenException>()),
    );
    await expectLater(
      endpoint.update(book.session, otherEnvelope.id!, name: 'Steal'),
      throwsA(isA<ForbiddenException>()),
    );
    await expectLater(
      endpoint.reorder(book.session, otherCategory.id!, [otherEnvelope.id!]),
      throwsA(isA<ForbiddenException>()),
    );
    await expectLater(
      endpoint.delete(book.session, otherEnvelope.id!),
      throwsA(isA<ForbiddenException>()),
    );

    final reordered = await endpoint.reorder(
      book.session,
      category.id!,
      [own.id!],
    );
    expect(reordered.single.id, own.id);
  });

  test('unauthenticated calls fail before any write', () async {
    final book = await newBook();
    final category = await book.addCategory();
    final envelope = await book.addEnvelopeIn(category);
    final anonymous = server.anonymousSession();

    await expectLater(
      endpoint.list(anonymous, book.entity.id!),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    await expectLater(
      endpoint.get(anonymous, envelope.id!),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    await expectLater(
      endpoint.create(anonymous, category.id!, 'Nope'),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    await expectLater(
      endpoint.update(anonymous, envelope.id!, name: 'Nope'),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    await expectLater(
      endpoint.reorder(anonymous, category.id!, [envelope.id!]),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    await expectLater(
      endpoint.delete(anonymous, envelope.id!),
      throwsA(isA<AuthenticationRequiredException>()),
    );
    expect(await Envelope.db.findById(book.session, envelope.id!), isNotNull);
  });
}
