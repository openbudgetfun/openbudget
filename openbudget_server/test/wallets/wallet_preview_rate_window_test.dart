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

/// The preview limit is one fixed hour per user, owned by PostgreSQL, so a
/// restart cannot hand out 20 more reads (multichain-wallets.md 5.5).
const _evmAddress = '0x1111111111111111111111111111111111111111';
const _ethQuantity = '1000000000000000000';
final _windowStart = DateTime.utc(2026, 1, 1, 12);

void main() {
  late PgTestServer server;
  late BudgetTestBook book;
  late WalletEndpoint endpoint;
  late _PreviewProvider provider;
  var serverStarted = false;

  /// Registers [provider] for the EVM family, as a configured server would.
  void registerEvmProvider(WalletProvider provider) {
    WalletService.debugRegistry = WalletProviderRegistry(
      registrations: {
        ChainFamily.evm: WalletProviderRegistration(
          factory: (_, _) => provider,
          hasSecret: (_, _) => true,
        ),
      },
    );
  }

  Future<WalletPreview> readPreview({Session? session}) => endpoint.preview(
    session ?? book.session,
    book.entity.id!,
    _evmAddress,
  );

  Future<WalletPreviewRateWindow?> windowRow({Session? session}) =>
      WalletPreviewRateWindow.db.findFirstRow(
        session ?? book.session,
        where: (t) => t.userId.equals(book.userId),
      );

  /// A second connection for the same user, so concurrent previews really
  /// race in PostgreSQL instead of sharing one session.
  Session newSession() {
    final session = server.authenticatedSession(book.userId);
    addTearDown(session.close);
    return session;
  }

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    provider = _PreviewProvider();
    registerEvmProvider(provider);
    WalletService.clock = () => _windowStart;
    WalletService.manualSyncThrottle = Duration.zero;
    book = await BudgetTestBook.create(server.anonymousSession());
    endpoint = WalletEndpoint();
    addTearDown(book.expectBalancesConsistent);
  });

  tearDown(WalletService.resetForTests);

  test(
    'when 20 previews are read in an hour then the 21st is refused',
    () async {
      for (var attempt = 1; attempt <= 20; attempt++) {
        final preview = await readPreview();
        expect(preview.networks.first.valueMinor, 100);
      }

      await expectLater(
        readPreview(),
        throwsA(isA<WalletPreviewRateLimitedException>()),
      );

      expect(
        provider.requests,
        hasLength(20),
        reason: 'the refused read never reaches the provider',
      );
      final row = (await windowRow())!;
      expect(row.windowStart, _windowStart);
      expect(row.requestCount, 21, reason: 'a refused read is still counted');
    },
  );

  test('when the server restarts then the spent hour is still spent', () async {
    for (var attempt = 1; attempt <= 20; attempt++) {
      await readPreview();
    }

    // A restart forgets every in-process static, including the provider
    // registry override. The window lives in PostgreSQL and survives it.
    WalletService.resetForTests();
    WalletService.clock = () => _windowStart;
    registerEvmProvider(provider);

    await expectLater(
      readPreview(),
      throwsA(isA<WalletPreviewRateLimitedException>()),
    );
    expect(provider.requests, hasLength(20));
    expect((await windowRow())!.requestCount, 21);
  });

  test('when an hour has passed then the window restarts at one', () async {
    for (var attempt = 1; attempt <= 20; attempt++) {
      await readPreview();
    }
    await expectLater(
      readPreview(),
      throwsA(isA<WalletPreviewRateLimitedException>()),
    );

    WalletService.clock = () => _windowStart.add(const Duration(minutes: 59));
    await expectLater(
      readPreview(),
      throwsA(isA<WalletPreviewRateLimitedException>()),
      reason: 'the window is an hour, not a sliding minute',
    );

    final nextWindow = _windowStart.add(const Duration(hours: 1));
    WalletService.clock = () => nextWindow;
    final preview = await readPreview();
    expect(preview.networks.first.valueMinor, 100);

    final row = (await windowRow())!;
    expect(row.windowStart, nextWindow);
    expect(row.requestCount, 1, reason: 'the new hour starts from one');
    expect(
      provider.requests,
      hasLength(21),
      reason: 'only the two refused reads stayed away from the provider',
    );
  });

  test('when 25 previews race then exactly 20 are read', () async {
    final sessions = [for (var index = 0; index < 25; index++) newSession()];

    Future<Object> attempt(Session session) async {
      try {
        return await readPreview(session: session);
      } on WalletPreviewRateLimitedException catch (error) {
        return error;
      }
    }

    final results = await Future.wait([
      for (final session in sessions) attempt(session),
    ]);

    expect(
      results.whereType<WalletPreview>(),
      hasLength(20),
      reason: 'the unique userId row serialises the concurrent upserts',
    );
    expect(
      results.whereType<WalletPreviewRateLimitedException>(),
      hasLength(5),
    );
    expect(provider.requests, hasLength(20));
    expect((await windowRow())!.requestCount, 25);
  });
}

/// A provider that answers one EVM network and records every request.
final class _PreviewProvider implements WalletProvider {
  final List<WalletReadRequest> requests = [];

  @override
  Future<WalletProviderSnapshot> fetchSnapshot(
    WalletReadRequest request,
  ) async {
    requests.add(request);
    return WalletProviderSnapshot(
      readNetworks: [WalletNetwork.ethereumMainnet],
      holdings: [
        WalletProviderHolding(
          network: WalletNetwork.ethereumMainnet,
          assetId: 'native',
          decimals: 18,
          quantityRaw: BigInt.parse(_ethQuantity),
          isNft: false,
          prices: [
            WalletProviderPrice(
              currencyCode: 'USD',
              source: PriceSource.jupiter,
              quality: PriceQuality.live,
              confidence: Confidence.high,
              asOf: DateTime.utc(2026),
              unitPrice: ExactDecimal.tryParse('1'),
            ),
          ],
        ),
      ],
      transactions: const [],
      warnings: const [],
    );
  }
}
