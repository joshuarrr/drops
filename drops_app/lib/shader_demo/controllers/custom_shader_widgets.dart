import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'dart:math' as math;

import '../models/effect_settings.dart';
import '../models/animation_options.dart';

/// Controls debug logging for shaders
bool enableShaderDebugLogs = false;

/// Custom color effect shader widget
class ColorEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;

  const ColorEffectShader({
    super.key,
    required this.child,
    required this.settings,
    required this.animationValue, // This is the shared base time (0-1)
  });

  @override
  Widget build(BuildContext context) {
    if (enableShaderDebugLogs) {
      print("COLOR_SHADER: Building widget");
    }

    // Convenience aliases so the helper functions are easily accessible.
    final AnimationOptions colorOpts = settings.colorAnimOptions;
    final AnimationOptions overlayOpts = settings.overlayAnimOptions;

    // Pre-compute animated values for HSL and Overlay independently.
    final double hslAnimValue = _computeAnimatedValue(
      colorOpts,
      animationValue,
    );
    final double overlayAnimValue = _computeAnimatedValue(
      overlayOpts,
      animationValue,
    );

    // Simplified approach using AnimatedSampler with ShaderBuilder
    return ShaderBuilder(assetKey: 'assets/shaders/color_effect.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          // Set the texture sampler first
          shader.setImageSampler(0, image);

          // Compute animated values when requested
          double hue = settings.hue;
          double saturation = settings.saturation;
          double lightness = settings.lightness;

          if (settings.colorAnimated) {
            // Animate hue through the full color wheel [0,1)
            hue = (hue + hslAnimValue) % 1.0;

            // Add a gentle pulse to saturation & lightness for a richer effect
            final double pulse = math.sin(hslAnimValue * 2 * math.pi);
            saturation = (saturation + 0.25 * pulse).clamp(-1.0, 1.0);
            lightness = (lightness + 0.15 * pulse).clamp(-1.0, 1.0);
          }

          // Determine overlay values (may animate independently)
          double overlayHue = settings.overlayHue;
          double overlayIntensity = settings.overlayIntensity;
          double overlayOpacity = settings.overlayOpacity;

          if (settings.overlayAnimated) {
            overlayHue = (overlayHue + overlayAnimValue) % 1.0;
            // Subtle breathing effect on intensity & opacity
            final double pulse = math.sin(overlayAnimValue * 2 * math.pi);
            overlayIntensity = (overlayIntensity + 0.3 * pulse).clamp(0.0, 1.0);
            overlayOpacity = (overlayOpacity + 0.3 * pulse).clamp(0.0, 1.0);
          }

          // Set uniforms after the texture sampler
          shader.setFloat(0, animationValue);
          shader.setFloat(1, hue);
          shader.setFloat(2, saturation);
          shader.setFloat(3, lightness);
          shader.setFloat(4, overlayHue);
          shader.setFloat(5, overlayIntensity);
          shader.setFloat(6, overlayOpacity);
          shader.setFloat(7, image.width.toDouble());
          shader.setFloat(8, image.height.toDouble());

          // Draw with the shader, ensuring it covers the full area
          canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
        } catch (e) {
          print("COLOR_SHADER ERROR: $e");
          // Fall back to drawing the original image
          canvas.drawImageRect(
            image,
            Rect.fromLTWH(
              0,
              0,
              image.width.toDouble(),
              image.height.toDouble(),
            ),
            Rect.fromLTWH(0, 0, size.width, size.height),
            Paint(),
          );
        }
      }, child: this.child);
    }, child: child);
  }

  // ---------------------------------------------------------------------------
  // Helper functions
  // ---------------------------------------------------------------------------

  // Animation duration bounds – keep in sync with the values in the demo.
  static const int _minDurationMs = 30000; // slowest
  static const int _maxDurationMs = 300; // fastest

  // Simple hash function for repeatable pseudo-random numbers.
  double _hash(double x) {
    return (math.sin(x * 12.9898) * 43758.5453).abs() % 1;
  }

  // Smoothly varying random value in [0,1) for a given time ‑ matches the
  // implementation used in the main demo widget.
  double _smoothRandom(double t, {int segments = 8}) {
    final double scaled = t * segments;
    final double idx0 = scaled.floorToDouble();
    final double idx1 = idx0 + 1.0;
    final double frac = scaled - idx0;

    final double r0 = _hash(idx0);
    final double r1 = _hash(idx1);

    // Ease in/out for softer transitions.
    final double eased = Curves.easeInOut.transform(frac);
    return ui.lerpDouble(r0, r1, eased)!;
  }

  double _applyEasing(AnimationEasing easing, double t) {
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

  // Compute the animated value (0-1) for the given options using the shared
  // base time coming from the AnimationController.
  double _computeAnimatedValue(AnimationOptions opts, double baseTime) {
    // Map the normalised speed to a duration (same mapping as in the demo).
    final double durationMs = ui.lerpDouble(
      _minDurationMs.toDouble(),
      _maxDurationMs.toDouble(),
      opts.speed,
    )!;

    // Translate duration back into a speed factor relative to the slowest.
    final double speedFactor = _minDurationMs / durationMs;

    // Scale time – keep it in [0,1).
    final double scaledTime = (baseTime * speedFactor) % 1.0;

    // Apply animation mode.
    final double modeValue = opts.mode == AnimationMode.pulse
        ? scaledTime
        : _smoothRandom(scaledTime);

    // Apply easing and return.
    return _applyEasing(opts.easing, modeValue);
  }
}

