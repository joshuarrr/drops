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
      // For randomized mode, we need to generate random values that smoothly transition
      // Use a different approach for randomized mode that creates more variation

      // Scale time by speed - higher speed = faster animation
      final double scaledTime = (baseTime * opts.speed * 2.0);

      // Use multiple sine waves with different frequencies to create pseudo-random values
      // This creates smooth transitions between random-looking values
      final double random1 = (math.sin(scaledTime * math.pi * 2.7) * 0.5 + 0.5);
      final double random2 = (math.sin(scaledTime * math.pi * 1.3) * 0.5 + 0.5);
      final double random3 = (math.sin(scaledTime * math.pi * 3.9) * 0.5 + 0.5);

      // Combine the waves for a more random-looking but smooth result
      final double combinedRandom = (random1 + random2 + random3) / 3.0;

      // Apply easing and return
      final result = applyEasing(opts.easing, combinedRandom);
      print(
        "[DEBUG] ShaderAnimationUtils computed randomized value: $result from scaledTime=$scaledTime",
      );
      return result;
    }
  }

  /// Compute a randomized parameter value for locked/unlocked parameters
  ///
  /// For randomized animation mode:
  /// - Locked parameters: stay fixed at the slider value (no animation)
  /// - Unlocked parameters: animate randomly between min and max range, starting from slider value
  ///
  /// @param sliderValue The current slider setting
  /// @param animationOptions The animation configuration (speed, easing)
  /// @param baseTime The animation time from the controller
  /// @param isLocked Whether the parameter is locked to the slider value
  /// @param minValue The minimum possible value for this parameter
  /// @param maxValue The maximum possible value for this parameter
  /// @param parameterId Optional parameter ID to create unique random patterns for each parameter
  static double computeRandomizedParameterValue(
    double sliderValue,
    AnimationOptions animationOptions,
    double baseTime, {
    required bool isLocked,
    required double minValue,
    required double maxValue,
    String? parameterId,
  }) {
    if (isLocked) {
      // Locked: stay fixed at the slider value (no animation)
      print("[DEBUG] Locked parameter using fixed slider value: $sliderValue");
      return sliderValue;
    } else {
      // Unlocked: animate randomly between min and max range
      // Create a unique phase offset based on parameter ID to make each parameter animate differently
      double phaseOffset = 0.0;

      // Use the parameter ID to create a unique phase offset
      if (parameterId != null) {
        // Simple hash of the parameter ID string to get a consistent phase offset
        int hash = 0;
        for (int i = 0; i < parameterId.length; i++) {
          hash = (hash + parameterId.codeUnitAt(i) * 31) % 1000;
        }
        phaseOffset = hash / 1000; // Normalize to 0.0-1.0 range

        // Add the phase offset to the base time to create a unique starting point
        baseTime = (baseTime + phaseOffset) % 1.0;
      }

      // Get the base random animation value (0-1) with the phase offset applied
      final double randomValue = computeAnimatedValue(
        animationOptions,
        baseTime,
      );

      // Use the random value to animate across the parameter's full range
      final double animatedValue = ui.lerpDouble(
        minValue,
        maxValue,
        randomValue,
      )!;
      print(
        "[DEBUG] Unlocked parameter ($parameterId) randomized value: $animatedValue (from $randomValue, offset=$phaseOffset)",
      );
      return animatedValue;
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
