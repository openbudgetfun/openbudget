import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';

/// Manual checker for the CoinGecko ids pinned in [ChainCatalog].
///
/// Run with `dart run tool/check_coingecko_price_ids.dart --check`. It tries
/// the public endpoints without a key and reports any pinned id or platform
/// that is missing. Network failures leave the pinned ids marked unverified;
/// they are not a CI step.
Future<void> main(List<String> args) async {
  if (!args.contains('--check')) {
    stdout.writeln(
      'Usage: dart run tool/check_coingecko_price_ids.dart --check',
    );
    return;
  }
  final client = HttpClient();
  try {
    final coinIds = await _fetchStringSet(
      client,
      Uri.parse('https://api.coingecko.com/api/v3/coins/list'),
      (item) {
        if (item is! Map<String, dynamic>) return null;
        final id = item['id'];
        return id is String ? id : null;
      },
    );
    final platforms = await _fetchStringSet(
      client,
      Uri.parse('https://api.coingecko.com/api/v3/asset_platforms'),
      (item) {
        if (item is! Map<String, dynamic>) return null;
        final id = item['id'];
        return id is String ? id : null;
      },
    );

    if (coinIds == null || platforms == null) {
      stdout.writeln(
        'Could not reach CoinGecko endpoints; pinned ids remain unverified.',
      );
      return;
    }

    var allOk = true;
    for (final entry in ChainCatalog.entries) {
      final id = entry.coingeckoId;
      if (id != null && !coinIds.contains(id)) {
        stdout.writeln('MISSING coin id: ${entry.network.name} -> $id');
        allOk = false;
      }
      final platform = entry.coingeckoPlatform;
      if (platform != null && !platforms.contains(platform)) {
        stdout.writeln('MISSING platform: ${entry.network.name} -> $platform');
        allOk = false;
      }
    }
    stdout.writeln(
      allOk
          ? 'All pinned CoinGecko ids and platforms verified.'
          : 'Some pinned ids are unverified; update the catalogue.',
    );
  } finally {
    client.close();
  }
}

Future<Set<String>?> _fetchStringSet(
  HttpClient client,
  Uri uri,
  String? Function(Object?) pick,
) async {
  try {
    final request = await client.getUrl(uri);
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.userAgentHeader, 'openbudget/wallets');
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode > 299) return null;
    final decoded = jsonDecode(body);
    if (decoded is! List) return null;
    return decoded.map(pick).whereType<String>().toSet();
  } on Object catch (_) {
    return null;
  }
}
