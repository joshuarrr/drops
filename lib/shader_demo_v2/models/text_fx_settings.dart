import 'package:flutter/material.dart';
import 'animation_options.dart';
import 'targetable_effect_settings.dart';

class TextFXSettings extends ChangeNotifier with TargetableEffectSettings {
  // Update counter to track changes
  int _updateCounter = 0;
  int get updateCounter => _updateCounter;

  // Logging flag for debugging
  static bool enableLogging = false;

  // Enable flag for text effects
  bool _textfxEnabled;

  // Animation flag
  bool _textfxAnimated = false;

  // Animation options
  AnimationOptions _textfxAnimOptions = AnimationOptions();

  // Getter and setter for textfxAnimated
  bool get textfxAnimated => _textfxAnimated;
  set textfxAnimated(bool value) {
    if (_textfxAnimated == value) return;
    _textfxAnimated = value;
    _updateCounter++;
    notifyListeners();
  }

  // Animation options getter and setter
  AnimationOptions get textfxAnimOptions => _textfxAnimOptions;
  set textfxAnimOptions(AnimationOptions value) {
    _textfxAnimOptions = value;
    _updateCounter++;
    notifyListeners();
  }

  // Getter and setter for textfxEnabled with synchronization to applyToText
  bool get textfxEnabled => _textfxEnabled;
  set textfxEnabled(bool value) {
    if (_textfxEnabled == value) return;
    _textfxEnabled = value;
    // Keep applyToText in sync with textfxEnabled for consistent behavior
    super.applyToText = value;
    _updateCounter++;
    if (enableLogging)
      print(
        "SETTINGS: textfxEnabled set to $value and applyToText synced to $value",
      );
    notifyListeners();
  }

  // Shadow settings
  bool _textShadowEnabled; // Enable/disable text shadow
  double _textShadowBlur; // Shadow blur radius
  double _textShadowOffsetX; // Shadow offset X
  double _textShadowOffsetY; // Shadow offset Y
  Color _textShadowColor; // Shadow color
  double _textShadowOpacity; // Shadow opacity

  // Glow settings
  bool _textGlowEnabled; // Enable/disable text glow
  double _textGlowBlur; // Glow blur radius
  Color _textGlowColor; // Glow color
  double _textGlowOpacity; // Glow opacity

  // Outline settings
  bool _textOutlineEnabled; // Enable/disable text outline
  double _textOutlineWidth; // Outline width
  Color _textOutlineColor; // Outline color

  // Metal effect settings
  bool _textMetalEnabled; // Enable/disable metallic text
  double _textMetalShine; // Intensity of metallic shine (0-1)
  Color _textMetalBaseColor; // Base color for metal
  Color _textMetalShineColor; // Highlight color for shine

  // Glass effect settings
  bool _textGlassEnabled; // Enable/disable glass text
  double _textGlassOpacity; // Overall opacity (0-1)
  double _textGlassBlur; // Frosted glass blur amount
  Color _textGlassColor; // Tint color for the glass
  double _textGlassRefraction; // Refraction strength

  // Neon effect settings
  bool _textNeonEnabled; // Enable/disable neon text
  double _textNeonIntensity; // Neon glow intensity
  double _textNeonWidth; // Width of the neon tube
  Color _textNeonColor; // Primary neon color
  Color _textNeonOuterColor; // Outer glow color

  // Force notify method to trigger a rebuild
  void forceNotify() {
    _updateCounter++;
    if (enableLogging) {
      print(
        "SETTINGS: TextFXSettings forceNotify called, counter: $_updateCounter",
      );
    }
    notifyListeners();
  }

  // Shadow getters and setters
  bool get textShadowEnabled => _textShadowEnabled;
  set textShadowEnabled(bool value) {
    if (_textShadowEnabled == value) return;
    _textShadowEnabled = value;
    _updateCounter++;
    notifyListeners();
  }

  double get textShadowBlur => _textShadowBlur;
  set textShadowBlur(double value) {
    if (_textShadowBlur == value) return;
    _textShadowBlur = value;
    _updateCounter++;
    notifyListeners();
  }

  double get textShadowOffsetX => _textShadowOffsetX;
  set textShadowOffsetX(double value) {
    if (_textShadowOffsetX == value) return;
    _textShadowOffsetX = value;
    _updateCounter++;
    notifyListeners();
  }

  double get textShadowOffsetY => _textShadowOffsetY;
  set textShadowOffsetY(double value) {
    if (_textShadowOffsetY == value) return;
    _textShadowOffsetY = value;
    _updateCounter++;
    notifyListeners();
  }

