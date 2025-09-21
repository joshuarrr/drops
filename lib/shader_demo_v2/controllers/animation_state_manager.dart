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

  // Color HSL effect parameters
  static const String colorHue = 'color.hue';
  static const String colorSaturation = 'color.saturation';
  static const String colorLightness = 'color.lightness';

  // Color Overlay effect parameters
  static const String overlayHue = 'overlay.hue';
  static const String overlayIntensity = 'overlay.intensity';
  static const String overlayOpacity = 'overlay.opacity';

  // Rain effect parameters
  static const String rainIntensity = 'rain.intensity';
  static const String rainDropSize = 'rain.dropSize';
  static const String rainFallSpeed = 'rain.fallSpeed';
  static const String rainRefraction = 'rain.refraction';
  static const String rainTrailIntensity = 'rain.trailIntensity';

  // Ripple effect parameters
  static const String rippleIntensity = 'ripple.intensity';
  static const String rippleSize = 'ripple.size';
  static const String rippleSpeed = 'ripple.speed';
  static const String rippleOpacity = 'ripple.opacity';
  static const String rippleColor = 'ripple.color';
  static const String rippleDropCount = 'ripple.dropCount';
  static const String rippleSeed = 'ripple.seed';
  static const String rippleOvalness = 'ripple.ovalness';
  static const String rippleRotation = 'ripple.rotation';

  // Sketch effect parameters
  static const String sketchOpacity = 'sketch.opacity';
  static const String sketchImageOpacity = 'sketch.imageOpacity';
  static const String sketchLumThreshold1 = 'sketch.lumThreshold1';
  static const String sketchLumThreshold2 = 'sketch.lumThreshold2';
  static const String sketchLumThreshold3 = 'sketch.lumThreshold3';
  static const String sketchLumThreshold4 = 'sketch.lumThreshold4';
  static const String sketchHatchYOffset = 'sketch.hatchYOffset';
  static const String sketchLineSpacing = 'sketch.lineSpacing';
  static const String sketchLineThickness = 'sketch.lineThickness';

  // Edge effect parameters
  static const String edgeOpacity = 'edge.opacity';
  static const String edgeIntensity = 'edge.intensity';
  static const String edgeThickness = 'edge.thickness';
  static const String edgeColor = 'edge.color';

  // Glitch effect parameters
  static const String glitchOpacity = 'glitch.opacity';
  static const String glitchIntensity = 'glitch.intensity';
  static const String glitchSpeed = 'glitch.speed';
  static const String glitchBlockSize = 'glitch.blockSize';
  static const String glitchHorizontalSliceIntensity =
      'glitch.horizontalSliceIntensity';
  static const String glitchVerticalSliceIntensity =
      'glitch.verticalSliceIntensity';

  // VHS effect parameters
  static const String vhsOpacity = 'vhs.opacity';
  static const String vhsNoiseIntensity = 'vhs.noiseIntensity';
  static const String vhsFieldLines = 'vhs.fieldLines';
  static const String vhsHorizontalWaveStrength = 'vhs.horizontalWaveStrength';
  static const String vhsHorizontalWaveScreenSize =
      'vhs.horizontalWaveScreenSize';
  static const String vhsHorizontalWaveVerticalSize =
      'vhs.horizontalWaveVerticalSize';
  static const String vhsDottedNoiseStrength = 'vhs.dottedNoiseStrength';
  static const String vhsHorizontalDistortionStrength =
      'vhs.horizontalDistortionStrength';

  // Flare effect parameters
  static const String flareDistortion = 'flare.distortion';
  static const String flareSwirl = 'flare.swirl';
  static const String flareGrainMixer = 'flare.grainMixer';
  static const String flareGrainOverlay = 'flare.grainOverlay';
  static const String flareOffsetX = 'flare.offsetX';
  static const String flareOffsetY = 'flare.offsetY';
  static const String flareScale = 'flare.scale';
  static const String flareRotation = 'flare.rotation';
  static const String flareOpacity = 'flare.opacity';

  // Add more effects as needed...
}
