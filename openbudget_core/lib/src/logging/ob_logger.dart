import 'package:logging/logging.dart';

/// Thin wrapper around `package:logging` that provides a consistent API
/// for logging across the OpenBudget codebase.
///
/// Does NOT contain any file handler — that is server-only.
class ObLogger {
  ObLogger(this.name) : _logger = Logger(name);

  /// The name of this logger (e.g. `'BudgetService'`).
  final String name;

  final Logger _logger;

  static String _source = 'unknown';
  static Level _minLevel = Level.ALL;

  /// The source identifier set during initialization (e.g. `'server'`,
  /// `'flutter:ios-simulator'`).
  static String get source => _source;

  /// Initializes the root logger configuration.
  ///
  /// [source] identifies the origin (e.g. `'server'`, `'flutter:web'`).
  /// [minLevel] sets the minimum log level for the root logger.
  static void init({required String source, Level minLevel = Level.ALL}) {
    _source = source;
    _minLevel = minLevel;
    Logger.root.level = _minLevel;
    hierarchicalLoggingEnabled = true;
  }

  /// Logs a message at [Level.INFO].
  void info(String message) => _logger.info(message);

  /// Logs a message at [Level.WARNING].
  void warning(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.warning(message, error, stackTrace);

  /// Logs a message at [Level.SEVERE].
  void severe(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.severe(message, error, stackTrace);

  /// Logs a message at [Level.FINE].
  void fine(String message) => _logger.fine(message);

  /// Logs a message at [Level.CONFIG].
  void config(String message) => _logger.config(message);
}
