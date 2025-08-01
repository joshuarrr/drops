import 'dart:math' as math;
import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../models/animation_options.dart';
import '../../utils/animation_utils.dart';
import '../animation_state_manager.dart';

/// Controls debug logging for shaders (external reference)
bool enableShaderDebugLogs = false;

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

  @override
  Widget build(BuildContext context) {
    // Use animated shader when animation is enabled, static when disabled
    if (settings.noiseSettings.noiseAnimated) {
      return _buildAnimatedShader();
    } else {
      return _buildStaticShader();
    }
  }

  Widget _buildAnimatedShader() {
    // Use AnimatedSampler for animated noise effects
    return ShaderBuilder(assetKey: 'assets/shaders/noise_effect.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          _renderShader(shader, image, size, canvas);
        } catch (e) {
          _fallbackRender(image, size, canvas);
        }
      }, child: this.child);
    }, child: child);
  }

  Widget _buildStaticShader() {
    // FIX A: Use actual shader for static effects, not fallback painter
    // Use AnimatedSampler even for static effects to ensure shader is properly executed
    return ShaderBuilder(assetKey: 'assets/shaders/noise_effect.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          _renderShader(shader, image, size, canvas);
        } catch (e) {
          _fallbackRender(image, size, canvas);
        }
      }, child: this.child);
    }, child: child);
  }

  void _renderShader(
    ui.FragmentShader shader,
    ui.Image image,
    Size size,
    Canvas canvas,
  ) {
    // Set the texture sampler first
    shader.setImageSampler(0, image);

    // When noiseAnimated is false, we still send the noise speed
    // but we don't send an animated time value
    double timeValue = settings.noiseSettings.noiseAnimated
        ? animationValue
        : 0.0;

    // The noise speed to use, which can be 0 even when animated
    double noiseSpeed = settings.noiseSettings.noiseSpeed;
    double noiseScale = settings.noiseSettings.noiseScale;

    double colorIntensity = settings.noiseSettings.colorIntensity;
    double waveAmount = settings.noiseSettings.waveAmount;

    // Compute animation values if animation is enabled
    if (settings.noiseSettings.noiseAnimated) {
      final animManager = AnimationStateManager();

      if (settings.noiseSettings.noiseAnimOptions.mode == AnimationMode.pulse) {
        // FIX B: Use consistent animation timing with other effects
        // Use shared pulse calculation for consistency with blur/shatter
        final double pulse = ShaderAnimationUtils.computePulseValue(
          settings.noiseSettings.noiseAnimOptions,
          animationValue,
        );
        timeValue = pulse;

        // PULSE MODE: Unlocked parameters pulse from 0 to slider value
        // Locked parameters stay at slider value
        if (animManager.isParameterLocked(ParameterIds.noiseScale)) {
          // Locked: use slider value
          noiseScale = settings.noiseSettings.noiseScale;
          animManager.clearAnimatedValue(ParameterIds.noiseScale);
        } else {
          // Unlocked: pulse from 0 to slider value
          noiseScale = settings.noiseSettings.noiseScale * pulse;
          animManager.updateAnimatedValue(ParameterIds.noiseScale, noiseScale);
        }

        if (animManager.isParameterLocked(ParameterIds.noiseSpeed)) {
          // Locked: use slider value
          noiseSpeed = settings.noiseSettings.noiseSpeed;
          animManager.clearAnimatedValue(ParameterIds.noiseSpeed);
        } else {
          // Unlocked: pulse from 0 to slider value
          noiseSpeed = settings.noiseSettings.noiseSpeed * pulse;
          animManager.updateAnimatedValue(ParameterIds.noiseSpeed, noiseSpeed);
        }

        if (animManager.isParameterLocked(ParameterIds.colorIntensity)) {
          // Locked: use slider value
          colorIntensity = settings.noiseSettings.colorIntensity;
          animManager.clearAnimatedValue(ParameterIds.colorIntensity);
        } else {
          // Unlocked: pulse from 0 to slider value
          colorIntensity = settings.noiseSettings.colorIntensity * pulse;
          animManager.updateAnimatedValue(
            ParameterIds.colorIntensity,
            colorIntensity,
          );
        }

        if (animManager.isParameterLocked(ParameterIds.waveAmount)) {
          // Locked: use slider value
          waveAmount = settings.noiseSettings.waveAmount;
          animManager.clearAnimatedValue(ParameterIds.waveAmount);
        } else {
          // Unlocked: pulse from 0 to slider value
          waveAmount = settings.noiseSettings.waveAmount * pulse;
          animManager.updateAnimatedValue(ParameterIds.waveAmount, waveAmount);
        }
      } else {
        // For randomized modes, use the centralized animation utilities
        final double animValue = ShaderAnimationUtils.computeAnimatedValue(
          settings.noiseSettings.noiseAnimOptions,
          animationValue,
        );
        timeValue = animValue;

        // RANDOMIZED MODE: Locked parameters animate 0 to slider value
        // Unlocked parameters animate across full range
        if (animManager.isParameterLocked(ParameterIds.noiseScale)) {
          // Locked: animate between 0 and slider value
          noiseScale = settings.noiseSettings.noiseScale * animValue;
          animManager.updateAnimatedValue(ParameterIds.noiseScale, noiseScale);
        } else {
          // Unlocked: animate across full range
          noiseScale = ShaderAnimationUtils.computeRandomizedParameterValue(
            settings.noiseSettings.noiseScale,
            settings.noiseSettings.noiseAnimOptions,
            animationValue,
            isLocked: false,
            minValue: 0.1,
            maxValue: 20.0,
          );
          animManager.updateAnimatedValue(ParameterIds.noiseScale, noiseScale);
        }

        if (animManager.isParameterLocked(ParameterIds.noiseSpeed)) {
          // Locked: animate between 0 and slider value
          noiseSpeed = settings.noiseSettings.noiseSpeed * animValue;
          animManager.updateAnimatedValue(ParameterIds.noiseSpeed, noiseSpeed);
        } else {
          // Unlocked: animate across full range
          noiseSpeed = ShaderAnimationUtils.computeRandomizedParameterValue(
            settings.noiseSettings.noiseSpeed,
            settings.noiseSettings.noiseAnimOptions,
            animationValue,
            isLocked: false,
            minValue: 0.0,
            maxValue: 1.0,
          );
          animManager.updateAnimatedValue(ParameterIds.noiseSpeed, noiseSpeed);
        }

        if (animManager.isParameterLocked(ParameterIds.colorIntensity)) {
          // Locked: animate between 0 and slider value
          colorIntensity = settings.noiseSettings.colorIntensity * animValue;
          animManager.updateAnimatedValue(
            ParameterIds.colorIntensity,
            colorIntensity,
          );
        } else {
          // Unlocked: animate across full range
          colorIntensity = ShaderAnimationUtils.computeRandomizedParameterValue(
            settings.noiseSettings.colorIntensity,
            settings.noiseSettings.noiseAnimOptions,
            animationValue,
            isLocked: false,
            minValue: 0.0,
            maxValue: 1.0,
          );
          animManager.updateAnimatedValue(
            ParameterIds.colorIntensity,
            colorIntensity,
          );
        }

        if (animManager.isParameterLocked(ParameterIds.waveAmount)) {
          // Locked: animate between 0 and slider value
          waveAmount = settings.noiseSettings.waveAmount * animValue;
          animManager.updateAnimatedValue(ParameterIds.waveAmount, waveAmount);
        } else {
          // Unlocked: animate across full range
          waveAmount = ShaderAnimationUtils.computeRandomizedParameterValue(
            settings.noiseSettings.waveAmount,
            settings.noiseSettings.noiseAnimOptions,
            animationValue,
            isLocked: false,
            minValue: 0.0,
            maxValue: 0.1,
          );
          animManager.updateAnimatedValue(ParameterIds.waveAmount, waveAmount);
        }
      }
    } else {
      // Clear animated values when animation is disabled
      final animManager = AnimationStateManager();
      animManager.clearAnimatedValue(ParameterIds.noiseScale);
      animManager.clearAnimatedValue(ParameterIds.noiseSpeed);
      animManager.clearAnimatedValue(ParameterIds.colorIntensity);
      animManager.clearAnimatedValue(ParameterIds.waveAmount);
    }

    // CRITICAL FIX: Special handling for text content
    if (isTextContent) {
      // For text content, dramatically reduce settings that cause background problems
      colorIntensity = colorIntensity * 0.1; // Much more reduction for text
      waveAmount =
          waveAmount * 0.1; // Dramatically reduce wave distortion for text
    }
    // Less aggressive adjustments for general transparency preservation
    else if (preserveTransparency) {
      colorIntensity = colorIntensity * 0.3; // Reduce color intensity
      waveAmount = waveAmount * 0.5; // Reduce wave distortion
    }

    // Set uniforms after the texture sampler
    shader.setFloat(0, timeValue); // Time

    // CRITICAL FIX: Prevent NaN values in aspect ratio calculation
    double aspectRatio = 1.0; // Default fallback
    if (size.height > 0.0 && size.width > 0.0) {
      aspectRatio = size.width / size.height;
      // Clamp to reasonable bounds to prevent extreme values
      aspectRatio = aspectRatio.clamp(0.1, 10.0);
    }
    shader.setFloat(1, aspectRatio); // Resolution aspect ratio

    // Clamp all shader parameters to safe ranges to prevent NaN
    shader.setFloat(2, noiseScale.clamp(0.1, 20.0)); // Noise scale
    shader.setFloat(3, noiseSpeed.clamp(0.0, 2.0)); // Noise speed
    shader.setFloat(4, colorIntensity.clamp(0.0, 1.0)); // Color intensity
    shader.setFloat(5, waveAmount.clamp(0.0, 0.5)); // Wave distortion amount
    shader.setFloat(
      6,
      settings.noiseSettings.noiseAnimated ? 1.0 : 0.0,
    ); // Animation flag

    // Draw with the shader, ensuring it covers the full area
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  void _fallbackRender(ui.Image image, Size size, Canvas canvas) {
    // Fall back to drawing the original image
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );
  }
}

