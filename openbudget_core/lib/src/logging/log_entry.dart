import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_entry.freezed.dart';
part 'log_entry.g.dart';

/// A structured log entry that can be serialized for relay between
/// frontend and server.
@freezed
abstract class LogEntry with _$LogEntry {
  const factory LogEntry({
    required DateTime timestamp,
    required String level,
    required String source,
    required String message,
    required String loggerName,
    String? error,
    String? stackTrace,
  }) = _LogEntry;

  factory LogEntry.fromJson(Map<String, dynamic> json) =>
      _$LogEntryFromJson(json);
}
