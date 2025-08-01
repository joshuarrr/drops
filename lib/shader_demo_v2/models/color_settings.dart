import 'package:flutter/material.dart';
import 'animation_options.dart';
import 'targetable_effect_settings.dart';

class ColorSettings with TargetableEffectSettings {
  // Enable flags for color effects
  bool _colorEnabled;

  // Color settings
  double _hue;
  double _saturation;
  double _lightness;
  double _overlayHue;
  double _overlayIntensity;
  double _overlayOpacity;

  // Animation flags for color effects
  bool _colorAnimated;
  bool _overlayAnimated;

  // Animation options
  AnimationOptions _colorAnimOptions;
  AnimationOptions _overlayAnimOptions;

  // Flag to control logging
  static bool enableLogging = false;

  // Property getters and setters
  bool get colorEnabled => _colorEnabled;
  set colorEnabled(bool value) {
    _colorEnabled = value;
  }

  // Color settings with logging
  double get hue => _hue;
  set hue(double value) {
    _hue = value;
  }

  double get saturation => _saturation;
  set saturation(double value) {
    _saturation = value;
  }

  double get lightness => _lightness;
  set lightness(double value) {
    _lightness = value;
  }

  double get overlayHue => _overlayHue;
  set overlayHue(double value) {
    _overlayHue = value;
  }

  double get overlayIntensity => _overlayIntensity;
  set overlayIntensity(double value) {
    _overlayIntensity = value;
  }

  double get overlayOpacity => _overlayOpacity;
  set overlayOpacity(double value) {
    _overlayOpacity = value;
  }

  // Color animation toggle with logging
  bool get colorAnimated => _colorAnimated;
  set colorAnimated(bool value) {
    _colorAnimated = value;
  }

  // Overlay animation toggle with logging
  bool get overlayAnimated => _overlayAnimated;
  set overlayAnimated(bool value) {
    _overlayAnimated = value;
  }

  AnimationOptions get colorAnimOptions => _colorAnimOptions;
  set colorAnimOptions(AnimationOptions value) {
    _colorAnimOptions = value;
  }

  AnimationOptions get overlayAnimOptions => _overlayAnimOptions;
  set overlayAnimOptions(AnimationOptions value) {
    _overlayAnimOptions = value;
  }

  ColorSettings({
    bool colorEnabled = false,
    double hue = 0.0,
    double saturation = 0.0,
    double lightness = 0.0,
    double overlayHue = 0.0,
    double overlayIntensity = 0.0,
    double overlayOpacity = 0.0,
    bool colorAnimated = false,
    bool overlayAnimated = false,
    AnimationOptions? colorAnimOptions,
    AnimationOptions? overlayAnimOptions,
    bool applyToImage = true,
    bool applyToText = true,
  }) : _colorEnabled = colorEnabled,
       _hue = hue,
       _saturation = saturation,
       _lightness = lightness,
       _overlayHue = overlayHue,
       _overlayIntensity = overlayIntensity,
       _overlayOpacity = overlayOpacity,
       _colorAnimated = colorAnimated,
       _overlayAnimated = overlayAnimated,
       _colorAnimOptions = colorAnimOptions ?? AnimationOptions(),
       _overlayAnimOptions = overlayAnimOptions ?? AnimationOptions() {
    this.applyToImage = applyToImage;
    this.applyToText = applyToText;
  }

  // Serialization helpers
  Map<String, dynamic> toMap() {
    final map = {
      'colorEnabled': _colorEnabled,
      'hue': _hue,
      'saturation': _saturation,
      'lightness': _lightness,
      'overlayHue': _overlayHue,
      'overlayIntensity': _overlayIntensity,
      'overlayOpacity': _overlayOpacity,
      'colorAnimated': _colorAnimated,
      'overlayAnimated': _overlayAnimated,
      'colorAnimOptions': _colorAnimOptions.toMap(),
      'overlayAnimOptions': _overlayAnimOptions.toMap(),
    };

    addTargetingToMap(map);

    return map;
  }

  factory ColorSettings.fromMap(Map<String, dynamic> map) {
    final settings = ColorSettings(
      colorEnabled: map['colorEnabled'] ?? false,
      hue: map['hue'] ?? 0.0,
      saturation: map['saturation'] ?? 0.0,
      lightness: map['lightness'] ?? 0.0,
      overlayHue: map['overlayHue'] ?? 0.0,
      overlayIntensity: map['overlayIntensity'] ?? 0.0,
      overlayOpacity: map['overlayOpacity'] ?? 0.0,
      colorAnimated: map['colorAnimated'] ?? false,
      overlayAnimated: map['overlayAnimated'] ?? false,
      colorAnimOptions: map['colorAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['colorAnimOptions']),
            )
          : null,
      overlayAnimOptions: map['overlayAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['overlayAnimOptions']),
            )
          : null,
    );

    settings.loadTargetingFromMap(map);

    return settings;
  }
}
