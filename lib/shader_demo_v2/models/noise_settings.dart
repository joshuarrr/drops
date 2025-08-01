import 'animation_options.dart';
import 'targetable_effect_settings.dart';

class NoiseSettings with TargetableEffectSettings {
  // Enable flag for noise effect
  bool _noiseEnabled;

  // Noise effect settings
  double _noiseScale; // Scale of the noise pattern
  double _noiseSpeed; // Speed of the animation
  double _colorIntensity; // Intensity of the color overlay
  double _waveAmount; // Amount of wave distortion

  // Animation flag
  bool _noiseAnimated; // Animation flag for noise effect

  // Animation options
  AnimationOptions _noiseAnimOptions;

  // Flag to control logging
  static bool enableLogging = false;

  // Property getters and setters
  bool get noiseEnabled => _noiseEnabled;
  set noiseEnabled(bool value) {
    _noiseEnabled = value;
    if (enableLogging) print("SETTINGS: noiseEnabled set to $value");
  }

  // Noise effect getters and setters
  double get noiseScale => _noiseScale.clamp(0.1, 20.0);
  set noiseScale(double value) {
    // FIX: Prevent negative values that cause shader flashing
    _noiseScale = value.clamp(0.1, 20.0);
    if (enableLogging) {
      print(
        "SETTINGS: noiseScale set to ${_noiseScale.toStringAsFixed(3)} (input: ${value.toStringAsFixed(3)})",
      );
    }
  }

  double get noiseSpeed => _noiseSpeed.clamp(0.0, 1.0);
  set noiseSpeed(double value) {
    _noiseSpeed = value.clamp(0.0, 1.0);
    if (enableLogging) {
      print(
        "SETTINGS: noiseSpeed set to ${_noiseSpeed.toStringAsFixed(3)} (input: ${value.toStringAsFixed(3)})",
      );
    }
  }

  double get colorIntensity => _colorIntensity.clamp(0.0, 1.0);
  set colorIntensity(double value) {
    _colorIntensity = value.clamp(0.0, 1.0);
    if (enableLogging) {
      print(
        "SETTINGS: colorIntensity set to ${_colorIntensity.toStringAsFixed(3)} (input: ${value.toStringAsFixed(3)})",
      );
    }
  }

  double get waveAmount => _waveAmount.clamp(0.0, 0.1);
  set waveAmount(double value) {
    _waveAmount = value.clamp(0.0, 0.1);
    if (enableLogging) {
      print(
        "SETTINGS: waveAmount set to ${_waveAmount.toStringAsFixed(3)} (input: ${value.toStringAsFixed(3)})",
      );
    }
  }

  bool get noiseAnimated => _noiseAnimated;
  set noiseAnimated(bool value) {
    _noiseAnimated = value;
    if (enableLogging) print("SETTINGS: noiseAnimated set to $value");
  }

  AnimationOptions get noiseAnimOptions => _noiseAnimOptions;
  set noiseAnimOptions(AnimationOptions value) {
    _noiseAnimOptions = value;
    if (enableLogging) print("SETTINGS: noiseAnimOptions updated");
  }

  NoiseSettings({
    bool noiseEnabled = false,
    double noiseScale = 5.0,
    double noiseSpeed = 0.5,
    double colorIntensity = 0.3,
    double waveAmount = 0.02,
    bool noiseAnimated = false,
    AnimationOptions? noiseAnimOptions,
    bool applyToImage = true, // New parameter with default true
    bool applyToText = true, // New parameter with default true
  }) : _noiseEnabled = noiseEnabled,
       _noiseScale = noiseScale,
       _noiseSpeed = noiseSpeed,
       _colorIntensity = colorIntensity,
       _waveAmount = waveAmount,
       _noiseAnimated = noiseAnimated,
       _noiseAnimOptions = noiseAnimOptions ?? AnimationOptions() {
    // Set the targeting flags
    this.applyToImage = applyToImage;
    this.applyToText = applyToText;

    if (enableLogging) print("SETTINGS: NoiseSettings initialized");
  }

  // Serialization helpers
  Map<String, dynamic> toMap() {
    final map = {
      'noiseEnabled': _noiseEnabled,
      'noiseScale': _noiseScale,
      'noiseSpeed': _noiseSpeed,
      'colorIntensity': _colorIntensity,
      'waveAmount': _waveAmount,
      'noiseAnimated': _noiseAnimated,
      'noiseAnimOptions': _noiseAnimOptions.toMap(),
    };

    // Add targeting flags from the mixin
    addTargetingToMap(map);

    return map;
  }

  factory NoiseSettings.fromMap(Map<String, dynamic> map) {
    final settings = NoiseSettings(
      noiseEnabled: map['noiseEnabled'] ?? false,
      noiseScale: map['noiseScale'] ?? 5.0,
      noiseSpeed: map['noiseSpeed'] ?? 0.5,
      colorIntensity: map['colorIntensity'] ?? 0.3,
      waveAmount: map['waveAmount'] ?? 0.02,
      noiseAnimated: map['noiseAnimated'] ?? false,
      noiseAnimOptions: map['noiseAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['noiseAnimOptions']),
            )
          : null,
    );

    // Load targeting flags from the map
    settings.loadTargetingFromMap(map);

    return settings;
  }
}
