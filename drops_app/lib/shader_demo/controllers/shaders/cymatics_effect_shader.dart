import 'dart:developer' as developer;
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../services/audio_analyzer_service.dart';
import '../../controllers/music_controller.dart';
import '../../utils/animation_utils.dart';
import 'debug_flags.dart';

// Force enable logging for debugging
bool enableVerboseCymaticsLogging = true;
bool enableShaderDebugLogs = true;

/// CymaticsEffectShader: Adds sound wave visualization effects to a widget
class CymaticsEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;
  final bool isBackgroundOnly;
  final String _logTag = 'CymaticsEffectShader';

  // Default background color for the cymatics effect
  final Color backgroundColor;

  const CymaticsEffectShader({
    Key? key,
    required this.child,
    required this.settings,
    required this.animationValue,
    this.preserveTransparency = false,
    this.isTextContent = false,
    this.isBackgroundOnly = false,
    this.backgroundColor = const Color(0xFF1A237E), // Deep blue default
  }) : super(key: key);

  // Custom log function that uses both dart:developer and debugPrint for visibility
  void _log(String message) {
    if (!enableShaderDebugLogs) return;
    developer.log(message, name: _logTag);
    debugPrint('[$_logTag] $message');
  }

  // Helper to convert Color to HSL components (0-1 range)
  Map<String, double> _colorToHSL(Color color) {
    // Extract RGB components (0-1)
    final r = color.red / 255.0;
    final g = color.green / 255.0;
    final b = color.blue / 255.0;

    final max = math.max(math.max(r, g), b);
    final min = math.min(math.min(r, g), b);

    // Calculate lightness
    final l = (max + min) / 2;

    double h = 0;
    double s = 0;

    if (max != min) {
      // Calculate saturation
      s = l > 0.5 ? (max - min) / (2.0 - max - min) : (max - min) / (max + min);

      // Calculate hue
      if (max == r) {
        h = (g - b) / (max - min) + (g < b ? 6 : 0);
      } else if (max == g) {
        h = (b - r) / (max - min) + 2;
      } else {
        h = (r - g) / (max - min) + 4;
      }
      h /= 6;
    }

    return {'hue': h, 'saturation': s, 'lightness': l};
  }

  @override
  Widget build(BuildContext context) {
    if (enableShaderDebugLogs) {
      _log(
        "Building CymaticsEffectShader with intensity=${settings.cymaticsSettings.intensity.toStringAsFixed(2)}, "
        "frequency=${settings.cymaticsSettings.frequency.toStringAsFixed(2)}, "
        "amplitude=${settings.cymaticsSettings.amplitude.toStringAsFixed(2)}, "
        "complexity=${settings.cymaticsSettings.complexity.toStringAsFixed(2)}, "
        "speed=${settings.cymaticsSettings.speed.toStringAsFixed(2)}, "
        "colorIntensity=${settings.cymaticsSettings.colorIntensity.toStringAsFixed(2)}, "
        "audioReactive=${settings.cymaticsSettings.audioReactive}, "
        "audioSensitivity=${settings.cymaticsSettings.audioSensitivity.toStringAsFixed(2)} "
        "(animated: ${settings.cymaticsSettings.cymaticsAnimated}, isBackgroundOnly: $isBackgroundOnly)",
      );
    }

    // Get background color either from settings or use default
    Color bgColor = backgroundColor;
    if (settings.colorEnabled && settings.colorSettings.overlayOpacity > 0) {
      // Use color settings if available
      final hue = settings.colorSettings.overlayHue;
      final lightness =
          0.3 +
          (settings.colorSettings.lightness * 0.3); // Adjust for visibility
      final saturation =
          0.5 +
          (settings.colorSettings.saturation * 0.3); // Adjust for visibility

      // Convert HSL to Color (simplified)
      bgColor = HSLColor.fromAHSL(
        1.0,
        hue * 360,
        saturation,
        lightness,
      ).toColor();
    }

    // Convert color to HSL components
    final Map<String, double> hslComponents = _colorToHSL(bgColor);

    // For background-only mode, we'll use a black background for better contrast
    if (isBackgroundOnly) {
      bgColor = Colors.black;
    }

    // Shader builder pattern
    return ShaderBuilder(assetKey: 'assets/shaders/cymatics_effect.frag', (
      context,
      shader,
      child,
    ) {
      return AnimatedSampler((image, size, canvas) {
        try {
          if (enableVerboseCymaticsLogging) {
            _log(
              "CYMATICS SAMPLER: image=${image.width}x${image.height}, canvas=${size.width}x${size.height}, isBackgroundOnly=$isBackgroundOnly",
            );
          }

          // Set the texture sampler
          shader.setImageSampler(0, image);

          // Calculate animation value and time parameter
          double timeValue = settings.cymaticsSettings.cymaticsAnimated
              ? animationValue
              : 0.0;

          // Get the individual parameters
          double intensity = settings.cymaticsSettings.intensity;
          double frequency = settings.cymaticsSettings.frequency;
          double amplitude = settings.cymaticsSettings.amplitude;
          double complexity = settings.cymaticsSettings.complexity;
          double speed = settings.cymaticsSettings.speed;
          double colorIntensity = settings.cymaticsSettings.colorIntensity;
          double audioReactive = settings.cymaticsSettings.audioReactive
              ? 1.0
              : 0.0;
          double audioSensitivity = settings.cymaticsSettings.audioSensitivity;

          // Always get audio waveform data from analyzer
          double bassLevel = 0.5;
          double midLevel = 0.5;
          double trebleLevel = 0.5;

          try {
            // Force audioReactive to true since it's required for the shader
            audioReactive = 1.0; // Override the toggle setting

            // Get audio frequency data from music controller
            final musicController = MusicController.getInstance(
              settings: settings,
              onSettingsChanged: (_) {}, // No need to update settings here
            );

            // Get real-time audio data with fallback minimums
            bassLevel = math.max(0.2, musicController.getBassLevel());
            midLevel = math.max(0.15, musicController.getMidLevel());
            trebleLevel = math.max(0.1, musicController.getTrebleLevel());

            // Add more dynamic variation by amplifying the differences
            if (musicController.isPlaying()) {
              // Boost levels when music is playing to make effect more visible
              bassLevel = 0.3 + (bassLevel * 0.7);
              midLevel = 0.25 + (midLevel * 0.75);
              trebleLevel = 0.2 + (trebleLevel * 0.8);
            }

            // Always log audio levels to help with debugging
            _log(
              "Audio levels - Bass: ${bassLevel.toStringAsFixed(2)}, "
              "Mid: ${midLevel.toStringAsFixed(2)}, "
              "Treble: ${trebleLevel.toStringAsFixed(2)} - "
              "Playing: ${musicController.isPlaying()}",
            );
          } catch (e) {
            _log("Error getting audio data: $e");
          }

          // Compute animation values if animation is enabled
          if (settings.cymaticsSettings.cymaticsAnimated) {
            timeValue = ShaderAnimationUtils.computeAnimatedValue(
              settings.cymaticsSettings.animOptions,
              animationValue,
            );
          }

          // For background-only mode, make patterns more visible with higher contrast
          if (isBackgroundOnly) {
            // Enhance parameters for background mode to make a cleaner visualization
            // with much higher contrast and visibility
            intensity = math.max(0.8, intensity); // Higher minimum intensity
            colorIntensity = 1.0; // Full color for better visibility
            amplitude = math.max(0.7, amplitude); // Increase amplitude
            complexity = math.min(
              0.5,
              complexity,
            ); // Limit complexity for cleaner look

            // Make audio more visible by boosting levels
            bassLevel = math.max(0.6, bassLevel);
            midLevel = math.max(0.5, midLevel);
            trebleLevel = math.max(0.4, trebleLevel);

            // Increase audio sensitivity for more dynamic patterns
            audioSensitivity = math.max(0.8, audioSensitivity);

            _log(
              "Background-only mode: Boosting visual parameters for better visibility",
            );
          }

          // Set uniforms
          // CRITICAL FIX: Ensure size values are never zero to prevent shader issues
          shader.setFloat(0, size.width > 0.0 ? size.width : 1.0);
          shader.setFloat(1, size.height > 0.0 ? size.height : 1.0);
          // Clamp all parameters to safe ranges to prevent NaN
          shader.setFloat(2, timeValue);
          shader.setFloat(3, intensity.clamp(0.0, 1.0));
          shader.setFloat(4, frequency.clamp(0.0, 10.0));
          shader.setFloat(5, amplitude.clamp(0.0, 1.0));
          shader.setFloat(6, complexity.clamp(0.0, 1.0));
          shader.setFloat(7, speed.clamp(0.0, 5.0));
          shader.setFloat(8, colorIntensity.clamp(0.0, 1.0));
          shader.setFloat(9, audioReactive.clamp(0.0, 1.0));
          shader.setFloat(10, audioSensitivity.clamp(0.0, 1.0));
          shader.setFloat(11, bassLevel.clamp(0.0, 1.0));
          shader.setFloat(12, midLevel.clamp(0.0, 1.0));
          shader.setFloat(13, trebleLevel.clamp(0.0, 1.0));

          // Set background color uniforms
          if (isBackgroundOnly) {
            // For background-only mode, use simpler coloring with white patterns on black
            shader.setFloat(14, 0.0); // Hue (not used in background mode)
            shader.setFloat(
              15,
              0.0,
            ); // Saturation (not used in background mode)
            shader.setFloat(16, 0.0); // Lightness (black background)
          } else {
            // Normal mode - use the calculated HSL values
            shader.setFloat(14, hslComponents['hue']!);
            shader.setFloat(15, hslComponents['saturation']!);
            shader.setFloat(16, hslComponents['lightness']!);
          }

          // Draw with shader
          canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
        } catch (e) {
          _log("ERROR: $e");
          // Fall back to drawing original image
          canvas.drawImageRect(
            image,
            Rect.fromLTWH(
              0,
              0,
              image.width.toDouble(),
              image.height.toDouble(),
            ),
            Rect.fromLTWH(0, 0, size.width, size.height),
            Paint(),
          );
        }
      }, child: this.child);
    }, child: child);
  }
}

