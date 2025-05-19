import 'package:flutter/material.dart';
import 'animation_options.dart';

class TextFXSettings extends ChangeNotifier {
  // Enable flag for text effects
  bool _textfxEnabled;

  // Flag to control if background shaders affect text
  bool _applyShaderEffectsToText;

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
  Color _textNeonColor; // Primary neon color
  Color _textNeonOuterColor; // Outer glow color
  double _textNeonIntensity; // Intensity of the neon effect
  double _textNeonWidth; // Width of the neon "tube"

  // Animation flag
  bool _textfxAnimated;

  // Animation options
  AnimationOptions _textfxAnimOptions;

  // Flag to control logging
  static bool enableLogging = false;

  // Counter for forcing rebuilds when properties change
  int _updateCounter = 0;
  int get updateCounter => _updateCounter;

  // Public method to increment counter
  void incrementCounter() {
    _updateCounter++;
    notifyListeners();
  }

  // Helper to safely get a color's value or default to white if null
  int _safeColorValue(Color? color) {
    return color?.value ?? Colors.white.value;
  }

  // Property getters and setters
  bool get textfxEnabled => _textfxEnabled;
  set textfxEnabled(bool value) {
    _textfxEnabled = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textfxEnabled set to $value");
    notifyListeners();
  }

  bool get applyShaderEffectsToText => _applyShaderEffectsToText;
  set applyShaderEffectsToText(bool value) {
    _applyShaderEffectsToText = value;
    _updateCounter++;
    if (enableLogging)
      print("SETTINGS: applyShaderEffectsToText set to $value");
    notifyListeners();
  }

  // Text effects getters and setters
  bool get textShadowEnabled => _textShadowEnabled;
  set textShadowEnabled(bool value) {
    _textShadowEnabled = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textShadowEnabled set to $value");
    notifyListeners();
  }

  double get textShadowBlur => _textShadowBlur;
  set textShadowBlur(double value) {
    _textShadowBlur = value;
    _updateCounter++;
    if (enableLogging) {
      print("SETTINGS: textShadowBlur set to ${value.toStringAsFixed(3)}");
    }
    notifyListeners();
  }

  double get textShadowOffsetX => _textShadowOffsetX;
  set textShadowOffsetX(double value) {
    _textShadowOffsetX = value;
    _updateCounter++;
    if (enableLogging) {
      print("SETTINGS: textShadowOffsetX set to ${value.toStringAsFixed(3)}");
    }
    notifyListeners();
  }

  double get textShadowOffsetY => _textShadowOffsetY;
  set textShadowOffsetY(double value) {
    _textShadowOffsetY = value;
    _updateCounter++;
    if (enableLogging) {
      print("SETTINGS: textShadowOffsetY set to ${value.toStringAsFixed(3)}");
    }
    notifyListeners();
  }

  Color get textShadowColor => _textShadowColor;
  set textShadowColor(Color value) {
    _textShadowColor = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textShadowColor set to $value");
    notifyListeners();
  }

  double get textShadowOpacity => _textShadowOpacity;
  set textShadowOpacity(double value) {
    _textShadowOpacity = value;
    _updateCounter++;
    if (enableLogging) {
      print("SETTINGS: textShadowOpacity set to ${value.toStringAsFixed(3)}");
    }
    notifyListeners();
  }

  bool get textGlowEnabled => _textGlowEnabled;
  set textGlowEnabled(bool value) {
    _textGlowEnabled = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textGlowEnabled set to $value");
    notifyListeners();
  }

  double get textGlowBlur => _textGlowBlur;
  set textGlowBlur(double value) {
    _textGlowBlur = value;
    _updateCounter++;
    if (enableLogging) {
      print("SETTINGS: textGlowBlur set to ${value.toStringAsFixed(3)}");
    }
    notifyListeners();
  }

  Color get textGlowColor => _textGlowColor;
  set textGlowColor(Color value) {
    _textGlowColor = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textGlowColor set to $value");
    notifyListeners();
  }

