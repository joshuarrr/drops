// shatter effect
import 'animation_options.dart';
import 'targetable_effect_settings.dart';

class BlurSettings with TargetableEffectSettings {
  // Enable flag for blur effect
  bool _blurEnabled;

  // Blur settings
  double _blurAmount;
  double _blurRadius;
  double _blurOpacity; // 0-1 opacity applied to effect
  int _blurBlendMode; // 0=normal,1=multiply,2=screen
  double _blurIntensity; // Amplifies the intensity of shatter fragments
  double _blurContrast; // Increases contrast between fragments

  // Animation flag
  bool _blurAnimated;

  // Animation options
  AnimationOptions _blurAnimOptions;

  // Flag to control logging
  static bool enableLogging = true;

  // Property getters and setters
  bool get blurEnabled => _blurEnabled;
  set blurEnabled(bool value) {
    _blurEnabled = value;
    if (enableLogging) print("SETTINGS: blurEnabled set to $value");
  }

  double get blurAmount => _blurAmount;
  set blurAmount(double value) {
    _blurAmount = value;
    if (enableLogging) {
      print("SETTINGS: blurAmount set to ${value.toStringAsFixed(3)}");
    }
  }

  double get blurRadius => _blurRadius;
  set blurRadius(double value) {
    _blurRadius = value;
    if (enableLogging) {
      print("SETTINGS: blurRadius set to ${value.toStringAsFixed(3)}");
    }
  }

  // Blur animation toggle with logging
  bool get blurAnimated => _blurAnimated;
  set blurAnimated(bool value) {
    _blurAnimated = value;
    if (enableLogging) print("SETTINGS: blurAnimated set to $value");
  }

  // Settings with logging
  double get blurOpacity => _blurOpacity;
  set blurOpacity(double value) {
    _blurOpacity = value;
    if (enableLogging) {
      print("SETTINGS: blurOpacity set to ${value.toStringAsFixed(3)}");
    }
  }

  int get blurBlendMode => _blurBlendMode;
  set blurBlendMode(int value) {
    _blurBlendMode = value;
    if (enableLogging) print("SETTINGS: blurBlendMode set to $value");
  }

  // Intensity and contrast controls
  double get blurIntensity => _blurIntensity;
  set blurIntensity(double value) {
    _blurIntensity = value;
    if (enableLogging) {
      print("SETTINGS: blurIntensity set to ${value.toStringAsFixed(3)}");
    }
  }

  double get blurContrast => _blurContrast;
  set blurContrast(double value) {
    _blurContrast = value;
    if (enableLogging) {
      print("SETTINGS: blurContrast set to ${value.toStringAsFixed(3)}");
    }
  }

  AnimationOptions get blurAnimOptions => _blurAnimOptions;
  set blurAnimOptions(AnimationOptions value) {
    _blurAnimOptions = value;
    if (enableLogging) print("SETTINGS: blurAnimOptions updated");
  }

  BlurSettings({
    bool blurEnabled = false,
    double blurAmount = 0.0,
    double blurRadius = 15.0,
    double blurOpacity = 1.0,
    int blurBlendMode = 0,
    double blurIntensity = 1.0,
    double blurContrast = 0.0,
    bool blurAnimated = false,
    AnimationOptions? blurAnimOptions,
    bool applyToImage = true, // New parameter with default true
    bool applyToText = true, // New parameter with default true
  }) : _blurEnabled = blurEnabled,
       _blurAmount = blurAmount,
       _blurRadius = blurRadius,
       _blurOpacity = blurOpacity,
       _blurBlendMode = blurBlendMode,
       _blurIntensity = blurIntensity,
       _blurContrast = blurContrast,
       _blurAnimated = blurAnimated,
       _blurAnimOptions = blurAnimOptions ?? AnimationOptions() {
    // Set the targeting flags
    this.applyToImage = applyToImage;
    this.applyToText = applyToText;

    if (enableLogging) print("SETTINGS: BlurSettings initialized");
  }

  // Serialization helpers
  Map<String, dynamic> toMap() {
    final map = {
      'blurEnabled': _blurEnabled,
      'blurAmount': _blurAmount,
      'blurRadius': _blurRadius,
      'blurOpacity': _blurOpacity,
      'blurBlendMode': _blurBlendMode,
      'blurIntensity': _blurIntensity,
      'blurContrast': _blurContrast,
      'blurAnimated': _blurAnimated,
      'blurAnimOptions': _blurAnimOptions.toMap(),
    };

    // Add targeting flags from the mixin
    addTargetingToMap(map);

    return map;
  }

  factory BlurSettings.fromMap(Map<String, dynamic> map) {
    final settings = BlurSettings(
      blurEnabled: map['blurEnabled'] ?? false,
      blurAmount: map['blurAmount'] ?? 0.0,
      blurRadius: map['blurRadius'] ?? 15.0,
      blurOpacity: map['blurOpacity'] ?? 1.0,
      blurBlendMode: map['blurBlendMode'] ?? 0,
      blurIntensity: map['blurIntensity'] ?? 1.0,
      blurContrast: map['blurContrast'] ?? 0.0,
      blurAnimated: map['blurAnimated'] ?? false,
      blurAnimOptions: map['blurAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['blurAnimOptions']),
            )
          : null,
    );

    // Load targeting flags from the map
    settings.loadTargetingFromMap(map);

    return settings;
  }
}
