import 'dart:math' as math;
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../models/animation_options.dart';
import '../../utils/animation_utils.dart';
import 'debug_flags.dart'; // Import the shared debug flag

/// Controls debug logging for shaders (external reference)
bool enableShaderDebugLogs = false;

/// Custom blur effect shader widget
class BlurEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;
  final String _logTag = 'BlurEffectShader';

  // Log throttling - using static variables for efficient throttling
  static DateTime _lastLogTime = DateTime.now().subtract(
    const Duration(seconds: 1),
  );
  static const Duration _logThrottleInterval = Duration(milliseconds: 2000);
  static String _lastLogMessage =
      ""; // Track the last message to avoid duplicates

  // Cache previous settings values to avoid unnecessary shader updates
  static double _lastAmount = -1;
  static double _lastRadius = -1;
  static double _lastOpacity = -1;
  static int _lastBlendMode = -1;
  static double _lastIntensity = -1;
  static double _lastContrast = -1;
  static bool _settingsChanged = true;

  const BlurEffectShader({
    super.key,
    required this.child,
    required this.settings,
    required this.animationValue,
    this.preserveTransparency = false,
    this.isTextContent = false,
  });

  // Custom log function that uses both dart:developer and debugPrint for visibility
  void _log(String message) {
    if (!enableShaderDebugLogs) return;

    // Skip if this is the same message that was just logged
    if (message == _lastLogMessage) return;

    // Throttle logs to avoid excessive output
    final now = DateTime.now();
    if (now.difference(_lastLogTime) < _logThrottleInterval) {
      return;
    }

    _lastLogTime = now;
    _lastLogMessage = message;

    developer.log(message, name: _logTag);
    debugPrint('[$_logTag] $message');
  }

  // Check if shader settings have meaningfully changed
  bool _haveSettingsChanged() {
    // Use rounded values to avoid minor fluctuations causing rebuilds
    final amount = (settings.blurSettings.blurAmount * 100).round() / 100;
    final radius = (settings.blurSettings.blurRadius * 10).round() / 10;
    final opacity = (settings.blurSettings.blurOpacity * 100).round() / 100;
    final blendMode = settings.blurSettings.blurBlendMode;
    final intensity = (settings.blurSettings.blurIntensity * 100).round() / 100;
    final contrast = (settings.blurSettings.blurContrast * 100).round() / 100;

    // Check if any values have changed significantly
    final bool changed =
        amount != _lastAmount ||
        radius != _lastRadius ||
        opacity != _lastOpacity ||
        blendMode != _lastBlendMode ||
        intensity != _lastIntensity ||
        contrast != _lastContrast;

    // Update cached values
    if (changed) {
      _lastAmount = amount;
      _lastRadius = radius;
      _lastOpacity = opacity;
      _lastBlendMode = blendMode;
      _lastIntensity = intensity;
      _lastContrast = contrast;
      _settingsChanged = true;

      if (enableShaderDebugLogs) {
        _log(
          "Settings changed - amount:$amount radius:$radius opacity:$opacity blend:$blendMode intensity:$intensity contrast:$contrast",
        );
      }
    } else {
      _settingsChanged = false;
    }

    return changed;
  }

  @override
  Widget build(BuildContext context) {
    // Check if settings have changed to avoid unnecessary logging
    final bool settingsChanged = _haveSettingsChanged();

    if (enableShaderDebugLogs && settingsChanged) {
      _log(
        "Building BlurEffectShader with amount=${settings.blurSettings.blurAmount.toStringAsFixed(2)} "
        "opacity=${settings.blurSettings.blurOpacity.toStringAsFixed(2)} "
        "(animated: ${settings.blurSettings.blurAnimated})",
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
            if (settings.blurSettings.blurAnimOptions.mode ==
                AnimationMode.pulse) {
              // Simplified pulse animation - use raw animationValue to avoid memory issues
              final double pulseTime =
                  animationValue *
                  settings.blurSettings.blurAnimOptions.speed *
                  4.0;
              final double pulse = (math.sin(pulseTime * math.pi) * 0.5 + 0.5)
                  .abs();

              // Apply pulse to blur amount
              amount = settings.blurSettings.blurAmount * pulse;
            } else {
              // For non-pulse modes, use the standard animation utilities
              final double animValue =
                  ShaderAnimationUtils.computeAnimatedValue(
                    settings.blurSettings.blurAnimOptions,
                    animationValue,
                  );
              amount = settings.blurSettings.blurAmount * animValue;
            }
          }

          // If preserveTransparency is enabled or this is text content, adjust blur settings
          double opacity = settings.blurSettings.blurOpacity;
          double intensity = settings.blurSettings.blurIntensity;
          double contrast = settings.blurSettings.blurContrast;

          if (enableShaderDebugLogs && settingsChanged) {
            _log(
              "Setting shader parameters - Amount: ${amount.toStringAsFixed(2)}, " +
                  "Opacity: ${opacity.toStringAsFixed(2)}, " +
                  "Intensity: ${intensity.toStringAsFixed(2)}, " +
                  "Contrast: ${contrast.toStringAsFixed(2)}, " +
                  "BlendMode: ${settings.blurSettings.blurBlendMode}",
            );
          }

          // Performance tweak: reduce blur radius for text-only layers to
          // minimise the number of kernel samples.  A 40-50 % cut keeps most
          // of the shatter look but greatly improves frame rate.
          double effectiveRadius = settings.blurSettings.blurRadius;

          if (isTextContent) {
            effectiveRadius = effectiveRadius * 0.6; // 40% reduction
            if (enableShaderDebugLogs && settingsChanged) {
              _log(
                "Reducing radius for text content from ${settings.blurSettings.blurRadius} to $effectiveRadius",
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
}

/// Helper method to apply blur effect using custom shader
Widget applyBlurEffect({
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
