import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;

import '../models/effect_settings.dart';
import 'shader_program_loader.dart';

/// Controls debug logging for shaders
bool enableShaderDebugLogs = false;

/// Custom color effect shader widget
class ColorEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;

  const ColorEffectShader({
    super.key,
    required this.child,
    required this.settings,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    if (enableShaderDebugLogs) {
      print("COLOR_SHADER: Building widget");
    }

    // Simplified approach using AnimatedSampler with ShaderBuilder
    return ShaderBuilder(assetKey: 'assets/shaders/color_effect.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          // Set the texture sampler first
          shader.setImageSampler(0, image);

          // Set uniforms after the texture sampler
          shader.setFloat(0, animationValue);
          shader.setFloat(1, settings.hue);
          shader.setFloat(2, settings.saturation);
          shader.setFloat(3, settings.lightness);
          shader.setFloat(4, settings.overlayHue);
          shader.setFloat(5, settings.overlayIntensity);
          shader.setFloat(6, settings.overlayOpacity);
          shader.setFloat(7, image.width.toDouble());
          shader.setFloat(8, image.height.toDouble());

          // Draw with the shader, ensuring it covers the full area
          canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
        } catch (e) {
          print("COLOR_SHADER ERROR: $e");
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

/// Custom blur effect shader widget
class BlurEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;

  const BlurEffectShader({
    super.key,
    required this.child,
    required this.settings,
    required this.animationValue,
  });

  @override
  Widget build(BuildContext context) {
    if (enableShaderDebugLogs) {
      print(
        "SHATTER_SHADER: Building widget with amount=${settings.blurAmount.toStringAsFixed(2)} (animated: ${settings.blurAnimated})",
      );
    }

    // Simplified approach using AnimatedSampler with ShaderBuilder
    return ShaderBuilder(assetKey: 'assets/shaders/blur_effect.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          // Set the texture sampler first
          shader.setImageSampler(0, image);

          // Compute animated amount if enabled
          double amount = settings.blurAmount;
          if (settings.blurAnimated) {
            amount =
                amount * (0.5 + 0.5 * math.sin(animationValue * 2 * math.pi));
          }

          // Set uniforms after the texture sampler
          shader.setFloat(0, amount);
          shader.setFloat(1, settings.blurRadius);
          shader.setFloat(2, image.width.toDouble());
          shader.setFloat(3, image.height.toDouble());
          shader.setFloat(4, settings.blurOpacity);
          shader.setFloat(5, settings.blurFacets);
          shader.setFloat(6, settings.blurBlendMode.toDouble());

          // Draw with the shader, ensuring it covers the full area
          canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
        } catch (e) {
          print("BLUR_SHADER ERROR: $e");
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
