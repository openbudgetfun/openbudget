// Calendar dates are naturally written with their day component.

import 'package:openbudget_server/src/entities/entity_realtime_notifier.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/reports/report_endpoint.dart';
import 'package:openbudget_server/src/reports/report_service.dart';
import 'package:openbudget_server/src/transactions/transaction_writer.dart';
import 'package:test/test.dart';

import '../budget/budget_helpers.dart';
import '../support/pg_test_server.dart';
import 'net_worth_helpers.dart';

final _today = DateTime.utc(2026, 6, 15);

void main() {
  late PgTestServer server;
  late BudgetFixture fixture;
  late NetWorthFixture netWorth;
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
      clock: () => DateTime.utc(2026, 6, 15, 12),
      backfillScheduler: (_, _) async {},
    );
    TransactionWriter.debugPublisher = (
      session,
      entityId,
      scope, {
      month,
      accountId,
    }) async {};
    EntityRealtimeNotifier.debugPublisher = (
      session,
      entityId,
      scope, {
      month,
      accountId,
    }) async {};
    fixture = await BudgetFixture.create(
      server.anonymousSession(),
      baseCurrencyCode: 'USD',
    );
    netWorth = NetWorthFixture(server: server, book: fixture.book);
  });

  tearDown(() {
    FxService.resetForTests();
    TransactionWriter.resetForTests();
    EntityRealtimeNotifier.resetForTests();
  });

  Future<({Entity entity, Account account, Envelope envelope})> addBook(
    String name,
  ) async {
    final entity = await fixture.book.addEntity(
      name: name,
      baseCurrencyCode: 'USD',
    );
    final account = await fixture.book.addAccount(
      name: '$name checking',
      entity: entity,
    );
    final envelope = await fixture.book.addEnvelope(
      name: '$name envelope',
      entity: entity,
    );
    return (entity: entity, account: account, envelope: envelope);
  }

  Future<void> income(Account account, int amountMinor, DateTime date) =>
      TransactionWriter.create(
        fixture.session,
        TransactionInput(
          accountId: account.id!,
          date: date,
          amountMinor: amountMinor,
          description: 'Income',
          lines: const [],
        ),
      );

  Future<void> spend(
    Account account,
    Envelope envelope,
    int amountMinor,
    DateTime date,
  ) => TransactionWriter.create(
    fixture.session,
    TransactionInput(
      accountId: account.id!,
      date: date,
      amountMinor: -amountMinor,
      description: 'Spend',
      lines: [
        TransactionLineInput(
          amountMinor: -amountMinor,
          envelopeId: envelope.id,
        ),
      ],
    ),
  );

  test(
    'given no outflows when age of money runs then it returns null',
    () async {
      final book = await addBook('No outflows');
      await income(
        book.account,
        1000,
        _today.subtract(const Duration(days: 10)),
      );

      expect(
        await ReportService.ageOfMoney(fixture.session, book.entity.id!),
        isNull,
      );
    },
  );

  test(
    'given one inflow followed by outflows when age of money runs then it '
    'averages the FIFO ages',
    () async {
      final book = await addBook('FIFO');
      await income(
        book.account,
        1000,
        _today.subtract(const Duration(days: 10)),
      );
      await spend(
        book.account,
        book.envelope,
        400,
        _today.subtract(const Duration(days: 5)),
      );
      await spend(
        book.account,
        book.envelope,
        600,
        _today.subtract(const Duration(days: 2)),
      );

      expect(
        await ReportService.ageOfMoney(fixture.session, book.entity.id!),
        7,
      );
      expect(
        await ReportEndpoint().ageOfMoney(fixture.session, book.entity.id!),
        7,
      );
    },
  );

  test(
    'given a split outflow when age of money runs then its lines are counted '
    'once',
    () async {
      final book = await addBook('Split');
      await income(
        book.account,
        1000,
        _today.subtract(const Duration(days: 20)),
      );
      await TransactionWriter.create(
        fixture.session,
        TransactionInput(
          accountId: book.account.id!,
          date: _today.subtract(const Duration(days: 10)),
          amountMinor: -700,
          description: 'Split',
          lines: [
            TransactionLineInput(
              amountMinor: -300,
              envelopeId: book.envelope.id,
            ),
            TransactionLineInput(
              amountMinor: -400,
              envelopeId: book.envelope.id,
            ),
          ],
        ),
      );
      await spend(
        book.account,
        book.envelope,
        300,
        _today.subtract(const Duration(days: 5)),
      );

      expect(
        await ReportService.ageOfMoney(fixture.session, book.entity.id!),
        12,
      );
    },
  );

  test(
    'given an inflow outside the 365-day window when age of money runs then '
    'it is ignored until a recent inflow exists',
    () async {
      final book = await addBook('Cutoff');
      await income(
        book.account,
        1000,
        _today.subtract(const Duration(days: 366)),
      );
      await spend(book.account, book.envelope, 500, _today);

      expect(
        await ReportService.ageOfMoney(fixture.session, book.entity.id!),
        isNull,
      );

      await income(
        book.account,
        1000,
        _today.subtract(const Duration(days: 300)),
      );
      expect(
        await ReportService.ageOfMoney(fixture.session, book.entity.id!),
        300,
      );
    },
  );

  test(
    'given an inflow exactly 365 days old when age of money runs then it stays '
    'inside the window',
    () async {
      final book = await addBook('Boundary');
      await income(
        book.account,
        100,
        _today.subtract(const Duration(days: 365)),
      );
      await spend(book.account, book.envelope, 100, _today);

      expect(
        await ReportService.ageOfMoney(fixture.session, book.entity.id!),
        365,
      );
    },
  );

  test(
    'given an internal transfer when age of money runs then the peer inflow is '
    'not matched',
    () async {
      final book = await addBook('Transfer');
      final savings = await fixture.book.addAccount(
        name: 'Transfer savings',
        entity: book.entity,
      );
      await income(
        book.account,
        500,
        _today.subtract(const Duration(days: 20)),
      );
      await TransactionWriter.createTransfer(
        fixture.session,
        TransferInput(
          fromAccountId: book.account.id!,
          toAccountId: savings.id!,
          date: _today.subtract(const Duration(days: 10)),
          fromAmountMinor: 500,
        ),
      );
      await spend(book.account, book.envelope, 1000, _today);

      expect(
        await ReportService.ageOfMoney(fixture.session, book.entity.id!),
        20,
      );
    },
  );

  test(
    'given more than ten outflows when age of money runs then only the last '
    'ten outflows money is averaged',
    () async {
      final book = await addBook('Last ten');
      await income(
        book.account,
        1000,
        _today.subtract(const Duration(days: 30)),
      );
      for (var daysAgo = 11; daysAgo >= 0; daysAgo--) {
        await spend(
          book.account,
          book.envelope,
          50,
          _today.subtract(Duration(days: daysAgo)),
        );
      }

      expect(
        await ReportService.ageOfMoney(fixture.session, book.entity.id!),
        26,
      );
    },
  );

  test(
    'given another user entity when age of money runs then it is refused',
    () async {
      final foreign = await netWorth.addForeignEntity();

      await expectLater(
        ReportService.ageOfMoney(fixture.session, foreign.id!),
        throwsA(isA<ForbiddenException>()),
      );
    },
  );
}
