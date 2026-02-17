import 'dart:io';

import 'package:openbudget_core/openbudget_core.dart';

/// Appends formatted log lines to a dev log file.
///
/// Auto-truncates when the file exceeds [maxSizeBytes] (keeps the last
/// [keepSizeBytes]).
class DevFileLogHandler {
  DevFileLogHandler({
    required String filePath,
    this.maxSizeBytes = 10 * 1024 * 1024,
    this.keepSizeBytes = 2 * 1024 * 1024,
  }) : _file = File(filePath) {
    _file.parent.createSync(recursive: true);
    _sink = _file.openWrite(mode: FileMode.append);
  }

  final File _file;
  late IOSink _sink;

  /// Maximum file size before truncation (default 10 MB).
  final int maxSizeBytes;

  /// Size to keep after truncation (default 2 MB).
  final int keepSizeBytes;

  /// Writes a formatted log line and auto-truncates if needed.
  void writeLine(String line) {
    _sink.writeln(line);
    _maybeAutoTruncate();
  }

  /// Writes a [LogEntry] as a formatted line.
  void writeEntry(LogEntry entry) {
    writeLine(LogFormatter.format(entry));
  }

  /// Manually truncates the log file, keeping the last [keepSizeBytes].
  Future<void> truncate() async {
    await _sink.flush();
    await _sink.close();

    if (_file.existsSync()) {
      final length = _file.lengthSync();
      if (length > keepSizeBytes) {
        final bytes = _file.readAsBytesSync();
        final start = bytes.length - keepSizeBytes;
        _file.writeAsBytesSync(bytes.sublist(start));
      }
    }

    _sink = _file.openWrite(mode: FileMode.append);
  }

  void _maybeAutoTruncate() {
    if (!_file.existsSync()) return;

    try {
      final length = _file.lengthSync();
      if (length > maxSizeBytes) {
        // Schedule truncation asynchronously to avoid blocking writes.
        truncate();
      }
    } on FileSystemException {
      // Ignore — file may be in flux.
    }
  }

  /// Flushes and closes the file sink.
  Future<void> close() async {
    await _sink.flush();
    await _sink.close();
  }
}
