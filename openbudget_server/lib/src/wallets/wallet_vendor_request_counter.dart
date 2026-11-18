import 'dart:async';

import 'package:openbudget_core/openbudget_core.dart';

/// Counts the outbound vendor requests of one wallet operation, so the
/// logs show how close Bitcoin traffic is to the Esplora scale threshold
/// (`docs/multichain-wallets.md` section 4.3).
///
/// The counter is zone-scoped: [track] runs an operation in a zone that
/// carries a fresh counter, and every client records through [current].
/// Concurrent operations run in separate zones, so each counts only its
/// own requests, and a client outside any operation records nothing.
final class WalletVendorRequestCounter {
  static final _log = ObLogger('WalletVendorRequestCounter');
  static const _zoneKey = #walletVendorRequestCounter;

  final Map<String, int> _counts = {};

  /// The counter of the operation running in this zone, if any.
  static WalletVendorRequestCounter? get current =>
      Zone.current[_zoneKey] as WalletVendorRequestCounter?;

  /// Runs [body] in a zone carrying a new counter, then logs the counts
  /// once, whether [body] returns or throws.
  static Future<T> track<T>(Future<T> Function() body) async {
    final counter = WalletVendorRequestCounter();
    try {
      return await runZoned(body, zoneValues: {_zoneKey: counter});
    } finally {
      counter.log();
    }
  }

  /// Records one request to [vendor].
  void record(String vendor) {
    _counts.update(vendor, (count) => count + 1, ifAbsent: () => 1);
  }

  /// Logs one `wallet.vendor.requests vendor=<v> count=<n>` line per vendor.
  /// The line carries the vendor name and the count only: no URL, address
  /// or key.
  void log() {
    for (final MapEntry(:key, :value) in _counts.entries) {
      _log.info('wallet.vendor.requests vendor=$key count=$value');
    }
  }
}