// Custom painter for static noise effect to avoid AnimatedSampler memory accumulation
class _NoiseStaticPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;

  _NoiseStaticPainter({
    required this.shader,
    required this.settings,
    required this.animationValue,
    required this.preserveTransparency,
    required this.isTextContent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    try {
      // For static noise, we need to render the shader with a static input
      // Since we can't easily create an image synchronously, we'll use a different approach

      // Create a minimal texture using a Picture rendered to the canvas directly
      final recorder = ui.PictureRecorder();
      final textureCanvas = Canvas(recorder);

      // Create a simple white rectangle as our texture source
      final texturePaint = Paint()..color = Colors.white;
      textureCanvas.drawRect(
        Rect.fromLTWH(0, 0, 64, 64), // Small texture is fine for noise
        texturePaint,
      );

      final picture = recorder.endRecording();

      // For now, let's render the static noise pattern manually since
      // synchronous image creation is complex in Flutter
      _renderStaticNoisePattern(canvas, size);

      picture.dispose();
    } catch (e) {
      // Fallback to simple noise pattern
      _renderStaticNoisePattern(canvas, size);
    }
  }

  void _renderStaticNoisePattern(Canvas canvas, Size size) {
    // Render a static noise pattern that resembles what the shader would produce
    // but without needing an actual shader image input

    final paint = Paint();

    // Get noise settings
    double colorIntensity = settings.noiseSettings.colorIntensity;
    double waveAmount = settings.noiseSettings.waveAmount;
    double noiseScale = settings.noiseSettings.noiseScale;

    // Apply same adjustments as the main shader
    if (isTextContent) {
      colorIntensity = colorIntensity * 0.1;
      waveAmount = waveAmount * 0.1;
    } else if (preserveTransparency) {
      colorIntensity = colorIntensity * 0.3;
      waveAmount = waveAmount * 0.5;
    }

    // FIX A: Render wave effects even when color intensity is zero
    // Render color-based noise effects if there's color intensity
    if (colorIntensity > 0.0) {
      // Create a subtle static noise effect
      final random = math.Random(
        42,
      ); // Fixed seed for consistent static pattern

      // Draw small noise dots across the surface
      for (
        int i = 0;
        i < (size.width * size.height * noiseScale * 0.001).toInt();
        i++
      ) {
        final x = random.nextDouble() * size.width;
        final y = random.nextDouble() * size.height;

        final alpha = (colorIntensity * 0.3 * random.nextDouble()).clamp(
          0.0,
          1.0,
        );

        paint.color = Color.fromRGBO(
          242,
          143,
          202, // Noise color
          alpha,
        );

        // Small dots for texture
        canvas.drawCircle(
          Offset(x, y),
          (0.5 + random.nextDouble() * 1.0) * noiseScale,
          paint,
        );
      }
    }

    // Render wave distortion effect independently of color intensity
    if (waveAmount > 0.0) {
      paint.color = Color.fromRGBO(242, 143, 202, waveAmount * 0.2);
      canvas.drawRect(Offset.zero & size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
