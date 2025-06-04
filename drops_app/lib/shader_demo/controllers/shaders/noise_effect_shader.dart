import 'dart:math' as math;
import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../models/animation_options.dart';
import '../../utils/animation_utils.dart';
import 'debug_flags.dart'; // Import the shared debug flag

/// Controls debug logging for shaders (external reference)
bool enableShaderDebugLogs = true;

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

  // Memory management for animated shaders
  static bool _isPresetSaving = false;
  static int _activeShaderCount = 0;
  static const int _maxActiveShaders = 3;

  const NoiseEffectShader({
    super.key,
    required this.child,
    required this.settings,
    required this.animationValue,
    this.preserveTransparency = false,
    this.isTextContent = false,
  });

  // Static method to indicate preset saving is in progress
  static void setPresetSaving(bool saving) {
    _isPresetSaving = saving;
    if (saving) {
      _logStatic("Preset saving started - limiting shader instances");
    } else {
      _logStatic("Preset saving ended - normal shader operation");
    }
  }

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

  // Static log function with different name
  static void _logStatic(String message) {
    if (!enableShaderDebugLogs) return;
    developer.log(message, name: 'NoiseEffectShader');
    debugPrint('[NoiseEffectShader] $message');
  }

  @override
  Widget build(BuildContext context) {
    // Memory management: limit shader instances during preset saving
    if (_isPresetSaving && settings.noiseSettings.noiseAnimated) {
      _activeShaderCount++;
      if (_activeShaderCount > _maxActiveShaders) {
        _log("Memory protection: skipping animated shader during preset save");
        // Return a static version during preset saving to prevent memory overflow
        return _buildStaticShader();
      }
    }

    if (enableShaderDebugLogs) {
      _log(
        "Building NoiseEffectShader with scale=${settings.noiseSettings.noiseScale.toStringAsFixed(2)}, wave=${settings.noiseSettings.waveAmount.toStringAsFixed(3)} (animated: ${settings.noiseSettings.noiseAnimated})",
      );
    }

    // During preset saving, force static mode to prevent memory issues
    final bool forceStatic =
        _isPresetSaving && settings.noiseSettings.noiseAnimated;

    if (forceStatic) {
      _log("Forcing static mode during preset save to prevent memory leak");
      return _buildStaticShader();
    }

    return _buildAnimatedShader();
  }

  Widget _buildAnimatedShader() {
    // Simplified approach using AnimatedSampler with ShaderBuilder
    return ShaderBuilder(assetKey: 'assets/shaders/noise_effect.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          _renderShader(shader, image, size, canvas);
        } catch (e) {
          _log("ERROR in animated shader: $e");
          _fallbackRender(image, size, canvas);
        } finally {
          // Memory cleanup
          if (_isPresetSaving) {
            _activeShaderCount = (_activeShaderCount - 1).clamp(0, 100);
          }
        }
      }, child: this.child);
    }, child: child);
  }

  Widget _buildStaticShader() {
    // Build a static version without AnimatedSampler for memory efficiency
    return ShaderBuilder(assetKey: 'assets/shaders/noise_effect.frag', (
      context,
      shader,
      child,
    ) {
      // Use a simpler StatelessWidget that doesn't accumulate AnimatedSampler instances
      return CustomPaint(
        painter: _NoiseStaticPainter(
          shader: shader,
          settings: settings,
          animationValue: animationValue,
          preserveTransparency: preserveTransparency,
          isTextContent: isTextContent,
        ),
        child: child,
      );
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

    double colorIntensity = settings.noiseSettings.colorIntensity;
    double waveAmount = settings.noiseSettings.waveAmount;

    // Compute animation values if animation is enabled
    if (settings.noiseSettings.noiseAnimated) {
      if (settings.noiseSettings.noiseAnimOptions.mode == AnimationMode.pulse) {
        // Simplified pulse animation - use raw animationValue to avoid memory issues
        timeValue = animationValue;

        // Create smooth pulse with optimized calculation (avoiding complex speed mapping)
        final double pulseTime =
            animationValue *
            settings.noiseSettings.noiseAnimOptions.speed *
            4.0;
        final double pulse = (math.sin(pulseTime * math.pi) * 0.5 + 0.5).abs();

        // Apply pulse to all effect parameters
        noiseSpeed = settings.noiseSettings.noiseSpeed * pulse;
        colorIntensity = settings.noiseSettings.colorIntensity * pulse;
        waveAmount = settings.noiseSettings.waveAmount * pulse;
      } else {
        // For non-pulse modes, use the standard animation utilities
        final double animValue = ShaderAnimationUtils.computeAnimatedValue(
          settings.noiseSettings.noiseAnimOptions,
          animationValue,
        );
        timeValue = animValue;
      }
    }

    // CRITICAL FIX: Special handling for text content
    if (isTextContent) {
      // For text content, dramatically reduce settings that cause background problems
      colorIntensity = colorIntensity * 0.1; // Much more reduction for text
      waveAmount =
          waveAmount * 0.1; // Dramatically reduce wave distortion for text

      if (enableShaderDebugLogs) {
        _log(
          "Reducing effects for text content - original colorIntensity=$colorIntensity, waveAmount=$waveAmount",
        );
      }
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
    shader.setFloat(
      2,
      settings.noiseSettings.noiseScale.clamp(0.1, 20.0),
    ); // Noise scale
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
    // This is a simplified static version that doesn't use AnimatedSampler
    // Just draw a simple background color to avoid memory issues during preset saving
    if (settings.noiseSettings.colorIntensity > 0) {
      final paint = Paint()
        ..color = Color.fromRGBO(
          (242 * settings.noiseSettings.colorIntensity).round(),
          (143 * settings.noiseSettings.colorIntensity).round(),
          (202 * settings.noiseSettings.colorIntensity).round(),
          0.1 + (settings.noiseSettings.colorIntensity * 0.2),
        );
      canvas.drawRect(Offset.zero & size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint for simplicity
  }
}
