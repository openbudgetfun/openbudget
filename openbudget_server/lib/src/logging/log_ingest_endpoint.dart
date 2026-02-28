import 'dart:convert';
import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/exceptions/exceptions.dart';
import 'package:openbudget_server/src/logging/server_logging.dart';
import 'package:serverpod/serverpod.dart';

/// Endpoint for receiving log entries from Flutter clients.
///
/// Only active in dev mode. In production this endpoint no-ops.
class LogIngestEndpoint extends Endpoint {
  static const int maxPayloadBytes = 256 * 1024;

  @override
  bool get requireLogin => true;

  /// Accepts a JSON array of [LogEntry] objects and writes them to the
  /// shared dev log file.
  Future<void> ingest(Session session, String entriesJson) async {
    if (utf8.encode(entriesJson).length > maxPayloadBytes) {
      throw ValidationException(
        'Log payload exceeds the maximum size of $maxPayloadBytes bytes.',
      );
    }

    final handler = devFileLogHandler;
    if (handler == null) return;

    try {
      final decoded = jsonDecode(entriesJson);
      if (decoded is! List) return;

      for (final item in decoded) {
        if (item is! Map<String, dynamic>) continue;
        final entry = LogEntry.fromJson(item);
        final line = LogFormatter.format(entry);
        handler.writeLine(line);
        stdout.writeln(line);
      }
    } on Object {
      // Never crash for logging.
    }
  }
}
