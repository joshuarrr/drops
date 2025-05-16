import 'package:flutter/material.dart';
import 'animation_options.dart';

class ColorSettings {
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
    if (enableLogging) print("SETTINGS: colorEnabled set to $value");
  }

  // Color settings with logging
  double get hue => _hue;
  set hue(double value) {
    _hue = value;
    if (enableLogging) {
      print("SETTINGS: hue set to ${value.toStringAsFixed(3)}");
    }
  }

  double get saturation => _saturation;
  set saturation(double value) {
    _saturation = value;
    if (enableLogging) {
      print("SETTINGS: saturation set to ${value.toStringAsFixed(3)}");
    }
  }

  double get lightness => _lightness;
  set lightness(double value) {
    _lightness = value;
    if (enableLogging) {
      print("SETTINGS: lightness set to ${value.toStringAsFixed(3)}");
    }
  }

  double get overlayHue => _overlayHue;
  set overlayHue(double value) {
    _overlayHue = value;
    if (enableLogging) {
      print("SETTINGS: overlayHue set to ${value.toStringAsFixed(3)}");
    }
  }

  double get overlayIntensity => _overlayIntensity;
  set overlayIntensity(double value) {
    _overlayIntensity = value;
    if (enableLogging) {
      print("SETTINGS: overlayIntensity set to ${value.toStringAsFixed(3)}");
    }
  }

  double get overlayOpacity => _overlayOpacity;
  set overlayOpacity(double value) {
    _overlayOpacity = value;
    if (enableLogging) {
      print("SETTINGS: overlayOpacity set to ${value.toStringAsFixed(3)}");
    }
  }

  // Color animation toggle with logging
  bool get colorAnimated => _colorAnimated;
  set colorAnimated(bool value) {
    _colorAnimated = value;
    if (enableLogging) print("SETTINGS: colorAnimated set to $value");
  }

  // Overlay animation toggle with logging
  bool get overlayAnimated => _overlayAnimated;
  set overlayAnimated(bool value) {
    _overlayAnimated = value;
    if (enableLogging) print("SETTINGS: overlayAnimated set to $value");
  }

  AnimationOptions get colorAnimOptions => _colorAnimOptions;
  set colorAnimOptions(AnimationOptions value) {
    _colorAnimOptions = value;
    if (enableLogging) print("SETTINGS: colorAnimOptions updated");
  }

  AnimationOptions get overlayAnimOptions => _overlayAnimOptions;
  set overlayAnimOptions(AnimationOptions value) {
    _overlayAnimOptions = value;
    if (enableLogging) print("SETTINGS: overlayAnimOptions updated");
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
    if (enableLogging) print("SETTINGS: ColorSettings initialized");
  }

  // Serialization helpers
  Map<String, dynamic> toMap() {
    return {
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
  }

  factory ColorSettings.fromMap(Map<String, dynamic> map) {
    return ColorSettings(
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
  }
}
