import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/wallets/wallet_endpoint.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/wallet_provider_registry.dart';
import 'package:openbudget_server/src/wallets/wallet_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../catalogue/catalogue_helpers.dart';
import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';

/// One EVM address is valid on every EVM network, so one wallet reads
/// several networks and a failed network keeps its facts
/// (multichain-wallets.md 8.1 and 8.3, task W1.5).
const _evmAddress = '0x1111111111111111111111111111111111111111';
const _ethQuantity = '1000000000000000000';

void main() {
  const evmAddress = _evmAddress;
  const twoNetworks = [
    WalletNetwork.ethereumMainnet,
    WalletNetwork.baseMainnet,
  ];
  const baseFailure = 'Base could not be reached.';
  const ethFailure = 'Ethereum could not be reached.';

  late PgTestServer server;
  late BudgetTestBook book;
  late WalletEndpoint endpoint;
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
    WalletService.clock = () => DateTime.utc(2026);
    book = await BudgetTestBook.create(server.anonymousSession());
    await book.session.caches.clear();
    await book.session.db.unsafeExecute('DELETE FROM asset_price');
    endpoint = WalletEndpoint();
    addTearDown(book.expectBalancesConsistent);
  });

  tearDown(() {
    WalletService.resetForTests();
    events.reset();
  });

  /// Registers [provider] as the EVM family's provider through the
  /// service's registry override, so connect accepts the family and every
  /// read goes through it.
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

  _RecordingProvider recordingProvider(
    Future<WalletProviderSnapshot> Function(
      WalletReadRequest request,
      int callNumber,
    )
    handler,
  ) => _RecordingProvider(handler);

  /// Connects an EVM wallet over [scanNetworks] with [provider] serving the
  /// initial sync too.
  Future<Wallet> connectEvm(
    WalletProvider provider, {
    List<WalletNetwork>? scanNetworks = twoNetworks,
  }) => endpoint.connect(
    book.session,
    book.entity.id!,
    WalletNetwork.ethereumMainnet,
    evmAddress,
    label: 'Vault',
    scanNetworks: scanNetworks,
  );

  Future<Wallet> reloadWallet(Wallet wallet) async {
    final row = await Wallet.db.findById(book.session, wallet.id!);
    if (row == null) throw StateError('Wallet disappeared');
    return row;
  }

  Future<List<WalletHolding>> holdings(Wallet wallet) => WalletHolding.db.find(
    book.session,
    where: (t) => t.walletId.equals(wallet.id),
  );

  Future<WalletNetworkState?> networkState(
    UuidValue walletId,
    WalletNetwork network,
  ) => WalletNetworkState.db.findFirstRow(
    book.session,
    where: (t) => t.walletId.equals(walletId) & t.network.equals(network),
  );

  Future<AccountValuation?> todayValuation(UuidValue accountId) =>
      AccountValuation.db.findFirstRow(
        book.session,
        where: (t) => t.accountId.equals(accountId),
      );

  group('Given a two-network EVM wallet sync', () {
    test('when one network fails then its holdings keep their quantities and '
        'the other network commits', () async {
      final provider = recordingProvider((request, call) async {
        if (call <= 2) {
          return _evmSnapshot(
            readNetworks: twoNetworks,
            holdings: [
              _evmHolding(
                network: WalletNetwork.ethereumMainnet,
                price: '2000',
              ),
              _evmHolding(
                network: WalletNetwork.baseMainnet,
                quantity: '2000000000000000000',
                price: '100',
              ),
            ],
          );
        }
        return _evmSnapshot(
          readNetworks: [WalletNetwork.ethereumMainnet],
          failedNetworks: {WalletNetwork.baseMainnet: baseFailure},
          holdings: [
            _evmHolding(
              network: WalletNetwork.ethereumMainnet,
              quantity: '1500000000000000000',
              price: '2000',
            ),
          ],
        );
      });
      registerEvmProvider(provider);
      final wallet = await connectEvm(provider);
      final first = await endpoint.sync(book.session, wallet.id!);
      expect(first.readNetworks, twoNetworks);
      expect(first.failedNetworks, isEmpty);

      final second = await endpoint.sync(book.session, wallet.id!);
      expect(second.readNetworks, [WalletNetwork.ethereumMainnet]);
      expect(second.failedNetworks, [WalletNetwork.baseMainnet]);

      final rows = await holdings(wallet);
      final ethereum = rows.firstWhere(
        (row) => row.network == WalletNetwork.ethereumMainnet,
      );
      final base = rows.firstWhere(
        (row) => row.network == WalletNetwork.baseMainnet,
      );
      // The read network's quantity was replaced; the failed network's
      // quantity stands and was priced again from its cached price.
      expect(ethereum.quantityRaw, BigInt.parse('1500000000000000000'));
      expect(ethereum.valueMinor, 300000);
      expect(base.quantityRaw, BigInt.parse('2000000000000000000'));
      expect(base.valueMinor, 20000);
      expect(base.priceQuality, PriceQuality.cached);

      final walletRow = await reloadWallet(wallet);
      expect(walletRow.syncStatus, SyncStatus.synced);
      expect(walletRow.lastSyncError, isNull);

      final ethereumState = await networkState(
        wallet.id!,
        WalletNetwork.ethereumMainnet,
      );
      expect(ethereumState!.lastReadAt, isNotNull);
      expect(ethereumState.lastError, isNull);
      final baseState = await networkState(
        wallet.id!,
        WalletNetwork.baseMainnet,
      );
      expect(
        baseState!.lastReadAt,
        isNotNull,
        reason: 'the failed network keeps its last successful read time',
      );
      expect(baseState.lastError, baseFailure);

      final valuation = await todayValuation(wallet.accountId);
      expect(valuation!.valueMinor, 320000);
      expect(second.totalValueMinor, 320000);
    });

    test('when every network fails then every fact stands', () async {
      final bothRead = _evmSnapshot(
        readNetworks: twoNetworks,
        holdings: [
          _evmHolding(
            network: WalletNetwork.ethereumMainnet,
            price: '2000',
          ),
          _evmHolding(
            network: WalletNetwork.baseMainnet,
            quantity: '2000000000000000000',
            price: '100',
          ),
        ],
      );
      final provider = recordingProvider((request, call) async {
        if (call <= 2) return bothRead;
        return _evmSnapshot(
          readNetworks: const [],
          failedNetworks: {
            WalletNetwork.ethereumMainnet: ethFailure,
            WalletNetwork.baseMainnet: baseFailure,
          },
        );
      });
      registerEvmProvider(provider);
      final wallet = await connectEvm(provider);
      await endpoint.sync(book.session, wallet.id!);
      final valuationBefore = await todayValuation(wallet.accountId);
      final holdingsBefore = await holdings(wallet);
      final ethStateBefore = await networkState(
        wallet.id!,
        WalletNetwork.ethereumMainnet,
      );
      final baseStateBefore = await networkState(
        wallet.id!,
        WalletNetwork.baseMainnet,
      );
      events.events.clear();

      await expectLater(
        endpoint.sync(book.session, wallet.id!),
        throwsA(
          isA<WalletProviderException>().having(
            (error) => error.message,
            'message',
            '$ethFailure $baseFailure',
          ),
        ),
      );

      // Every fact stands, down to the row's updatedAt: nothing was
      // rewritten.
      (
        WalletNetwork network,
        String assetId,
        BigInt quantityRaw,
        int? valueMinor,
        DateTime updatedAt,
      )
      factsOf(WalletHolding row) => (
        row.network,
        row.assetId,
        row.quantityRaw,
        row.valueMinor,
        row.updatedAt,
      );
      final rowsAfter = await holdings(wallet);
      expect(
        rowsAfter.map(factsOf),
        holdingsBefore.map(factsOf),
      );
      final valuationAfter = await todayValuation(wallet.accountId);
      expect(valuationAfter!.valueMinor, valuationBefore!.valueMinor);
      expect(valuationAfter.valuationDate, valuationBefore.valuationDate);
      expect(events.events, isEmpty, reason: 'nothing committed, no event');

      final walletRow = await reloadWallet(wallet);
      expect(walletRow.syncStatus, SyncStatus.failed);
      expect(walletRow.lastSyncError, '$ethFailure $baseFailure');

      final ethState = await networkState(
        wallet.id!,
        WalletNetwork.ethereumMainnet,
      );
      expect(ethState!.lastError, ethFailure);
      expect(ethState.lastReadAt, ethStateBefore!.lastReadAt);
      final baseState = await networkState(
        wallet.id!,
        WalletNetwork.baseMainnet,
      );
      expect(baseState!.lastError, baseFailure);
      expect(baseState.lastReadAt, baseStateBefore!.lastReadAt);
    });

    test('when a network leaves scanNetworks then its holdings are removed at '
        'the next read', () async {
      final provider = recordingProvider((request, call) async {
        if (call == 1) {
          return _evmSnapshot(
            readNetworks: twoNetworks,
            holdings: [
              _evmHolding(
                network: WalletNetwork.ethereumMainnet,
                price: '2000',
              ),
              _evmHolding(
                network: WalletNetwork.baseMainnet,
                quantity: '2000000000000000000',
                price: '100',
              ),
            ],
          );
        }
        return _evmSnapshot(
          readNetworks: [WalletNetwork.ethereumMainnet],
          holdings: [
            _evmHolding(
              network: WalletNetwork.ethereumMainnet,
              price: '2000',
            ),
          ],
        );
      });
      registerEvmProvider(provider);
      final wallet = await connectEvm(provider);
      expect(
        (await holdings(wallet)).map((row) => row.network),
        unorderedEquals(twoNetworks),
      );

      await endpoint.setScanNetworks(book.session, wallet.id!, [
        WalletNetwork.ethereumMainnet,
      ]);
      final result = await endpoint.sync(book.session, wallet.id!);

      expect(provider.requests.last.networks, [
        WalletNetwork.ethereumMainnet,
      ]);
      final rows = await holdings(wallet);
      expect(rows, hasLength(1));
      expect(rows.single.network, WalletNetwork.ethereumMainnet);
      expect(result.totalValueMinor, 200000);
      expect((await todayValuation(wallet.accountId))!.valueMinor, 200000);
    });
  });

  group('Given wallet.preview', () {
    test(
      'when one network fails then the others report what they hold',
      () async {
        final provider = recordingProvider(
          (request, _) async => _evmSnapshot(
            readNetworks: request.networks
                .where((network) => network != WalletNetwork.arbitrumOne)
                .toList(),
            failedNetworks: {
              WalletNetwork.arbitrumOne: 'Arbitrum could not be reached.',
            },
            holdings: [
              _evmHolding(
                network: WalletNetwork.ethereumMainnet,
                price: '2000',
              ),
              _evmHolding(
                network: WalletNetwork.baseMainnet,
                quantity: '5000000000000000000',
                price: '2',
              ),
              _evmHolding(network: WalletNetwork.baseMainnet, prices: const []),
            ],
          ),
        );
        registerEvmProvider(provider);

        final preview = await endpoint.preview(
          book.session,
          book.entity.id!,
          evmAddress,
        );

        expect(preview.address, evmAddress);
        expect(provider.requests.single.networks, [
          WalletNetwork.ethereumMainnet,
          WalletNetwork.baseMainnet,
          WalletNetwork.arbitrumOne,
          WalletNetwork.opMainnet,
          WalletNetwork.polygonPos,
          WalletNetwork.bnbSmartChain,
          WalletNetwork.avalancheCChain,
        ], reason: 'a preview reads every supported network of the family');
        expect(preview.networks, hasLength(7));
        final ethereum = preview.networks.first;
        expect(ethereum.network, WalletNetwork.ethereumMainnet);
        expect(ethereum.holdingCount, 1);
        expect(ethereum.pricedHoldingCount, 1);
        expect(ethereum.valueMinor, 200000);
        expect(ethereum.valueCurrencyCode, 'USD');
        expect(ethereum.readError, isNull);
        final base = preview.networks[1];
        expect(base.holdingCount, 2);
        expect(base.pricedHoldingCount, 1);
        expect(base.valueMinor, 1000);
        expect(base.readError, isNull);
        final arbitrum = preview.networks[2];
        expect(arbitrum.readError, 'Arbitrum could not be reached.');
        expect(arbitrum.holdingCount, 0);

        expect(
          await Wallet.db.find(
            book.session,
            where: (t) => t.entityId.equals(book.entity.id),
          ),
          isEmpty,
          reason: 'a preview writes nothing',
        );
      },
    );

    test('when the input is refused then no provider is reached', () async {
      var factoryCalls = 0;
      WalletService.debugRegistry = WalletProviderRegistry(
        registrations: {
          ChainFamily.evm: WalletProviderRegistration(
            factory: (session, network) {
              factoryCalls += 1;
              return recordingProvider(
                (_, _) async => _evmSnapshot(readNetworks: const []),
              );
            },
            hasSecret: (_, _) => true,
          ),
        },
      );
      const refusalMessage =
          "That's a private key. OpenBudget never needs it. Clear it, and "
          "don't share it with anyone.";
      const recoveryPhrase =
          'turn signal road gauge warm season steel crowd '
          'note shine claim autumn';

      await expectLater(
        endpoint.connect(
          book.session,
          book.entity.id!,
          WalletNetwork.ethereumMainnet,
          recoveryPhrase,
        ),
        throwsA(
          isA<ValidationException>().having(
            (error) => error.message,
            'message',
            refusalMessage,
          ),
        ),
      );
      await expectLater(
        endpoint.preview(book.session, book.entity.id!, recoveryPhrase),
        throwsA(isA<ValidationException>()),
      );
      await expectLater(
        endpoint.preview(book.session, book.entity.id!, 'not-an-address'),
        throwsA(isA<ValidationException>()),
      );
      expect(
        factoryCalls,
        0,
        reason: 'a refused input never reaches a provider',
      );
      expect(
        await Wallet.db.find(
          book.session,
          where: (t) => t.entityId.equals(book.entity.id),
        ),
        isEmpty,
      );
    });

    test(
      'when the 21st preview in an hour is asked then it is rejected',
      () async {
        final provider = recordingProvider(
          (request, _) async => _evmSnapshot(
            readNetworks: [WalletNetwork.ethereumMainnet],
            holdings: [
              _evmHolding(
                network: WalletNetwork.ethereumMainnet,
                price: '1',
              ),
            ],
          ),
        );
        registerEvmProvider(provider);

        for (var attempt = 1; attempt <= 20; attempt++) {
          final preview = await endpoint.preview(
            book.session,
            book.entity.id!,
            evmAddress,
          );
          expect(preview.networks.first.valueMinor, 100);
        }
        await expectLater(
          endpoint.preview(book.session, book.entity.id!, evmAddress),
          throwsA(isA<WalletPreviewRateLimitedException>()),
        );
        expect(
          provider.requests,
          hasLength(20),
          reason: 'the rejected preview never reaches the provider',
        );

        // Another user's hour is their own.
        final other = await BudgetTestBook.create(server.anonymousSession());
        addTearDown(other.session.close);
        final otherPreview = await endpoint.preview(
          other.session,
          other.entity.id!,
          evmAddress,
        );
        expect(otherPreview.networks.first.valueMinor, 100);
      },
    );

    test('when no reader is configured for the family then the preview is '
        'empty and no read happens', () async {
      // Only Solana is registered, and its secret is absent in tests, so an
      // EVM address has no supported network.
      WalletService.debugRegistry = WalletProviderRegistry.defaultRegistry;
      final preview = await endpoint.preview(
        book.session,
        book.entity.id!,
        evmAddress,
      );
      expect(preview.networks, isEmpty);
      expect(preview.warnings, ['No reader is set up for that chain yet.']);
    });
  });

  group('Given the new wallet endpoints', () {
    test('when supportedNetworks is asked then it lists each supported '
        "family's mainnets", () async {
      WalletService.debugRegistry = WalletProviderRegistry(
        registrations: {
          ChainFamily.evm: WalletProviderRegistration(
            factory: (_, _) => throw UnimplementedError(),
            hasSecret: (_, _) => true,
          ),
        },
      );
      expect(await endpoint.supportedNetworks(book.session), [
        WalletNetwork.ethereumMainnet,
        WalletNetwork.baseMainnet,
        WalletNetwork.arbitrumOne,
        WalletNetwork.opMainnet,
        WalletNetwork.polygonPos,
        WalletNetwork.bnbSmartChain,
        WalletNetwork.avalancheCChain,
      ]);

      WalletService.debugRegistry = WalletProviderRegistry(
        registrations: {
          ChainFamily.solana: WalletProviderRegistration(
            factory: (_, _) => throw UnimplementedError(),
            hasSecret: (_, _) => true,
          ),
        },
      );
      expect(
        await endpoint.supportedNetworks(book.session),
        [WalletNetwork.solanaMainnet],
        reason: 'the test network is never offered',
      );
    });

    test('when setScanNetworks replaces the list then the next read covers '
        'it, and an invalid list is refused', () async {
      final provider = recordingProvider((request, call) async {
        if (call == 1) {
          return _evmSnapshot(
            readNetworks: [WalletNetwork.ethereumMainnet],
            holdings: [
              _evmHolding(
                network: WalletNetwork.ethereumMainnet,
                price: '2000',
              ),
            ],
          );
        }
        return _evmSnapshot(readNetworks: [WalletNetwork.ethereumMainnet]);
      });
      registerEvmProvider(provider);
      final wallet = await connectEvm(provider, scanNetworks: null);
      expect(wallet.scanNetworks, isNull);
      expect(provider.requests.single.networks, [
        WalletNetwork.ethereumMainnet,
      ], reason: 'no scan list reads the home network only');

      final updated = await endpoint.setScanNetworks(
        book.session,
        wallet.id!,
        twoNetworks,
      );
      expect(updated.scanNetworks, twoNetworks);
      await endpoint.sync(book.session, wallet.id!);
      expect(provider.requests.last.networks, twoNetworks);

      for (final invalid in [
        [WalletNetwork.baseMainnet],
        [WalletNetwork.ethereumMainnet, WalletNetwork.ethereumMainnet],
        [WalletNetwork.ethereumMainnet, WalletNetwork.solanaMainnet],
      ]) {
        await expectLater(
          endpoint.setScanNetworks(book.session, wallet.id!, invalid),
          throwsA(isA<ValidationException>()),
        );
      }
      await expectLater(
        endpoint.connect(
          book.session,
          book.entity.id!,
          WalletNetwork.solanaMainnet,
          '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin',
          scanNetworks: twoNetworks,
        ),
        throwsA(isA<ValidationException>()),
        reason: 'only an EVM wallet reads more than one network',
      );
      await expectLater(
        endpoint.connect(
          book.session,
          book.entity.id!,
          WalletNetwork.baseMainnet,
          evmAddress,
        ),
        throwsA(isA<ValidationException>()),
        reason: 'an EVM wallet connects through Ethereum',
      );
    });

    test('when listNetworkStates is asked then every read network answers in '
        'display order', () async {
      final provider = recordingProvider((request, call) async {
        if (call == 1) {
          return _evmSnapshot(
            readNetworks: twoNetworks,
            holdings: [
              _evmHolding(
                network: WalletNetwork.ethereumMainnet,
                price: '2000',
              ),
            ],
          );
        }
        return _evmSnapshot(
          readNetworks: [WalletNetwork.ethereumMainnet],
          failedNetworks: {WalletNetwork.baseMainnet: baseFailure},
          holdings: [
            _evmHolding(
              network: WalletNetwork.ethereumMainnet,
              price: '2000',
            ),
          ],
        );
      });
      registerEvmProvider(provider);
      final wallet = await connectEvm(provider);
      await endpoint.sync(book.session, wallet.id!);
      await endpoint.sync(book.session, wallet.id!);

      final states = await endpoint.listNetworkStates(
        book.session,
        wallet.id!,
      );
      expect(states.map((state) => state.network), twoNetworks);
      expect(states.first.lastReadAt, isNotNull);
      expect(states.first.lastError, isNull);
      expect(states.last.lastError, baseFailure);
      expect(states.last.lastReadAt, isNotNull);
    });

    test('when a Solana wallet connects then it behaves as before', () async {
      WalletService.debugProviderFactory = (_, _) => recordingProvider(
        (_, _) async => WalletProviderSnapshot(
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
                  asOf: DateTime.utc(2026),
                  unitPrice: ExactDecimal.tryParse('150'),
                ),
              ],
            ),
          ],
          transactions: const [],
          warnings: const [],
        ),
      );
      final wallet = await endpoint.connect(
        book.session,
        book.entity.id!,
        WalletNetwork.solanaMainnet,
        '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin',
      );
      expect(wallet.syncStatus, SyncStatus.synced);
      expect(wallet.scanNetworks, isNull);
      expect(wallet.network, WalletNetwork.solanaMainnet);
      final result = await endpoint.sync(book.session, wallet.id!);
      expect(result.totalValueMinor, 15000);
      expect(result.readNetworks, [WalletNetwork.solanaMainnet]);
      expect(result.failedNetworks, isEmpty);
      final state = await networkState(wallet.id!, WalletNetwork.solanaMainnet);
      expect(state!.lastReadAt, isNotNull);
      expect(state.lastError, isNull);
    });
  });
}

