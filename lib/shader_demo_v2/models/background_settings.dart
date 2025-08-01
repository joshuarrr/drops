import 'package:flutter/material.dart';
import 'animation_options.dart';

class BackgroundSettings {
  // Enable flag for background
  bool _backgroundEnabled;

  // Background color
  Color _backgroundColor;

  // Animation flag
  bool _backgroundAnimated;

  // Animation options
  AnimationOptions _backgroundAnimOptions;

  // Flag to control logging
  static bool enableLogging = true;

  // Property getters and setters
  bool get backgroundEnabled => _backgroundEnabled;
  set backgroundEnabled(bool value) {
    _backgroundEnabled = value;
    if (enableLogging) print("SETTINGS: backgroundEnabled set to $value");
  }

  Color get backgroundColor => _backgroundColor;
  set backgroundColor(Color value) {
    _backgroundColor = value;
    if (enableLogging) {
      print("SETTINGS: backgroundColor set to ${value.toString()}");
    }
  }

  // Background animation toggle with logging
  bool get backgroundAnimated => _backgroundAnimated;
  set backgroundAnimated(bool value) {
    _backgroundAnimated = value;
    if (enableLogging) print("SETTINGS: backgroundAnimated set to $value");
  }

  // Animation options
  AnimationOptions get backgroundAnimOptions => _backgroundAnimOptions;
  set backgroundAnimOptions(AnimationOptions value) {
    _backgroundAnimOptions = value;
    if (enableLogging) print("SETTINGS: backgroundAnimOptions updated");
  }

  // Constructor with default values
  BackgroundSettings({
    bool backgroundEnabled = false,
    Color? backgroundColor,
    bool backgroundAnimated = false,
    AnimationOptions? backgroundAnimOptions,
  }) : _backgroundEnabled = backgroundEnabled,
       _backgroundColor = backgroundColor ?? Colors.black,
       _backgroundAnimated = backgroundAnimated,
       _backgroundAnimOptions = backgroundAnimOptions ?? AnimationOptions();

  // Create a map of the settings for serialization
  Map<String, dynamic> toMap() {
    return {
      'backgroundEnabled': _backgroundEnabled,
      'backgroundColor': _backgroundColor.value,
      'backgroundAnimated': _backgroundAnimated,
      'backgroundAnimOptions': _backgroundAnimOptions.toMap(),
    };
  }

  // Create settings from a map (deserialization)
  factory BackgroundSettings.fromMap(
    Map<String, dynamic> map, {
    bool skipLogging = false,
  }) {
    // Check if backgroundColor is explicitly null or missing
    Color backgroundColor;
    if (map.containsKey('backgroundColor') && map['backgroundColor'] != null) {
      backgroundColor = Color(map['backgroundColor']);
    } else {
      // This is the issue - defaulting to black when the color is missing
      // We should preserve the existing color or use a more sensible default
      backgroundColor = Colors.black;
    }

    if (enableLogging && !skipLogging) {
      print(
        "SETTINGS: BackgroundSettings.fromMap loaded backgroundColor: 0x${backgroundColor.value.toRadixString(16).padLeft(8, '0')}",
      );
    }

    return BackgroundSettings(
      backgroundEnabled: map['backgroundEnabled'] ?? false,
      backgroundColor: backgroundColor,
      backgroundAnimated: map['backgroundAnimated'] ?? false,
      backgroundAnimOptions: map['backgroundAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['backgroundAnimOptions']),
            )
          : null,
    );
  }

  // Create a copy of the settings
  BackgroundSettings copy() {
    return BackgroundSettings(
      backgroundEnabled: _backgroundEnabled,
      backgroundColor: _backgroundColor,
      backgroundAnimated: _backgroundAnimated,
      backgroundAnimOptions: _backgroundAnimOptions.copyWith(),
    );
  }
}
