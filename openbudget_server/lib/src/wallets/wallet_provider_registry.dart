import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/wallets/solana_wallet_provider.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/xrpl/xrpl_wallet_provider.dart';

/// Whether a family's provider secret is present.
///
/// Pure in the server's passwords and the process environment so support
/// reporting never builds a provider; each provider owns its own environment
/// fallback and keeps the key value out of every message.
typedef WalletSecretProbe = bool Function(
  Map<String, String> passwords,
  Map<String, String> environment,
);

/// One chain family's provider: how to build it and whether its secret is set.
final class WalletProviderRegistration {
  const WalletProviderRegistration({
    required this.factory,
    required this.hasSecret,
  });

  /// Builds the family's provider from the session and the wallet's home
  /// network.
  final WalletProviderFactory factory;

  /// Whether the family's required secret is configured.
  final WalletSecretProbe hasSecret;
}

/// The wallet chain providers, one registration per chain family.
///
/// A family is supported when it has a registered provider and that
/// provider's secret is present; a missing key turns its family off, and
/// `wallet.supportedNetworks` then leaves it out. Providers are resolved
/// before the sync transaction opens, so a slow provider never holds a row
/// lock.
final class WalletProviderRegistry {
  const WalletProviderRegistry({required this.registrations});

  final Map<ChainFamily, WalletProviderRegistration> registrations;

  /// The registration for [family]'s provider, or null when the family has
  /// no registered provider.
  WalletProviderRegistration? registrationFor(ChainFamily family) =>
      registrations[family];

  /// Whether [family] can be read now: registered, and its secret present.
  bool isSupported({
    required Map<String, String> passwords,
    required Map<String, String> environment,
    required ChainFamily family,
  }) {
    final registration = registrations[family];
    return registration != null &&
        registration.hasSecret(passwords, environment);
  }

  /// The families that can be read now, in enum order.
  List<ChainFamily> supportedFamilies({
    required Map<String, String> passwords,
    required Map<String, String> environment,
  }) => [
    for (final family in ChainFamily.values)
      if (isSupported(
        passwords: passwords,
        environment: environment,
        family: family,
      ))
        family,
  ];

  /// The families OpenBudget ships readers for. Each chain task registers
  /// its family here beside Solana.
  static const WalletProviderRegistry defaultRegistry = WalletProviderRegistry(
    registrations: {
      ChainFamily.solana: WalletProviderRegistration(
        factory: SolanaWalletProvider.fromSession,
        hasSecret: SolanaWalletProvider.hasSecret,
      ),
      ChainFamily.xrpl: WalletProviderRegistration(
        factory: XrplWalletProvider.fromSession,
        hasSecret: XrplWalletProvider.hasSecret,
      ),
    },
  );
}