  double get textGlowOpacity => _textGlowOpacity;
  set textGlowOpacity(double value) {
    _textGlowOpacity = value;
    _updateCounter++;
    if (enableLogging) {
      print("SETTINGS: textGlowOpacity set to ${value.toStringAsFixed(3)}");
    }
    notifyListeners();
  }

  bool get textOutlineEnabled => _textOutlineEnabled;
  set textOutlineEnabled(bool value) {
    _textOutlineEnabled = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textOutlineEnabled set to $value");
    notifyListeners();
  }

  double get textOutlineWidth => _textOutlineWidth;
  set textOutlineWidth(double value) {
    _textOutlineWidth = value;
    _updateCounter++;
    if (enableLogging) {
      print("SETTINGS: textOutlineWidth set to ${value.toStringAsFixed(3)}");
    }
    notifyListeners();
  }

  Color get textOutlineColor => _textOutlineColor;
  set textOutlineColor(Color value) {
    _textOutlineColor = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textOutlineColor set to $value");
    notifyListeners();
  }

  bool get textfxAnimated => _textfxAnimated;
  set textfxAnimated(bool value) {
    _textfxAnimated = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textfxAnimated set to $value");
    notifyListeners();
  }

  // Metal effect getters and setters
  bool get textMetalEnabled => _textMetalEnabled;
  set textMetalEnabled(bool value) {
    _textMetalEnabled = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textMetalEnabled set to $value");
    notifyListeners();
  }

  double get textMetalShine => _textMetalShine;
  set textMetalShine(double value) {
    _textMetalShine = value;
    _updateCounter++;
    if (enableLogging) {
      print("SETTINGS: textMetalShine set to ${value.toStringAsFixed(3)}");
    }
    notifyListeners();
  }

  Color get textMetalBaseColor => _textMetalBaseColor;
  set textMetalBaseColor(Color value) {
    _textMetalBaseColor = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textMetalBaseColor set to $value");
    notifyListeners();
  }

  Color get textMetalShineColor => _textMetalShineColor;
  set textMetalShineColor(Color value) {
    _textMetalShineColor = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textMetalShineColor set to $value");
    notifyListeners();
  }

  // Glass effect getters and setters
  bool get textGlassEnabled => _textGlassEnabled;
  set textGlassEnabled(bool value) {
    _textGlassEnabled = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textGlassEnabled set to $value");
    notifyListeners();
  }

  double get textGlassOpacity => _textGlassOpacity;
  set textGlassOpacity(double value) {
    _textGlassOpacity = value;
    _updateCounter++;
    if (enableLogging) {
      print("SETTINGS: textGlassOpacity set to ${value.toStringAsFixed(3)}");
    }
    notifyListeners();
  }

  double get textGlassBlur => _textGlassBlur;
  set textGlassBlur(double value) {
    _textGlassBlur = value;
    _updateCounter++;
    if (enableLogging) {
      print("SETTINGS: textGlassBlur set to ${value.toStringAsFixed(3)}");
    }
    notifyListeners();
  }

  Color get textGlassColor => _textGlassColor;
  set textGlassColor(Color value) {
    _textGlassColor = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textGlassColor set to $value");
    notifyListeners();
  }

  double get textGlassRefraction => _textGlassRefraction;
  set textGlassRefraction(double value) {
    _textGlassRefraction = value;
    _updateCounter++;
    if (enableLogging) {
      print("SETTINGS: textGlassRefraction set to ${value.toStringAsFixed(3)}");
    }
    notifyListeners();
  }

  // Neon effect getters and setters
  bool get textNeonEnabled => _textNeonEnabled;
  set textNeonEnabled(bool value) {
    _textNeonEnabled = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textNeonEnabled set to $value");
    notifyListeners();
  }

  Color get textNeonColor => _textNeonColor;
  set textNeonColor(Color value) {
    _textNeonColor = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textNeonColor set to $value");
    notifyListeners();
  }

