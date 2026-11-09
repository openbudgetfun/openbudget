// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/fx_rates/fx_backfill_future_call.dart';
import 'package:openbudget_server/src/fx_rates/fx_provider_client.dart';
import 'package:openbudget_server/src/fx_rates/fx_rate_endpoint.dart';
import 'package:openbudget_server/src/fx_rates/fx_refresh_future_call.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'support/fx_test_server.dart';

final _now = DateTime.utc(2026, 3, 10, 12);

class _FakeFxProviderClient implements FxRateProviderClient {
  _FakeFxProviderClient({
    this.latest,
    this.historical = const {},
    this.historicalError,
  });

  final FxProviderResult Function(int call)? latest;
  final Map<DateTime, FxProviderResult> historical;
  final Exception? historicalError;

  int latestCalls = 0;
  final List<DateTime> historicalCalls = [];

  @override
  String get providerName => 'fake';

  @override
  Future<FxProviderResult> fetchLatest({
    required String apiKey,
    required String baseCurrencyCode,
    required List<String> currencies,
    required String baseUrl,
  }) async {
    latestCalls += 1;
    final builder = latest;
    if (builder == null) {
      throw ValidationException(message: 'No fake latest response');
    }
    return builder(latestCalls);
  }

  @override
  Future<FxProviderResult> fetchHistorical({
    required String apiKey,
    required String baseCurrencyCode,
    required List<String> currencies,
    required DateTime date,
    required String baseUrl,
  }) async {
    historicalCalls.add(date);
    final error = historicalError;
    if (error != null) throw error;
    final result = historical[date];
    if (result == null) {
      throw ValidationException(
        message: 'No fake historical response for $date',
      );
    }
    return result;
  }
}

