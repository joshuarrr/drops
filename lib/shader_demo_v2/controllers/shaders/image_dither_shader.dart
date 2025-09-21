import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';

/// Controls debug logging for shaders (external reference)
bool enableShaderDebugLogs = false;

/// Image Dither shader widget
class ImageDitherShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue; // unused but kept for consistency
  final bool preserveTransparency;
  final bool isTextContent;
  final String _logTag = 'ImageDitherShader';

  // Log throttling
  static DateTime _lastLogTime = DateTime.now().subtract(
    const Duration(seconds: 1),
  );
  static const Duration _logThrottleInterval = Duration(milliseconds: 1000);
  static String _lastLogMessage = "";

  const ImageDitherShader({
    super.key,
    required this.child,
    required this.settings,
    required this.animationValue,
    this.preserveTransparency = false,
    this.isTextContent = false,
  });

  void _log(String message) {
    if (!enableShaderDebugLogs) return;
    if (message == _lastLogMessage) return;
    final now = DateTime.now();
    if (now.difference(_lastLogTime) < _logThrottleInterval) return;
    _lastLogTime = now;
    _lastLogMessage = message;
    developer.log(message, name: _logTag);
    debugPrint('[' + _logTag + '] ' + message);
  }

  @override
  Widget build(BuildContext context) {
    if (!settings.ditherSettings.shouldApplyEffect) {
      return child;
    }

    return ShaderBuilder(assetKey: 'assets/shaders/image_dither.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          shader.setImageSampler(0, image);

          // Uniforms: uTime, uResolution.x, uResolution.y, uType, uPixelSize, uColorSteps, uIsTextContent
          shader.setFloat(0, 0.0); // uTime (not used)
          shader.setFloat(1, size.width > 0.0 ? size.width : 1.0);
          shader.setFloat(2, size.height > 0.0 ? size.height : 1.0);
          shader.setFloat(3, settings.ditherSettings.type.clamp(0.0, 2.0));
          shader.setFloat(
            4,
            settings.ditherSettings.pixelSize.clamp(1.0, 64.0),
          );
          shader.setFloat(
            5,
            settings.ditherSettings.colorSteps.clamp(2.0, 64.0),
          );
          shader.setFloat(6, isTextContent ? 1.0 : 0.0);

          canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
        } catch (e) {
          _log('ERROR in dither shader: ' + e.toString());
          _fallbackRender(image, size, canvas);
        }
      }, child: this.child);
    }, child: child);
  }

  void _fallbackRender(ui.Image image, Size size, Canvas canvas) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );
  }
}

Widget applyDitherEffect({
  required Widget child,
  required ShaderSettings settings,
  required double animationValue,
  bool preserveTransparency = false,
  bool isTextContent = false,
}) {
  return ImageDitherShader(
    child: child,
    settings: settings,
    animationValue: animationValue,
    preserveTransparency: preserveTransparency,
    isTextContent: isTextContent,
  );
}
