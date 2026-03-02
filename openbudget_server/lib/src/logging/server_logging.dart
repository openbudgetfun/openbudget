import 'dart:io';

import 'package:logging/logging.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// Initializes server-side logging.
///
/// Sets up [ObLogger] with source `'server'` and writes structured logs
/// to stdout, allowing process-compose to persist them in `tmp/log.txt`.
void initServerLogging() {
  ObLogger.init(source: 'server');

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
    stdout.writeln(LogFormatter.format(entry));
  });
}
