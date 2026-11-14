import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/billing/entitlement_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/wallet_refresh_future_call.dart';
import 'package:openbudget_server/src/wallets/wallet_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

const _walletAddress = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin';

class _FakeProvider implements WalletProvider {
  int calls = 0;

  @override
  Future<WalletProviderSnapshot> fetchSnapshot(
    WalletReadRequest request,
  ) async {
    calls++;
    final now = WalletService.clock();
    return WalletProviderSnapshot(
      readNetworks: request.networks,
      holdings: [
        WalletProviderHolding(
          network: WalletNetwork.solanaMainnet,
          assetId: 'SOL',
          decimals: 9,
          quantityRaw: BigInt.from(1000000000),
          isNft: false,
          prices: [
            WalletProviderPrice(
              currencyCode: 'USD',
              source: PriceSource.jupiter,
              quality: PriceQuality.live,
              confidence: Confidence.high,
              asOf: now,
              unitPrice: ExactDecimal.tryParse('100'),
            ),
          ],
        ),
      ],
      transactions: const [],
      warnings: const [],
    );
  }
}

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
    await book.session.db.unsafeExecute('DELETE FROM asset_price');
    WalletService.clock = () => DateTime.utc(2026);
    WalletService.debugProviderFactory = (_, _) => _FakeProvider();
    WalletRefreshFutureCall.readCap = 500;
  });

  tearDown(WalletService.resetForTests);

  Future<UuidValue> seedWallet({
    DateTime? lastSyncedAt,
    String address = _walletAddress,
  }) async {
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
        address: address,
        label: 'Treasury',
        syncStatus: SyncStatus.pending,
        lastSyncedAt: lastSyncedAt,
        createdAt: WalletService.clock(),
        updatedAt: WalletService.clock(),
      ),
    );
    return wallet.id!;
  }

  Future<void> makePlus() async {
    final now = WalletService.clock();
    await EntitlementService.record(
      book.session,
      userId: book.userId,
      source: EntitlementSource.stripe,
      externalId: 'sub-1',
      status: EntitlementStatus.active,
      currentPeriodStart: now,
      currentPeriodEnd: now.add(const Duration(days: 30)),
    );
  }

  test(
    'free wallet is read once in 24 hours and revalued every hour',
    () async {
      final base = DateTime.utc(2026);
      WalletService.clock = () => base;
      await seedWallet();
      final provider = _FakeProvider();
      WalletService.debugProviderFactory = (_, _) => provider;

      var reads = 0;
      var revaluations = 0;
      for (var i = 0; i < 25; i++) {
        WalletService.clock = () => base.add(Duration(hours: i));
        final report = await WalletRefreshFutureCall.run(book.session);
        reads += report.reads;
        revaluations += report.revaluations;
      }

      expect(provider.calls, 2);
      expect(reads, 2);
      expect(revaluations, 23);
    },
  );

  test('plus wallet is read every 6 hours', () async {
    final base = DateTime.utc(2026);
    WalletService.clock = () => base;
    await seedWallet();
    await makePlus();
    final provider = _FakeProvider();
    WalletService.debugProviderFactory = (_, _) => provider;

    var reads = 0;
    var revaluations = 0;
    for (var i = 0; i < 25; i++) {
      WalletService.clock = () => base.add(Duration(hours: i));
      final report = await WalletRefreshFutureCall.run(book.session);
      reads += report.reads;
      revaluations += report.revaluations;
    }

    expect(provider.calls, 5);
    expect(reads, 5);
    expect(revaluations, 20);
  });

  test('a revaluation makes no provider call', () async {
    final base = DateTime.utc(2026);
    WalletService.clock = () => base;
    final walletId = await seedWallet();
    final provider = _FakeProvider();
    WalletService.debugProviderFactory = (_, _) => provider;

    await WalletService.sync(book.session, walletId, force: true);
    final before = provider.calls;
    WalletService.clock = () => base.add(const Duration(hours: 1));
    await WalletService.revalue(book.session, walletId);
    expect(provider.calls, before);
  });

  test(
    'a manual sync racing the job leaves one consistent valuation',
    () async {
      final base = DateTime.utc(2026);
      WalletService.clock = () => base;
      final walletId = await seedWallet();
      final provider = _FakeProvider();
      WalletService.debugProviderFactory = (_, _) => provider;

      await Future.wait([
        WalletRefreshFutureCall.run(book.session),
        WalletService.sync(book.session, walletId),
      ]);

      final wallet = await Wallet.db.findById(book.session, walletId);
      final valuations = await AccountValuation.db.find(
        book.session,
        where: (t) => t.accountId.equals(wallet!.accountId),
      );
      expect(valuations, hasLength(1));
      expect(valuations.single.valueMinor, 10000);
    },
  );

  test(
    'a second manual sync inside 5 minutes makes no provider call',
    () async {
      final base = DateTime.utc(2026);
      WalletService.clock = () => base;
      final walletId = await seedWallet();
      final provider = _FakeProvider();
      WalletService.debugProviderFactory = (_, _) => provider;

      await WalletService.sync(book.session, walletId);
      final firstCalls = provider.calls;

      WalletService.clock = () => base.add(const Duration(minutes: 1));
      await WalletService.sync(book.session, walletId);
      expect(provider.calls, firstCalls);

      WalletService.clock = () =>
          base.add(const Duration(minutes: 5, seconds: 1));
      await WalletService.sync(book.session, walletId);
      expect(provider.calls, firstCalls + 1);
    },
  );

  test('a revaluation re-prices holdings from the swept price', () async {
    final base = DateTime.utc(2026);
    WalletService.clock = () => base;
    final walletId = await seedWallet();
    final provider = _FakeProvider();
    WalletService.debugProviderFactory = (_, _) => provider;

    // The first run reads the wallet: 1 SOL at $100 is 10,000 cents.
    await WalletRefreshFutureCall.run(book.session);
    expect(provider.calls, 1);

    // An hour later the price cache holds $150. The wallet is not due a
    // read, so the run revalues it from the swept price.
    final later = base.add(const Duration(hours: 1));
    WalletService.clock = () => later;
    await book.session.db.unsafeExecute('DELETE FROM asset_price');
    await AssetPrice.db.insertRow(
      book.session,
      AssetPrice(
        network: WalletNetwork.solanaMainnet,
        assetId: 'SOL',
        currencyCode: 'USD',
        unitPrice: '150',
        source: PriceSource.jupiter,
        fetchedAt: later,
        expiresAt: later.add(const Duration(hours: 1)),
      ),
    );

    final report = await WalletRefreshFutureCall.run(book.session);
    expect(report.reads, 0);
    expect(report.revaluations, 1);
    expect(provider.calls, 1);

    final holdings = await WalletHolding.db.find(
      book.session,
      where: (t) => t.walletId.equals(walletId),
    );
    expect(holdings.single.valueMinor, 15000);
    expect(holdings.single.unitPrice, '150');
  });

  test('the per-run cap is honoured, oldest first', () async {
    final base = DateTime.utc(2026);
    WalletService.clock = () => base.add(const Duration(hours: 30));
    WalletRefreshFutureCall.readCap = 2;

    final idNew = await seedWallet(
      lastSyncedAt: base.add(const Duration(hours: 20)),
      address: '${_walletAddress}1',
    );
    final idMid = await seedWallet(
      lastSyncedAt: base.add(const Duration(hours: 10)),
      address: '${_walletAddress}2',
    );
    final idOld = await seedWallet(
      lastSyncedAt: base,
      address: '${_walletAddress}3',
    );

    // Reorder lastSyncedAt: oldest idOld, mid, new.
    await Wallet.db.updateRow(
      book.session,
      (await Wallet.db.findById(book.session, idOld))!.copyWith(
        lastSyncedAt: base.subtract(const Duration(hours: 48)),
      ),
    );
    await Wallet.db.updateRow(
      book.session,
      (await Wallet.db.findById(book.session, idMid))!.copyWith(
        lastSyncedAt: base.subtract(const Duration(hours: 36)),
      ),
    );
    await Wallet.db.updateRow(
      book.session,
      (await Wallet.db.findById(book.session, idNew))!.copyWith(
        lastSyncedAt: base.subtract(const Duration(hours: 25)),
      ),
    );

    final provider = _FakeProvider();
    WalletService.debugProviderFactory = (_, _) => provider;

    WalletService.clock = () => base;
    final report = await WalletRefreshFutureCall.run(book.session);
    expect(report.reads, 2);

    final oldWallet = await Wallet.db.findById(book.session, idOld);
    final newWallet = await Wallet.db.findById(book.session, idNew);
    // Oldest two were read (lastSyncedAt moved to now); newest was revalued.
    expect(oldWallet!.lastSyncedAt, base);
    expect(newWallet!.lastSyncedAt, base.subtract(const Duration(hours: 25)));
  });
}
