import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../models/effect_settings.dart';
import 'shader_program_loader.dart';

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
    // Use ShaderBuilder for loading and applying the shader
    return ShaderBuilder(assetKey: 'assets/shaders/color_effect.frag', (
      context,
      shader,
      child,
    ) {
      // Set shader uniforms
      shader.setFloat(0, animationValue); // uTime
      shader.setFloat(1, settings.hue); // uHue
      shader.setFloat(2, settings.saturation); // uSaturation
      shader.setFloat(3, settings.lightness); // uLightness
      shader.setFloat(4, settings.overlayHue); // uOverlayHue
      shader.setFloat(5, settings.overlayIntensity); // uOverlayIntensity
      shader.setFloat(6, settings.overlayOpacity); // uOverlayOpacity

      // Get screen size for shader resolution
      final Size size = MediaQuery.of(context).size;
      shader.setFloat(7, size.width); // uResolution.x
      shader.setFloat(8, size.height); // uResolution.y

      // Apply shader to child
      return AnimatedSampler((ui.Image image, Size size, Canvas canvas) {
        // Set the sampled texture
        shader.setImageSampler(0, image);

        // Draw the shader
        canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
      }, child: child!);
    }, child: child);
  }
}

/// Custom blur effect shader widget
class BlurEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;

  const BlurEffectShader({
    super.key,
    required this.child,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    // Use ShaderBuilder for loading and applying the shader
    return ShaderBuilder(assetKey: 'assets/shaders/blur_effect.frag', (
      context,
      shader,
      child,
    ) {
      // Set shader uniforms
      shader.setFloat(0, settings.blurAmount); // uBlurAmount
      shader.setFloat(1, settings.blurRadius); // uBlurRadius

      // Get screen size for shader resolution
      final Size size = MediaQuery.of(context).size;
      shader.setFloat(2, size.width); // uResolution.x
      shader.setFloat(3, size.height); // uResolution.y

      // Apply shader to child
      return AnimatedSampler((ui.Image image, Size size, Canvas canvas) {
        // Set the sampled texture
        shader.setImageSampler(0, image);

        // Draw the shader
        canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
      }, child: child!);
    }, child: child);
  }
}