/// Custom blur effect shader widget
class BlurEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;

  const BlurEffectShader({
    super.key,
    required this.child,
    required this.settings,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    if (enableShaderDebugLogs) {
      print(
        "SHATTER_SHADER: Building widget with amount=${settings.blurAmount.toStringAsFixed(2)} (animated: ${settings.blurAnimated})",
      );
    }

    // Simplified approach using AnimatedSampler with ShaderBuilder
    return ShaderBuilder(assetKey: 'assets/shaders/blur_effect.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          // Set the texture sampler first
          shader.setImageSampler(0, image);

          // Compute animated amount if enabled
          double amount = settings.blurAmount;
          if (settings.blurAnimated) {
            // Compute animated progress based on per-blur animation options.

            // Reuse helper to obtain a 0-1 value taking speed/mode/easing into account.
            final double animValue = _computeAnimatedValue(
              settings.blurAnimOptions,
              animationValue,
            );

            // Map to a smooth pulse (same visual as before) for pulse mode or
            // directly use the randomised value for the alternative mode.
            final double intensity =
                settings.blurAnimOptions.mode == AnimationMode.pulse
                ? (0.5 + 0.5 * math.sin(animValue * 2 * math.pi))
                : animValue;

            amount = amount * intensity;
          }

          // Set uniforms after the texture sampler
          shader.setFloat(0, amount);
          shader.setFloat(1, settings.blurRadius);
          shader.setFloat(2, image.width.toDouble());
          shader.setFloat(3, image.height.toDouble());
          shader.setFloat(4, settings.blurOpacity);
          shader.setFloat(5, settings.blurFacets);
          shader.setFloat(6, settings.blurBlendMode.toDouble());

          // Draw with the shader, ensuring it covers the full area
          canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
        } catch (e) {
          print("BLUR_SHADER ERROR: $e");
          // Fall back to drawing the original image
          canvas.drawImageRect(
            image,
            Rect.fromLTWH(
              0,
              0,
              image.width.toDouble(),
              image.height.toDouble(),
            ),
            Rect.fromLTWH(0, 0, size.width, size.height),
            Paint(),
          );
        }
      }, child: this.child);
    }, child: child);
  }

  // ---------------------------------------------------------------------------
  // Helper functions (duplicated from ColorEffectShader for now; could be
  // refactored into a shared utility if needed).
  // ---------------------------------------------------------------------------

  // Animation duration bounds – keep in sync with the demo.
  static const int _minDurationMs = 30000;
  static const int _maxDurationMs = 300;

  double _hash(double x) {
    return (math.sin(x * 12.9898) * 43758.5453).abs() % 1;
  }

  double _smoothRandom(double t, {int segments = 8}) {
    final double scaled = t * segments;
    final double idx0 = scaled.floorToDouble();
    final double idx1 = idx0 + 1.0;
    final double frac = scaled - idx0;

    final double r0 = _hash(idx0);
    final double r1 = _hash(idx1);

    final double eased = Curves.easeInOut.transform(frac);
    return ui.lerpDouble(r0, r1, eased)!;
  }

  double _applyEasing(AnimationEasing easing, double t) {
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

  double _computeAnimatedValue(AnimationOptions opts, double baseTime) {
    final double durationMs = ui.lerpDouble(
      _minDurationMs.toDouble(),
      _maxDurationMs.toDouble(),
      opts.speed,
    )!;

    final double speedFactor = _minDurationMs / durationMs;
    final double scaledTime = (baseTime * speedFactor) % 1.0;

    final double modeValue = opts.mode == AnimationMode.pulse
        ? scaledTime
        : _smoothRandom(scaledTime);

    return _applyEasing(opts.easing, modeValue);
  }
}

