import 'dart:math' as math;
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../models/animation_options.dart';
import '../../utils/animation_utils.dart';
import 'debug_flags.dart'; // Import the shared debug flag

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

    // Use LayoutBuilder to ensure consistent sizing
    return LayoutBuilder(
      builder: (context, constraints) {
        // Simplified approach using AnimatedSampler with ShaderBuilder
        return ShaderBuilder(assetKey: 'assets/shaders/color_effect.frag', (
          context,
          shader,
          child,
        ) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: AnimatedSampler((image, size, canvas) {
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
                double overlayIntensity =
                    settings.colorSettings.overlayIntensity;
                double overlayOpacity = settings.colorSettings.overlayOpacity;

                if (settings.colorSettings.overlayAnimated) {
                  overlayHue = (overlayHue + overlayAnimValue) % 1.0;
                  // Subtle breathing effect on intensity & opacity
                  final double pulse = math.sin(overlayAnimValue * 2 * math.pi);
                  overlayIntensity = (overlayIntensity + 0.3 * pulse).clamp(
                    0.0,
                    1.0,
                  );
                  overlayOpacity = (overlayOpacity + 0.3 * pulse).clamp(
                    0.0,
                    1.0,
                  );
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
            }, child: this.child),
          );
        }, child: child);
      },
    );
  }
}
