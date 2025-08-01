import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/animation_options.dart';

/// Utility class for shader animation calculations
class ShaderAnimationUtils {
  // Track animation start time for continuous timing
  static DateTime? _animationStartTime;
  // Animation duration bounds - centralized for consistency
  static const int minDurationMs = 30000; // slowest (30s)
  static const int maxDurationMs = 500; // fastest (0.5s)

  // Randomization state
  static int _currentCycle = -1;
  static double _currentRandomStart = 0.0;
  static double _currentRandomEnd = 0.0;
  static final math.Random _random = math.Random();

  // Apply easing curve to a normalized time value
  static double applyEasing(AnimationEasing easing, double t) {
    switch (easing) {
      case AnimationEasing.easeIn:
        return Curves.easeIn.transform(t);
      case AnimationEasing.easeOut:
        return Curves.easeOut.transform(t);
      case AnimationEasing.easeInOut:
        return Curves.easeInOut.transform(t);
      case AnimationEasing.linear:
      default:
        return t;
    }
  }

  // Compute the animated value (0-1) for the given options using real elapsed time
  static double computeAnimatedValue(AnimationOptions opts, double baseTime) {
    // Get real elapsed time in seconds
    final now = DateTime.now();
    if (_animationStartTime == null) {
      _animationStartTime = now;
    }
    final double elapsedSeconds =
        now.difference(_animationStartTime!).inMilliseconds / 1000.0;

    // Map the normalized speed to actual duration in seconds
    final double durationSeconds = ui.lerpDouble(
      30.0, // slowest = 30 actual seconds
      0.5, // fastest = 0.5 actual seconds
      opts.speed,
    )!;

    // Calculate animation phase (0-1) based on actual elapsed time
    final double animationPhase = (elapsedSeconds / durationSeconds) % 1.0;
    final int currentCycle = (elapsedSeconds / durationSeconds).floor();

    // Apply animation mode
    final double modeValue;
    if (opts.mode == AnimationMode.pulse) {
      modeValue = animationPhase;
    } else {
      // For randomized mode: generate new random targets for each cycle
      if (currentCycle != _currentCycle) {
        _currentCycle = currentCycle;
        _currentRandomStart = _currentRandomEnd;
        _currentRandomEnd = _random.nextDouble();
      }

      // Smoothly interpolate between start and end values for this cycle
      final double easedPhase = Curves.easeInOut.transform(animationPhase);
      modeValue = ui.lerpDouble(
        _currentRandomStart,
        _currentRandomEnd,
        easedPhase,
      )!;
    }

    // Apply easing and return
    return applyEasing(opts.easing, modeValue);
  }

  /// Compute a randomized parameter value for locked/unlocked parameters
  ///
  /// For randomized animation mode:
  /// - Locked parameters: animate randomly between 0 and the slider value
  /// - Unlocked parameters: animate randomly between min and max range
  ///
  /// @param sliderValue The current slider setting
  /// @param animationOptions The animation configuration (speed, easing)
  /// @param baseTime The animation time from the controller
  /// @param isLocked Whether the parameter is locked to the slider value
  /// @param minValue The minimum possible value for this parameter
  /// @param maxValue The maximum possible value for this parameter
  static double computeRandomizedParameterValue(
    double sliderValue,
    AnimationOptions animationOptions,
    double baseTime, {
    required bool isLocked,
    required double minValue,
    required double maxValue,
  }) {
    // Get the base random animation value (0-1)
    final double randomValue = computeAnimatedValue(animationOptions, baseTime);

    if (isLocked) {
      // Locked: animate between 0 and slider value
      return ui.lerpDouble(0.0, sliderValue, randomValue)!;
    } else {
      // Unlocked: animate between min and max range
      return ui.lerpDouble(minValue, maxValue, randomValue)!;
    }
  }

  /// Compute a smooth pulse value (0-1) for consistent pulse animations across all shaders
  ///
  /// This creates a smooth oscillating pulse that goes from 0 to 1 and back to 0
  /// with timing based on real elapsed time matching the speed setting
  static double computePulseValue(AnimationOptions opts, double baseTime) {
    // Use the same real elapsed time approach as computeAnimatedValue
    final now = DateTime.now();
    if (_animationStartTime == null) {
      _animationStartTime = now;
    }
    final double elapsedSeconds =
        now.difference(_animationStartTime!).inMilliseconds / 1000.0;

    // Map the normalized speed to actual duration in seconds
    final double durationSeconds = ui.lerpDouble(
      30.0, // slowest = 30 actual seconds
      0.5, // fastest = 0.5 actual seconds
      opts.speed,
    )!;

    // Calculate animation phase (0-1) based on actual elapsed time
    final double animationPhase = (elapsedSeconds / durationSeconds) % 1.0;

    // Create pulse using sine wave
    final double pulse = math.sin(animationPhase * 2 * math.pi) * 0.5 + 0.5;

    // Apply easing curve if specified
    return applyEasing(opts.easing, pulse);
  }
}
