// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/reports/net_worth_service.dart';
import 'package:openbudget_server/src/settings/user_settings_service.dart';
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
    int balanceMinor = 0,
    DateTime? closedAt,
    Entity? entity,
  }) => fixture.book.addAccount(
    name: name,
    kind: kind,
    currencyCode: currencyCode,
    balanceSource: balanceSource,
    onBudget: onBudget,
    balanceMinor: balanceMinor,
    closedAt: closedAt,
    entity: entity,
  );

  test(
    'given USD, EUR, JPY and KWD accounts when current runs then every '
    'exponent converts once and all totals agree',
    () async {
      final usd = await addAccount(name: 'USD', balanceMinor: 10000);
      final eur = await addAccount(
        name: 'EUR',
        currencyCode: 'EUR',
        balanceMinor: 5000,
      );
      final jpy = await addAccount(
        name: 'JPY',
        currencyCode: 'JPY',
        balanceMinor: 100000,
      );
      final kwd = await addAccount(
        name: 'KWD',
        currencyCode: 'KWD',
        balanceMinor: 500,
      );
      final card = await addAccount(
        name: 'Card',
        kind: AccountKind.creditCard,
        balanceMinor: -20000,
      );
      final loan = await addAccount(
        name: 'Loan',
        kind: AccountKind.loan,
        balanceMinor: -50000,
      );
      await fixture.seedRates(_today, {
        'EUR': '0.9',
        'JPY': '150',
        'KWD': '0.307',
      });

      final view = await NetWorthService.current(
        fixture.session,
        currencyCode: 'USD',
        asOf: _today,
      );

      expect(view.currencyCode, 'USD');
      expect(view.asOf, _today);
      expect(view.assetsMinor, 10000 + 5556 + 66667 + 163);
      expect(view.liabilitiesMinor, -70000);
      expect(view.netWorthMinor, 82386 - 70000);
      expect(view.isComplete, isTrue);
      expect(view.missingCurrencyCodes, isEmpty);
      expect(view.hasStaleRates, isFalse);

      expect(view.currencies.map((row) => row.currencyCode), [
        'EUR',
        'JPY',
        'KWD',
        'USD',
      ]);
      final eurRow = view.currencies.first;
      expect(eurRow.nativeMinor, 5000);
      expect(eurRow.convertedMinor, 5556);
      expect(eurRow.fxRate, '1.11111111111');
      expect(eurRow.fxRateDate, _today);
      expect(eurRow.fxRateSource, FxRateSource.market);
      expect(eurRow.isStale, isFalse);
      expect(eurRow.accountCount, 1);
      final usdRow = view.currencies.last;
      expect(usdRow.nativeMinor, -60000);
      expect(usdRow.convertedMinor, -60000);
      expect(usdRow.fxRate, '1');
      expect(usdRow.fxRateSource, FxRateSource.identity);
      expect(usdRow.accountCount, 3);

      expect(view.accounts, hasLength(6));
      expect(
        view.accounts
            .singleWhere((row) => row.accountId == eur.id)
            .convertedMinor,
        5556,
      );
      expect(
        view.accounts
            .singleWhere((row) => row.accountId == jpy.id)
            .convertedMinor,
        66667,
      );
      expect(
        view.accounts
            .singleWhere((row) => row.accountId == kwd.id)
            .convertedMinor,
        163,
      );
      expect(
        view.accounts
            .singleWhere((row) => row.accountId == card.id)
            .isLiability,
        isTrue,
      );
      expect(
        view.accounts
            .singleWhere((row) => row.accountId == loan.id)
            .isLiability,
        isTrue,
      );
      expect(
        view.accounts.singleWhere((row) => row.accountId == usd.id).isLiability,
        isFalse,
      );

      final accountTotal = view.accounts.fold<int>(
        0,
        (sum, row) => sum + row.convertedMinor!,
      );
      final currencyTotal = view.currencies.fold<int>(
        0,
        (sum, row) => sum + row.convertedMinor!,
      );
      final entityRow = view.entities.single;
      expect(accountTotal, view.netWorthMinor);
      expect(currencyTotal, view.netWorthMinor);
      expect(entityRow.assetsMinor, view.assetsMinor);
      expect(entityRow.liabilitiesMinor, view.liabilitiesMinor);
      expect(entityRow.netWorthMinor, view.netWorthMinor);
      expect(entityRow.isComplete, isTrue);

      expect(NetWorthService.debugStatementLabels, [
        'scope',
        'accounts',
        'fx',
      ]);
      expect(NetWorthService.debugStatementCountFor('fx'), 1);
    },
  );

  test(
    'given two accounts with a rounding residue when current runs then the '
    'account sum wins over converting the aggregate',
    () async {
      final first = await addAccount(
        name: 'GBP one',
        currencyCode: 'GBP',
        balanceMinor: 3333,
      );
      final second = await addAccount(
        name: 'GBP two',
        currencyCode: 'GBP',
        balanceMinor: 3333,
      );
      await fixture.seedRates(_today, {'GBP': '0.8'});

      final view = await NetWorthService.current(
        fixture.session,
        currencyCode: 'USD',
        asOf: _today,
      );
      final perAccount = view.accounts.fold<int>(
        0,
        (sum, row) => sum + row.convertedMinor!,
      );
      final aggregate = convertMinorUnits(
        amountMinor: 6666,
        exchangeRate: ExactDecimal.tryParse('1.25')!,
        transactionExponent: 2,
        functionalExponent: 2,
      );

      expect(
        view.accounts
            .singleWhere((row) => row.accountId == first.id)
            .convertedMinor,
        4166,
      );
      expect(
        view.accounts
            .singleWhere((row) => row.accountId == second.id)
            .convertedMinor,
        4166,
      );
      expect(perAccount, 8332);
      expect(aggregate, 8333);
      expect(view.netWorthMinor, perAccount);
      expect(view.currencies.single.nativeMinor, 6666);
      expect(view.currencies.single.convertedMinor, perAccount);
      expect(view.currencies.single.accountCount, 2);
    },
  );

  test(
    'given an overpaid card and a negative asset when current runs then kind '
    'decides the side, not the sign',
    () async {
      await addAccount(
        name: 'Overpaid card',
        kind: AccountKind.creditCard,
        balanceMinor: 1500,
      );
      await addAccount(name: 'Overdrawn checking', balanceMinor: -800);

      final view = await NetWorthService.current(
        fixture.session,
        currencyCode: 'USD',
        asOf: _today,
      );

      expect(view.assetsMinor, -800);
      expect(view.liabilitiesMinor, 1500);
      expect(view.netWorthMinor, 700);
      expect(
        view.accounts
            .singleWhere((row) => row.name == 'Overpaid card')
            .isLiability,
        isTrue,
      );
      expect(
        view.accounts
            .singleWhere((row) => row.name == 'Overdrawn checking')
            .isLiability,
        isFalse,
      );
      expect(
        view.entities.single.liabilitiesMinor,
        1500,
        reason: 'a positive liability contributes positively to liabilities',
      );
      expect(view.currencies.single.nativeMinor, 700);
    },
  );

  test(
    'given default and explicit scopes when current runs then include flags, '
    'archives, duplicates and ownership follow one contract',
    () async {
      final first = fixture.entity;
      final second = await fixture.addEntity(name: 'Included');
      final excluded = await fixture.addEntity(
        name: 'Excluded company',
        kind: EntityKind.company,
        includeInNetWorth: false,
      );
      final archived = await fixture.addEntity(
        name: 'Archived',
        archivedAt: DateTime.utc(2026, 1, 1),
      );
      final foreign = await fixture.addForeignEntity();
      final accounts = [
        await addAccount(name: 'First', balanceMinor: 100, entity: first),
        await addAccount(name: 'Second', balanceMinor: 200, entity: second),
        await addAccount(name: 'Excluded', balanceMinor: 400, entity: excluded),
        await addAccount(name: 'Archived', balanceMinor: 800, entity: archived),
        await addAccount(name: 'Foreign', balanceMinor: 1600, entity: foreign),
      ];

      final defaultView = await NetWorthService.current(
        fixture.session,
        currencyCode: 'USD',
      );
      expect(defaultView.entities.map((row) => row.entityId), [
        first.id,
        second.id,
      ]);
      expect(defaultView.netWorthMinor, 300);
      expect(defaultView.accounts, hasLength(2));

      final explicitView = await NetWorthService.current(
        fixture.session,
        entityIds: [archived.id!, excluded.id!, first.id!, first.id!],
        currencyCode: 'USD',
      );
      expect(explicitView.entities.map((row) => row.entityId), [
        first.id,
        excluded.id,
        archived.id,
      ]);
      expect(explicitView.netWorthMinor, 100 + 400 + 800);
      expect(explicitView.accounts, hasLength(3));
      expect(
        explicitView.accounts.every(
          (row) => accounts.any((account) => account.id == row.accountId),
        ),
        isTrue,
      );

      await expectLater(
        NetWorthService.current(
          fixture.session,
          entityIds: [first.id!, foreign.id!],
          currencyCode: 'USD',
        ),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        NetWorthService.current(
          fixture.session,
          entityIds: [first.id!, const Uuid().v7obj()],
          currencyCode: 'USD',
        ),
        throwsA(isA<NotFoundException>()),
      );

      final emptyView = await NetWorthService.current(
        fixture.session,
        entityIds: const [],
        currencyCode: 'USD',
      );
      expect(emptyView.entities, isEmpty);
      expect(emptyView.accounts, isEmpty);
      expect(emptyView.currencies, isEmpty);
      expect(emptyView.assetsMinor, 0);
      expect(emptyView.liabilitiesMinor, 0);
      expect(emptyView.netWorthMinor, 0);
      expect(emptyView.isComplete, isTrue);
      expect(emptyView.hasStaleRates, isFalse);
    },
  );

  test(
    'given user settings and an explicit currency when current runs then the '
    'explicit code wins and settings fill the default',
    () async {
      await UserSettingsService.setReportingCurrency(fixture.session, 'EUR');

      final fromSettings = await NetWorthService.current(
        fixture.session,
        entityIds: const [],
      );
      expect(fromSettings.currencyCode, 'EUR');

      final explicit = await NetWorthService.current(
        fixture.session,
        entityIds: const [],
        currencyCode: 'jpy',
      );
      expect(explicit.currencyCode, 'JPY');

      await expectLater(
        NetWorthService.current(
          fixture.session,
          entityIds: const [],
          currencyCode: 'ZZZ',
        ),
        throwsA(isA<ValidationException>()),
      );
    },
  );

  test(
    'given closed and zero accounts when current runs then only non-zero '
    'accounts become atoms',
    () async {
      final closedNonZero = await addAccount(
        name: 'Closed non-zero',
        balanceMinor: 500,
        closedAt: _today,
      );
      await addAccount(
        name: 'Closed zero',
        balanceMinor: 0,
        closedAt: _today,
      );
      await addAccount(name: 'Open zero', balanceMinor: 0);

      final view = await NetWorthService.current(
        fixture.session,
        currencyCode: 'USD',
        asOf: _today,
      );

      expect(view.accounts, hasLength(1));
      expect(view.accounts.single.accountId, closedNonZero.id);
      expect(view.accounts.single.balanceMinor, 500);
      expect(view.currencies.single.accountCount, 1);
      expect(view.netWorthMinor, 500);
      expect(view.entities.single.isComplete, isTrue);
    },
  );

  test(
    'given corrected and future valuations when current runs then today uses '
    'the cache and a past date uses the as-of facts',
    () async {
      final property = await addAccount(
        name: 'House',
        kind: AccountKind.property,
        balanceSource: AccountBalanceSource.valuations,
        onBudget: false,
      );
      await fixture.setValuation(
        account: property,
        date: DateTime.utc(2026, 6, 10),
        valueMinor: 100000,
      );
      await fixture.setValuation(
        account: property,
        date: DateTime.utc(2026, 6, 12),
        valueMinor: 120000,
      );

      final todayView = await NetWorthService.current(
        fixture.session,
        currencyCode: 'USD',
        asOf: _today,
      );
      expect(todayView.netWorthMinor, 120000);
      expect(
        todayView.accounts.single.valuationDate,
        DateTime.utc(2026, 6, 12),
      );

      await fixture.setValuation(
        account: property,
        date: DateTime.utc(2026, 6, 10),
        valueMinor: 110000,
      );

      final pastView = await NetWorthService.current(
        fixture.session,
        currencyCode: 'USD',
        asOf: DateTime.utc(2026, 6, 11),
      );
      expect(pastView.asOf, DateTime.utc(2026, 6, 11));
      expect(pastView.netWorthMinor, 110000);
      expect(pastView.accounts.single.valuationDate, DateTime.utc(2026, 6, 10));
      expect(pastView.accounts.single.balanceMinor, 110000);
      expect(pastView.currencies.single.convertedMinor, 110000);
      expect(pastView.entities.single.netWorthMinor, 110000);
    },
  );

  test(
    'given a missing rate when current runs then converted values are null, '
    'the code is listed once and totals exclude it',
    () async {
      await addAccount(name: 'USD', balanceMinor: 5000);
      await addAccount(
        name: 'EUR',
        currencyCode: 'EUR',
        balanceMinor: 1000,
      );

      final view = await NetWorthService.current(
        fixture.session,
        currencyCode: 'USD',
        asOf: _today,
      );

      expect(view.assetsMinor, 5000);
      expect(view.liabilitiesMinor, 0);
      expect(view.netWorthMinor, 5000);
      expect(view.isComplete, isFalse);
      expect(view.missingCurrencyCodes, ['EUR']);
      expect(view.hasStaleRates, isFalse);
      final eurRow = view.currencies.singleWhere(
        (row) => row.currencyCode == 'EUR',
      );
      expect(eurRow.nativeMinor, 1000);
      expect(eurRow.convertedMinor, isNull);
      expect(eurRow.fxRate, isNull);
      expect(eurRow.fxRateDate, isNull);
      expect(eurRow.fxRateSource, isNull);
      expect(eurRow.isStale, isFalse);
      expect(eurRow.accountCount, 1);
      expect(
        view.accounts.singleWhere((row) => row.name == 'EUR').convertedMinor,
        isNull,
      );
      expect(view.entities.single.isComplete, isFalse);
      expect(view.entities.single.netWorthMinor, 5000);
      expect(backfills, [_today]);
    },
  );

  test(
    'given two missing currencies when current runs then codes are sorted and '
    'one backfill is requested',
    () async {
      await addAccount(
        name: 'EUR',
        currencyCode: 'EUR',
        balanceMinor: 1000,
      );
      await addAccount(
        name: 'JPY',
        currencyCode: 'JPY',
        balanceMinor: 1000,
      );

      final view = await NetWorthService.current(
        fixture.session,
        currencyCode: 'USD',
        asOf: _today,
      );

      expect(view.missingCurrencyCodes, ['EUR', 'JPY']);
      expect(view.isComplete, isFalse);
      expect(backfills, [_today]);
    },
  );

  test(
    'given stale dates and stale fetches when current runs then a found rate '
    'still converts and sets the stale flag',
    () async {
      await addAccount(
        name: 'GBP',
        currencyCode: 'GBP',
        balanceMinor: 1000,
      );
      await fixture.seedRates(DateTime.utc(2026, 6, 12), {'GBP': '0.8'});

      final staleDate = await NetWorthService.current(
        fixture.session,
        currencyCode: 'USD',
        asOf: _today,
      );
      expect(staleDate.isComplete, isTrue);
      expect(staleDate.hasStaleRates, isTrue);
      expect(staleDate.currencies.single.isStale, isTrue);
      expect(staleDate.currencies.single.fxRateDate, DateTime.utc(2026, 6, 12));
      expect(staleDate.netWorthMinor, 1250);

      await server.clearRates();
      await fixture.seedRate(
        currencyCode: 'USD',
        rateDate: _today,
        rate: '1',
        fetchedAt: _now.subtract(const Duration(hours: 73)),
      );
      await fixture.seedRate(
        currencyCode: 'GBP',
        rateDate: _today,
        rate: '0.8',
        fetchedAt: _now.subtract(const Duration(hours: 73)),
      );

      final staleFetch = await NetWorthService.current(
        fixture.session,
        currencyCode: 'USD',
        asOf: _today,
      );
      expect(staleFetch.hasStaleRates, isTrue);
      expect(staleFetch.currencies.single.isStale, isTrue);
    },
  );

  test(
    'given the reporting currency itself when current runs then identity is '
    'used without an FX row or a backfill',
    () async {
      await addAccount(
        name: 'GBP',
        currencyCode: 'GBP',
        balanceMinor: 1000,
      );

      final view = await NetWorthService.current(
        fixture.session,
        currencyCode: 'GBP',
        asOf: _today,
      );

      expect(view.isComplete, isTrue);
      expect(view.netWorthMinor, 1000);
      expect(view.currencies.single.fxRate, '1');
      expect(view.currencies.single.fxRateDate, _today);
      expect(view.currencies.single.fxRateSource, FxRateSource.identity);
      expect(view.currencies.single.isStale, isFalse);
      expect(backfills, isEmpty);
      expect(NetWorthService.debugStatementCountFor('fx'), 0);
    },
  );

  test(
    'given bad dates, an unsupported account currency or no login when current '
    'runs then the contract rejects each',
    () async {
      await expectLater(
        NetWorthService.current(
          server.anonymousSession(),
          entityIds: const [],
          currencyCode: 'USD',
        ),
        throwsA(isA<AuthenticationRequiredException>()),
      );

      await expectLater(
        NetWorthService.current(
          fixture.session,
          currencyCode: 'USD',
          asOf: DateTime.utc(2026, 6, 15, 12),
        ),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        NetWorthService.current(
          fixture.session,
          currencyCode: 'USD',
          asOf: DateTime.utc(2026, 6, 16),
        ),
        throwsA(isA<ValidationException>()),
      );

      await addAccount(
        name: 'Bad currency',
        currencyCode: 'ZZZ',
        balanceMinor: 100,
      );
      await expectLater(
        NetWorthService.current(
          fixture.session,
          currencyCode: 'USD',
          asOf: _today,
        ),
        throwsA(isA<ValidationException>()),
      );
    },
  );

  test(
    'given today in the first entity time zone when current omits asOf then '
    'the date is that civil day',
    () async {
      final view = await NetWorthService.current(
        fixture.session,
        currencyCode: 'USD',
      );

      expect(view.asOf, EntityClock.today(fixture.entity, now: _now));
      expect(view.asOf, _today);
    },
  );
}
