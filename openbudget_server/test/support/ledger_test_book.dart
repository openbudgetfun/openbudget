import 'dart:convert';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_service.dart';
import 'package:openbudget_server/src/entities/entity_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/ledger/ledger_endpoint.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import 'pg_test_server.dart';

/// One owned entity with a fresh session and ledger endpoint helpers.
class LedgerTestBook {
  LedgerTestBook._({
    required this.server,
    required this.session,
    required this.userId,
    required this.entity,
    required this.baseCurrency,
  });

  final PgTestServer server;
  final Session session;
  final UuidValue userId;
  final Entity entity;
  final String baseCurrency;
  final LedgerEndpoint endpoint = LedgerEndpoint();

  /// Creates an auth user, an owned entity and one authenticated session.
  static Future<LedgerTestBook> create(
    PgTestServer server, {
    EntityKind kind = EntityKind.company,
    String countryCode = 'GB',
    String baseCurrencyCode = 'GBP',
    String name = 'Books',
  }) async {
    final userId = await server.insertAuthUser();
    final session = server.authenticatedSession(userId);
    final entity = await EntityService.create(
      session,
      name,
      kind,
      countryCode,
      baseCurrencyCode,
      'Europe/London',
    );
    return LedgerTestBook._(
      server: server,
      session: session,
      userId: userId,
      entity: entity,
      baseCurrency: baseCurrencyCode,
    );
  }

  /// Another authenticated session for the same user, for concurrency tests.
  Session newSession() {
    final created = server.authenticatedSession(userId);
    addTearDown(created.close);
    return created;
  }

  /// A second user's book, for cross-owner checks.
  static Future<LedgerTestBook> createStranger(PgTestServer server) =>
      create(server, name: 'Other books');

  Future<Entity> reloadEntity({Session? session}) async =>
      (await Entity.db.findById(session ?? this.session, entity.id!))!;

  Future<Account> addAccount({
    Session? session,
    String name = 'Checking',
    AccountKind kind = AccountKind.checking,
    String? currencyCode,
    AccountBalanceSource balanceSource = AccountBalanceSource.transactions,
    bool onBudget = true,
    int? openingBalanceMinor,
  }) => AccountService.create(
    session ?? this.session,
    entity.id!,
    name,
    kind,
    currencyCode ?? baseCurrency,
    balanceSource: balanceSource,
    onBudget: onBudget,
    openingBalanceMinor: openingBalanceMinor,
  );

  Future<Entity> enable({
    Session? session,
  }) => endpoint.enableLedger(session ?? this.session, entity.id!);

  Future<List<LedgerAccount>> chart({
    Session? session,
    bool includeArchived = false,
  }) => endpoint.listAccounts(
    session ?? this.session,
    entity.id!,
    includeArchived: includeArchived,
  );

  Future<Account> reloadAccount(
    UuidValue accountId, {
    Session? session,
  }) async => (await Account.db.findById(session ?? this.session, accountId))!;

  Future<LedgerAccount> reloadLedgerAccount(
    UuidValue ledgerAccountId, {
    Session? session,
  }) async => (await LedgerAccount.db.findById(
    session ?? this.session,
    ledgerAccountId,
  ))!;

  /// Loads the ledger account linked to a money account.
  Future<LedgerAccount> linkedAccount(Account account) async {
    final id = account.ledgerAccountId;
    if (id == null) {
      throw StateError('Account ${account.name} has no ledger account');
    }
    return reloadLedgerAccount(id);
  }

  /// Finds a structural account by role in the current chart.
  Future<LedgerAccount> accountWithRole(
    LedgerSystemRole role, {
    Session? session,
  }) async {
    final accounts = await chart(session: session, includeArchived: true);
    return accounts.singleWhere((account) => account.systemRole == role);
  }

  /// Finds a chart account by code. Codes are labels only, never keys; tests
  /// use this to assert template shape, not to address accounts.
  Future<LedgerAccount> accountWithCode(String code, {Session? session}) async {
    final accounts = await chart(session: session, includeArchived: true);
    return accounts.singleWhere((account) => account.code == code);
  }

  /// Saves and posts one journal through the public endpoint path.
  Future<Journal> post(
    DateTime date,
    List<JournalLineInput> lines, {
    Session? session,
    String reference = 'JB-test',
    JournalSource source = JournalSource.manual,
  }) async {
    final draft = await endpoint.saveDraftJournal(
      session ?? this.session,
      entity.id!,
      date,
      lines,
      reference: reference,
      source: source,
    );
    return endpoint.postJournal(session ?? this.session, draft.id!);
  }

  /// A no-op event sink for tests that do not observe realtime messages.
  static Future<void> ignoreEvent(
    Session session,
    UuidValue entityId,
    ChangeScope scope, {
    int? month,
    UuidValue? accountId,
  }) async {}
}

/// Builds transaction-currency and base-currency lines for one entity.
class LedgerLineBuilder {
  LedgerLineBuilder(this.baseCurrency);

  final String baseCurrency;

  JournalLineInput line(
    LedgerAccount account, {
    required bool isDebit,
    required int amountMinor,
    String? currencyCode,
    int? baseAmountMinor,
    String fxRate = '1',
    DateTime? fxRateDate,
    FxRateSource? fxRateSource,
    String? description,
    String? taxCode,
  }) {
    final currency = currencyCode ?? baseCurrency;
    final base = baseAmountMinor ?? amountMinor;
    final source =
        fxRateSource ??
        (currency == baseCurrency
            ? FxRateSource.identity
            : FxRateSource.manual);
    return JournalLineInput(
      ledgerAccountId: account.id!,
      description: description,
      debitMinor: isDebit ? amountMinor : 0,
      creditMinor: isDebit ? 0 : amountMinor,
      currencyCode: currency,
      baseDebitMinor: isDebit ? base : 0,
      baseCreditMinor: isDebit ? 0 : base,
      fxRate: fxRate,
      fxRateDate: fxRateDate,
      fxRateSource: source,
      taxCode: taxCode,
    );
  }

  JournalLineInput debit(
    LedgerAccount account,
    int amountMinor, {
    String? currencyCode,
    int? baseAmountMinor,
    String fxRate = '1',
    DateTime? fxRateDate,
    FxRateSource? fxRateSource,
    String? description,
  }) => line(
    account,
    isDebit: true,
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    baseAmountMinor: baseAmountMinor,
    fxRate: fxRate,
    fxRateDate: fxRateDate,
    fxRateSource: fxRateSource,
    description: description,
  );

  JournalLineInput credit(
    LedgerAccount account,
    int amountMinor, {
    String? currencyCode,
    int? baseAmountMinor,
    String fxRate = '1',
    DateTime? fxRateDate,
    FxRateSource? fxRateSource,
    String? description,
  }) => line(
    account,
    isDebit: false,
    amountMinor: amountMinor,
    currencyCode: currencyCode,
    baseAmountMinor: baseAmountMinor,
    fxRate: fxRate,
    fxRateDate: fxRateDate,
    fxRateSource: fxRateSource,
    description: description,
  );
}

/// Encodes a journal cursor exactly as the documented contract does.
String journalCursor(DateTime date, UuidValue id) {
  final text =
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}|${id.uuid}';
  return base64Url.encode(utf8.encode(text)).replaceAll('=', '');
}
