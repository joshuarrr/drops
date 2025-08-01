import 'dart:async';
import 'dart:math' as math;
import '../controllers/effect_controller.dart';

/// A memory profiler to prevent memory leaks and excessive memory usage
class MemoryProfiler {
  static Timer? _monitorTimer;
  static bool _isMonitoring = false;

  // Lowered thresholds for more aggressive memory management
  static const int _largeCacheThreshold = 5; // Reduced from 10

  // Track memory usage patterns
  static int _peakCacheSize = 0;
  static int _cacheCleanupCount = 0;
  static DateTime? _lastCleanupTime;
  static final List<int> _recentCacheSizes = [];

  // Reduce log frequency
  static bool _verboseLogging = false;
  static int _logCounter = 0;
  static const int _logFrequency = 5; // Only log every 5th check

  /// Start memory monitoring
  static void startMonitoring({int intervalMs = 3000, bool verbose = false}) {
    // Only start if not already monitoring
    if (_isMonitoring) {
      print(
        'Memory profiler already running, ignoring duplicate start request',
      );
      return;
    }

    _verboseLogging = verbose;
    print('Memory profiling enabled - monitoring effect cache');
    _isMonitoring = true;

    // Initial cache check without cleanup
    _checkCacheSize();

    // Set up periodic monitoring
    _monitorTimer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      _checkCacheSize();
    });
  }

  /// Stop memory monitoring
  static void stopMonitoring() {
    if (!_isMonitoring) return;

    _monitorTimer?.cancel();
    _monitorTimer = null;
    _isMonitoring = false;

    if (_verboseLogging) {
      _log('Stopped monitoring');
    }

    // Final cleanup when stopping
    _triggerCleanup(reason: "shutdown");

    // Report statistics
    _reportMemoryStats();
  }

  /// Check cache size and clean up if needed
  static void _checkCacheSize() {
    final effectCacheSize = EffectController.getEffectCacheSize();

    // Update tracking metrics
    _peakCacheSize = math.max(_peakCacheSize, effectCacheSize);
    _recentCacheSizes.add(effectCacheSize);
    if (_recentCacheSizes.length > 10) {
      _recentCacheSizes.removeAt(0);
    }

    // Log cache usage periodically, but reduce frequency
    _logCounter++;
    if (_verboseLogging || _logCounter % _logFrequency == 0) {
      if (effectCacheSize > 0 || _verboseLogging) {
        _log('Effect cache size: $effectCacheSize items');
      }
    }

    // Clean up if cache gets too large
    if (effectCacheSize > _largeCacheThreshold) {
      _triggerCleanup(reason: "threshold_exceeded");
    }

    // No more periodic cleanup - too spammy
  }

  /// Trigger memory cleanup (smart - only when needed)
  static void _triggerCleanup({required String reason}) {
    final effectCacheSize = EffectController.getEffectCacheSize();

    // Only clear if there's actually something to clear
    if (effectCacheSize > 0) {
      _log('Smart cleanup: clearing $effectCacheSize items - reason: $reason');

      // Record cleanup time and stats
      _lastCleanupTime = DateTime.now();
      _cacheCleanupCount++;

      // Clear the effect cache
      EffectController.clearEffectCache();
    }
    // Don't spam logs or waste time clearing empty caches
  }

  /// Report memory statistics
  static void _reportMemoryStats() {
    final avgCacheSize = _recentCacheSizes.isEmpty
        ? 0
        : _recentCacheSizes.reduce((a, b) => a + b) / _recentCacheSizes.length;

    if (_cacheCleanupCount > 0 || _peakCacheSize > 0) {
      _log(
        'Memory stats: peak cache size: $_peakCacheSize, cleanups: $_cacheCleanupCount, '
        'avg recent size: ${avgCacheSize.toStringAsFixed(1)}',
      );
    }
  }

  /// Simple logging method
  static void _log(String message) {
    print('[MemoryProfiler] $message');
  }
}
