import 'dart:async';

import 'package:openbudget_core/openbudget_core.dart';
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

const _walletA = '9xQeWvG816bUx9EPjHmaT23yvVM2ZWbrrpZb9PusVFin';
const _walletB = '7dHbWXmci3dT8UFYWYZweBLXgycuY3iL6trKn1Y7ARj';
const _mint = 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';

void main() {
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

  Future<Wallet> connect({
    String address = _walletA,
    WalletNetwork network = WalletNetwork.solanaMainnet,
    WalletProvider? provider,
    String? label = 'Treasury',
    String? accountName = 'Crypto account',
  }) {
    WalletService.debugProviderFactory = (_, _) =>
        provider ?? _ScriptedProvider((_) async => _snapshot());
    return endpoint.connect(
      book.session,
      book.entity.id!,
      network,
      address,
      label: label,
      accountName: accountName,
    );
  }

  Future<Wallet> reloadWallet(Wallet wallet) async {
    final row = await Wallet.db.findById(book.session, wallet.id!);
    if (row == null) throw StateError('Wallet disappeared');
    return row;
  }

  Future<Account> reloadAccount(UuidValue accountId) async {
    final row = await Account.db.findById(book.session, accountId);
    if (row == null) throw StateError('Account disappeared');
    return row;
  }

  Future<AccountValuation?> todayValuation(UuidValue accountId) =>
      AccountValuation.db.findFirstRow(
        book.session,
        where: (t) =>
            t.accountId.equals(accountId) &
            t.valuationDate.equals(EntityClock.today(book.entity)),
      );

  group('Given WalletEndpoint connect', () {
    test(
      'when connecting atomically then creates a fixed crypto account',
      () async {
        final wallet = await connect();

        expect(wallet.entityId, book.entity.id);
        expect(wallet.network, WalletNetwork.solanaMainnet);
        expect(wallet.address, _walletA);
        expect(wallet.syncStatus, SyncStatus.synced);
        expect(wallet.lastSyncError, isNull);

        final account = await reloadAccount(wallet.accountId);
        expect(account.kind, AccountKind.crypto);
        expect(account.currencyCode, 'USD');
        expect(account.balanceSource, AccountBalanceSource.valuations);
        expect(account.onBudget, isFalse);
        expect(account.name, 'Crypto account');
        expect(account.balanceMinor, 15000);
      },
    );

    test(
      'when connecting twice then reuses the same wallet and account',
      () async {
        final first = await connect();
        final second = await connect(label: 'Renamed');

        expect(second.id, first.id);
        expect(second.accountId, first.accountId);
        expect(second.label, 'Renamed');
        final accounts = await Account.db.find(
          book.session,
          where: (t) => t.entityId.equals(book.entity.id),
        );
        expect(accounts, hasLength(1));
      },
    );

    test(
      'when two connects race then exactly one wallet and account win',
      () async {
        final provider = _ScriptedProvider((_) async => _snapshot());
        WalletService.debugProviderFactory = (_, _) => provider;

        final secondSession = server.authenticatedSession(book.userId);
        addTearDown(secondSession.close);
        final results = await Future.wait([
          endpoint.connect(
            book.session,
            book.entity.id!,
            WalletNetwork.solanaMainnet,
            _walletA,
          ),
          endpoint.connect(
            secondSession,
            book.entity.id!,
            WalletNetwork.solanaMainnet,
            _walletA,
          ),
        ]);

        expect(results.first.id, results.last.id);
        final wallets = await Wallet.db.find(
          book.session,
          where: (t) =>
              t.entityId.equals(book.entity.id) & t.address.equals(_walletA),
        );
        expect(wallets, hasLength(1));
        final accounts = await Account.db.find(
          book.session,
          where: (t) => t.entityId.equals(book.entity.id),
        );
        expect(accounts, hasLength(1));
      },
    );

    test('when the address is not 32 base58 bytes then rejects it', () async {
      for (final address in [
        '',
        'not-a-wallet',
        '0OIl',
        '1'.padRight(33, '1'),
      ]) {
        await expectLater(
          endpoint.connect(
            book.session,
            book.entity.id!,
            WalletNetwork.solanaMainnet,
            address,
          ),
          throwsA(isA<ValidationException>()),
        );
      }
      expect(
        await Wallet.db.find(
          book.session,
          where: (t) => t.entityId.equals(book.entity.id),
        ),
        isEmpty,
      );
    });

    test(
      'when another owner connects then rejects the foreign entity',
      () async {
        final foreign = await BudgetTestBook.create(server.anonymousSession());
        addTearDown(foreign.session.close);
        WalletService.debugProviderFactory = (_, _) =>
            _ScriptedProvider((_) async => _snapshot());

        await expectLater(
          endpoint.connect(
            book.session,
            foreign.entity.id!,
            WalletNetwork.solanaMainnet,
            _walletA,
          ),
          throwsA(isA<ForbiddenException>()),
        );
      },
    );

    test('when the entity is archived then rejects the write', () async {
      final archived = await book.addEntity(archivedAt: DateTime.utc(2026));
      WalletService.debugProviderFactory = (_, _) =>
          _ScriptedProvider((_) async => _snapshot());

      await expectLater(
        endpoint.connect(
          book.session,
          archived.id!,
          WalletNetwork.solanaMainnet,
          _walletA,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('when the initial sync fails then keeps the wallet usable', () async {
      final provider = _ScriptedProvider(
        (_) async => throw const WalletProviderException('rpc down'),
      );
      final wallet = await connect(provider: provider);

      expect(wallet.syncStatus, SyncStatus.failed);
      expect(wallet.lastSyncError, contains('rpc down'));
      expect(wallet.lastSignature, isNull);
      final account = await reloadAccount(wallet.accountId);
      expect(account.kind, AccountKind.crypto);
      expect(account.balanceMinor, 0);
    });

    test('when a later sync succeeds then clears the failed status', () async {
      final wallet = await connect(
        provider: _ScriptedProvider(
          (_) async => throw const WalletProviderException('rpc down'),
        ),
      );
      expect(wallet.syncStatus, SyncStatus.failed);

      WalletService.debugProviderFactory = (_, _) =>
          _ScriptedProvider((_) async => _snapshot());
      final synced = await endpoint.sync(book.session, wallet.id!);
      expect(synced.walletId, wallet.id);
      final reread = await reloadWallet(wallet);
      expect(reread.syncStatus, SyncStatus.synced);
      expect(reread.lastSyncError, isNull);
    });

    test('when the network is devnet then stores that network only', () async {
      final wallet = await connect(network: WalletNetwork.solanaDevnet);
      expect(wallet.network, WalletNetwork.solanaDevnet);
      expect(wallet.address, _walletA);
    });
  });

  group('Given WalletEndpoint reads', () {
    test('when another owner reads then rejects every path', () async {
      final foreign = await BudgetTestBook.create(server.anonymousSession());
      addTearDown(foreign.session.close);
      WalletService.debugProviderFactory = (_, _) => _ScriptedProvider(
        (_) async => _snapshot(transactions: [_transaction('sig-foreign')]),
      );
      final foreignWallet = await endpoint.connect(
        foreign.session,
        foreign.entity.id!,
        WalletNetwork.solanaMainnet,
        _walletB,
      );
      final transaction = (await endpoint.listTransactions(
        foreign.session,
        foreignWallet.id!,
      )).single;

      for (final call in [
        () => endpoint.list(book.session, foreign.entity.id!),
        () => endpoint.getForAccount(book.session, foreignWallet.accountId),
        () => endpoint.sync(book.session, foreignWallet.id!),
        () => endpoint.listHoldings(book.session, foreignWallet.id!),
        () => endpoint.listTransactions(book.session, foreignWallet.id!),
        () => endpoint.listTaxYearSummaries(book.session, foreignWallet.id!),
        () => endpoint.updateTransactionMetadata(
          book.session,
          transaction.id!,
          memo: 'mine now',
        ),
        () => endpoint.listNetworkStates(book.session, foreignWallet.id!),
        () => endpoint.setScanNetworks(book.session, foreignWallet.id!, null),
        () => endpoint.disconnect(book.session, foreignWallet.id!),
      ]) {
        await expectLater(call(), throwsA(isA<ForbiddenException>()));
      }
    });

    test('when ids are missing then every path is not found', () async {
      final missingWallet = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000001',
      );
      final missingAccount = UuidValue.fromString(
        '30000000-0000-4000-a000-000000000002',
      );
      for (final call in [
        () => endpoint.getForAccount(book.session, missingAccount),
        () => endpoint.sync(book.session, missingWallet),
        () => endpoint.listHoldings(book.session, missingWallet),
        () => endpoint.listTransactions(book.session, missingWallet),
        () => endpoint.listTaxYearSummaries(book.session, missingWallet),
        () => endpoint.disconnect(book.session, missingWallet),
      ]) {
        await expectLater(call(), throwsA(isA<NotFoundException>()));
      }
    });

    test('when listing one entity then returns its wallets only', () async {
      final wallet = await connect();
      final other = await book.addEntity(name: 'Other');
      WalletService.debugProviderFactory = (_, _) =>
          _ScriptedProvider((_) async => _snapshot());
      final otherWallet = await endpoint.connect(
        book.session,
        other.id!,
        WalletNetwork.solanaMainnet,
        _walletB,
      );

      final primary = await endpoint.list(book.session, book.entity.id!);
      final secondary = await endpoint.list(book.session, other.id!);
      expect(primary.map((wallet) => wallet.id), [wallet.id]);
      expect(secondary.map((wallet) => wallet.id), [otherWallet.id]);
      expect(
        await endpoint.getForAccount(book.session, wallet.accountId),
        isA<Wallet>().having((row) => row.id, 'id', wallet.id),
      );
    });
  });

  group('Given WalletEndpoint sync', () {
    test(
      'when syncing then values holdings exactly and writes today once',
      () async {
        final wallet = await connect(
          provider: _ScriptedProvider(
            (_) async => _snapshot(
              holdings: [
                _holding(
                  assetId: 'native',
                  quantity: '1500000000',
                  price: '150',
                ),
                _holding(
                  assetId: _mint,
                  decimals: 6,
                  quantity: '2000000',
                  price: '2.5',
                ),
              ],
            ),
          ),
        );

        final holdings = await endpoint.listHoldings(book.session, wallet.id!);
        expect(holdings.map((row) => row.assetId), ['native', _mint]);
        expect(holdings.first.quantityRaw, BigInt.from(1500000000));
        expect(holdings.first.unitPrice, '150');
        expect(holdings.first.valueMinor, 22500);
        expect(holdings.last.valueMinor, 500);
        expect(holdings.first.priceQuality, PriceQuality.live);

        final valuation = await todayValuation(wallet.accountId);
        expect(valuation, isNotNull);
        expect(valuation!.source, ValuationSource.wallet);
        expect(valuation.valueMinor, 23000);
        expect((await reloadAccount(wallet.accountId)).balanceMinor, 23000);

        final valuations = await AccountValuation.db.find(
          book.session,
          where: (t) => t.accountId.equals(wallet.accountId),
        );
        expect(valuations, hasLength(1));
      },
    );

    test(
      'when quantity exceeds 2^53 then persists and values it exactly',
      () async {
        final wallet = await connect(
          provider: _ScriptedProvider(
            (_) async => _snapshot(
              holdings: [
                _holding(
                  assetId: 'native',
                  quantity: '9007199254740993',
                  price: '1',
                ),
              ],
            ),
          ),
        );

        final holding = (await endpoint.listHoldings(
          book.session,
          wallet.id!,
        )).single;
        expect(holding.quantityRaw, BigInt.parse('9007199254740993'));
        expect(holding.valueMinor, 900719925);
        expect((await reloadAccount(wallet.accountId)).balanceMinor, 900719925);
      },
    );

    test('when a USD value needs rounding then rounds half up once', () async {
      final wallet = await connect(
        provider: _ScriptedProvider(
          (_) async => _snapshot(
            holdings: [
              _holding(
                assetId: _mint,
                decimals: 3,
                quantity: '1005',
                price: '1',
              ),
            ],
          ),
        ),
      );

      final holding = (await endpoint.listHoldings(
        book.session,
        wallet.id!,
      )).single;
      expect(holding.valueMinor, 101);
    });

    test(
      'when a holding is an NFT then keeps token program and metadata',
      () async {
        final wallet = await connect(
          provider: _ScriptedProvider(
            (_) async => _snapshot(
              holdings: [
                _holding(
                  assetId: 'native',
                  quantity: '1000000000',
                  price: '150',
                ),
                _holding(
                  assetId: _walletB,
                  decimals: 0,
                  quantity: '1',
                  price: '5',
                  isNft: true,
                  tokenProgram: 'TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA',
                  symbol: 'EAR',
                  name: 'Earring',
                  metadataJson: '{"interface":"V1_NFT"}',
                ),
              ],
            ),
          ),
        );

        final result = await endpoint.sync(book.session, wallet.id!);
        expect(result.holdingCount, 2);
        expect(result.pricedHoldingCount, 2);
        expect(result.nftHoldingCount, 1);
        expect(result.pricedNftHoldingCount, 1);
        expect(result.unpricedHoldingCount, 0);
        expect(result.valuationCoverageRatio, 1);
        expect(result.totalValueMinor, 15500);

        final nft = (await endpoint.listHoldings(
          book.session,
          wallet.id!,
        )).firstWhere((row) => row.isNft);
        expect(nft.tokenProgram, startsWith('Tokenkeg'));
        expect(nft.metadataJson, contains('V1_NFT'));
        expect(nft.symbol, 'EAR');
        expect(nft.name, 'Earring');
      },
    );

    test(
      'when the provider has no price then marks unpriced and warns',
      () async {
        final wallet = await connect(
          provider: _ScriptedProvider(
            (_) async => _snapshot(
              holdings: [
                _holding(assetId: _mint, prices: const []),
              ],
            ),
          ),
        );

        final result = await endpoint.sync(book.session, wallet.id!);
        expect(result.pricedHoldingCount, 0);
        expect(result.unpricedHoldingCount, 1);
        expect(result.valuationCoverageRatio, 0);
        expect(result.totalValueMinor, 0);
        expect(
          result.warnings,
          contains('Missing price for asset $_mint'),
        );
        final holding = (await endpoint.listHoldings(
          book.session,
          wallet.id!,
        )).single;
        expect(holding.priceQuality, PriceQuality.unpriced);
        expect(holding.valueMinor, isNull);
        expect((await reloadAccount(wallet.accountId)).balanceMinor, 0);
      },
    );

    test(
      'when a fresh quote disappears then reuses it as clearly cached',
      () async {
        final wallet = await connect(
          provider: _ScriptedProvider(
            (_) async => _snapshot(
              holdings: [
                _holding(assetId: 'native', quantity: '1000000000', price: '2'),
              ],
            ),
          ),
        );
        WalletService.debugProviderFactory = (_, _) => _ScriptedProvider(
          (_) async => _snapshot(
            holdings: [
              _holding(
                assetId: 'native',
                quantity: '1000000000',
                prices: const [],
              ),
            ],
          ),
        );

        final result = await endpoint.sync(book.session, wallet.id!);
        expect(result.pricedHoldingCount, 0);
        expect(result.cachedHoldingCount, 1);
        expect(result.unpricedHoldingCount, 0);
        expect(result.valuationCoverageRatio, 1);
        expect(result.totalValueMinor, 200);
        expect(result.warnings.join(' '), contains('Using cached price'));
        final holding = (await endpoint.listHoldings(
          book.session,
          wallet.id!,
        )).single;
        expect(holding.priceQuality, PriceQuality.cached);
        expect(holding.priceConfidence, Confidence.low);
        expect(holding.unitPrice, '2');
        expect(holding.valueMinor, 200);
        expect((await reloadAccount(wallet.accountId)).balanceMinor, 200);
      },
    );

    test(
      'when a quote is malformed then ignores it without losing the sync',
      () async {
        final wallet = await connect(
          provider: _ScriptedProvider(
            (_) async => _snapshot(
              holdings: [
                _holding(
                  assetId: _mint,
                  prices: [
                    _providerPrice(
                      unitPrice: ExactDecimal.tryParse('2'),
                      currencyCode: 'GBP',
                    ),
                    _providerPrice(),
                  ],
                ),
              ],
            ),
          ),
        );

        final result = await endpoint.sync(book.session, wallet.id!);
        expect(result.unpricedHoldingCount, 1);
        expect(result.warnings.join(' '), contains('Ignoring GBP price'));
        expect(result.warnings.join(' '), contains('invalid provider price'));
      },
    );

    test(
      'when the provider fails entirely then keeps the last facts',
      () async {
        final wallet = await connect(
          provider: _ScriptedProvider(
            (_) async => _snapshot(
              holdings: [
                _holding(
                  assetId: 'native',
                  quantity: '2000000000',
                  price: '100',
                ),
              ],
            ),
          ),
        );
        final before = (await endpoint.listHoldings(
          book.session,
          wallet.id!,
        )).single;
        final valuationBefore = await todayValuation(wallet.accountId);
        events.events.clear();

        WalletService.debugProviderFactory = (_, _) => _ScriptedProvider(
          (_) async => throw const WalletProviderException('chain offline'),
        );
        await expectLater(
          endpoint.sync(book.session, wallet.id!),
          throwsA(isA<WalletProviderException>()),
        );

        final after = (await endpoint.listHoldings(
          book.session,
          wallet.id!,
        )).single;
        expect(after.valueMinor, before.valueMinor);
        expect(after.quantityRaw, before.quantityRaw);
        expect(
          (await todayValuation(wallet.accountId))!.valueMinor,
          valuationBefore!.valueMinor,
        );
        expect((await reloadAccount(wallet.accountId)).balanceMinor, 20000);
        final failed = await reloadWallet(wallet);
        expect(failed.syncStatus, SyncStatus.failed);
        expect(failed.lastSyncError, contains('chain offline'));
        expect(events.events, isEmpty);
      },
    );

    test(
      'when the provider is late then does not overwrite newer facts',
      () async {
        final firstStarted = Completer<void>();
        final releaseFirst = Completer<void>();
        var calls = 0;
        final provider = _ScriptedProvider((until) async {
          calls += 1;
          if (calls == 1) {
            firstStarted.complete();
            await releaseFirst.future;
            return _snapshot(
              holdings: [
                _holding(assetId: 'native', quantity: '1000000000', price: '1'),
              ],
            );
          }
          return _snapshot(
            holdings: [
              _holding(assetId: 'native', quantity: '1000000000', price: '2'),
            ],
          );
        });
        final wallet = await connect();
        WalletService.debugProviderFactory = (_, _) => provider;
        final first = endpoint.sync(book.session, wallet.id!);
        await firstStarted.future;
        final secondSession = server.authenticatedSession(book.userId);
        addTearDown(secondSession.close);
        final second = await endpoint.sync(secondSession, wallet.id!);
        expect(second.totalValueMinor, 200);

        releaseFirst.complete();
        final late = await first;
        final holding = (await endpoint.listHoldings(
          book.session,
          wallet.id!,
        )).single;
        expect(holding.valueMinor, 200);
        expect(holding.unitPrice, '2');
        expect(late.totalValueMinor, 200);
      },
    );

    test(
      'when the entity is archived then rejects the sync before fetching',
      () async {
        var calls = 0;
        final provider = _ScriptedProvider((_) async {
          calls += 1;
          return _snapshot();
        });
        final wallet = await connect(provider: provider);
        await Entity.db.updateRow(
          book.session,
          book.entity.copyWith(archivedAt: DateTime.utc(2026)),
        );
        calls = 0;

        await expectLater(
          endpoint.sync(book.session, wallet.id!),
          throwsA(isA<ValidationException>()),
        );
        expect(calls, 0);
      },
    );

    test('when the commit is unsafe then rolls back the whole sync', () async {
      final wallet = await connect(
        provider: _ScriptedProvider(
          (_) async => _snapshot(
            holdings: [
              _holding(assetId: 'native', quantity: '1000000000', price: '1'),
            ],
          ),
        ),
      );
      events.events.clear();
      WalletService.debugProviderFactory = (_, _) => _ScriptedProvider(
        (_) async => _snapshot(
          holdings: [
            _holding(
              assetId: 'native',
              quantity: '1000000000',
              price: '1000000000000000000',
            ),
          ],
        ),
      );

      await expectLater(
        endpoint.sync(book.session, wallet.id!),
        throwsA(isA<ValidationException>()),
      );
      final holding = (await endpoint.listHoldings(
        book.session,
        wallet.id!,
      )).single;
      expect(holding.valueMinor, 100);
      expect((await reloadAccount(wallet.accountId)).balanceMinor, 100);
      expect(events.events, isEmpty);
    });
  });

  group('Given WalletEndpoint transactions', () {
    test(
      'when syncing twice then upserts by signature without duplicates',
      () async {
        final provider = _ScriptedProvider((until) async {
          if (until == null) {
            return _snapshot(
              transactions: [
                _transaction('sig-b', occurredAt: DateTime.utc(2026, 2, 2)),
                _transaction('sig-a', occurredAt: DateTime.utc(2026, 2)),
              ],
            );
          }
          if (until == 'sig-b') {
            return _snapshot(
              transactions: [
                _transaction('sig-c', occurredAt: DateTime.utc(2026, 2, 3)),
              ],
            );
          }
          return _snapshot();
        });
        final wallet = await connect(provider: provider);
        expect((await reloadWallet(wallet)).lastSignature, 'sig-b');

        final second = await endpoint.sync(book.session, wallet.id!);
        expect(second.insertedTransactions, 1);
        expect(provider.untils, [null, 'sig-b']);
        final rows = await endpoint.listTransactions(book.session, wallet.id!);
        expect(rows.map((row) => row.signature), ['sig-c', 'sig-b', 'sig-a']);

        final third = await endpoint.sync(book.session, wallet.id!);
        expect(third.insertedTransactions, 0);
        expect(third.updatedTransactions, 0);
        expect(
          await WalletTransaction.db.find(
            book.session,
            where: (t) => t.walletId.equals(wallet.id),
          ),
          hasLength(3),
        );
      },
    );

    test('when a later page fails then keeps the cursor and facts', () async {
      final provider = _ScriptedProvider((until) async {
        if (until == null) {
          return _snapshot(
            transactions: [_transaction('sig-a')],
            newestSignature: 'sig-a',
          );
        }
        throw const WalletProviderException('page two failed');
      });
      final wallet = await connect(provider: provider);
      WalletService.debugProviderFactory = (_, _) => provider;

      await expectLater(
        endpoint.sync(book.session, wallet.id!),
        throwsA(isA<WalletProviderException>()),
      );
      expect((await reloadWallet(wallet)).lastSignature, 'sig-a');
      expect(
        await endpoint.listTransactions(book.session, wallet.id!),
        hasLength(1),
      );
    });

    test('when re-syncing then preserves user metadata', () async {
      const signature = 'sig-metadata';
      final provider = _ScriptedProvider(
        (_) async => _snapshot(
          transactions: [_transaction(signature, description: 'first')],
        ),
      );
      final wallet = await connect(provider: provider);
      final transaction = (await endpoint.listTransactions(
        book.session,
        wallet.id!,
      )).single;

      final updated = await endpoint.updateTransactionMetadata(
        book.session,
        transaction.id!,
        category: '  Income ',
        tags: const [' a ', 'a', 'b'],
        memo: ' note ',
      );
      expect(updated.category, 'Income');
      expect(updated.tags, ['a', 'b']);
      expect(updated.memo, 'note');

      WalletService.debugProviderFactory = (_, _) => _ScriptedProvider(
        (_) async => _snapshot(
          transactions: [_transaction(signature, description: 'second')],
        ),
      );
      await endpoint.sync(book.session, wallet.id!);
      final reread = (await endpoint.listTransactions(
        book.session,
        wallet.id!,
      )).single;
      expect(reread.description, 'second');
      expect(reread.category, 'Income');
      expect(reread.tags, ['a', 'b']);
      expect(reread.memo, 'note');

      final cleared = await endpoint.updateTransactionMetadata(
        book.session,
        transaction.id!,
        category: '',
        tags: const [],
        memo: '',
      );
      expect(cleared.category, isNull);
      expect(cleared.tags, isEmpty);
      expect(cleared.memo, isNull);

      await expectLater(
        endpoint.updateTransactionMetadata(
          book.session,
          transaction.id!,
          tags: ['x' * 51],
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test(
      'when listing then bounds limits and pages deterministically',
      () async {
        final wallet = await connect(
          provider: _ScriptedProvider(
            (_) async => _snapshot(
              transactions: [
                _transaction('sig-null'),
                _transaction('sig-4', occurredAt: DateTime.utc(2026, 2, 4)),
                _transaction('sig-3', occurredAt: DateTime.utc(2026, 2, 3)),
                _transaction('sig-2', occurredAt: DateTime.utc(2026, 2, 2)),
                _transaction('sig-1', occurredAt: DateTime.utc(2026, 2)),
              ],
            ),
          ),
        );

        final page = await endpoint.listTransactions(
          book.session,
          wallet.id!,
          limit: 2,
        );
        expect(page.map((row) => row.signature), ['sig-4', 'sig-3']);
        final next = await endpoint.listTransactions(
          book.session,
          wallet.id!,
          before: DateTime.utc(2026, 2, 3),
          limit: 2,
        );
        expect(next.map((row) => row.signature), ['sig-2', 'sig-1']);
        final all = await endpoint.listTransactions(book.session, wallet.id!);
        expect(all.last.signature, 'sig-null');

        for (final limit in [0, 201]) {
          await expectLater(
            endpoint.listTransactions(book.session, wallet.id!, limit: limit),
            throwsA(isA<ValidationException>()),
          );
        }
      },
    );

    test('when tax years span a fiscal year then groups exactly', () async {
      final wallet = await connect(
        provider: _ScriptedProvider(
          (_) async => _snapshot(
            holdings: [
              _holding(
                assetId: _mint,
                decimals: 6,
                quantity: '0',
                price: '10',
              ),
            ],
            transactions: [
              _transaction(
                'buy',
                occurredAt: DateTime.utc(2025, 5),
                amount: '2000000',
                from: _walletB,
                to: _walletA,
              ),
              _transaction(
                'sell-2025',
                occurredAt: DateTime.utc(2025, 6),
                from: _walletA,
                to: _walletB,
              ),
              _transaction(
                'sell-2026',
                occurredAt: DateTime.utc(2026, 6),
                from: _walletA,
                to: _walletB,
              ),
              _transaction('unknown'),
            ],
          ),
        ),
      );

      final summaries = await endpoint.listTaxYearSummaries(
        book.session,
        wallet.id!,
      );
      expect(summaries.map((row) => row.taxYear), [2026, 2025]);
      expect(summaries.map((row) => row.pnlCurrencyCode), ['USD', 'USD']);
      for (final summary in summaries) {
        expect(summary.transactionCount, 1);
        expect(summary.proceedsMinor, 1000);
        expect(summary.costBasisMinor, 1000);
        expect(summary.realizedPnlMinor, 0);
      }
    });
  });

  group('Given WalletEndpoint disconnect', () {
    test(
      'when deleteAccount is false then keeps the account and history',
      () async {
        final wallet = await connect();
        final valuation = await todayValuation(wallet.accountId);

        await endpoint.disconnect(book.session, wallet.id!);

        expect(await Wallet.db.findById(book.session, wallet.id!), isNull);
        final account = await reloadAccount(wallet.accountId);
        expect(account.balanceMinor, 15000);
        expect(
          (await todayValuation(wallet.accountId))!.valueMinor,
          valuation!.valueMinor,
        );
      },
    );

    test(
      'when deleteAccount is true then removes the wallet and account',
      () async {
        final wallet = await connect();

        await endpoint.disconnect(
          book.session,
          wallet.id!,
          deleteAccount: true,
        );

        expect(await Wallet.db.findById(book.session, wallet.id!), isNull);
        expect(
          await Account.db.findById(book.session, wallet.accountId),
          isNull,
        );
        expect(await todayValuation(wallet.accountId), isNull);
      },
    );
  });

  group('Given wallet events', () {
    test('when a sync commits then publishes only after the commit', () async {
      final wallet = await connect();
      events.events.clear();
      WalletService.debugProviderFactory = (_, _) => _ScriptedProvider(
        (_) async => _snapshot(
          holdings: [
            _holding(assetId: 'native', quantity: '1000000000', price: '200'),
          ],
        ),
      );

      await endpoint.sync(book.session, wallet.id!);

      expect(
        events.events.map((event) => event.scope),
        [ChangeScope.accounts, ChangeScope.transactions],
      );
      expect(
        events.events.every((event) => event.accountId == wallet.accountId),
        isTrue,
      );
    });

    test(
      'when connect creates the account then publishes an account event',
      () async {
        await connect();
        expect(events.events.first.scope, ChangeScope.accounts);
        expect(events.events.first.accountId, isNotNull);
      },
    );
  });
}

WalletProviderSnapshot _snapshot({
  List<WalletProviderHolding>? holdings,
  List<WalletProviderTransaction>? transactions,
  String? newestSignature,
  List<String> warnings = const [],
  WalletNetwork network = WalletNetwork.solanaMainnet,
}) {
  final txRows = transactions ?? const <WalletProviderTransaction>[];
  return WalletProviderSnapshot(
    readNetworks: [network],
    holdings:
        holdings ??
        [
          _holding(assetId: 'native', quantity: '1000000000', price: '150'),
        ],
    transactions: txRows,
    newestSignature:
        newestSignature ?? (txRows.isEmpty ? null : txRows.first.signature),
    warnings: warnings,
  );
}

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
}) => WalletProviderPrice(
  currencyCode: currencyCode,
  source: PriceSource.jupiter,
  quality: PriceQuality.live,
  confidence: Confidence.high,
  asOf: DateTime.utc(2026),
  unitPrice: unitPrice,
  totalPrice: totalPrice,
);

WalletProviderTransaction _transaction(
  String signature, {
  DateTime? occurredAt,
  String amount = '1000000',
  String? from,
  String? to,
  String description = 'Transfer',
}) => WalletProviderTransaction(
  signature: signature,
  slot: signature.hashCode,
  occurredAt: occurredAt,
  description: description,
  txType: 'TRANSFER',
  source: 'SYSTEM_PROGRAM',
  interpretationConfidence: Confidence.medium,
  movements: [
    WalletProviderMovement(
      mint: _mint,
      fromAccount: from ?? _walletB,
      toAccount: to ?? _walletA,
      amountRaw: BigInt.parse(amount),
    ),
  ],
  tokenTransfersJson:
      '[{"mint":"$_mint","fromUserAccount":"${from ?? _walletB}",'
      '"toUserAccount":"${to ?? _walletA}","tokenAmount":$amount}]',
  rawJson: '{"signature":"$signature"}',
);

ExactDecimal _exact(String value) => ExactDecimal.tryParse(value)!;

final class _ScriptedProvider implements WalletProvider {
  _ScriptedProvider(this.handler);

  final Future<WalletProviderSnapshot> Function(String? until) handler;
  final List<String?> untils = [];

  @override
  Future<WalletProviderSnapshot> fetchSnapshot(WalletReadRequest request) {
    untils.add(request.untilSignature);
    return handler(request.untilSignature);
  }
}
