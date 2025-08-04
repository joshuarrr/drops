// Removed unused math import
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../models/animation_options.dart';
import '../../utils/animation_utils.dart';
import '../animation_state_manager.dart';
// Removed unused debug_flags.dart import

/// Controls debug logging for shaders (external reference)
bool enableShaderDebugLogs = false;

/// Custom chromatic aberration effect shader widget
class ChromaticEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;
  final String _logTag = 'ChromaticEffectShader';

  // Log throttling - using static variables for efficient throttling
  static DateTime _lastLogTime = DateTime.now().subtract(
    const Duration(seconds: 1),
  );
  static const Duration _logThrottleInterval = Duration(milliseconds: 1000);
  static String _lastLogMessage =
      ""; // Track the last message to avoid duplicates

  const ChromaticEffectShader({
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
          "Building ChromaticEffectShader with intensity=${settings.chromaticSettings.intensity.toStringAsFixed(2)} "
          "(animated: ${settings.chromaticSettings.chromaticAnimated})";
      _log(logMessage);
    }

    // Use ShaderBuilder with AnimatedSampler for the effect
    return ShaderBuilder(assetKey: 'assets/shaders/chromatic_effect.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          // Set the texture sampler first
          shader.setImageSampler(0, image);

          // Compute animated intensity if enabled
          double intensity = settings.chromaticSettings.intensity;
          double amount = settings.chromaticSettings.amount;
          double angle = settings.chromaticSettings.angle;
          double spread = settings.chromaticSettings.spread;

          if (settings.chromaticSettings.chromaticAnimated) {
            final animManager = AnimationStateManager();

            // Apply animation based on the current animation mode
            if (settings.chromaticSettings.animOptions.mode ==
                AnimationMode.pulse) {
              // Apply pulse mode with parameter locking

              // Animate intensity if unlocked
              if (!animManager.isParameterLocked(
                ParameterIds.chromaticIntensity,
              )) {
                final double pulse = ShaderAnimationUtils.computePulseValue(
                  settings.chromaticSettings.animOptions,
                  animationValue,
                );
                intensity = settings.chromaticSettings.intensity * pulse;
                animManager.updateAnimatedValue(
                  ParameterIds.chromaticIntensity,
                  intensity,
                );
              } else {
                // If locked, keep the slider value
                animManager.updateAnimatedValue(
                  ParameterIds.chromaticIntensity,
                  intensity,
                );
              }

              // Animate amount if unlocked
              if (!animManager.isParameterLocked(
                ParameterIds.chromaticAmount,
              )) {
                final double pulse = ShaderAnimationUtils.computePulseValue(
                  settings.chromaticSettings.animOptions,
                  animationValue,
                );
                amount = settings.chromaticSettings.amount * pulse;
                animManager.updateAnimatedValue(
                  ParameterIds.chromaticAmount,
                  amount,
                );
              } else {
                // If locked, keep the slider value
                animManager.updateAnimatedValue(
                  ParameterIds.chromaticAmount,
                  amount,
                );
              }

              // Animate spread if unlocked
              if (!animManager.isParameterLocked(
                ParameterIds.chromaticSpread,
              )) {
                final double pulse = ShaderAnimationUtils.computePulseValue(
                  settings.chromaticSettings.animOptions,
                  animationValue,
                );
                spread = settings.chromaticSettings.spread * pulse;
                animManager.updateAnimatedValue(
                  ParameterIds.chromaticSpread,
                  spread,
                );
              } else {
                // If locked, keep the slider value
                animManager.updateAnimatedValue(
                  ParameterIds.chromaticSpread,
                  spread,
                );
              }

              // Animate angle if unlocked (rotation animation)
              if (!animManager.isParameterLocked(ParameterIds.chromaticAngle)) {
                final double pulse = ShaderAnimationUtils.computePulseValue(
                  settings.chromaticSettings.animOptions,
                  animationValue,
                );
                // For angle, we do rotation animation rather than pulsing to zero
                // This provides a more visually appealing rotation effect
                angle =
                    (settings.chromaticSettings.angle + (pulse * 180.0)) %
                    360.0;
                animManager.updateAnimatedValue(
                  ParameterIds.chromaticAngle,
                  angle,
                );
              } else {
                // If locked, keep the slider value
                animManager.updateAnimatedValue(
                  ParameterIds.chromaticAngle,
                  angle,
                );
              }
            } else {
              // Randomized animation mode with parameter locking

              // Animate intensity if unlocked
              if (!animManager.isParameterLocked(
                ParameterIds.chromaticIntensity,
              )) {
                intensity =
                    ShaderAnimationUtils.computeRandomizedParameterValue(
                      settings.chromaticSettings.intensity,
                      settings.chromaticSettings.animOptions,
                      animationValue,
                      isLocked: animManager.isParameterLocked(
                        ParameterIds.chromaticIntensity,
                      ),
                      minValue: 0.0,
                      maxValue: 1.0,
                      parameterId: ParameterIds.chromaticIntensity,
                    );
                animManager.updateAnimatedValue(
                  ParameterIds.chromaticIntensity,
                  intensity,
                );
              } else {
                // If locked, keep the slider value
                animManager.updateAnimatedValue(
                  ParameterIds.chromaticIntensity,
                  intensity,
                );
              }

              // Animate amount if unlocked
              if (!animManager.isParameterLocked(
                ParameterIds.chromaticAmount,
              )) {
                amount = ShaderAnimationUtils.computeRandomizedParameterValue(
                  settings.chromaticSettings.amount,
                  settings.chromaticSettings.animOptions,
                  animationValue,
                  isLocked: animManager.isParameterLocked(
                    ParameterIds.chromaticAmount,
                  ),
                  minValue: 0.0,
                  maxValue: 20.0,
                  parameterId: ParameterIds.chromaticAmount,
                );
                animManager.updateAnimatedValue(
                  ParameterIds.chromaticAmount,
                  amount,
                );
              } else {
                // If locked, keep the slider value
                animManager.updateAnimatedValue(
                  ParameterIds.chromaticAmount,
                  amount,
                );
              }

              // Animate spread if unlocked
              if (!animManager.isParameterLocked(
                ParameterIds.chromaticSpread,
              )) {
                spread = ShaderAnimationUtils.computeRandomizedParameterValue(
                  settings.chromaticSettings.spread,
                  settings.chromaticSettings.animOptions,
                  animationValue,
                  isLocked: animManager.isParameterLocked(
                    ParameterIds.chromaticSpread,
                  ),
                  minValue: 0.0,
                  maxValue: 1.0,
                  parameterId: ParameterIds.chromaticSpread,
                );
                animManager.updateAnimatedValue(
                  ParameterIds.chromaticSpread,
                  spread,
                );
              } else {
                // If locked, keep the slider value
                animManager.updateAnimatedValue(
                  ParameterIds.chromaticSpread,
                  spread,
                );
              }

              // Animate angle if unlocked
              if (!animManager.isParameterLocked(ParameterIds.chromaticAngle)) {
                // For angle we want full rotation, so use a special approach
                // We'll animate between 0 and 360 degrees
                angle = ShaderAnimationUtils.computeRandomizedParameterValue(
                  settings.chromaticSettings.angle,
                  settings.chromaticSettings.animOptions,
                  animationValue,
                  isLocked: animManager.isParameterLocked(
                    ParameterIds.chromaticAngle,
                  ),
                  minValue: 0.0,
                  maxValue: 360.0,
                  parameterId: ParameterIds.chromaticAngle,
                );
                animManager.updateAnimatedValue(
                  ParameterIds.chromaticAngle,
                  angle,
                );
              } else {
                // If locked, keep the slider value
                animManager.updateAnimatedValue(
                  ParameterIds.chromaticAngle,
                  angle,
                );
              }
            }
          } else {
            // Clear animated values when animation is disabled
            final animManager = AnimationStateManager();
            animManager.clearAnimatedValue(ParameterIds.chromaticIntensity);
            animManager.clearAnimatedValue(ParameterIds.chromaticAmount);
            animManager.clearAnimatedValue(ParameterIds.chromaticAngle);
            animManager.clearAnimatedValue(ParameterIds.chromaticSpread);
          }

          // Set uniforms for the shader
          // CRITICAL FIX: Ensure size values are never zero to prevent shader issues
          shader.setFloat(
            0,
            size.width > 0.0 ? size.width : 1.0,
          ); // iResolution.x
          shader.setFloat(
            1,
            size.height > 0.0 ? size.height : 1.0,
          ); // iResolution.y

          // PERFORMANCE FIX: Only update iTime when animation is actually enabled
          // This prevents constant rebuilds when animation is disabled
          final double timeValue = settings.chromaticSettings.chromaticAnimated
              ? animationValue
              : 0.0; // Static time when not animating

          shader.setFloat(2, timeValue); // iTime
          shader.setFloat(3, intensity.clamp(0.0, 1.0)); // iIntensity
          shader.setFloat(4, amount.clamp(0.0, 20.0)); // iAmount
          shader.setFloat(5, angle.clamp(0.0, 360.0)); // iAngle
          shader.setFloat(6, spread.clamp(0.0, 1.0)); // iSpread

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