  Color get textShadowColor => _textShadowColor;
  set textShadowColor(Color value) {
    if (_textShadowColor == value) return;
    _textShadowColor = value;
    _updateCounter++;
    notifyListeners();
  }

  double get textShadowOpacity => _textShadowOpacity;
  set textShadowOpacity(double value) {
    if (_textShadowOpacity == value) return;
    _textShadowOpacity = value;
    _updateCounter++;
    notifyListeners();
  }

  // Glow getters and setters
  bool get textGlowEnabled => _textGlowEnabled;
  set textGlowEnabled(bool value) {
    if (_textGlowEnabled == value) return;
    _textGlowEnabled = value;
    _updateCounter++;
    notifyListeners();
  }

  double get textGlowBlur => _textGlowBlur;
  set textGlowBlur(double value) {
    if (_textGlowBlur == value) return;
    _textGlowBlur = value;
    _updateCounter++;
    notifyListeners();
  }

  Color get textGlowColor => _textGlowColor;
  set textGlowColor(Color value) {
    if (_textGlowColor == value) return;
    _textGlowColor = value;
    _updateCounter++;
    notifyListeners();
  }

  double get textGlowOpacity => _textGlowOpacity;
  set textGlowOpacity(double value) {
    if (_textGlowOpacity == value) return;
    _textGlowOpacity = value;
    _updateCounter++;
    notifyListeners();
  }

  // Outline getters and setters
  bool get textOutlineEnabled => _textOutlineEnabled;
  set textOutlineEnabled(bool value) {
    if (_textOutlineEnabled == value) return;
    _textOutlineEnabled = value;
    _updateCounter++;
    notifyListeners();
  }

  double get textOutlineWidth => _textOutlineWidth;
  set textOutlineWidth(double value) {
    if (_textOutlineWidth == value) return;
    _textOutlineWidth = value;
    _updateCounter++;
    notifyListeners();
  }

  Color get textOutlineColor => _textOutlineColor;
  set textOutlineColor(Color value) {
    if (_textOutlineColor == value) return;
    _textOutlineColor = value;
    _updateCounter++;
    notifyListeners();
  }

  // Metal getters and setters
  bool get textMetalEnabled => _textMetalEnabled;
  set textMetalEnabled(bool value) {
    if (_textMetalEnabled == value) return;
    _textMetalEnabled = value;
    _updateCounter++;
    notifyListeners();
  }

  double get textMetalShine => _textMetalShine;
  set textMetalShine(double value) {
    if (_textMetalShine == value) return;
    _textMetalShine = value;
    _updateCounter++;
    notifyListeners();
  }

  Color get textMetalBaseColor => _textMetalBaseColor;
  set textMetalBaseColor(Color value) {
    if (_textMetalBaseColor == value) return;
    _textMetalBaseColor = value;
    _updateCounter++;
    notifyListeners();
  }

  Color get textMetalShineColor => _textMetalShineColor;
  set textMetalShineColor(Color value) {
    if (_textMetalShineColor == value) return;
    _textMetalShineColor = value;
    _updateCounter++;
    notifyListeners();
  }

  // Glass getters and setters
  bool get textGlassEnabled => _textGlassEnabled;
  set textGlassEnabled(bool value) {
    if (_textGlassEnabled == value) return;
    _textGlassEnabled = value;
    _updateCounter++;
    notifyListeners();
  }

  double get textGlassOpacity => _textGlassOpacity;
  set textGlassOpacity(double value) {
    if (_textGlassOpacity == value) return;
    _textGlassOpacity = value;
    _updateCounter++;
    notifyListeners();
  }

  double get textGlassBlur => _textGlassBlur;
  set textGlassBlur(double value) {
    if (_textGlassBlur == value) return;
    _textGlassBlur = value;
    _updateCounter++;
    notifyListeners();
  }

  Color get textGlassColor => _textGlassColor;
  set textGlassColor(Color value) {
    if (_textGlassColor == value) return;
    _textGlassColor = value;
    _updateCounter++;
    notifyListeners();
  }

  double get textGlassRefraction => _textGlassRefraction;
  set textGlassRefraction(double value) {
    if (_textGlassRefraction == value) return;
    _textGlassRefraction = value;
    _updateCounter++;
    notifyListeners();
  }

  // Neon getters and setters
  bool get textNeonEnabled => _textNeonEnabled;
  set textNeonEnabled(bool value) {
    if (_textNeonEnabled == value) return;
    _textNeonEnabled = value;
    _updateCounter++;
    notifyListeners();
  }

