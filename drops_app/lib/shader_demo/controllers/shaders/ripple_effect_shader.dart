import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../utils/animation_utils.dart';
import 'debug_flags.dart';

// Set to true for more verbose logging
bool enableVerboseRippleLogging = true;

/// RippleEffectShader: Adds a ripple water-like effect to a widget
class RippleEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;
  final String _logTag = 'RippleEffectShader';

  const RippleEffectShader({
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
        "Building RippleEffectShader with intensity=${settings.rippleSettings.rippleIntensity.toStringAsFixed(2)}, "
        "size=${settings.rippleSettings.rippleSize.toStringAsFixed(2)}, "
        "speed=${settings.rippleSettings.rippleSpeed.toStringAsFixed(2)}, "
        "dropCount=${settings.rippleSettings.rippleDropCount}, "
        "seed=${settings.rippleSettings.rippleSeed.toStringAsFixed(2)}, "
        "ovalness=${settings.rippleSettings.rippleOvalness.toStringAsFixed(2)}, "
        "rotation=${settings.rippleSettings.rippleRotation.toStringAsFixed(2)} "
        "(animated: ${settings.rippleSettings.rippleAnimated})",
      );
    }

    // Simplified shader structure - no LayoutBuilder, matching ChromaticEffectShader
    return ShaderBuilder(assetKey: 'assets/shaders/ripple_effect.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          if (enableVerboseRippleLogging) {
            _log(
              "RIPPLE SAMPLER: image=${image.width}x${image.height}, canvas=${size.width}x${size.height}",
            );
          }

          // Set the texture sampler first - match ChromaticEffectShader naming
          shader.setImageSampler(0, image);

          // Calculate animation value and time parameter
          double timeValue = settings.rippleSettings.rippleAnimated
              ? animationValue
              : 0.0;

          // Get the individual parameters
          double intensity = settings.rippleSettings.rippleIntensity;
          double rippleSize =
              1.0 -
              settings
                  .rippleSettings
                  .rippleSize; // Invert size for more intuitive control
          double speed = settings.rippleSettings.rippleSpeed;
          double opacity = settings.rippleSettings.rippleOpacity;
          double colorFactor = settings.rippleSettings.rippleColor;
          double dropCount = settings.rippleSettings.rippleDropCount.toDouble();
          double seed = settings.rippleSettings.rippleSeed;
          double ovalness = settings.rippleSettings.rippleOvalness;
          double rotation = settings.rippleSettings.rippleRotation;

          // Compute animation values if animation is enabled
          if (settings.rippleSettings.rippleAnimated) {
            timeValue = ShaderAnimationUtils.computeAnimatedValue(
              settings.rippleSettings.rippleAnimOptions,
              animationValue,
            );
          }

          // Set uniforms using size from canvas rather than constraints
          shader.setFloat(0, size.width);
          shader.setFloat(1, size.height);
          shader.setFloat(2, timeValue);
          shader.setFloat(3, intensity);
          shader.setFloat(4, rippleSize);
          shader.setFloat(5, speed);
          shader.setFloat(6, opacity);
          shader.setFloat(7, colorFactor);
          shader.setFloat(8, dropCount);
          shader.setFloat(9, seed);
          shader.setFloat(10, ovalness);
          shader.setFloat(11, rotation);

          // Draw with shader using exact same approach as other shaders
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

/// Helper method to apply ripple effect using custom shader
Widget applyRippleEffect({
  required Widget child,
  required ShaderSettings settings,
  required double animationValue,
  bool preserveTransparency = false,
  bool isTextContent = false,
}) {
  // Skip if ripple settings are minimal and no animation
  if (settings.rippleSettings.rippleIntensity <= 0.0 &&
      settings.rippleSettings.rippleSize <= 0.0 &&
      settings.rippleSettings.rippleSpeed <= 0.0 &&
      settings.rippleSettings.rippleOpacity <= 0.0 &&
      !settings.rippleSettings.rippleAnimated) {
    return child;
  }

  // Use custom shader implementation
  return RippleEffectShader(
    settings: settings,
    animationValue: animationValue,
    child: child,
    preserveTransparency: preserveTransparency,
    isTextContent: isTextContent,
  );
}