WalletProviderSnapshot _evmSnapshot({
  required List<WalletNetwork> readNetworks,
  Map<WalletNetwork, String> failedNetworks = const {},
  List<WalletProviderHolding> holdings = const [],
}) => WalletProviderSnapshot(
  readNetworks: readNetworks,
  failedNetworks: failedNetworks,
  holdings: holdings,
  transactions: const [],
  warnings: const [],
);

WalletProviderHolding _evmHolding({
  required WalletNetwork network,
  String assetId = 'native',
  String quantity = _ethQuantity,
  int decimals = 18,
  String? price,
  List<WalletProviderPrice>? prices,
}) => WalletProviderHolding(
  network: network,
  assetId: assetId,
  decimals: decimals,
  quantityRaw: BigInt.parse(quantity),
  isNft: false,
  prices:
      prices ??
      [
        if (price != null)
          WalletProviderPrice(
            currencyCode: 'USD',
            source: PriceSource.jupiter,
            quality: PriceQuality.live,
            confidence: Confidence.high,
            asOf: DateTime.utc(2026),
            unitPrice: ExactDecimal.tryParse(price),
          ),
      ],
);

/// A fake provider that records every request so tests can assert on the
/// networks a read covered and script on call order.
final class _RecordingProvider implements WalletProvider {
  _RecordingProvider(this.handler);

  final Future<WalletProviderSnapshot> Function(
    WalletReadRequest request,
    int callNumber,
  )
  handler;
  final List<WalletReadRequest> requests = [];

  @override
  Future<WalletProviderSnapshot> fetchSnapshot(WalletReadRequest request) {
    final callNumber = requests.length + 1;
    requests.add(request);
    return handler(request, callNumber);
  }
}
