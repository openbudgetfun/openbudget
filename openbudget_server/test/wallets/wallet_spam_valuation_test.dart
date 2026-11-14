import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/wallets/wallet_endpoint.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/wallet_provider_registry.dart';
import 'package:openbudget_server/src/wallets/wallet_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

const _walletA = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin';

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
    WalletService.clock = () => DateTime.utc(2026);
    WalletService.manualSyncThrottle = Duration.zero;
    book = await BudgetTestBook.create(server.anonymousSession());
    await book.session.caches.clear();
    await book.session.db.unsafeExecute('DELETE FROM asset_price');
    WalletService.debugRegistry = WalletProviderRegistry(
      registrations: {
        ChainFamily.solana: WalletProviderRegistration(
          factory: (_, _) => _ScriptedProvider((_) async => _snapshot()),
          hasSecret: (_, _) => true,
        ),
      },
    );
    WalletService.debugProviderFactory = (_, _) =>
        _ScriptedProvider((_) async => _snapshot());
    endpoint = WalletEndpoint();
    addTearDown(book.expectBalancesConsistent);
  });

  tearDown(WalletService.resetForTests);

  Future<Wallet> connect({List<WalletProviderHolding>? holdings}) async {
    if (holdings != null) {
      WalletService.debugProviderFactory = (_, _) =>
          _ScriptedProvider((_) async => _snapshot(holdings: holdings));
      WalletService.debugRegistry = WalletProviderRegistry(
        registrations: {
          ChainFamily.solana: WalletProviderRegistration(
            factory: (_, _) => _ScriptedProvider(
              (_) async => _snapshot(holdings: holdings),
            ),
            hasSecret: (_, _) => true,
          ),
        },
      );
    }
    return endpoint.connect(
      book.session,
      book.entity.id!,
      WalletNetwork.solanaMainnet,
      _walletA,
      label: 'Treasury',
      accountName: 'Crypto account',
    );
  }

  Future<List<WalletHolding>> holdings(Wallet wallet) => WalletHolding.db.find(
    book.session,
    where: (t) => t.walletId.equals(wallet.id),
  );

  group('allowedByUser survives resync and counts', () {
    test('verdict persists and valuation counts', () async {
      final wallet = await connect(
        holdings: [
          _holding(assetId: 'TokenX', symbol: 'FOO', decimals: 6, price: '100'),
        ],
      );
      final rows = await holdings(wallet);
      final h = rows.single;
      await endpoint.setHoldingVerdict(
        book.session,
        h.id!,
        SpamVerdict.allowedByUser,
      );

      // Resync with the same provider output.
      final result = await endpoint.sync(book.session, wallet.id!);
      final after = await holdings(wallet);
      expect(after.single.spamVerdict, SpamVerdict.allowedByUser);
      expect(result.totalValueMinor, 10000);
    });
  });

  group('hiddenByUser survives resync and does not count', () {
    test('verdict persists and valuation excludes', () async {
      final wallet = await connect(
        holdings: [
          _holding(assetId: 'TokenX', symbol: 'FOO', decimals: 6, price: '100'),
        ],
      );
      final rows = await holdings(wallet);
      final h = rows.single;
      await endpoint.setHoldingVerdict(
        book.session,
        h.id!,
        SpamVerdict.hiddenByUser,
      );

      final result = await endpoint.sync(book.session, wallet.id!);
      final after = await holdings(wallet);
      expect(after.single.spamVerdict, SpamVerdict.hiddenByUser);
      expect(result.totalValueMinor, 0);
    });
  });

  group('Solana valuation excludes suspected token', () {
    test(
      'fake USDC with non-canonical mint is suspected and uncounted',
      () async {
        final wallet = await connect(
          holdings: [
            _holding(assetId: 'native', quantity: '1000000000', price: '150'),
            _holding(
              assetId: 'FakeMint123',
              symbol: 'USDC',
              decimals: 6,
              price: '100',
            ),
          ],
        );
        final rows = await holdings(wallet);
        final fake = rows.firstWhere((r) => r.assetId == 'FakeMint123');
        expect(fake.spamVerdict, SpamVerdict.suspected);
        final result = await endpoint.sync(book.session, wallet.id!);
        // Only the native coin counts.
        expect(result.totalValueMinor, 15000);
      },
    );
  });

  group('price staleness', () {
    test('8 days old leaves holding unpriced and uncounted', () async {
      final first = _snapshot(
        holdings: [
          _holding(
            assetId: 'TokenX',
            symbol: 'FOO',
            decimals: 6,
            prices: [
              _price(
                unitPrice: _exact('100'),
                asOf: DateTime.utc(2025, 12, 24),
              ),
            ],
          ),
        ],
      );
      final second = _snapshot(
        holdings: [
          _holding(
            assetId: 'TokenX',
            symbol: 'FOO',
            decimals: 6,
            prices: const [],
          ),
        ],
      );
      final provider = _CountingProvider(first, second);
      WalletService.debugProviderFactory = (_, _) => provider;
      WalletService.debugRegistry = WalletProviderRegistry(
        registrations: {
          ChainFamily.solana: WalletProviderRegistration(
            factory: (_, _) => provider,
            hasSecret: (_, _) => true,
          ),
        },
      );

      final wallet = await endpoint.connect(
        book.session,
        book.entity.id!,
        WalletNetwork.solanaMainnet,
        _walletA,
        label: 'Treasury',
        accountName: 'Crypto account',
      );

      final result = await endpoint.sync(book.session, wallet.id!);
      final rows = await holdings(wallet);
      expect(rows.single.priceQuality, PriceQuality.unpriced);
      expect(rows.single.valueMinor, isNull);
      expect(result.totalValueMinor, 0);
    });

    test('6 days old is cached, low confidence, counted', () async {
      final first = _snapshot(
        holdings: [
          _holding(
            assetId: 'TokenX',
            symbol: 'FOO',
            decimals: 6,
            prices: [
              _price(
                unitPrice: _exact('100'),
                asOf: DateTime.utc(2025, 12, 26),
              ),
            ],
          ),
        ],
      );
      final second = _snapshot(
        holdings: [
          _holding(
            assetId: 'TokenX',
            symbol: 'FOO',
            decimals: 6,
            prices: const [],
          ),
        ],
      );
      final provider = _CountingProvider(first, second);
      WalletService.debugProviderFactory = (_, _) => provider;
      WalletService.debugRegistry = WalletProviderRegistry(
        registrations: {
          ChainFamily.solana: WalletProviderRegistration(
            factory: (_, _) => provider,
            hasSecret: (_, _) => true,
          ),
        },
      );

      final wallet = await endpoint.connect(
        book.session,
        book.entity.id!,
        WalletNetwork.solanaMainnet,
        _walletA,
        label: 'Treasury',
        accountName: 'Crypto account',
      );

      final result = await endpoint.sync(book.session, wallet.id!);
      final rows = await holdings(wallet);
      expect(rows.single.priceQuality, PriceQuality.cached);
      expect(rows.single.priceConfidence, Confidence.low);
      expect(rows.single.valueMinor, isNotNull);
      expect(result.totalValueMinor, 10000);
    });
  });

  group('setHoldingVerdict', () {
    test('owner can set and clear a verdict', () async {
      final wallet = await connect(
        holdings: [
          _holding(assetId: 'TokenX', symbol: 'FOO', decimals: 6, price: '100'),
        ],
      );
      final rows = await holdings(wallet);
      final h = rows.single;

      final hidden = await endpoint.setHoldingVerdict(
        book.session,
        h.id!,
        SpamVerdict.hiddenByUser,
      );
      expect(hidden.spamVerdict, SpamVerdict.hiddenByUser);

      final cleared = await endpoint.setHoldingVerdict(
        book.session,
        h.id!,
        null,
      );
      expect(cleared.spamVerdict, SpamVerdict.clean);
    });

    test('another user gets forbidden; missing id not found', () async {
      final wallet = await connect(
        holdings: [
          _holding(assetId: 'TokenX', symbol: 'FOO', decimals: 6, price: '100'),
        ],
      );
      final rows = await holdings(wallet);
      final h = rows.single;

      final foreign = await BudgetTestBook.create(server.anonymousSession());
      addTearDown(foreign.session.close);

      await expectLater(
        endpoint.setHoldingVerdict(
          foreign.session,
          h.id!,
          SpamVerdict.allowedByUser,
        ),
        throwsA(isA<ForbiddenException>()),
      );

      final missing = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000001',
      );
      await expectLater(
        endpoint.setHoldingVerdict(
          book.session,
          missing,
          SpamVerdict.allowedByUser,
        ),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('clearing hands control back to classifier on next sync', () async {
      final wallet = await connect(
        holdings: [
          _holding(
            assetId: 'FakeMint123',
            symbol: 'USDC',
            decimals: 6,
            price: '100',
          ),
        ],
      );
      final rows = await holdings(wallet);
      final h = rows.single;
      expect(h.spamVerdict, SpamVerdict.suspected);

      await endpoint.setHoldingVerdict(
        book.session,
        h.id!,
        SpamVerdict.allowedByUser,
      );
      final cleared = await endpoint.setHoldingVerdict(
        book.session,
        h.id!,
        null,
      );
      // Reclassified by classifier -> suspected.
      expect(cleared.spamVerdict, SpamVerdict.suspected);

      final result = await endpoint.sync(book.session, wallet.id!);
      final after = await holdings(wallet);
      expect(after.single.spamVerdict, SpamVerdict.suspected);
      // Not counted.
      expect(result.totalValueMinor, 0);
    });
  });
}

// Helpers

WalletProviderSnapshot _snapshot({List<WalletProviderHolding>? holdings}) =>
    WalletProviderSnapshot(
      readNetworks: [WalletNetwork.solanaMainnet],
      holdings:
          holdings ??
          [
            _holding(assetId: 'native', quantity: '1000000000', price: '150'),
          ],
      transactions: const [],
      warnings: const [],
    );

WalletProviderHolding _holding({
  required String assetId,
  int decimals = 9,
  String quantity = '1000000',
  String? price,
  List<WalletProviderPrice>? prices,
  bool isNft = false,
  String? tokenProgram,
  String? symbol,
  String? name,
  String? metadataJson,
  WalletNetwork network = WalletNetwork.solanaMainnet,
}) => WalletProviderHolding(
  network: network,
  assetId: assetId,
  decimals: decimals,
  quantityRaw: BigInt.parse(quantity),
  isNft: isNft,
  symbol: symbol,
  name: name,
  tokenProgram: tokenProgram,
  metadataJson: metadataJson,
  prices:
      prices ?? [if (price != null) _providerPrice(unitPrice: _exact(price))],
);

WalletProviderPrice _providerPrice({
  ExactDecimal? unitPrice,
  ExactDecimal? totalPrice,
  String currencyCode = 'USD',
  DateTime? asOf,
}) => WalletProviderPrice(
  currencyCode: currencyCode,
  source: PriceSource.jupiter,
  quality: PriceQuality.live,
  confidence: Confidence.high,
  asOf: asOf ?? DateTime.utc(2026),
  unitPrice: unitPrice,
  totalPrice: totalPrice,
);

WalletProviderPrice _price({
  required ExactDecimal unitPrice,
  required DateTime asOf,
}) => WalletProviderPrice(
  currencyCode: 'USD',
  source: PriceSource.jupiter,
  quality: PriceQuality.live,
  confidence: Confidence.high,
  asOf: asOf,
  unitPrice: unitPrice,
);

ExactDecimal _exact(String value) => ExactDecimal.tryParse(value)!;

final class _ScriptedProvider implements WalletProvider {
  _ScriptedProvider(this.handler);
  final Future<WalletProviderSnapshot> Function(WalletReadRequest request)
  handler;
  @override
  Future<WalletProviderSnapshot> fetchSnapshot(WalletReadRequest request) =>
      handler(request);
}

final class _CountingProvider implements WalletProvider {
  _CountingProvider(this.first, this.second);
  final WalletProviderSnapshot first;
  final WalletProviderSnapshot second;
  int calls = 0;
  @override
  Future<WalletProviderSnapshot> fetchSnapshot(
    WalletReadRequest request,
  ) async {
    calls++;
    return calls == 1 ? first : second;
  }
}
