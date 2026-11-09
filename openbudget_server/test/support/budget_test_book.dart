import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/generated/transactions/transaction.dart'
    as model;
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

/// One owned entity with the rows a transaction writer test needs.
class BudgetTestBook {
  BudgetTestBook._(this.session, this.userId, this.entity);

  final Session session;
  final UuidValue userId;
  final Entity entity;

  /// Creates an auth user, an authenticated session and an owned entity.
  static Future<BudgetTestBook> create(
    Session session, {
    String baseCurrencyCode = 'GBP',
    String countryCode = 'GB',
    EntityKind kind = EntityKind.individual,
    AccountingMode accountingMode = AccountingMode.envelope,
    String timeZone = 'Europe/London',
  }) async {
    final userId = const Uuid().v7obj();
    await session.db.unsafeExecute(
      'INSERT INTO serverpod_auth_core_user '
      '(id, "createdAt", "scopeNames", blocked) '
      "VALUES (@id::uuid, now(), '[]'::json, false)",
      parameters: QueryParameters.named({'id': userId.toString()}),
    );
    session.updateAuthenticated(
      AuthenticationInfo(
        userId.toString(),
        const {},
        authId: 'test-auth-$userId',
      ),
    );
    final entity = await Entity.db.insertRow(
      session,
      Entity(
        id: const Uuid().v7obj(),
        ownerId: userId,
        name: 'Test book',
        kind: kind,
        countryCode: countryCode,
        baseCurrencyCode: baseCurrencyCode,
        timeZone: timeZone,
        accountingMode: accountingMode,
        fiscalYearEndMonth: 4,
        fiscalYearEndDay: 5,
      ),
    );
    return BudgetTestBook._(session, userId, entity);
  }

  /// Creates an account in this entity.
  Future<Account> addAccount({
    String name = 'Checking',
    AccountKind kind = AccountKind.checking,
    String? currencyCode,
    AccountBalanceSource balanceSource = AccountBalanceSource.transactions,
    bool onBudget = true,
    int balanceMinor = 0,
    DateTime? closedAt,
    UuidValue? ledgerAccountId,
  }) => Account.db.insertRow(
    session,
    Account(
      id: const Uuid().v7obj(),
      entityId: entity.id!,
      name: name,
      kind: kind,
      currencyCode: currencyCode ?? entity.baseCurrencyCode,
      balanceSource: balanceSource,
      balanceMinor: balanceMinor,
      onBudget: onBudget,
      closedAt: closedAt,
      ledgerAccountId: ledgerAccountId,
    ),
  );

  /// Creates a category and an envelope in this entity.
  Future<Envelope> addEnvelope({String name = 'Groceries'}) async {
    final category = await Category.db.insertRow(
      session,
      Category(
        id: const Uuid().v7obj(),
        entityId: entity.id!,
        name: '$name category',
      ),
    );
    return Envelope.db.insertRow(
      session,
      Envelope(
        id: const Uuid().v7obj(),
        entityId: entity.id!,
        categoryId: category.id!,
        name: name,
      ),
    );
  }

  /// Creates a ledger account in this entity's books.
  Future<LedgerAccount> addLedgerAccount({
    String code = '6100',
    String name = 'Office costs',
    LedgerAccountType type = LedgerAccountType.expense,
    DateTime? archivedAt,
  }) => LedgerAccount.db.insertRow(
    session,
    LedgerAccount(
      id: const Uuid().v7obj(),
      entityId: entity.id!,
      code: code,
      name: name,
      type: type,
      archivedAt: archivedAt,
    ),
  );

  /// Creates a payee in this entity.
  Future<Payee> addPayee({String name = 'Corner shop'}) => Payee.db.insertRow(
    session,
    Payee(id: const Uuid().v7obj(), entityId: entity.id!, name: name),
  );

  /// Assigns an envelope to a payee for outflow rules.
  Future<TransactionRule> addRule({
    required Payee payee,
    required Envelope envelope,
    bool enabled = true,
  }) => TransactionRule.db.insertRow(
    session,
    TransactionRule(
      id: const Uuid().v7obj(),
      entityId: entity.id!,
      payeeId: payee.id!,
      envelopeId: envelope.id!,
      enabled: enabled,
    ),
  );

