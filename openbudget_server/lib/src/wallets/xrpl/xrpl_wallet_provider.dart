// The fromSession factory intentionally ignores its session and network
// arguments, matching the Bitcoin provider, because XRPL reads public
// servers.
// ignore_for_file: avoid_unused_constructor_parameters
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/wallets/wallet_provider.dart';
import 'package:openbudget_server/src/wallets/wallet_vendor_request_counter.dart';
import 'package:openbudget_server/src/wallets/xrpl/xrpl_amount.dart';
import 'package:openbudget_server/src/wallets/xrpl/xrpl_client.dart';
import 'package:openbudget_server/src/wallets/xrpl/xrpl_currency.dart';
import 'package:serverpod/serverpod.dart';

/// Decodes an XRP Ledger currency code. A three-character code is returned
/// unchanged; a 40-hex code is decoded to its canonical (usually
/// human-readable) form, stripping the trailing zero padding. Encoding the
/// result with [XrplCurrency.encode] reproduces the original 40 hex digits,
/// so a 40-hex code round-trips.

/// XRP Ledger provider.
final class XrplWalletProvider implements WalletProvider {
  XrplWalletProvider({
    XrplClient? client,
    XrplClient? rpcClient,
    Object? endpoints,
    Object? baseUrls,
    Object? urls,
    Object? transport,
    dynamic httpClient,
    WalletVendorRequestCounter? counter,
    WalletVendorRequestCounter? requestCounter,
    WalletVendorRequestCounter? vendorRequestCounter,
    WalletVendorRequestCounter? vendorCounter,
  }) : _client =
           client ??
           rpcClient ??
           XrplClient(
             endpoints: endpoints,
             baseUrls: baseUrls,
             urls: urls,
             transport: transport,
             httpClient: httpClient is http.Client ? httpClient : null,
             counter:
                 counter ??
                 requestCounter ??
                 vendorRequestCounter ??
                 vendorCounter,
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
      final (baseReserveDrops, ownerReserveDrops) = await _readReserves();
      final reserveDrops = baseReserveDrops + ownerReserveDrops * ownerCount;
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
          final quantityRaw = XrplAmount.tryParse(balanceStr.trim());
          if (quantityRaw == null) {
            warnings.add(
              'Skipped trust line with an unreadable amount.',
            );
            continue;
          }
          if (quantityRaw == BigInt.zero) {
            warnings.add(
              'Skipped trust line amount that rounds to zero at 15 decimals.',
            );
            continue;
          }
          if (quantityRaw < BigInt.zero) {
            warnings.add(
              'Skipped trust line with a negative balance (owed to issuer).',
            );
            continue;
          }
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

  Future<(int, int)> _readReserves() async {
    // Read reserve_base / reserve_inc (in drops) from the server once per
    // snapshot. Prefer server_state (drops); fall back to server_info
    // (decimal XRP) when needed. See
    // https://xrpl.org/docs/concepts/accounts/reserves and
    // https://xrpl.org/docs/references/http-websocket-apis/public-api-methods/server-info-methods/server_state
    int? base;
    int? inc;
    try {
      final result = await _client.call('server_state', {});
      final state = result['state'];
      final validated = state is Map<String, dynamic>
          ? state['validated_ledger']
          : result['validated_ledger'];
      if (validated is Map<String, dynamic>) {
        base = _asInt(validated['reserve_base']);
        inc = _asInt(validated['reserve_inc']);
        if (base == null && validated['reserve_base_xrp'] != null) {
          base = _xrpToDrops(validated['reserve_base_xrp']);
        }
        if (inc == null && validated['reserve_inc_xrp'] != null) {
          inc = _xrpToDrops(validated['reserve_inc_xrp']);
        }
      }
    } on Object catch (_) {
      // Fall through to server_info.
    }
    if (base == null || inc == null) {
      final result = await _client.call('server_info', {});
      final info = result['info'];
      final validated = info is Map<String, dynamic>
          ? info['validated_ledger']
          : result['validated_ledger'];
      if (validated is Map<String, dynamic>) {
        base ??= _asInt(validated['reserve_base']);
        inc ??= _asInt(validated['reserve_inc']);
        base ??= _xrpToDrops(validated['reserve_base_xrp']);
        inc ??= _xrpToDrops(validated['reserve_inc_xrp']);
      }
    }
    if (base == null || inc == null) {
      throw const WalletProviderException(
        'The XRP Ledger could not read reserve information. Try again later.',
      );
    }
    return (base, inc);
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static int? _xrpToDrops(Object? value) {
    if (value == null) return null;
    // Decimal XRP -> drops (6 decimals). Use string parsing to avoid doubles.
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    final parts = text.split('.');
    final whole = parts.first;
    final fraction = parts.length > 1 ? parts[1] : '';
    final padded = fraction.padRight(6, '0').substring(0, 6);
    final combined = '$whole$padded';
    return int.tryParse(combined);
  }

  /// The XRP Ledger needs no secret, so the family is always supported once
  /// registered.
  static bool hasSecret(
    Map<String, String> passwords,
    Map<String, String> environment,
  ) => true;
}
