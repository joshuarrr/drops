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

/// Custom noise effect shader widget
class NoiseEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;
  final String _logTag = 'NoiseEffectShader';

  // Log throttling - using static variables for efficient throttling
  static DateTime _lastLogTime = DateTime.now().subtract(
    const Duration(seconds: 1),
  );
  static const Duration _logThrottleInterval = Duration(milliseconds: 1000);
  static String _lastLogMessage =
      ""; // Track the last message to avoid duplicates

  const NoiseEffectShader({
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
      _log(
        "Building NoiseEffectShader with scale=${settings.noiseSettings.noiseScale.toStringAsFixed(2)}, wave=${settings.noiseSettings.waveAmount.toStringAsFixed(3)} (animated: ${settings.noiseSettings.noiseAnimated})",
      );
    }

    // Simplified approach using AnimatedSampler with ShaderBuilder
    return ShaderBuilder(assetKey: 'assets/shaders/noise_effect.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          // Set the texture sampler first
          shader.setImageSampler(0, image);

          // When noiseAnimated is false, we still send the noise speed
          // but we don't send an animated time value
          double timeValue = settings.noiseSettings.noiseAnimated
              ? animationValue
              : 0.0;

          // The noise speed to use, which can be 0 even when animated
          double noiseSpeed = settings.noiseSettings.noiseSpeed;

          // Compute animation values if animation is enabled
          if (settings.noiseSettings.noiseAnimated) {
            // Compute animated progress based on noise animation options
            final double animValue = ShaderAnimationUtils.computeAnimatedValue(
              settings.noiseSettings.noiseAnimOptions,
              animationValue,
            );

            // Use the animation value to control time
            timeValue = animValue;

            // Scale the noise speed based on animation options
            if (settings.noiseSettings.noiseAnimOptions.mode ==
                AnimationMode.pulse) {
              // Add a breathing effect to the speed in pulse mode
              final double pulse = math.sin(animValue * 2 * math.pi);
              noiseSpeed =
                  settings.noiseSettings.noiseSpeed * (0.5 + 0.5 * pulse);
            }
          }

          // If preserveTransparency is enabled or this is text content, adjust noise settings
          double colorIntensity = settings.noiseSettings.colorIntensity;
          double waveAmount = settings.noiseSettings.waveAmount;

          // CRITICAL FIX: Special handling for text content
          if (isTextContent) {
            // For text content, dramatically reduce settings that cause background problems
            colorIntensity =
                colorIntensity * 0.1; // Much more reduction for text
            waveAmount =
                waveAmount *
                0.1; // Dramatically reduce wave distortion for text

            if (enableShaderDebugLogs) {
              _log(
                "Reducing effects for text content - original colorIntensity=$colorIntensity, waveAmount=$waveAmount",
              );
            }
          }
          // Less aggressive adjustments for general transparency preservation
          else if (preserveTransparency) {
            colorIntensity = colorIntensity * 0.3; // Reduce color intensity
            waveAmount = waveAmount * 0.5; // Reduce wave distortion
          }

          // Set uniforms after the texture sampler
          shader.setFloat(0, timeValue); // Time
          shader.setFloat(
            1,
            size.width / size.height,
          ); // Resolution aspect ratio
          shader.setFloat(2, settings.noiseSettings.noiseScale); // Noise scale
          shader.setFloat(3, noiseSpeed); // Noise speed
          shader.setFloat(4, colorIntensity); // Color intensity
          shader.setFloat(5, waveAmount); // Wave distortion amount
          shader.setFloat(
            6,
            settings.noiseSettings.noiseAnimated ? 1.0 : 0.0,
          ); // Animation flag

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
