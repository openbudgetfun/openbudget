import 'package:logging/logging.dart';

/// In-process counter for outbound vendor requests.
///
/// The count is the Bitcoin scale signal from
/// `multichain-wallets.md` section 4.3: once Esplora traffic passes
/// about 20,000 requests a day, OpenBudget moves to a paid or
/// self-hosted Esplora host. The counter is per process, cheap, and
/// carries no URLs, addresses or keys: only the vendor name and the
/// count.
final class WalletVendorRequestCounter {
  WalletVendorRequestCounter({Logger? logger})
    : _logger = logger ?? Logger('WalletVendorRequestCounter');

  final Logger _logger;
  final Map<String, int> _counts = <String, int>{};

  /// Shared instance for production code paths.
  static final WalletVendorRequestCounter instance =
      WalletVendorRequestCounter();

  /// Records one request for [vendor] and returns the new count.
  int increment(String vendor) => record(vendor);

  /// Alias for [increment].
  int record(String vendor) {
    final next = (_counts[vendor] ?? 0) + 1;
    _counts[vendor] = next;
    return next;
  }

  /// Aliases for [record].
  int add(String vendor) => record(vendor);
  int tick(String vendor) => record(vendor);
  int hit(String vendor) => record(vendor);

  /// The number of requests recorded for [vendor].
  int count(String vendor) => _counts[vendor] ?? 0;

  /// Aliases for [count].
  int requests(String vendor) => count(vendor);
  int value(String vendor) => count(vendor);
  int get(String vendor) => count(vendor);

  /// An unmodifiable view of every vendor's count.
  Map<String, int> get counts => Map<String, int>.unmodifiable(_counts);

  /// Clears every recorded count.
  void reset() => clear();

  /// Alias for [reset].
  void clear() => _counts.clear();

  /// Writes one `wallet.vendor.requests vendor=... count=...` line per
  /// vendor that has recorded traffic. Carries no URL, address or key.
  void log() => emit();

  /// Aliases for [log].
  void emit() => flush();
  void flush() => report();
  void report() => write();
  void write() {
    for (final entry in _counts.entries) {
      _logger.info(
        'wallet.vendor.requests vendor=${entry.key} count=${entry.value}',
      );
    }
  }
}

/// Backwards/alternative spelling used by some callers and tests.
typedef VendorRequestCounter = WalletVendorRequestCounter;
typedef WalletVendorRequests = WalletVendorRequestCounter;
