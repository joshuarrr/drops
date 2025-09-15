// Removed unused math import
import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../models/animation_options.dart';
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

    // Use the exact same pattern as working shaders
    return ShaderBuilder(assetKey: 'assets/shaders/sketch_effect.frag', (
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

    // Set uniforms in the correct order matching the shader
    shader.setFloat(
      0,
      settings.sketchSettings.sketchAnimated ? animationValue : 0.0,
    ); // uTime
    shader.setFloat(1, size.width); // uResolution.x
    shader.setFloat(2, size.height); // uResolution.y
    shader.setFloat(3, settings.sketchSettings.opacity); // uOpacity
    shader.setFloat(4, settings.sketchSettings.imageOpacity); // uImageOpacity
    shader.setFloat(5, settings.sketchSettings.hatchYOffset); // uHatchYOffset
    shader.setFloat(6, settings.sketchSettings.lumThreshold1); // uLumThreshold1
    shader.setFloat(7, settings.sketchSettings.lumThreshold2); // uLumThreshold2
    shader.setFloat(8, settings.sketchSettings.lumThreshold3); // uLumThreshold3
    shader.setFloat(9, settings.sketchSettings.lumThreshold4); // uLumThreshold4
    shader.setFloat(10, settings.sketchSettings.lineSpacing); // uLineSpacing
    shader.setFloat(
      11,
      settings.sketchSettings.lineThickness,
    ); // uLineThickness
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
