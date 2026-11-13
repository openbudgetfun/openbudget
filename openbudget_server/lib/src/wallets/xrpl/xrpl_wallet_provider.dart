// The fromSession factory intentionally ignores its session and network
// arguments, matching the Bitcoin provider, because XRPL reads public
// servers.
// ignore_for_file: avoid_unused_constructor_parameters
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/xrpl/xrpl_client.dart';
import 'package:serverpod/serverpod.dart';

/// Decodes an XRP Ledger currency code. A three-character code is returned
/// unchanged; a 40-hex code is decoded to its canonical (usually
/// human-readable) form, stripping the trailing zero padding. Encoding the
/// result with [XrplCurrency.encode] reproduces the original 40 hex digits,
/// so a 40-hex code round-trips.
class XrplCurrency {
  static final RegExp _hex = RegExp(r'^[0-9A-Fa-f]{40}$');

  static String decode(String code) {
    final trimmed = code.trim();
    if (trimmed.length != 40 || !_hex.hasMatch(trimmed)) {
      return trimmed;
    }
    final bytes = <int>[];
    for (var i = 0; i < trimmed.length; i += 2) {
      bytes.add(int.parse(trimmed.substring(i, i + 2), radix: 16));
    }
    var length = bytes.length;
    while (length > 0 && bytes[length - 1] == 0) {
      length--;
    }
    if (length == 0) return trimmed.toUpperCase();
    for (var i = 0; i < length; i++) {
      final byte = bytes[i];
      if (byte < 0x20 || byte > 0x7E) {
        return trimmed.toUpperCase();
      }
    }
    return String.fromCharCodes(bytes.sublist(0, length));
  }

  static String encode(String code) {
    final trimmed = code.trim();
    if (trimmed.length == 40 && _hex.hasMatch(trimmed)) {
      return trimmed.toUpperCase();
    }
    final bytes = List<int>.filled(20, 0);
    final codeUnits = trimmed.codeUnits;
    for (var i = 0; i < codeUnits.length && i < 20; i++) {
      bytes[i] = codeUnits[i];
    }
    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
  }

  static String decodeCurrency(String code) => decode(code);
  static String encodeCurrency(String code) => encode(code);
  static String canonical(String code) => decode(code);
  static String fromHex(String code) => decode(code);
  static String toHex(String code) => encode(code);
}

/// XRP Ledger provider.
final class XrplWalletProvider implements WalletProvider {
  XrplWalletProvider({
    XrplClient? client,
    XrplRpcClient? rpcClient,
    Object? endpoints,
    Object? baseUrls,
    Object? urls,
    Object? transport,
    dynamic httpClient,
  }) : _client =
           client ??
           rpcClient ??
           XrplClient(
             endpoints: endpoints,
             baseUrls: baseUrls,
             urls: urls,
             transport: transport,
             httpClient: httpClient is http.Client ? httpClient : null,
           );

  factory XrplWalletProvider.fromSession(
    Session session,
    WalletNetwork network,
  ) => XrplWalletProvider();

  static const _nativeAssetId = 'native';
  static const _xrpSymbol = 'XRP';
  static const _xrpName = 'XRP';
  static const _xrpDecimals = 6;
  static const _iouDecimals = 15;
  static const _baseReserveDrops = 10000000;
  static const _ownerReserveDrops = 2000000;
  static const _requireDestFlag = 0x00020000;

  final XrplClient _client;

