/// This file contains flags that control debugging features
/// for the shader system.

/// Controls debug logging for all shaders
bool enableShaderDebugLogs = false;

/// Controls animation debug logging (separate from general shader logs)
bool enableAnimationDebugLogs = false;

// Enable performance logging
bool enablePerformanceLogging = false;

/// Centralized animation debug logging
class AnimationLogger {
  static DateTime _lastLogTime = DateTime.now().subtract(
    const Duration(seconds: 1),
  );
  static const Duration _logThrottleInterval = Duration(milliseconds: 1000);

  // Keep track of what we've logged to avoid repetition
  static final Map<String, String> _lastLoggedValues = {};

  // Sample rate for animation logs (1 = log every frame, 10 = log every 10th frame)
  static const int _logSampleRate = 10;

  /// Log an animation debug message with throttling
  static void log(String message, {String category = 'default'}) {
    if (!enableAnimationDebugLogs) return;

    // Skip repetitive logs with the same content
    if (_lastLoggedValues[category] == message) return;

    // Sample logs to reduce frequency
    if (DateTime.now().millisecondsSinceEpoch % _logSampleRate != 0) return;

    final now = DateTime.now();
    if (now.difference(_lastLogTime) > _logThrottleInterval) {
      _lastLogTime = now;
      _lastLoggedValues[category] = message;
      print("[ANIM] $category: $message");
    }
  }

  /// Clear all logging history - useful when changing animation modes
  static void reset() {
    _lastLoggedValues.clear();
    _lastLogTime = DateTime.now().subtract(const Duration(seconds: 1));
  }
}
