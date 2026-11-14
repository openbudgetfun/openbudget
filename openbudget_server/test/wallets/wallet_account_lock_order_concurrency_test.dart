import 'dart:async';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/accounts/account_service.dart';
import 'package:openbudget_server/src/accounts/account_valuation_service.dart';
import 'package:openbudget_server/src/entities/entity_clock.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/wallets/wallet_endpoint.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/wallet_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../catalogue/catalogue_helpers.dart';
import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

const _walletAddress = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin';
const _nativeAsset = 'native';

/// Wallet rows cascade from [Account], so wallet writes must take the account
/// before the wallet. These races are staged with a real row-lock gate and a
/// bounded blocked-backend barrier rather than a sleep.
void main() {
  late PgTestServer server;
  late BudgetTestBook book;
  late EventLog events;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    events = EventLog()..install();
    WalletService.debugPublisher = events.record;
    AccountService.debugPublisher = events.record;
    book = await BudgetTestBook.create(server.anonymousSession());
    await book.session.caches.clear();
    addTearDown(book.expectBalancesConsistent);
  });

  tearDown(() {
    WalletService.resetForTests();
    AccountService.resetForTests();
    events.reset();
  });

  Session sessionOf() {
    final session = server.authenticatedSession(book.userId);
    addTearDown(session.close);
    return session;
  }

  Future<_WalletFixture> seedWallet() async {
    final account = await book.addAccount(
      name: 'Solana wallet',
      kind: AccountKind.crypto,
      currencyCode: 'USD',
      balanceSource: AccountBalanceSource.valuations,
      onBudget: false,
    );
    final wallet = await Wallet.db.insertRow(
      book.session,
      Wallet(
        entityId: book.entity.id!,
        accountId: account.id!,
        network: WalletNetwork.solanaMainnet,
        address: _walletAddress,
        label: 'Treasury',
        syncStatus: SyncStatus.pending,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    final holding = await WalletHolding.db.insertRow(
      book.session,
      WalletHolding(
        walletId: wallet.id!,
        network: wallet.network,
        assetId: _nativeAsset,
        symbol: 'SOL',
        name: 'Solana',
        decimals: 9,
        quantityRaw: BigInt.parse('1000000000'),
        priceCurrencyCode: 'USD',
        unitPrice: '150',
        valueMinor: 15000,
        priceSource: PriceSource.jupiter,
        priceQuality: PriceQuality.live,
        priceConfidence: Confidence.high,
        priceAsOf: DateTime.utc(2026),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    WalletService.debugProviderFactory = (_, _) =>
        _ScriptedProvider((_) async => _snapshot());
    events.events.clear();

    return _WalletFixture(
      walletId: wallet.id!,
      accountId: account.id!,
      holdingId: holding.id!,
    );
  }

  group('wallet account lock order', () {
    test(
      'when a wallet sync races an account delete then neither deadlocks',
      () async {
        final fixture = await seedWallet();
        final gate = await _RowGate.hold(
          sessionOf(),
          'wallet_holding',
          fixture.holdingId,
        );
        addTearDown(gate.release);

        final syncRun = _runCatching(
          () => WalletService.sync(sessionOf(), fixture.walletId, force: true),
        );
        await _waitForRowLock(server, 'wallet', fixture.walletId);

        final deleteRun = _runCatching(
          () => AccountService.delete(sessionOf(), fixture.accountId),
        );
        await _waitForBlockedWriters(server);
        await gate.release();

        final outcomes = await _settle(syncRun, deleteRun);
        _expectNoDeadlock(outcomes);
        await _expectConsistentWalletFacts(
          fixture,
          outcomes.last,
          book,
          events,
        );
      },
    );

    test(
      'when reconnecting an existing wallet races an account delete then '
      'neither deadlocks',
      () async {
        final fixture = await seedWallet();
        final endpoint = WalletEndpoint();
        final gate = await _RowGate.hold(
          sessionOf(),
          'wallet',
          fixture.walletId,
        );
        addTearDown(gate.release);

        final connectRun = _runCatching(
          () => endpoint.connect(
            sessionOf(),
            book.entity.id!,
            WalletNetwork.solanaMainnet,
            _walletAddress,
            label: 'Renamed while deleting',
            accountName: 'Renamed account while deleting',
          ),
        );
        await _waitForBlockedCount(server, 1);

        final deleteRun = _runCatching(
          () => AccountService.delete(sessionOf(), fixture.accountId),
        );
        await _waitForBlockedWriters(server);
        await gate.release();

        final outcomes = await _settle(connectRun, deleteRun);
        _expectNoDeadlock(outcomes);
        await _expectConsistentWalletFacts(
          fixture,
          outcomes.last,
          book,
          events,
        );
      },
    );

    test(
      'when a manual valuation races a wallet sync then both settle with one '
      'consistent valuation and neither deadlocks',
      () async {
        final fixture = await seedWallet();
        final gate = await _RowGate.hold(
          sessionOf(),
          'wallet_holding',
          fixture.holdingId,
        );
        addTearDown(gate.release);

        final syncRun = _runCatching(
          () => WalletService.sync(sessionOf(), fixture.walletId, force: true),
        );
        await _waitForRowLock(server, 'wallet', fixture.walletId);

        final valuationRun = _runCatching(
          () => AccountValuationService.set(
            sessionOf(),
            fixture.accountId,
            EntityClock.today(book.entity),
            99900,
            note: 'manual while syncing',
          ),
        );
        await gate.release();

        final outcomes = await _settle(syncRun, valuationRun);
        _expectNoDeadlock(outcomes);

        final account = await Account.db.findById(
          book.session,
          fixture.accountId,
        );
        expect(account, isNotNull);
        final valuation = await AccountValuation.db.findFirstRow(
          book.session,
          where: (t) =>
              t.accountId.equals(fixture.accountId) &
              t.valuationDate.equals(EntityClock.today(book.entity)),
        );
        expect(valuation, isNotNull);
        expect(
          valuation!.valueMinor,
          anyOf(15000, 99900),
          reason: 'the valuation that commits last must be the stored one',
        );
        expect(
          valuation.source,
          anyOf(ValuationSource.wallet, ValuationSource.manual),
        );
        expect(account!.balanceMinor, valuation.valueMinor);
      },
    );
  });
}

Future<List<Object?>> _settle(
  Future<Object?> first,
  Future<Object?> second,
) => Future.wait([
  first.timeout(const Duration(seconds: 30)),
  second.timeout(const Duration(seconds: 30)),
]);

Future<Object?> _runCatching(Future<Object?> Function() body) async {
  try {
    return await body();
  } on Object catch (error) {
    return error;
  }
}

void _expectNoDeadlock(List<Object?> outcomes) {
  for (final error in outcomes.nonNulls) {
    expect(
      error is DatabaseQueryException ? error.code : null,
      isNot('40P01'),
      reason: 'wallet writes must never deadlock: $error',
    );
  }
}

/// A completed delete may remove the wallet, and a completed sync must leave a
/// valuation-backed account whose cache matches its newest valuation.
Future<void> _expectConsistentWalletFacts(
  _WalletFixture fixture,
  Object? deleteError,
  BudgetTestBook book,
  EventLog events,
) async {
  for (final event in events.events) {
    if (event.accountId == null) continue;
    expect(
      event.accountId,
      fixture.accountId,
      reason: 'a committed wallet write must publish only its own account',
    );
  }

  final account = await Account.db.findById(book.session, fixture.accountId);
  if (account == null) {
    expect(
      await Wallet.db.findById(book.session, fixture.walletId),
      isNull,
      reason: 'deleting the account must cascade its wallet',
    );
    expect(
      deleteError,
      isNull,
      reason: 'an account only disappears when its delete committed',
    );
    return;
  }

  expect(deleteError, isNotNull);
  final wallet = await Wallet.db.findById(book.session, fixture.walletId);
  expect(wallet, isNotNull);
  expect(wallet!.accountId, fixture.accountId);
  final valuation = await AccountValuation.db.findFirstRow(
    book.session,
    where: (t) =>
        t.accountId.equals(fixture.accountId) &
        t.valuationDate.equals(EntityClock.today(book.entity)),
  );
  expect(valuation, isNotNull);
  expect(account.balanceMinor, valuation!.valueMinor);
}

/// Waits until [id] is locked by another backend.
Future<void> _waitForRowLock(
  PgTestServer server,
  String table,
  UuidValue id,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (DateTime.now().isBefore(deadline)) {
    try {
      await server.session.db.unsafeQuery(
        'SELECT id FROM "$table" WHERE id = @id::uuid FOR UPDATE NOWAIT',
        parameters: QueryParameters.named({'id': id.toString()}),
      );
    } on DatabaseQueryException catch (error) {
      if (error.code == '55P03') return;
      rethrow;
    }

    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  fail('$table row $id was not locked within the timeout');
}

/// Waits until both racing writes are blocked on their row locks.
Future<void> _waitForBlockedWriters(PgTestServer server) =>
    _waitForBlockedCount(server, 2);

/// Waits until [minimum] backends are blocked on row locks.
Future<void> _waitForBlockedCount(PgTestServer server, int minimum) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (DateTime.now().isBefore(deadline)) {
    final rows = await server.session.db.unsafeQuery(
      'SELECT count(*)::bigint FROM pg_stat_activity '
      'WHERE datname = current_database() '
      "AND wait_event_type = 'Lock' AND pid <> pg_backend_pid()",
    );
    if ((rows.first.first as int) >= minimum) return;

    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('$minimum writers did not block on a row lock within the timeout');
}

/// Holds a row lock in its own transaction until [release] is called.
final class _RowGate {
  _RowGate._(this._release, this._done);

  static Future<_RowGate> hold(
    Session session,
    String table,
    UuidValue id,
  ) async {
    final locked = Completer<void>();
    final release = Completer<void>();
    final done = session.db.transaction((tx) async {
      await session.db.unsafeQuery(
        'SELECT id FROM "$table" WHERE id = @id::uuid FOR UPDATE',
        parameters: QueryParameters.named({'id': id.toString()}),
        transaction: tx,
      );
      locked.complete();
      await release.future;
    });
    await locked.future;

    return _RowGate._(release, done);
  }

  final Completer<void> _release;
  final Future<void> _done;

  Future<void> release() async {
    if (!_release.isCompleted) _release.complete();
    await _done;
  }
}

final class _WalletFixture {
  const _WalletFixture({
    required this.walletId,
    required this.accountId,
    required this.holdingId,
  });

  final UuidValue walletId;
  final UuidValue accountId;
  final UuidValue holdingId;
}

final class _ScriptedProvider implements WalletProvider {
  _ScriptedProvider(this.handler);

  final Future<WalletProviderSnapshot> Function(String? until) handler;

  @override
  Future<WalletProviderSnapshot> fetchSnapshot(WalletReadRequest request) =>
      handler(request.untilSignature);
}

WalletProviderSnapshot _snapshot() => WalletProviderSnapshot(
  readNetworks: [WalletNetwork.solanaMainnet],
  holdings: [
    WalletProviderHolding(
      network: WalletNetwork.solanaMainnet,
      assetId: _nativeAsset,
      symbol: 'SOL',
      name: 'Solana',
      decimals: 9,
      quantityRaw: BigInt.parse('1000000000'),
      isNft: false,
      prices: [
        WalletProviderPrice(
          currencyCode: 'USD',
          source: PriceSource.jupiter,
          quality: PriceQuality.live,
          confidence: Confidence.high,
          asOf: DateTime.utc(2026),
          unitPrice: ExactDecimal.tryParse('150'),
        ),
      ],
    ),
  ],
  transactions: const [],
  warnings: const [],
);
