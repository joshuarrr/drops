import 'dart:math';
import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../models/animation_options.dart';
import '../../utils/animation_utils.dart';
import 'debug_flags.dart'; // Import the shared debug flag

/// Controls debug logging for shaders (external reference)
bool enableShaderDebugLogs = true;

/// Custom chromatic aberration effect shader widget using GLSL
class ChromaticEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;
  final String _logTag = 'ChromaticEffectShader';

  // Log throttling - improved to be static and more efficient
  static DateTime _lastLogTime = DateTime.now().subtract(
    const Duration(seconds: 1),
  );
  static const Duration _logThrottleInterval = Duration(
    milliseconds: 1000,
  ); // Increased from 500ms to 1000ms
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
    // Only log when parameters actually change
    final String logMessage =
        "Building ChromaticEffectShader with amount=${settings.chromaticSettings.amount.toStringAsFixed(2)}, "
        "spread=${settings.chromaticSettings.spread.toStringAsFixed(2)}, "
        "intensity=${settings.chromaticSettings.intensity.toStringAsFixed(2)}, "
        "animated=${settings.chromaticSettings.chromaticAnimated}";

    if (enableShaderDebugLogs) {
      _log(logMessage);
    }

    // Use ShaderBuilder to apply the custom GLSL shader
    return ShaderBuilder(assetKey: 'assets/shaders/chromatic_aberration.frag', (
      context,
      shader,
      child,
    ) {
      // Calculate parameters
      double amount = settings.chromaticSettings.amount;
      double angle =
          settings.chromaticSettings.angle * (pi / 180.0); // Convert to radians
      double spread = settings.chromaticSettings.spread;
      double intensity = settings.chromaticSettings.intensity;

      // Apply animation if enabled
      double animTime = 0.0;
      if (settings.chromaticSettings.chromaticAnimated) {
        final double animValue = ShaderAnimationUtils.computeAnimatedValue(
          settings.chromaticSettings.animOptions,
          animationValue,
        );

        // Calculate animation time for shader
        animTime = animValue;

        // Add pulsing effect
        if (settings.chromaticSettings.animOptions.mode ==
            AnimationMode.pulse) {
          final double pulse = sin(animValue * 2 * pi);
          amount = amount * (0.5 + 0.5 * pulse.abs());
          spread = spread * (0.8 + 0.4 * pulse.abs());
        }
      }

      // Adjust for text content if needed
      if (isTextContent) {
        intensity *= 0.5; // Reduce intensity for text
        amount *= 0.3; // Reduce amount for text
      }

      return AnimatedSampler((image, size, canvas) {
        try {
          // Set shader uniform values
          shader.setFloat(0, animTime); // uTime
          shader.setFloat(1, size.width); // uResolutionX
          shader.setFloat(2, size.height); // uResolutionY
          shader.setImageSampler(0, image); // uTexture
          shader.setFloat(3, amount); // uAmount
          shader.setFloat(4, spread); // uSpread
          shader.setFloat(5, intensity); // uIntensity
          shader.setFloat(
            6,
            angle * (180 / pi),
          ); // Convert angle back to degrees for shader

          // Draw the shader
          canvas.drawRect(
            Rect.fromLTWH(0, 0, size.width, size.height),
            Paint()..shader = shader,
          );
        } catch (e) {
          _log("SHADER ERROR: $e");
          // Fall back to drawing the original image on error
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