  double get textNeonIntensity => _textNeonIntensity;
  set textNeonIntensity(double value) {
    if (_textNeonIntensity == value) return;
    _textNeonIntensity = value;
    _updateCounter++;
    notifyListeners();
  }

  double get textNeonWidth => _textNeonWidth;
  set textNeonWidth(double value) {
    if (_textNeonWidth == value) return;
    _textNeonWidth = value;
    _updateCounter++;
    notifyListeners();
  }

  Color get textNeonColor => _textNeonColor;
  set textNeonColor(Color value) {
    if (_textNeonColor == value) return;
    _textNeonColor = value;
    _updateCounter++;
    notifyListeners();
  }

  Color get textNeonOuterColor => _textNeonOuterColor;
  set textNeonOuterColor(Color value) {
    if (_textNeonOuterColor == value) return;
    _textNeonOuterColor = value;
    _updateCounter++;
    notifyListeners();
  }

  // Constructor with default values
  TextFXSettings({
    bool textfxEnabled = false,
    bool textShadowEnabled = false,
    double textShadowBlur = 4.0,
    double textShadowOffsetX = 2.0,
    double textShadowOffsetY = 2.0,
    Color textShadowColor = Colors.black,
    double textShadowOpacity = 0.5,
    bool textGlowEnabled = false,
    double textGlowBlur = 10.0,
    Color textGlowColor = Colors.blue,
    double textGlowOpacity = 0.8,
    bool textOutlineEnabled = false,
    double textOutlineWidth = 2.0,
    Color textOutlineColor = Colors.black,
    bool textMetalEnabled = false,
    double textMetalShine = 0.7,
    Color textMetalBaseColor = const Color(0xFF8A8A8A),
    Color textMetalShineColor = Colors.white,
    bool textGlassEnabled = false,
    double textGlassOpacity = 0.8,
    double textGlassBlur = 5.0,
    Color textGlassColor = Colors.white,
    double textGlassRefraction = 0.5,
    bool textNeonEnabled = false,
    double textNeonIntensity = 1.0,
    double textNeonWidth = 0.02,
    Color textNeonColor = Colors.red,
    Color textNeonOuterColor = Colors.orange,
    bool textfxAnimated = false,
    AnimationOptions? textfxAnimOptions,
    bool applyToText = true,
  }) : // Initialize all properties
       _textfxEnabled = textfxEnabled,
       _textShadowEnabled = textShadowEnabled,
       _textShadowBlur = textShadowBlur,
       _textShadowOffsetX = textShadowOffsetX,
       _textShadowOffsetY = textShadowOffsetY,
       _textShadowColor = textShadowColor,
       _textShadowOpacity = textShadowOpacity,
       _textGlowEnabled = textGlowEnabled,
       _textGlowBlur = textGlowBlur,
       _textGlowColor = textGlowColor,
       _textGlowOpacity = textGlowOpacity,
       _textOutlineEnabled = textOutlineEnabled,
       _textOutlineWidth = textOutlineWidth,
       _textOutlineColor = textOutlineColor,
       _textMetalEnabled = textMetalEnabled,
       _textMetalShine = textMetalShine,
       _textMetalBaseColor = textMetalBaseColor,
       _textMetalShineColor = textMetalShineColor,
       _textGlassEnabled = textGlassEnabled,
       _textGlassOpacity = textGlassOpacity,
       _textGlassBlur = textGlassBlur,
       _textGlassColor = textGlassColor,
       _textGlassRefraction = textGlassRefraction,
       _textNeonEnabled = textNeonEnabled,
       _textNeonIntensity = textNeonIntensity,
       _textNeonWidth = textNeonWidth,
       _textNeonColor = textNeonColor,
       _textNeonOuterColor = textNeonOuterColor,
       _textfxAnimated = textfxAnimated,
       _textfxAnimOptions = textfxAnimOptions ?? AnimationOptions() {
    super.applyToText = applyToText;
  }

