import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/generated/protocol.dart' hide Transaction;
import 'package:openbudget_server/src/wallets/wallet_math.dart';
import 'package:serverpod/serverpod.dart';
import 'package:test/test.dart';

void main() {
  group('WalletMath.valueMinor', () {
    test('keeps raw quantities beyond 2^53 exact', () {
      final value = WalletMath.valueMinor(
        quantityRaw: BigInt.parse('9007199254740993'),
        decimals: 9,
        unitPrice: ExactDecimal.tryParse('1')!,
        currencyCode: 'USD',
      );

      expect(value, 900719925);
    });

    test('rounds the USD minor value half up once', () {
      final value = WalletMath.valueMinor(
        quantityRaw: BigInt.from(1005),
        decimals: 3,
        unitPrice: ExactDecimal.tryParse('1')!,
        currencyCode: 'USD',
      );

      expect(value, 101);
    });

    test('rejects a negative raw quantity', () {
      expect(
        () => WalletMath.valueMinor(
          quantityRaw: BigInt.from(-1),
          decimals: 9,
          unitPrice: ExactDecimal.one,
          currencyCode: 'USD',
        ),
        throwsA(isA<WalletValueException>()),
      );
    });

    test('rejects invalid token decimals', () {
      expect(
        () => WalletMath.valueMinor(
          quantityRaw: BigInt.one,
          decimals: 37,
          unitPrice: ExactDecimal.one,
          currencyCode: 'USD',
        ),
        throwsA(isA<WalletValueException>()),
      );
    });

    test('rejects a value beyond the web-safe range', () {
      expect(
        () => WalletMath.valueMinor(
          quantityRaw: BigInt.from(1000000000),
          decimals: 9,
          unitPrice: ExactDecimal.tryParse('1000000000000000000')!,
          currencyCode: 'USD',
        ),
        throwsA(isA<WalletValueException>()),
      );
    });
  });

  group('WalletMath totals', () {
    test('rounds a provider total once instead of a derived unit price', () {
      expect(
        WalletMath.totalValueMinor(
          totalPrice: ExactDecimal.tryParse('1.005')!,
          currencyCode: 'USD',
        ),
        101,
      );
    });

    test('derives a display unit price from a total', () {
      expect(
        WalletMath.unitPriceFromTotal(
          totalPrice: ExactDecimal.tryParse('10')!,
          quantityRaw: BigInt.from(3000000),
          decimals: 6,
        ),
        '3.33333333333333333',
      );
    });
  });

  group('WalletPnlCalculator', () {
    test('keeps lots in raw units and reports exact minor estimates', () {
      final estimate = WalletPnlCalculator.estimate(
        walletAddress: 'wallet',
        transactions: [
          WalletPnlTransaction(
            signature: 'buy',
            slot: 1,
            occurredAt: DateTime.utc(2026),
            movements: [
              WalletTokenMovement(
                mint: 'mint',
                fromAccount: 'other',
                toAccount: 'wallet',
                amountRaw: BigInt.from(2000000),
              ),
            ],
          ),
          WalletPnlTransaction(
            signature: 'sell',
            slot: 2,
            occurredAt: DateTime.utc(2026, 2),
            movements: [
              WalletTokenMovement(
                mint: 'mint',
                fromAccount: 'wallet',
                toAccount: 'other',
                amountRaw: BigInt.from(1000000),
              ),
            ],
          ),
        ],
        holdings: [
          WalletPnlHolding(
            assetId: 'mint',
            quantityRaw: BigInt.from(1000000),
            decimals: 6,
            unitPrice: ExactDecimal.tryParse('10')!,
            currencyCode: 'USD',
          ),
        ],
      );

      expect(estimate.transactions['sell']!.costBasisMinor, 1000);
      expect(estimate.transactions['sell']!.proceedsMinor, 1000);
      expect(estimate.transactions['sell']!.realizedPnlMinor, 0);
      expect(estimate.holdings['mint']!.costBasisMinor, 1000);
      expect(estimate.holdings['mint']!.realizedPnlMinor, 0);
      expect(estimate.holdings['mint']!.currencyCode, 'USD');
    });

    test('warns about a disposal larger than the tracked lots', () {
      final estimate = WalletPnlCalculator.estimate(
        walletAddress: 'wallet',
        transactions: [
          WalletPnlTransaction(
            signature: 'sell',
            slot: 1,
            occurredAt: DateTime.utc(2026),
            movements: [
              WalletTokenMovement(
                mint: 'mint',
                fromAccount: 'wallet',
                toAccount: 'other',
                amountRaw: BigInt.from(2000000),
              ),
            ],
          ),
        ],
        holdings: [
          WalletPnlHolding(
            assetId: 'mint',
            quantityRaw: BigInt.zero,
            decimals: 6,
            unitPrice: ExactDecimal.tryParse('10')!,
            currencyCode: 'USD',
          ),
        ],
      );

      expect(
        estimate.warnings.join(' '),
        contains('disposal exceeded tracked basis quantity'),
      );
    });

    test('skips every estimate when a holding has no price', () {
      final estimate = WalletPnlCalculator.estimate(
        walletAddress: 'wallet',
        transactions: const [],
        holdings: const [],
      );

      expect(estimate.transactions, isEmpty);
      expect(estimate.holdings, isEmpty);
    });
  });

  test('wallet raw JSON is excluded from the protocol payload', () {
    final transaction = WalletTransaction(
      walletId: UuidValue.fromString('10000000-0000-4000-a000-000000000001'),
      signature: 'sig',
      slot: 1,
      description: 'Swap',
      txType: 'SWAP',
      source: 'JUPITER',
      rawJson: '{"secret":"provider payload"}',
      tags: const ['tag'],
    );

    expect(transaction.toJsonForProtocol().containsKey('rawJson'), isFalse);
    expect(transaction.toJsonForProtocol()['tags'], ['tag']);
  });
}
