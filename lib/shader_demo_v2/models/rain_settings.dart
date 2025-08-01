import 'animation_options.dart';
import 'targetable_effect_settings.dart';

class RainSettings with TargetableEffectSettings {
  // Enable flag for rain effect
  bool _rainEnabled;

  // Rain settings
  double _rainIntensity; // Controls number of drops (0-1)
  double _dropSize; // Controls size of droplets (0-1, scaled internally)
  double _fallSpeed; // Controls speed of falling drops (0-1)
  double _refraction; // Controls visual distortion from drops (0-1)
  double
  _trailIntensity; // Controls length/opacity of trails behind drops (0-1)

  // Animation flag
  bool _rainAnimated;

  // Animation options
  AnimationOptions _rainAnimOptions;

  // Flag to control logging
  static bool enableLogging = false;

  // Property getters and setters
  bool get rainEnabled => _rainEnabled;
  set rainEnabled(bool value) {
    _rainEnabled = value;
    if (enableLogging) print("SETTINGS: rainEnabled set to $value");
  }

  double get rainIntensity => _rainIntensity;
  set rainIntensity(double value) {
    _rainIntensity = value;
    if (enableLogging) {
      print("SETTINGS: rainIntensity set to ${value.toStringAsFixed(3)}");
    }
  }

  double get dropSize => _dropSize;
  set dropSize(double value) {
    _dropSize = value;
    if (enableLogging) {
      print("SETTINGS: dropSize set to ${value.toStringAsFixed(3)}");
    }
  }

  double get fallSpeed => _fallSpeed;
  set fallSpeed(double value) {
    _fallSpeed = value;
    if (enableLogging) {
      print("SETTINGS: fallSpeed set to ${value.toStringAsFixed(3)}");
    }
  }

  double get refraction => _refraction;
  set refraction(double value) {
    _refraction = value;
    if (enableLogging) {
      print("SETTINGS: refraction set to ${value.toStringAsFixed(3)}");
    }
  }

  double get trailIntensity => _trailIntensity;
  set trailIntensity(double value) {
    _trailIntensity = value;
    if (enableLogging) {
      print("SETTINGS: trailIntensity set to ${value.toStringAsFixed(3)}");
    }
  }

  // Rain animation toggle with logging
  bool get rainAnimated => _rainAnimated;
  set rainAnimated(bool value) {
    _rainAnimated = value;
    if (enableLogging) print("SETTINGS: rainAnimated set to $value");
  }

  AnimationOptions get rainAnimOptions => _rainAnimOptions;
  set rainAnimOptions(AnimationOptions value) {
    _rainAnimOptions = value;
    if (enableLogging) print("SETTINGS: rainAnimOptions updated");
  }

  // Constructor with default values
  RainSettings({
    bool rainEnabled = false,
    double rainIntensity = 0.5,
    double dropSize = 0.5,
    double fallSpeed = 0.5,
    double refraction = 0.5,
    double trailIntensity = 0.3,
    bool rainAnimated = false,
    AnimationOptions? rainAnimOptions,
    bool applyToImage = true, // New parameter with default true
    bool applyToText = true, // New parameter with default true
  }) : _rainEnabled = rainEnabled,
       _rainIntensity = rainIntensity,
       _dropSize = dropSize,
       _fallSpeed = fallSpeed,
       _refraction = refraction,
       _trailIntensity = trailIntensity,
       _rainAnimated = rainAnimated,
       _rainAnimOptions = rainAnimOptions ?? AnimationOptions() {
    // Set the targeting flags
    this.applyToImage = applyToImage;
    this.applyToText = applyToText;

    if (enableLogging) print("SETTINGS: RainSettings initialized");
  }

  // Serialization helpers
  Map<String, dynamic> toMap() {
    final map = {
      'rainEnabled': _rainEnabled,
      'rainIntensity': _rainIntensity,
      'dropSize': _dropSize,
      'fallSpeed': _fallSpeed,
      'refraction': _refraction,
      'trailIntensity': _trailIntensity,
      'rainAnimated': _rainAnimated,
      'rainAnimOptions': _rainAnimOptions.toMap(),
    };

    // Add targeting flags from the mixin
    addTargetingToMap(map);

    return map;
  }

  factory RainSettings.fromMap(Map<String, dynamic> map) {
    final settings = RainSettings(
      rainEnabled: map['rainEnabled'] ?? false,
      rainIntensity: map['rainIntensity'] ?? 0.5,
      dropSize: map['dropSize'] ?? 0.5,
      fallSpeed: map['fallSpeed'] ?? 0.5,
      refraction: map['refraction'] ?? 0.5,
      trailIntensity: map['trailIntensity'] ?? 0.3,
      rainAnimated: map['rainAnimated'] ?? false,
      rainAnimOptions: map['rainAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['rainAnimOptions']),
            )
          : null,
    );

    // Load targeting flags from the map
    settings.loadTargetingFromMap(map);

    return settings;
  }
}
