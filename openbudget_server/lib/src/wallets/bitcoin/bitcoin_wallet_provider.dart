/// Bitcoin needs no session secrets, so the factory ignores its arguments.
// ignore_for_file: avoid_unused_constructor_parameters
library;

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/wallets/bitcoin/esplora_client.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/wallet_vendor_request_counter.dart';
import 'package:serverpod/serverpod.dart';

/// Esplora-backed Bitcoin provider for single addresses.
///
/// One read asks `/address/:address` once and maps `chain_stats` and
/// `mempool_stats` (funded_txo_sum − spent_txo_sum) to one satoshi
/// quantity with 8 decimals (multichain-wallets.md 3.4). Bitcoin has no
/// tokens and no history sync yet, and pricing stays with the price
/// service (W2.1), so the snapshot carries exactly one holding and no
/// prices.
///
/// Extended keys (`xpub`, `zpub` and friends) are recognised by the core
/// parser but their addresses are not derived until W4.2, so they are
/// reported as not yet supported in plain words.
final class BitcoinWalletProvider implements WalletProvider {
  BitcoinWalletProvider({
    EsploraClient? client,
    WalletVendorRequestCounter? counter,
    WalletVendorRequestCounter? requestCounter,
    WalletVendorRequestCounter? vendorRequestCounter,
    WalletVendorRequestCounter? vendorCounter,
  }) : _client =
           client ??
           EsploraClient(
             counter:
                 counter ??
                 requestCounter ??
                 vendorRequestCounter ??
                 vendorCounter,
           );

  /// Builds the provider from the session. Bitcoin reads public Esplora
  /// servers, so no key is needed.
  factory BitcoinWalletProvider.fromSession(
    Session session,
    WalletNetwork network,
  ) => BitcoinWalletProvider();

  static const _nativeAssetId = 'native';
  static const _btcSymbol = 'BTC';
  static const _btcName = 'Bitcoin';
  static const _btcDecimals = 8;
  static const _hdIdentityPrefix = 'hd:';

  static const _hdUnsupportedMessage =
      'Extended Bitcoin keys are not supported yet. '
      'Add single addresses for now.';

  final EsploraClient _client;

  @override
  Future<WalletProviderSnapshot> fetchSnapshot(
    WalletReadRequest request,
  ) async {
    // Bitcoin reads its one network; it takes no scanNetworks list.
    final network = request.networks.single;
    _requireSingleAddress(request.address);
    final summary = await _client.fetchAddress(request.address);

    return WalletProviderSnapshot(
      readNetworks: [network],
      holdings: [
        // The balance is reported even when it is zero, matching the
        // Solana provider's native coin handling: the read says what the
        // address holds, and the valuation decides what counts.
        WalletProviderHolding(
          network: network,
          assetId: _nativeAssetId,
          symbol: _btcSymbol,
          name: _btcName,
          decimals: _btcDecimals,
          quantityRaw: summary.totalSats,
          isNft: false,
          prices: const [],
        ),
      ],
      transactions: const [],
      warnings: const [],
    );
  }

  /// Refuses HD identities and extended keys in plain words until W4.2
  /// lands derivation. The message never contains the key or its id.
  static void _requireSingleAddress(String address) {
    if (address.startsWith(_hdIdentityPrefix)) {
      throw const WalletProviderException(_hdUnsupportedMessage);
    }
    final parsed = WalletAddressParser.parse(address);
    if (parsed is WalletAddressMatch &&
        parsed.candidates.any((candidate) => candidate.isHdKey)) {
      throw const WalletProviderException(_hdUnsupportedMessage);
    }
  }

  /// Bitcoin needs no secret, so the family is always supported once
  /// registered.
  static bool hasSecret(
    Map<String, String> passwords,
    Map<String, String> environment,
  ) => true;
}
