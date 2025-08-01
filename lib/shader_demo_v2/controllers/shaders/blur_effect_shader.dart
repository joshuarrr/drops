import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../models/animation_options.dart';
import '../../utils/animation_utils.dart';
import '../animation_state_manager.dart';

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

      if (enableShaderDebugLogs) {
        _log(
          "Settings changed - amount:$amount radius:$radius opacity:$opacity blend:$blendMode intensity:$intensity contrast:$contrast",
        );
      }
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
    return LayoutBuilder(
      builder: (context, constraints) {
        return ShaderBuilder(assetKey: 'assets/shaders/blur_effect.frag', (
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

                // Compute animated amount using proper animation utilities
                double amount = settings.blurSettings.blurAmount;
                if (settings.blurSettings.blurAnimated) {
                  // Get animation state manager
                  final animManager = AnimationStateManager();

                  // Check if parameter is locked
                  final bool isAmountLocked = animManager.isParameterLocked(
                    ParameterIds.blurAmount,
                  );

                  print(
                    "[DEBUG] BlurEffectShader with animationValue=${animationValue.toStringAsFixed(3)}, locked=$isAmountLocked",
                  );

                  if (isAmountLocked) {
                    // If locked, keep the slider value (no animation)
                    // Just update the animation manager for UI consistency
                    animManager.updateAnimatedValue(
                      ParameterIds.blurAmount,
                      amount,
                    );

                    print(
                      "[DEBUG] Parameter locked: using fixed value $amount",
                    );
                  } else {
                    // If unlocked, animate according to the selected mode
                    if (settings.blurSettings.blurAnimOptions.mode ==
                        AnimationMode.pulse) {
                      // Use pulse animation - oscillate between slider value and zero
                      final double animValue =
                          ShaderAnimationUtils.computePulseValue(
                            settings.blurSettings.blurAnimOptions,
                            animationValue,
                          );

                      // Animate from slider value to zero and back
                      amount = settings.blurSettings.blurAmount * animValue;

                      print(
                        "[DEBUG] Pulse animation: value=$animValue, amount=$amount",
                      );
                    } else {
                      // Use randomized animation - animate across parameter range
                      amount =
                          ShaderAnimationUtils.computeRandomizedParameterValue(
                            settings.blurSettings.blurAmount,
                            settings.blurSettings.blurAnimOptions,
                            animationValue,
                            isLocked: isAmountLocked,
                            minValue: 0.0,
                            maxValue: 1.0,
                          );

                      print("[DEBUG] Randomized animation: amount=$amount");
                    }

                    // Update animation manager with current animated value
                    animManager.updateAnimatedValue(
                      ParameterIds.blurAmount,
                      amount,
                    );
                  }
                } else {
                  // Clear animated value when animation is disabled
                  final animManager = AnimationStateManager();
                  animManager.clearAnimatedValue(ParameterIds.blurAmount);
                }

                // Handle other blur parameters (opacity, intensity, contrast, radius)
                double opacity = settings.blurSettings.blurOpacity;
                double intensity = settings.blurSettings.blurIntensity;
                double contrast = settings.blurSettings.blurContrast;
                double effectiveRadius = settings.blurSettings.blurRadius;

                // Animate other parameters if animation is enabled
                if (settings.blurSettings.blurAnimated) {
                  final animManager = AnimationStateManager();

                  // Handle opacity animation
                  if (!animManager.isParameterLocked(
                    ParameterIds.blurOpacity,
                  )) {
                    if (settings.blurSettings.blurAnimOptions.mode ==
                        AnimationMode.pulse) {
                      final double animValue =
                          ShaderAnimationUtils.computePulseValue(
                            settings.blurSettings.blurAnimOptions,
                            animationValue,
                          );
                      opacity = settings.blurSettings.blurOpacity * animValue;
                    } else {
                      opacity =
                          ShaderAnimationUtils.computeRandomizedParameterValue(
                            settings.blurSettings.blurOpacity,
                            settings.blurSettings.blurAnimOptions,
                            animationValue,
                            isLocked: animManager.isParameterLocked(
                              ParameterIds.blurOpacity,
                            ),
                            minValue: 0.0,
                            maxValue: 1.0,
                          );
                    }
                    animManager.updateAnimatedValue(
                      ParameterIds.blurOpacity,
                      opacity,
                    );
                  }

                  // Handle intensity animation
                  if (!animManager.isParameterLocked(
                    ParameterIds.blurIntensity,
                  )) {
                    if (settings.blurSettings.blurAnimOptions.mode ==
                        AnimationMode.pulse) {
                      final double animValue =
                          ShaderAnimationUtils.computePulseValue(
                            settings.blurSettings.blurAnimOptions,
                            animationValue,
                          );
                      intensity =
                          settings.blurSettings.blurIntensity * animValue;
                    } else {
                      intensity =
                          ShaderAnimationUtils.computeRandomizedParameterValue(
                            settings.blurSettings.blurIntensity,
                            settings.blurSettings.blurAnimOptions,
                            animationValue,
                            isLocked: animManager.isParameterLocked(
                              ParameterIds.blurIntensity,
                            ),
                            minValue: 0.0,
                            maxValue: 3.0,
                          );
                    }
                    animManager.updateAnimatedValue(
                      ParameterIds.blurIntensity,
                      intensity,
                    );
                  }

                  // Handle contrast animation
                  if (!animManager.isParameterLocked(
                    ParameterIds.blurContrast,
                  )) {
                    if (settings.blurSettings.blurAnimOptions.mode ==
                        AnimationMode.pulse) {
                      final double animValue =
                          ShaderAnimationUtils.computePulseValue(
                            settings.blurSettings.blurAnimOptions,
                            animationValue,
                          );
                      contrast = settings.blurSettings.blurContrast * animValue;
                    } else {
                      contrast =
                          ShaderAnimationUtils.computeRandomizedParameterValue(
                            settings.blurSettings.blurContrast,
                            settings.blurSettings.blurAnimOptions,
                            animationValue,
                            isLocked: animManager.isParameterLocked(
                              ParameterIds.blurContrast,
                            ),
                            minValue: 0.0,
                            maxValue: 2.0,
                          );
                    }
                    animManager.updateAnimatedValue(
                      ParameterIds.blurContrast,
                      contrast,
                    );
                  }

                  // Handle radius animation
                  if (!animManager.isParameterLocked(ParameterIds.blurRadius)) {
                    if (settings.blurSettings.blurAnimOptions.mode ==
                        AnimationMode.pulse) {
                      final double animValue =
                          ShaderAnimationUtils.computePulseValue(
                            settings.blurSettings.blurAnimOptions,
                            animationValue,
                          );
                      effectiveRadius =
                          settings.blurSettings.blurRadius * animValue;
                    } else {
                      effectiveRadius =
                          ShaderAnimationUtils.computeRandomizedParameterValue(
                            settings.blurSettings.blurRadius,
                            settings.blurSettings.blurAnimOptions,
                            animationValue,
                            isLocked: animManager.isParameterLocked(
                              ParameterIds.blurRadius,
                            ),
                            minValue: 0.0,
                            maxValue: 120.0,
                          );
                    }
                    animManager.updateAnimatedValue(
                      ParameterIds.blurRadius,
                      effectiveRadius,
                    );
                  }
                } else {
                  // Clear animated values when animation is disabled
                  final animManager = AnimationStateManager();
                  animManager.clearAnimatedValue(ParameterIds.blurOpacity);
                  animManager.clearAnimatedValue(ParameterIds.blurIntensity);
                  animManager.clearAnimatedValue(ParameterIds.blurContrast);
                  animManager.clearAnimatedValue(ParameterIds.blurRadius);
                }

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
                shader.setFloat(
                  5,
                  settings.blurSettings.blurBlendMode.toDouble(),
                );
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
            }, child: this.child),
          );
        }, child: child);
      },
    );
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
