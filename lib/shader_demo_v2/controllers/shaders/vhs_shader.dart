import 'dart:developer' as developer;
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/animation_options.dart';
import '../../models/effect_settings.dart';
import '../../utils/animation_utils.dart';
import '../animation_state_manager.dart';
import 'debug_flags.dart';

/// Custom shader widget for VHS effect
class VHSShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;
  final String _logTag = 'VHSShader';

  // Log throttling
  static DateTime _lastLogTime = DateTime.now().subtract(
    const Duration(seconds: 1),
  );
  static const Duration _logThrottleInterval = Duration(milliseconds: 1000);
  static String _lastLogMessage = "";

  const VHSShader({
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
        "Building VHSShader with opacity=${settings.vhsSettings.opacity.toStringAsFixed(2)}",
      );
    }

    // Skip if effect is disabled or opacity is too low
    if (!settings.vhsSettings.shouldApplyEffect) {
      return child;
    }

    // Use ShaderBuilder with AnimatedSampler
    return ShaderBuilder(assetKey: 'assets/shaders/vhs.frag', (
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

    final vhsSettings = settings.vhsSettings;

    double time = 0.0;
    double opacity = vhsSettings.opacity;
    double noiseIntensity = vhsSettings.noiseIntensity;
    double fieldLines = vhsSettings.fieldLines;
    double horizontalWaveStrength = vhsSettings.horizontalWaveStrength;
    double horizontalWaveScreenSize = vhsSettings.horizontalWaveScreenSize;
    double horizontalWaveVerticalSize = vhsSettings.horizontalWaveVerticalSize;
    double dottedNoiseStrength = vhsSettings.dottedNoiseStrength;
    double horizontalDistortionStrength = vhsSettings.horizontalDistortionStrength;

    final animManager = AnimationStateManager();

    if (vhsSettings.effectAnimated) {
      final AnimationOptions animOptions = vhsSettings.effectAnimOptions;
      final bool isPulseMode = animOptions.mode == AnimationMode.pulse;

      // Use controller progress for time and dial sensitivity with speed slider.
      final double normalizedSpeed = animOptions.speed.clamp(0.0, 1.0);
      final double timeScale = ui.lerpDouble(0.0, 3.0, normalizedSpeed)!;
      time = animationValue * math.pi * 2.0 * timeScale;

      if (!animManager.isParameterLocked(ParameterIds.vhsOpacity)) {
        if (isPulseMode) {
          final pulse = ShaderAnimationUtils.computePulseValue(
            animOptions,
            animationValue,
          );
          opacity = vhsSettings.opacity * pulse;
        } else {
          opacity = ShaderAnimationUtils.computeRandomizedParameterValue(
            vhsSettings.opacity,
            animOptions,
            animationValue,
            isLocked: false,
            minValue: 0.05,
            maxValue: 1.0,
            parameterId: ParameterIds.vhsOpacity,
          );
        }
        animManager.updateAnimatedValue(ParameterIds.vhsOpacity, opacity);
      } else {
        animManager.updateAnimatedValue(ParameterIds.vhsOpacity, opacity);
      }

      if (!animManager.isParameterLocked(ParameterIds.vhsNoiseIntensity)) {
        if (isPulseMode) {
          final pulse = ShaderAnimationUtils.computePulseValue(
            animOptions,
            animationValue,
          );
          noiseIntensity = vhsSettings.noiseIntensity * pulse;
        } else {
          noiseIntensity = ShaderAnimationUtils.computeRandomizedParameterValue(
            vhsSettings.noiseIntensity,
            animOptions,
            animationValue,
            isLocked: false,
            minValue: 0.0,
            maxValue: 1.0,
            parameterId: ParameterIds.vhsNoiseIntensity,
          );
        }
        animManager.updateAnimatedValue(
          ParameterIds.vhsNoiseIntensity,
          noiseIntensity,
        );
      } else {
        animManager.updateAnimatedValue(
          ParameterIds.vhsNoiseIntensity,
          noiseIntensity,
        );
      }

      if (!animManager.isParameterLocked(ParameterIds.vhsFieldLines)) {
        if (!isPulseMode) {
          fieldLines = ShaderAnimationUtils.computeRandomizedParameterValue(
            vhsSettings.fieldLines,
            animOptions,
            animationValue,
            isLocked: false,
            minValue: 0.0,
            maxValue: 400.0,
            parameterId: ParameterIds.vhsFieldLines,
          );
        }
        animManager.updateAnimatedValue(
          ParameterIds.vhsFieldLines,
          fieldLines,
        );
      } else {
        animManager.updateAnimatedValue(
          ParameterIds.vhsFieldLines,
          fieldLines,
        );
      }

      if (!animManager.isParameterLocked(ParameterIds.vhsHorizontalWaveStrength)) {
        if (isPulseMode) {
          final pulse = ShaderAnimationUtils.computePulseValue(
            animOptions,
            animationValue,
          );
          horizontalWaveStrength = vhsSettings.horizontalWaveStrength * pulse;
        } else {
          horizontalWaveStrength = ShaderAnimationUtils.computeRandomizedParameterValue(
            vhsSettings.horizontalWaveStrength,
            animOptions,
            animationValue,
            isLocked: false,
            minValue: 0.0,
            maxValue: 0.5,
            parameterId: ParameterIds.vhsHorizontalWaveStrength,
          );
        }
        animManager.updateAnimatedValue(
          ParameterIds.vhsHorizontalWaveStrength,
          horizontalWaveStrength,
        );
      } else {
        animManager.updateAnimatedValue(
          ParameterIds.vhsHorizontalWaveStrength,
          horizontalWaveStrength,
        );
      }

      if (!animManager.isParameterLocked(ParameterIds.vhsHorizontalWaveScreenSize)) {
        if (!isPulseMode) {
          horizontalWaveScreenSize =
              ShaderAnimationUtils.computeRandomizedParameterValue(
            vhsSettings.horizontalWaveScreenSize,
            animOptions,
            animationValue,
            isLocked: false,
            minValue: 10.0,
            maxValue: 200.0,
            parameterId: ParameterIds.vhsHorizontalWaveScreenSize,
          );
        }
        animManager.updateAnimatedValue(
          ParameterIds.vhsHorizontalWaveScreenSize,
          horizontalWaveScreenSize,
        );
      } else {
        animManager.updateAnimatedValue(
          ParameterIds.vhsHorizontalWaveScreenSize,
          horizontalWaveScreenSize,
        );
      }

      if (!animManager.isParameterLocked(ParameterIds.vhsHorizontalWaveVerticalSize)) {
        if (!isPulseMode) {
          horizontalWaveVerticalSize =
              ShaderAnimationUtils.computeRandomizedParameterValue(
            vhsSettings.horizontalWaveVerticalSize,
            animOptions,
            animationValue,
            isLocked: false,
            minValue: 10.0,
            maxValue: 300.0,
            parameterId: ParameterIds.vhsHorizontalWaveVerticalSize,
          );
        }
        animManager.updateAnimatedValue(
          ParameterIds.vhsHorizontalWaveVerticalSize,
          horizontalWaveVerticalSize,
        );
      } else {
        animManager.updateAnimatedValue(
          ParameterIds.vhsHorizontalWaveVerticalSize,
          horizontalWaveVerticalSize,
        );
      }

      if (!animManager.isParameterLocked(ParameterIds.vhsDottedNoiseStrength)) {
        if (isPulseMode) {
          final pulse = ShaderAnimationUtils.computePulseValue(
            animOptions,
            animationValue,
          );
          dottedNoiseStrength = vhsSettings.dottedNoiseStrength * pulse;
        } else {
          dottedNoiseStrength = ShaderAnimationUtils.computeRandomizedParameterValue(
            vhsSettings.dottedNoiseStrength,
            animOptions,
            animationValue,
            isLocked: false,
            minValue: 0.0,
            maxValue: 1.0,
            parameterId: ParameterIds.vhsDottedNoiseStrength,
          );
        }
        animManager.updateAnimatedValue(
          ParameterIds.vhsDottedNoiseStrength,
          dottedNoiseStrength,
        );
      } else {
        animManager.updateAnimatedValue(
          ParameterIds.vhsDottedNoiseStrength,
          dottedNoiseStrength,
        );
      }

      if (!animManager.isParameterLocked(ParameterIds.vhsHorizontalDistortionStrength)) {
        if (isPulseMode) {
          final pulse = ShaderAnimationUtils.computePulseValue(
            animOptions,
            animationValue,
          );
          horizontalDistortionStrength =
              vhsSettings.horizontalDistortionStrength * pulse;
        } else {
          horizontalDistortionStrength =
              ShaderAnimationUtils.computeRandomizedParameterValue(
            vhsSettings.horizontalDistortionStrength,
            animOptions,
            animationValue,
            isLocked: false,
            minValue: 0.0,
            maxValue: 0.02,
            parameterId: ParameterIds.vhsHorizontalDistortionStrength,
          );
        }
        animManager.updateAnimatedValue(
          ParameterIds.vhsHorizontalDistortionStrength,
          horizontalDistortionStrength,
        );
      } else {
        animManager.updateAnimatedValue(
          ParameterIds.vhsHorizontalDistortionStrength,
          horizontalDistortionStrength,
        );
      }
    } else {
      // Clear animated values when animation is disabled so locks/UI remain in sync.
      animManager.clearAnimatedValue(ParameterIds.vhsOpacity);
      animManager.clearAnimatedValue(ParameterIds.vhsNoiseIntensity);
      animManager.clearAnimatedValue(ParameterIds.vhsFieldLines);
      animManager.clearAnimatedValue(ParameterIds.vhsHorizontalWaveStrength);
      animManager.clearAnimatedValue(ParameterIds.vhsHorizontalWaveScreenSize);
      animManager.clearAnimatedValue(ParameterIds.vhsHorizontalWaveVerticalSize);
      animManager.clearAnimatedValue(ParameterIds.vhsDottedNoiseStrength);
      animManager.clearAnimatedValue(
        ParameterIds.vhsHorizontalDistortionStrength,
      );
    }

    // Set uniforms in the correct order matching the shader
    shader.setFloat(0, time); // uTime
    shader.setFloat(1, size.width); // uResolution.x
    shader.setFloat(2, size.height); // uResolution.y
    shader.setFloat(3, opacity); // uOpacity
    shader.setFloat(4, noiseIntensity); // uNoiseIntensity
    shader.setFloat(5, fieldLines); // uFieldLines
    shader.setFloat(6, horizontalWaveStrength); // uHorizontalWaveStrength
    shader.setFloat(7, horizontalWaveScreenSize); // uHorizontalWaveScreenSize
    shader.setFloat(8, horizontalWaveVerticalSize); // uHorizontalWaveVerticalSize
    shader.setFloat(9, dottedNoiseStrength); // uDottedNoiseStrength
    shader.setFloat(
      10,
      horizontalDistortionStrength,
    ); // uHorizontalDistortionStrength
    shader.setFloat(11, isTextContent ? 1.0 : 0.0); // uIsTextContent

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

// Helper function to apply VHS effect
Widget applyVHSEffect({
  required Widget child,
  required ShaderSettings settings,
  required double animationValue,
  bool preserveTransparency = false,
  bool isTextContent = false,
}) {
  return VHSShader(
    settings: settings,
    animationValue: animationValue,
    child: child,
    preserveTransparency: preserveTransparency,
    isTextContent: isTextContent,
  );
}
