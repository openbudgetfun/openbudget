import 'package:openbudget_server/src/wallets/solana_wallet_provider.dart';
import 'package:test/test.dart';

void main() {
  group('Given the Helius key resolution', () {
    test('when the password is set then it wins over the environment', () {
      final apiKey = SolanaWalletProvider.heliusApiKeyFrom(
        passwords: const {'heliusApiKey': 'from-passwords'},
        environment: const {'HELIUS_API_KEY': 'from-environment'},
      );
      expect(apiKey, 'from-passwords');
    });

    test('when only the environment fallback is set then it is used', () {
      final apiKey = SolanaWalletProvider.heliusApiKeyFrom(
        passwords: const {},
        environment: const {'HELIUS_API_KEY': 'from-environment'},
      );
      expect(apiKey, 'from-environment');
    });

    test('when neither source is set then there is no key', () {
      final apiKey = SolanaWalletProvider.heliusApiKeyFrom(
        passwords: const {},
        environment: const {},
      );
      expect(apiKey, isNull);
    });

    test('when a value is blank or whitespace then it does not count', () {
      expect(
        SolanaWalletProvider.heliusApiKeyFrom(
          passwords: const {'heliusApiKey': '   '},
          environment: const {},
        ),
        isNull,
      );
      expect(
        SolanaWalletProvider.heliusApiKeyFrom(
          passwords: const {},
          environment: const {'HELIUS_API_KEY': ''},
        ),
        isNull,
      );
    });

    test('when a trimmed password is set then it is accepted', () {
      expect(
        SolanaWalletProvider.heliusApiKeyFrom(
          passwords: const {'heliusApiKey': ' padded '},
          environment: const {},
        ),
        'padded',
      );
    });

    test(
      'when hasSecret is asked then it mirrors the key resolution',
      () {
        expect(
          SolanaWalletProvider.hasSecret(const {}, const {}),
          isFalse,
        );
        expect(
          SolanaWalletProvider.hasSecret(
            const {'heliusApiKey': 'test-key'},
            const {},
          ),
          isTrue,
        );
        expect(
          SolanaWalletProvider.hasSecret(
            const {},
            const {'HELIUS_API_KEY': 'test-key'},
          ),
          isTrue,
        );
      },
    );
  });
}
