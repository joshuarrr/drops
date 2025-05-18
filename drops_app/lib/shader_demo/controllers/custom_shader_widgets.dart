import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'dart:math' as math;
import 'dart:developer' as developer;

import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../utils/animation_utils.dart';

/// Controls debug logging for shaders
bool enableShaderDebugLogs = true;

/// Custom color effect shader widget
class ColorEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final String _logTag = 'ColorEffectShader';

  // Add static map to track last logged values to avoid repeating identical logs
  static final Map<String, Map<String, dynamic>> _lastLoggedValues = {};

  // Custom log function that uses both dart:developer and debugPrint for visibility
  void _log(String message) {
    if (!enableShaderDebugLogs) return;
    developer.log(message, name: _logTag);
    debugPrint('[$_logTag] $message');
  }

  // Reduces verbosity by only logging when values are non-zero or changed
  bool _shouldLogColorSettings() {
    // Only log if some values are non-zero
    const double threshold = 0.01;

    // For color effect, only log if saturation or lightness is significant
    bool hasColorEffect =
        settings.colorSettings.saturation.abs() > threshold ||
        settings.colorSettings.lightness.abs() > threshold;

    // For overlay, only log when both intensity and opacity are non-zero
    bool hasOverlayEffect =
        settings.colorSettings.overlayIntensity > threshold &&
        settings.colorSettings.overlayOpacity > threshold;

    // Track instance ID to compare with previous values
    final String instanceId = preserveTransparency ? 'text' : 'background';
    final Map<String, dynamic> currentValues = {
      'hue': settings.colorSettings.hue,
      'saturation': settings.colorSettings.saturation,
      'lightness': settings.colorSettings.lightness,
      'overlayIntensity': settings.colorSettings.overlayIntensity,
      'overlayOpacity': settings.colorSettings.overlayOpacity,
    };

    // Check if values changed
    bool changed = false;
    if (_lastLoggedValues.containsKey(instanceId)) {
      final prevValues = _lastLoggedValues[instanceId]!;
      changed =
          (prevValues['hue'] != currentValues['hue']) ||
          (prevValues['saturation'] != currentValues['saturation']) ||
          (prevValues['lightness'] != currentValues['lightness']) ||
          (prevValues['overlayIntensity'] !=
              currentValues['overlayIntensity']) ||
          (prevValues['overlayOpacity'] != currentValues['overlayOpacity']);
    } else {
      // First time seeing this instance
      changed = true;
    }

    // Update values for next time
    if (changed && (hasColorEffect || hasOverlayEffect)) {
      _lastLoggedValues[instanceId] = currentValues;
    }

    return changed && (hasColorEffect || hasOverlayEffect);
  }

  const ColorEffectShader({
    super.key,
    required this.child,
    required this.settings,
    required this.animationValue, // This is the shared base time (0-1)
    this.preserveTransparency = false,
  });

  @override
  Widget build(BuildContext context) {
    // Only log when there are non-zero values or values have changed
    if (_shouldLogColorSettings()) {
      _log(
        "Building ColorEffectShader (${preserveTransparency ? 'text' : 'background'}) with " +
            "hsl=[${settings.colorSettings.hue.toStringAsFixed(2)}, " +
            "${settings.colorSettings.saturation.toStringAsFixed(2)}, " +
            "${settings.colorSettings.lightness.toStringAsFixed(2)}], " +
            "overlay=[${settings.colorSettings.overlayIntensity.toStringAsFixed(2)}, " +
            "${settings.colorSettings.overlayOpacity.toStringAsFixed(2)}]",
      );
    }

    // Convenience aliases so the helper functions are easily accessible.
    final AnimationOptions colorOpts = settings.colorSettings.colorAnimOptions;
    final AnimationOptions overlayOpts =
        settings.colorSettings.overlayAnimOptions;

    // Pre-compute animated values for HSL and Overlay independently.
    final double hslAnimValue = ShaderAnimationUtils.computeAnimatedValue(
      colorOpts,
      animationValue,
    );
    final double overlayAnimValue = ShaderAnimationUtils.computeAnimatedValue(
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
          double hue = settings.colorSettings.hue;
          double saturation = settings.colorSettings.saturation;
          double lightness = settings.colorSettings.lightness;

          if (settings.colorSettings.colorAnimated) {
            // Animate hue through the full color wheel [0,1)
            hue = (hue + hslAnimValue) % 1.0;

            // Add a gentle pulse to saturation & lightness for a richer effect
            final double pulse = math.sin(hslAnimValue * 2 * math.pi);
            saturation = (saturation + 0.25 * pulse).clamp(-1.0, 1.0);
            lightness = (lightness + 0.15 * pulse).clamp(-1.0, 1.0);
          }

          // Determine overlay values (may animate independently)
          double overlayHue = settings.colorSettings.overlayHue;
          double overlayIntensity = settings.colorSettings.overlayIntensity;
          double overlayOpacity = settings.colorSettings.overlayOpacity;

          if (settings.colorSettings.overlayAnimated) {
            overlayHue = (overlayHue + overlayAnimValue) % 1.0;
            // Subtle breathing effect on intensity & opacity
            final double pulse = math.sin(overlayAnimValue * 2 * math.pi);
            overlayIntensity = (overlayIntensity + 0.3 * pulse).clamp(0.0, 1.0);
            overlayOpacity = (overlayOpacity + 0.3 * pulse).clamp(0.0, 1.0);
          }

          // If preserveTransparency is enabled, we need to avoid applying color overlays
          if (preserveTransparency) {
            if (overlayIntensity > 0 || overlayOpacity > 0) {
              _log(
                "preserveTransparency enabled - zeroing overlay intensity and opacity",
              );
            }
            // IMPORTANT FIX: Setting these to 0 prevents the solid background effect
            overlayIntensity = 0.0;
            overlayOpacity = 0.0;
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
          _log("ERROR: $e");
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

  // Note: Animation helper functions have been moved to ShaderAnimationUtils
}

/// Custom blur effect shader widget
class BlurEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;

  const BlurEffectShader({
    super.key,
    required this.child,
    required this.settings,
    required this.animationValue,
    this.preserveTransparency = false,
    this.isTextContent = false,
  });

  @override
  Widget build(BuildContext context) {
    if (enableShaderDebugLogs) {
      print(
        "SHATTER_SHADER: Building widget with amount=${settings.blurSettings.blurAmount.toStringAsFixed(2)} (animated: ${settings.blurSettings.blurAnimated})",
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
          double amount = settings.blurSettings.blurAmount;
          if (settings.blurSettings.blurAnimated) {
            // Compute animated progress based on per-blur animation options.

            // Reuse helper to obtain a 0-1 value taking speed/mode/easing into account.
            final double animValue = ShaderAnimationUtils.computeAnimatedValue(
              settings.blurSettings.blurAnimOptions,
              animationValue,
            );

            // Map to a smooth pulse (same visual as before) for pulse mode or
            // directly use the randomised value for the alternative mode.
            final double intensity =
                settings.blurSettings.blurAnimOptions.mode ==
                    AnimationMode.pulse
                ? (0.5 + 0.5 * math.sin(animValue * 2 * math.pi))
                : animValue;

            amount = amount * intensity;
          }

          // If preserveTransparency is enabled or this is text content, adjust blur settings
          double opacity = settings.blurSettings.blurOpacity;
          double intensity = settings.blurSettings.blurIntensity;
          double contrast = settings.blurSettings.blurContrast;

          // Performance tweak: reduce blur radius for text-only layers to
          // minimise the number of kernel samples.  A 40-50 % cut keeps most
          // of the shatter look but greatly improves frame rate.
          double effectiveRadius = settings.blurSettings.blurRadius;

          if (isTextContent) {
            effectiveRadius = effectiveRadius * 0.6; // 40% reduction
            if (enableShaderDebugLogs) {
              print(
                "SHATTER_SHADER: Reducing radius for text content from ${settings.blurSettings.blurRadius} to $effectiveRadius",
              );
            }
          }

          // Preserve transparency: avoid introducing a solid backdrop, but let
          // the blur (shatter) characteristics shine through on the glyphs.
          // With the transparent-fallback fix in the GLSL shader, we no longer
          // need to severely dampen the effect for text.  Keep the original
          // parameters and only make a mild reduction when *only*
          // preserveTransparency is requested (i.e. non-text overlays).

          if (!isTextContent && preserveTransparency) {
            opacity = opacity * 0.6; // Slight reduction for safety
          }

          // Set uniforms after the texture sampler
          shader.setFloat(0, amount);
          shader.setFloat(1, effectiveRadius);
          shader.setFloat(2, image.width.toDouble());
          shader.setFloat(3, image.height.toDouble());
          shader.setFloat(4, opacity);
          shader.setFloat(5, settings.blurSettings.blurBlendMode.toDouble());
          shader.setFloat(6, intensity); // Use adjusted intensity
          shader.setFloat(7, contrast); // Use adjusted contrast

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

  // Note: Animation helper functions have been moved to ShaderAnimationUtils
}

/// Custom noise effect shader widget
class NoiseEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;

  const NoiseEffectShader({
    super.key,
    required this.child,
    required this.settings,
    required this.animationValue,
    this.preserveTransparency = false,
    this.isTextContent = false,
  });

  @override
  Widget build(BuildContext context) {
    if (enableShaderDebugLogs) {
      print(
        "NOISE_SHADER: Building widget with scale=${settings.noiseSettings.noiseScale.toStringAsFixed(2)}, wave=${settings.noiseSettings.waveAmount.toStringAsFixed(3)} (animated: ${settings.noiseSettings.noiseAnimated})",
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
          double timeValue = settings.noiseSettings.noiseAnimated
              ? animationValue
              : 0.0;

          // The noise speed to use, which can be 0 even when animated
          double noiseSpeed = settings.noiseSettings.noiseSpeed;

          // Compute animation values if animation is enabled
          if (settings.noiseSettings.noiseAnimated) {
            // Compute animated progress based on noise animation options
            final double animValue = ShaderAnimationUtils.computeAnimatedValue(
              settings.noiseSettings.noiseAnimOptions,
              animationValue,
            );

            // Use the animation value to control time
            timeValue = animValue;

            // Scale the noise speed based on animation options
            if (settings.noiseSettings.noiseAnimOptions.mode ==
                AnimationMode.pulse) {
              // Add a breathing effect to the speed in pulse mode
              final double pulse = math.sin(animValue * 2 * math.pi);
              noiseSpeed =
                  settings.noiseSettings.noiseSpeed * (0.5 + 0.5 * pulse);
            }
          }

          // If preserveTransparency is enabled or this is text content, adjust noise settings
          double colorIntensity = settings.noiseSettings.colorIntensity;
          double waveAmount = settings.noiseSettings.waveAmount;

          // CRITICAL FIX: Special handling for text content
          if (isTextContent) {
            // For text content, dramatically reduce settings that cause background problems
            colorIntensity =
                colorIntensity * 0.1; // Much more reduction for text
            waveAmount =
                waveAmount *
                0.1; // Dramatically reduce wave distortion for text

            if (enableShaderDebugLogs) {
              print(
                "NOISE_SHADER: Reducing effects for text content - original colorIntensity=$colorIntensity, waveAmount=$waveAmount",
              );
            }
          }
          // Less aggressive adjustments for general transparency preservation
          else if (preserveTransparency) {
            colorIntensity = colorIntensity * 0.3; // Reduce color intensity
            waveAmount = waveAmount * 0.5; // Reduce wave distortion
          }

          // Set uniforms after the texture sampler
          shader.setFloat(0, timeValue); // Time
          shader.setFloat(
            1,
            size.width / size.height,
          ); // Resolution aspect ratio
          shader.setFloat(2, settings.noiseSettings.noiseScale); // Noise scale
          shader.setFloat(3, noiseSpeed); // Noise speed
          shader.setFloat(4, colorIntensity); // Color intensity
          shader.setFloat(5, waveAmount); // Wave distortion amount
          shader.setFloat(
            6,
            settings.noiseSettings.noiseAnimated ? 1.0 : 0.0,
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

  // Note: Animation helper functions have been moved to ShaderAnimationUtils
}

// Helper method to apply blur effect using custom shader
Widget _applyBlurEffect({
  required Widget child,
  required ShaderSettings settings,
  required double animationValue,
  bool preserveTransparency = false,
  bool isTextContent = false,
}) {
  // Skip if blur amount is zero
  if (settings.blurSettings.blurAmount <= 0.0 &&
      !settings.blurSettings.blurAnimated) {
    return child;
  }

  // Use custom shader implementation
  return BlurEffectShader(
    settings: settings,
    animationValue: animationValue,
    child: child,
    preserveTransparency: preserveTransparency,
    isTextContent: isTextContent,
  );
}
