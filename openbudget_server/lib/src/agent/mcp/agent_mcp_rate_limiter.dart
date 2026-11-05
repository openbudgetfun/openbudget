import 'package:serverpod/serverpod.dart';

/// A fixed-window, in-memory rate limit for MCP requests.
///
/// Each token gets its own window, so one busy client cannot lock out another.
/// The window resets [window] after it opens; a server restart forgets it.
class AgentMcpRateLimiter {
  AgentMcpRateLimiter({
    this.limit = 120,
    this.window = const Duration(minutes: 1),
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  /// Requests allowed per token in one window.
  final int limit;

  /// How long one window lasts.
  final Duration window;

  final DateTime Function() _clock;
  final Map<UuidValue, ({DateTime openedAt, int count})> _windows = {};

  /// Returns true when [tokenId] may make another request now.
  bool allow(UuidValue tokenId) {
    final now = _clock();
    final current = _windows[tokenId];
    if (current == null || now.difference(current.openedAt) >= window) {
      _windows[tokenId] = (openedAt: now, count: 1);
      return true;
    }
    if (current.count >= limit) return false;
    _windows[tokenId] = (openedAt: current.openedAt, count: current.count + 1);
    return true;
  }
}
