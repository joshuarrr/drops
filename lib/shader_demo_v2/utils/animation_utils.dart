import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/animation_options.dart';

/// Utility class for shader animation calculations
class ShaderAnimationUtils {
  // Animation duration bounds - centralized for consistency
  static const int minDurationMs = 30000; // slowest (30s)
  static const int maxDurationMs = 500; // fastest (0.5s)

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
        return t;
    }
  }

  // Compute the animated value (0-1) for the given options using the animation controller value
  static double computeAnimatedValue(AnimationOptions opts, double baseTime) {
    // CRITICAL FIX: Log the baseTime to verify it's being used
    print(
      "[DEBUG] ShaderAnimationUtils.computeAnimatedValue called with baseTime=${baseTime.toStringAsFixed(3)}",
    );

    // Simplified approach like V1's blur_effect_shader.dart
    if (opts.mode == AnimationMode.pulse) {
      // Use pulse calculation for consistency
      return computePulseValue(opts, baseTime);
    } else {
      // For randomized mode, use a simpler approach
      // Scale time by speed - higher speed = faster animation
      final double scaledTime = (baseTime * opts.speed * 2.0) % 1.0;

      // Apply easing and return
      final result = applyEasing(opts.easing, scaledTime);
      print(
        "[DEBUG] ShaderAnimationUtils computed value: $result from scaledTime=$scaledTime",
      );
      return result;
    }
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
  /// using the animation controller value
  static double computePulseValue(AnimationOptions opts, double baseTime) {
    // CRITICAL FIX: Log the baseTime to verify it's being used
    print(
      "[DEBUG] ShaderAnimationUtils.computePulseValue called with baseTime=${baseTime.toStringAsFixed(3)}",
    );

    // Simplified approach like V1's blur_effect_shader.dart
    // Direct pulse calculation - multiply by speed factor for faster animation
    final double pulseTime = baseTime * opts.speed * 4.0;

    // Create sine wave oscillation (0 to 1 to 0)
    final double pulse = (math.sin(pulseTime * math.pi) * 0.5 + 0.5).abs();

    // Apply easing
    final result = applyEasing(opts.easing, pulse);

    // Log the result for debugging
    print(
      "[DEBUG] ShaderAnimationUtils computed pulse: $result from pulseTime=$pulseTime",
    );

    return result;
  }
}
