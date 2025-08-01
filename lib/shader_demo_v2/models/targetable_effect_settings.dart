import 'package:flutter/material.dart';

/// A mixin class for effect settings that adds properties for targeting
/// the effect to specific content types (image or text).
///
/// This allows for granular control over where each shader effect is applied.
mixin TargetableEffectSettings {
  // Target flags with defaults (both true as requested)
  bool _applyToImage = true;
  bool _applyToText = true;

  // Enable logging of changes if needed
  static bool enableLogging = false;

  // Getters and setters for the target flags
  bool get applyToImage => _applyToImage;
  set applyToImage(bool value) {
    _applyToImage = value;
    if (enableLogging) {
      debugPrint("SETTINGS: applyToImage set to $value");
    }
  }

  bool get applyToText => _applyToText;
  set applyToText(bool value) {
    _applyToText = value;
    if (enableLogging) {
      debugPrint("SETTINGS: applyToText set to $value");
    }
  }

  // Utility methods for serialization

  /// Add target flags to a settings map
  void addTargetingToMap(Map<String, dynamic> map) {
    map['applyToImage'] = _applyToImage;
    map['applyToText'] = _applyToText;
  }

  /// Load target flags from a settings map
  void loadTargetingFromMap(Map<String, dynamic> map) {
    _applyToImage = map['applyToImage'] ?? true;
    _applyToText = map['applyToText'] ?? true;
  }
}