  Color get textNeonOuterColor => _textNeonOuterColor;
  set textNeonOuterColor(Color value) {
    _textNeonOuterColor = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textNeonOuterColor set to $value");
    notifyListeners();
  }

  double get textNeonIntensity => _textNeonIntensity;
  set textNeonIntensity(double value) {
    _textNeonIntensity = value;
    _updateCounter++;
    if (enableLogging) {
      print("SETTINGS: textNeonIntensity set to ${value.toStringAsFixed(3)}");
    }
    notifyListeners();
  }

  double get textNeonWidth => _textNeonWidth;
  set textNeonWidth(double value) {
    _textNeonWidth = value;
    _updateCounter++;
    if (enableLogging) {
      print("SETTINGS: textNeonWidth set to ${value.toStringAsFixed(3)}");
    }
    notifyListeners();
  }

  AnimationOptions get textfxAnimOptions => _textfxAnimOptions;
  set textfxAnimOptions(AnimationOptions value) {
    _textfxAnimOptions = value;
    _updateCounter++;
    if (enableLogging) print("SETTINGS: textfxAnimOptions updated");
    notifyListeners();
  }

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

  TextFXSettings({
    bool textfxEnabled = false,
    bool applyShaderEffectsToText = false,
    bool textShadowEnabled = false,
    double textShadowBlur = 3.0,
    double textShadowOffsetX = 2.0,
    double textShadowOffsetY = 2.0,
    Color textShadowColor = Colors.black,
    double textShadowOpacity = 0.7,
    bool textGlowEnabled = false,
    double textGlowBlur = 5.0,
    Color textGlowColor = Colors.white,
    double textGlowOpacity = 0.7,
    bool textOutlineEnabled = false,
    double textOutlineWidth = 1.0,
    Color textOutlineColor = Colors.black,
    bool textMetalEnabled = false,
    double textMetalShine = 0.5,
    Color textMetalBaseColor = Colors.white,
    Color textMetalShineColor = Colors.yellow,
    bool textGlassEnabled = false,
    double textGlassOpacity = 0.7,
    double textGlassBlur = 5.0,
    Color textGlassColor = Colors.white,
    double textGlassRefraction = 1.0,
    bool textNeonEnabled = false,
    Color textNeonColor = Colors.white,
    Color textNeonOuterColor = Colors.white,
    double textNeonIntensity = 1.0,
    double textNeonWidth = 0.01,
    bool textfxAnimated = false,
    AnimationOptions? textfxAnimOptions,
  }) : _textfxEnabled = textfxEnabled,
       _applyShaderEffectsToText = applyShaderEffectsToText,
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
       _textNeonColor = textNeonColor,
       _textNeonOuterColor = textNeonOuterColor,
       _textNeonIntensity = textNeonIntensity,
       _textNeonWidth = textNeonWidth,
       _textfxAnimated = textfxAnimated,
       _textfxAnimOptions = textfxAnimOptions ?? AnimationOptions() {
    if (enableLogging) print("SETTINGS: TextFXSettings initialized");
  }

