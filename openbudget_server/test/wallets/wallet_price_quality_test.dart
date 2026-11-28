import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/wallets/prices/price_service.dart';
import 'package:openbudget_server/src/wallets/wallet_endpoint.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/wallet_provider_registry.dart';
import 'package:openbudget_server/src/wallets/wallet_service.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/fake_http_client.dart';
import '../support/pg_test_server.dart';

const _evmAddress = '0x1111111111111111111111111111111111111111';
const _token = '0x2222222222222222222222222222222222222222';
const _ethQuantity = '1000000000000000000';
final DateTime _now = DateTime.utc(2026, 1, 10, 12);
final DateTime _eightDaysAgo = _now.subtract(const Duration(days: 8));

void main() {
  late PgTestServer server;
  late BudgetTestBook book;
  late WalletEndpoint endpoint;
  var serverStarted = false;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    WalletService.clock = () => _now;
    WalletService.manualSyncThrottle = Duration.zero;
    PriceService.resetForTests();
    book = await BudgetTestBook.create(server.anonymousSession());
    await book.session.caches.clear();
    await book.session.db.unsafeExecute('DELETE FROM asset_price');
    book.session.server.passwords.remove('coingeckoProApiKey');
    endpoint = WalletEndpoint();
    addTearDown(book.expectBalancesConsistent);
  });

  tearDown(() {
    WalletService.resetForTests();
    PriceService.resetForTests();
  });

  Future<Wallet> connect({List<WalletProviderHolding>? holdings}) async {
    final snapshot = WalletProviderSnapshot(
      readNetworks: const [WalletNetwork.ethereumMainnet],
      holdings:
          holdings ??
          [_holding(assetId: 'native', network: WalletNetwork.ethereumMainnet)],
      transactions: const [],
      warnings: const [],
    );
    final provider = _ScriptedProvider((_) async => snapshot);
    WalletService.debugRegistry = WalletProviderRegistry(
      registrations: {
        ChainFamily.evm: WalletProviderRegistration(
          factory: (_, _) => provider,
          hasSecret: (_, _) => true,
        ),
      },
    );
    WalletService.debugProviderFactory = (_, _) => provider;
    return endpoint.connect(
      book.session,
      book.entity.id!,
      WalletNetwork.ethereumMainnet,
      _evmAddress,
      label: 'Vault',
      accountName: 'Crypto account',
    );
  }

  Future<List<WalletHolding>> holdings(Wallet wallet) => WalletHolding.db.find(
    book.session,
    where: (t) => t.walletId.equals(wallet.id),
  );

  test('when the session carries a CoinGecko pro key then revalue sends it '
      'to the pro host', () async {
    final wallet = await connect();
    book.session.server.passwords['coingeckoProApiKey'] = 'pro-secret';
    addTearDown(
      () => book.session.server.passwords.remove('coingeckoProApiKey'),
    );
    final requests = <FakeHttpClientRequest>[];
    PriceService.configure(
      httpClient: FakeHttpClient(
        handler: (_, request) async {
          requests.add(request);
          return const FakeHttpResponse(body: '{"ethereum":{"usd":2000}}');
        },
      ),
    );

    await WalletService.revalue(book.session, wallet.id!);

    expect(requests, hasLength(1));
    expect(requests.single.uri.host, 'pro-api.coingecko.com');
    expect(requests.single.headers.value('x-cg-pro-api-key'), 'pro-secret');
    expect((await holdings(wallet)).single.valueMinor, 200000);
  });

  test('when the price comes from the stored cache then revalue records it '
      'as cached with low confidence', () async {
    final wallet = await connect();
    await AssetPrice.db.insertRow(
      book.session,
      AssetPrice(
        network: WalletNetwork.ethereumMainnet,
        assetId: 'native',
        currencyCode: 'USD',
        unitPrice: '250.5',
        source: PriceSource.coingecko,
        fetchedAt: _now.subtract(const Duration(minutes: 5)),
        expiresAt: _now.add(const Duration(minutes: 10)),
      ),
    );
    PriceService.configure(
      httpClient: FakeHttpClient(
        handler: (_, _) async =>
            throw AssertionError('HTTP called for a cached price'),
      ),
    );

    await WalletService.revalue(book.session, wallet.id!);

    final row = (await holdings(wallet)).single;
    expect(row.unitPrice, '250.5');
    expect(row.valueMinor, 25050);
    expect(row.priceQuality, PriceQuality.cached);
    expect(row.priceConfidence, Confidence.low);
  });

  test('when a source quotes the asset then revalue records it as live with '
      'high confidence', () async {
    final wallet = await connect();
    PriceService.configure(
      httpClient: FakeHttpClient(
        handler: (_, _) async =>
            const FakeHttpResponse(body: '{"ethereum":{"usd":1940.13}}'),
      ),
    );

    await WalletService.revalue(book.session, wallet.id!);

    final row = (await holdings(wallet)).single;
    expect(row.unitPrice, '1940.13');
    expect(row.valueMinor, 194013);
    expect(row.priceQuality, PriceQuality.live);
    expect(row.priceConfidence, Confidence.high);
  });

  test('when no source quotes an eight-day-old holding then revalue clears '
      'it and leaves it out of the valuation', () async {
    final wallet = await connect(
      holdings: [
        _holding(assetId: 'native', network: WalletNetwork.ethereumMainnet),
        _holding(
          assetId: _token,
          network: WalletNetwork.ethereumMainnet,
          decimals: 6,
          quantity: '1000000000',
          symbol: 'OLD',
        ),
      ],
    );
    final stale = (await holdings(
      wallet,
    )).firstWhere((row) => row.assetId == _token);
    await WalletHolding.db.updateRow(
      book.session,
      stale.copyWith(
        unitPrice: '100',
        valueMinor: 10000000,
        priceSource: PriceSource.coingecko,
        priceQuality: PriceQuality.live,
        priceConfidence: Confidence.high,
        priceAsOf: _eightDaysAgo,
      ),
    );
    PriceService.configure(
      httpClient: FakeHttpClient(
        handler: (uri, _) async {
          if (uri.path.contains('token_price')) {
            return const FakeHttpResponse();
          }
          if (uri.host.contains('llama')) {
            return const FakeHttpResponse(body: '{"coins":{}}');
          }
          return const FakeHttpResponse(body: '{"ethereum":{"usd":2000}}');
        },
      ),
    );

    await WalletService.revalue(book.session, wallet.id!);

    final rows = await holdings(wallet);
    final staleRow = rows.firstWhere((row) => row.assetId == _token);
    expect(staleRow.valueMinor, isNull);
    expect(staleRow.unitPrice, isNull);
    expect(staleRow.priceAsOf, isNull);
    expect(staleRow.priceQuality, PriceQuality.unpriced);
    final nativeRow = rows.firstWhere((row) => row.assetId == 'native');
    expect(nativeRow.valueMinor, 200000);
    final valuations = await AccountValuation.db.find(
      book.session,
      where: (t) => t.accountId.equals(wallet.accountId),
    );
    final revaluation = valuations.firstWhere(
      (row) => row.valuationDate.toUtc() == DateTime.utc(2026, 1, 10),
    );
    expect(revaluation.valueMinor, 200000);
  });
}

WalletProviderHolding _holding({
  required String assetId,
  required WalletNetwork network,
  int decimals = 18,
  String quantity = _ethQuantity,
  String? symbol,
}) => WalletProviderHolding(
  network: network,
  assetId: assetId,
  decimals: decimals,
  quantityRaw: BigInt.parse(quantity),
  isNft: false,
  prices: const [],
  symbol: symbol,
);

final class _ScriptedProvider implements WalletProvider {
  _ScriptedProvider(this.handler);

  final Future<WalletProviderSnapshot> Function(WalletReadRequest request)
  handler;

  @override
  Future<WalletProviderSnapshot> fetchSnapshot(WalletReadRequest request) =>
      handler(request);
}
