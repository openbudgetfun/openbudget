import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/wallet_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

const _walletAddress = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin';

/// The sync must fetch the chain before its transaction opens, so a slow
/// provider never holds a row lock (multichain-wallets.md 8.1).
void main() {
  late PgTestServer server;
  late BudgetTestBook book;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    book = await BudgetTestBook.create(server.anonymousSession());
    await book.session.caches.clear();
  });

  tearDown(WalletService.resetForTests);

  Future<UuidValue> seedWallet() async {
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
    return wallet.id!;
  }

  group('Given a wallet sync', () {
    test(
      'when the provider is called then no database transaction is open',
      () async {
        final walletId = await seedWallet();
        final probe = _TransactionProbeProvider(server.session, walletId);
        WalletService.debugProviderFactory = (_, _) => probe;

        await WalletService.sync(book.session, walletId);

        expect(probe.calls, 1);
        expect(
          probe.sawOpenTransaction,
          isFalse,
          reason:
              'every provider network call happens before the sync '
              'transaction opens',
        );
        expect(
          probe.walletRowWasLocked,
          isFalse,
          reason: 'the wallet row is not locked while the provider runs',
        );
      },
    );

    test(
      'when the sync runs then the provider receives the wallet read '
      'request',
      () async {
        final walletId = await seedWallet();
        final probe = _TransactionProbeProvider(server.session, walletId);
        WalletService.debugProviderFactory = (_, _) => probe;

        await WalletService.sync(book.session, walletId);

        final request = probe.requests.single;
        expect(request.homeNetwork, WalletNetwork.solanaMainnet);
        expect(request.networks, [WalletNetwork.solanaMainnet]);
        expect(request.address, _walletAddress);
        expect(request.descriptor, isNull);
        expect(request.untilSignature, isNull);
        expect(request.historyCursors, isEmpty);
      },
    );

    test(
      'when the provider fails then the stored error stays the provider '
      'message alone',
      () async {
        final walletId = await seedWallet();
        WalletService.debugProviderFactory = (_, _) => _FailingProvider();
        const message = 'Solana could not be reached (HTTP 503).';

        await expectLater(
          WalletService.sync(book.session, walletId),
          throwsA(isA<WalletProviderException>()),
        );

        final wallet = await Wallet.db.findById(book.session, walletId);
        expect(wallet!.syncStatus, SyncStatus.failed);
        expect(wallet.lastSyncError, message);
        expect(
          wallet.lastSyncError,
          isNot(matches(RegExp('https?://', caseSensitive: false))),
        );
        expect(wallet.lastSyncError, isNot(contains(_walletAddress)));
      },
    );
  });
}

/// A scripted provider that records whether any transaction was open and
/// whether the wallet row was locked at the moment it was called.
///
/// The probes run through a separate session so they never queue behind the
/// sync's own database work. `pg_locks` sees every other backend's open
/// transaction through its `virtualxid` lock, which a transaction holds
/// before and after any row lock is taken.
final class _TransactionProbeProvider implements WalletProvider {
  _TransactionProbeProvider(this.probeSession, this.walletId);

  final Session probeSession;
  final UuidValue walletId;

  final List<WalletReadRequest> requests = [];
  int calls = 0;
  bool sawOpenTransaction = false;
  bool walletRowWasLocked = false;

  @override
  Future<WalletProviderSnapshot> fetchSnapshot(
    WalletReadRequest request,
  ) async {
    calls += 1;
    requests.add(request);

    final openTransactions = await probeSession.db.unsafeQuery(
      'SELECT count(*)::bigint FROM pg_locks '
      "WHERE locktype = 'virtualxid' AND pid <> pg_backend_pid()",
    );
    sawOpenTransaction = (openTransactions.first.first as int) > 0;

    try {
      await probeSession.db.unsafeQuery(
        'SELECT id FROM wallet WHERE id = @id::uuid FOR UPDATE NOWAIT',
        parameters: QueryParameters.named({'id': walletId.toString()}),
      );
    } on DatabaseQueryException catch (error) {
      if (error.code == '55P03') walletRowWasLocked = true;
    }

    return WalletProviderSnapshot(
      readNetworks: [WalletNetwork.solanaMainnet],
      holdings: [
        WalletProviderHolding(
          network: WalletNetwork.solanaMainnet,
          assetId: 'native',
          decimals: 9,
          quantityRaw: BigInt.parse('1000000000'),
          isNft: false,
          prices: [
            WalletProviderPrice(
              currencyCode: 'USD',
              source: PriceSource.jupiter,
              quality: PriceQuality.live,
              confidence: Confidence.high,
              asOf: DateTime.now().toUtc(),
              unitPrice: ExactDecimal.tryParse('150'),
            ),
          ],
        ),
      ],
      transactions: const [],
      warnings: const [],
    );
  }
}

final class _FailingProvider implements WalletProvider {
  @override
  Future<WalletProviderSnapshot> fetchSnapshot(WalletReadRequest request) =>
      throw const WalletProviderException(
        'Solana could not be reached (HTTP 503).',
      );
}
