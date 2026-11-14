import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/reports/crypto_breakdown.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

const _usdc = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48';
const _baseUsdc = '0x833589fcd6edb6e08f4c7c32d4f71b54bda02913';
final _walletA = UuidValue.fromString('00000000-0000-4000-8000-00000000000a');
final _walletB = UuidValue.fromString('00000000-0000-4000-8000-00000000000b');

CountedHolding _holding(
  WalletNetwork network,
  String assetId,
  int valueMinor, {
  String currencyCode = 'USD',
  String? symbol,
  UuidValue? walletId,
}) => CountedHolding(
  walletId: walletId ?? _walletA,
  network: network,
  assetId: assetId,
  symbol: symbol,
  name: symbol,
  currencyCode: currencyCode,
  valueMinor: valueMinor,
);

/// One USD is two units of the reporting currency; every other code has no
/// rate.
int? _doubleUsd(String code, int amount) => code == 'USD' ? amount * 2 : null;

int? _identity(String code, int amount) => amount;

CryptoBreakdownResult _build(
  List<CountedHolding> holdings,
  CryptoBreakdownGrouping grouping, {
  MinorConverter convert = _identity,
}) => CryptoBreakdownBuilder.build(
  holdings: holdings,
  grouping: grouping,
  convert: convert,
);

