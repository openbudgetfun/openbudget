import 'package:openbudget_core/src/logging/log_entry.dart';

/// Formats [LogEntry] objects into human-readable log lines.
///
/// Format: `[2026-02-17T10:30:00] [INFO   ] [server] [BudgetService] message`
class LogFormatter {
  const LogFormatter._();

  /// Formats a [LogEntry] into a single log string.
  ///
  /// Error and stack trace are appended on indented subsequent lines.
  static String format(LogEntry entry) {
    final level = entry.level.toUpperCase().padRight(7);
    final buf = StringBuffer()
      ..write('[${entry.timestamp.toIso8601String()}] ')
      ..write('[$level] ')
      ..write('[${entry.source}] ')
      ..write('[${entry.loggerName}] ')
      ..write(entry.message);

    if (entry.error != null) {
      buf
        ..writeln()
        ..write('  error: ${entry.error}');
    }

    if (entry.stackTrace != null) {
      buf
        ..writeln()
        ..write('  stackTrace: ${entry.stackTrace}');
    }

    return buf.toString();
  }
}
