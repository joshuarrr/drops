import 'package:flutter/material.dart';
import 'animation_options.dart';
import 'targetable_effect_settings.dart';

class ChromaticSettings with TargetableEffectSettings {
  // Main toggle
  bool _chromaticEnabled;

  // Effect properties
  double _amount; // How much chromatic aberration to apply
  double _angle; // Direction of the aberration (degrees)
  double _spread; // How far apart the color channels are spread
  double _intensity; // Overall intensity of the effect

  // Animation controls
  bool _chromaticAnimated;
  AnimationOptions _animOptions;

  // Debug flag
  static bool enableLogging = false;

  // Getters and setters
  bool get chromaticEnabled => _chromaticEnabled;
  set chromaticEnabled(bool value) {
    _chromaticEnabled = value;
    if (enableLogging)
      print("SETTINGS: ChromaticSettings.chromaticEnabled = $value");
  }

  double get amount => _amount;
  set amount(double value) {
    _amount = value;
    if (enableLogging) print("SETTINGS: ChromaticSettings.amount = $value");
  }

  double get angle => _angle;
  set angle(double value) {
    _angle = value;
    if (enableLogging) print("SETTINGS: ChromaticSettings.angle = $value");
  }

  double get spread => _spread;
  set spread(double value) {
    _spread = value;
    if (enableLogging) print("SETTINGS: ChromaticSettings.spread = $value");
  }

  double get intensity => _intensity;
  set intensity(double value) {
    _intensity = value;
    if (enableLogging) print("SETTINGS: ChromaticSettings.intensity = $value");
  }

  bool get chromaticAnimated => _chromaticAnimated;
  set chromaticAnimated(bool value) {
    _chromaticAnimated = value;
    if (enableLogging)
      print("SETTINGS: ChromaticSettings.chromaticAnimated = $value");
  }

  AnimationOptions get animOptions => _animOptions;
  set animOptions(AnimationOptions value) {
    _animOptions = value;
    if (enableLogging) print("SETTINGS: ChromaticSettings.animOptions updated");
  }

  // Constructor
  ChromaticSettings({
    bool chromaticEnabled = false,
    double amount = 0.5,
    double angle = 0.0,
    double spread = 0.5,
    double intensity = 0.5,
    bool chromaticAnimated = false,
    AnimationOptions? animOptions,
    bool applyToImage = true, // New parameter with default true
    bool applyToText = true, // New parameter with default true
  }) : _chromaticEnabled = chromaticEnabled,
       _amount = amount,
       _angle = angle,
       _spread = spread,
       _intensity = intensity,
       _chromaticAnimated = chromaticAnimated,
       _animOptions = animOptions ?? AnimationOptions() {
    // Set the targeting flags
    this.applyToImage = applyToImage;
    this.applyToText = applyToText;

    if (enableLogging) print("SETTINGS: ChromaticSettings initialized");
  }

  // Serialization
  Map<String, dynamic> toMap() {
    final map = {
      'chromaticEnabled': _chromaticEnabled,
      'amount': _amount,
      'angle': _angle,
      'spread': _spread,
      'intensity': _intensity,
      'chromaticAnimated': _chromaticAnimated,
      'animOptions': _animOptions.toMap(),
    };

    // Add targeting flags from the mixin
    addTargetingToMap(map);

    return map;
  }

  factory ChromaticSettings.fromMap(Map<String, dynamic> map) {
    final settings = ChromaticSettings(
      chromaticEnabled: map['chromaticEnabled'] ?? false,
      amount: map['amount']?.toDouble() ?? 0.5,
      angle: map['angle']?.toDouble() ?? 0.0,
      spread: map['spread']?.toDouble() ?? 0.5,
      intensity: map['intensity']?.toDouble() ?? 0.5,
      chromaticAnimated: map['chromaticAnimated'] ?? false,
      animOptions: map['animOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['animOptions']),
            )
          : null,
    );

    // Load targeting flags from the map
    settings.loadTargetingFromMap(map);

    return settings;
  }
}
