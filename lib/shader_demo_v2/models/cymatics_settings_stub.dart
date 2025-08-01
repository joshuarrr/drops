// Minimal stub for CymaticsSettings to maintain compatibility
// Cymatics functionality removed in V2

import 'animation_options.dart';

class CymaticsSettings {
  bool cymaticsEnabled = false;
  double intensity = 0.0;
  double frequency = 0.0;
  double amplitude = 0.0;
  double complexity = 0.0;
  double speed = 0.0;
  double colorIntensity = 0.0;
  bool audioReactive = false;
  double audioSensitivity = 0.0;
  bool cymaticsAnimated = false;
  AnimationOptions animOptions = AnimationOptions();

  // Apply to text/image flags (always false in V2)
  bool applyToText = false;
  bool applyToImage = false;

  CymaticsSettings({
    this.cymaticsEnabled = false,
    this.intensity = 0.0,
    this.frequency = 0.0,
    this.amplitude = 0.0,
    this.complexity = 0.0,
    this.speed = 0.0,
    this.colorIntensity = 0.0,
    this.audioReactive = false,
    this.audioSensitivity = 0.0,
    this.cymaticsAnimated = false,
    AnimationOptions? animOptions,
    this.applyToText = false,
    this.applyToImage = false,
  }) : animOptions = animOptions ?? AnimationOptions();

  static void enableLogging(bool enabled) {
    // No-op stub
  }

  Map<String, dynamic> toMap() {
    return {
      'cymaticsEnabled': false,
      'intensity': 0.0,
      'frequency': 0.0,
      'amplitude': 0.0,
      'complexity': 0.0,
      'speed': 0.0,
      'colorIntensity': 0.0,
      'audioReactive': false,
      'audioSensitivity': 0.0,
      'cymaticsAnimated': false,
      'animOptions': animOptions.toMap(),
      'applyToText': false,
      'applyToImage': false,
    };
  }

  static CymaticsSettings fromMap(Map<String, dynamic> map) {
    return CymaticsSettings(); // Always return disabled stub
  }
}
