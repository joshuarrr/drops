import 'animation_options.dart';
import 'dart:math';
import 'targetable_effect_settings.dart';

class RippleSettings with TargetableEffectSettings {
  // Enable flag for ripple effect
  bool _rippleEnabled;

  // Ripple settings
  double _rippleIntensity; // Controls number of ripples (0-1)
  double _rippleSize; // Controls size of ripples (0-1, scaled internally)
  double _rippleSpeed; // Controls speed of ripple expansion (0-1)
  double _rippleOpacity; // Controls opacity of ripples (0-1)
  double _rippleColor; // Controls color influence (0-1)
  int _rippleDropCount; // Controls number of ripple sources (1-30)
  double _rippleSeed; // Randomization seed for drop positions
  double
  _rippleOvalness; // Controls how oval the ripples are (0=circles, 1=very oval)
  double
  _rippleRotation; // Controls rotation angle of oval ripples (0-1, scaled to 0-2π)

  // Random generator
  static final Random _random = Random();

  // Animation flag
  bool _rippleAnimated;

  // Animation options
  AnimationOptions _rippleAnimOptions;

  // Flag to control logging
  static bool enableLogging = false;

  // Property getters and setters
  bool get rippleEnabled => _rippleEnabled;
  set rippleEnabled(bool value) {
    _rippleEnabled = value;
    if (enableLogging) print("SETTINGS: rippleEnabled set to $value");
  }

  double get rippleIntensity => _rippleIntensity;
  set rippleIntensity(double value) {
    _rippleIntensity = value;
    if (enableLogging) {
      print("SETTINGS: rippleIntensity set to ${value.toStringAsFixed(3)}");
    }
  }

  double get rippleSize => _rippleSize;
  set rippleSize(double value) {
    _rippleSize = value;
    if (enableLogging) {
      print("SETTINGS: rippleSize set to ${value.toStringAsFixed(3)}");
    }
  }

  double get rippleSpeed => _rippleSpeed;
  set rippleSpeed(double value) {
    _rippleSpeed = value;
    if (enableLogging) {
      print("SETTINGS: rippleSpeed set to ${value.toStringAsFixed(3)}");
    }
  }

  double get rippleOpacity => _rippleOpacity;
  set rippleOpacity(double value) {
    _rippleOpacity = value;
    if (enableLogging) {
      print("SETTINGS: rippleOpacity set to ${value.toStringAsFixed(3)}");
    }
  }

  double get rippleColor => _rippleColor;
  set rippleColor(double value) {
    _rippleColor = value;
    if (enableLogging) {
      print("SETTINGS: rippleColor set to ${value.toStringAsFixed(3)}");
    }
  }

  int get rippleDropCount => _rippleDropCount;
  set rippleDropCount(int value) {
    _rippleDropCount = value;
    if (enableLogging) {
      print("SETTINGS: rippleDropCount set to $value");
    }
  }

  double get rippleSeed => _rippleSeed;
  set rippleSeed(double value) {
    _rippleSeed = value;
    if (enableLogging) {
      print("SETTINGS: rippleSeed set to ${value.toStringAsFixed(3)}");
    }
  }

  double get rippleOvalness => _rippleOvalness;
  set rippleOvalness(double value) {
    _rippleOvalness = value;
    if (enableLogging) {
      print("SETTINGS: rippleOvalness set to ${value.toStringAsFixed(3)}");
    }
  }

  double get rippleRotation => _rippleRotation;
  set rippleRotation(double value) {
    _rippleRotation = value;
    if (enableLogging) {
      print("SETTINGS: rippleRotation set to ${value.toStringAsFixed(3)}");
    }
  }

  // Generate a new random seed to randomize drop positions
  void randomizeDropPositions() {
    _rippleSeed = _random.nextDouble() * 1000.0;
    if (enableLogging) {
      print("SETTINGS: randomized drop positions with seed $_rippleSeed");
    }
  }

  // Ripple animation toggle with logging
  bool get rippleAnimated => _rippleAnimated;
  set rippleAnimated(bool value) {
    _rippleAnimated = value;
    if (enableLogging) print("SETTINGS: rippleAnimated set to $value");
  }

  AnimationOptions get rippleAnimOptions => _rippleAnimOptions;
  set rippleAnimOptions(AnimationOptions value) {
    _rippleAnimOptions = value;
    if (enableLogging) print("SETTINGS: rippleAnimOptions updated");
  }

  // Constructor with default values
  RippleSettings({
    bool rippleEnabled = false,
    double rippleIntensity = 0.5,
    double rippleSize = 0.5,
    double rippleSpeed = 0.5,
    double rippleOpacity = 0.7,
    double rippleColor = 0.3,
    int rippleDropCount = 9,
    double? rippleSeed,
    double rippleOvalness = 0.0,
    double rippleRotation = 0.0,
    bool rippleAnimated = false,
    AnimationOptions? rippleAnimOptions,
    bool applyToImage = true, // New parameter with default true
    bool applyToText = true, // New parameter with default true
  }) : _rippleEnabled = rippleEnabled,
       _rippleIntensity = rippleIntensity,
       _rippleSize = rippleSize,
       _rippleSpeed = rippleSpeed,
       _rippleOpacity = rippleOpacity,
       _rippleColor = rippleColor,
       _rippleDropCount = rippleDropCount,
       _rippleSeed = rippleSeed ?? _random.nextDouble() * 1000.0,
       _rippleOvalness = rippleOvalness,
       _rippleRotation = rippleRotation,
       _rippleAnimated = rippleAnimated,
       _rippleAnimOptions = rippleAnimOptions ?? AnimationOptions() {
    // Set the targeting flags
    this.applyToImage = applyToImage;
    this.applyToText = applyToText;

    if (enableLogging) print("SETTINGS: RippleSettings initialized");
  }

  // Serialization helpers
  Map<String, dynamic> toMap() {
    final map = {
      'rippleEnabled': _rippleEnabled,
      'rippleIntensity': _rippleIntensity,
      'rippleSize': _rippleSize,
      'rippleSpeed': _rippleSpeed,
      'rippleOpacity': _rippleOpacity,
      'rippleColor': _rippleColor,
      'rippleDropCount': _rippleDropCount,
      'rippleSeed': _rippleSeed,
      'rippleOvalness': _rippleOvalness,
      'rippleRotation': _rippleRotation,
      'rippleAnimated': _rippleAnimated,
      'rippleAnimOptions': _rippleAnimOptions.toMap(),
    };

    // Add targeting flags from the mixin
    addTargetingToMap(map);

    return map;
  }

  factory RippleSettings.fromMap(Map<String, dynamic> map) {
    final settings = RippleSettings(
      rippleEnabled: map['rippleEnabled'] ?? false,
      rippleIntensity: map['rippleIntensity'] ?? 0.5,
      rippleSize: map['rippleSize'] ?? 0.5,
      rippleSpeed: map['rippleSpeed'] ?? 0.5,
      rippleOpacity: map['rippleOpacity'] ?? 0.7,
      rippleColor: map['rippleColor'] ?? 0.3,
      rippleDropCount: map['rippleDropCount'] ?? 9,
      rippleSeed: map['rippleSeed'],
      rippleOvalness: map['rippleOvalness'] ?? 0.0,
      rippleRotation: map['rippleRotation'] ?? 0.0,
      rippleAnimated: map['rippleAnimated'] ?? false,
      rippleAnimOptions: map['rippleAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['rippleAnimOptions']),
            )
          : null,
    );

    // Load targeting flags from the map
    settings.loadTargetingFromMap(map);

    return settings;
  }
}
