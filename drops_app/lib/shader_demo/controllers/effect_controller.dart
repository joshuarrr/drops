import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../models/effect_settings.dart';
import '../models/shader_effect.dart';
import '../views/wave_distortion_painter.dart';

class EffectController {
  // Apply the selected effect to a widget
  static Widget applyEffect({
    required Widget child,
    required ShaderEffect selectedEffect,
    required WaveSettings waveSettings,
    required ColorSettings colorSettings,
    required PixelateSettings pixelateSettings,
    required double animationValue,
  }) {
    switch (selectedEffect) {
      case ShaderEffect.none:
        return child;
      case ShaderEffect.color:
        return _applyColorEffect(
          child: child,
          colorSettings: colorSettings,
          animationValue: animationValue,
        );
      case ShaderEffect.wave:
        if (waveSettings.intensity > 0.0 && waveSettings.speed > 0.0) {
          return _applyWaveEffect(
            child: child,
            waveSettings: waveSettings,
            animationValue: animationValue,
          );
        }
        return child;
      case ShaderEffect.pixelate:
        if (pixelateSettings.blurAmount > 0.0) {
          return _applyPixelateEffect(
            child: child,
            pixelateSettings: pixelateSettings,
          );
        }
        return child;
    }
  }

  // Helper method to apply wave effect to any widget
  static Widget _applyWaveEffect({
    required Widget child,
    required WaveSettings waveSettings,
    required double animationValue,
  }) {
    final time = animationValue;
    final intensity = waveSettings.intensity * 20.0; // Amplify effect
    final speed = waveSettings.speed;

    // Create a wave distortion effect without color changes
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base image
        child,

        // Wave grid overlay
        Opacity(
          opacity: 0.8,
          child: CustomPaint(
            painter: WaveDistortionPainter(
              time: time,
              intensity: intensity,
              speed: speed,
            ),
            size: Size.infinite,
          ),
        ),
      ],
    );
  }

  // Helper method to apply color effect to any widget
  static Widget _applyColorEffect({
    required Widget child,
    required ColorSettings colorSettings,
    required double animationValue,
  }) {
    final time = animationValue;
    final speed = 0.5; // Use a moderate speed for any animations

    // Base image color adjustments from the color settings object
    final double baseHueCos = cos(2 * pi * colorSettings.hue);
    final double baseHueSin = sin(2 * pi * colorSettings.hue);

    // First apply the base image adjustments
    Widget adjustedImage = ColorFiltered(
      colorFilter: ColorFilter.matrix([
        // Red channel
        1.0 + colorSettings.saturation * (baseHueCos - 1.0),
        colorSettings.saturation *
            sin(2 * pi * (colorSettings.hue + 1 / 3)) *
            0.5,
        colorSettings.saturation *
            sin(2 * pi * (colorSettings.hue + 2 / 3)) *
            0.5,
        0,
        colorSettings.lightness * 0.3,

        // Green channel
        colorSettings.saturation * sin(2 * pi * colorSettings.hue) * 0.5,
        1.0 +
            colorSettings.saturation *
                (cos(2 * pi * (colorSettings.hue + 1 / 3)) - 1.0),
        colorSettings.saturation *
            sin(2 * pi * (colorSettings.hue + 2 / 3)) *
            0.5,
        0,
        colorSettings.lightness * 0.3,

        // Blue channel
        colorSettings.saturation * sin(2 * pi * colorSettings.hue) * 0.5,
        colorSettings.saturation *
            sin(2 * pi * (colorSettings.hue + 1 / 3)) *
            0.5,
        1.0 +
            colorSettings.saturation *
                (cos(2 * pi * (colorSettings.hue + 2 / 3)) - 1.0),
        0,
        colorSettings.lightness * 0.3,

        // Alpha channel
        0,
        0,
        0,
        1.0,
        0,
      ]),
      child: child,
    );

    // Then apply color overlay if opacity > 0
    if (colorSettings.overlayOpacity > 0) {
      // Create the base stack with the adjusted image and an overlay
      List<Widget> stackChildren = [
        adjustedImage,
        Opacity(
          opacity:
              colorSettings.overlayOpacity * colorSettings.overlayIntensity,
          child: Container(
            color: HSLColor.fromAHSL(
              1.0,
              colorSettings.overlayHue * 360,
              1.0,
              0.5,
            ).toColor(),
          ),
        ),
      ];

      // Rainbow effect was moved here from wave effect
      if (colorSettings.overlayIntensity > 0.5) {
        // Add a rainbow-like color gradient with animation if intensity is high enough
        stackChildren.add(
          ShaderMask(
            blendMode: BlendMode.overlay,
            shaderCallback: (Rect bounds) {
              // Create a rainbow-like wave effect
              final rainbowColors = [
                HSLColor.fromAHSL(
                  0.4,
                  (time * speed * 360) % 360,
                  0.8,
                  0.5,
                ).toColor(),
                HSLColor.fromAHSL(
                  0.4,
                  (time * speed * 360 + 60) % 360,
                  0.8,
                  0.5,
                ).toColor(),
                HSLColor.fromAHSL(
                  0.4,
                  (time * speed * 360 + 120) % 360,
                  0.8,
                  0.5,
                ).toColor(),
                HSLColor.fromAHSL(
                  0.4,
                  (time * speed * 360 + 180) % 360,
                  0.8,
                  0.5,
                ).toColor(),
                HSLColor.fromAHSL(
                  0.4,
                  (time * speed * 360 + 240) % 360,
                  0.8,
                  0.5,
                ).toColor(),
              ];

              return ui.Gradient.linear(
                Offset(bounds.width * 0.5, 0),
                Offset(bounds.width * 0.5, bounds.height),
                rainbowColors,
                [0.0, 0.25, 0.5, 0.75, 1.0],
                TileMode.mirror,
              );
            },
            child: Container(color: Colors.white.withOpacity(0.3)),
          ),
        );
      }

      return Stack(fit: StackFit.expand, children: stackChildren);
    }

    return adjustedImage;
  }

  // Helper method to apply pixelate/blur effect to any widget
  static Widget _applyPixelateEffect({
    required Widget child,
    required PixelateSettings pixelateSettings,
  }) {
    // Use blur parameters from the pixelate settings object
    final blurValue = 0.5 + 1.5 * pixelateSettings.blurAmount;
    final qualityFactor = 1.0 + pixelateSettings.blurQuality * 2.0;

    return ImageFiltered(
      imageFilter: ui.ImageFilter.blur(
        sigmaX: blurValue * qualityFactor,
        sigmaY: blurValue * qualityFactor,
      ),
      child: child,
    );
  }
}
