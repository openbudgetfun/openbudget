// Calendar dates are naturally written with their day component.
// ignore_for_file: avoid_redundant_argument_values

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/fx_rates/fx_service.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/reports/net_worth_service.dart';
import 'package:openbudget_server/src/reports/report_endpoint.dart';
import 'package:openbudget_server/src/settings/user_settings_service.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

import '../support/budget_test_book.dart';
import '../support/pg_test_server.dart';
import 'net_worth_helpers.dart';

final _now = DateTime.utc(2026, 6, 15, 12);
final _today = DateTime.utc(2026, 6, 15);

const _solUsdc = 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v';
const _ethUsdc = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48';
const _baseUsdc = '0x833589fcd6edb6e08f4c7c32d4f71b54bda02913';
const _scamToken = '0x00000000000000000000000000000000000dead1';

void main() {
  late PgTestServer server;
  late NetWorthFixture fixture;
  late List<DateTime> backfills;
  var serverStarted = false;
  var addressCounter = 0;

  setUpAll(() async {
    server = await PgTestServer.start();
    serverStarted = true;
  });

  tearDownAll(() async {
    if (serverStarted) await server.stop();
  });

  setUp(() async {
    backfills = [];
    FxService.configure(
      apiKey: null,
      baseUrl: null,
      clock: () => _now,
      backfillScheduler: (_, date) async {
        backfills.add(date);
      },
    );
    await server.clearRates();
    fixture = NetWorthFixture(
      server: server,
      book: await BudgetTestBook.create(
        server.anonymousSession(),
        baseCurrencyCode: 'USD',
        countryCode: 'US',
        timeZone: 'Europe/London',
      ),
    );
    // USD is the rate base. One USD buys 0.8 GBP, and 0.9 EUR, so one EUR
    // is 0.888888888889 GBP once the cross rate is rounded to 12 digits.
    await fixture.seedRates(_today, {'GBP': '0.8', 'EUR': '0.9'});
  });

  tearDown(FxService.resetForTests);

  Future<Wallet> addWallet({
    required WalletNetwork network,
    String accountCurrency = 'USD',
    Entity? entity,
  }) async {
    final owner = entity ?? fixture.entity;
    final account = await fixture.book.addAccount(
      name: 'Wallet ${network.name}',
      kind: AccountKind.crypto,
      currencyCode: accountCurrency,
      balanceSource: AccountBalanceSource.valuations,
      onBudget: false,
      entity: owner,
    );
    addressCounter += 1;
    return Wallet.db.insertRow(
      fixture.session,
      Wallet(
        entityId: owner.id!,
        accountId: account.id!,
        network: network,
        address: 'address-$addressCounter',
        syncStatus: SyncStatus.pending,
      ),
    );
  }

  Future<WalletHolding> addHolding(
    Wallet wallet, {
    required WalletNetwork network,
    required String assetId,
    int? valueMinor,
    String? symbol,
    String currencyCode = 'USD',
    SpamVerdict verdict = SpamVerdict.clean,
    PriceQuality quality = PriceQuality.live,
    HoldingPosition position = HoldingPosition.available,
  }) => WalletHolding.db.insertRow(
    fixture.session,
    WalletHolding(
      walletId: wallet.id!,
      network: network,
      assetId: assetId,
      position: position,
      symbol: symbol,
      decimals: 6,
      quantityRaw: BigInt.from(1000000),
      spamVerdict: verdict,
      priceCurrencyCode: valueMinor == null ? null : currencyCode,
      valueMinor: valueMinor,
      priceQuality: valueMinor == null ? PriceQuality.unpriced : quality,
    ),
  );

  Future<CryptoBreakdownView> breakdown(
    CryptoBreakdownGrouping grouping, {
    String currencyCode = 'GBP',
    Entity? entity,
  }) => NetWorthService.cryptoBreakdown(
    fixture.session,
    entityId: (entity ?? fixture.entity).id!,
    grouping: grouping,
    currencyCode: currencyCode,
  );

  /// Two wallets in two currencies:
  /// - the Solana wallet: SOL $150.00 and USDC $100.00;
  /// - the EVM wallet: ETH $200.00 and base ETH $10.00 in USD, USDC on
  ///   Ethereum €90.00 and on Base $30.00.
  Future<void> seedTwoWallets() async {
    final solana = await addWallet(network: WalletNetwork.solanaMainnet);
    await addHolding(
      solana,
      network: WalletNetwork.solanaMainnet,
      assetId: 'native',
      valueMinor: 15000,
    );
    await addHolding(
      solana,
      network: WalletNetwork.solanaMainnet,
      assetId: _solUsdc,
      valueMinor: 10000,
    );
    final evm = await addWallet(network: WalletNetwork.ethereumMainnet);
    await addHolding(
      evm,
      network: WalletNetwork.ethereumMainnet,
      assetId: 'native',
      valueMinor: 20000,
    );
    await addHolding(
      evm,
      network: WalletNetwork.baseMainnet,
      assetId: 'native',
      valueMinor: 1000,
    );
    await addHolding(
      evm,
      network: WalletNetwork.ethereumMainnet,
      assetId: _ethUsdc,
      valueMinor: 9000,
      currencyCode: 'EUR',
    );
    await addHolding(
      evm,
      network: WalletNetwork.baseMainnet,
      assetId: _baseUsdc,
      valueMinor: 3000,
    );
  }

  group('by chain', () {
    test('given two wallets in two currencies when the breakdown runs then '
        'the chain rows sum to the wallets counted value in the reporting '
        'currency', () async {
      await seedTwoWallets();

      final view = await breakdown(CryptoBreakdownGrouping.byChain);

      // Counted value per wallet and currency, converted once each:
      //   Solana $250.00 -> £200.00
      //   EVM    $240.00 -> £192.00
      //   EVM    €90.00  -> £80.00
      expect(view.currencyCode, 'GBP');
      expect(view.asOf, _today);
      expect(view.totalMinor, 20000 + 19200 + 8000);
      expect(view.walletCount, 2);
      expect(view.isComplete, isTrue);
      expect(view.missingCurrencyCodes, isEmpty);
      expect(view.hasStaleRates, isFalse);

      final byKey = {for (final row in view.rows) row.key: row};
      expect(byKey['solanaMainnet']!.valueMinor, 20000);
      expect(byKey['ethereumMainnet']!.valueMinor, 16000 + 8000);
      expect(byKey['baseMainnet']!.valueMinor, 800 + 2400);
      expect(view.rows.map((row) => row.key), [
        'ethereumMainnet',
        'solanaMainnet',
        'baseMainnet',
      ]);
      expect(
        view.rows.fold(0, (sum, row) => sum + row.valueMinor),
        view.totalMinor,
      );
      expect(
        view.rows.fold(0, (sum, row) => sum + row.shareBasisPoints),
        10000,
      );
    });

    test('given a USD wallet when net worth values its account then the '
        'breakdown total is the figure net worth converts', () async {
      final wallet = await addWallet(network: WalletNetwork.solanaMainnet);
      await addHolding(
        wallet,
        network: WalletNetwork.solanaMainnet,
        assetId: 'native',
        valueMinor: 12347,
      );
      await addHolding(
        wallet,
        network: WalletNetwork.solanaMainnet,
        assetId: _solUsdc,
        valueMinor: 7001,
      );
      final account = (await Account.db.findById(
        fixture.session,
        wallet.accountId,
      ))!;
      // The wallet sync stores the counted sum as the account's valuation.
      await fixture.setValuation(
        account: account,
        date: _today,
        valueMinor: 12347 + 7001,
      );

      final view = await breakdown(CryptoBreakdownGrouping.byAsset);
      final netWorth = await NetWorthService.current(
        fixture.session,
        entityIds: [fixture.entity.id!],
        currencyCode: 'GBP',
      );

      // 19348 * 0.8 = 15478.4 -> 15478; converting the two holdings apart
      // would give 9878 + 5601 = 15479.
      expect(netWorth.accounts.single.convertedMinor, 15478);
      expect(view.totalMinor, 15478);
      expect(
        view.rows.fold(0, (sum, row) => sum + row.valueMinor),
        15478,
      );
    });

    test(
      'given no reporting currency then the settings currency is used',
      () async {
        await seedTwoWallets();
        await UserSettingsService.setReportingCurrency(fixture.session, 'USD');

        final view = await NetWorthService.cryptoBreakdown(
          fixture.session,
          entityId: fixture.entity.id!,
          grouping: CryptoBreakdownGrouping.byChain,
        );

        expect(view.currencyCode, 'USD');
        // €90.00 at 1 / 0.9 is $100.00, so $250.00 + $240.00 + $100.00.
        expect(view.totalMinor, 25000 + 24000 + 10000);
      },
    );
  });

  group('by asset', () {
    test('given USDC on three networks when the breakdown runs then it is '
        'one row', () async {
      await seedTwoWallets();

      final view = await breakdown(CryptoBreakdownGrouping.byAsset);

      final usdc = view.rows.where((row) => row.symbol == 'USDC').toList();
      expect(usdc, hasLength(1));
      expect(usdc.single.key, 'asset:USDC');
      expect(
        usdc.single.networks,
        containsAll(<WalletNetwork>[
          WalletNetwork.solanaMainnet,
          WalletNetwork.ethereumMainnet,
          WalletNetwork.baseMainnet,
        ]),
      );
      expect(usdc.single.holdingCount, 3);
      // $100.00 -> £80.00, €90.00 -> £80.00, $30.00 -> £24.00; the Ethereum
      // wallet's $240.00 shares its £192.00 over four holdings, of which the
      // Base USDC's share is exactly £24.00.
      expect(usdc.single.valueMinor, 8000 + 8000 + 2400);
      expect(
        view.rows.map((row) => row.key),
        containsAll(<String>['asset:SOL', 'asset:ETH', 'asset:USDC']),
      );
      expect(view.rows.where((row) => row.key == 'asset:ETH'), hasLength(1));
      expect(
        view.rows.fold(0, (sum, row) => sum + row.valueMinor),
        view.totalMinor,
      );
      expect(view.totalMinor, 20000 + 19200 + 8000);
    });

    test('given grouping changes then the total does not', () async {
      await seedTwoWallets();

      final byChain = await breakdown(CryptoBreakdownGrouping.byChain);
      final byAsset = await breakdown(CryptoBreakdownGrouping.byAsset);

      expect(byAsset.totalMinor, byChain.totalMinor);
    });

    test('given an unlisted token on two networks then each network is its '
        'own row', () async {
      final wallet = await addWallet(network: WalletNetwork.ethereumMainnet);
      for (final network in [
        WalletNetwork.baseMainnet,
        WalletNetwork.arbitrumOne,
      ]) {
        await addHolding(
          wallet,
          network: network,
          assetId: '0xabc',
          symbol: 'GEM',
          valueMinor: 5000,
        );
      }

      final view = await breakdown(CryptoBreakdownGrouping.byAsset);

      expect(view.rows.map((row) => row.key), [
        'arbitrumOne:0xabc',
        'baseMainnet:0xabc',
      ]);
      expect(view.rows.first.symbol, 'GEM');
      expect(view.rows.first.assetId, '0xabc');
    });

    test('given eleven assets then the top eight are listed and the rest '
        'are Other', () async {
      final wallet = await addWallet(network: WalletNetwork.ethereumMainnet);
      for (var index = 1; index <= 11; index++) {
        await addHolding(
          wallet,
          network: WalletNetwork.baseMainnet,
          assetId: '0x${index.toString().padLeft(3, '0')}',
          symbol: 'T$index',
          valueMinor: index * 1000,
        );
      }

      final view = await breakdown(
        CryptoBreakdownGrouping.byAsset,
        currencyCode: 'USD',
      );

      expect(view.rows, hasLength(9));
      expect(view.rows.last.isOther, isTrue);
      expect(view.rows.last.valueMinor, 1000 + 2000 + 3000);
      expect(view.totalMinor, 66000);
    });
  });

  group('what counts', () {
    test('given suspected, hidden and unpriced holdings then they are '
        'excluded, and an allowed holding is counted', () async {
      final wallet = await addWallet(network: WalletNetwork.ethereumMainnet);
      const eth = WalletNetwork.ethereumMainnet;
      await addHolding(
        wallet,
        network: eth,
        assetId: 'native',
        valueMinor: 10000,
      );
      await addHolding(
        wallet,
        network: eth,
        assetId: _scamToken,
        valueMinor: 999999,
        symbol: 'CLAIM',
        verdict: SpamVerdict.suspected,
      );
      await addHolding(
        wallet,
        network: eth,
        assetId: '0x2',
        valueMinor: 555555,
        verdict: SpamVerdict.hiddenByUser,
      );
      await addHolding(
        wallet,
        network: eth,
        assetId: '0x3',
        valueMinor: 2500,
        verdict: SpamVerdict.allowedByUser,
        symbol: 'OKAY',
      );
      await addHolding(wallet, network: eth, assetId: '0x4');
      // A stored value with no price quality is not priced.
      await addHolding(
        wallet,
        network: eth,
        assetId: '0x5',
        valueMinor: 777777,
        quality: PriceQuality.unpriced,
      );
      await addHolding(
        wallet,
        network: eth,
        assetId: '0x6',
        valueMinor: 1500,
        quality: PriceQuality.cached,
        symbol: 'OLD',
      );

      final view = await breakdown(
        CryptoBreakdownGrouping.byAsset,
        currencyCode: 'USD',
      );

      expect(view.totalMinor, 10000 + 2500 + 1500);
      expect(
        view.rows.map((row) => row.symbol),
        ['ETH', 'OKAY', 'OLD'],
      );
    });

    test('given another entity wallet then it is not counted', () async {
      await seedTwoWallets();
      final other = await fixture.addEntity();
      final wallet = await addWallet(
        network: WalletNetwork.solanaMainnet,
        entity: other,
      );
      await addHolding(
        wallet,
        network: WalletNetwork.solanaMainnet,
        assetId: 'native',
        valueMinor: 999999,
      );

      final view = await breakdown(CryptoBreakdownGrouping.byChain);
      final otherView = await breakdown(
        CryptoBreakdownGrouping.byChain,
        entity: other,
      );

      expect(view.walletCount, 2);
      expect(view.totalMinor, 20000 + 19200 + 8000);
      expect(otherView.walletCount, 1);
      expect(otherView.totalMinor, 799999);
    });

    test('given no wallets then the view is empty and says so', () async {
      final view = await breakdown(CryptoBreakdownGrouping.byChain);

      expect(view.walletCount, 0);
      expect(view.rows, isEmpty);
      expect(view.totalMinor, 0);
      expect(view.isComplete, isTrue);
    });

    test(
      'given wallets but nothing counted then the view has no rows',
      () async {
        final wallet = await addWallet(network: WalletNetwork.solanaMainnet);
        await addHolding(
          wallet,
          network: WalletNetwork.solanaMainnet,
          assetId: _scamToken,
          valueMinor: 1000,
          verdict: SpamVerdict.suspected,
        );

        final view = await breakdown(CryptoBreakdownGrouping.byChain);

        expect(view.walletCount, 1);
        expect(view.rows, isEmpty);
        expect(view.totalMinor, 0);
      },
    );
  });

  group('rates', () {
    test('given a holding currency with no rate then it is left out, '
        'reported and a backfill is requested', () async {
      final wallet = await addWallet(network: WalletNetwork.ethereumMainnet);
      await addHolding(
        wallet,
        network: WalletNetwork.ethereumMainnet,
        assetId: 'native',
        valueMinor: 10000,
      );
      await addHolding(
        wallet,
        network: WalletNetwork.baseMainnet,
        assetId: 'native',
        valueMinor: 5000,
        currencyCode: 'JPY',
      );

      final view = await breakdown(CryptoBreakdownGrouping.byChain);

      expect(view.isComplete, isFalse);
      expect(view.missingCurrencyCodes, ['JPY']);
      expect(view.rows.single.key, 'ethereumMainnet');
      expect(view.totalMinor, 8000);
      expect(backfills, [_today]);
    });

    test('given an old rate then the view says the rates are stale', () async {
      await server.clearRates();
      await fixture.seedRates(_today.subtract(const Duration(days: 4)), {
        'GBP': '0.8',
      });
      final wallet = await addWallet(network: WalletNetwork.solanaMainnet);
      await addHolding(
        wallet,
        network: WalletNetwork.solanaMainnet,
        assetId: 'native',
        valueMinor: 10000,
      );

      final view = await breakdown(CryptoBreakdownGrouping.byChain);

      expect(view.hasStaleRates, isTrue);
      expect(view.totalMinor, 8000);
    });

    test('given the reporting currency equals the holding currency then '
        'no rate is needed', () async {
      await server.clearRates();
      final wallet = await addWallet(network: WalletNetwork.solanaMainnet);
      await addHolding(
        wallet,
        network: WalletNetwork.solanaMainnet,
        assetId: 'native',
        valueMinor: 12345,
      );

      final view = await breakdown(
        CryptoBreakdownGrouping.byChain,
        currencyCode: 'USD',
      );

      expect(view.totalMinor, 12345);
      expect(view.isComplete, isTrue);
    });
  });

  group('ownership', () {
    test('given another user entity then the call is forbidden, and a '
        'missing entity is not found', () async {
      final foreign = await fixture.addForeignEntity();

      await expectLater(
        ReportEndpoint().cryptoBreakdown(
          fixture.session,
          foreign.id!,
          CryptoBreakdownGrouping.byChain,
        ),
        throwsA(isA<ForbiddenException>()),
      );
      await expectLater(
        ReportEndpoint().cryptoBreakdown(
          fixture.session,
          const Uuid().v7obj(),
          CryptoBreakdownGrouping.byChain,
        ),
        throwsA(isA<NotFoundException>()),
      );
    });

    test(
      'given another user wallets then they never reach the view',
      () async {
        final foreign = await fixture.addForeignEntity();
        final wallet = await addWallet(
          network: WalletNetwork.solanaMainnet,
          entity: foreign,
        );
        await addHolding(
          wallet,
          network: WalletNetwork.solanaMainnet,
          assetId: 'native',
          valueMinor: 100000,
        );

        final view = await breakdown(CryptoBreakdownGrouping.byChain);

        expect(view.walletCount, 0);
        expect(view.totalMinor, 0);
      },
    );

    test(
      'given the endpoint and an owned entity then it returns the view',
      () async {
        await seedTwoWallets();

        final view = await ReportEndpoint().cryptoBreakdown(
          fixture.session,
          fixture.entity.id!,
          CryptoBreakdownGrouping.byAsset,
          currencyCode: 'GBP',
        );

        expect(view.grouping, CryptoBreakdownGrouping.byAsset);
        expect(view.totalMinor, 47200);
      },
    );

    test('given no login then the endpoint is rejected', () async {
      await expectLater(
        ReportEndpoint().cryptoBreakdown(
          server.anonymousSession(),
          fixture.entity.id!,
          CryptoBreakdownGrouping.byChain,
        ),
        throwsA(isA<AuthenticationRequiredException>()),
      );
    });
  });
}
