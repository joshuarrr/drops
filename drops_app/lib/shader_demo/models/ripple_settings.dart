import 'animation_options.dart';

class RippleSettings {
  // Enable flag for ripple effect
  bool _rippleEnabled;

  // Ripple settings
  double _rippleIntensity; // Controls number of ripples (0-1)
  double _rippleSize; // Controls size of ripples (0-1, scaled internally)
  double _rippleSpeed; // Controls speed of ripple expansion (0-1)
  double _rippleOpacity; // Controls opacity of ripples (0-1)
  double _rippleColor; // Controls color influence (0-1)

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
    bool rippleAnimated = false,
    AnimationOptions? rippleAnimOptions,
  }) : _rippleEnabled = rippleEnabled,
       _rippleIntensity = rippleIntensity,
       _rippleSize = rippleSize,
       _rippleSpeed = rippleSpeed,
       _rippleOpacity = rippleOpacity,
       _rippleColor = rippleColor,
       _rippleAnimated = rippleAnimated,
       _rippleAnimOptions = rippleAnimOptions ?? AnimationOptions() {
    if (enableLogging) print("SETTINGS: RippleSettings initialized");
  }

  // Serialization helpers
  Map<String, dynamic> toMap() {
    return {
      'rippleEnabled': _rippleEnabled,
      'rippleIntensity': _rippleIntensity,
      'rippleSize': _rippleSize,
      'rippleSpeed': _rippleSpeed,
      'rippleOpacity': _rippleOpacity,
      'rippleColor': _rippleColor,
      'rippleAnimated': _rippleAnimated,
      'rippleAnimOptions': _rippleAnimOptions.toMap(),
    };
  }

  factory RippleSettings.fromMap(Map<String, dynamic> map) {
    return RippleSettings(
      rippleEnabled: map['rippleEnabled'] ?? false,
      rippleIntensity: map['rippleIntensity'] ?? 0.5,
      rippleSize: map['rippleSize'] ?? 0.5,
      rippleSpeed: map['rippleSpeed'] ?? 0.5,
      rippleOpacity: map['rippleOpacity'] ?? 0.7,
      rippleColor: map['rippleColor'] ?? 0.3,
      rippleAnimated: map['rippleAnimated'] ?? false,
      rippleAnimOptions: map['rippleAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['rippleAnimOptions']),
            )
          : null,
    );
  }
}