void main() {
  group('by chain', () {
    test('given holdings on two networks then each network is one row, '
        'largest first, with shares that add up to 10000', () {
      final result = _build(
        [
          _holding(WalletNetwork.solanaMainnet, 'native', 1000),
          _holding(WalletNetwork.solanaMainnet, 'mint', 1000),
          _holding(WalletNetwork.baseMainnet, 'native', 500),
          _holding(WalletNetwork.ethereumMainnet, 'native', 500),
        ],
        CryptoBreakdownGrouping.byChain,
      );

      expect(result.rows.map((row) => row.key), [
        'solanaMainnet',
        'baseMainnet',
        'ethereumMainnet',
      ]);
      expect(result.rows.map((row) => row.valueMinor), [2000, 500, 500]);
      expect(result.rows.first.holdingCount, 2);
      expect(result.rows.first.networks, [WalletNetwork.solanaMainnet]);
      expect(result.rows.first.symbol, isNull);
      expect(result.totalMinor, 3000);
      expect(
        result.rows.fold(0, (sum, row) => sum + row.shareBasisPoints),
        10000,
      );
      expect(result.rows.map((row) => row.shareBasisPoints), [
        6667,
        1667,
        1666,
      ]);
    });

    test('given an empty set then there are no rows and a zero total', () {
      final result = _build(const [], CryptoBreakdownGrouping.byChain);

      expect(result.rows, isEmpty);
      expect(result.totalMinor, 0);
      expect(result.missingCurrencyCodes, isEmpty);
    });

    test('given a zero-valued holding then it makes no row', () {
      final result = _build(
        [_holding(WalletNetwork.solanaMainnet, 'native', 0)],
        CryptoBreakdownGrouping.byChain,
      );

      expect(result.rows, isEmpty);
    });
  });

  group('by asset', () {
    test('given USDC on three networks then it is one row listing them, '
        'the biggest contributor first', () {
      final result = _build(
        [
          _holding(
            WalletNetwork.solanaMainnet,
            'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
            100,
          ),
          _holding(WalletNetwork.ethereumMainnet, _usdc, 700),
          _holding(WalletNetwork.baseMainnet, _baseUsdc, 200),
          _holding(WalletNetwork.baseMainnet, 'native', 50),
        ],
        CryptoBreakdownGrouping.byAsset,
      );

      final usdc = result.rows.first;
      expect(usdc.key, 'asset:USDC');
      expect(usdc.symbol, 'USDC');
      expect(usdc.name, 'USD Coin');
      expect(usdc.assetId, isNull);
      expect(usdc.valueMinor, 1000);
      expect(usdc.holdingCount, 3);
      expect(usdc.networks, [
        WalletNetwork.ethereumMainnet,
        WalletNetwork.baseMainnet,
        WalletNetwork.solanaMainnet,
      ]);
      expect(result.rows, hasLength(2));
    });

    test('given ETH on Ethereum, Base and Arbitrum then the native coin '
        'is one row named by its ticker, apart from WETH', () {
      final result = _build(
        [
          _holding(WalletNetwork.ethereumMainnet, 'native', 300),
          _holding(WalletNetwork.baseMainnet, 'native', 200),
          _holding(WalletNetwork.arbitrumOne, 'native', 100),
          _holding(
            WalletNetwork.ethereumMainnet,
            '0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2',
            50,
          ),
        ],
        CryptoBreakdownGrouping.byAsset,
      );

      expect(result.rows.map((row) => row.key), ['asset:ETH', 'asset:WETH']);
      expect(result.rows.first.valueMinor, 600);
      expect(result.rows.first.name, isNull);
      expect(result.rows.first.networks, hasLength(3));
    });

    test('given the same unknown token id on two networks then they stay '
        'separate rows, and two tokens sharing a ticker stay apart', () {
      final result = _build(
        [
          _holding(WalletNetwork.baseMainnet, '0xaaa', 300, symbol: 'PEPE'),
          _holding(
            WalletNetwork.arbitrumOne,
            '0xaaa',
            200,
            symbol: 'PEPE',
          ),
          _holding(WalletNetwork.baseMainnet, '0xbbb', 100, symbol: 'PEPE'),
        ],
        CryptoBreakdownGrouping.byAsset,
      );

      expect(result.rows.map((row) => row.key), [
        'baseMainnet:0xaaa',
        'arbitrumOne:0xaaa',
        'baseMainnet:0xbbb',
      ]);
      expect(result.rows.first.assetId, '0xaaa');
      expect(result.rows.first.symbol, 'PEPE');
      expect(result.rows.first.networks, [WalletNetwork.baseMainnet]);
    });

    test('given a staked and an available position of one asset then they '
        'are one row', () {
      final result = _build(
        [
          _holding(WalletNetwork.solanaMainnet, 'native', 700),
          _holding(WalletNetwork.solanaMainnet, 'native', 300),
        ],
        CryptoBreakdownGrouping.byAsset,
      );

      expect(result.rows.single.key, 'asset:SOL');
      expect(result.rows.single.valueMinor, 1000);
      expect(result.rows.single.holdingCount, 2);
    });

    List<CountedHolding> tokens(int count) => [
      for (var index = 1; index <= count; index++)
        _holding(
          WalletNetwork.baseMainnet,
          '0x${index.toString().padLeft(3, '0')}',
          index * 100,
          symbol: 'T$index',
        ),
    ];

    test('given exactly eight assets then there is no Other row', () {
      final result = _build(tokens(8), CryptoBreakdownGrouping.byAsset);

      expect(result.rows, hasLength(8));
      expect(result.rows.any((row) => row.isOther), isFalse);
    });

    test('given eleven assets then the top eight are listed and the other '
        'three are one Other row that still adds up', () {
      final result = _build(tokens(11), CryptoBreakdownGrouping.byAsset);

      expect(result.rows, hasLength(9));
      expect(result.rows.take(8).map((row) => row.symbol), [
        'T11',
        'T10',
        'T9',
        'T8',
        'T7',
        'T6',
        'T5',
        'T4',
      ]);
      final other = result.rows.last;
      expect(other.isOther, isTrue);
      expect(other.key, 'other');
      expect(other.valueMinor, 100 + 200 + 300);
      expect(other.holdingCount, 3);
      expect(other.symbol, isNull);
      expect(other.assetId, isNull);
      expect(other.networks, [WalletNetwork.baseMainnet]);
      expect(result.totalMinor, 6600);
      expect(
        result.rows.fold(0, (sum, row) => sum + row.valueMinor),
        result.totalMinor,
      );
      expect(
        result.rows.fold(0, (sum, row) => sum + row.shareBasisPoints),
        10000,
      );
    });

    test('given equal values then the order is stable, by key', () {
      final result = _build(
        [
          _holding(WalletNetwork.baseMainnet, '0xb', 100, symbol: 'B'),
          _holding(WalletNetwork.baseMainnet, '0xa', 100, symbol: 'A'),
        ],
        CryptoBreakdownGrouping.byAsset,
      );

      expect(result.rows.map((row) => row.assetId), ['0xa', '0xb']);
    });
  });

  group('conversion', () {
    test('given holdings in two currencies then each wallet-currency is '
        'converted once and every grouping reaches the same total', () {
      final holdings = [
        _holding(WalletNetwork.solanaMainnet, 'native', 1000),
        _holding(WalletNetwork.baseMainnet, 'native', 500),
        _holding(
          WalletNetwork.ethereumMainnet,
          '0xaaa',
          400,
          currencyCode: 'EUR',
          symbol: 'X',
          walletId: _walletB,
        ),
      ];
      int? convert(String code, int amount) =>
          code == 'USD' ? amount * 2 : amount * 3;

      final byChain = _build(
        holdings,
        CryptoBreakdownGrouping.byChain,
        convert: convert,
      );
      final byAsset = _build(
        holdings,
        CryptoBreakdownGrouping.byAsset,
        convert: convert,
      );

      expect(byChain.totalMinor, 1500 * 2 + 400 * 3);
      expect(byAsset.totalMinor, byChain.totalMinor);
      expect(byChain.rows.map((row) => row.valueMinor), [2000, 1200, 1000]);
    });

    test('given a wallet whose conversion rounds then the parts still add '
        'up to the one rounded total', () {
      // One wallet holds 10, converted once at a third to 3; the three
      // holdings must share exactly those 3, not 1 + 1 + 1 by luck.
      final holdings = [
        _holding(WalletNetwork.solanaMainnet, 'native', 4),
        _holding(WalletNetwork.baseMainnet, 'native', 3),
        _holding(WalletNetwork.ethereumMainnet, 'native', 3),
      ];

      final result = _build(
        holdings,
        CryptoBreakdownGrouping.byChain,
        convert: (code, amount) => (amount + 1) ~/ 3,
      );

      expect(result.totalMinor, 3);
      expect(result.rows.fold(0, (sum, row) => sum + row.valueMinor), 3);
    });

    test('given a currency with no rate then its holdings are left out '
        'and it is reported', () {
      final result = _build(
        [
          _holding(WalletNetwork.solanaMainnet, 'native', 1000),
          _holding(
            WalletNetwork.baseMainnet,
            'native',
            9999,
            currencyCode: 'EUR',
            walletId: _walletB,
          ),
        ],
        CryptoBreakdownGrouping.byChain,
        convert: _doubleUsd,
      );

      expect(result.rows.single.key, 'solanaMainnet');
      expect(result.rows.single.shareBasisPoints, 10000);
      expect(result.totalMinor, 2000);
      expect(result.missingCurrencyCodes, ['EUR']);
    });

    test('given a sum beyond the safe range then it is a validation '
        'failure', () {
      expect(
        () => _build(
          [
            _holding(WalletNetwork.solanaMainnet, 'native', maxSafeMinor),
            _holding(WalletNetwork.solanaMainnet, 'mint', 1),
          ],
          CryptoBreakdownGrouping.byChain,
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