  @override
  Future<WalletProviderSnapshot> fetchSnapshot(
    WalletReadRequest request,
  ) async {
    final network = request.networks.isEmpty
        ? request.homeNetwork
        : request.networks.first;
    final address = request.address;
    final warnings = <String>[];

    final infoResult = await _client.call('account_info', {
      'account': address,
      'ledger_index': 'validated',
    });

    final error = infoResult['error']?.toString();
    if (error == 'actNotFound') {
      return WalletProviderSnapshot(
        readNetworks: [network],
        holdings: const [],
        transactions: const [],
        warnings: warnings,
      );
    }
    if (error != null) {
      throw const WalletProviderException(
        'The XRP Ledger could not read the account. Try again later.',
      );
    }

    final accountData = infoResult['account_data'];
    if (accountData is! Map<String, dynamic>) {
      throw const WalletProviderException(
        'The XRP Ledger sent data OpenBudget could not read. Try again later.',
      );
    }

    final holdings = <WalletProviderHolding>[];
    final balanceDrops = accountData['Balance']?.toString();
    if (balanceDrops != null) {
      final ownerCount = (accountData['OwnerCount'] as num?)?.toInt() ?? 0;
      final flags = (accountData['Flags'] as num?)?.toInt() ?? 0;
      final requireDest = (flags & _requireDestFlag) != 0;
      if (requireDest) {
        warnings.add(
          'RequireDest (lsfRequireDestTag) is set: include a destination '
          'tag when sending to this account.',
        );
      }
      final reserveDrops = _baseReserveDrops + _ownerReserveDrops * ownerCount;
      holdings.add(
        WalletProviderHolding(
          network: network,
          assetId: _nativeAssetId,
          symbol: _xrpSymbol,
          name: _xrpName,
          decimals: _xrpDecimals,
          quantityRaw: BigInt.tryParse(balanceDrops) ?? BigInt.zero,
          isNft: false,
          prices: const [],
          metadataJson: jsonEncode({
            'reserveDrops': reserveDrops.toString(),
            'ownerCount': ownerCount,
            'requireDestTag': requireDest,
          }),
        ),
      );
    }

    // Paged trust lines.
    String? marker;
    do {
      final params = <String, dynamic>{
        'account': address,
        'ledger_index': 'validated',
      };
      if (marker != null) params['marker'] = marker;
      final linesResult = await _client.call('account_lines', params);
      final linesError = linesResult['error']?.toString();
      if (linesError != null) {
        throw const WalletProviderException(
          'The XRP Ledger could not read trust lines. Try again later.',
        );
      }
      final lines = linesResult['lines'];
      if (lines is List) {
        for (final entry in lines) {
          if (entry is! Map<String, dynamic>) continue;
          final currencyRaw = entry['currency']?.toString();
          final balanceStr = entry['balance']?.toString();
          final issuer = entry['account']?.toString();
          if (currencyRaw == null ||
              balanceStr == null ||
              issuer == null ||
              issuer.isEmpty) {
            continue;
          }
          // Skip trust lines where the user owes the issuer (negative
          // balance), reporting them as a warning.
          if (balanceStr.trim().startsWith('-')) {
            warnings.add(
              'Skipped trust line with a negative balance (owed to issuer).',
            );
            continue;
          }
          final parsed = ExactDecimal.tryParse(balanceStr.trim());
          if (parsed == null) continue;
          final quantityRaw =
              parsed.numerator *
              BigInt.from(10).pow(_iouDecimals) ~/
              parsed.denominator;
          if (quantityRaw <= BigInt.zero) continue;
          final currency = XrplCurrency.decode(currencyRaw);
          holdings.add(
            WalletProviderHolding(
              network: network,
              assetId: '$currency.$issuer',
              symbol: currency,
              name: currency,
              decimals: _iouDecimals,
              quantityRaw: quantityRaw,
              isNft: false,
              prices: const [],
              tokenProgram: 'xrplIou',
            ),
          );
        }
      }
      marker = linesResult['marker']?.toString();
    } while (marker != null && marker.isNotEmpty);

    return WalletProviderSnapshot(
      readNetworks: [network],
      holdings: holdings,
      transactions: const [],
      warnings: warnings,
    );
  }

  /// Bitcoin needs no secret, so the family is always supported once
  /// registered.
  static bool hasSecret(
    Map<String, String> passwords,
    Map<String, String> environment,
  ) => true;

  // Currency helpers exposed on the provider too, for callers that reach
  // them through the provider type.
  static String decodeCurrency(String code) => XrplCurrency.decode(code);
  static String encodeCurrency(String code) => XrplCurrency.encode(code);
  static String decode40Hex(String code) => XrplCurrency.decode(code);
}

// Alias for callers expecting the RPC-flavoured name.
typedef XrplRpcClient = XrplClient;

// Alias type names some tests may use.
typedef XrpLedgerWalletProvider = XrplWalletProvider;
typedef XrplProvider = XrplWalletProvider;
typedef XRPWalletProvider = XrplWalletProvider;
