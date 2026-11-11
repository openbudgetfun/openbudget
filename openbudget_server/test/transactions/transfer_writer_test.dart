// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

import 'package:openbudget_core/openbudget_core.dart';
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

final _date = DateTime.utc(2026, 3, 10);

void main() {
  late PgTestServer server;
  late BudgetTestBook book;
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
    TransactionWriter.debugPublisher =
        (session, entityId, scope, {month, accountId}) async {
          events.add(
            EntityChangedEvent(
              entityId: entityId,
              scope: scope,
              month: month,
              accountId: accountId,
            ),
          );
        };
    FxService.configure(
      apiKey: null,
      baseUrl: null,
      backfillScheduler: (_, _) async {},
    );
    await server.clearRates();
    book = await BudgetTestBook.create(server.anonymousSession());
    await book.session.caches.clear();
    addTearDown(book.expectBalancesConsistent);
  });

  tearDown(() {
    TransactionWriter.resetForTests();
    FxService.resetForTests();
  });

  TransferInput movement(
    Account from,
    Account to, {
    int fromAmountMinor = 1000,
    int? toAmountMinor,
    bool useMarketRate = false,
    DateTime? date,
    UuidValue? envelopeId,
    String? memo,
    TransactionStatus status = TransactionStatus.uncleared,
  }) => TransferInput(
    fromAccountId: from.id!,
    toAccountId: to.id!,
    date: date ?? _date,
    fromAmountMinor: fromAmountMinor,
    toAmountMinor: toAmountMinor,
    useMarketRate: useMarketRate,
    envelopeId: envelopeId,
    memo: memo,
    status: status,
  );

  Future<List<model.Transaction>> legsOn(Account account) =>
      model.Transaction.db.find(
        book.session,
        where: (t) => t.accountId.equals(account.id),
        orderBy: (t) => t.createdAt,
      );

  Future<Transfer?> linkFor(UuidValue legId) => Transfer.db.findFirstRow(
    book.session,
    where: (t) =>
        t.fromTransactionId.equals(legId) | t.toTransactionId.equals(legId),
  );

  /// The links whose legs are on [accounts], ignoring rows from other tests.
  Future<List<Transfer>> transfersFor(Iterable<Account> accounts) async {
    final accountIds = accounts.map((account) => account.id!).toSet();
    final legs = await model.Transaction.db.find(
      book.session,
      where: (t) => t.accountId.inSet(accountIds),
    );
    final legIds = {for (final leg in legs) leg.id!};
    final links = await Transfer.db.find(book.session);
    return [
      for (final link in links)
        if (legIds.contains(link.fromTransactionId) ||
            legIds.contains(link.toTransactionId))
          link,
    ];
  }

  void expectZeroSum(List<TransactionView> views) {
    expect(views, hasLength(2));
    expect(
      views[0].transaction.baseAmountMinor +
          views[1].transaction.baseAmountMinor,
      0,
    );
  }

  group('createTransfer', () {
    test('writes both legs, one link and exact balances', () async {
      final from = await book.addAccount(name: 'From');
      final to = await book.addAccount(name: 'To');

      final views = await TransactionWriter.createTransfer(
        book.session,
        movement(from, to, fromAmountMinor: 1250),
      );

      expect(views, hasLength(2));
      expect(views[0].transaction.amountMinor, -1250);
      expect(views[1].transaction.amountMinor, 1250);
      expect(views[0].transaction.baseAmountMinor, -1250);
      expect(views[1].transaction.baseAmountMinor, 1250);
      expect(views[0].transaction.fxRateSource, FxRateSource.identity);
      expect(views[1].transaction.fxRateSource, FxRateSource.identity);
      expect(views[0].lines.single.envelopeId, isNull);
      expect(views[1].lines.single.envelopeId, isNull);
      expect(views[0].transferPeer?.transactionId, views[1].transaction.id);
      expect(views[1].transferPeer?.transactionId, views[0].transaction.id);

      final link = await linkFor(views[0].transaction.id!);
      expect(link, isNotNull);
      expect(link!.fromTransactionId, views[0].transaction.id);
      expect(link.toTransactionId, views[1].transaction.id);

      expect(await book.cachedBalanceMinor(from), -1250);
      expect(await book.cachedBalanceMinor(to), 1250);
      expect(await book.recomputedBalanceMinor(from), -1250);
      expect(await book.recomputedBalanceMinor(to), 1250);
      expect(events, hasLength(2));
      expect(events.map((event) => event.accountId), {from.id, to.id});
      expect(
        events.every((event) => event.scope == ChangeScope.transactions),
        isTrue,
      );
    });

    test('a same-entity transfer nets to exactly zero in base', () async {
      final from = await book.addAccount(name: 'From', currencyCode: 'USD');
      final to = await book.addAccount(name: 'To', currencyCode: 'EUR');
      await book.seedMarketRate(
        fromCurrencyCode: 'USD',
        toCurrencyCode: 'GBP',
        rateDate: _date,
        fromPerUsd: '1',
        toPerUsd: '0.8',
      );

      final views = await TransactionWriter.createTransfer(
        book.session,
        movement(
          from,
          to,
          fromAmountMinor: 800,
          toAmountMinor: 700,
        ),
      );

      expectZeroSum(views);
      expect(views[0].transaction.fxRateSource, FxRateSource.market);
      expect(views[0].transaction.baseAmountMinor, -640);
      expect(views[1].transaction.fxRateSource, FxRateSource.implied);
      expect(views[1].transaction.baseAmountMinor, 640);
      expect(views[1].transaction.fxRateDate, _date);
      expect(
        views[0].lines.single.baseAmountMinor +
            views[1].lines.single.baseAmountMinor,
        0,
      );
    });

    test('a base-currency leg is identity and the other is implied', () async {
      final base = await book.addAccount(name: 'Base');
      final usd = await book.addAccount(name: 'USD', currencyCode: 'USD');

      final outward = await TransactionWriter.createTransfer(
        book.session,
        movement(base, usd, fromAmountMinor: 1000, toAmountMinor: 800),
      );
      expect(outward[0].transaction.fxRateSource, FxRateSource.identity);
      expect(outward[0].transaction.fxRate, '1');
      expect(outward[0].transaction.baseAmountMinor, -1000);
      expect(outward[1].transaction.fxRateSource, FxRateSource.implied);
      expect(outward[1].transaction.fxRate, '1.25');
      expect(outward[1].transaction.baseAmountMinor, 1000);
      expectZeroSum(outward);

      final inward = await TransactionWriter.createTransfer(
        book.session,
        movement(usd, base, fromAmountMinor: 800, toAmountMinor: 1000),
      );
      expect(inward[0].transaction.fxRateSource, FxRateSource.implied);
      expect(inward[0].transaction.fxRate, '1.25');
      expect(inward[0].transaction.baseAmountMinor, -1000);
      expect(inward[1].transaction.fxRateSource, FxRateSource.identity);
      expect(inward[1].transaction.fxRate, '1');
      expect(inward[1].transaction.baseAmountMinor, 1000);
      expectZeroSum(inward);
    });

    test('market conversion fills a missing destination amount', () async {
      final from = await book.addAccount(name: 'USD', currencyCode: 'USD');
      final to = await book.addAccount(name: 'EUR', currencyCode: 'EUR');
      await book.seedMarketRate(
        fromCurrencyCode: 'USD',
        toCurrencyCode: 'EUR',
        rateDate: _date,
        fromPerUsd: '1',
        toPerUsd: '0.9',
      );
      await book.seedRate(
        currencyCode: 'GBP',
        rateDate: _date,
        rate: '0.8',
      );

      final views = await TransactionWriter.createTransfer(
        book.session,
        movement(from, to, fromAmountMinor: 1000, useMarketRate: true),
      );

      expect(views[1].transaction.amountMinor, 900);
      expectZeroSum(views);
    });

    test('JPY and KWD keep their minor-unit exponents exact', () async {
      final yen = await book.addAccount(name: 'Yen', currencyCode: 'JPY');
      final dinar = await book.addAccount(name: 'Dinar', currencyCode: 'KWD');
      await book.seedMarketRate(
        fromCurrencyCode: 'JPY',
        toCurrencyCode: 'GBP',
        rateDate: _date,
        fromPerUsd: '150',
        toPerUsd: '0.8',
      );

      final views = await TransactionWriter.createTransfer(
        book.session,
        movement(
          yen,
          dinar,
          fromAmountMinor: 10000,
          toAmountMinor: 1000,
        ),
      );

      expect(views[0].transaction.baseAmountMinor, -5333);
      expect(views[1].transaction.baseAmountMinor, 5333);
      expect(views[1].transaction.fxRate, '53.33');
      expectZeroSum(views);
    });

    test('different entities convert each leg into its own base', () async {
      final first = await book.addAccount(name: 'Sterling');
      final secondEntity = await book.addEntity(
        name: 'Dollar book',
        baseCurrencyCode: 'USD',
        countryCode: 'US',
        timeZone: 'America/New_York',
      );
      final second = await book.addAccount(
        name: 'Euro',
        currencyCode: 'EUR',
        entity: secondEntity,
      );
      await book.seedMarketRate(
        fromCurrencyCode: 'EUR',
        toCurrencyCode: 'USD',
        rateDate: _date,
        fromPerUsd: '0.5',
        toPerUsd: '1',
      );

      final views = await TransactionWriter.createTransfer(
        book.session,
        movement(
          first,
          second,
          fromAmountMinor: 700,
          toAmountMinor: 500,
        ),
      );

      expect(views[0].transaction.entityId, book.entity.id);
      expect(views[0].transaction.baseAmountMinor, -700);
      expect(views[0].transaction.fxRateSource, FxRateSource.identity);
      expect(views[1].transaction.entityId, secondEntity.id);
      expect(views[1].transaction.baseAmountMinor, 1000);
      expect(views[1].transaction.fxRateSource, FxRateSource.market);
      expect(
        views[0].transaction.baseAmountMinor +
            views[1].transaction.baseAmountMinor,
        300,
      );
      expect(await book.cachedBalanceMinor(first), -700);
      expect(await book.cachedBalanceMinor(second), 500);
    });

    test('missing market data rolls the whole write back', () async {
      final from = await book.addAccount(name: 'USD', currencyCode: 'USD');
      final to = await book.addAccount(name: 'EUR', currencyCode: 'EUR');

      await expectLater(
        TransactionWriter.createTransfer(
          book.session,
          movement(from, to, fromAmountMinor: 1000, useMarketRate: true),
        ),
        throwsA(isA<FxRateUnavailableException>()),
      );

      expect(await legsOn(from), isEmpty);
      expect(await legsOn(to), isEmpty);
      expect(await transfersFor([from, to]), isEmpty);
      expect(await book.cachedBalanceMinor(from), 0);
      expect(events, isEmpty);
    });

    test('positive safe source and destination amounts are required', () async {
      final from = await book.addAccount(name: 'From');
      final to = await book.addAccount(name: 'To', currencyCode: 'USD');

      for (final amount in [0, -1, -maxSafeMinor, maxSafeMinor + 1]) {
        await expectLater(
          TransactionWriter.createTransfer(
            book.session,
            movement(from, to, fromAmountMinor: amount, toAmountMinor: 100),
          ),
          throwsA(isA<ValidationException>()),
          reason: 'fromAmountMinor $amount must be rejected',
        );
      }
      for (final amount in [0, -1, maxSafeMinor + 1]) {
        await expectLater(
          TransactionWriter.createTransfer(
            book.session,
            movement(from, to, fromAmountMinor: 100, toAmountMinor: amount),
          ),
          throwsA(isA<ValidationException>()),
          reason: 'toAmountMinor $amount must be rejected',
        );
      }

      expect(await transfersFor([from, to]), isEmpty);
      expect(await book.cachedBalanceMinor(from), 0);
    });

    test(
      'the same account, foreign owners and valuations are rejected',
      () async {
        final account = await book.addAccount();
        await expectLater(
          TransactionWriter.createTransfer(
            book.session,
            movement(account, account),
          ),
          throwsA(isA<ValidationException>()),
        );

        final otherBook = await BudgetTestBook.create(
          server.anonymousSession(),
        );
        final foreign = await otherBook.addAccount();
        await expectLater(
          TransactionWriter.createTransfer(
            book.session,
            movement(account, foreign),
          ),
          throwsA(isA<ForbiddenException>()),
        );

        final valuation = await book.addAccount(
          name: 'House',
          balanceSource: AccountBalanceSource.valuations,
        );
        await expectLater(
          TransactionWriter.createTransfer(
            book.session,
            movement(valuation, account),
          ),
          throwsA(isA<StateError>()),
        );
      },
    );

    test('closed accounts and archived entities reject transfers', () async {
      final open = await book.addAccount(name: 'Open');
      final closed = await book.addAccount(
        name: 'Closed',
        closedAt: DateTime.utc(2026, 1, 1),
      );
      await expectLater(
        TransactionWriter.createTransfer(
          book.session,
          movement(open, closed),
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        TransactionWriter.createTransfer(
          book.session,
          movement(closed, open),
        ),
        throwsA(isA<ValidationException>()),
      );

      final archivedEntity = await book.addEntity(
        name: 'Archived book',
        archivedAt: DateTime.utc(2026, 1, 1),
      );
      final archived = await book.addAccount(
        name: 'Archived account',
        entity: archivedEntity,
      );
      await expectLater(
        TransactionWriter.createTransfer(
          book.session,
          movement(open, archived),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('an envelope is allowed only when money leaves the plan', () async {
      final from = await book.addAccount(name: 'From');
      final offBudget = await book.addAccount(
        name: 'Off budget',
        onBudget: false,
      );
      final onBudget = await book.addAccount(name: 'On budget');
      final envelope = await book.addEnvelope();

      final leaving = await TransactionWriter.createTransfer(
        book.session,
        movement(
          from,
          offBudget,
          fromAmountMinor: 400,
          envelopeId: envelope.id,
        ),
      );
      expect(leaving[0].lines.single.envelopeId, envelope.id);
      expect(leaving[1].lines.single.envelopeId, isNull);

      await expectLater(
        TransactionWriter.createTransfer(
          book.session,
          movement(
            from,
            onBudget,
            fromAmountMinor: 400,
            envelopeId: envelope.id,
          ),
        ),
        throwsA(isA<ValidationException>()),
      );

      final offBudgetFrom = await book.addAccount(
        name: 'Off budget from',
        onBudget: false,
      );
      await expectLater(
        TransactionWriter.createTransfer(
          book.session,
          movement(
            offBudgetFrom,
            offBudget,
            fromAmountMinor: 400,
            envelopeId: envelope.id,
          ),
        ),
        throwsA(isA<ValidationException>()),
      );

      final otherEntity = await book.addEntity(
        name: 'Other entity',
        baseCurrencyCode: 'USD',
        countryCode: 'US',
      );
      final otherAccount = await book.addAccount(
        name: 'Other account',
        currencyCode: 'USD',
        entity: otherEntity,
      );
      final crossEntity = await TransactionWriter.createTransfer(
        book.session,
        movement(
          from,
          otherAccount,
          fromAmountMinor: 400,
          toAmountMinor: 500,
          envelopeId: envelope.id,
        ),
      );
      expect(crossEntity[0].lines.single.envelopeId, envelope.id);

      final otherEnvelope = await book.addEnvelope(
        name: 'Other envelope',
        entity: otherEntity,
      );
      await expectLater(
        TransactionWriter.createTransfer(
          book.session,
          movement(
            from,
            offBudget,
            fromAmountMinor: 400,
            envelopeId: otherEnvelope.id,
          ),
        ),
        throwsA(isA<ForbiddenException>()),
      );
    });

    test('a transfer dated after both entities today is rejected', () async {
      final firstEntity = await book.addEntity(
        name: 'Far east',
        timeZone: 'Pacific/Kiritimati',
      );
      final secondEntity = await book.addEntity(
        name: 'Far west',
        baseCurrencyCode: 'USD',
        countryCode: 'US',
        timeZone: 'Pacific/Honolulu',
      );
      final first = await book.addAccount(name: 'First', entity: firstEntity);
      final second = await book.addAccount(
        name: 'Second',
        entity: secondEntity,
      );
      final laterToday = EntityClock.today(firstEntity);
      final earlierToday = EntityClock.today(secondEntity);
      expect(
        laterToday.isAfter(earlierToday),
        isTrue,
        reason: 'the test needs a one-day difference between the entities',
      );

      await expectLater(
        TransactionWriter.createTransfer(
          book.session,
          movement(
            first,
            second,
            fromAmountMinor: 100,
            toAmountMinor: 100,
            date: laterToday.add(const Duration(days: 1)),
          ),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('a caller transaction publishes only after it commits', () async {
      final from = await book.addAccount(name: 'From');
      final to = await book.addAccount(name: 'To');

      await expectLater(
        TransactionWriter.inTransaction(book.session, (tx) async {
          await TransactionWriter.createTransfer(
            book.session,
            movement(from, to),
            transaction: tx,
          );
          throw StateError('roll back');
        }),
        throwsA(isA<StateError>()),
      );

      expect(await legsOn(from), isEmpty);
      expect(await transfersFor([from, to]), isEmpty);
      expect(await book.cachedBalanceMinor(from), 0);
      expect(events, isEmpty);
    });

    test('twenty concurrent creates leave the exact balances', () async {
      final from = await book.addAccount(name: 'From');
      final to = await book.addAccount(name: 'To');

      await Future.wait([
        for (var index = 0; index < 20; index++)
          TransactionWriter.createTransfer(
            book.session,
            movement(from, to, fromAmountMinor: 100),
          ),
      ]);

      expect(await legsOn(from), hasLength(20));
      expect(await legsOn(to), hasLength(20));
      expect(await transfersFor([from, to]), hasLength(20));
      expect(await book.cachedBalanceMinor(from), -2000);
      expect(await book.cachedBalanceMinor(to), 2000);
    });
  });

  group('updateTransfer', () {
    test('a metadata edit keeps stored FX and stable row ids', () async {
      final from = await book.addAccount(name: 'USD from', currencyCode: 'USD');
      final to = await book.addAccount(name: 'USD to', currencyCode: 'USD');
      await book.seedMarketRate(
        fromCurrencyCode: 'USD',
        toCurrencyCode: 'GBP',
        rateDate: _date,
        fromPerUsd: '1',
        toPerUsd: '0.8',
      );
      final created = await TransactionWriter.createTransfer(
        book.session,
        movement(from, to, fromAmountMinor: 1000),
      );
      final link = await linkFor(created[0].transaction.id!);
      final lineIds = [
        created[0].lines.single.id,
        created[1].lines.single.id,
      ];
      await server.clearRates();

      final edited = await TransactionWriter.updateTransfer(
        book.session,
        link!.id!,
        movement(from, to, fromAmountMinor: 1000, memo: 'Edited memo'),
      );

      expect(edited[0].transaction.id, created[0].transaction.id);
      expect(edited[1].transaction.id, created[1].transaction.id);
      expect(edited[0].lines.single.id, lineIds[0]);
      expect(edited[1].lines.single.id, lineIds[1]);
      expect(edited[0].transaction.memo, 'Edited memo');
      expect(edited[1].transaction.memo, 'Edited memo');
      expect(edited[0].transaction.fxRate, '0.8');
      expect(edited[0].transaction.fxRateSource, FxRateSource.market);
      expect(edited[0].transaction.baseAmountMinor, -800);
      expect(edited[1].transaction.fxRateSource, FxRateSource.implied);
      expect(edited[1].transaction.baseAmountMinor, 800);
      expect(await book.cachedBalanceMinor(from), -1000);
      expect(await book.cachedBalanceMinor(to), 1000);
      expectZeroSum(edited);
    });

    test('an amount change re-prices both legs coherently', () async {
      final from = await book.addAccount(name: 'USD from', currencyCode: 'USD');
      final to = await book.addAccount(name: 'USD to', currencyCode: 'USD');
      await book.seedMarketRate(
        fromCurrencyCode: 'USD',
        toCurrencyCode: 'GBP',
        rateDate: _date,
        fromPerUsd: '1',
        toPerUsd: '0.8',
      );
      final created = await TransactionWriter.createTransfer(
        book.session,
        movement(from, to, fromAmountMinor: 1000),
      );
      final link = await linkFor(created[0].transaction.id!);

      await book.seedRate(
        currencyCode: 'GBP',
        rateDate: _date,
        rate: '0.9',
      );
      final edited = await TransactionWriter.updateTransfer(
        book.session,
        link!.id!,
        movement(from, to, fromAmountMinor: 2000),
      );

      expect(edited[0].transaction.amountMinor, -2000);
      expect(edited[1].transaction.amountMinor, 2000);
      expect(edited[0].transaction.baseAmountMinor, -1800);
      expect(edited[1].transaction.baseAmountMinor, 1800);
      expect(edited[0].transaction.fxRate, '0.9');
      expect(edited[0].transaction.fxRateSource, FxRateSource.market);
      expect(edited[1].transaction.fxRateSource, FxRateSource.implied);
      expect(await book.cachedBalanceMinor(from), -2000);
      expect(await book.cachedBalanceMinor(to), 2000);
    });

    test('a source/destination swap keeps the leg and link ids', () async {
      final first = await book.addAccount(name: 'First');
      final second = await book.addAccount(name: 'Second');
      final created = await TransactionWriter.createTransfer(
        book.session,
        movement(first, second, fromAmountMinor: 1000),
      );
      final link = await linkFor(created[0].transaction.id!);
      events.clear();

      final swapped = await TransactionWriter.updateTransfer(
        book.session,
        link!.id!,
        movement(second, first, fromAmountMinor: 1000),
      );

      expect(swapped[0].transaction.id, created[0].transaction.id);
      expect(swapped[1].transaction.id, created[1].transaction.id);
      expect(link.fromTransactionId, created[0].transaction.id);
      expect(link.toTransactionId, created[1].transaction.id);
      expect(swapped[0].transaction.accountId, second.id);
      expect(swapped[0].transaction.amountMinor, -1000);
      expect(swapped[1].transaction.accountId, first.id);
      expect(swapped[1].transaction.amountMinor, 1000);
      expect(await book.cachedBalanceMinor(first), 1000);
      expect(await book.cachedBalanceMinor(second), -1000);
      expect(await book.recomputedBalanceMinor(first), 1000);
      expect(await book.recomputedBalanceMinor(second), -1000);
      expect(events, hasLength(4));
      expect(events.map((event) => event.accountId), {
        first.id,
        second.id,
      });
    });

    test('moving the legs changes entity, balances and events', () async {
      final first = await book.addAccount(name: 'First');
      final second = await book.addAccount(name: 'Second');
      final created = await TransactionWriter.createTransfer(
        book.session,
        movement(first, second, fromAmountMinor: 700),
      );
      final link = await linkFor(created[0].transaction.id!);
      final otherEntity = await book.addEntity(
        name: 'Other entity',
        baseCurrencyCode: 'USD',
        countryCode: 'US',
        timeZone: 'America/New_York',
      );
      final third = await book.addAccount(
        name: 'Third',
        currencyCode: 'USD',
        entity: otherEntity,
      );
      final fourth = await book.addAccount(
        name: 'Fourth',
        currencyCode: 'USD',
        entity: otherEntity,
      );
      events.clear();

      final moved = await TransactionWriter.updateTransfer(
        book.session,
        link!.id!,
        movement(third, fourth, fromAmountMinor: 900),
      );

      expect(moved[0].transaction.entityId, otherEntity.id);
      expect(moved[1].transaction.entityId, otherEntity.id);
      expect(moved[0].transaction.amountMinor, -900);
      expect(moved[1].transaction.amountMinor, 900);
      expect(moved[0].transaction.baseAmountMinor, -900);
      expect(moved[1].transaction.baseAmountMinor, 900);
      expect(await book.cachedBalanceMinor(first), 0);
      expect(await book.cachedBalanceMinor(second), 0);
      expect(await book.cachedBalanceMinor(third), -900);
      expect(await book.cachedBalanceMinor(fourth), 900);
      expect(events.map((event) => event.entityId), {
        book.entity.id,
        otherEntity.id,
      });
      expect(events.map((event) => event.accountId), {
        first.id,
        second.id,
        third.id,
        fourth.id,
      });
    });

    test(
      'an envelope-only edit keeps the stored FX and updates one line',
      () async {
        final from = await book.addAccount(
          name: 'USD from',
          currencyCode: 'USD',
        );
        final to = await book.addAccount(
          name: 'EUR off budget',
          currencyCode: 'EUR',
          onBudget: false,
        );
        await book.seedMarketRate(
          fromCurrencyCode: 'USD',
          toCurrencyCode: 'GBP',
          rateDate: _date,
          fromPerUsd: '1',
          toPerUsd: '0.8',
        );
        final created = await TransactionWriter.createTransfer(
          book.session,
          movement(from, to, fromAmountMinor: 1000, toAmountMinor: 900),
        );
        final link = await linkFor(created[0].transaction.id!);
        final envelope = await book.addEnvelope();
        await server.clearRates();
        events.clear();

        final edited = await TransactionWriter.updateTransfer(
          book.session,
          link!.id!,
          movement(
            from,
            to,
            fromAmountMinor: 1000,
            envelopeId: envelope.id,
          ),
        );

        expect(edited[0].lines.single.envelopeId, envelope.id);
        expect(edited[1].lines.single.envelopeId, isNull);
        expect(edited[0].transaction.baseAmountMinor, -800);
        expect(edited[0].transaction.fxRate, '0.8');
        expect(edited[0].transaction.fxRateSource, FxRateSource.market);
        expect(edited[1].transaction.baseAmountMinor, 800);
        expect(edited[1].transaction.fxRateSource, FxRateSource.implied);
        expect(await book.cachedBalanceMinor(from), -1000);
        expect(await book.cachedBalanceMinor(to), 900);
      },
    );

    test(
      'a date edit notifies both old and new months for both legs',
      () async {
        final from = await book.addAccount(name: 'From');
        final to = await book.addAccount(name: 'To');
        final created = await TransactionWriter.createTransfer(
          book.session,
          movement(from, to, date: DateTime.utc(2026, 3, 10)),
        );
        final link = await linkFor(created[0].transaction.id!);
        events.clear();

        await TransactionWriter.updateTransfer(
          book.session,
          link!.id!,
          movement(
            from,
            to,
            date: DateTime.utc(2026, 4, 2),
          ),
        );

        expect(events, hasLength(4));
        expect(
          events.map((event) => event.month),
          containsAll([202603, 202604]),
        );
        expect(events.map((event) => event.accountId), {
          from.id,
          to.id,
        });
        expect(
          events.every((event) => event.entityId == book.entity.id),
          isTrue,
        );
      },
    );

    test('same-currency destination must match the source', () async {
      final from = await book.addAccount(name: 'From');
      final to = await book.addAccount(name: 'To');
      final created = await TransactionWriter.createTransfer(
        book.session,
        movement(from, to, fromAmountMinor: 1000),
      );
      final link = await linkFor(created[0].transaction.id!);

      await expectLater(
        TransactionWriter.updateTransfer(
          book.session,
          link!.id!,
          movement(
            from,
            to,
            fromAmountMinor: 1000,
            toAmountMinor: 900,
          ),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test(
      'reconciled legs protect money and allow metadata or unlocking',
      () async {
        final from = await book.addAccount(name: 'From');
        final to = await book.addAccount(name: 'To');
        final created = await TransactionWriter.createTransfer(
          book.session,
          movement(from, to),
        );
        final link = await linkFor(created[0].transaction.id!);

        await expectLater(
          TransactionWriter.updateTransfer(
            book.session,
            link!.id!,
            movement(from, to, status: TransactionStatus.reconciled),
          ),
          throwsA(isA<ValidationException>()),
        );

        await TransactionWriter.update(
          book.session,
          created[0].transaction.id!,
          TransactionInput(
            accountId: from.id!,
            date: _date,
            amountMinor: -1000,
            status: TransactionStatus.reconciled,
            lines: const [],
          ),
        );
        await TransactionWriter.update(
          book.session,
          created[1].transaction.id!,
          TransactionInput(
            accountId: to.id!,
            date: _date,
            amountMinor: 1000,
            status: TransactionStatus.reconciled,
            lines: const [],
          ),
        );

        await expectLater(
          TransactionWriter.updateTransfer(
            book.session,
            link.id!,
            movement(
              from,
              to,
              fromAmountMinor: 2000,
              status: TransactionStatus.reconciled,
            ),
          ),
          throwsA(isA<ValidationException>()),
        );

        final metadata = await TransactionWriter.updateTransfer(
          book.session,
          link.id!,
          movement(
            from,
            to,
            memo: 'Still reconciled',
            status: TransactionStatus.reconciled,
          ),
        );
        expect(metadata[0].transaction.memo, 'Still reconciled');
        expect(metadata[0].transaction.status, TransactionStatus.reconciled);

        final unlocked = await TransactionWriter.updateTransfer(
          book.session,
          link.id!,
          movement(from, to, status: TransactionStatus.cleared),
        );
        expect(unlocked[0].transaction.status, TransactionStatus.cleared);
        expect(unlocked[1].transaction.status, TransactionStatus.cleared);
        expect(await book.cachedBalanceMinor(from), -1000);
        expect(await book.cachedBalanceMinor(to), 1000);
      },
    );

    test('a period lock protects material transfer edits', () async {
      final ledger = await BudgetTestBook.create(
        server.anonymousSession(),
        accountingMode: AccountingMode.ledger,
      );
      final from = await ledger.addAccount(name: 'From');
      final to = await ledger.addAccount(name: 'To');
      final created = await TransactionWriter.createTransfer(
        ledger.session,
        movement(from, to, date: DateTime.utc(2026, 2, 1)),
      );
      final link = await linkFor(created[0].transaction.id!);
      await ledger.addPeriodLock(DateTime.utc(2026, 2, 28));

      await expectLater(
        TransactionWriter.updateTransfer(
          ledger.session,
          link!.id!,
          movement(
            from,
            to,
            fromAmountMinor: 2000,
            date: DateTime.utc(2026, 2, 1),
          ),
        ),
        throwsA(isA<ValidationException>()),
      );

      final metadata = await TransactionWriter.updateTransfer(
        ledger.session,
        link.id!,
        movement(
          from,
          to,
          date: DateTime.utc(2026, 2, 1),
          memo: 'Metadata is allowed',
        ),
      );
      expect(metadata[0].transaction.memo, 'Metadata is allowed');
      expect(metadata[0].transaction.revision, 0);
      expect(await ledger.cachedBalanceMinor(from), -1000);
      expect(await ledger.cachedBalanceMinor(to), 1000);

      await expectLater(
        TransactionWriter.createTransfer(
          ledger.session,
          movement(
            from,
            to,
            date: DateTime.utc(2026, 2, 20),
          ),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('a missing rate on a material edit rolls the old legs back', () async {
      final from = await book.addAccount(name: 'USD', currencyCode: 'USD');
      final to = await book.addAccount(name: 'EUR', currencyCode: 'EUR');
      await book.seedMarketRate(
        fromCurrencyCode: 'USD',
        toCurrencyCode: 'GBP',
        rateDate: _date,
        fromPerUsd: '1',
        toPerUsd: '0.8',
      );
      final created = await TransactionWriter.createTransfer(
        book.session,
        movement(
          from,
          to,
          fromAmountMinor: 1000,
          toAmountMinor: 900,
        ),
      );
      final link = await linkFor(created[0].transaction.id!);
      await server.clearRates();
      events.clear();

      await expectLater(
        TransactionWriter.updateTransfer(
          book.session,
          link!.id!,
          movement(
            from,
            to,
            fromAmountMinor: 2000,
            toAmountMinor: 1800,
          ),
        ),
        throwsA(isA<FxRateUnavailableException>()),
      );

      final stored = await book.transaction(created[0].transaction.id!);
      expect(stored!.amountMinor, -1000);
      expect(stored.baseAmountMinor, created[0].transaction.baseAmountMinor);
      expect(await book.cachedBalanceMinor(from), -1000);
      expect(await book.cachedBalanceMinor(to), 900);
      expect(events, isEmpty);
    });

    test('a caller rollback keeps the old legs and emits nothing', () async {
      final from = await book.addAccount(name: 'From');
      final to = await book.addAccount(name: 'To');
      final created = await TransactionWriter.createTransfer(
        book.session,
        movement(from, to),
      );
      final link = await linkFor(created[0].transaction.id!);
      events.clear();

      await expectLater(
        TransactionWriter.inTransaction(book.session, (tx) async {
          await TransactionWriter.updateTransfer(
            book.session,
            link!.id!,
            movement(from, to, fromAmountMinor: 2000),
            transaction: tx,
          );
          throw StateError('roll back');
        }),
        throwsA(isA<StateError>()),
      );

      final stored = await book.transaction(created[0].transaction.id!);
      expect(stored!.amountMinor, -1000);
      expect(await book.cachedBalanceMinor(from), -1000);
      expect(await book.cachedBalanceMinor(to), 1000);
      expect(events, isEmpty);
    });

    test('concurrent edits keep one coherent pair and balance', () async {
      final from = await book.addAccount(name: 'From');
      final to = await book.addAccount(name: 'To');
      final created = await TransactionWriter.createTransfer(
        book.session,
        movement(from, to),
      );
      final link = await linkFor(created[0].transaction.id!);

      final results = await Future.wait([
        TransactionWriter.updateTransfer(
          book.session,
          link!.id!,
          movement(from, to, fromAmountMinor: 1100, memo: 'one'),
        ),
        TransactionWriter.updateTransfer(
          book.session,
          link.id!,
          movement(from, to, fromAmountMinor: 1200, memo: 'two'),
        ),
      ]);

      expect(results, hasLength(2));
      final storedFrom = (await book.transaction(created[0].transaction.id!))!;
      final storedTo = (await book.transaction(created[1].transaction.id!))!;
      expect(storedFrom.amountMinor, -storedTo.amountMinor);
      expect(storedFrom.memo, storedTo.memo);
      expect(
        await book.cachedBalanceMinor(from),
        storedFrom.amountMinor,
      );
      expect(await book.cachedBalanceMinor(to), storedTo.amountMinor);
      expect(await transfersFor([from, to]), hasLength(1));
    });

    test('an update racing a delete never leaves an orphan leg', () async {
      final from = await book.addAccount(name: 'From');
      final to = await book.addAccount(name: 'To');
      final created = await TransactionWriter.createTransfer(
        book.session,
        movement(from, to),
      );
      final link = await linkFor(created[0].transaction.id!);

      final update = _runCatching(
        () => TransactionWriter.updateTransfer(
          book.session,
          link!.id!,
          movement(from, to, fromAmountMinor: 1100),
        ),
      );
      final delete = _runCatching(
        () => TransactionWriter.delete(
          book.session,
          created[1].transaction.id!,
        ),
      );
      final outcomes = await Future.wait([update, delete]);

      for (final error in outcomes.nonNulls) {
        expect(error, isNot(isA<StateError>()));
      }
      final remaining = await model.Transaction.db.find(
        book.session,
        where: (t) => t.accountId.equals(from.id) | t.accountId.equals(to.id),
      );
      expect(
        remaining,
        anyOf(isEmpty, hasLength(2)),
        reason: 'a transfer delete removes both legs or neither',
      );
      if (remaining.isEmpty) {
        expect(await transfersFor([from, to]), isEmpty);
        expect(await book.cachedBalanceMinor(from), 0);
        expect(await book.cachedBalanceMinor(to), 0);
      } else {
        expect(
          remaining.map((row) => row.amountMinor).reduce((a, b) => a + b),
          0,
        );
        expect(await transfersFor([from, to]), hasLength(1));
        await book.expectBalancesConsistent();
      }
    });
  });
}

Future<Object?> _runCatching(Future<void> Function() body) async {
  try {
    await body();
    return null;
  } on Object catch (error) {
    return error;
  }
}
