// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/reports/report_endpoint.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';
import 'net_worth_helpers.dart';

final _now = DateTime.utc(2026, 6, 15, 12);
final _today = DateTime.utc(2026, 6, 15);

void main() {
  late PgTestServer server;
  late NetWorthFixture fixture;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    FxService.configure(
      apiKey: null,
      baseUrl: null,
      clock: () => _now,
      backfillScheduler: (_, _) async {},
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
  });

  tearDown(FxService.resetForTests);

  test(
    'given the report endpoint when the only two report methods run then each '
    'returns the service contract',
    () async {
      final account = await fixture.book.addAccount(
        name: 'Checking',
        balanceMinor: 0,
      );
      await fixture.addTransaction(
        account: account,
        date: _today,
        amountMinor: 1000,
      );
      await fixture.seedRates(_today, {'EUR': '0.9'});
      final endpoint = ReportEndpoint();

      final view = await endpoint.netWorth(
        fixture.session,
        currencyCode: 'USD',
        asOf: _today,
      );
      expect(view.netWorthMinor, 1000);
      expect(view.accounts.single.accountId, account.id);

      final history = await endpoint.netWorthHistory(
        fixture.session,
        _today,
        _today,
        NetWorthGranularity.day,
        currencyCode: 'USD',
      );
      expect(history.points.single.netWorthMinor, 1000);
    },
  );

  test(
    'given no login when the report endpoint runs then it is rejected',
    () async {
      await expectLater(
        ReportEndpoint().netWorth(
          server.anonymousSession(),
          entityIds: const [],
          currencyCode: 'USD',
        ),
        throwsA(isA<AuthenticationRequiredException>()),
      );
    },
  );
}
