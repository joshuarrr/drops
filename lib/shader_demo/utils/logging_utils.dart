import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

// Set true to enable additional debug logging
bool _enableDebugLogging = true;

/// Log levels for the shader effects logger
enum LogLevel { debug, info, warning, error }

/// Central logging class for shader effects
class EffectLogger {
  // Default logging level - change this to filter logs globally
  static LogLevel currentLevel = LogLevel.info;

  // Cache for log throttling
  static Map<String, String> _lastLogMessages = {};
  static Map<String, DateTime> _lastLoggedTimes = {};
  static const _throttleMs = 1000; // Throttle identical logs by 1 second

  /// Log a message with the given level
  static void log(String message, {LogLevel level = LogLevel.info}) {
    if (!_enableDebugLogging || level.index < currentLevel.index) {
      return;
    }

    // Generate a hash key for this message
    String messageKey = message.hashCode.toString();

    // Skip logging if we've already logged this exact message recently
    final now = DateTime.now();
    if (_lastLogMessages[messageKey] == message) {
      final lastTime = _lastLoggedTimes[messageKey];
      if (lastTime != null &&
          now.difference(lastTime).inMilliseconds < _throttleMs) {
        return; // Skip this log due to throttling
      }
    }

    // Update cache with this message
    _lastLogMessages[messageKey] = message;
    _lastLoggedTimes[messageKey] = now;

    // Keep cache size reasonable
    if (_lastLogMessages.length > 100) {
      // Remove oldest 20 entries
      final oldestKeys = _lastLogMessages.keys.take(20).toList();
      for (final key in oldestKeys) {
        _lastLogMessages.remove(key);
        _lastLoggedTimes.remove(key);
      }
    }

    // Format message with level prefix
    final prefix = level == LogLevel.debug
        ? "[DEBUG]"
        : level == LogLevel.warning
        ? "[WARN]"
        : level == LogLevel.error
        ? "[ERROR]"
        : "";

    final formattedMessage = prefix.isEmpty ? message : "$prefix $message";

    // Actually log the message
    final String tag = 'ShaderDemo';
    developer.log(formattedMessage, name: tag);

    // Only print debug logs to console if explicitly enabled
    if (level.index >= LogLevel.info.index) {
      debugPrint('[$tag] $formattedMessage');
    }
  }

  /// Enables or disables debug logging
  static void setDebugLogging(bool enabled) {
    _enableDebugLogging = enabled;
  }

  /// Set the minimum log level to display
  static void setLogLevel(LogLevel level) {
    currentLevel = level;
  }
}
