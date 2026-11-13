import 'dart:math';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:test/test.dart';

import 'address_test_helpers.dart';

/// Copied from `openbudget_server/lib/src/wallets/wallet_service.dart`
/// (`_isSolanaAddress`, around line 1365 on `main` when this test was
/// written). Keep the two in step: section 5.2 requires the parser to accept
/// exactly what the server already accepts.
bool serverIsSolanaAddress(String value) {
  if (value.length < 32 || value.length > 44) return false;
  const alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
  var number = BigInt.zero;
  final base = BigInt.from(58);
  for (final unit in value.codeUnits) {
    final digit = alphabet.indexOf(String.fromCharCode(unit));
    if (digit < 0) return false;
    number = number * base + BigInt.from(digit);
  }
  var leadingZeros = 0;
  while (leadingZeros < value.length && value[leadingZeros] == '1') {
    leadingZeros += 1;
  }
  var byteLength = 0;
  while (number > BigInt.zero) {
    byteLength += 1;
    number >>= 8;
  }
  return leadingZeros + byteLength == 32;
}

bool _parserAcceptsSolana(String input) {
  final result = WalletAddressParser.parse(input);
  return result is WalletAddressMatch &&
      result.candidates.any(
        (candidate) => candidate.family == WalletAddressFamily.solana,
      );
}

void main() {
  group('Solana parity', () {
    test('matches the server predicate on 1,000 generated inputs', () {
      final random = Random(20261113);
      const alphabet =
          '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz';
      const invalidCharacters = ['0', 'O', 'I', 'l', ' ', '-'];
      var checked = 0;

      void check(String input) {
        final value = input.trim();
        expect(
          _parserAcceptsSolana(value),
          serverIsSolanaAddress(value),
          reason:
              'input ${checked + 1} of length ${value.length} disagreed with '
              'the server predicate',
        );
        checked++;
      }

      // 400 valid 32-byte keys, each followed by one mutation.
      for (var index = 0; index < 400; index++) {
        final bytes = List.generate(32, (_) => random.nextInt(256));
        final address = base58Encode(bytes);
        check(address);

        final chars = address.split('');
        switch (random.nextInt(4)) {
          case 0:
            chars[random.nextInt(chars.length)] =
                alphabet[random.nextInt(alphabet.length)];
          case 1:
            chars.removeAt(random.nextInt(chars.length));
          case 2:
            chars.insert(
              random.nextInt(chars.length + 1),
              invalidCharacters[random.nextInt(invalidCharacters.length)],
            );
          case 3:
            chars[random.nextInt(chars.length)] =
                invalidCharacters[random.nextInt(invalidCharacters.length)];
        }
        check(chars.join());
      }

      // 100 strings at the edges of the accepted length range.
      for (var index = 0; index < 100; index++) {
        final length = 28 + random.nextInt(20);
        final buffer = StringBuffer();
        for (var position = 0; position < length; position++) {
          buffer.write(alphabet[random.nextInt(alphabet.length)]);
        }
        check(buffer.toString());
      }

      // 100 arbitrary strings drawn from the alphabet, which may decode to a
      // different length and therefore must be rejected identically.
      for (var index = 0; index < 100; index++) {
        final length = 20 + random.nextInt(30);
        final buffer = StringBuffer();
        for (var position = 0; position < length; position++) {
          buffer.write(alphabet[random.nextInt(alphabet.length)]);
        }
        check(buffer.toString());
      }

      expect(checked, 1000);
    });

    test('accepts the all-ones system address', () {
      const address = '11111111111111111111111111111111';
      expect(serverIsSolanaAddress(address), isTrue);
      expect(_parserAcceptsSolana(address), isTrue);
    });

    test('refuses a 64-byte Solana secret key', () {
      final secret = base58Encode(List.generate(64, (index) => index));
      expect(serverIsSolanaAddress(secret), isFalse);
      expect(WalletAddressParser.parse(secret), isA<WalletAddressRefused>());
    });
  });

  group('fuzzing', () {
    test('parse never throws on random strings', () {
      final random = Random(424242);
      for (var index = 0; index < 5000; index++) {
        final length = random.nextInt(320);
        final input = String.fromCharCodes(
          List.generate(length, (_) => random.nextInt(0x3000)),
        );
        late final WalletAddressParseResult result;
        expect(
          () => result = WalletAddressParser.parse(input),
          returnsNormally,
          reason: 'random input $index of length $length threw',
        );
        expect(
          result,
          anyOf(
            isA<WalletAddressMatch>(),
            isA<WalletAddressRefused>(),
            isA<WalletAddressInvalid>(),
          ),
        );
      }
    });

    test('parse never throws on pathological long input', () {
      final long = List.filled(10000, 'a').join();
      expect(WalletAddressParser.parse(long), isA<WalletAddressInvalid>());
      expect(
        WalletAddressParser.parse('\x00${List.filled(600, '0').join()}'),
        isA<WalletAddressInvalid>(),
      );
    });
  });
}
