// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_print
// ignore_for_file: avoid_redundant_argument_values

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_valuation_service.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/reports/net_worth_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';
import 'net_worth_helpers.dart';

final _now = DateTime.utc(2026, 6, 15, 12);
final _today = DateTime.utc(2026, 6, 15);

void main() {
  late PgTestServer server;
  late NetWorthFixture fixture;
  late List<DateTime> backfills;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    backfills = [];
    FxService.configure(
      apiKey: null,
      baseUrl: null,
      clock: () => _now,
      backfillScheduler: (_, date) async {
        backfills.add(date);
      },
    );
    await server.clearRates();
    fixture = NetWorthFixture(
      server: server,
      book: await BudgetTestBook.create(
        server.anonymousSession(),
        baseCurrencyCode: 'USD',
        countryCode: 'US',
        timeZone: 'Europe/London',
      ),
    );
    NetWorthService.resetDebugStatementCount();
  });

  tearDown(() {
    NetWorthService.resetDebugStatementCount();
    NetWorthService.debugAfterTransactionsQuery = null;
    FxService.resetForTests();
  });

  Future<Account> addAccount({
    String name = 'Checking',
    AccountKind kind = AccountKind.checking,
    String? currencyCode,
    AccountBalanceSource balanceSource = AccountBalanceSource.transactions,
    bool onBudget = true,
  }) => fixture.book.addAccount(
    name: name,
    kind: kind,
    currencyCode: currencyCode,
    balanceSource: balanceSource,
    onBudget: onBudget,
  );

  test(
    'given an opening balance and daily movements when day history runs then '
    'points carry running balances from one fact query',
    () async {
      final account = await addAccount();
      await fixture.addTransaction(
        account: account,
        date: DateTime.utc(2023, 12, 31),
        amountMinor: 1000,
      );
      await fixture.addTransaction(
        account: account,
        date: DateTime.utc(2024, 1, 5),
        amountMinor: -200,
      );
      await fixture.addTransaction(
        account: account,
        date: DateTime.utc(2024, 1, 7),
        amountMinor: 50,
      );

      final view = await NetWorthService.history(
        fixture.session,
        fromDate: DateTime.utc(2024, 1, 5),
        toDate: DateTime.utc(2024, 1, 7),
        granularity: NetWorthGranularity.day,
        currencyCode: 'USD',
      );

      expect(view.currencyCode, 'USD');
      expect(view.granularity, NetWorthGranularity.day);
      expect(view.points.map((point) => point.date), [
        DateTime.utc(2024, 1, 5),
        DateTime.utc(2024, 1, 6),
        DateTime.utc(2024, 1, 7),
      ]);
      expect(view.points.map((point) => point.netWorthMinor), [800, 800, 850]);
      expect(view.points.map((point) => point.assetsMinor), [800, 800, 850]);
      expect(view.points.every((point) => point.liabilitiesMinor == 0), isTrue);
      expect(view.points.every((point) => point.isComplete), isTrue);
      expect(NetWorthService.debugStatementLabels, [
        'scope',
        'accounts',
        'transactions',
      ]);
      expect(NetWorthService.debugStatementCountFor('transactions'), 1);
      expect(NetWorthService.debugStatementCountFor('valuations'), 0);
      expect(NetWorthService.debugStatementCountFor('fx'), 0);
    },
  );

  test(
    'given an account whose first fact is inside the range when history runs '
    'then points before that fact are zero',
    () async {
      final account = await addAccount();
      await fixture.addTransaction(
        account: account,
        date: DateTime.utc(2024, 1, 2),
        amountMinor: 500,
      );

      final view = await NetWorthService.history(
        fixture.session,
        fromDate: DateTime.utc(2024, 1, 1),
        toDate: DateTime.utc(2024, 1, 3),
        granularity: NetWorthGranularity.day,
        currencyCode: 'USD',
      );

      expect(view.points.map((point) => point.netWorthMinor), [0, 500, 500]);
      expect(view.points.every((point) => point.isComplete), isTrue);
    },
  );

  test(
    'given dated valuations including zero when month history runs then each '
    'point takes the latest value on or before its date',
    () async {
      final property = await addAccount(
        name: 'House',
        kind: AccountKind.property,
        balanceSource: AccountBalanceSource.valuations,
        onBudget: false,
      );
      await fixture.setValuation(
        account: property,
        date: DateTime.utc(2023, 12, 1),
        valueMinor: 100000,
      );
      await fixture.setValuation(
        account: property,
        date: DateTime.utc(2024, 1, 15),
        valueMinor: 100000,
      );
      await fixture.setValuation(
        account: property,
        date: DateTime.utc(2024, 2, 1),
        valueMinor: 0,
      );
      await fixture.setValuation(
        account: property,
        date: DateTime.utc(2024, 3, 1),
        valueMinor: 250000,
      );

      final view = await NetWorthService.history(
        fixture.session,
        fromDate: DateTime.utc(2024, 1, 1),
        toDate: DateTime.utc(2024, 3, 31),
        granularity: NetWorthGranularity.month,
        currencyCode: 'USD',
      );

      expect(view.points.map((point) => point.date), [
        DateTime.utc(2024, 1, 31),
        DateTime.utc(2024, 2, 29),
        DateTime.utc(2024, 3, 31),
      ]);
      expect(view.points.map((point) => point.netWorthMinor), [
        100000,
        0,
        250000,
      ]);
      expect(view.points[1].assetsMinor, 0);
      expect(view.points.every((point) => point.isComplete), isTrue);
      expect(NetWorthService.debugStatementLabels, [
        'scope',
        'accounts',
        'valuations',
      ]);
      expect(NetWorthService.debugStatementCountFor('valuations'), 1);
    },
  );

  test(
    'given transaction and valuation sources in several currencies when '
    'history runs then both fact queries and one FX query supply every point',
    () async {
      final usd = await addAccount(name: 'USD');
      final eur = await addAccount(name: 'EUR', currencyCode: 'EUR');
      final house = await addAccount(
        name: 'House',
        kind: AccountKind.property,
        currencyCode: 'GBP',
        balanceSource: AccountBalanceSource.valuations,
        onBudget: false,
      );
      await fixture.addTransaction(
        account: usd,
        date: DateTime.utc(2023, 12, 31),
        amountMinor: 10000,
      );
      await fixture.addTransaction(
        account: eur,
        date: DateTime.utc(2023, 12, 31),
        amountMinor: 5000,
      );
      await fixture.setValuation(
        account: house,
        date: DateTime.utc(2023, 12, 1),
        valueMinor: 200000,
      );
      await fixture.seedRates(DateTime.utc(2024, 1, 31), {
        'EUR': '0.9',
        'GBP': '0.8',
      });

      final view = await NetWorthService.history(
        fixture.session,
        fromDate: DateTime.utc(2024, 1, 1),
        toDate: DateTime.utc(2024, 1, 31),
        granularity: NetWorthGranularity.month,
        currencyCode: 'USD',
      );

      expect(view.points.single.netWorthMinor, 10000 + 5556 + 250000);
      expect(view.points.single.assetsMinor, 10000 + 5556 + 250000);
      expect(view.points.single.isComplete, isTrue);
      expect(NetWorthService.debugStatementLabels, [
        'scope',
        'accounts',
        'transactions',
        'valuations',
        'fx',
      ]);
      expect(NetWorthService.debugStatementCountFor('transactions'), 1);
      expect(NetWorthService.debugStatementCountFor('valuations'), 1);
      expect(NetWorthService.debugStatementCountFor('fx'), 1);
    },
  );

  test(
    'given a rate exactly seven days old when history runs then the window is '
    'exclusive and the missing point requests one backfill',
    () async {
      final eur = await addAccount(name: 'EUR', currencyCode: 'EUR');
      await fixture.addTransaction(
        account: eur,
        date: DateTime.utc(2023, 12, 31),
        amountMinor: 1000,
      );
      await fixture.seedRates(DateTime.utc(2024, 1, 3), {'EUR': '0.9'});

      final view = await NetWorthService.history(
        fixture.session,
        fromDate: DateTime.utc(2024, 1, 9),
        toDate: DateTime.utc(2024, 1, 10),
        granularity: NetWorthGranularity.day,
        currencyCode: 'USD',
      );

      expect(view.points, hasLength(2));
      expect(view.points[0].date, DateTime.utc(2024, 1, 9));
      expect(view.points[0].netWorthMinor, 1111);
      expect(view.points[0].isComplete, isTrue);
      expect(view.points[1].date, DateTime.utc(2024, 1, 10));
      expect(view.points[1].netWorthMinor, 0);
      expect(view.points[1].isComplete, isFalse);
      expect(
        view.points[1].netWorthMinor,
        isNot(1000),
        reason: 'a missing quote is never replaced with identity',
      );
      expect(backfills, [DateTime.utc(2024, 1, 10)]);
    },
  );

  test(
    'given two currencies missing on one point when history runs then only '
    'one backfill is requested for that date',
    () async {
      final eur = await addAccount(name: 'EUR', currencyCode: 'EUR');
      final jpy = await addAccount(name: 'JPY', currencyCode: 'JPY');
      await fixture.addTransaction(
        account: eur,
        date: DateTime.utc(2023, 12, 31),
        amountMinor: 1000,
      );
      await fixture.addTransaction(
        account: jpy,
        date: DateTime.utc(2023, 12, 31),
        amountMinor: 1000,
      );

      final view = await NetWorthService.history(
        fixture.session,
        fromDate: DateTime.utc(2024, 1, 5),
        toDate: DateTime.utc(2024, 1, 5),
        granularity: NetWorthGranularity.day,
        currencyCode: 'USD',
      );

      expect(view.points.single.isComplete, isFalse);
      expect(view.points.single.netWorthMinor, 0);
      expect(backfills, [DateTime.utc(2024, 1, 5)]);
    },
  );

  test(
    'given later edits, a delete and an import when history runs again then '
    'every call follows the live facts',
    () async {
      final account = await addAccount();
      final opening = await fixture.addTransaction(
        account: account,
        date: DateTime.utc(2023, 12, 31),
        amountMinor: 1000,
      );
      final inRange = await fixture.addTransaction(
        account: account,
        date: DateTime.utc(2024, 1, 2),
        amountMinor: 500,
      );

      Future<List<int>> read() async {
        final view = await NetWorthService.history(
          fixture.session,
          fromDate: DateTime.utc(2024, 1, 1),
          toDate: DateTime.utc(2024, 1, 3),
          granularity: NetWorthGranularity.day,
          currencyCode: 'USD',
        );
        return [for (final point in view.points) point.netWorthMinor];
      }

      expect(await read(), [1000, 1500, 1500]);

      await fixture.updateTransactionAmount(opening.id!, 1200);
      expect(await read(), [1200, 1700, 1700]);

      await fixture.deleteTransaction(inRange.id!);
      expect(await read(), [1200, 1200, 1200]);

      await fixture.addTransaction(
        account: account,
        date: DateTime.utc(2024, 1, 3),
        amountMinor: 300,
        externalId: 'import:1',
      );
      expect(await read(), [1200, 1200, 1500]);
    },
  );

  test(
    'given the same facts when current and a single history point run then '
    'both totals agree',
    () async {
      final usd = await addAccount(name: 'USD');
      final eur = await addAccount(name: 'EUR', currencyCode: 'EUR');
      final house = await addAccount(
        name: 'House',
        kind: AccountKind.property,
        currencyCode: 'GBP',
        balanceSource: AccountBalanceSource.valuations,
        onBudget: false,
      );
      await fixture.addTransaction(
        account: usd,
        date: DateTime.utc(2026, 1, 1),
        amountMinor: 1000,
      );
      await fixture.addTransaction(
        account: usd,
        date: DateTime.utc(2026, 2, 1),
        amountMinor: -300,
      );
      await fixture.addTransaction(
        account: eur,
        date: DateTime.utc(2026, 3, 1),
        amountMinor: 500,
      );
      await fixture.setValuation(
        account: house,
        date: DateTime.utc(2026, 4, 1),
        valueMinor: 200000,
      );
      await fixture.seedRates(_today, {'EUR': '0.9', 'GBP': '0.8'});

      final current = await NetWorthService.current(
        fixture.session,
        currencyCode: 'USD',
        asOf: _today,
      );
      final history = await NetWorthService.history(
        fixture.session,
        fromDate: _today,
        toDate: _today,
        granularity: NetWorthGranularity.day,
        currencyCode: 'USD',
      );

      expect(history.points, hasLength(1));
      expect(history.points.single.assetsMinor, current.assetsMinor);
      expect(
        history.points.single.liabilitiesMinor,
        current.liabilitiesMinor,
      );
      expect(history.points.single.netWorthMinor, current.netWorthMinor);
      expect(history.points.single.isComplete, current.isComplete);
      expect(current.netWorthMinor, 700 + 556 + 250000);
    },
  );

  test(
    'given a competing valuation committed after the transaction query when '
    'history runs then the returned points come from one snapshot',
    () async {
      final cash = await addAccount(name: 'Cash');
      final house = await addAccount(
        name: 'House',
        kind: AccountKind.property,
        balanceSource: AccountBalanceSource.valuations,
        onBudget: false,
      );
      await fixture.addTransaction(
        account: cash,
        date: DateTime.utc(2023, 12, 31),
        amountMinor: 100,
      );
      await fixture.setValuation(
        account: house,
        date: DateTime.utc(2023, 12, 1),
        valueMinor: 100000,
      );

      final writer = server.authenticatedSession(fixture.book.userId);
      addTearDown(writer.close);
      var writes = 0;
      NetWorthService.debugAfterTransactionsQuery = () async {
        if (writes != 0) return;
        writes = 1;
        await AccountValuationService.set(
          writer,
          house.id!,
          DateTime.utc(2024, 1, 5),
          999999,
        );
      };

      final view = await NetWorthService.history(
        fixture.session,
        fromDate: DateTime.utc(2024, 1, 5),
        toDate: DateTime.utc(2024, 1, 6),
        granularity: NetWorthGranularity.day,
        currencyCode: 'USD',
      );

      expect(writes, 1);
      expect(view.points.map((point) => point.netWorthMinor), [
        100100,
        100100,
      ]);

      final after = await NetWorthService.history(
        fixture.session,
        fromDate: DateTime.utc(2024, 1, 5),
        toDate: DateTime.utc(2024, 1, 6),
        granularity: NetWorthGranularity.day,
        currencyCode: 'USD',
      );
      expect(after.points.map((point) => point.netWorthMinor), [
        1000099,
        1000099,
      ]);
    },
  );

  test(
    'given 400 monthly points and many accounts when history runs then fact '
    'queries stay at one each and the plans use the declared indexes',
    () async {
      final from = DateTime.utc(2020, 1, 1);
      final to = DateTime.utc(2053, 4, 30);
      final transactionAccounts = <Account>[];
      final valuationAccounts = <Account>[];
      const currencies = ['USD', 'EUR', 'GBP'];

      for (var index = 0; index < 10; index++) {
        final currency = currencies[index % currencies.length];
        final transactionAccount = await addAccount(
          name: 'Transaction $index',
          currencyCode: currency,
        );
        await fixture.addTransaction(
          account: transactionAccount,
          date: DateTime.utc(2019, 12, 31),
          amountMinor: 1000 + index,
        );
        transactionAccounts.add(transactionAccount);

        final valuationAccount = await addAccount(
          name: 'Valuation $index',
          kind: AccountKind.property,
          currencyCode: currency,
          balanceSource: AccountBalanceSource.valuations,
          onBudget: false,
        );
        await fixture.setValuation(
          account: valuationAccount,
          date: DateTime.utc(2019, 12, 1),
          valueMinor: 2000 + index,
        );
        valuationAccounts.add(valuationAccount);
      }

      final fxRows = <FxRate>[];
      for (
        var date = DateTime.utc(2020, 1, 31);
        !date.isAfter(to);
        date = DateTime.utc(date.year, date.month + 2, 0)
      ) {
        fxRows
          ..add(
            FxRate(
              rateDate: date,
              currencyCode: 'USD',
              rate: '1',
              provider: FxProvider.currencyapi,
              fetchedAt: date.add(const Duration(hours: 2)),
            ),
          )
          ..add(
            FxRate(
              rateDate: date,
              currencyCode: 'EUR',
              rate: '0.9',
              provider: FxProvider.currencyapi,
              fetchedAt: date.add(const Duration(hours: 2)),
            ),
          )
          ..add(
            FxRate(
              rateDate: date,
              currencyCode: 'GBP',
              rate: '0.8',
              provider: FxProvider.currencyapi,
              fetchedAt: date.add(const Duration(hours: 2)),
            ),
          );
      }
      await FxRate.db.insert(fixture.session, fxRows);

      NetWorthService.resetDebugStatementCount();
      final view = await NetWorthService.history(
        fixture.session,
        fromDate: from,
        toDate: to,
        granularity: NetWorthGranularity.month,
        currencyCode: 'USD',
      );
      final fullLabels = NetWorthService.debugStatementLabels;
      final fullCount = NetWorthService.debugStatementCount;

      expect(view.points, hasLength(400));
      expect(view.points.first.date, DateTime.utc(2020, 1, 31));
      expect(view.points.last.date, DateTime.utc(2053, 4, 30));
      expect(fullLabels, [
        'scope',
        'accounts',
        'transactions',
        'valuations',
        'fx',
      ]);
      expect(NetWorthService.debugStatementCountFor('transactions'), 1);
      expect(NetWorthService.debugStatementCountFor('valuations'), 1);
      expect(NetWorthService.debugStatementCountFor('fx'), 1);

      NetWorthService.resetDebugStatementCount();
      await NetWorthService.history(
        fixture.session,
        fromDate: from,
        toDate: DateTime.utc(2020, 3, 31),
        granularity: NetWorthGranularity.month,
        currencyCode: 'USD',
      );
      expect(NetWorthService.debugStatementLabels, fullLabels);
      expect(NetWorthService.debugStatementCount, fullCount);

      Future<String> explain(
        String sql,
        Map<String, Object?> parameters,
      ) async {
        final rows = await fixture.session.db.transaction((transaction) async {
          await fixture.session.db.unsafeExecute(
            'SET LOCAL enable_seqscan = off',
            transaction: transaction,
          );
          return fixture.session.db.unsafeQuery(
            'EXPLAIN (ANALYZE, FORMAT JSON) $sql',
            parameters: QueryParameters.named(parameters),
            transaction: transaction,
          );
        });
        final value = rows.first.single;
        return value is String ? value : value.toString();
      }

      final transactionIds = transactionAccounts
          .map((account) => account.id!.toString())
          .toList();
      final valuationIds = valuationAccounts
          .map((account) => account.id!.toString())
          .toList();
      final transactionPlan = await explain(NetWorthService.transactionsSql, {
        'openingAccountIds': '{${transactionIds.join(',')}}',
        'rangeAccountIds': '{${transactionIds.join(',')}}',
        'fromDate': from,
        'toDate': to,
      });
      final valuationPlan = await explain(NetWorthService.valuationsSql, {
        'openingAccountIds': '{${valuationIds.join(',')}}',
        'rangeAccountIds': '{${valuationIds.join(',')}}',
        'fromDate': from,
        'toDate': to,
      });
      final fxPlan = await explain(NetWorthService.fxRowsSql, {
        'currencyCodes': '{EUR,GBP,USD}',
        'windowStart': from.subtract(const Duration(days: 7)),
        'toDate': to,
      });

      expect(transactionPlan, contains('transaction_account_date_idx'));
      expect(
        valuationPlan,
        contains('account_valuation_account_date_unique_idx'),
      );
      expect(
        fxPlan,
        anyOf(
          contains('fx_rate_currency_date_unique_idx'),
          contains('fx_rate_date_idx'),
        ),
        reason: 'the batch scan may use either declared FX index',
      );
      final fxLookupPlan = await explain(
        '''
SELECT "currencyCode", "rateDate", "rate", "fetchedAt"
FROM fx_rate
WHERE "currencyCode" = @currencyCode
  AND "rateDate" <= @date::timestamp
  AND "rateDate" > @windowStart::timestamp
ORDER BY "rateDate" DESC
LIMIT 1''',
        {
          'currencyCode': 'EUR',
          'date': to,
          'windowStart': to.subtract(const Duration(days: 7)),
        },
      );
      expect(fxLookupPlan, contains('fx_rate_currency_date_unique_idx'));
      print(
        '400-point history: $fullCount statements, '
        '${view.points.length} points, '
        '${transactionAccounts.length + valuationAccounts.length} accounts',
      );
    },
  );

  test(
    'given no login or an invalid range when history runs then each is '
    'rejected before any facts are read',
    () async {
      await expectLater(
        NetWorthService.history(
          server.anonymousSession(),
          fromDate: DateTime.utc(2024, 1, 1),
          toDate: DateTime.utc(2024, 1, 2),
          granularity: NetWorthGranularity.day,
          currencyCode: 'USD',
        ),
        throwsA(isA<AuthenticationRequiredException>()),
      );

      await expectLater(
        NetWorthService.history(
          fixture.session,
          fromDate: DateTime.utc(2024, 1, 2),
          toDate: DateTime.utc(2024, 1, 1),
          granularity: NetWorthGranularity.day,
          currencyCode: 'USD',
        ),
        throwsA(isA<ValidationException>()),
      );
    },
  );
}
