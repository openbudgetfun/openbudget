import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/transaction_rules/transaction_rule_endpoint.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../catalogue/catalogue_helpers.dart';
import '../payees/payee_helpers.dart';
import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

final _day = DateTime.utc(2026, 3);

/// Captures a success value or the thrown error so two calls can race.
Future<Object> _capture(Future<Object?> future) async {
  try {
    final result = await future;
    if (result == null) {
      throw StateError('Captured a null result');
    }
    return result;
  } on Object catch (error) {
    return error;
  }
}

void main() {
  late PgTestServer server;
  late TransactionRuleEndpoint endpoint;
  late EventLog events;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    events = EventLog()..install();
    endpoint = TransactionRuleEndpoint();
    FxService.configure(
      apiKey: null,
      baseUrl: null,
      backfillScheduler: (_, _) async {},
    );
  });

  tearDown(() {
    events.reset();
    FxService.resetForTests();
  });

  Future<BudgetTestBook> newBook() =>
      BudgetTestBook.create(server.anonymousSession());

  group('Given the transaction rule endpoint', () {
    test(
      'when creating then reads, updates, matches and deletes one rule',
      () async {
        final book = await newBook();
        final payee = await book.addPayee(name: 'Shop');
        final first = await book.addEnvelope(name: 'First');
        final second = await book.addEnvelope(name: 'Second');

        final rule = await endpoint.create(
          book.session,
          book.entity.id!,
          payee.id!,
          first.id!,
        );
        expect(rule.entityId, book.entity.id);
        expect(rule.payeeId, payee.id);
        expect(rule.envelopeId, first.id);
        expect(rule.enabled, isTrue);

        expect(
          (await endpoint.list(book.session, book.entity.id!)).map(
            (row) => row.id,
          ),
          [rule.id],
        );
        expect((await endpoint.get(book.session, rule.id!)).id, rule.id);
        expect(
          await endpoint.findMatchingEnvelope(
            book.session,
            book.entity.id!,
            payee.id!,
          ),
          first.id,
        );

        final updated = await endpoint.update(
          book.session,
          rule.id!,
          envelopeId: second.id,
          enabled: false,
        );
        expect(updated.envelopeId, second.id);
        expect(updated.enabled, isFalse);
        expect(
          await endpoint.findMatchingEnvelope(
            book.session,
            book.entity.id!,
            payee.id!,
          ),
          isNull,
        );

        final enabled = await endpoint.update(
          book.session,
          rule.id!,
          enabled: true,
        );
        expect(enabled.enabled, isTrue);
        expect(
          await endpoint.findMatchingEnvelope(
            book.session,
            book.entity.id!,
            payee.id!,
          ),
          second.id,
        );

        expect((await endpoint.delete(book.session, rule.id!)).id, rule.id);
        expect(await endpoint.list(book.session, book.entity.id!), isEmpty);
        expect(events.events, isNotEmpty);
        expect(
          events.events.every(
            (event) => event.scope == ChangeScope.transactions,
          ),
          isTrue,
        );
      },
    );

    test(
      'when another payee has a rule then a second rule is rejected',
      () async {
        final book = await newBook();
        final payee = await book.addPayee(name: 'Shop');
        final first = await book.addEnvelope(name: 'First');
        final second = await book.addEnvelope(name: 'Second');

        await endpoint.create(
          book.session,
          book.entity.id!,
          payee.id!,
          first.id!,
        );
        final eventCount = events.events.length;

        await expectLater(
          endpoint.create(
            book.session,
            book.entity.id!,
            payee.id!,
            second.id!,
          ),
          throwsA(isA<ValidationException>()),
        );

        expect(await book.ruleCount(payee.id!), 1);
        expect(events.events.length, eventCount);
      },
    );

    test('when two creates race then exactly one rule survives', () async {
      final book = await newBook();
      final payee = await book.addPayee(name: 'Shop');
      final first = await book.addEnvelope(name: 'First');
      final second = await book.addEnvelope(name: 'Second');
      final secondSession = server.authenticatedSession(book.userId);
      addTearDown(secondSession.close);

      final results = await Future.wait([
        _capture(
          endpoint.create(
            book.session,
            book.entity.id!,
            payee.id!,
            first.id!,
          ),
        ),
        _capture(
          endpoint.create(
            secondSession,
            book.entity.id!,
            payee.id!,
            second.id!,
          ),
        ),
      ]);

      expect(results.whereType<TransactionRule>(), hasLength(1));
      expect(results.whereType<ValidationException>(), hasLength(1));
      expect(await book.ruleCount(payee.id!), 1);
    });

    test('when listing with tied creation times then orders by id', () async {
      final book = await newBook();
      final firstPayee = await book.addPayee(name: 'First payee');
      final secondPayee = await book.addPayee(name: 'Second payee');
      final envelope = await book.addEnvelope();
      final createdAt = DateTime.utc(2026);

      final firstRule = await TransactionRule.db.insertRow(
        book.session,
        TransactionRule(
          id: const Uuid().v7obj(),
          entityId: book.entity.id!,
          payeeId: firstPayee.id!,
          envelopeId: envelope.id!,
          createdAt: createdAt,
        ),
      );
      final secondRule = await TransactionRule.db.insertRow(
        book.session,
        TransactionRule(
          id: const Uuid().v7obj(),
          entityId: book.entity.id!,
          payeeId: secondPayee.id!,
          envelopeId: envelope.id!,
          createdAt: createdAt,
        ),
      );
      final expected = [firstRule.id!, secondRule.id!]
        ..sort((a, b) => a.uuid.compareTo(b.uuid));

      expect(
        (await endpoint.list(book.session, book.entity.id!)).map(
          (rule) => rule.id,
        ),
        expected,
      );
    });

    test('when the entity is archived then every write rejects it', () async {
      final book = await newBook();
      final archived = await book.addEntity(
        archivedAt: DateTime.utc(2026),
      );
      final payee = await book.addPayeeIn(archived);
      final envelope = await book.addEnvelope(name: 'Old', entity: archived);
      final rule = await TransactionRule.db.insertRow(
        book.session,
        TransactionRule(
          id: const Uuid().v7obj(),
          entityId: archived.id!,
          payeeId: payee.id!,
          envelopeId: envelope.id!,
        ),
      );

      await expectLater(
        endpoint.create(
          book.session,
          archived.id!,
          payee.id!,
          envelope.id!,
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.update(book.session, rule.id!, enabled: false),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.delete(book.session, rule.id!),
        throwsA(isA<ValidationException>()),
      );
      expect(await book.ruleCount(payee.id!), 1);
    });

    test('when unauthenticated then every method requires a login', () async {
      final book = await newBook();
      final payee = await book.addPayee();
      final envelope = await book.addEnvelope();
      final rule = await book.addRule(payee: payee, envelope: envelope);
      final anonymous = server.anonymousSession();

      await expectAuthenticationRequired(
        () => endpoint.create(
          anonymous,
          book.entity.id!,
          payee.id!,
          envelope.id!,
        ),
      );
      await expectAuthenticationRequired(
        () => endpoint.list(anonymous, book.entity.id!),
      );
      await expectAuthenticationRequired(
        () => endpoint.get(anonymous, rule.id!),
      );
      await expectAuthenticationRequired(
        () => endpoint.update(anonymous, rule.id!, enabled: false),
      );
      await expectAuthenticationRequired(
        () => endpoint.findMatchingEnvelope(
          anonymous,
          book.entity.id!,
          payee.id!,
        ),
      );
      await expectAuthenticationRequired(
        () => endpoint.delete(anonymous, rule.id!),
      );
    });

    test('when another owner calls then every method is forbidden', () async {
      final book = await newBook();
      final other = await newBook();
      final otherPayee = await other.addPayee();
      final otherEnvelope = await other.addEnvelope();
      final otherRule = await other.addRule(
        payee: otherPayee,
        envelope: otherEnvelope,
      );

      await expectLater(
        endpoint.create(
          book.session,
          other.entity.id!,
          otherPayee.id!,
          otherEnvelope.id!,
        ),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.list(book.session, other.entity.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.get(book.session, otherRule.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.update(book.session, otherRule.id!, enabled: false),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.findMatchingEnvelope(
          book.session,
          other.entity.id!,
          otherPayee.id!,
        ),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.delete(book.session, otherRule.id!),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('when a reference belongs to another entity then create and update reject', () async {
      final book = await newBook();
      final otherEntity = await book.addEntity(name: 'Other book');
      final payee = await book.addPayee(name: 'Mine');
      final envelope = await book.addEnvelope(name: 'Mine envelope');
      final otherPayee = await book.addPayeeIn(otherEntity, name: 'Other');
      final otherEnvelope = await book.addEnvelope(
        name: 'Other envelope',
        entity: otherEntity,
      );
      final rule = await book.addRule(payee: payee, envelope: envelope);

      await expectLater(
        endpoint.create(
          book.session,
          book.entity.id!,
          otherPayee.id!,
          envelope.id!,
        ),
        throwsA(isA<NotFoundException>()),
      );
      await expectLater(
        endpoint.create(
          book.session,
          book.entity.id!,
          payee.id!,
          otherEnvelope.id!,
        ),
        throwsA(isA<NotFoundException>()),
      );
      await expectLater(
        endpoint.update(
          book.session,
          rule.id!,
          envelopeId: otherEnvelope.id,
        ),
        throwsA(isA<NotFoundException>()),
      );
      expect(
        (await endpoint.get(book.session, rule.id!)).envelopeId,
        envelope.id,
      );
    });

    test(
      'when finding a match for a foreign payee then returns not found',
      () async {
        final book = await newBook();
        final otherEntity = await book.addEntity(name: 'Other book');
        final otherPayee = await book.addPayeeIn(otherEntity, name: 'Other');

        await expectLater(
          endpoint.findMatchingEnvelope(
            book.session,
            book.entity.id!,
            otherPayee.id!,
          ),
          throwsA(isA<NotFoundException>()),
        );
      },
    );
  });

  group('Given a payee rule and the transaction writer', () {
    test(
      'when an ordinary outflow has no envelope then the rule fills it',
      () async {
        final book = await newBook();
        final account = await book.addAccount();
        final payee = await book.addPayee(name: 'Shop');
        final ruleEnvelope = await book.addEnvelope(name: 'Rule');
        final explicitEnvelope = await book.addEnvelope(name: 'Explicit');
        await endpoint.create(
          book.session,
          book.entity.id!,
          payee.id!,
          ruleEnvelope.id!,
        );

        final automatic = await book.addTransaction(
          account: account,
          date: _day,
          payee: payee,
        );
        expect(automatic.lines.single.envelopeId, ruleEnvelope.id);

        final explicit = await book.addTransaction(
          account: account,
          date: _day,
          payee: payee,
          lines: [
            TransactionLineInput(
              amountMinor: -1000,
              envelopeId: explicitEnvelope.id,
            ),
          ],
        );
        expect(explicit.lines.single.envelopeId, explicitEnvelope.id);

        final inflow = await book.addTransaction(
          account: account,
          date: _day,
          amountMinor: 1000,
          payee: payee,
        );
        expect(inflow.lines.single.envelopeId, isNull);
      },
    );

    test('when the account is off budget or the rule is disabled then it stays uncoded', () async {
      final book = await newBook();
      final offBudget = await book.addAccount(name: 'Savings', onBudget: false);
      final account = await book.addAccount();
      final payee = await book.addPayee(name: 'Shop');
      final disabledPayee = await book.addPayee(name: 'Disabled shop');
      final envelope = await book.addEnvelope();
      await endpoint.create(
        book.session,
        book.entity.id!,
        payee.id!,
        envelope.id!,
      );
      await book.addRule(
        payee: disabledPayee,
        envelope: envelope,
        enabled: false,
      );

      final offBudgetView = await book.addTransaction(
        account: offBudget,
        date: _day,
        payee: payee,
      );
      expect(offBudgetView.lines.single.envelopeId, isNull);

      final disabledView = await book.addTransaction(
        account: account,
        date: _day,
        payee: disabledPayee,
      );
      expect(disabledView.lines.single.envelopeId, isNull);
    });

    test('when importing a payee row then the rule fills the line', () async {
      final book = await newBook();
      final account = await book.addAccount();
      final payee = await book.addPayee(name: 'Shop');
      final envelope = await book.addEnvelope();
      await endpoint.create(
        book.session,
        book.entity.id!,
        payee.id!,
        envelope.id!,
      );

      final result = await TransactionWriter.importRows(
        book.session,
        account.id!,
        [
          ImportRow(
            date: _day,
            amountMinor: -1250,
            description: 'Weekly shop',
            payeeName: 'Shop',
          ),
        ],
      );

      expect(result.insertedCount, 1);
      final rows = await model.Transaction.db.find(
        book.session,
        where: (t) => t.accountId.equals(account.id),
      );
      expect(rows, hasLength(1));
      final lines = await book.linesOf(rows.single.id!);
      expect(lines.single.envelopeId, envelope.id);
    });

    test(
      'when a rule is created later then history keeps its old coding',
      () async {
        final book = await newBook();
        final account = await book.addAccount();
        final payee = await book.addPayee(name: 'Shop');
        final envelope = await book.addEnvelope();
        final historical = await book.addTransaction(
          account: account,
          date: DateTime.utc(2026, 2),
          payee: payee,
        );
        expect(historical.lines.single.envelopeId, isNull);

        await endpoint.create(
          book.session,
          book.entity.id!,
          payee.id!,
          envelope.id!,
        );

        final reloaded = await book.linesOf(historical.transaction.id!);
        expect(reloaded.single.envelopeId, isNull);

        final fresh = await book.addTransaction(
          account: account,
          date: DateTime.utc(2026, 3),
          payee: payee,
        );
        expect(fresh.lines.single.envelopeId, envelope.id);
      },
    );
  });
}
