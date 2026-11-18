import 'package:openbudget_server/src/wallets/xrpl/xrpl_amount.dart';
import 'package:test/test.dart';

void main() {
  group('Given XrplAmount', () {
    test('when parsing a plain value then it scales to 15 decimals', () {
      expect(
        XrplAmount.tryParse('10'),
        BigInt.from(10) * BigInt.from(10).pow(15),
      );
    });

    test('when parsing a negative exponent then it scales correctly', () {
      expect(XrplAmount.tryParse('1.5e-7'), BigInt.from(150000000));
    });

    test('when parsing a positive exponent then it scales correctly', () {
      expect(
        XrplAmount.tryParse('9999999999999999e80'),
        BigInt.parse('9999999999999999') * BigInt.from(10).pow(95),
      );
    });

    test('when parsing dust then it returns zero', () {
      expect(XrplAmount.tryParse('1e-20'), BigInt.zero);
    });

    test('when parsing garbage then it returns null', () {
      expect(XrplAmount.tryParse('not-a-number'), isNull);
    });
  });
}
