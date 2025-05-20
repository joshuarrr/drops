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
bool enableShaderDebugLogs = true;

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
  static const Duration _logThrottleInterval = Duration(milliseconds: 1000);
  static String _lastLogMessage =
      ""; // Track the last message to avoid duplicates

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

  @override
  Widget build(BuildContext context) {
    if (enableShaderDebugLogs) {
      final String logMessage =
          "Building BlurEffectShader with amount=${settings.blurSettings.blurAmount.toStringAsFixed(2)} "
          "opacity=${settings.blurSettings.blurOpacity.toStringAsFixed(2)} "
          "(animated: ${settings.blurSettings.blurAnimated})";
      _log(logMessage);
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

          if (enableShaderDebugLogs) {
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
            if (enableShaderDebugLogs) {
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
