import 'dart:math' as math;
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../models/animation_options.dart';
import '../../utils/animation_utils.dart';
import '../animation_state_manager.dart';
import 'debug_flags.dart'; // Import the shared debug flag

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

  @override
  Widget build(BuildContext context) {
    if (enableShaderDebugLogs) {
      final String logMessage =
          "Building ChromaticEffectShader with intensity=${settings.chromaticSettings.intensity.toStringAsFixed(2)} "
          "(animated: ${settings.chromaticSettings.chromaticAnimated})";
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
              // Use consistent pulse calculation for chromatic effect
              final double pulse = ShaderAnimationUtils.computePulseValue(
                settings.chromaticSettings.animOptions,
                animationValue,
              );

              // Apply pulse to all chromatic effect parameters and report animated values
              intensity = settings.chromaticSettings.intensity * pulse;
              amount = settings.chromaticSettings.amount * pulse;
              spread = settings.chromaticSettings.spread * pulse;
              // Angle can animate through full rotation
              angle =
                  (settings.chromaticSettings.angle + (pulse * 360.0)) % 360.0;

              animManager.updateAnimatedValue(
                ParameterIds.chromaticIntensity,
                intensity,
              );
              animManager.updateAnimatedValue(
                ParameterIds.chromaticAmount,
                amount,
              );
              animManager.updateAnimatedValue(
                ParameterIds.chromaticAngle,
                angle,
              );
              animManager.updateAnimatedValue(
                ParameterIds.chromaticSpread,
                spread,
              );
            } else {
              // For non-pulse modes, use the standard animation utilities
              final double animValue =
                  ShaderAnimationUtils.computeAnimatedValue(
                    settings.chromaticSettings.animOptions,
                    animationValue,
                  );

              // Apply animation to all chromatic effect parameters and report values
              intensity = settings.chromaticSettings.intensity * animValue;
              amount = settings.chromaticSettings.amount * animValue;
              spread = settings.chromaticSettings.spread * animValue;
              // Angle can animate through full rotation
              angle =
                  (settings.chromaticSettings.angle + (animValue * 360.0)) %
                  360.0;

              animManager.updateAnimatedValue(
                ParameterIds.chromaticIntensity,
                intensity,
              );
              animManager.updateAnimatedValue(
                ParameterIds.chromaticAmount,
                amount,
              );
              animManager.updateAnimatedValue(
                ParameterIds.chromaticAngle,
                angle,
              );
              animManager.updateAnimatedValue(
                ParameterIds.chromaticSpread,
                spread,
              );
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
