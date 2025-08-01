import 'dart:math' as math;
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../models/animation_options.dart';
import '../../utils/animation_utils.dart';

/// Controls debug logging for shaders
bool enableShaderDebugLogs = true;

/// Custom color effect shader widget
class ColorEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent; // Add parameter to identify text content
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
    this.isTextContent = false, // Default to false for backward compatibility
  });

  @override
  Widget build(BuildContext context) {
    // Only log when there are non-zero values or values have changed
    if (_shouldLogColorSettings()) {
      _log(
        "Building ColorEffectShader (${isTextContent ? 'text' : 'background'}) with " +
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
            // CRITICAL: ALWAYS force shader to rebuild on EVERY frame
            key: ValueKey(DateTime.now().millisecondsSinceEpoch),
            child: AnimatedSampler((image, size, canvas) {
              try {
                // Set the texture sampler first
                shader.setImageSampler(0, image);

                // Compute animated values when requested
                double hue = settings.colorSettings.hue;
                double saturation = settings.colorSettings.saturation;
                double lightness = settings.colorSettings.lightness;

                if (settings.colorSettings.colorAnimated) {
                  // V3-style direct animation approach
                  // This creates a clear visual oscillation that's easy to see
                  final double animFactor = (math.sin(
                    animationValue * math.pi,
                  )).abs();

                  // SUPER EXTREME ANIMATION: Force maximally visible changes
                  // Directly use animation value for hue to cycle through all colors
                  hue = animationValue; // Cycle through all colors (0-1)

                  // Maximum saturation and medium lightness for most vibrant colors
                  saturation = 1.0; // Maximum saturation
                  lightness = 0.5; // Medium lightness for optimal vibrancy

                  // Log the values for debugging
                  print(
                    "[V3-STYLE] Color animation: value=$animationValue, hue=$hue, saturation=$saturation, lightness=$lightness",
                  );
                }

                // Determine overlay values (may animate independently)
                double overlayHue = settings.colorSettings.overlayHue;
                double overlayIntensity =
                    settings.colorSettings.overlayIntensity;
                double overlayOpacity = settings.colorSettings.overlayOpacity;

                if (settings.colorSettings.overlayAnimated) {
                  // V3-style direct animation approach
                  // This creates a clear visual oscillation that's easy to see
                  final double animFactor = (math.sin(
                    animationValue * math.pi,
                  )).abs();

                  // SUPER EXTREME ANIMATION: Force maximally visible overlay changes
                  // Use animation value with offset for overlay hue
                  overlayHue =
                      (animationValue + 0.5) % 1.0; // Complementary color

                  // Maximum intensity and pulsing opacity for most visible effect
                  overlayIntensity = 1.0; // Maximum intensity
                  overlayOpacity = animFactor; // Pulsing opacity

                  // Log the values for debugging
                  print(
                    "[V3-STYLE] Overlay animation: value=$animationValue, hue=$overlayHue, intensity=$overlayIntensity, opacity=$overlayOpacity",
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
                // PERFORMANCE FIX: Only use animationValue for time when color animation is enabled
                final double timeValue =
                    (settings.colorSettings.colorAnimated ||
                        settings.colorSettings.overlayAnimated)
                    ? animationValue
                    : 0.0;

                // DEBUG: Log the actual shader uniform values being set
                _log(
                  "[DEBUG] Setting shader uniforms: " +
                      "timeValue=$timeValue, " +
                      "hue=$hue, " +
                      "saturation=$saturation, " +
                      "lightness=$lightness, " +
                      "overlayHue=$overlayHue, " +
                      "overlayIntensity=$overlayIntensity, " +
                      "overlayOpacity=$overlayOpacity",
                );

                // V3-style animation is always enabled
                // This ensures the animation is always visible and consistent

                // We've already set the values above, so no need to override again
                // Just log that we're using the V3 approach
                if (settings.colorSettings.colorAnimated ||
                    settings.colorSettings.overlayAnimated) {
                  print(
                    "[V3-STYLE] Using direct animation values from V3 approach",
                  );
                }

                shader.setFloat(0, timeValue);
                shader.setFloat(1, hue);
                shader.setFloat(2, saturation);
                shader.setFloat(3, lightness);
                shader.setFloat(4, overlayHue);
                shader.setFloat(5, overlayIntensity);
                shader.setFloat(6, overlayOpacity);
                shader.setFloat(7, image.width.toDouble());
                shader.setFloat(8, image.height.toDouble());
                shader.setFloat(
                  9,
                  isTextContent ? 1.0 : 0.0,
                ); // Pass the isTextContent flag to the shader

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
