import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../utils/animation_utils.dart';
import 'debug_flags.dart';

// Set to true for more verbose logging
bool enableVerboseCymaticsLogging = true;

/// CymaticsEffectShader: Adds sound wave visualization effects to a widget
class CymaticsEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;
  final String _logTag = 'CymaticsEffectShader';

  const CymaticsEffectShader({
    Key? key,
    required this.child,
    required this.settings,
    required this.animationValue,
    this.preserveTransparency = false,
    this.isTextContent = false,
  }) : super(key: key);

  // Custom log function that uses both dart:developer and debugPrint for visibility
  void _log(String message) {
    if (!enableShaderDebugLogs) return;
    developer.log(message, name: _logTag);
    debugPrint('[$_logTag] $message');
  }

  @override
  Widget build(BuildContext context) {
    if (enableShaderDebugLogs) {
      _log(
        "Building CymaticsEffectShader with intensity=${settings.cymaticsSettings.intensity.toStringAsFixed(2)}, "
        "frequency=${settings.cymaticsSettings.frequency.toStringAsFixed(2)}, "
        "amplitude=${settings.cymaticsSettings.amplitude.toStringAsFixed(2)}, "
        "complexity=${settings.cymaticsSettings.complexity.toStringAsFixed(2)}, "
        "speed=${settings.cymaticsSettings.speed.toStringAsFixed(2)}, "
        "colorIntensity=${settings.cymaticsSettings.colorIntensity.toStringAsFixed(2)}, "
        "audioReactive=${settings.cymaticsSettings.audioReactive}, "
        "audioSensitivity=${settings.cymaticsSettings.audioSensitivity.toStringAsFixed(2)} "
        "(animated: ${settings.cymaticsSettings.cymaticsAnimated})",
      );
    }

    // Shader builder pattern
    return ShaderBuilder(assetKey: 'assets/shaders/cymatics_effect.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          if (enableVerboseCymaticsLogging) {
            _log(
              "CYMATICS SAMPLER: image=${image.width}x${image.height}, canvas=${size.width}x${size.height}",
            );
          }

          // Set the texture sampler
          shader.setImageSampler(0, image);

          // Calculate animation value and time parameter
          double timeValue = settings.cymaticsSettings.cymaticsAnimated
              ? animationValue
              : 0.0;

          // Get the individual parameters
          double intensity = settings.cymaticsSettings.intensity;
          double frequency = settings.cymaticsSettings.frequency;
          double amplitude = settings.cymaticsSettings.amplitude;
          double complexity = settings.cymaticsSettings.complexity;
          double speed = settings.cymaticsSettings.speed;
          double colorIntensity = settings.cymaticsSettings.colorIntensity;
          double audioReactive = settings.cymaticsSettings.audioReactive
              ? 1.0
              : 0.0;
          double audioSensitivity = settings.cymaticsSettings.audioSensitivity;

          // Get audio waveform data if available (to be implemented)
          // This would come from the MusicController when we have access to audio visualization data
          double bassLevel =
              0.5; // Placeholder - should come from audio analysis
          double midLevel =
              0.5; // Placeholder - should come from audio analysis
          double trebleLevel =
              0.5; // Placeholder - should come from audio analysis

          // Compute animation values if animation is enabled
          if (settings.cymaticsSettings.cymaticsAnimated) {
            timeValue = ShaderAnimationUtils.computeAnimatedValue(
              settings.cymaticsSettings.animOptions,
              animationValue,
            );
          }

          // Set uniforms
          shader.setFloat(0, size.width);
          shader.setFloat(1, size.height);
          shader.setFloat(2, timeValue);
          shader.setFloat(3, intensity);
          shader.setFloat(4, frequency);
          shader.setFloat(5, amplitude);
          shader.setFloat(6, complexity);
          shader.setFloat(7, speed);
          shader.setFloat(8, colorIntensity);
          shader.setFloat(9, audioReactive);
          shader.setFloat(10, audioSensitivity);
          shader.setFloat(11, bassLevel);
          shader.setFloat(12, midLevel);
          shader.setFloat(13, trebleLevel);

          // Draw with shader
          canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
        } catch (e) {
          _log("ERROR: $e");
          // Fall back to drawing original image
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

/// Helper method to apply cymatics effect using custom shader
Widget applyCymaticsEffect({
  required Widget child,
  required ShaderSettings settings,
  required double animationValue,
  bool preserveTransparency = false,
  bool isTextContent = false,
}) {
  // Skip if cymatics settings are minimal and no animation
  if (settings.cymaticsSettings.intensity <= 0.0 &&
      settings.cymaticsSettings.frequency <= 0.0 &&
      settings.cymaticsSettings.amplitude <= 0.0 &&
      settings.cymaticsSettings.complexity <= 0.0 &&
      settings.cymaticsSettings.speed <= 0.0 &&
      !settings.cymaticsSettings.cymaticsAnimated) {
    return child;
  }

  // Use custom shader implementation
  return CymaticsEffectShader(
    settings: settings,
    animationValue: animationValue,
    child: child,
    preserveTransparency: preserveTransparency,
    isTextContent: isTextContent,
  );
}
