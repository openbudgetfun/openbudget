import 'dart:async';

import 'package:logging/logging.dart' as logging;
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/wallets/bitcoin/bitcoin_wallet_provider.dart';
import 'package:openbudget_server/src/wallets/bitcoin/esplora_client.dart';
import 'package:openbudget_server/src/wallets/wallet_service.dart';
import 'package:openbudget_server/src/wallets/wallet_vendor_request_counter.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

const _walletAddress = '1A1zP1eP5QGefi2DMPTfTL5SLmv7DivfNa';

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
    captured = <String>[];
    subscription = logging.Logger.root.onRecord.listen((record) {
      captured.add(record.message);
    });
    WalletService.clock = () => DateTime.utc(2026);
    book = await BudgetTestBook.create(server.anonymousSession());
    await book.session.caches.clear();
  });

  tearDown(() async {
    await subscription.cancel();
    WalletService.resetForTests();
  });

  Future<UuidValue> seedBitcoinWallet() async {
    final account = await book.addAccount(
      name: 'Bitcoin wallet',
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
        network: WalletNetwork.bitcoinMainnet,
        address: _walletAddress,
        label: 'Treasury',
        syncStatus: SyncStatus.pending,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      ),
    );
    return wallet.id!;
  }

  test('Bitcoin sync records one esplora request', () async {
    final walletId = await seedBitcoinWallet();
    final counter = WalletVendorRequestCounter();
    final client = EsploraClient(
      baseUrls: [Uri.parse('https://mempool.space/api')],
      minRequestInterval: Duration.zero,
      transport: (_) async => const EsploraResponse(
        statusCode: 200,
        body: '{"chain_stats":{"funded_txo_sum":100,"spent_txo_sum":40},"mempool_stats":{"funded_txo_sum":0,"spent_txo_sum":0}}',
      ),
      counter: counter,
    );
    WalletService.debugProviderFactory = (_, _) =>
        BitcoinWalletProvider(client: client);

    await WalletService.sync(book.session, walletId);

    expect(counter.count('esplora'), 1);
    expect(
      captured,
      contains('wallet.vendor.requests vendor=esplora count=1'),
    );
  });
}
