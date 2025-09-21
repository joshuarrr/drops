// Removed unused math import
import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../utils/animation_utils.dart';
import '../animation_state_manager.dart';
// Removed unused debug_flags.dart import

/// Controls debug logging for shaders (external reference)
bool enableShaderDebugLogs = false;

/// Custom sketch effect shader widget
class SketchEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;
  final String _logTag = 'SketchEffectShader';

  // Log throttling - using static variables for efficient throttling
  static DateTime _lastLogTime = DateTime.now().subtract(
    const Duration(seconds: 1),
  );
  static const Duration _logThrottleInterval = Duration(milliseconds: 1000);
  static String _lastLogMessage = "";

  const SketchEffectShader({
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

    // Skip if this is the same message that was just logged
    if (message == _lastLogMessage) return;

    // Throttle logs to avoid excessive output
    final now = DateTime.now();
    if (now.difference(_lastLogTime) < _logThrottleInterval) {
      return;
    }

    _lastLogTime = now;
    _lastLogMessage = message;

    developer.log(message, name: _logTag);
    debugPrint('[$_logTag] $message');
  }

  @override
  Widget build(BuildContext context) {
    if (enableShaderDebugLogs) {
      _log(
        "Building SketchEffectShader with opacity=${settings.sketchSettings.opacity.toStringAsFixed(2)} (animated: ${settings.sketchSettings.sketchAnimated})",
      );
    }

    // Skip if sketch is disabled or opacity is too low
    if (!settings.sketchSettings.shouldApplySketch) {
      return child;
    }

    // Get animation state manager
    final animManager = AnimationStateManager();

    // Use the exact same pattern as working shaders
    return ShaderBuilder(assetKey: 'assets/shaders/sketch_effect.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          // Apply animations to parameters if enabled
          if (settings.sketchSettings.sketchAnimated) {
            _applyAnimations(animManager);
          } else {
            // Clear animated values when animation is disabled
            _clearAnimations(animManager);
          }

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

    // Get animation state manager to check for animated values
    final animManager = AnimationStateManager();

    // Set uniforms in the correct order matching the shader
    // Use animated values if available, otherwise use the settings values
    final double opacity =
        animManager.getCurrentAnimatedValue(ParameterIds.sketchOpacity) ??
        settings.sketchSettings.opacity;

    final double imageOpacity =
        animManager.getCurrentAnimatedValue(ParameterIds.sketchImageOpacity) ??
        settings.sketchSettings.imageOpacity;

    final double hatchYOffset =
        animManager.getCurrentAnimatedValue(ParameterIds.sketchHatchYOffset) ??
        settings.sketchSettings.hatchYOffset;

    final double lumThreshold1 =
        animManager.getCurrentAnimatedValue(ParameterIds.sketchLumThreshold1) ??
        settings.sketchSettings.lumThreshold1;

    final double lumThreshold2 =
        animManager.getCurrentAnimatedValue(ParameterIds.sketchLumThreshold2) ??
        settings.sketchSettings.lumThreshold2;

    final double lumThreshold3 =
        animManager.getCurrentAnimatedValue(ParameterIds.sketchLumThreshold3) ??
        settings.sketchSettings.lumThreshold3;

    final double lumThreshold4 =
        animManager.getCurrentAnimatedValue(ParameterIds.sketchLumThreshold4) ??
        settings.sketchSettings.lumThreshold4;

    final double lineSpacing =
        animManager.getCurrentAnimatedValue(ParameterIds.sketchLineSpacing) ??
        settings.sketchSettings.lineSpacing;

    final double lineThickness =
        animManager.getCurrentAnimatedValue(ParameterIds.sketchLineThickness) ??
        settings.sketchSettings.lineThickness;

    // Set uniforms in the correct order matching the shader
    shader.setFloat(
      0,
      settings.sketchSettings.sketchAnimated ? animationValue : 0.0,
    ); // uTime
    shader.setFloat(1, size.width); // uResolution.x
    shader.setFloat(2, size.height); // uResolution.y
    shader.setFloat(3, opacity); // uOpacity
    shader.setFloat(4, imageOpacity); // uImageOpacity
    shader.setFloat(5, hatchYOffset); // uHatchYOffset
    shader.setFloat(6, lumThreshold1); // uLumThreshold1
    shader.setFloat(7, lumThreshold2); // uLumThreshold2
    shader.setFloat(8, lumThreshold3); // uLumThreshold3
    shader.setFloat(9, lumThreshold4); // uLumThreshold4
    shader.setFloat(10, lineSpacing); // uLineSpacing
    shader.setFloat(11, lineThickness); // uLineThickness
    shader.setFloat(12, isTextContent ? 1.0 : 0.0); // uIsTextContent

    // Draw with shader using exact same approach as other shaders
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

  // Apply animations to parameters based on lock state
  void _applyAnimations(AnimationStateManager animManager) {
    // Get current animation options
    final animOptions = settings.sketchSettings.sketchAnimOptions;

    // Opacity animation
    if (!animManager.isParameterLocked(ParameterIds.sketchOpacity)) {
      final double pulse = ShaderAnimationUtils.computePulseValue(
        animOptions,
        animationValue,
      );
      final double animatedValue =
          settings.sketchSettings.opacityRange.userMin +
          (settings.sketchSettings.opacityRange.userMax -
                  settings.sketchSettings.opacityRange.userMin) *
              pulse;
      animManager.updateAnimatedValue(
        ParameterIds.sketchOpacity,
        animatedValue,
      );
    } else {
      animManager.updateAnimatedValue(
        ParameterIds.sketchOpacity,
        settings.sketchSettings.opacity,
      );
    }

    // Image opacity animation
    if (!animManager.isParameterLocked(ParameterIds.sketchImageOpacity)) {
      final double pulse = ShaderAnimationUtils.computePulseValue(
        animOptions,
        animationValue,
      );
      final double animatedValue =
          settings.sketchSettings.imageOpacityRange.userMin +
          (settings.sketchSettings.imageOpacityRange.userMax -
                  settings.sketchSettings.imageOpacityRange.userMin) *
              pulse;
      animManager.updateAnimatedValue(
        ParameterIds.sketchImageOpacity,
        animatedValue,
      );
    } else {
      animManager.updateAnimatedValue(
        ParameterIds.sketchImageOpacity,
        settings.sketchSettings.imageOpacity,
      );
    }

    // Threshold animations - Threshold 1
    if (!animManager.isParameterLocked(ParameterIds.sketchLumThreshold1)) {
      final double pulse = ShaderAnimationUtils.computePulseValue(
        animOptions,
        animationValue,
      );
      final double animatedValue =
          settings.sketchSettings.lumThreshold1Range.userMin +
          (settings.sketchSettings.lumThreshold1Range.userMax -
                  settings.sketchSettings.lumThreshold1Range.userMin) *
              pulse;
      animManager.updateAnimatedValue(
        ParameterIds.sketchLumThreshold1,
        animatedValue,
      );
    } else {
      animManager.updateAnimatedValue(
        ParameterIds.sketchLumThreshold1,
        settings.sketchSettings.lumThreshold1,
      );
    }

    // Threshold 2
    if (!animManager.isParameterLocked(ParameterIds.sketchLumThreshold2)) {
      final double pulse = ShaderAnimationUtils.computePulseValue(
        animOptions,
        animationValue,
      );
      final double animatedValue =
          settings.sketchSettings.lumThreshold2Range.userMin +
          (settings.sketchSettings.lumThreshold2Range.userMax -
                  settings.sketchSettings.lumThreshold2Range.userMin) *
              pulse;
      animManager.updateAnimatedValue(
        ParameterIds.sketchLumThreshold2,
        animatedValue,
      );
    } else {
      animManager.updateAnimatedValue(
        ParameterIds.sketchLumThreshold2,
        settings.sketchSettings.lumThreshold2,
      );
    }

    // Threshold 3
    if (!animManager.isParameterLocked(ParameterIds.sketchLumThreshold3)) {
      final double pulse = ShaderAnimationUtils.computePulseValue(
        animOptions,
        animationValue,
      );
      final double animatedValue =
          settings.sketchSettings.lumThreshold3Range.userMin +
          (settings.sketchSettings.lumThreshold3Range.userMax -
                  settings.sketchSettings.lumThreshold3Range.userMin) *
              pulse;
      animManager.updateAnimatedValue(
        ParameterIds.sketchLumThreshold3,
        animatedValue,
      );
    } else {
      animManager.updateAnimatedValue(
        ParameterIds.sketchLumThreshold3,
        settings.sketchSettings.lumThreshold3,
      );
    }

    // Threshold 4
    if (!animManager.isParameterLocked(ParameterIds.sketchLumThreshold4)) {
      final double pulse = ShaderAnimationUtils.computePulseValue(
        animOptions,
        animationValue,
      );
      final double animatedValue =
          settings.sketchSettings.lumThreshold4Range.userMin +
          (settings.sketchSettings.lumThreshold4Range.userMax -
                  settings.sketchSettings.lumThreshold4Range.userMin) *
              pulse;
      animManager.updateAnimatedValue(
        ParameterIds.sketchLumThreshold4,
        animatedValue,
      );
    } else {
      animManager.updateAnimatedValue(
        ParameterIds.sketchLumThreshold4,
        settings.sketchSettings.lumThreshold4,
      );
    }

    // Line spacing animation
    if (!animManager.isParameterLocked(ParameterIds.sketchLineSpacing)) {
      final double pulse = ShaderAnimationUtils.computePulseValue(
        animOptions,
        animationValue,
      );
      final double animatedValue =
          settings.sketchSettings.lineSpacingRange.userMin +
          (settings.sketchSettings.lineSpacingRange.userMax -
                  settings.sketchSettings.lineSpacingRange.userMin) *
              pulse;
      animManager.updateAnimatedValue(
        ParameterIds.sketchLineSpacing,
        animatedValue,
      );
    } else {
      animManager.updateAnimatedValue(
        ParameterIds.sketchLineSpacing,
        settings.sketchSettings.lineSpacing,
      );
    }

    // Line thickness animation
    if (!animManager.isParameterLocked(ParameterIds.sketchLineThickness)) {
      final double pulse = ShaderAnimationUtils.computePulseValue(
        animOptions,
        animationValue,
      );
      final double animatedValue =
          settings.sketchSettings.lineThicknessRange.userMin +
          (settings.sketchSettings.lineThicknessRange.userMax -
                  settings.sketchSettings.lineThicknessRange.userMin) *
              pulse;
      animManager.updateAnimatedValue(
        ParameterIds.sketchLineThickness,
        animatedValue,
      );
    } else {
      animManager.updateAnimatedValue(
        ParameterIds.sketchLineThickness,
        settings.sketchSettings.lineThickness,
      );
    }

    // Hatch Y offset animation
    if (!animManager.isParameterLocked(ParameterIds.sketchHatchYOffset)) {
      // Use pulse animation like other parameters
      final double pulse = ShaderAnimationUtils.computePulseValue(
        animOptions,
        animationValue,
      );
      final double animatedValue =
          settings.sketchSettings.hatchYOffsetRange.userMin +
          (settings.sketchSettings.hatchYOffsetRange.userMax -
                  settings.sketchSettings.hatchYOffsetRange.userMin) *
              pulse;
      animManager.updateAnimatedValue(
        ParameterIds.sketchHatchYOffset,
        animatedValue,
      );
    } else {
      animManager.updateAnimatedValue(
        ParameterIds.sketchHatchYOffset,
        settings.sketchSettings.hatchYOffset,
      );
    }
  }

  // Clear all animated values when animation is disabled
  void _clearAnimations(AnimationStateManager animManager) {
    animManager.clearAnimatedValue(ParameterIds.sketchOpacity);
    animManager.clearAnimatedValue(ParameterIds.sketchImageOpacity);
    animManager.clearAnimatedValue(ParameterIds.sketchLumThreshold1);
    animManager.clearAnimatedValue(ParameterIds.sketchLumThreshold2);
    animManager.clearAnimatedValue(ParameterIds.sketchLumThreshold3);
    animManager.clearAnimatedValue(ParameterIds.sketchLumThreshold4);
    animManager.clearAnimatedValue(ParameterIds.sketchHatchYOffset);
    animManager.clearAnimatedValue(ParameterIds.sketchLineSpacing);
    animManager.clearAnimatedValue(ParameterIds.sketchLineThickness);
  }
}

// Helper function to apply sketch effect
Widget applySketchEffect({
  required Widget child,
  required ShaderSettings settings,
  required double animationValue,
  bool preserveTransparency = false,
  bool isTextContent = false,
}) {
  return SketchEffectShader(
    settings: settings,
    animationValue: animationValue,
    child: child,
    preserveTransparency: preserveTransparency,
    isTextContent: isTextContent,
  );
}
