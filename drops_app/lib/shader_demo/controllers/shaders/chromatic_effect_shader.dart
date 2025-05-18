import 'dart:math';
import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/effect_settings.dart';
import '../../models/animation_options.dart';
import '../../utils/animation_utils.dart';
import 'custom_shader_builder.dart';
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
    developer.log(message, name: _logTag);
    debugPrint('[$_logTag] $message');
  }

  @override
  Widget build(BuildContext context) {
    // Log when the shader is being built
    if (enableShaderDebugLogs) {
      _log(
        "Building ChromaticEffectShader with amount=${settings.chromaticSettings.amount.toStringAsFixed(2)}, "
        "spread=${settings.chromaticSettings.spread.toStringAsFixed(2)}, "
        "intensity=${settings.chromaticSettings.intensity.toStringAsFixed(2)}, "
        "animated=${settings.chromaticSettings.chromaticAnimated}",
      );
    }

    // Use AnimatedSampler with custom FragmentShader
    return CustomShaderBuilder(
      child: child,
      callback:
          (BuildContext context, ui.Image image, Size size, Canvas canvas) {
            try {
              // Create a simple fragment program for chromatic aberration
              // This emulates a shader by manually manipulating the image

              // Get the image dimensions
              final double width = image.width.toDouble();
              final double height = image.height.toDouble();

              // Calculate parameters
              double amount = settings.chromaticSettings.amount;
              double angle =
                  settings.chromaticSettings.angle *
                  (pi / 180.0); // Convert to radians
              double spread = settings.chromaticSettings.spread;
              double intensity = settings.chromaticSettings.intensity;

              // Apply animation if enabled
              if (settings.chromaticSettings.chromaticAnimated) {
                final double animValue =
                    ShaderAnimationUtils.computeAnimatedValue(
                      settings.chromaticSettings.animOptions,
                      animationValue,
                    );

                // Add pulsing effect
                if (settings.chromaticSettings.animOptions.mode ==
                    AnimationMode.pulse) {
                  final double pulse = sin(animValue * 2 * pi);
                  amount = amount * (0.5 + 0.5 * pulse.abs());
                  spread = spread * (0.8 + 0.4 * pulse.abs());
                }

                // Add rotation to the angle based on animation
                angle = (angle + animValue * 2 * pi) % (2 * pi);
              }

              // Adjust for text content if needed
              if (isTextContent) {
                intensity *= 0.5; // Reduce intensity for text
                amount *= 0.3; // Reduce amount for text
              }

              // Calculate pixel displacement based on angle
              final double dx = cos(angle) * amount * width * 0.01;
              final double dy = sin(angle) * amount * width * 0.01;

              // Create paint for each RGB channel
              final Paint redPaint = Paint()
                ..colorFilter = const ColorFilter.matrix([
                  1,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ])
                ..blendMode = BlendMode.plus;

              final Paint greenPaint = Paint()
                ..colorFilter = const ColorFilter.matrix([
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ])
                ..blendMode = BlendMode.plus;

              final Paint bluePaint = Paint()
                ..colorFilter = const ColorFilter.matrix([
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ])
                ..blendMode = BlendMode.plus;

              // Clear the canvas first (for transparency)
              if (preserveTransparency) {
                canvas.saveLayer(
                  Rect.fromLTWH(0, 0, size.width, size.height),
                  Paint(),
                );
              } else {
                canvas.drawColor(Colors.black, BlendMode.src);
              }

              // Draw original image first if not fully separated
              if (spread < 1.0) {
                final double baseOpacity = 1.0 - (spread * intensity);
                final Paint basePaint = Paint()
                  ..colorFilter = ColorFilter.mode(
                    Colors.white.withOpacity(baseOpacity),
                    BlendMode.srcOver,
                  );

                canvas.drawImageRect(
                  image,
                  Rect.fromLTWH(0, 0, width, height),
                  Rect.fromLTWH(0, 0, size.width, size.height),
                  basePaint,
                );
              }

              // Calculate offsets for each channel based on spread
              final double redDx = -dx * spread;
              final double redDy = -dy * spread;
              final double blueDx = dx * spread;
              final double blueDy = dy * spread;

              // Apply the channel offsets with adjusted opacity
              final double channelOpacity = intensity * min(1.0, spread * 2);

              // Draw red channel
              redPaint.colorFilter = ColorFilter.matrix([
                1,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                channelOpacity,
                0,
              ]);

              canvas.drawImageRect(
                image,
                Rect.fromLTWH(0, 0, width, height),
                Rect.fromLTWH(redDx, redDy, size.width, size.height),
                redPaint,
              );

              // Draw green channel (no offset, serves as base)
              greenPaint.colorFilter = ColorFilter.matrix([
                0,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                channelOpacity,
                0,
              ]);

              canvas.drawImageRect(
                image,
                Rect.fromLTWH(0, 0, width, height),
                Rect.fromLTWH(0, 0, size.width, size.height),
                greenPaint,
              );

              // Draw blue channel
              bluePaint.colorFilter = ColorFilter.matrix([
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
                0,
                0,
                0,
                0,
                channelOpacity,
                0,
              ]);

              canvas.drawImageRect(
                image,
                Rect.fromLTWH(0, 0, width, height),
                Rect.fromLTWH(blueDx, blueDy, size.width, size.height),
                bluePaint,
              );

              if (preserveTransparency) {
                canvas.restore();
              }
            } catch (e) {
              _log("ERROR: $e");
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
          },
    );
  }
}
