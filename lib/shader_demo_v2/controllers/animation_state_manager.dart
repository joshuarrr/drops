import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Manages individual parameter lock states for granular animation control
/// This keeps animation UI state separate from data models
class AnimationStateManager extends ChangeNotifier {
  static final AnimationStateManager _instance =
      AnimationStateManager._internal();
  factory AnimationStateManager() => _instance;
  AnimationStateManager._internal();

  // Map of parameter IDs to their lock states
  final Map<String, bool> _parameterLocks = {};

  // Map of parameter IDs to their current animated values
  final Map<String, double> _currentAnimatedValues = {};

  // Throttling to prevent excessive rebuilds
  static const double _minimumValueChange =
      0.01; // Only notify if change is significant (1%)
  DateTime _lastNotification = DateTime.now();
  static const int _minNotificationIntervalMs =
      100; // Max 10fps updates for animated values

  /// Check if a parameter is locked (defaults to unlocked if not set)
  /// Unlocked = parameter animates, Locked = parameter uses slider value
  bool isParameterLocked(String parameterId) {
    return _parameterLocks[parameterId] ?? false;
  }

  /// Set the lock state for a parameter
  void setParameterLock(String parameterId, bool isLocked) {
    if (_parameterLocks[parameterId] != isLocked) {
      _parameterLocks[parameterId] = isLocked;
      // CRITICAL FIX: Defer notification to avoid build-during-frame
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      print(
        'Parameter $parameterId lock state changed to: ${isLocked ? "locked" : "unlocked"}',
      );
    }
  }

  /// Toggle the lock state for a parameter
  void toggleParameterLock(String parameterId) {
    setParameterLock(parameterId, !isParameterLocked(parameterId));
  }

  /// Update the current animated value for a parameter
  /// This allows sliders to show real-time animated values
  void updateAnimatedValue(String parameterId, double value) {
    final currentValue = _currentAnimatedValues[parameterId];

    // Only update if the change is significant to prevent excessive rebuilds
    if (currentValue == null ||
        (currentValue - value).abs() > _minimumValueChange) {
      _currentAnimatedValues[parameterId] = value;
      _notifyListenersThrottled();
    }
  }

  /// Throttled notification to prevent excessive rebuilds
  /// Uses post-frame callback to avoid build-during-frame issues
  void _notifyListenersThrottled() {
    final now = DateTime.now();
    final timeSinceLastNotification = now
        .difference(_lastNotification)
        .inMilliseconds;

    if (timeSinceLastNotification >= _minNotificationIntervalMs) {
      _lastNotification = now;
      // CRITICAL FIX: Defer notification to avoid build-during-frame
      // Use SchedulerBinding instead of WidgetsBinding for consistency
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (hasListeners) {
          // Check if we still have listeners before notifying
          notifyListeners();
        }
      });
    }
  }

  /// Get the current animated value for a parameter
  /// Returns null if no animated value is set (parameter not animating)
  double? getCurrentAnimatedValue(String parameterId) {
    return _currentAnimatedValues[parameterId];
  }

  /// Clear animated value for a parameter (when animation stops)
  void clearAnimatedValue(String parameterId) {
    if (_currentAnimatedValues.containsKey(parameterId)) {
      _currentAnimatedValues.remove(parameterId);

      // Defer notification to avoid setState during build
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Clear all locks (useful for reset functionality)
  void clearAllLocks() {
    if (_parameterLocks.isNotEmpty) {
      _parameterLocks.clear();
      // Defer notification to avoid setState during build
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Clear all animated values (useful for when all animations stop)
  void clearAllAnimatedValues() {
    if (_currentAnimatedValues.isNotEmpty) {
      _currentAnimatedValues.clear();
      // Defer notification to avoid setState during build
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Get all locked parameters (useful for debugging)
  Map<String, bool> getAllLocks() {
    return Map.unmodifiable(_parameterLocks);
  }

  /// Get all current animated values (useful for debugging)
  Map<String, double> getAllAnimatedValues() {
    return Map.unmodifiable(_currentAnimatedValues);
  }

  /// Reset locks for a specific effect (e.g., when resetting noise settings)
  void clearLocksForEffect(String effectPrefix) {
    final keysToRemove = _parameterLocks.keys
        .where((key) => key.startsWith(effectPrefix))
        .toList();

    if (keysToRemove.isNotEmpty) {
      for (final key in keysToRemove) {
        _parameterLocks.remove(key);
      }
      // Defer notification to avoid setState during build
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  /// Clear animated values for a specific effect
  void clearAnimatedValuesForEffect(String effectPrefix) {
    final keysToRemove = _currentAnimatedValues.keys
        .where((key) => key.startsWith(effectPrefix))
        .toList();

    if (keysToRemove.isNotEmpty) {
      for (final key in keysToRemove) {
        _currentAnimatedValues.remove(key);
      }
      // Defer notification to avoid setState during build
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
}

/// Parameter ID constants for consistent referencing
class ParameterIds {
  // Noise effect parameters
  static const String noiseScale = 'noise.scale';
  static const String noiseSpeed = 'noise.speed';
  static const String waveAmount = 'noise.waveAmount';
  static const String colorIntensity = 'noise.colorIntensity';

  // Blur effect parameters
  static const String blurAmount = 'blur.amount';
  static const String blurRadius = 'blur.radius';
  static const String blurOpacity = 'blur.opacity';
  static const String blurIntensity = 'blur.intensity';
  static const String blurContrast = 'blur.contrast';

  // Chromatic aberration effect parameters
  static const String chromaticAmount = 'chromatic.amount';
  static const String chromaticAngle = 'chromatic.angle';
  static const String chromaticSpread = 'chromatic.spread';
  static const String chromaticIntensity = 'chromatic.intensity';

  // Add more effects as needed...
}