/// Helper method to apply cymatics effect using custom shader
Widget applyCymaticsEffect({
  required Widget child,
  required ShaderSettings settings,
  required double animationValue,
  bool preserveTransparency = false,
  bool isTextContent = false,
}) {
  // Always apply cymatics effect when it's enabled
  if (!settings.cymaticsSettings.cymaticsEnabled) {
    if (enableShaderDebugLogs) {
      print(
        "[CymaticsEffectShader] Cymatics effect disabled, skipping application",
      );
    }
    return child;
  }

  // Check where to apply the effect based on settings
  bool applyToImage = settings.cymaticsSettings.applyToImage;
  bool applyToText = settings.cymaticsSettings.applyToText;
  bool applyToBackground = settings.cymaticsSettings.applyToBackground;

  if (enableShaderDebugLogs) {
    print(
      "[CymaticsEffectShader] Apply settings - toImage: $applyToImage, toText: $applyToText, toBackground: $applyToBackground, isTextContent: $isTextContent",
    );
  }

  // Skip applying to this content type if settings say not to
  if (isTextContent && !applyToText) {
    if (enableShaderDebugLogs) {
      print(
        "[CymaticsEffectShader] Not applying to text content (applyToText=false)",
      );
    }
    return child;
  }

  // Skip applying to image content when applyToImage is false
  if (!isTextContent && !applyToImage) {
    if (!applyToBackground) {
      // If neither apply to image nor apply to background is enabled, return unmodified child
      if (enableShaderDebugLogs) {
        print(
          "[CymaticsEffectShader] Not applying to image (applyToImage=false) and not to background (applyToBackground=false)",
        );
      }
      return child;
    }

    // If we're here, applyToImage is false but applyToBackground is true
    if (enableShaderDebugLogs) {
      print(
        "[CymaticsEffectShader] Creating background-only mode with full-screen effect",
      );
    }

    // Make sure we have minimum values to create visible effects
    var modifiedSettings = ShaderSettings.fromMap(settings.toMap());
    if (modifiedSettings.cymaticsSettings.intensity < 0.5) {
      modifiedSettings.cymaticsSettings.intensity =
          0.5; // Higher minimum for background mode
    }
    if (modifiedSettings.cymaticsSettings.amplitude < 0.5) {
      modifiedSettings.cymaticsSettings.amplitude =
          0.5; // Higher minimum for background mode
    }

    // Boost parameters further for background mode to make it more prominent
    modifiedSettings.cymaticsSettings.intensity =
        (modifiedSettings.cymaticsSettings.intensity + 0.4).clamp(0.0, 1.0);
    modifiedSettings.cymaticsSettings.amplitude =
        (modifiedSettings.cymaticsSettings.amplitude + 0.3).clamp(0.0, 1.0);
    modifiedSettings.cymaticsSettings.audioSensitivity =
        (modifiedSettings.cymaticsSettings.audioSensitivity + 0.2).clamp(
          0.0,
          1.0,
        );

    // For background-only mode, create a full-screen container with the effect
    // This will be rendered behind the image
    return Stack(
      children: [
        // Background effect layer (full screen)
        Positioned.fill(
          child: ClipRect(
            child: ColoredBox(
              color: Colors.black,
              child: CymaticsEffectShader(
                settings: modifiedSettings,
                animationValue: animationValue,
                child: Container(
                  color: Colors.black,
                ), // Simple black background
                isBackgroundOnly: true,
                backgroundColor: Colors.black,
              ),
            ),
          ),
        ),
        // Original content completely unaffected on top
        child,
      ],
    );
  }

  // If we got here, we are applying to the image content itself
  if (enableShaderDebugLogs) {
    print(
      "[CymaticsEffectShader] Applying effect directly to content (applyToImage=true)",
    );
  }

  // Make sure we have minimum values to create visible effects
  var modifiedSettings = ShaderSettings.fromMap(settings.toMap());
  if (modifiedSettings.cymaticsSettings.intensity < 0.1) {
    modifiedSettings.cymaticsSettings.intensity = 0.1;
  }
  if (modifiedSettings.cymaticsSettings.amplitude < 0.1) {
    modifiedSettings.cymaticsSettings.amplitude = 0.1;
  }

  // Determine background color based on app theme or settings
  Color backgroundColor = const Color(0xFF1A237E); // Default deep blue

  // If color effect is enabled, use its overlay color as base
  if (settings.colorEnabled && settings.colorSettings.overlayOpacity > 0.3) {
    // Create color from overlay hue
    final hue = settings.colorSettings.overlayHue;
    backgroundColor = HSLColor.fromAHSL(
      1.0,
      hue * 360,
      0.7, // Higher saturation for more vibrant background
      0.3, // Darker for better pattern visibility
    ).toColor();
  }

  // Regular mode - apply effect directly to content
  return CymaticsEffectShader(
    settings: modifiedSettings,
    animationValue: animationValue,
    child: child,
    preserveTransparency: preserveTransparency,
    isTextContent: isTextContent,
    backgroundColor: backgroundColor,
  );
}
