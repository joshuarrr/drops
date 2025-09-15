import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../models/animation_options.dart';
import '../../utils/animation_utils.dart';
import '../animation_state_manager.dart';

/// Controls debug logging for shaders (external reference)
bool enableShaderDebugLogs = false;

/// Custom edge detection shader widget
class EdgeEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;
  final String _logTag = 'EdgeEffectShader';

  // Log throttling
  static DateTime _lastLogTime = DateTime.now().subtract(
    const Duration(seconds: 1),
  );
  static const Duration _logThrottleInterval = Duration(milliseconds: 1000);
  static String _lastLogMessage = "";

  EdgeEffectShader({
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
        "Building EdgeEffectShader with opacity=${settings.edgeSettings.opacity.toStringAsFixed(2)}",
      );
    }

    // Skip if effect is disabled or opacity is too low
    if (!settings.edgeSettings.shouldApplyEdge) {
      return child;
    }

    // Use ShaderBuilder with AnimatedSampler for the effect
    return ShaderBuilder(assetKey: 'assets/shaders/edge_effect.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          // Set the texture sampler first
          shader.setImageSampler(0, image);

          // Compute animated values if needed
          double opacity = settings.edgeSettings.opacity;
          double intensity = settings.edgeSettings.edgeIntensity;
          double thickness = settings.edgeSettings.edgeThickness;
          double edgeColor = settings.edgeSettings.edgeColor;

          if (settings.edgeSettings.edgeAnimated) {
            final animManager = AnimationStateManager();

            // Apply animation based on the current animation mode
            if (settings.edgeSettings.edgeAnimOptions.mode ==
                AnimationMode.pulse) {
              // Apply pulse mode with parameter locking

              // Animate opacity if unlocked
              if (!animManager.isParameterLocked(ParameterIds.edgeOpacity)) {
                double pulse = ShaderAnimationUtils.computePulseValue(
                  settings.edgeSettings.edgeAnimOptions,
                  animationValue,
                );
                opacity = settings.edgeSettings.opacity * pulse;
                animManager.updateAnimatedValue(
                  ParameterIds.edgeOpacity,
                  opacity,
                );
              } else {
                // If locked, keep the slider value
                animManager.updateAnimatedValue(
                  ParameterIds.edgeOpacity,
                  opacity,
                );
              }

              // Animate intensity if unlocked
              if (!animManager.isParameterLocked(ParameterIds.edgeIntensity)) {
                double pulse = ShaderAnimationUtils.computePulseValue(
                  settings.edgeSettings.edgeAnimOptions,
                  animationValue,
                );
                intensity = settings.edgeSettings.edgeIntensity * pulse;
                animManager.updateAnimatedValue(
                  ParameterIds.edgeIntensity,
                  intensity,
                );
              } else {
                // If locked, keep the slider value
                animManager.updateAnimatedValue(
                  ParameterIds.edgeIntensity,
                  intensity,
                );
              }

              // Animate thickness if unlocked
              if (!animManager.isParameterLocked(ParameterIds.edgeThickness)) {
                double pulse = ShaderAnimationUtils.computePulseValue(
                  settings.edgeSettings.edgeAnimOptions,
                  animationValue,
                );
                thickness = settings.edgeSettings.edgeThickness * pulse;
                animManager.updateAnimatedValue(
                  ParameterIds.edgeThickness,
                  thickness,
                );
              } else {
                // If locked, keep the slider value
                animManager.updateAnimatedValue(
                  ParameterIds.edgeThickness,
                  thickness,
                );
              }

              // Animate edge color if unlocked
              if (!animManager.isParameterLocked(ParameterIds.edgeColor)) {
                // For color, we'll oscillate through the hue range
                edgeColor =
                    (settings.edgeSettings.edgeColor + animationValue) % 1.0;
                animManager.updateAnimatedValue(
                  ParameterIds.edgeColor,
                  edgeColor,
                );
              } else {
                // If locked, keep the slider value
                animManager.updateAnimatedValue(
                  ParameterIds.edgeColor,
                  edgeColor,
                );
              }
            } else {
              // Randomized animation mode with parameter locking

              // Animate opacity if unlocked
              if (!animManager.isParameterLocked(ParameterIds.edgeOpacity)) {
                opacity = ShaderAnimationUtils.computeRandomizedParameterValue(
                  settings.edgeSettings.opacity,
                  settings.edgeSettings.edgeAnimOptions,
                  animationValue,
                  isLocked: animManager.isParameterLocked(
                    ParameterIds.edgeOpacity,
                  ),
                  minValue: 0.0,
                  maxValue: 1.0,
                  parameterId: ParameterIds.edgeOpacity,
                );
                animManager.updateAnimatedValue(
                  ParameterIds.edgeOpacity,
                  opacity,
                );
              } else {
                // If locked, keep the slider value
                animManager.updateAnimatedValue(
                  ParameterIds.edgeOpacity,
                  opacity,
                );
              }

              // Animate intensity if unlocked
              if (!animManager.isParameterLocked(ParameterIds.edgeIntensity)) {
                intensity =
                    ShaderAnimationUtils.computeRandomizedParameterValue(
                      settings.edgeSettings.edgeIntensity,
                      settings.edgeSettings.edgeAnimOptions,
                      animationValue,
                      isLocked: animManager.isParameterLocked(
                        ParameterIds.edgeIntensity,
                      ),
                      minValue: 0.0,
                      maxValue: 5.0,
                      parameterId: ParameterIds.edgeIntensity,
                    );
                animManager.updateAnimatedValue(
                  ParameterIds.edgeIntensity,
                  intensity,
                );
              } else {
                // If locked, keep the slider value
                animManager.updateAnimatedValue(
                  ParameterIds.edgeIntensity,
                  intensity,
                );
              }

              // Animate thickness if unlocked
              if (!animManager.isParameterLocked(ParameterIds.edgeThickness)) {
                thickness =
                    ShaderAnimationUtils.computeRandomizedParameterValue(
                      settings.edgeSettings.edgeThickness,
                      settings.edgeSettings.edgeAnimOptions,
                      animationValue,
                      isLocked: animManager.isParameterLocked(
                        ParameterIds.edgeThickness,
                      ),
                      minValue: 0.5,
                      maxValue: 5.0,
                      parameterId: ParameterIds.edgeThickness,
                    );
                animManager.updateAnimatedValue(
                  ParameterIds.edgeThickness,
                  thickness,
                );
              } else {
                // If locked, keep the slider value
                animManager.updateAnimatedValue(
                  ParameterIds.edgeThickness,
                  thickness,
                );
              }

              // Animate edge color if unlocked
              if (!animManager.isParameterLocked(ParameterIds.edgeColor)) {
                edgeColor =
                    ShaderAnimationUtils.computeRandomizedParameterValue(
                      settings.edgeSettings.edgeColor,
                      settings.edgeSettings.edgeAnimOptions,
                      animationValue,
                      isLocked: animManager.isParameterLocked(
                        ParameterIds.edgeColor,
                      ),
                      minValue: 0.0,
                      maxValue: 1.0,
                      parameterId: ParameterIds.edgeColor,
                    );
                animManager.updateAnimatedValue(
                  ParameterIds.edgeColor,
                  edgeColor,
                );
              } else {
                // If locked, keep the slider value
                animManager.updateAnimatedValue(
                  ParameterIds.edgeColor,
                  edgeColor,
                );
              }
            }
          } else {
            // Clear animated values when animation is disabled
            final animManager = AnimationStateManager();
            animManager.clearAnimatedValue(ParameterIds.edgeOpacity);
            animManager.clearAnimatedValue(ParameterIds.edgeIntensity);
            animManager.clearAnimatedValue(ParameterIds.edgeThickness);
            animManager.clearAnimatedValue(ParameterIds.edgeColor);
          }

          // Set uniforms for the shader
          // CRITICAL FIX: Ensure size values are never zero to prevent shader issues
          shader.setFloat(
            0,
            settings.edgeSettings.edgeAnimated ? animationValue : 0.0,
          ); // uTime
          shader.setFloat(
            1,
            size.width > 0.0 ? size.width : 1.0,
          ); // uResolution.x
          shader.setFloat(
            2,
            size.height > 0.0 ? size.height : 1.0,
          ); // uResolution.y
          shader.setFloat(3, opacity.clamp(0.0, 1.0)); // uOpacity
          shader.setFloat(4, intensity.clamp(0.0, 5.0)); // uEdgeIntensity
          shader.setFloat(5, thickness.clamp(0.5, 5.0)); // uEdgeThickness
          shader.setFloat(6, edgeColor.clamp(0.0, 1.0)); // uEdgeColor
          shader.setFloat(7, isTextContent ? 1.0 : 0.0); // uIsTextContent

          // Draw with the shader, ensuring it covers the full area
          canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
        } catch (e) {
          _log("ERROR in shader: $e");
          // Fall back to drawing the original image
          _fallbackRender(image, size, canvas);
        }
      }, child: this.child);
    }, child: child);
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

// Helper function to apply edge effect
Widget applyEdgeEffect({
  required Widget child,
  required ShaderSettings settings,
  required double animationValue,
  bool preserveTransparency = false,
  bool isTextContent = false,
}) {
  return EdgeEffectShader(
    settings: settings,
    animationValue: animationValue,
    child: child,
    preserveTransparency: preserveTransparency,
    isTextContent: isTextContent,
  );
}
