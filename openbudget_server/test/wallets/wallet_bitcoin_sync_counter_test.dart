import 'dart:async';

import 'package:logging/logging.dart' as logging;
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/wallets/bitcoin/bitcoin_wallet_provider.dart';
import 'package:openbudget_server/src/wallets/bitcoin/esplora_client.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/wallet_service.dart';
import 'package:openbudget_server/src/wallets/wallet_vendor_request_counter.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

const _bitcoinAddress = '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa';
const _solanaAddress = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin';

void main() {
  late PgTestServer server;
  late BudgetTestBook book;
  var serverStarted = false;
  late List<String> captured;
  late StreamSubscription<logging.LogRecord> subscription;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    logging.Logger.root.level = logging.Level.ALL;
    captured = [];
    subscription = logging.Logger.root.onRecord.listen(
      (record) => captured.add(record.message),
    );
    WalletService.clock = () => DateTime.utc(2026);
    book = await BudgetTestBook.create(server.anonymousSession());
    await book.session.caches.clear();
  });

  tearDown(() async {
    await subscription.cancel();
    WalletService.resetForTests();
  });

  Future<UuidValue> seedWallet(WalletNetwork network, String address) async {
    final account = await book.addAccount(
      name: '${network.name} wallet',
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
        network: network,
        address: address,
        label: 'Treasury',
        syncStatus: SyncStatus.pending,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    return wallet.id!;
  }

  List<String> requestLines() => captured
      .where((line) => line.startsWith('wallet.vendor.requests'))
      .toList();

  test('a Bitcoin sync logs its one esplora request', () async {
    final walletId = await seedWallet(
      WalletNetwork.bitcoinMainnet,
      _bitcoinAddress,
    );
    final client = EsploraClient(
      baseUrls: [Uri.parse('https://mempool.space/api')],
      minRequestInterval: Duration.zero,
      transport: (_) async => const EsploraResponse(
        statusCode: 200,
        body:
            '{"chain_stats":{"funded_txo_sum":100,"spent_txo_sum":40},'
            '"mempool_stats":{"funded_txo_sum":0,"spent_txo_sum":0}}',
      ),
    );
    WalletService.debugProviderFactory = (_, _) =>
        BitcoinWalletProvider(client: client);

    await WalletService.sync(book.session, walletId);

    expect(requestLines(), ['wallet.vendor.requests vendor=esplora count=1']);
  });

  test('concurrent syncs each count only their own requests', () async {
    final bitcoinId = await seedWallet(
      WalletNetwork.bitcoinMainnet,
      _bitcoinAddress,
    );
    final solanaId = await seedWallet(
      WalletNetwork.solanaMainnet,
      _solanaAddress,
    );
    // Both providers wait here until both syncs are in flight, so the two
    // counters are live at the same time.
    final bothStarted = Completer<void>();
    var started = 0;
    WalletService.debugProviderFactory = (_, network) => _RecordingProvider(
      network: network,
      vendor: network == WalletNetwork.bitcoinMainnet ? 'esplora' : 'helius',
      requests: network == WalletNetwork.bitcoinMainnet ? 3 : 1,
      onStarted: () {
        if (++started == 2) bothStarted.complete();
        return bothStarted.future;
      },
    );

    await Future.wait([
      WalletService.sync(book.session, bitcoinId),
      WalletService.sync(book.session, solanaId),
    ]);

    expect(
      requestLines(),
      unorderedEquals([
        'wallet.vendor.requests vendor=esplora count=3',
        'wallet.vendor.requests vendor=helius count=1',
      ]),
    );
  });
}

/// Reads nothing, but records [requests] vendor requests the way a client
/// would, with a yield between each so concurrent syncs interleave.
final class _RecordingProvider implements WalletProvider {
  _RecordingProvider({
    required this.network,
    required this.vendor,
    required this.requests,
    required this.onStarted,
  });

  final WalletNetwork network;
  final String vendor;
  final int requests;
  final Future<void> Function() onStarted;

  @override
  Future<WalletProviderSnapshot> fetchSnapshot(
    WalletReadRequest request,
  ) async {
    await onStarted();
    for (var i = 0; i < requests; i++) {
      WalletVendorRequestCounter.current?.record(vendor);
      await Future<void>.delayed(Duration.zero);
    }
    return WalletProviderSnapshot(
      readNetworks: [network],
      holdings: const [],
      transactions: const [],
      warnings: const [],
    );
  }
}