/// Custom noise effect shader widget
class NoiseEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;

  const NoiseEffectShader({
    super.key,
    required this.child,
    required this.settings,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    if (enableShaderDebugLogs) {
      print(
        "NOISE_SHADER: Building widget with scale=${settings.noiseScale.toStringAsFixed(2)}, wave=${settings.waveAmount.toStringAsFixed(3)} (animated: ${settings.noiseAnimated})",
      );
    }

    // Simplified approach using AnimatedSampler with ShaderBuilder
    return ShaderBuilder(assetKey: 'assets/shaders/noise_effect.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          // Set the texture sampler first
          shader.setImageSampler(0, image);

          // When noiseAnimated is false, we still send the noise speed
          // but we don't send an animated time value
          double timeValue = settings.noiseAnimated ? animationValue : 0.0;

          // The noise speed to use, which can be 0 even when animated
          double noiseSpeed = settings.noiseSpeed;

          // Compute animation values if animation is enabled
          if (settings.noiseAnimated) {
            // Compute animated progress based on noise animation options
            final double animValue = _computeAnimatedValue(
              settings.noiseAnimOptions,
              animationValue,
            );

            // Use the animation value to control time
            timeValue = animValue;

            // Scale the noise speed based on animation options
            if (settings.noiseAnimOptions.mode == AnimationMode.pulse) {
              // Add a breathing effect to the speed in pulse mode
              final double pulse = math.sin(animValue * 2 * math.pi);
              noiseSpeed = settings.noiseSpeed * (0.5 + 0.5 * pulse);
            }
          }

          // Set uniforms after the texture sampler
          shader.setFloat(0, timeValue); // Time
          shader.setFloat(
            1,
            size.width / size.height,
          ); // Resolution aspect ratio
          shader.setFloat(2, settings.noiseScale); // Noise scale
          shader.setFloat(3, noiseSpeed); // Noise speed
          shader.setFloat(4, settings.colorIntensity); // Color intensity
          shader.setFloat(5, settings.waveAmount); // Wave distortion amount
          shader.setFloat(
            6,
            settings.noiseAnimated ? 1.0 : 0.0,
          ); // Animation flag

          // Draw with the shader, ensuring it covers the full area
          canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
        } catch (e) {
          print("NOISE_SHADER ERROR: $e");
          // Fall back to drawing the original image
          canvas.drawImageRect(
            image,
            Rect.fromLTWH(
              0,
              0,
              image.width.toDouble(),
              image.height.toDouble(),
            ),
            Rect.fromLTWH(0, 0, size.width, size.height),
            Paint(),
          );
        }
      }, child: this.child);
    }, child: child);
  }

  // ---------------------------------------------------------------------------
  // Helper functions (similar to other shader widgets)
  // ---------------------------------------------------------------------------

  // Animation duration bounds – keep in sync with the demo.
  static const int _minDurationMs = 30000;
  static const int _maxDurationMs = 300;

  double _hash(double x) {
    return (math.sin(x * 12.9898) * 43758.5453).abs() % 1;
  }

  double _smoothRandom(double t, {int segments = 8}) {
    final double scaled = t * segments;
    final double idx0 = scaled.floorToDouble();
    final double idx1 = idx0 + 1.0;
    final double frac = scaled - idx0;

    final double r0 = _hash(idx0);
    final double r1 = _hash(idx1);

    final double eased = Curves.easeInOut.transform(frac);
    return ui.lerpDouble(r0, r1, eased)!;
  }

  double _applyEasing(AnimationEasing easing, double t) {
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

  double _computeAnimatedValue(AnimationOptions opts, double baseTime) {
    final double durationMs = ui.lerpDouble(
      _minDurationMs.toDouble(),
      _maxDurationMs.toDouble(),
      opts.speed,
    )!;

    final double speedFactor = _minDurationMs / durationMs;
    final double scaledTime = (baseTime * speedFactor) % 1.0;

    final double modeValue = opts.mode == AnimationMode.pulse
        ? scaledTime
        : _smoothRandom(scaledTime);

    return _applyEasing(opts.easing, modeValue);
  }
}
