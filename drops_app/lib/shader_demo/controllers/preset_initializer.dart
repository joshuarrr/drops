import '../models/presets_manager.dart';
import '../models/shader_effect.dart';

/// Utility class for initializing default presets when the app starts
class PresetInitializer {
  /// Initializes all default presets if they don't already exist
  static Future<void> initializeDefaultPresets() async {
    await _initializeRealisticRainPreset();
    // Add other preset initializations here in the future
  }

  /// Initialize the realistic rain preset based on the article implementation
  static Future<void> _initializeRealisticRainPreset() async {
    try {
      // First check if we already have any rain presets
      final existingPresets = await PresetsManager.getPresetsForAspect(
        ShaderAspect.rain,
      );

      // Only create the preset if no rain presets exist yet
      if (existingPresets.isEmpty) {
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

        print("Created default realistic rain preset");
      }
    } catch (e) {
      print("Error creating realistic rain preset: $e");
    }
  }
}