  // Method to deserialize from Map
  factory TextFXSettings.fromMap(Map<String, dynamic> map) {
    try {
      return TextFXSettings(
        textfxEnabled: map['textfxEnabled'] ?? false,
        textShadowEnabled: map['textShadowEnabled'] ?? false,
        textShadowBlur: (map['textShadowBlur'] ?? 4.0).toDouble(),
        textShadowOffsetX: (map['textShadowOffsetX'] ?? 2.0).toDouble(),
        textShadowOffsetY: (map['textShadowOffsetY'] ?? 2.0).toDouble(),
        textShadowColor: map['textShadowColor'] != null
            ? Color(map['textShadowColor'])
            : Colors.black,
        textShadowOpacity: (map['textShadowOpacity'] ?? 0.5).toDouble(),
        textGlowEnabled: map['textGlowEnabled'] ?? false,
        textGlowBlur: (map['textGlowBlur'] ?? 10.0).toDouble(),
        textGlowColor: map['textGlowColor'] != null
            ? Color(map['textGlowColor'])
            : Colors.blue,
        textGlowOpacity: (map['textGlowOpacity'] ?? 0.8).toDouble(),
        textOutlineEnabled: map['textOutlineEnabled'] ?? false,
        textOutlineWidth: (map['textOutlineWidth'] ?? 2.0).toDouble(),
        textOutlineColor: map['textOutlineColor'] != null
            ? Color(map['textOutlineColor'])
            : Colors.black,
        textMetalEnabled: map['textMetalEnabled'] ?? false,
        textMetalShine: (map['textMetalShine'] ?? 0.7).toDouble(),
        textMetalBaseColor: map['textMetalBaseColor'] != null
            ? Color(map['textMetalBaseColor'])
            : const Color(0xFF8A8A8A),
        textMetalShineColor: map['textMetalShineColor'] != null
            ? Color(map['textMetalShineColor'])
            : Colors.white,
        textGlassEnabled: map['textGlassEnabled'] ?? false,
        textGlassOpacity: (map['textGlassOpacity'] ?? 0.8).toDouble(),
        textGlassBlur: (map['textGlassBlur'] ?? 5.0).toDouble(),
        textGlassColor: map['textGlassColor'] != null
            ? Color(map['textGlassColor'])
            : Colors.white,
        textGlassRefraction: (map['textGlassRefraction'] ?? 0.5).toDouble(),
        textNeonEnabled: map['textNeonEnabled'] ?? false,
        textNeonIntensity: (map['textNeonIntensity'] ?? 1.0).toDouble(),
        textNeonWidth: (map['textNeonWidth'] ?? 0.02).toDouble(),
        textNeonColor: map['textNeonColor'] != null
            ? Color(map['textNeonColor'])
            : Colors.red,
        textNeonOuterColor: map['textNeonOuterColor'] != null
            ? Color(map['textNeonOuterColor'])
            : Colors.orange,
        textfxAnimated: map['textfxAnimated'] ?? false,
        textfxAnimOptions: map['textfxAnimOptions'] != null
            ? AnimationOptions.fromMap(
                Map<String, dynamic>.from(map['textfxAnimOptions']),
              )
            : null,
        applyToText: map['applyToText'] ?? true,
      );
    } catch (e) {
      print('Error deserializing TextFXSettings: $e');
      return TextFXSettings();
    }
  }

  // Method to serialize to Map
  Map<String, dynamic> toMap() {
    return {
      'textfxEnabled': _textfxEnabled,
      'textShadowEnabled': _textShadowEnabled,
      'textShadowBlur': _textShadowBlur,
      'textShadowOffsetX': _textShadowOffsetX,
      'textShadowOffsetY': _textShadowOffsetY,
      'textShadowColor': _textShadowColor.value,
      'textShadowOpacity': _textShadowOpacity,
      'textGlowEnabled': _textGlowEnabled,
      'textGlowBlur': _textGlowBlur,
      'textGlowColor': _textGlowColor.value,
      'textGlowOpacity': _textGlowOpacity,
      'textOutlineEnabled': _textOutlineEnabled,
      'textOutlineWidth': _textOutlineWidth,
      'textOutlineColor': _textOutlineColor.value,
      'textMetalEnabled': _textMetalEnabled,
      'textMetalShine': _textMetalShine,
      'textMetalBaseColor': _textMetalBaseColor.value,
      'textMetalShineColor': _textMetalShineColor.value,
      'textGlassEnabled': _textGlassEnabled,
      'textGlassOpacity': _textGlassOpacity,
      'textGlassBlur': _textGlassBlur,
      'textGlassColor': _textGlassColor.value,
      'textGlassRefraction': _textGlassRefraction,
      'textNeonEnabled': _textNeonEnabled,
      'textNeonIntensity': _textNeonIntensity,
      'textNeonWidth': _textNeonWidth,
      'textNeonColor': _textNeonColor.value,
      'textNeonOuterColor': _textNeonOuterColor.value,
      'textfxAnimated': _textfxAnimated,
      'textfxAnimOptions': _textfxAnimOptions.toMap(),
      'applyToText': applyToText,
    };
  }
}
