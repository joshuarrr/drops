import 'dart:async';
import 'package:flutter/foundation.dart';
import '../controllers/effect_controller.dart';

/// Utility class to monitor memory usage in the app
class MemoryMonitor {
  // Singleton pattern
  static final MemoryMonitor _instance = MemoryMonitor._internal();
  factory MemoryMonitor() => _instance;
  MemoryMonitor._internal();

  // Monitoring timer
  Timer? _monitorTimer;
  bool _isMonitoring = false;

  // Cache thresholds
  static const int _largeCacheThreshold = 10;

  /// Start monitoring memory usage (disabled for performance with heavy shaders)
  void startMonitoring({int intervalMs = 5000}) {
    if (_isMonitoring) return;

    _log('Memory monitoring disabled for shader performance optimization');
    _isMonitoring = false; // Keep disabled for performance

    // Only do initial cleanup, no periodic monitoring
    _triggerCleanup();
  }

  /// Stop monitoring memory usage
  void stopMonitoring() {
    if (!_isMonitoring) return;

    _monitorTimer?.cancel();
    _monitorTimer = null;
    _isMonitoring = false;
    _log('Stopped memory monitoring');
  }

  /// Report current cache usage
  void _reportCacheUsage() {
    final effectCacheSize = EffectController.getEffectCacheSize();

    // Log cache usage
    _log('Effect cache size: $effectCacheSize items');

    // We can't reliably get exact memory thresholds on all platforms,
    // but we can periodically clean up cache to prevent memory issues
    if (effectCacheSize > _largeCacheThreshold) {
      _log(
        'Large effect cache detected ($effectCacheSize items) - triggering cleanup',
      );
      _triggerCleanup();
    }
  }

  /// Trigger memory cleanup
  void _triggerCleanup() {
    // Clear the effect cache
    EffectController.clearEffectCache();
  }

  /// Log with prefix
  void _log(String message) {
    debugPrint('[MemoryMonitor] $message');
  }
}
