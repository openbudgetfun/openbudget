// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_endpoint.dart';
import 'package:openbudget_server/src/accounts/account_service.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

void main() {
  late PgTestServer server;
  late BudgetTestBook book;
  late AccountEndpoint endpoint;
  late List<EntityChangedEvent> events;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    events = [];
    Future<void> record(
      Session session,
      UuidValue entityId,
      ChangeScope scope, {
      int? month,
      UuidValue? accountId,
    }) async {
      events.add(
        EntityChangedEvent(
          entityId: entityId,
          scope: scope,
          month: month,
          accountId: accountId,
        ),
      );
    }

    AccountService.debugPublisher = record;
    TransactionWriter.debugPublisher = record;
    FxService.configure(
      apiKey: null,
      baseUrl: null,
      backfillScheduler: (_, _) async {},
    );
    await server.clearRates();
    book = await BudgetTestBook.create(server.anonymousSession());
    endpoint = AccountEndpoint();
    addTearDown(book.expectBalancesConsistent);
  });

  tearDown(() {
    AccountService.resetForTests();
    TransactionWriter.resetForTests();
    FxService.resetForTests();
  });

  DateTime day(int offset) =>
      EntityClock.today(book.entity).add(Duration(days: offset));

  Future<Account> createAccount({
    String name = 'Checking',
    AccountKind kind = AccountKind.checking,
    String? currencyCode,
    AccountBalanceSource? balanceSource,
    bool? onBudget,
    int? openingBalanceMinor,
    DateTime? openingDate,
    UuidValue? institutionId,
    String? note,
    Session? session,
    UuidValue? entityId,
  }) => endpoint.create(
    session ?? book.session,
    entityId ?? book.entity.id!,
    name,
    kind,
    currencyCode ?? book.entity.baseCurrencyCode,
    balanceSource: balanceSource,
    onBudget: onBudget,
    openingBalanceMinor: openingBalanceMinor,
    openingDate: openingDate,
    institutionId: institutionId,
    note: note,
  );

  Future<List<model.Transaction>> transactionsOf(UuidValue accountId) =>
      model.Transaction.db.find(
        book.session,
        where: (t) => t.accountId.equals(accountId),
      );

  Future<Account> reload(UuidValue accountId) async {
    final account = await Account.db.findById(book.session, accountId);
    if (account == null) throw StateError('Account disappeared');
    return account;
  }

  Future<Entity> addEntity({
    String name = 'Second book',
    AccountingMode accountingMode = AccountingMode.envelope,
    UuidValue? ownerId,
  }) => Entity.db.insertRow(
    book.session,
    Entity(
      ownerId: ownerId ?? book.userId,
      name: name,
      kind: EntityKind.individual,
      countryCode: 'GB',
      baseCurrencyCode: 'GBP',
      timeZone: 'Europe/London',
      accountingMode: accountingMode,
      fiscalYearEndMonth: 4,
      fiscalYearEndDay: 5,
    ),
  );

  group('create', () {
    test(
      'stores a signed opening transaction and the cached balance',
      () async {
        expect(endpoint.requireLogin, isTrue);

        final account = await createAccount(
          openingBalanceMinor: 12500,
          onBudget: true,
          note: '  main current account  ',
        );
        final stored = await reload(account.id!);
        final rows = await transactionsOf(account.id!);

        expect(stored.balanceSource, AccountBalanceSource.transactions);
        expect(stored.balanceMinor, 12500);
        expect(stored.onBudget, isTrue);
        expect(stored.note, 'main current account');
        expect(stored.sortOrder, 0);
        expect(rows, hasLength(1));
        expect(rows.single.kind, TransactionKind.openingBalance);
        expect(rows.single.amountMinor, 12500);
        expect(rows.single.baseAmountMinor, 12500);
        expect(rows.single.fxRate, '1');
        expect(rows.single.date, day(0));
        expect(await book.lineCount(rows.single.id!), 1);
      },
    );

    test('keeps a liability opening balance signed', () async {
      final account = await createAccount(
        name: 'Car loan',
        kind: AccountKind.loan,
        openingBalanceMinor: -250000,
      );
      final stored = await reload(account.id!);
      final rows = await transactionsOf(account.id!);

      expect(stored.balanceMinor, -250000);
      expect(stored.onBudget, isFalse);
      expect(rows.single.amountMinor, -250000);
    });

    test('creates a valuations account with its first dated value', () async {
      final opened = day(-10);
      final account = await createAccount(
        name: 'House',
        kind: AccountKind.property,
        openingBalanceMinor: 30000000,
        openingDate: opened,
      );
      final stored = await reload(account.id!);
      final values = await endpoint.listValuations(book.session, account.id!);

      expect(stored.balanceSource, AccountBalanceSource.valuations);
      expect(stored.balanceMinor, 30000000);
      expect(values, hasLength(1));
      expect(values.single.valuationDate, opened);
      expect(values.single.valueMinor, 30000000);
      expect(values.single.source, ValuationSource.manual);
      expect(await transactionsOf(account.id!), isEmpty);
    });

    test('missing FX rolls the account and its fact back', () async {
      await expectLater(
        createAccount(
          name: 'Euro account',
          currencyCode: 'EUR',
          openingBalanceMinor: 1000,
          openingDate: day(-2),
        ),
        throwsA(isA<FxRateUnavailableException>()),
      );

      expect(
        await Account.db.find(
          book.session,
          where: (t) => t.entityId.equals(book.entity.id),
        ),
        isEmpty,
      );
      expect(
        await model.Transaction.db.count(
          book.session,
          where: (t) => t.entityId.equals(book.entity.id),
        ),
        0,
      );
      expect(events, isEmpty);
    });

    test('stores the real market rate for a foreign opening', () async {
      final opened = day(-2);
      await book.seedMarketRate(
        fromCurrencyCode: 'EUR',
        toCurrencyCode: 'GBP',
        rateDate: opened,
        fromPerUsd: '1.1',
        toPerUsd: '0.8',
      );

      final account = await createAccount(
        name: 'Euro account',
        currencyCode: 'EUR',
        openingBalanceMinor: 1000,
        openingDate: opened,
      );
      final rows = await transactionsOf(account.id!);

      expect((await reload(account.id!)).balanceMinor, 1000);
      expect(rows.single.fxRateSource, FxRateSource.market);
      expect(rows.single.fxRate, isNot('1'));
      expect(rows.single.baseAmountMinor, 727);
    });

    test('a zero opening writes no transaction but still validates', () async {
      final account = await createAccount(openingBalanceMinor: 0);

      expect(await transactionsOf(account.id!), isEmpty);
      expect((await reload(account.id!)).balanceMinor, 0);

      await expectLater(
        createAccount(
          name: 'Bad date',
          openingBalanceMinor: 0,
          openingDate: DateTime.utc(2026, 1, 1, 12),
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        createAccount(
          name: 'Too early',
          openingBalanceMinor: 0,
          openingDate: day(2),
        ),
        throwsA(isA<ValidationException>()),
      );

      final property = await createAccount(
        name: 'Zero house',
        kind: AccountKind.property,
        openingBalanceMinor: 0,
      );
      expect(
        await endpoint.listValuations(book.session, property.id!),
        hasLength(1),
      );
      expect((await reload(property.id!)).balanceMinor, 0);
    });

    test(
      'rejects invalid names, currencies, amounts and institutions',
      () async {
        await expectLater(
          createAccount(name: '   '),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          createAccount(currencyCode: 'ZZZ'),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          createAccount(openingBalanceMinor: maxSafeMinor + 1),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          createAccount(institutionId: const Uuid().v7obj()),
          throwsA(isA<NotFoundException>()),
        );
      },
    );

    test('normalises a supported lowercase currency code', () async {
      final account = await createAccount(currencyCode: 'gbp');

      expect((await reload(account.id!)).currencyCode, 'GBP');
    });

    test(
      'rejects disallowed sources and on-budget valuation accounts',
      () async {
        await expectLater(
          createAccount(
            name: 'Crypto',
            kind: AccountKind.crypto,
            balanceSource: AccountBalanceSource.transactions,
          ),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          createAccount(
            name: 'Cash',
            kind: AccountKind.cash,
            balanceSource: AccountBalanceSource.valuations,
          ),
          throwsA(isA<ValidationException>()),
        );
        await expectLater(
          createAccount(
            name: 'House plan',
            kind: AccountKind.property,
            onBudget: true,
          ),
          throwsA(isA<ValidationException>()),
        );
        expect(
          await Account.db.find(
            book.session,
            where: (t) => t.entityId.equals(book.entity.id),
          ),
          isEmpty,
        );
      },
    );

    test('an archived entity rejects every account write', () async {
      final account = await createAccount(openingBalanceMinor: 1000);
      await Entity.db.updateRow(
        book.session,
        book.entity.copyWith(archivedAt: DateTime.now().toUtc()),
      );

      await expectLater(
        createAccount(name: 'New'),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.update(book.session, account.id!, name: 'Renamed'),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.close(book.session, account.id!),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.delete(book.session, account.id!),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('read and ownership', () {
    test('lists one entity and every owned entity only', () async {
      final checking = await createAccount(name: 'Checking');
      final savings = await createAccount(name: 'Savings');
      final other = await addEntity();
      final otherAccount = await createAccount(
        name: 'Brokerage',
        kind: AccountKind.investment,
        entityId: other.id,
      );

      final listed = await endpoint.list(book.session, book.entity.id!);
      final all = await endpoint.listAll(book.session);

      expect(listed.map((a) => a.id), [checking.id, savings.id]);
      expect(
        all.map((a) => a.id),
        containsAll([
          checking.id,
          savings.id,
          otherAccount.id,
        ]),
      );
    });

    test('rejects another owner on every read and write', () async {
      final account = await createAccount(openingBalanceMinor: 1000);
      final strangerId = await server.insertAuthUser();
      final stranger = server.authenticatedSession(strangerId);

      await expectLater(
        endpoint.get(stranger, account.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.list(stranger, book.entity.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.update(stranger, account.id!, name: 'Mine'),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.close(stranger, account.id!),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.delete(stranger, account.id!),
        throwsA(isA<ForbiddenException>()),
      );
      expect(await endpoint.listAll(stranger), isEmpty);
    });

    test('missing accounts are not found', () async {
      await expectLater(
        endpoint.get(book.session, const Uuid().v7obj()),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('getBalances reports cached, cleared and uncleared sums', () async {
      final account = await createAccount(openingBalanceMinor: 1000);
      await TransactionWriter.create(
        book.session,
        TransactionInput(
          accountId: account.id!,
          date: day(0),
          amountMinor: 500,
          status: TransactionStatus.cleared,
          lines: const [],
        ),
      );

      final balances = await endpoint.getBalances(book.session, account.id!);

      expect(balances.accountId, account.id);
      expect(balances.currencyCode, 'GBP');
      expect(balances.balanceMinor, 1500);
      expect(balances.clearedMinor, 500);
      expect(balances.unclearedMinor, 1000);

      final property = await createAccount(
        name: 'House',
        kind: AccountKind.property,
        openingBalanceMinor: 9000,
      );
      final valued = await endpoint.getBalances(book.session, property.id!);
      expect(valued.balanceMinor, 9000);
      expect(valued.clearedMinor, 0);
      expect(valued.unclearedMinor, 0);
    });
  });

  group('update', () {
    test('updates metadata without moving the cached balance', () async {
      final institution = await Institution.db.insertRow(
        book.session,
        Institution(
          slug: 'bank-${const Uuid().v4()}',
          name: 'Test Bank',
        ),
      );
      final account = await createAccount(
        openingBalanceMinor: 1000,
        note: 'before',
      );

      final renamed = await endpoint.update(
        book.session,
        account.id!,
        name: '  Current account  ',
        institutionId: institution.id,
        note: '  after  ',
        sortOrder: 7,
      );

      expect(renamed.name, 'Current account');
      expect(renamed.institutionId, institution.id);
      expect(renamed.note, 'after');
      expect(renamed.sortOrder, 7);
      expect(renamed.balanceMinor, 1000);

      await expectLater(
        endpoint.update(
          book.session,
          account.id!,
          institutionId: const Uuid().v7obj(),
        ),
        throwsA(isA<NotFoundException>()),
      );
      expect((await reload(account.id!)).institutionId, institution.id);

      final cleared = await endpoint.update(
        book.session,
        account.id!,
        note: '',
        clearInstitution: true,
      );
      expect(cleared.note, isNull);
      expect(cleared.institutionId, isNull);
      expect(cleared.balanceMinor, 1000);
    });

    test('changes kind only within one liability and source group', () async {
      final checking = await createAccount(onBudget: true);
      final savings = await endpoint.update(
        book.session,
        checking.id!,
        kind: AccountKind.savings,
      );
      expect(savings.kind, AccountKind.savings);
      expect(savings.onBudget, isTrue);

      await expectLater(
        endpoint.update(
          book.session,
          checking.id!,
          kind: AccountKind.investment,
        ),
        throwsA(isA<ValidationException>()),
      );

      final card = await createAccount(
        name: 'Card',
        kind: AccountKind.creditCard,
      );
      await expectLater(
        endpoint.update(book.session, card.id!, kind: AccountKind.cash),
        throwsA(isA<ValidationException>()),
      );

      final investment = await createAccount(
        name: 'Brokerage',
        kind: AccountKind.investment,
      );
      final asset = await endpoint.update(
        book.session,
        investment.id!,
        kind: AccountKind.otherAsset,
      );
      expect(asset.kind, AccountKind.otherAsset);
    });

    test('onBudget changes only before ordinary transactions', () async {
      final account = await createAccount(
        openingBalanceMinor: 1000,
        onBudget: true,
      );

      final off = await endpoint.update(
        book.session,
        account.id!,
        onBudget: false,
      );
      expect(off.onBudget, isFalse);

      final on = await endpoint.update(
        book.session,
        account.id!,
        onBudget: true,
      );
      expect(on.onBudget, isTrue);

      await TransactionWriter.create(
        book.session,
        TransactionInput(
          accountId: account.id!,
          date: day(0),
          amountMinor: -100,
          lines: const [],
        ),
      );

      await expectLater(
        endpoint.update(book.session, account.id!, onBudget: false),
        throwsA(isA<ValidationException>()),
      );
      expect((await reload(account.id!)).onBudget, isTrue);

      final loan = await createAccount(
        name: 'Mortgage',
        kind: AccountKind.mortgage,
      );
      await expectLater(
        endpoint.update(book.session, loan.id!, onBudget: true),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('reorder', () {
    test('applies an exact order and returns it', () async {
      final first = await createAccount(name: 'First');
      final second = await createAccount(name: 'Second');
      final third = await createAccount(name: 'Third');

      final ordered = await endpoint.reorder(book.session, book.entity.id!, [
        third.id!,
        first.id!,
        second.id!,
      ]);

      expect(ordered.map((a) => a.name), ['Third', 'First', 'Second']);
      expect(ordered.map((a) => a.sortOrder), [0, 1, 2]);
      expect(
        (await endpoint.list(book.session, book.entity.id!)).map((a) => a.name),
        ['Third', 'First', 'Second'],
      );
    });

    test('rejects duplicates, foreign and missing ids atomically', () async {
      final first = await createAccount(name: 'First');
      final second = await createAccount(name: 'Second');
      final other = await addEntity();
      final foreign = await createAccount(name: 'Foreign', entityId: other.id);
      final before = {
        first.id!: (await reload(first.id!)).sortOrder,
        second.id!: (await reload(second.id!)).sortOrder,
      };
      events.clear();

      await expectLater(
        endpoint.reorder(book.session, book.entity.id!, [
          first.id!,
          first.id!,
          second.id!,
        ]),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.reorder(book.session, book.entity.id!, [
          first.id!,
          foreign.id!,
        ]),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.reorder(book.session, book.entity.id!, [first.id!]),
        throwsA(isA<ValidationException>()),
      );

      for (final entry in before.entries) {
        expect((await reload(entry.key)).sortOrder, entry.value);
      }
      expect(events, isEmpty);
    });
  });

  group('close and reopen', () {
    test('closes only a zero balance and reopens', () async {
      final zero = await createAccount(name: 'Empty');
      final closed = await endpoint.close(book.session, zero.id!);
      expect(closed.closedAt, isNotNull);
      expect(
        (await endpoint.list(book.session, book.entity.id!)).map((a) => a.id),
        contains(zero.id),
      );

      final reopened = await endpoint.reopen(book.session, zero.id!);
      expect(reopened.closedAt, isNull);

      final funded = await createAccount(
        name: 'Funded',
        openingBalanceMinor: 500,
      );
      await expectLater(
        endpoint.close(book.session, funded.id!),
        throwsA(isA<ValidationException>()),
      );
      expect((await reload(funded.id!)).closedAt, isNull);
    });

    test('a closed valuation account rejects valuation writes', () async {
      final property = await createAccount(
        name: 'House',
        kind: AccountKind.property,
        openingBalanceMinor: 0,
      );
      await endpoint.close(book.session, property.id!);

      await expectLater(
        endpoint.setValuation(
          book.session,
          property.id!,
          day(-1),
          1000,
        ),
        throwsA(isA<ValidationException>()),
      );
      final valuation = (await endpoint.listValuations(
        book.session,
        property.id!,
      )).single;
      await expectLater(
        endpoint.deleteValuation(book.session, valuation.id!),
        throwsA(isA<ValidationException>()),
      );

      await endpoint.reopen(book.session, property.id!);
      final saved = await endpoint.setValuation(
        book.session,
        property.id!,
        day(0),
        1000,
      );
      expect(saved.valueMinor, 1000);
      expect((await reload(property.id!)).balanceMinor, 1000);
    });
  });

  group('valuations', () {
    test('keeps the latest date as the cache, not the latest insert', () async {
      final property = await createAccount(
        name: 'House',
        kind: AccountKind.property,
      );

      await endpoint.setValuation(book.session, property.id!, day(-5), 100);
      await endpoint.setValuation(book.session, property.id!, day(-1), 300);
      await endpoint.setValuation(book.session, property.id!, day(-3), 200);

      expect((await reload(property.id!)).balanceMinor, 300);

      final values = await endpoint.listValuations(book.session, property.id!);
      expect(values.map((v) => v.valuationDate), [day(-1), day(-3), day(-5)]);

      await endpoint.setValuation(book.session, property.id!, day(-1), 350);
      expect((await reload(property.id!)).balanceMinor, 350);

      await endpoint.deleteValuation(book.session, values.first.id!);
      expect((await reload(property.id!)).balanceMinor, 200);

      for (final value in await endpoint.listValuations(
        book.session,
        property.id!,
      )) {
        await endpoint.deleteValuation(book.session, value.id!);
      }
      expect((await reload(property.id!)).balanceMinor, 0);
    });

    test('rejects invalid dates, amounts, sources and owners', () async {
      final checking = await createAccount();
      await expectLater(
        endpoint.setValuation(book.session, checking.id!, day(0), 100),
        throwsA(isA<ValidationException>()),
      );

      final property = await createAccount(
        name: 'House',
        kind: AccountKind.property,
      );
      await expectLater(
        endpoint.setValuation(book.session, property.id!, day(1), 100),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.setValuation(
          book.session,
          property.id!,
          DateTime.utc(2026, 1, 1, 8),
          100,
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.setValuation(
          book.session,
          property.id!,
          day(-1),
          maxSafeMinor + 1,
        ),
        throwsA(isA<ValidationException>()),
      );

      final saved = await endpoint.setValuation(
        book.session,
        property.id!,
        day(-1),
        100,
        note: '  survey  ',
      );
      expect(saved.note, 'survey');

      final strangerId = await server.insertAuthUser();
      final stranger = server.authenticatedSession(strangerId);
      await expectLater(
        endpoint.setValuation(stranger, property.id!, day(-1), 100),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        endpoint.deleteValuation(stranger, saved.id!),
        throwsA(isA<ForbiddenException>()),
      );
    });
  });

  group('delete', () {
    test('removes the account, its transactions and its valuations', () async {
      final checking = await createAccount(openingBalanceMinor: 1000);
      final property = await createAccount(
        name: 'House',
        kind: AccountKind.property,
        openingBalanceMinor: 5000,
      );
      final checkingId = checking.id!;
      final propertyId = property.id!;

      await endpoint.delete(book.session, checkingId);
      await endpoint.delete(book.session, propertyId);

      expect(await Account.db.findById(book.session, checkingId), isNull);
      expect(await Account.db.findById(book.session, propertyId), isNull);
      expect(await transactionsOf(checkingId), isEmpty);
      expect(
        await AccountValuation.db.find(
          book.session,
          where: (t) => t.accountId.equals(propertyId),
        ),
        isEmpty,
      );
    });

    test('reverses a surviving transfer peer through the writer', () async {
      final from = await createAccount(name: 'From');
      final to = await createAccount(
        name: 'To',
        openingBalanceMinor: 1000,
      );
      final fromLeg = await TransactionWriter.create(
        book.session,
        TransactionInput(
          accountId: from.id!,
          date: day(0),
          amountMinor: -400,
          lines: const [],
        ),
      );
      final toLeg = await TransactionWriter.create(
        book.session,
        TransactionInput(
          accountId: to.id!,
          date: day(0),
          amountMinor: 400,
          lines: const [],
        ),
      );
      final transfer = await Transfer.db.insertRow(
        book.session,
        Transfer(
          fromTransactionId: fromLeg.transaction.id!,
          toTransactionId: toLeg.transaction.id!,
        ),
      );
      expect((await reload(to.id!)).balanceMinor, 1400);
      events.clear();

      await endpoint.delete(book.session, from.id!);

      expect(await Account.db.findById(book.session, from.id!), isNull);
      expect((await reload(to.id!)).balanceMinor, 1000);
      expect(await book.transaction(fromLeg.transaction.id!), isNull);
      expect(await book.transaction(toLeg.transaction.id!), isNull);
      expect(
        await Transfer.db.findById(book.session, transfer.id!),
        isNull,
      );
      expect(events.map((e) => e.scope), contains(ChangeScope.transactions));
      expect(events.map((e) => e.scope), contains(ChangeScope.accounts));
    });

    test('journal lines on its ledger account protect it', () async {
      final ledgerEntity = await addEntity(
        accountingMode: AccountingMode.ledger,
      );
      final created = await createAccount(
        name: 'Bank',
        entityId: ledgerEntity.id,
      );
      final account = (await Account.db.findById(
        book.session,
        created.id!,
      ))!;
      expect(account.ledgerAccountId, isNotNull);
      final ledger = (await LedgerAccount.db.findById(
        book.session,
        account.ledgerAccountId!,
      ))!;
      final journal = await Journal.db.insertRow(
        book.session,
        Journal(entityId: ledgerEntity.id!, date: day(0)),
      );
      await JournalLine.db.insertRow(
        book.session,
        JournalLine(
          journalId: journal.id!,
          lineNumber: 0,
          ledgerAccountId: ledger.id!,
          currencyCode: 'GBP',
          debitMinor: 100,
          baseDebitMinor: 100,
          fxRateDate: day(0),
        ),
      );
      events.clear();

      await expectLater(
        endpoint.delete(book.session, account.id!),
        throwsA(isA<ValidationException>()),
      );
      expect(await Account.db.findById(book.session, account.id!), isNotNull);
      expect(events, isEmpty);

      await Journal.db.deleteRow(book.session, journal);
      await endpoint.delete(book.session, account.id!);
      expect(await Account.db.findById(book.session, account.id!), isNull);
    });
  });

  group('notifications', () {
    test('publishes only after the commit and never on rollback', () async {
      final observed = <(ChangeScope, bool)>[];
      Future<void> record(
        Session session,
        UuidValue entityId,
        ChangeScope scope, {
        int? month,
        UuidValue? accountId,
      }) async {
        final visible =
            accountId == null ||
            await Account.db.findById(book.session, accountId) != null;
        observed.add((scope, visible));
      }

      AccountService.debugPublisher = record;
      TransactionWriter.debugPublisher = record;

      final account = await createAccount(openingBalanceMinor: 1000);
      expect(account.balanceMinor, 1000);

      expect(observed, hasLength(2));
      expect(observed.map((entry) => entry.$1), [
        ChangeScope.transactions,
        ChangeScope.accounts,
      ]);
      expect(observed.every((entry) => entry.$2), isTrue);

      observed.clear();
      await expectLater(
        createAccount(
          name: 'Euro',
          currencyCode: 'EUR',
          openingBalanceMinor: 1000,
          openingDate: day(-2),
        ),
        throwsA(isA<FxRateUnavailableException>()),
      );
      expect(observed, isEmpty);

      final loan = await createAccount(
        name: 'Loan',
        kind: AccountKind.mortgage,
      );
      observed.clear();
      await expectLater(
        endpoint.update(book.session, loan.id!, onBudget: true),
        throwsA(isA<ValidationException>()),
      );
      expect(observed, isEmpty);

      final bank = await createAccount(name: 'Other');
      observed.clear();
      await endpoint.close(book.session, bank.id!);
      expect(observed, hasLength(1));
      expect(observed.single.$1, ChangeScope.accounts);
      expect(observed.single.$2, isTrue);

      final property = await createAccount(
        name: 'House',
        kind: AccountKind.property,
      );
      observed.clear();
      await endpoint.setValuation(book.session, property.id!, day(-1), 5000);
      expect(observed, hasLength(1));
      expect(observed.single.$1, ChangeScope.accounts);
      expect(observed.single.$2, isTrue);

      observed.clear();
      await expectLater(
        endpoint.setValuation(book.session, property.id!, day(1), 5000),
        throwsA(isA<ValidationException>()),
      );
      expect(observed, isEmpty);
    });
  });
}