  // Serialization helpers
  Map<String, dynamic> toMap() {
    return {
      'textfxEnabled': _textfxEnabled,
      'applyShaderEffectsToText': _applyShaderEffectsToText,
      'textShadowEnabled': _textShadowEnabled,
      'textShadowBlur': _textShadowBlur,
      'textShadowOffsetX': _textShadowOffsetX,
      'textShadowOffsetY': _textShadowOffsetY,
      'textShadowColor': _safeColorValue(_textShadowColor),
      'textShadowOpacity': _textShadowOpacity,
      'textGlowEnabled': _textGlowEnabled,
      'textGlowBlur': _textGlowBlur,
      'textGlowColor': _safeColorValue(_textGlowColor),
      'textGlowOpacity': _textGlowOpacity,
      'textOutlineEnabled': _textOutlineEnabled,
      'textOutlineWidth': _textOutlineWidth,
      'textOutlineColor': _safeColorValue(_textOutlineColor),
      'textMetalEnabled': _textMetalEnabled,
      'textMetalShine': _textMetalShine,
      'textMetalBaseColor': _safeColorValue(_textMetalBaseColor),
      'textMetalShineColor': _safeColorValue(_textMetalShineColor),
      'textGlassEnabled': _textGlassEnabled,
      'textGlassOpacity': _textGlassOpacity,
      'textGlassBlur': _textGlassBlur,
      'textGlassColor': _safeColorValue(_textGlassColor),
      'textGlassRefraction': _textGlassRefraction,
      'textNeonEnabled': _textNeonEnabled,
      'textNeonColor': _safeColorValue(_textNeonColor),
      'textNeonOuterColor': _safeColorValue(_textNeonOuterColor),
      'textNeonIntensity': _textNeonIntensity,
      'textNeonWidth': _textNeonWidth,
      'textfxAnimated': _textfxAnimated,
      'textfxAnimOptions': _textfxAnimOptions.toMap(),
    };
  }

  factory TextFXSettings.fromMap(Map<String, dynamic> map) {
    return TextFXSettings(
      textfxEnabled: map['textfxEnabled'] ?? false,
      applyShaderEffectsToText: map['applyShaderEffectsToText'] ?? false,
      textShadowEnabled: map['textShadowEnabled'] ?? false,
      textShadowBlur: map['textShadowBlur'] ?? 3.0,
      textShadowOffsetX: map['textShadowOffsetX'] ?? 2.0,
      textShadowOffsetY: map['textShadowOffsetY'] ?? 2.0,
      textShadowColor: map['textShadowColor'] != null
          ? Color(map['textShadowColor'])
          : Colors.black,
      textShadowOpacity: map['textShadowOpacity'] ?? 0.7,
      textGlowEnabled: map['textGlowEnabled'] ?? false,
      textGlowBlur: map['textGlowBlur'] ?? 5.0,
      textGlowColor: map['textGlowColor'] != null
          ? Color(map['textGlowColor'])
          : Colors.white,
      textGlowOpacity: map['textGlowOpacity'] ?? 0.7,
      textOutlineEnabled: map['textOutlineEnabled'] ?? false,
      textOutlineWidth: map['textOutlineWidth'] ?? 1.0,
      textOutlineColor: map['textOutlineColor'] != null
          ? Color(map['textOutlineColor'])
          : Colors.black,
      textMetalEnabled: map['textMetalEnabled'] ?? false,
      textMetalShine: map['textMetalShine'] ?? 0.5,
      textMetalBaseColor: map['textMetalBaseColor'] != null
          ? Color(map['textMetalBaseColor'])
          : Colors.white,
      textMetalShineColor: map['textMetalShineColor'] != null
          ? Color(map['textMetalShineColor'])
          : Colors.yellow,
      textGlassEnabled: map['textGlassEnabled'] ?? false,
      textGlassOpacity: map['textGlassOpacity'] ?? 0.7,
      textGlassBlur: map['textGlassBlur'] ?? 5.0,
      textGlassColor: map['textGlassColor'] != null
          ? Color(map['textGlassColor'])
          : Colors.white,
      textGlassRefraction: map['textGlassRefraction'] ?? 1.0,
      textNeonEnabled: map['textNeonEnabled'] ?? false,
      textNeonColor: map['textNeonColor'] != null
          ? Color(map['textNeonColor'])
          : Colors.white,
      textNeonOuterColor: map['textNeonOuterColor'] != null
          ? Color(map['textNeonOuterColor'])
          : Colors.white,
      textNeonIntensity: map['textNeonIntensity'] ?? 1.0,
      textNeonWidth: map['textNeonWidth'] ?? 0.01,
      textfxAnimated: map['textfxAnimated'] ?? false,
      textfxAnimOptions: map['textfxAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['textfxAnimOptions']),
            )
          : null,
    );
  }
}
