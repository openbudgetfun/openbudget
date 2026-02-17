import 'dart:async';
import 'dart:convert';

import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// Batches log entries and sends them to the server's log ingest endpoint.
///
/// Flushes every 2 seconds or when the buffer hits 50 entries.
/// Silently drops logs if the server is unreachable.
class LogRelayService {
  LogRelayService({required Client client}) : _client = client;

  final Client _client;
  final List<LogEntry> _buffer = [];
  Timer? _flushTimer;

  static const _maxBufferSize = 50;
  static const _flushInterval = Duration(seconds: 2);

  /// Adds a log entry to the buffer and flushes if needed.
  void add(LogEntry entry) {
    _buffer.add(entry);
    _flushTimer ??= Timer(_flushInterval, flush);

    if (_buffer.length >= _maxBufferSize) {
      flush();
    }
  }

  /// Flushes buffered entries to the server.
  void flush() {
    _flushTimer?.cancel();
    _flushTimer = null;

    if (_buffer.isEmpty) return;

    final batch = List<LogEntry>.of(_buffer);
    _buffer.clear();

    final json = jsonEncode(batch.map((e) => e.toJson()).toList());

    // Fire and forget — never crash for logging.
    _client.logIngest.ingest(json).catchError((_) => null);
  }

  /// Cancels the flush timer and discards remaining entries.
  void dispose() {
    _flushTimer?.cancel();
    _flushTimer = null;
    _buffer.clear();
  }
}
