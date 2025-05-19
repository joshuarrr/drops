import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../utils/animation_utils.dart';
import 'debug_flags.dart';

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
        "speed=${settings.rippleSettings.rippleSpeed.toStringAsFixed(2)} "
        "(animated: ${settings.rippleSettings.rippleAnimated})",
      );
    }

    // Use ShaderBuilder with AnimatedSampler for the effect
    return ShaderBuilder(assetKey: 'assets/shaders/ripple_effect.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          // Set the texture sampler first
          shader.setImageSampler(0, image);

          // Calculate animation value and time parameter
          double timeValue = settings.rippleSettings.rippleAnimated
              ? animationValue
              : 0.0;

          // Get the individual parameters
          double intensity = settings.rippleSettings.rippleIntensity;
          double rippleSize = settings.rippleSettings.rippleSize;
          double speed = settings.rippleSettings.rippleSpeed;
          double opacity = settings.rippleSettings.rippleOpacity;
          double colorFactor = settings.rippleSettings.rippleColor;

          // Compute animation values if animation is enabled
          if (settings.rippleSettings.rippleAnimated) {
            // Compute animated progress
            timeValue = ShaderAnimationUtils.computeAnimatedValue(
              settings.rippleSettings.rippleAnimOptions,
              animationValue,
            );
          }

          // Set uniforms for the shader
          shader.setFloat(0, size.width); // width
          shader.setFloat(1, size.height); // height
          shader.setFloat(2, timeValue); // time
          shader.setFloat(3, intensity); // intensity
          shader.setFloat(4, rippleSize); // size
          shader.setFloat(5, speed); // speed
          shader.setFloat(6, opacity); // opacity
          shader.setFloat(7, colorFactor); // colorFactor

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