  /// Locks this entity's books on or before [lockDate].
  Future<LedgerPeriodLock> addPeriodLock(DateTime lockDate) =>
      LedgerPeriodLock.db.insertRow(
        session,
        LedgerPeriodLock(
          id: const Uuid().v7obj(),
          entityId: entity.id!,
          lockDate: lockDate,
          setBy: userId,
        ),
      );

  /// Stores one USD-based daily rate.
  Future<void> seedRate({
    required String currencyCode,
    required DateTime rateDate,
    required String rate,
  }) async {
    await FxRate.db.upsert(
      session,
      [
        FxRate(
          rateDate: rateDate,
          currencyCode: currencyCode,
          rate: rate,
          provider: FxProvider.currencyapi,
          fetchedAt: rateDate.add(const Duration(hours: 2)),
        ),
      ],
      conflictColumns: (t) => [t.currencyCode, t.rateDate],
      updateColumns: (t) => [t.rate, t.provider, t.fetchedAt],
    );
  }

  /// Stores both USD legs needed for [fromCurrencyCode] to [toCurrencyCode] market conversion.
  Future<void> seedMarketRate({
    required String fromCurrencyCode,
    required String toCurrencyCode,
    required DateTime rateDate,
    required String fromPerUsd,
    required String toPerUsd,
  }) async {
    await seedRate(
      currencyCode: 'USD',
      rateDate: rateDate,
      rate: '1',
    );
    if (fromCurrencyCode != 'USD') {
      await seedRate(
        currencyCode: fromCurrencyCode,
        rateDate: rateDate,
        rate: fromPerUsd,
      );
    }
    if (toCurrencyCode != 'USD') {
      await seedRate(
        currencyCode: toCurrencyCode,
        rateDate: rateDate,
        rate: toPerUsd,
      );
    }
  }

  /// A fresh row for [account], including the cached balance.
  Future<Account> reload(Account account) async {
    final row = await Account.db.findById(session, account.id!);
    if (row == null) throw StateError('Account disappeared');
    return row;
  }

  /// The stored cached balance for [account].
  Future<int> cachedBalanceMinor(Account account) async =>
      (await reload(account)).balanceMinor;

  /// The balance recomputed from persisted transactions.
  Future<int> recomputedBalanceMinor(Account account) async {
    final rows = await session.db.unsafeQuery(
      'SELECT COALESCE(SUM("amountMinor"), 0)::bigint '
      'FROM "transaction" WHERE "accountId" = @id::uuid',
      parameters: QueryParameters.named({'id': account.id!.toString()}),
    );
    return rows.first.first as int;
  }

  /// Number of persisted transaction headers.
  Future<int> transactionCount() async {
    final rows = await session.db.unsafeQuery(
      'SELECT count(*)::bigint FROM "transaction"',
    );
    return rows.first.first as int;
  }

  /// Number of persisted lines for one transaction.
  Future<int> lineCount(UuidValue transactionId) async {
    final rows = await session.db.unsafeQuery(
      'SELECT count(*)::bigint FROM transaction_line '
      'WHERE "transactionId" = @id::uuid',
      parameters: QueryParameters.named({'id': transactionId.toString()}),
    );
    return rows.first.first as int;
  }

  /// Loads the persisted header, or null.
  Future<model.Transaction?> transaction(UuidValue id) =>
      model.Transaction.db.findById(session, id);

  /// Asserts the section 6.2 verification query finds no drift.
  Future<void> expectBalancesConsistent() async {
    final rows = await session.db.unsafeQuery('''
SELECT a.id::text
FROM account a
JOIN LATERAL (
  SELECT CASE a."balanceSource"
    WHEN 'transactions' THEN
      (SELECT COALESCE(SUM(t."amountMinor"), 0) FROM "transaction" t WHERE t."accountId" = a.id)
    ELSE
      COALESCE((SELECT v."valueMinor" FROM account_valuation v
        WHERE v."accountId" = a.id ORDER BY v."valuationDate" DESC LIMIT 1), 0)
  END AS actual
) s ON true
WHERE a."balanceMinor" <> s.actual''');
    expect(rows, isEmpty, reason: 'cached balances must match persisted facts');
  }
}
