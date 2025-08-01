import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import '../models/color_settings.dart';

/// Simple color effect shader for V3 demo
class ColorEffectShader extends StatelessWidget {
  final Widget child;
  final ColorSettings settings;
  final double animationValue;

  const ColorEffectShader({
    super.key,
    required this.child,
    required this.settings,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    // Only log occasionally to reduce spam
    if (animationValue % 0.1 < 0.01) {
      debugPrint(
        '[V3] ColorEffectShader building with animationValue=${animationValue.toStringAsFixed(3)}',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return ShaderBuilder(assetKey: 'assets/shaders/color_effect.frag', (
          context,
          shader,
          child,
        ) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: AnimatedSampler((image, size, canvas) {
              try {
                // Set the texture sampler
                shader.setImageSampler(0, image);

                // Compute color values
                double hue = settings.hue;
                double saturation = settings.saturation;
                double lightness = settings.lightness;

                // Apply animation if enabled - SIMPLIFIED APPROACH
                if (settings.colorAnimated) {
                  // Direct animation using controller value
                  // This creates a clear visual oscillation between original values and zero
                  final double animFactor = math
                      .sin(animationValue * math.pi)
                      .abs();

                  // Animate between original values and zero
                  hue = settings.hue * animFactor;
                  saturation = settings.saturation * animFactor;
                  lightness = settings.lightness * animFactor;

                  // Log animated values occasionally to reduce spam
                  if (animationValue % 0.1 < 0.01) {
                    debugPrint(
                      '[V3] Animated values: animFactor=${animFactor.toStringAsFixed(3)}, hue=${hue.toStringAsFixed(3)}, saturation=${saturation.toStringAsFixed(3)}, lightness=${lightness.toStringAsFixed(3)}',
                    );
                  }
                }

                // Set shader uniforms
                shader.setFloat(0, animationValue); // time
                shader.setFloat(1, hue);
                shader.setFloat(2, saturation);
                shader.setFloat(3, lightness);
                shader.setFloat(4, 0.0); // overlayHue
                shader.setFloat(5, 0.0); // overlayIntensity
                shader.setFloat(6, 0.0); // overlayOpacity
                shader.setFloat(7, image.width.toDouble());
                shader.setFloat(8, image.height.toDouble());
                shader.setFloat(9, 0.0); // isTextContent

                // Draw with shader
                canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
              } catch (e) {
                debugPrint('[V3] Error in ColorEffectShader: $e');
                // Fallback to original image
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
