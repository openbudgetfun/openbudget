import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:openbudget_app/src/logging/platform_source.dart';
import 'package:openbudget_core/openbudget_core.dart';

/// Initializes frontend logging.
///
/// In debug mode, prints structured log lines to the local debug console.
void initAppLogging() {
  final source = detectPlatformSource();
  ObLogger.init(source: source);

  if (kDebugMode) {
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
      debugPrint(LogFormatter.format(entry));
    });
  }
}
