// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_print

@Tags(['benchmark'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart' show AccountKind;
import 'package:openbudget_server/src/accounts/account_endpoint.dart';
import 'package:openbudget_server/src/budget/budget_endpoint.dart';
import 'package:openbudget_server/src/categories/category_endpoint.dart';
import 'package:openbudget_server/src/entities/entity_endpoint.dart';
import 'package:openbudget_server/src/envelopes/envelope_endpoint.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/reports/report_endpoint.dart';
import 'package:openbudget_server/src/transactions/transaction_endpoint.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../budget/budget_helpers.dart';
import '../support/pg_test_server.dart';

/// The reads the app makes when it opens a book, timed against a household
/// book with two years of history.
///
/// Each call is measured the way the API server answers it: the time the
/// endpoint method takes, the statements it sends to PostgreSQL, and the
/// size of the JSON body before and after gzip. Run it on purpose:
///
/// ```sh
/// dart test --run-skipped -t benchmark test/benchmark/api_read_benchmark_test.dart
/// ```
///
/// Set `OPENBUDGET_BENCH_OUT` to a file path to also write the results as
/// JSON. `docs/performance.md` records the numbers and how to compare them.
void main() {
  late PgTestServer server;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start(trackStatements: true);
    serverStarted = true;
    await server.anonymousSession().db.unsafeExecute(
      'CREATE EXTENSION IF NOT EXISTS pg_stat_statements',
    );
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  test('household book reads', () async {
    final book = await _HouseholdBook.seed(server.anonymousSession());
    final session = book.fixture.session;
    final entityId = book.fixture.entityId;
    const month = 202611;

    final calls = <String, Future<Object?> Function()>{
      'entity.listSummaries': () => EntityEndpoint().listSummaries(session),
      'entity.list': () => EntityEndpoint().list(session),
      'budget.getMonth': () =>
          BudgetEndpoint().getMonth(session, entityId, month),
      'transaction.list (first page)': () => TransactionEndpoint().list(
        session,
        TransactionQuery(entityId: entityId),
      ),
      'account.list': () => AccountEndpoint().list(session, entityId),
      'category.list': () => CategoryEndpoint().list(session, entityId),
      'envelope.list': () => EnvelopeEndpoint().list(session, entityId),
      'report.ageOfMoney': () => ReportEndpoint().ageOfMoney(session, entityId),
    };

    final results = <Map<String, Object?>>[];
    for (final MapEntry(key: name, value: call) in calls.entries) {
      results.add(await _measure(session, name, call));
    }

    final report = const JsonEncoder.withIndent('  ').convert({
      'book': book.describe(),
      'calls': results,
    });
    print(report);
    final out = Platform.environment['OPENBUDGET_BENCH_OUT'];
    if (out != null && out.isNotEmpty) File(out).writeAsStringSync(report);
  });
}

const _warmups = 3;
const _runs = 25;

Future<Map<String, Object?>> _measure(
  Session session,
  String name,
  Future<Object?> Function() call,
) async {
  for (var i = 0; i < _warmups; i++) {
    await call();
  }

  await session.db.unsafeQuery('SELECT pg_stat_statements_reset()');
  final micros = <int>[];
  Object? result;
  for (var i = 0; i < _runs; i++) {
    final stopwatch = Stopwatch()..start();
    result = await call();
    stopwatch.stop();
    micros.add(stopwatch.elapsedMicroseconds);
  }
  final statementRows = await session.db.unsafeQuery(
    'SELECT coalesce(sum(calls), 0)::bigint FROM pg_stat_statements '
    "WHERE query NOT ILIKE '%pg_stat_statements%'",
  );
  final statements = (statementRows.single.single! as int) / _runs;

  // The API server answers with exactly this encoding.
  final body = SerializationManager.encodeForProtocolToUtf8(result);
  micros.sort();
  double ms(int us) => (us / 100).round() / 10;
  return {
    'call': name,
    'p50Ms': ms(micros[micros.length ~/ 2]),
    'p95Ms': ms(micros[(micros.length * 95 ~/ 100).clamp(0, _runs - 1)]),
    'statements': statements,
    'jsonBytes': body.length,
    'gzipBytes': gzip.encode(body).length,
  };
}

/// One household: four accounts, eight categories of five envelopes, two
/// years of monthly plans and about 150 transactions a month.
class _HouseholdBook {
  _HouseholdBook(this.fixture, this.accounts, this.transactionCount);

  final BudgetFixture fixture;
  final List<Account> accounts;
  final int transactionCount;

  static const _categories = 8;
  static const _envelopesPerCategory = 5;
  static const _months = 24;
  static const _transactionsPerMonth = 150;

  static Future<_HouseholdBook> seed(Session session) async {
    final fixture = await BudgetFixture.create(session, envelopeCount: 0);
    final book = fixture.book;
    final accounts = [
      fixture.account,
      await book.addAccount(name: 'Savings', kind: AccountKind.savings),
      await book.addAccount(name: 'Card', kind: AccountKind.creditCard),
      await book.addAccount(name: 'Cash', kind: AccountKind.cash),
    ];

    final envelopes = <Envelope>[];
    for (var c = 0; c < _categories; c++) {
      final category = await Category.db.insertRow(
        session,
        Category(
          id: const Uuid().v7obj(),
          entityId: fixture.entityId,
          name: 'Category $c',
          sortOrder: c,
        ),
      );
      envelopes.addAll(
        await Envelope.db.insert(session, [
          for (var e = 0; e < _envelopesPerCategory; e++)
            Envelope(
              id: const Uuid().v7obj(),
              entityId: fixture.entityId,
              categoryId: category.id!,
              name: 'Envelope $c.$e',
              sortOrder: e,
            ),
        ]),
      );
    }
    fixture.envelopes.addAll(envelopes);

    var count = 0;
    final allocations = <MonthlyAllocation>[];
    for (var m = 0; m < _months; m++) {
      final year = 2024 + (m + 11) ~/ 12;
      final monthOfYear = (m + 11) % 12 + 1;
      final rows =
          <
            ({
              DateTime date,
              int amountMinor,
              int baseAmountMinor,
              UuidValue? envelopeId,
            })
          >[
            (
              date: DateTime.utc(year, monthOfYear, 1),
              amountMinor: 450000,
              baseAmountMinor: 450000,
              envelopeId: null,
            ),
          ];
      for (var t = 1; t < _transactionsPerMonth; t++) {
        final amount = -(500 + (t * 137) % 9000);
        rows.add((
          date: DateTime.utc(year, monthOfYear, 1 + t % 28),
          amountMinor: amount,
          baseAmountMinor: amount,
          envelopeId: envelopes[t % envelopes.length].id,
        ));
      }
      for (final account in accounts) {
        final share = [
          for (var i = 0; i < rows.length; i++)
            if (i % accounts.length == accounts.indexOf(account)) rows[i],
        ];
        await seedTransactionRows(
          session,
          entityId: fixture.entityId,
          accountId: account.id!,
          rows: share,
        );
      }
      count += rows.length;
      for (final envelope in envelopes) {
        allocations.add(
          MonthlyAllocation(
            entityId: fixture.entityId,
            envelopeId: envelope.id!,
            month: year * 100 + monthOfYear,
            allocatedMinor: 10000,
          ),
        );
      }
    }
    await MonthlyAllocation.db.insert(session, allocations);
    return _HouseholdBook(fixture, accounts, count);
  }

  Map<String, Object?> describe() => {
    'accounts': accounts.length,
    'envelopes': fixture.envelopes.length,
    'months': _months,
    'transactions': transactionCount,
  };
}
