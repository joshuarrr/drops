import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/animation_options.dart';

/// Utility class for shader animation calculations
class ShaderAnimationUtils {
  // Animation duration bounds - centralized for consistency
  static const int minDurationMs = 30000; // slowest
  static const int maxDurationMs = 300; // fastest

  // Simple hash function for repeatable pseudo-random numbers
  static double hash(double x) {
    return (math.sin(x * 12.9898) * 43758.5453).abs() % 1;
  }

  // Smoothly varying random value in [0,1) for a given time
  static double smoothRandom(double t, {int segments = 8}) {
    final double scaled = t * segments;
    final double idx0 = scaled.floorToDouble();
    final double idx1 = idx0 + 1.0;
    final double frac = scaled - idx0;

    final double r0 = hash(idx0);
    final double r1 = hash(idx1);

    // Smooth interpolation using easeInOut for softer transitions
    final double eased = Curves.easeInOut.transform(frac);
    return ui.lerpDouble(r0, r1, eased)!;
  }

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

  // Compute the animated value (0-1) for the given options using the shared base time
  static double computeAnimatedValue(AnimationOptions opts, double baseTime) {
    // Map the normalized speed to a duration
    final double durationMs = ui.lerpDouble(
      minDurationMs.toDouble(),
      maxDurationMs.toDouble(),
      opts.speed,
    )!;

    // Translate duration back into a speed factor relative to the slowest
    final double speedFactor = minDurationMs / durationMs;

    // Scale time – keep it in [0,1)
    final double scaledTime = (baseTime * speedFactor) % 1.0;

    // Apply animation mode
    final double modeValue = opts.mode == AnimationMode.pulse
        ? scaledTime
        : smoothRandom(scaledTime);

    // Apply easing and return
    return applyEasing(opts.easing, modeValue);
  }
}
