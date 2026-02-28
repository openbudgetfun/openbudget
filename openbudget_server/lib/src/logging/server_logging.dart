import 'dart:io';

import 'package:logging/logging.dart';
import 'package:openbudget_core/openbudget_core.dart';
import 'package:openbudget_server/src/logging/dev_file_log_handler.dart';

/// Holds the shared [DevFileLogHandler] for the server process.
DevFileLogHandler? _handler;

/// Returns the active [DevFileLogHandler], or `null` if not initialized.
DevFileLogHandler? get devFileLogHandler => _handler;

/// Initializes server-side logging.
///
/// Sets up [ObLogger] with source `'server'` and wires [Logger.root] records
/// to the shared dev log file at `.tmp/omni.log`.
void initServerLogging() {
  ObLogger.init(source: 'server');

  // Resolve the project root relative to the server working directory.
  final projectRoot = Directory.current.parent.path;
  final logPath = '$projectRoot/.tmp/omni.log';

  _handler = DevFileLogHandler(filePath: logPath);

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
    _handler!.writeEntry(entry);
  });
}
