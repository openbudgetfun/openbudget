import 'package:logging/logging.dart';

/// In-process counter for outbound vendor requests.
final class WalletVendorRequestCounter {
  WalletVendorRequestCounter({Logger? logger})
    : _logger = logger ?? Logger('WalletVendorRequestCounter');

  final Logger _logger;
  final Map<String, int> _counts = <String, int>{};

  static WalletVendorRequestCounter? current;

  int record(String vendor) {
    final next = (_counts[vendor] ?? 0) + 1;
    _counts[vendor] = next;
    return next;
  }

  int count(String vendor) => _counts[vendor] ?? 0;

  Map<String, int> get counts => Map<String, int>.unmodifiable(_counts);

  void reset() => _counts.clear();

  void log() {
    for (final entry in _counts.entries) {
      _logger.info(
        'wallet.vendor.requests vendor=${entry.key} count=${entry.value}',
      );
    }
  }
}
