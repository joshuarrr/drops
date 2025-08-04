// Removed unused math import
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../models/animation_options.dart';
import '../../utils/animation_utils.dart';
import '../animation_state_manager.dart';
import 'debug_flags.dart';

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

    // We'll compute the animation values individually for each parameter
    // when needed rather than using global HSL and overlay animation values

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
                  // Get animation state manager
                  final animManager = AnimationStateManager();

                  // Animate hue if unlocked
                  if (!animManager.isParameterLocked(ParameterIds.colorHue)) {
                    // Animation logging disabled

                    if (settings.colorSettings.colorAnimOptions.mode ==
                        AnimationMode.pulse) {
                      // Use pulse animation - oscillate between slider value and zero
                      final double animValue =
                          ShaderAnimationUtils.computePulseValue(
                            settings.colorSettings.colorAnimOptions,
                            animationValue,
                          );
                      hue = settings.colorSettings.hue * animValue;
                    } else {
                      // Use randomized animation - animate across the full hue range (0-1)
                      hue =
                          ShaderAnimationUtils.computeRandomizedParameterValue(
                            settings.colorSettings.hue,
                            settings.colorSettings.colorAnimOptions,
                            animationValue,
                            isLocked: animManager.isParameterLocked(
                              ParameterIds.colorHue,
                            ),
                            minValue: 0.0,
                            maxValue: 1.0,
                            parameterId: ParameterIds.colorHue,
                          );
                    }
                    // Update animation manager with current animated value
                    animManager.updateAnimatedValue(ParameterIds.colorHue, hue);
                  } else {
                    // If locked, just update the animation manager for UI consistency
                    animManager.updateAnimatedValue(ParameterIds.colorHue, hue);
                  }

                  // Animate saturation if unlocked
                  if (!animManager.isParameterLocked(
                    ParameterIds.colorSaturation,
                  )) {
                    if (settings.colorSettings.colorAnimOptions.mode ==
                        AnimationMode.pulse) {
                      final double animValue =
                          ShaderAnimationUtils.computePulseValue(
                            settings.colorSettings.colorAnimOptions,
                            animationValue,
                          );
                      saturation =
                          settings.colorSettings.saturation * animValue;
                    } else {
                      saturation =
                          ShaderAnimationUtils.computeRandomizedParameterValue(
                            settings.colorSettings.saturation,
                            settings.colorSettings.colorAnimOptions,
                            animationValue,
                            isLocked: animManager.isParameterLocked(
                              ParameterIds.colorSaturation,
                            ),
                            minValue: 0.0,
                            maxValue: 1.0,
                            parameterId: ParameterIds.colorSaturation,
                          );
                    }
                    animManager.updateAnimatedValue(
                      ParameterIds.colorSaturation,
                      saturation,
                    );
                  } else {
                    animManager.updateAnimatedValue(
                      ParameterIds.colorSaturation,
                      saturation,
                    );
                  }

                  // Animate lightness if unlocked
                  if (!animManager.isParameterLocked(
                    ParameterIds.colorLightness,
                  )) {
                    if (settings.colorSettings.colorAnimOptions.mode ==
                        AnimationMode.pulse) {
                      final double animValue =
                          ShaderAnimationUtils.computePulseValue(
                            settings.colorSettings.colorAnimOptions,
                            animationValue,
                          );
                      lightness = settings.colorSettings.lightness * animValue;
                    } else {
                      lightness =
                          ShaderAnimationUtils.computeRandomizedParameterValue(
                            settings.colorSettings.lightness,
                            settings.colorSettings.colorAnimOptions,
                            animationValue,
                            isLocked: animManager.isParameterLocked(
                              ParameterIds.colorLightness,
                            ),
                            minValue: 0.0,
                            maxValue: 1.0,
                            parameterId: ParameterIds.colorLightness,
                          );
                    }
                    animManager.updateAnimatedValue(
                      ParameterIds.colorLightness,
                      lightness,
                    );
                  } else {
                    animManager.updateAnimatedValue(
                      ParameterIds.colorLightness,
                      lightness,
                    );
                  }

                  // Animation logging disabled
                } else {
                  // Clear animated values when animation is disabled
                  final animManager = AnimationStateManager();
                  animManager.clearAnimatedValue(ParameterIds.colorHue);
                  animManager.clearAnimatedValue(ParameterIds.colorSaturation);
                  animManager.clearAnimatedValue(ParameterIds.colorLightness);
                }

                // Determine overlay values (may animate independently)
                double overlayHue = settings.colorSettings.overlayHue;
                double overlayIntensity =
                    settings.colorSettings.overlayIntensity;
                double overlayOpacity = settings.colorSettings.overlayOpacity;

                if (settings.colorSettings.overlayAnimated) {
                  // Get animation state manager
                  final animManager = AnimationStateManager();

                  // Animate overlay hue if unlocked
                  if (!animManager.isParameterLocked(ParameterIds.overlayHue)) {
                    // Animation logging disabled

                    if (settings.colorSettings.overlayAnimOptions.mode ==
                        AnimationMode.pulse) {
                      // Use pulse animation - oscillate between slider value and zero
                      final double animValue =
                          ShaderAnimationUtils.computePulseValue(
                            settings.colorSettings.overlayAnimOptions,
                            animationValue,
                          );
                      overlayHue =
                          settings.colorSettings.overlayHue * animValue;
                    } else {
                      // Use randomized animation - animate across the full hue range (0-1)
                      overlayHue =
                          ShaderAnimationUtils.computeRandomizedParameterValue(
                            settings.colorSettings.overlayHue,
                            settings.colorSettings.overlayAnimOptions,
                            animationValue,
                            isLocked: animManager.isParameterLocked(
                              ParameterIds.overlayHue,
                            ),
                            minValue: 0.0,
                            maxValue: 1.0,
                            parameterId: ParameterIds.overlayHue,
                          );
                    }
                    // Update animation manager with current animated value
                    animManager.updateAnimatedValue(
                      ParameterIds.overlayHue,
                      overlayHue,
                    );
                  } else {
                    // If locked, just update the animation manager for UI consistency
                    animManager.updateAnimatedValue(
                      ParameterIds.overlayHue,
                      overlayHue,
                    );
                  }

                  // Animate overlay intensity if unlocked
                  if (!animManager.isParameterLocked(
                    ParameterIds.overlayIntensity,
                  )) {
                    if (settings.colorSettings.overlayAnimOptions.mode ==
                        AnimationMode.pulse) {
                      final double animValue =
                          ShaderAnimationUtils.computePulseValue(
                            settings.colorSettings.overlayAnimOptions,
                            animationValue,
                          );
                      overlayIntensity =
                          settings.colorSettings.overlayIntensity * animValue;
                    } else {
                      overlayIntensity =
                          ShaderAnimationUtils.computeRandomizedParameterValue(
                            settings.colorSettings.overlayIntensity,
                            settings.colorSettings.overlayAnimOptions,
                            animationValue,
                            isLocked: animManager.isParameterLocked(
                              ParameterIds.overlayIntensity,
                            ),
                            minValue: 0.0,
                            maxValue: 1.0,
                            parameterId: ParameterIds.overlayIntensity,
                          );
                    }
                    animManager.updateAnimatedValue(
                      ParameterIds.overlayIntensity,
                      overlayIntensity,
                    );
                  } else {
                    animManager.updateAnimatedValue(
                      ParameterIds.overlayIntensity,
                      overlayIntensity,
                    );
                  }

                  // Animate overlay opacity if unlocked
                  if (!animManager.isParameterLocked(
                    ParameterIds.overlayOpacity,
                  )) {
                    if (settings.colorSettings.overlayAnimOptions.mode ==
                        AnimationMode.pulse) {
                      final double animValue =
                          ShaderAnimationUtils.computePulseValue(
                            settings.colorSettings.overlayAnimOptions,
                            animationValue,
                          );
                      overlayOpacity =
                          settings.colorSettings.overlayOpacity * animValue;
                    } else {
                      overlayOpacity =
                          ShaderAnimationUtils.computeRandomizedParameterValue(
                            settings.colorSettings.overlayOpacity,
                            settings.colorSettings.overlayAnimOptions,
                            animationValue,
                            isLocked: animManager.isParameterLocked(
                              ParameterIds.overlayOpacity,
                            ),
                            minValue: 0.0,
                            maxValue: 1.0,
                            parameterId: ParameterIds.overlayOpacity,
                          );
                    }
                    animManager.updateAnimatedValue(
                      ParameterIds.overlayOpacity,
                      overlayOpacity,
                    );
                  } else {
                    animManager.updateAnimatedValue(
                      ParameterIds.overlayOpacity,
                      overlayOpacity,
                    );
                  }

                  // Animation logging disabled
                } else {
                  // Clear animated values when animation is disabled
                  final animManager = AnimationStateManager();
                  animManager.clearAnimatedValue(ParameterIds.overlayHue);
                  animManager.clearAnimatedValue(ParameterIds.overlayIntensity);
                  animManager.clearAnimatedValue(ParameterIds.overlayOpacity);
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

                // Shader uniform logging completely disabled

                // Animation has been properly applied above
                // No need for any special handling here

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
