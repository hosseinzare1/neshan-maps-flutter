import 'package:flutter/foundation.dart' show debugPrint;

/// A simple logger for the Neshan Map package.
///
/// This logger provides a centralized way to log messages across the entire
/// neshan_map module with consistent formatting and prefix-based identification.
///
/// The logger can be enabled or disabled at the widget level, allowing for
/// per-instance debug control.
///
/// Example usage:
/// ```dart
/// final logger = NeshanMapLogger(enabled: true, prefix: 'NeshanMap');
/// logger.log('Map initialized with zoom: 15.0');
/// logger.error('Failed to load map', error);
/// ```
class NeshanMapLogger {
  /// Whether logging is enabled.
  final bool enabled;

  /// The prefix to use for all log messages.
  ///
  /// This helps identify which component is logging.
  final String prefix;

  /// Creates a new logger instance.
  ///
  /// [enabled] controls whether logs are printed. Defaults to false.
  /// [prefix] is prepended to all log messages for identification.
  const NeshanMapLogger({
    this.enabled = false,
    this.prefix = '',
  });

  /// Logs an informational message.
  ///
  /// The message will only be printed if [enabled] is true.
  /// Format: `[prefix] message`
  void log(String message) {
    if (enabled) {
      debugPrint('[Neshan-$prefix] $message');
    }
  }

  /// Logs an error message with optional error details.
  ///
  /// The message will only be printed if [enabled] is true.
  /// Format: `[prefix] ERROR: message - error`
  void error(String message, [Object? error]) {
    if (enabled) {
      final errorSuffix = error != null ? ' - $error' : '';
      debugPrint('[Neshan-$prefix] ERROR: $message$errorSuffix');
    }
  }

  /// Creates a new logger with the same enabled state but a different prefix.
  ///
  /// This is useful for creating component-specific loggers while maintaining
  /// the same enable/disable state.
  NeshanMapLogger withPrefix(String newPrefix) {
    return NeshanMapLogger(enabled: enabled, prefix: newPrefix);
  }

  /// A disabled logger that never prints anything.
  ///
  /// Useful as a default value.
  static const NeshanMapLogger disabled = NeshanMapLogger(enabled: false);
}

