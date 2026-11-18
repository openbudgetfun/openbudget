import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/wallets/wallet_provider_registry.dart';
import 'package:test/test.dart';

void main() {
  // Injected maps keep the tests hermetic: no real password file and no
  // process environment is read. No real key value appears anywhere.
  const passwords = {'heliusApiKey': 'test-helius-key'};
  const emptyPasswords = <String, String>{};
  const emptyEnvironment = <String, String>{};
  const environmentFallback = {'HELIUS_API_KEY': 'test-helius-key'};

  group('Given WalletProviderRegistry.defaultRegistry', () {
    test(
      'when the family secret is missing then Solana is unsupported',
      () {
        expect(
          WalletProviderRegistry.defaultRegistry.isSupported(
            passwords: emptyPasswords,
            environment: emptyEnvironment,
            family: ChainFamily.solana,
          ),
          isFalse,
        );
      },
    );

    test(
      'when XRPL is asked for then it is supported with no secret at all',
      () {
        expect(
          WalletProviderRegistry.defaultRegistry.registrationFor(
            ChainFamily.xrpl,
          ),
          isNotNull,
        );
        expect(
          WalletProviderRegistry.defaultRegistry.isSupported(
            passwords: emptyPasswords,
            environment: emptyEnvironment,
            family: ChainFamily.xrpl,
          ),
          isTrue,
        );
      },
    );

    test(
      'when the family secret is set through passwords then Solana is '
      'supported',
      () {
        expect(
          WalletProviderRegistry.defaultRegistry.isSupported(
            passwords: passwords,
            environment: emptyEnvironment,
            family: ChainFamily.solana,
          ),
          isTrue,
        );
      },
    );

    test(
      'when the family secret is set through the environment fallback then '
      'Solana is supported',
      () {
        expect(
          WalletProviderRegistry.defaultRegistry.isSupported(
            passwords: emptyPasswords,
            environment: environmentFallback,
            family: ChainFamily.solana,
          ),
          isTrue,
        );
      },
    );

    test(
      'when Bitcoin is asked for then it is supported with no secret at '
      'all, because Esplora reads public hosts',
      () {
        expect(
          WalletProviderRegistry.defaultRegistry.registrationFor(
            ChainFamily.bitcoin,
          ),
          isNotNull,
        );
        expect(
          WalletProviderRegistry.defaultRegistry.isSupported(
            passwords: emptyPasswords,
            environment: emptyEnvironment,
            family: ChainFamily.bitcoin,
          ),
          isTrue,
        );
      },
    );

    test(
      'when a family has no registered provider then it stays unsupported '
      'whatever its secret',
      () {
        for (final family in ChainFamily.values) {
          if (family == ChainFamily.solana) continue;
          if (family == ChainFamily.xrpl) continue;
          if (family == ChainFamily.bitcoin) continue;
          expect(
            WalletProviderRegistry.defaultRegistry.isSupported(
              passwords: passwords,
              environment: environmentFallback,
              family: family,
            ),
            isFalse,
            reason: '$family has no provider registered yet',
          );
        }
      },
    );

    test(
      'when asked for registrations then only registered families resolve',
      () {
        expect(
          WalletProviderRegistry.defaultRegistry.registrationFor(
            ChainFamily.solana,
          ),
          isNotNull,
        );
        expect(
          WalletProviderRegistry.defaultRegistry.registrationFor(
            ChainFamily.xrpl,
          ),
          isNotNull,
        );
        expect(
          WalletProviderRegistry.defaultRegistry.registrationFor(
            ChainFamily.evm,
          ),
          isNull,
        );
      },
    );

    test(
      'when listing supported families then Solana appears while its secret '
      'is present and XRPL and Bitcoin always',
      () {
        expect(
          WalletProviderRegistry.defaultRegistry.supportedFamilies(
            passwords: passwords,
            environment: emptyEnvironment,
          ),
          [ChainFamily.solana, ChainFamily.bitcoin, ChainFamily.xrpl],
        );
        expect(
          WalletProviderRegistry.defaultRegistry.supportedFamilies(
            passwords: emptyPasswords,
            environment: emptyEnvironment,
          ),
          [ChainFamily.bitcoin, ChainFamily.xrpl],
        );
      },
    );
  });

  group('Given a custom registry', () {
    test('when its secret probe is missing then the family is unsupported', () {
      final registry = WalletProviderRegistry(
        registrations: {
          ChainFamily.evm: WalletProviderRegistration(
            factory: (_, _) => throw UnimplementedError(),
            hasSecret: (passwords, environment) =>
                passwords.containsKey('alchemyApiKey') ||
                environment.containsKey('ALCHEMY_API_KEY'),
          ),
        },
      );

      expect(
        registry.isSupported(
          passwords: emptyPasswords,
          environment: emptyEnvironment,
          family: ChainFamily.evm,
        ),
        isFalse,
      );
      expect(
        registry.isSupported(
          passwords: const {'alchemyApiKey': 'test-alchemy-key'},
          environment: emptyEnvironment,
          family: ChainFamily.evm,
        ),
        isTrue,
      );
      expect(
        registry.isSupported(
          passwords: emptyPasswords,
          environment: const {'ALCHEMY_API_KEY': 'test-alchemy-key'},
          family: ChainFamily.evm,
        ),
        isTrue,
      );
    });
  });
}