void main() {
  late FxTestServer server;
  late Session session;
  late List<DateTime> backfillRequests;
  late _FakeFxProviderClient provider;
  var serverStarted = false;

  setUpAll(() async {
    server = await FxTestServer.start();
    serverStarted = true;
    session = server.session;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    await server.clearRates();
    backfillRequests = [];
    provider = _FakeFxProviderClient();
  });

  tearDown(FxService.resetForTests);

  void configureProvider({DateTime Function()? clock}) {
    FxService.configure(
      apiKey: 'test-key',
      baseUrl: 'https://example.test/v3',
      providerClient: provider,
      clock: clock ?? () => _now,
      backfillScheduler: (_, date) async {
        backfillRequests.add(date);
      },
    );
  }

  Future<void> seed(
    String currencyCode,
    DateTime rateDate,
    String rate, {
    DateTime? fetchedAt,
  }) async {
    await FxRate.db.insertRow(
      session,
      FxRate(
        rateDate: rateDate,
        currencyCode: currencyCode,
        rate: rate,
        provider: FxProvider.currencyapi,
        fetchedAt: fetchedAt ?? rateDate.add(const Duration(hours: 2)),
      ),
    );
  }

  Future<void> seedUsd(DateTime rateDate, {DateTime? fetchedAt}) =>
      seed('USD', rateDate, '1', fetchedAt: fetchedAt);

  test('identity is returned only for identical currencies', () async {
    configureProvider();

    final quote = await FxService.rateOn(
      session,
      'GBP',
      'GBP',
      DateTime.utc(2026, 3, 1),
    );

    expect(quote, isNotNull);
    expect(quote!.rate, '1');
    expect(quote.rateDate, DateTime.utc(2026, 3, 1));
    expect(quote.source, FxRateSource.identity);
    expect(quote.fetchedAt, isNull);
    expect(quote.isStale, isFalse);
  });

  test('cross rates include USD and keep twelve significant digits', () async {
    configureProvider();
    final date = DateTime.utc(2026, 3, 9);
    await seedUsd(date);
    await seed('EUR', date, '0.9');
    await seed('GBP', date, '0.8');

    final eurToGbp = await FxService.rateOn(session, 'EUR', 'GBP', date);
    final gbpToEur = await FxService.rateOn(session, 'GBP', 'EUR', date);
    final eurToUsd = await FxService.rateOn(session, 'EUR', 'USD', date);
    final usdToEur = await FxService.rateOn(session, 'USD', 'EUR', date);

    expect(eurToGbp!.rate, '0.888888888889');
    expect(gbpToEur!.rate, '1.125');
    expect(eurToUsd!.rate, '1.11111111111');
    expect(usdToEur!.rate, '0.9');
    expect(eurToGbp.source, FxRateSource.market);
    expect(eurToGbp.rateDate, date);
    expect(eurToGbp.fetchedAt, date.add(const Duration(hours: 2)));
  });

  test(
    'JPY and KWD convert with their real exponents and signed rounding',
    () async {
      configureProvider();
      final date = DateTime.utc(2026, 3, 9);
      await seedUsd(date);
      await seed('JPY', date, '150');
      await seed('KWD', date, '0.307');

      final jpyToKwd = await FxService.rateOn(session, 'JPY', 'KWD', date);
      final kwdToJpy = await FxService.rateOn(session, 'KWD', 'JPY', date);

      expect(jpyToKwd!.rate, '0.00204666666667');
      expect(kwdToJpy!.rate, '488.599348534');
      expect(
        convertMinorUnits(
          amountMinor: 100000,
          exchangeRate: ExactDecimal.tryParse(jpyToKwd.rate)!,
          transactionExponent: 0,
          functionalExponent: 3,
        ),
        204667,
      );
      expect(
        convertMinorUnits(
          amountMinor: 500,
          exchangeRate: ExactDecimal.tryParse(kwdToJpy.rate)!,
          transactionExponent: 3,
          functionalExponent: 0,
        ),
        244,
      );
    },
  );

  test('negative conversions round half up away from zero', () async {
    configureProvider();
    final date = DateTime.utc(2026, 3, 9);
    await seedUsd(date);
    await seed('GBP', date, '0.8');
    await seed('JPY', date, '0.5');

    final usdToGbp = await FxService.rateOn(session, 'USD', 'GBP', date);
    final usdToJpy = await FxService.rateOn(session, 'USD', 'JPY', date);

    expect(
      convertMinorUnits(
        amountMinor: -3333,
        exchangeRate: ExactDecimal.tryParse(usdToGbp!.rate)!,
        transactionExponent: 2,
        functionalExponent: 2,
      ),
      -2666,
    );
    expect(
      convertMinorUnits(
        amountMinor: -5,
        exchangeRate: ExactDecimal.tryParse(usdToJpy!.rate)!,
        transactionExponent: 0,
        functionalExponent: 0,
      ),
      -3,
    );
  });

  test(
    'uses the latest row on or before the asked date and reports it',
    () async {
      configureProvider();
      await seedUsd(DateTime.utc(2026, 2, 1));
      await seed('GBP', DateTime.utc(2026, 2, 1), '0.8');
      await seedUsd(DateTime.utc(2026, 2, 3));
      await seed('GBP', DateTime.utc(2026, 2, 3), '0.81');

      final early = await FxService.rateOn(
        session,
        'USD',
        'GBP',
        DateTime.utc(2026, 2, 2),
      );
      final later = await FxService.rateOn(
        session,
        'USD',
        'GBP',
        DateTime.utc(2026, 2, 4),
      );

      expect(early!.rate, '0.8');
      expect(early.rateDate, DateTime.utc(2026, 2, 1));
      expect(early.isStale, isFalse);
      expect(later!.rate, '0.81');
      expect(later.rateDate, DateTime.utc(2026, 2, 3));
      expect(later.isStale, isFalse);
    },
  );

  test(
    'the seven-day window is exclusive at the cutoff and requests backfill',
    () async {
      configureProvider();
      final rateDate = DateTime.utc(2026, 2, 1);
      await seedUsd(rateDate);
      await seed('GBP', rateDate, '0.8');

      final within = await FxService.rateOn(
        session,
        'USD',
        'GBP',
        DateTime.utc(2026, 2, 7),
      );
      final outside = await FxService.rateOn(
        session,
        'USD',
        'GBP',
        DateTime.utc(2026, 2, 8),
      );

      expect(within!.rate, '0.8');
      expect(outside, isNull);
      expect(backfillRequests, [DateTime.utc(2026, 2, 8)]);
    },
  );

  test(
    'stale means more than two days behind or a 48-hour-old today fetch',
    () async {
      configureProvider();
      final freshDate = DateTime.utc(2026, 3, 8);
      await seedUsd(freshDate);
      await seed('GBP', freshDate, '0.8');
      final fresh = await FxService.rateOn(
        session,
        'USD',
        'GBP',
        DateTime.utc(2026, 3, 10),
      );
      expect(fresh!.rateDate, freshDate);
      expect(fresh.isStale, isFalse);

      await server.clearRates();
      final staleDate = DateTime.utc(2026, 3, 7);
      await seedUsd(staleDate);
      await seed('GBP', staleDate, '0.8');
      final stale = await FxService.rateOn(
        session,
        'USD',
        'GBP',
        DateTime.utc(2026, 3, 10),
      );
      expect(stale!.rateDate, staleDate);
      expect(stale.isStale, isTrue);

      await server.clearRates();
      final today = DateTime.utc(2026, 3, 10);
      await seedUsd(
        today,
        fetchedAt: DateTime.utc(2026, 3, 8, 11, 59),
      );
      await seed(
        'GBP',
        today,
        '0.8',
        fetchedAt: DateTime.utc(2026, 3, 8, 11, 59),
      );
      final oldFetch = await FxService.rateOn(session, 'USD', 'GBP', today);
      expect(oldFetch!.isStale, isTrue);

      await server.clearRates();
      await seedUsd(
        today,
        fetchedAt: DateTime.utc(2026, 3, 8, 12, 1),
      );
      await seed(
        'GBP',
        today,
        '0.8',
        fetchedAt: DateTime.utc(2026, 3, 8, 12, 1),
      );
      final newFetch = await FxService.rateOn(session, 'USD', 'GBP', today);
      expect(newFetch!.isStale, isFalse);
    },
  );

  test('a missing side returns no quote and requests a backfill', () async {
    configureProvider();
    final date = DateTime.utc(2026, 3, 1);
    await seed('EUR', date, '0.9');

    final quote = await FxService.rateOn(session, 'EUR', 'JPY', date);

    expect(quote, isNull);
    expect(backfillRequests, [date]);
    expect(
      await FxRate.db.find(
        session,
        where: (table) => table.currencyCode.equals('JPY'),
      ),
      isEmpty,
    );
  });

  test(
    'backfill stores the provider history for the exact requested date',
    () async {
      final date = DateTime.utc(2026, 3, 1);
      provider = _FakeFxProviderClient(
        historical: {
          date: FxProviderResult(
            fetchedAt: DateTime.utc(2026, 3, 10, 9),
            rates: const {'USD': '1', 'EUR': '0.9', 'JPY': '150'},
          ),
        },
      );
      configureProvider();
      await seed('EUR', date, '0.9');

      await FxService.backfill(session, date);
      final quote = await FxService.rateOn(session, 'EUR', 'JPY', date);

      expect(provider.historicalCalls, [date]);
      expect(quote, isNotNull);
      expect(quote!.rate, '166.666666667');
      expect(quote.rateDate, date);
    },
  );

  test(
    'a failed historical fetch writes nothing and surfaces the error',
    () async {
      final date = DateTime.utc(2026, 3, 1);
      provider = _FakeFxProviderClient(
        historicalError: ValidationException(message: 'upstream unavailable'),
      );
      configureProvider();

      await expectLater(
        FxService.backfill(session, date),
        throwsA(
          isA<ValidationException>().having(
            (error) => error.message,
            'message',
            contains('upstream unavailable'),
          ),
        ),
      );
      expect(
        await FxRate.db.count(
          session,
          where: (table) => table.rateDate.equals(date),
        ),
        0,
      );
    },
  );

  test(
    'backfill never fabricates a rate when the provider has none',
    () async {
      final date = DateTime.utc(2026, 3, 1);
      provider = _FakeFxProviderClient(
        historical: {
          date: FxProviderResult(
            fetchedAt: DateTime.utc(2026, 3, 10, 9),
            rates: const {'USD': '1', 'JPY': '0', 'EUR': 'not-a-rate'},
          ),
        },
      );
      configureProvider();

      await FxService.backfill(session, date);

      expect(
        await FxRate.db.count(
          session,
          where: (table) => table.rateDate.equals(date),
        ),
        0,
      );
    },
  );

  test(
    'malformed provider rates are skipped and never stored as zero',
    () async {
      provider = _FakeFxProviderClient(
        latest: (_) => FxProviderResult(
          fetchedAt: _now,
          rates: const {
            'USD': '1',
            'EUR': '0',
            'GBP': '-1',
            'JPY': 'NaN',
            'KWD': '0.0000001',
            'CHF': '1.1',
          },
        ),
      );
      configureProvider();

      final snapshot = await FxService.refreshNow(session);

      final rows = await FxRate.db.find(
        session,
        where: (table) => table.rateDate.equals(DateTime.utc(2026, 3, 10)),
        orderBy: (table) => table.currencyCode,
      );
      expect(
        rows.map((row) => row.currencyCode),
        ['CHF', 'KWD', 'USD'],
      );
      expect(
        rows.every((row) => ExactDecimal.tryParse(row.rate) != null),
        isTrue,
      );
      expect(
        snapshot.rates.map((quote) => quote.currencyCode),
        ['CHF', 'KWD', 'USD'],
      );
    },
  );

  test('refresh upserts one row per currency per day', () async {
    provider = _FakeFxProviderClient(
      latest: (call) => FxProviderResult(
        fetchedAt: call == 1
            ? DateTime.utc(2026, 3, 10, 10)
            : DateTime.utc(2026, 3, 10, 11),
        rates: {'USD': '1', 'EUR': call == 1 ? '0.9' : '0.91'},
      ),
    );
    configureProvider();

    await FxService.refreshNow(session);
    await FxService.refreshNow(session);

    final rows = await FxRate.db.find(
      session,
      where: (table) => table.rateDate.equals(DateTime.utc(2026, 3, 10)),
      orderBy: (table) => table.currencyCode,
    );
    expect(rows, hasLength(2));
    final eur = rows.singleWhere((row) => row.currencyCode == 'EUR');
    expect(eur.rate, '0.91');
    expect(eur.fetchedAt, DateTime.utc(2026, 3, 10, 11));
  });

  test('quotes are cached for the from/to/date key', () async {
    configureProvider();
    final date = DateTime.utc(2026, 3, 9);
    await seedUsd(date);
    await seed('EUR', date, '0.9');

    final first = await FxService.rateOn(session, 'EUR', 'USD', date);
    await FxRate.db.deleteWhere(
      session,
      where: (table) => table.currencyCode.equals('EUR'),
    );
    final second = await FxService.rateOn(session, 'EUR', 'USD', date);

    expect(first!.rate, '1.11111111111');
    expect(second!.rate, first.rate);
  });

  test('unsupported currencies and non-civil dates are rejected', () async {
    configureProvider();
    final date = DateTime.utc(2026, 3, 9);

    await expectLater(
      FxService.rateOn(session, 'ZZZ', 'USD', date),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      FxService.rateOn(session, 'USD', 'GBP', DateTime.utc(2026, 3, 9, 12)),
      throwsA(isA<ValidationException>()),
    );
  });

  test('latest is a stale USD-only snapshot before any rate exists', () async {
    configureProvider();

    final latest = await FxService.latest(session);

    expect(latest.baseCurrencyCode, 'USD');
    expect(latest.rateDate, DateTime.utc(2026, 3, 10));
    expect(latest.isStale, isTrue);
    expect(latest.rates.map((quote) => quote.currencyCode), ['USD']);
    expect(latest.rates.single.rate, '1');
  });

  test('latest serves the newest daily set and flags old data', () async {
    configureProvider();
    final oldDate = DateTime.utc(2026, 3, 1);
    await seedUsd(oldDate);
    await seed('EUR', oldDate, '0.9');

    final latest = await FxService.latest(session);

    expect(latest.rateDate, oldDate);
    expect(latest.isStale, isTrue);
    expect(
      latest.rates.map((quote) => quote.currencyCode),
      ['EUR', 'USD'],
    );
  });

  test(
    'refresh future call skips without credentials and persists with them',
    () async {
      FxService.configure(
        apiKey: null,
        baseUrl: null,
        providerClient: provider,
        clock: () => _now,
      );
      await FxRefreshFutureCall().refresh(session);
      expect(provider.latestCalls, 0);

      provider = _FakeFxProviderClient(
        latest: (_) => FxProviderResult(
          fetchedAt: _now,
          rates: const {'USD': '1', 'EUR': '0.9'},
        ),
      );
      configureProvider();
      await FxRefreshFutureCall().refresh(session);

      expect(provider.latestCalls, 1);
      expect(
        await FxRate.db.count(
          session,
          where: (table) => table.rateDate.equals(DateTime.utc(2026, 3, 10)),
        ),
        2,
      );
    },
  );

  test('backfill future call stores the requested day', () async {
    final date = DateTime.utc(2026, 3, 1);
    provider = _FakeFxProviderClient(
      historical: {
        date: FxProviderResult(
          fetchedAt: DateTime.utc(2026, 3, 10, 9),
          rates: const {'USD': '1', 'GBP': '0.8'},
        ),
      },
    );
    configureProvider();

    await FxBackfillFutureCall().fetch(session, date);

    expect(provider.historicalCalls, [date]);
    expect(
      await FxRate.db.count(
        session,
        where: (table) => table.rateDate.equals(date),
      ),
      2,
    );
  });

  test(
    'endpoint refreshes, returns latest and quotes through the service',
    () async {
      provider = _FakeFxProviderClient(
        latest: (_) => FxProviderResult(
          fetchedAt: _now,
          rates: const {'USD': '1', 'EUR': '0.9', 'GBP': '0.8'},
        ),
      );
      configureProvider();
      final endpoint = FxRateEndpoint();

      expect(endpoint.requireLogin, isTrue);
      final refreshed = await endpoint.refresh(session);
      final latest = await endpoint.latest(session);
      final quote = await endpoint.quote(
        session,
        'GBP',
        'EUR',
        DateTime.utc(2026, 3, 10),
      );

      expect(refreshed.rates, hasLength(3));
      expect(latest.rateDate, DateTime.utc(2026, 3, 10));
      expect(quote.rate, '1.125');
      expect(quote.source, FxRateSource.market);
    },
  );

  test(
    'endpoint quote throws FxRateUnavailableException when no rate exists',
    () async {
      configureProvider();
      final endpoint = FxRateEndpoint();
      final date = DateTime.utc(2026, 3, 1);

      await expectLater(
        endpoint.quote(session, 'EUR', 'JPY', date),
        throwsA(
          isA<FxRateUnavailableException>()
              .having((error) => error.fromCurrencyCode, 'from', 'EUR')
              .having((error) => error.toCurrencyCode, 'to', 'JPY')
              .having((error) => error.date, 'date', date),
        ),
      );
      expect(backfillRequests, [date]);
    },
  );
}
