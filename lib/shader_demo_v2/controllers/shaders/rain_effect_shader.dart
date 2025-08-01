import 'dart:math' as math;
import 'dart:developer' as developer;
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import '../../models/animation_options.dart';
import '../../utils/animation_utils.dart';
import '../../models/presets_manager.dart';
import '../../models/shader_effect.dart';
import 'debug_flags.dart'; // Import the shared debug flag

/// Custom rain effect shader widget
class RainEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;
  final String _logTag = 'RainEffectShader';

  // Asset path for the noise texture
  static const String noiseTexturePath = 'assets/img/noise_texture.png';

  const RainEffectShader({
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
    developer.log(message, name: _logTag);
    debugPrint('[$_logTag] $message');
  }

  @override
  Widget build(BuildContext context) {
    if (enableShaderDebugLogs) {
      _log(
        "Building RainEffectShader with intensity=${settings.rainSettings.rainIntensity.toStringAsFixed(2)}, "
        "dropSize=${settings.rainSettings.dropSize.toStringAsFixed(2)}, "
        "speed=${settings.rainSettings.fallSpeed.toStringAsFixed(2)} "
        "(animated: ${settings.rainSettings.rainAnimated})",
      );
    }

    // First load the noise texture
    return FutureBuilder<ui.Image>(
      future: _loadNoiseTexture(),
      builder: (context, snapshot) {
        // If the noise texture is still loading, show the original content
        if (!snapshot.hasData) return child;

        final noiseTexture = snapshot.data!;

        // Now use the ShaderBuilder with both textures - simplified structure
        return ShaderBuilder(assetKey: 'assets/shaders/rain_effect.frag', (
          context,
          shader,
          child,
        ) {
          return AnimatedSampler((image, size, canvas) {
            try {
              // Set the main texture sampler first
              shader.setImageSampler(0, image);

              // Set the noise texture sampler second
              shader.setImageSampler(1, noiseTexture);

              // When rainAnimated is false, we still send the fall speed
              // but we don't send an animated time value
              double timeValue = settings.rainSettings.rainAnimated
                  ? animationValue
                  : 0.0;

              // The fall speed to use, which can be 0 even when animated
              double fallSpeed = settings.rainSettings.fallSpeed;

              // If preserveTransparency is enabled or this is text content, adjust rain settings
              double rainIntensity = settings.rainSettings.rainIntensity;
              double dropSize = settings.rainSettings.dropSize;
              double refraction = settings.rainSettings.refraction;
              double trailIntensity = settings.rainSettings.trailIntensity;

              // Compute animation values if animation is enabled
              if (settings.rainSettings.rainAnimated) {
                if (settings.rainSettings.rainAnimOptions.mode ==
                    AnimationMode.pulse) {
                  // Use consistent pulse calculation for rain effect
                  final double pulse = ShaderAnimationUtils.computePulseValue(
                    settings.rainSettings.rainAnimOptions,
                    animationValue,
                  );
                  timeValue = pulse;

                  // Apply pulse to all rain effect parameters
                  fallSpeed = settings.rainSettings.fallSpeed * pulse;
                  rainIntensity = settings.rainSettings.rainIntensity * pulse;
                  dropSize = settings.rainSettings.dropSize * pulse;
                  refraction = settings.rainSettings.refraction * pulse;
                  trailIntensity = settings.rainSettings.trailIntensity * pulse;
                } else {
                  // For non-pulse modes, use the standard animation utilities
                  final double animValue =
                      ShaderAnimationUtils.computeAnimatedValue(
                        settings.rainSettings.rainAnimOptions,
                        animationValue,
                      );
                  timeValue = animValue;

                  // Apply animation to all rain effect parameters
                  fallSpeed = settings.rainSettings.fallSpeed * animValue;
                  rainIntensity =
                      settings.rainSettings.rainIntensity * animValue;
                  dropSize = settings.rainSettings.dropSize * animValue;
                  refraction = settings.rainSettings.refraction * animValue;
                  trailIntensity =
                      settings.rainSettings.trailIntensity * animValue;
                }
              }

              // CRITICAL FIX: Special handling for text content
              if (isTextContent) {
                // For text content, reduce settings to avoid overwhelming the text
                rainIntensity = rainIntensity * 0.3; // Less drops for text
                refraction = refraction * 0.2; // Less distortion for text
                trailIntensity =
                    trailIntensity * 0.2; // Shorter trails for text

                if (enableShaderDebugLogs) {
                  _log(
                    "Reducing effects for text content - original rainIntensity=$rainIntensity, refraction=$refraction",
                  );
                }
              }
              // Less aggressive adjustments for general transparency preservation
              else if (preserveTransparency) {
                rainIntensity = rainIntensity * 0.5; // Reduce drop density
                refraction = refraction * 0.5; // Reduce refraction distortion
                trailIntensity = trailIntensity * 0.5; // Reduce trail effects
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
                rainIntensity.clamp(0.0, 1.0),
              ); // Rain intensity
              shader.setFloat(3, dropSize.clamp(0.0, 1.0)); // Drop size
              shader.setFloat(4, fallSpeed.clamp(0.0, 2.0)); // Fall speed
              shader.setFloat(
                5,
                refraction.clamp(0.0, 1.0),
              ); // Refraction amount
              shader.setFloat(
                6,
                trailIntensity.clamp(0.0, 1.0),
              ); // Trail intensity
              shader.setFloat(
                7,
                settings.rainSettings.rainAnimated ? 1.0 : 0.0,
              ); // Animation flag

              // Draw with the shader, ensuring it covers the full area
              canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
            } catch (e) {
              _log("ERROR: $e");
              // Fall back to drawing the original image
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
      },
    );
  }

  // Helper method to load the noise texture
  Future<ui.Image> _loadNoiseTexture() async {
    try {
      // Try to use the cached texture if available
      if (_cachedNoiseTexture != null) return _cachedNoiseTexture!;

      // Load the texture from assets
      final completer = Completer<ui.Image>();

      // Load the asset bundle
      final ByteData data = await rootBundle.load(noiseTexturePath);

      // Decode the image
      ui.decodeImageFromList(data.buffer.asUint8List(), (ui.Image img) {
        _cachedNoiseTexture = img;
        completer.complete(img);
      });

      return completer.future;
    } catch (e) {
      _log("Error loading noise texture: $e");

      // Create a fallback noise texture if loading fails
      return _createFallbackNoiseTexture();
    }
  }

  // Create a simple noise texture programmatically if the asset can't be loaded
  Future<ui.Image> _createFallbackNoiseTexture() async {
    final int width = 256;
    final int height = 256;

    // Create a picture recorder
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    // Draw noise using random colors
    final Random random = Random(42); // Fixed seed for consistent results
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final double noise = random.nextDouble();
        canvas.drawRect(
          Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1),
          Paint()
            ..color = Color.fromRGBO(
              (noise * 255).round(),
              (noise * 255).round(),
              (noise * 255).round(),
              1.0,
            ),
        );
      }
    }

    // End recording and get the picture
    final picture = recorder.endRecording();

    // Convert to an image
    final completer = Completer<ui.Image>();
    picture.toImage(width, height).then((image) {
      _cachedNoiseTexture = image;
      completer.complete(image);
    });

    return completer.future;
  }

  // Static cache for the noise texture to avoid reloading
  static ui.Image? _cachedNoiseTexture;

  // Helper method to create a realistic raindrop preset based on the article implementation
  Future<void> createRealisticRainPreset() async {
    try {
      // Define the preset settings
      final Map<String, dynamic> realisticRainPreset = {
        'rainEnabled': true,
        'rainIntensity': 0.7, // Higher intensity for more drops
        'dropSize': 0.6, // Slightly larger drops
        'fallSpeed': 0.5, // Medium speed
        'refraction':
            0.8, // Higher refraction for more distortion (like in the article)
        'trailIntensity': 0.4, // Moderate trail effect
        'rainAnimated': true, // Enable animation
        'rainAnimOptions': {
          // Animation options
          'speed': 0.5,
          'mode': 0, // Continuous mode
          'easing': 0, // Linear easing
        },
      };

      // Save the preset using the PresetsManager
      await PresetsManager.savePreset(
        ShaderAspect.rain,
        "Realistic Article Rain",
        realisticRainPreset,
      );

      _log("Created realistic rain preset");
    } catch (e) {
      _log("Error creating realistic rain preset: $e");
    }
  }
}
