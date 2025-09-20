import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../models/animation_options.dart';
import '../../utils/animation_utils.dart';
import '../animation_state_manager.dart';
import 'debug_flags.dart';

/// Custom shader widget for glitch effect
class GlitchShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;
  final String _logTag = 'GlitchShader';

  // Log throttling
  static DateTime _lastLogTime = DateTime.now().subtract(
    const Duration(seconds: 1),
  );
  static const Duration _logThrottleInterval = Duration(milliseconds: 1000);
  static String _lastLogMessage = "";

  const GlitchShader({
    super.key,
    required this.child,
    required this.settings,
    required this.animationValue,
    this.preserveTransparency = false,
    this.isTextContent = false,
  });

  // Custom log function
  void _log(String message) {
    if (!enableShaderDebugLogs) return;
    if (message == _lastLogMessage) return;

    final now = DateTime.now();
    if (now.difference(_lastLogTime) < _logThrottleInterval) return;

    _lastLogTime = now;
    _lastLogMessage = message;

    developer.log(message, name: _logTag);
    debugPrint('[$_logTag] $message');
  }

  @override
  Widget build(BuildContext context) {
    if (enableShaderDebugLogs) {
      _log(
        "Building GlitchShader with opacity=${settings.glitchSettings.opacity.toStringAsFixed(2)}, animated=${settings.glitchSettings.effectAnimated}, animationValue=${animationValue.toStringAsFixed(3)}",
      );
    }

    // Skip if effect is disabled or opacity is too low
    if (!settings.glitchSettings.shouldApplyEffect) {
      return child;
    }

    // Use ShaderBuilder with AnimatedSampler
    return ShaderBuilder(assetKey: 'assets/shaders/glitch.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          _renderShader(shader, image, size, canvas);
        } catch (e) {
          _log("ERROR in shader: $e");
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

    // Compute animated values if needed
    double opacity = settings.glitchSettings.opacity;
    double intensity = settings.glitchSettings.intensity;
    double frequency = settings.glitchSettings.frequency;
    double blockSize = settings.glitchSettings.blockSize;
    double horizontalSliceIntensity =
        settings.glitchSettings.horizontalSliceIntensity;
    double verticalSliceIntensity =
        settings.glitchSettings.verticalSliceIntensity;
    double time = settings.glitchSettings.effectAnimated ? animationValue : 0.0;

    if (settings.glitchSettings.effectAnimated) {
      if (enableShaderDebugLogs) {
        _log(
          "Glitch animation enabled, animationValue=${animationValue.toStringAsFixed(3)}, mode=${settings.glitchSettings.effectAnimOptions.mode}",
        );
      }
      final animManager = AnimationStateManager();

      // Apply animation based on the current animation mode
      if (settings.glitchSettings.effectAnimOptions.mode ==
          AnimationMode.pulse) {
        // Apply pulse mode with parameter locking

        // Animate opacity if unlocked
        if (!animManager.isParameterLocked(ParameterIds.glitchOpacity)) {
          double pulse = ShaderAnimationUtils.computePulseValue(
            settings.glitchSettings.effectAnimOptions,
            animationValue,
          );
          opacity = settings.glitchSettings.opacity * pulse;
          animManager.updateAnimatedValue(ParameterIds.glitchOpacity, opacity);
        } else {
          animManager.updateAnimatedValue(ParameterIds.glitchOpacity, opacity);
        }

        // Animate intensity if unlocked
        if (!animManager.isParameterLocked(ParameterIds.glitchIntensity)) {
          double pulse = ShaderAnimationUtils.computePulseValue(
            settings.glitchSettings.effectAnimOptions,
            animationValue,
          );
          intensity = settings.glitchSettings.intensity * pulse;
          animManager.updateAnimatedValue(
            ParameterIds.glitchIntensity,
            intensity,
          );
        } else {
          animManager.updateAnimatedValue(
            ParameterIds.glitchIntensity,
            intensity,
          );
        }

        // Animate frequency if unlocked
        if (!animManager.isParameterLocked(ParameterIds.glitchSpeed)) {
          double pulse = ShaderAnimationUtils.computePulseValue(
            settings.glitchSettings.effectAnimOptions,
            animationValue,
          );
          frequency = settings.glitchSettings.frequency * pulse;
          animManager.updateAnimatedValue(ParameterIds.glitchSpeed, frequency);
        } else {
          animManager.updateAnimatedValue(ParameterIds.glitchSpeed, frequency);
        }

        // Animate block size if unlocked
        if (!animManager.isParameterLocked(ParameterIds.glitchBlockSize)) {
          double pulse = ShaderAnimationUtils.computePulseValue(
            settings.glitchSettings.effectAnimOptions,
            animationValue,
          );
          blockSize = settings.glitchSettings.blockSize * pulse;
          animManager.updateAnimatedValue(
            ParameterIds.glitchBlockSize,
            blockSize,
          );
        } else {
          animManager.updateAnimatedValue(
            ParameterIds.glitchBlockSize,
            blockSize,
          );
        }

        // Animate horizontal slice intensity if unlocked
        if (!animManager.isParameterLocked(
          ParameterIds.glitchHorizontalSliceIntensity,
        )) {
          double pulse = ShaderAnimationUtils.computePulseValue(
            settings.glitchSettings.effectAnimOptions,
            animationValue,
          );
          horizontalSliceIntensity =
              settings.glitchSettings.horizontalSliceIntensity * pulse;
          animManager.updateAnimatedValue(
            ParameterIds.glitchHorizontalSliceIntensity,
            horizontalSliceIntensity,
          );
        } else {
          animManager.updateAnimatedValue(
            ParameterIds.glitchHorizontalSliceIntensity,
            horizontalSliceIntensity,
          );
        }

        // Animate vertical slice intensity if unlocked
        if (!animManager.isParameterLocked(
          ParameterIds.glitchVerticalSliceIntensity,
        )) {
          double pulse = ShaderAnimationUtils.computePulseValue(
            settings.glitchSettings.effectAnimOptions,
            animationValue,
          );
          verticalSliceIntensity =
              settings.glitchSettings.verticalSliceIntensity * pulse;
          animManager.updateAnimatedValue(
            ParameterIds.glitchVerticalSliceIntensity,
            verticalSliceIntensity,
          );
        } else {
          animManager.updateAnimatedValue(
            ParameterIds.glitchVerticalSliceIntensity,
            verticalSliceIntensity,
          );
        }
      } else {
        // Randomized animation mode with parameter locking

        // Animate opacity if unlocked
        if (!animManager.isParameterLocked(ParameterIds.glitchOpacity)) {
          opacity = ShaderAnimationUtils.computeRandomizedParameterValue(
            settings.glitchSettings.opacity,
            settings.glitchSettings.effectAnimOptions,
            animationValue,
            isLocked: animManager.isParameterLocked(ParameterIds.glitchOpacity),
            minValue: 0.0,
            maxValue: 1.0,
            parameterId: ParameterIds.glitchOpacity,
          );
          animManager.updateAnimatedValue(ParameterIds.glitchOpacity, opacity);
        } else {
          animManager.updateAnimatedValue(ParameterIds.glitchOpacity, opacity);
        }

        // Animate intensity if unlocked
        if (!animManager.isParameterLocked(ParameterIds.glitchIntensity)) {
          intensity = ShaderAnimationUtils.computeRandomizedParameterValue(
            settings.glitchSettings.intensity,
            settings.glitchSettings.effectAnimOptions,
            animationValue,
            isLocked: animManager.isParameterLocked(
              ParameterIds.glitchIntensity,
            ),
            minValue: 0.0,
            maxValue: 1.0,
            parameterId: ParameterIds.glitchIntensity,
          );
          animManager.updateAnimatedValue(
            ParameterIds.glitchIntensity,
            intensity,
          );
        } else {
          animManager.updateAnimatedValue(
            ParameterIds.glitchIntensity,
            intensity,
          );
        }

        // Animate frequency if unlocked
        if (!animManager.isParameterLocked(ParameterIds.glitchSpeed)) {
          frequency = ShaderAnimationUtils.computeRandomizedParameterValue(
            settings.glitchSettings.frequency,
            settings.glitchSettings.effectAnimOptions,
            animationValue,
            isLocked: animManager.isParameterLocked(ParameterIds.glitchSpeed),
            minValue: 0.0,
            maxValue: 3.0,
            parameterId: ParameterIds.glitchSpeed,
          );
          animManager.updateAnimatedValue(ParameterIds.glitchSpeed, frequency);
        } else {
          animManager.updateAnimatedValue(ParameterIds.glitchSpeed, frequency);
        }

        // Animate block size if unlocked
        if (!animManager.isParameterLocked(ParameterIds.glitchBlockSize)) {
          blockSize = ShaderAnimationUtils.computeRandomizedParameterValue(
            settings.glitchSettings.blockSize,
            settings.glitchSettings.effectAnimOptions,
            animationValue,
            isLocked: animManager.isParameterLocked(
              ParameterIds.glitchBlockSize,
            ),
            minValue: 0.0,
            maxValue: 0.5,
            parameterId: ParameterIds.glitchBlockSize,
          );
          animManager.updateAnimatedValue(
            ParameterIds.glitchBlockSize,
            blockSize,
          );
        } else {
          animManager.updateAnimatedValue(
            ParameterIds.glitchBlockSize,
            blockSize,
          );
        }

        // Animate horizontal slice intensity if unlocked
        if (!animManager.isParameterLocked(
          ParameterIds.glitchHorizontalSliceIntensity,
        )) {
          horizontalSliceIntensity =
              ShaderAnimationUtils.computeRandomizedParameterValue(
                settings.glitchSettings.horizontalSliceIntensity,
                settings.glitchSettings.effectAnimOptions,
                animationValue,
                isLocked: animManager.isParameterLocked(
                  ParameterIds.glitchHorizontalSliceIntensity,
                ),
                minValue: 0.0,
                maxValue: 1.0,
                parameterId: ParameterIds.glitchHorizontalSliceIntensity,
              );
          animManager.updateAnimatedValue(
            ParameterIds.glitchHorizontalSliceIntensity,
            horizontalSliceIntensity,
          );
        } else {
          animManager.updateAnimatedValue(
            ParameterIds.glitchHorizontalSliceIntensity,
            horizontalSliceIntensity,
          );
        }

        // Animate vertical slice intensity if unlocked
        if (!animManager.isParameterLocked(
          ParameterIds.glitchVerticalSliceIntensity,
        )) {
          verticalSliceIntensity =
              ShaderAnimationUtils.computeRandomizedParameterValue(
                settings.glitchSettings.verticalSliceIntensity,
                settings.glitchSettings.effectAnimOptions,
                animationValue,
                isLocked: animManager.isParameterLocked(
                  ParameterIds.glitchVerticalSliceIntensity,
                ),
                minValue: 0.0,
                maxValue: 1.0,
                parameterId: ParameterIds.glitchVerticalSliceIntensity,
              );
          animManager.updateAnimatedValue(
            ParameterIds.glitchVerticalSliceIntensity,
            verticalSliceIntensity,
          );
        } else {
          animManager.updateAnimatedValue(
            ParameterIds.glitchVerticalSliceIntensity,
            verticalSliceIntensity,
          );
        }
      }
    } else {
      // Clear animated values when animation is disabled
      final animManager = AnimationStateManager();
      animManager.clearAnimatedValue(ParameterIds.glitchOpacity);
      animManager.clearAnimatedValue(ParameterIds.glitchIntensity);
      animManager.clearAnimatedValue(ParameterIds.glitchSpeed);
      animManager.clearAnimatedValue(ParameterIds.glitchBlockSize);
      animManager.clearAnimatedValue(
        ParameterIds.glitchHorizontalSliceIntensity,
      );
      animManager.clearAnimatedValue(ParameterIds.glitchVerticalSliceIntensity);
    }

    // Set uniforms in the correct order matching the shader
    shader.setFloat(0, time); // uTime
    shader.setFloat(1, size.width); // uResolution.x
    shader.setFloat(2, size.height); // uResolution.y
    shader.setFloat(3, opacity); // uOpacity
    shader.setFloat(4, intensity); // uIntensity
    shader.setFloat(5, frequency); // uFrequency
    shader.setFloat(6, blockSize); // uBlockSize
    shader.setFloat(7, horizontalSliceIntensity); // uHorizontalSliceIntensity
    shader.setFloat(8, verticalSliceIntensity); // uVerticalSliceIntensity
    shader.setFloat(9, isTextContent ? 1.0 : 0.0); // uIsTextContent

    // Draw with shader
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  void _fallbackRender(ui.Image image, Size size, Canvas canvas) {
    // Fall back to drawing original image
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );
  }
}

// Helper function to apply glitch effect
Widget applyGlitchEffect({
  required Widget child,
  required ShaderSettings settings,
  required double animationValue,
  bool preserveTransparency = false,
  bool isTextContent = false,
}) {
  return GlitchShader(
    settings: settings,
    animationValue: animationValue,
    child: child,
    preserveTransparency: preserveTransparency,
    isTextContent: isTextContent,
  );
}
