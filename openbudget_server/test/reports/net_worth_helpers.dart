// Calendar dates are naturally written with their day component.
//
// The reports tests intentionally read dates with their day component.

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_balance_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:serverpod/serverpod.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

/// One owned book plus the fact writers net worth tests need.
class NetWorthFixture {
  NetWorthFixture({required this.server, required this.book});

  final PgTestServer server;
  final BudgetTestBook book;

  Session get session => book.session;
  Entity get entity => book.entity;

  /// A fresh owned entity with net worth flags exposed.
  Future<Entity> addEntity({
    String name = 'Second book',
    String baseCurrencyCode = 'USD',
    EntityKind kind = EntityKind.individual,
    bool includeInNetWorth = true,
    DateTime? archivedAt,
    String timeZone = 'Europe/London',
    int sortOrder = 0,
  }) => Entity.db.insertRow(
    session,
    Entity(
      id: const Uuid().v7obj(),
      ownerId: book.userId,
      name: name,
      kind: kind,
      countryCode: 'US',
      baseCurrencyCode: baseCurrencyCode,
      timeZone: timeZone,
      fiscalYearEndMonth: 12,
      fiscalYearEndDay: 31,
      includeInNetWorth: includeInNetWorth,
      sortOrder: sortOrder,
      archivedAt: archivedAt,
    ),
  );

  /// An entity owned by a different auth user.
  Future<Entity> addForeignEntity({
    String name = 'Someone else',
    String baseCurrencyCode = 'USD',
  }) async {
    final ownerId = await server.insertAuthUser();
    return Entity.db.insertRow(
      session,
      Entity(
        id: const Uuid().v7obj(),
        ownerId: ownerId,
        name: name,
        kind: EntityKind.individual,
        countryCode: 'US',
        baseCurrencyCode: baseCurrencyCode,
        timeZone: 'Europe/London',
        fiscalYearEndMonth: 12,
        fiscalYearEndDay: 31,
      ),
    );
  }

  /// A transaction header and its cached balance movement.
  Future<model.Transaction> addTransaction({
    required Account account,
    required DateTime date,
    required int amountMinor,
    TransactionKind kind = TransactionKind.standard,
    String description = 'Seeded',
    String? externalId,
  }) async {
    final transaction = model.Transaction(
      id: const Uuid().v7obj(),
      entityId: account.entityId,
      accountId: account.id!,
      date: date,
      amountMinor: amountMinor,
      baseAmountMinor: amountMinor,
      fxRate: '1',
      fxRateDate: date,
      fxRateSource: FxRateSource.identity,
      kind: kind,
      description: description,
      externalId: externalId,
    );
    await session.db.transaction((tx) async {
      await model.Transaction.db.insertRow(
        session,
        transaction,
        transaction: tx,
      );
      await AccountBalanceService.applyDelta(
        session,
        account.id!,
        amountMinor,
        transaction: tx,
      );
    });
    return transaction;
  }

  /// Inserts or corrects one valuation and refreshes its cached balance.
  Future<AccountValuation> setValuation({
    required Account account,
    required DateTime date,
    required int valueMinor,
  }) => session.db.transaction((tx) async {
    final existing = await AccountValuation.db.findFirstRow(
      session,
      where: (table) =>
          table.accountId.equals(account.id) & table.valuationDate.equals(date),
      transaction: tx,
    );
    final valuation = existing == null
        ? await AccountValuation.db.insertRow(
            session,
            AccountValuation(
              accountId: account.id!,
              valuationDate: date,
              valueMinor: valueMinor,
              source: ValuationSource.manual,
            ),
            transaction: tx,
          )
        : await AccountValuation.db.updateRow(
            session,
            existing.copyWith(
              valueMinor: valueMinor,
              updatedAt: DateTime.now().toUtc(),
            ),
            transaction: tx,
          );
    await AccountBalanceService.refreshValuation(
      session,
      account.id!,
      transaction: tx,
    );
    return valuation;
  });

  /// Stores one USD-based daily rate with an optional fetch time.
  Future<void> seedRate({
    required String currencyCode,
    required DateTime rateDate,
    required String rate,
    DateTime? fetchedAt,
  }) => FxRate.db.upsert(
    session,
    [
      FxRate(
        rateDate: rateDate,
        currencyCode: currencyCode,
        rate: rate,
        provider: FxProvider.currencyapi,
        fetchedAt: fetchedAt ?? rateDate.add(const Duration(hours: 2)),
      ),
    ],
    conflictColumns: (table) => [table.currencyCode, table.rateDate],
    updateColumns: (table) => [table.rate, table.provider, table.fetchedAt],
  );

  /// Stores USD plus the non-USD legs in [rates] for one date.
  Future<void> seedRates(
    DateTime date,
    Map<String, String> rates, {
    DateTime? fetchedAt,
  }) async {
    await seedRate(
      currencyCode: 'USD',
      rateDate: date,
      rate: '1',
      fetchedAt: fetchedAt,
    );
    for (final entry in rates.entries) {
      await seedRate(
        currencyCode: entry.key,
        rateDate: date,
        rate: entry.value,
        fetchedAt: fetchedAt,
      );
    }
  }

  /// Deletes a transaction without touching the cached balance.
  ///
  /// History tests use this to prove a later read follows a deleted fact; no
  /// current-balance assertion runs on the same book afterwards.
  Future<void> deleteTransaction(UuidValue id) => session.db.unsafeExecute(
    'DELETE FROM "transaction" WHERE id = @id::uuid',
    parameters: QueryParameters.named({'id': id.toString()}),
  );

  /// Changes a transaction amount without touching the cached balance.
  Future<void> updateTransactionAmount(UuidValue id, int amountMinor) =>
      session.db.unsafeExecute(
        'UPDATE "transaction" SET "amountMinor" = @amount '
        'WHERE id = @id::uuid',
        parameters: QueryParameters.named({
          'id': id.toString(),
          'amount': amountMinor,
        }),
      );
}
