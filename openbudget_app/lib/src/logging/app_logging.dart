import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:openbudget_app/src/logging/log_relay_service.dart';
import 'package:openbudget_app/src/logging/platform_source.dart';
import 'package:openbudget_client/openbudget_client.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// The shared [LogRelayService] instance, available only in debug mode.
late LogRelayService? _relayService;

/// Initializes frontend logging.
///
/// In debug mode, wires [Logger.root] to a [LogRelayService] that relays
/// log entries to the server's log ingest endpoint.
/// In release mode, no relay is configured.
void initAppLogging(Client client) {
  final source = detectPlatformSource();
  ObLogger.init(source: source);

  if (kDebugMode) {
    _relayService = LogRelayService(client: client);

    Logger.root.onRecord.listen((record) {
      final entry = LogEntry(
        timestamp: record.time,
        level: record.level.name,
        source: ObLogger.source,
        message: record.message,
        loggerName: record.loggerName,
        error: record.error?.toString(),
        stackTrace: record.stackTrace?.toString(),
      );
      _relayService!.add(entry);
    });
  } else {
    _relayService = null;
  }
}
