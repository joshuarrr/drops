import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../utils/animation_utils.dart';
import 'debug_flags.dart'; // Import the shared debug flag

/// Controls debug logging for shaders (external reference)
bool enableShaderDebugLogs = true;

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
            // Reuse helper to obtain a 0-1 value taking animation settings into account
            final double animValue = ShaderAnimationUtils.computeAnimatedValue(
              settings.chromaticSettings.animOptions,
              animationValue,
            );

            // Apply animation based on the current animation mode
            intensity = intensity * animValue;
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
          // Clamp all parameters to safe ranges to prevent NaN
          shader.setFloat(2, animationValue); // iTime
          shader.setFloat(3, intensity.clamp(0.0, 1.0)); // iIntensity
          shader.setFloat(4, amount.clamp(0.0, 1.0)); // iAmount
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
