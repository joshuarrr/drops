import 'animation_options.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/material.dart' show Colors;

// Class to store all shader effect settings
class ShaderSettings {
  // Enable flags for each aspect
  bool _colorEnabled;
  bool _blurEnabled;
  bool _noiseEnabled; // New flag for noise effect
  bool _textfxEnabled; // New flag for text effects

  // Color settings
  double _hue;
  double _saturation;
  double _lightness;
  double _overlayHue;
  double _overlayIntensity;
  double _overlayOpacity;

  // Blur settings
  double _blurAmount;
  double _blurRadius;

  // Additional shatter settings
  double _blurOpacity; // 0-1 opacity applied to effect
  int _blurBlendMode; // 0=normal,1=multiply,2=screen
  double _blurIntensity; // Amplifies the intensity of shatter fragments
  double _blurContrast; // Increases contrast between fragments

  // Noise effect settings
  double _noiseScale; // Scale of the noise pattern
  double _noiseSpeed; // Speed of the animation
  double _colorIntensity; // Intensity of the color overlay
  double _waveAmount; // Amount of wave distortion
  bool _noiseAnimated; // Animation flag for noise effect

  // Text effects settings
  bool _textShadowEnabled; // Enable/disable text shadow
  double _textShadowBlur; // Shadow blur radius
  double _textShadowOffsetX; // Shadow offset X
  double _textShadowOffsetY; // Shadow offset Y
  Color _textShadowColor; // Shadow color
  double _textShadowOpacity; // Shadow opacity

  bool _textGlowEnabled; // Enable/disable text glow
  double _textGlowBlur; // Glow blur radius
  Color _textGlowColor; // Glow color
  double _textGlowOpacity; // Glow opacity

  bool _textOutlineEnabled; // Enable/disable text outline
  double _textOutlineWidth; // Outline width
  Color _textOutlineColor; // Outline color

  // Advanced text effects
  bool _textMetalEnabled; // Enable/disable metallic text
  double _textMetalShine; // Intensity of metallic shine (0-1)
  Color _textMetalBaseColor; // Base color for metal
  Color _textMetalShineColor; // Highlight color for shine

  bool _textGlassEnabled; // Enable/disable glass text
  double _textGlassOpacity; // Overall opacity (0-1)
  double _textGlassBlur; // Frosted glass blur amount
  Color _textGlassColor; // Tint color for the glass
  double _textGlassRefraction; // Refraction strength

  bool _textNeonEnabled; // Enable/disable neon text
  Color _textNeonColor; // Primary neon color
  Color _textNeonOuterColor; // Outer glow color
  double _textNeonIntensity; // Intensity of the neon effect
  double _textNeonWidth; // Width of the neon "tube"

  // Animation flag for text fx effect
  bool _textfxAnimated;

  // Animation flag for blur (shatter) effect
  bool _blurAnimated;

  // Animation flag for color effect
  bool _colorAnimated;

  // Animation flag for overlay color
  bool _overlayAnimated;

  // Image setting
  bool _fillScreen;

  // Text settings
  bool _textEnabled;
  String _textTitle;
  String _textSubtitle;
  String _textArtist;
  String _textFont;
  double _textSize;
  double _textPosX;
  double _textPosY;
  Color _textColor; // Default text color for all text elements

  // Per-line styling (independent font, size, position)
  String _titleFont;
  double _titleSize;
  double _titlePosX;
  double _titlePosY;
  Color _titleColor; // Title-specific color

  String _subtitleFont;
  double _subtitleSize;
  double _subtitlePosX;
  double _subtitlePosY;
  Color _subtitleColor; // Subtitle-specific color

  String _artistFont;
  double _artistSize;
  double _artistPosX;
  double _artistPosY;
  Color _artistColor; // Artist-specific color

  // Weight settings
  int _textWeight; // 100-900 (default 400)
  int _titleWeight;
  int _subtitleWeight;
  int _artistWeight;

  // Text layout settings
  bool _textFitToWidth; // General setting for all text
  int _textHAlign; // 0=left, 1=center, 2=right
  int _textVAlign; // 0=top, 1=middle, 2=bottom
  double _textLineHeight; // Multiplier for line height (default 1.2)

  // Per-line fit and alignment
  bool _titleFitToWidth;
  int _titleHAlign; // 0=left, 1=center, 2=right
  int _titleVAlign; // 0=top, 1=middle, 2=bottom
  double _titleLineHeight; // Line height multiplier

  bool _subtitleFitToWidth;
  int _subtitleHAlign;
  int _subtitleVAlign;
  double _subtitleLineHeight;

  bool _artistFitToWidth;
  int _artistHAlign;
  int _artistVAlign;
  double _artistLineHeight;

  // Flag to control logging
  static bool enableLogging = false;

  // Property getters and setters
  bool get colorEnabled => _colorEnabled;
  set colorEnabled(bool value) {
    _colorEnabled = value;
    if (enableLogging) print("SETTINGS: colorEnabled set to $value");
  }

  bool get blurEnabled => _blurEnabled;
  set blurEnabled(bool value) {
    _blurEnabled = value;
    if (enableLogging) print("SETTINGS: blurEnabled set to $value");
  }

  bool get noiseEnabled => _noiseEnabled;
  set noiseEnabled(bool value) {
    _noiseEnabled = value;
    if (enableLogging) print("SETTINGS: noiseEnabled set to $value");
  }

  bool get textfxEnabled => _textfxEnabled;
  set textfxEnabled(bool value) {
    _textfxEnabled = value;
    if (enableLogging) print("SETTINGS: textfxEnabled set to $value");
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

  // Noise effect getters and setters
  double get noiseScale => _noiseScale;
  set noiseScale(double value) {
    _noiseScale = value;
    if (enableLogging) {
      print("SETTINGS: noiseScale set to ${value.toStringAsFixed(3)}");
    }
  }

  double get noiseSpeed => _noiseSpeed;
  set noiseSpeed(double value) {
    _noiseSpeed = value;
    if (enableLogging) {
      print("SETTINGS: noiseSpeed set to ${value.toStringAsFixed(3)}");
    }
  }

  double get colorIntensity => _colorIntensity;
  set colorIntensity(double value) {
    _colorIntensity = value;
    if (enableLogging) {
      print("SETTINGS: colorIntensity set to ${value.toStringAsFixed(3)}");
    }
  }

  double get waveAmount => _waveAmount;
  set waveAmount(double value) {
    _waveAmount = value;
    if (enableLogging) {
      print("SETTINGS: waveAmount set to ${value.toStringAsFixed(3)}");
    }
  }

  bool get noiseAnimated => _noiseAnimated;
  set noiseAnimated(bool value) {
    _noiseAnimated = value;
    if (enableLogging) print("SETTINGS: noiseAnimated set to $value");
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

  // Text effects getters and setters
  bool get textShadowEnabled => _textShadowEnabled;
  set textShadowEnabled(bool value) {
    _textShadowEnabled = value;
    if (enableLogging) print("SETTINGS: textShadowEnabled set to $value");
  }

  double get textShadowBlur => _textShadowBlur;
  set textShadowBlur(double value) {
    _textShadowBlur = value;
    if (enableLogging) {
      print("SETTINGS: textShadowBlur set to ${value.toStringAsFixed(3)}");
    }
  }

  double get textShadowOffsetX => _textShadowOffsetX;
  set textShadowOffsetX(double value) {
    _textShadowOffsetX = value;
    if (enableLogging) {
      print("SETTINGS: textShadowOffsetX set to ${value.toStringAsFixed(3)}");
    }
  }

  double get textShadowOffsetY => _textShadowOffsetY;
  set textShadowOffsetY(double value) {
    _textShadowOffsetY = value;
    if (enableLogging) {
      print("SETTINGS: textShadowOffsetY set to ${value.toStringAsFixed(3)}");
    }
  }

  Color get textShadowColor => _textShadowColor;
  set textShadowColor(Color value) {
    _textShadowColor = value;
    if (enableLogging) print("SETTINGS: textShadowColor set to $value");
  }

  double get textShadowOpacity => _textShadowOpacity;
  set textShadowOpacity(double value) {
    _textShadowOpacity = value;
    if (enableLogging) {
      print("SETTINGS: textShadowOpacity set to ${value.toStringAsFixed(3)}");
    }
  }

  bool get textGlowEnabled => _textGlowEnabled;
  set textGlowEnabled(bool value) {
    _textGlowEnabled = value;
    if (enableLogging) print("SETTINGS: textGlowEnabled set to $value");
  }

  double get textGlowBlur => _textGlowBlur;
  set textGlowBlur(double value) {
    _textGlowBlur = value;
    if (enableLogging) {
      print("SETTINGS: textGlowBlur set to ${value.toStringAsFixed(3)}");
    }
  }

  Color get textGlowColor => _textGlowColor;
  set textGlowColor(Color value) {
    _textGlowColor = value;
    if (enableLogging) print("SETTINGS: textGlowColor set to $value");
  }

  double get textGlowOpacity => _textGlowOpacity;
  set textGlowOpacity(double value) {
    _textGlowOpacity = value;
    if (enableLogging) {
      print("SETTINGS: textGlowOpacity set to ${value.toStringAsFixed(3)}");
    }
  }

  bool get textOutlineEnabled => _textOutlineEnabled;
  set textOutlineEnabled(bool value) {
    _textOutlineEnabled = value;
    if (enableLogging) print("SETTINGS: textOutlineEnabled set to $value");
  }

  double get textOutlineWidth => _textOutlineWidth;
  set textOutlineWidth(double value) {
    _textOutlineWidth = value;
    if (enableLogging) {
      print("SETTINGS: textOutlineWidth set to ${value.toStringAsFixed(3)}");
    }
  }

  Color get textOutlineColor => _textOutlineColor;
  set textOutlineColor(Color value) {
    _textOutlineColor = value;
    if (enableLogging) print("SETTINGS: textOutlineColor set to $value");
  }

  bool get textfxAnimated => _textfxAnimated;
  set textfxAnimated(bool value) {
    _textfxAnimated = value;
    if (enableLogging) print("SETTINGS: textfxAnimated set to $value");
  }

  // Blur animation toggle with logging
  bool get blurAnimated => _blurAnimated;
  set blurAnimated(bool value) {
    _blurAnimated = value;
    if (enableLogging) print("SETTINGS: blurAnimated set to $value");
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

  // New shatter settings with logging
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

  // New intensity and contrast controls
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

  bool get fillScreen => _fillScreen;
  set fillScreen(bool value) {
    _fillScreen = value;
    if (enableLogging) print("SETTINGS: fillScreen set to $value");
  }

  // Text getters/setters
  bool get textEnabled => _textEnabled;
  set textEnabled(bool value) {
    _textEnabled = value;
    if (enableLogging) print("SETTINGS: textEnabled set to $value");
  }

  String get textTitle => _textTitle;
  set textTitle(String value) {
    _textTitle = value;
    if (enableLogging) print("SETTINGS: textTitle set to $value");
  }

  String get textSubtitle => _textSubtitle;
  set textSubtitle(String value) {
    _textSubtitle = value;
    if (enableLogging) print("SETTINGS: textSubtitle set to $value");
  }

  String get textArtist => _textArtist;
  set textArtist(String value) {
    _textArtist = value;
    if (enableLogging) print("SETTINGS: textArtist set to $value");
  }

  String get textFont => _textFont;
  set textFont(String value) {
    _textFont = value;
    if (enableLogging) print("SETTINGS: textFont set to $value");
  }

  double get textSize => _textSize;
  set textSize(double value) {
    _textSize = value;
    if (enableLogging) print("SETTINGS: textSize set to $value");
  }

  double get textPosX => _textPosX;
  set textPosX(double value) {
    _textPosX = value;
    if (enableLogging) print("SETTINGS: textPosX set to $value");
  }

  double get textPosY => _textPosY;
  set textPosY(double value) {
    _textPosY = value;
    if (enableLogging) print("SETTINGS: textPosY set to $value");
  }

  // Weight getters/setters
  int get textWeight => _textWeight;
  set textWeight(int v) {
    _textWeight = v;
    if (enableLogging) print("SETTINGS: textWeight set to $v");
  }

  int get titleWeight => _titleWeight;
  set titleWeight(int v) {
    _titleWeight = v;
    if (enableLogging) print("SETTINGS: titleWeight set to $v");
  }

  int get subtitleWeight => _subtitleWeight;
  set subtitleWeight(int v) {
    _subtitleWeight = v;
    if (enableLogging) print("SETTINGS: subtitleWeight set to $v");
  }

  int get artistWeight => _artistWeight;
  set artistWeight(int v) {
    _artistWeight = v;
    if (enableLogging) print("SETTINGS: artistWeight set to $v");
  }

  // --------------------- Per-line getters/setters ---------------------
  String get titleFont => _titleFont;
  set titleFont(String v) {
    _titleFont = v;
    if (enableLogging) print("SETTINGS: titleFont set to $v");
  }

  double get titleSize => _titleSize;
  set titleSize(double v) {
    _titleSize = v;
    if (enableLogging) print("SETTINGS: titleSize set to $v");
  }

  double get titlePosX => _titlePosX;
  set titlePosX(double v) {
    _titlePosX = v;
    if (enableLogging) print("SETTINGS: titlePosX set to $v");
  }

  double get titlePosY => _titlePosY;
  set titlePosY(double v) {
    _titlePosY = v;
    if (enableLogging) print("SETTINGS: titlePosY set to $v");
  }

  String get subtitleFont => _subtitleFont;
  set subtitleFont(String v) {
    _subtitleFont = v;
    if (enableLogging) print("SETTINGS: subtitleFont set to $v");
  }

  double get subtitleSize => _subtitleSize;
  set subtitleSize(double v) {
    _subtitleSize = v;
    if (enableLogging) print("SETTINGS: subtitleSize set to $v");
  }

  double get subtitlePosX => _subtitlePosX;
  set subtitlePosX(double v) {
    _subtitlePosX = v;
    if (enableLogging) print("SETTINGS: subtitlePosX set to $v");
  }

  double get subtitlePosY => _subtitlePosY;
  set subtitlePosY(double v) {
    _subtitlePosY = v;
    if (enableLogging) print("SETTINGS: subtitlePosY set to $v");
  }

  String get artistFont => _artistFont;
  set artistFont(String v) {
    _artistFont = v;
    if (enableLogging) print("SETTINGS: artistFont set to $v");
  }

  double get artistSize => _artistSize;
  set artistSize(double v) {
    _artistSize = v;
    if (enableLogging) print("SETTINGS: artistSize set to $v");
  }

  double get artistPosX => _artistPosX;
  set artistPosX(double v) {
    _artistPosX = v;
    if (enableLogging) print("SETTINGS: artistPosX set to $v");
  }

  double get artistPosY => _artistPosY;
  set artistPosY(double v) {
    _artistPosY = v;
    if (enableLogging) print("SETTINGS: artistPosY set to $v");
  }

  // ---------------------------------------------------------------------------
  // Independent animation options for HSL and Overlay
  // ---------------------------------------------------------------------------

  AnimationOptions _colorAnimOptions;
  AnimationOptions _overlayAnimOptions;
  AnimationOptions _blurAnimOptions;
  AnimationOptions _noiseAnimOptions;
  AnimationOptions _textfxAnimOptions;

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

  AnimationOptions get blurAnimOptions => _blurAnimOptions;
  set blurAnimOptions(AnimationOptions value) {
    _blurAnimOptions = value;
    if (enableLogging) print("SETTINGS: blurAnimOptions updated");
  }

  AnimationOptions get noiseAnimOptions => _noiseAnimOptions;
  set noiseAnimOptions(AnimationOptions value) {
    _noiseAnimOptions = value;
    if (enableLogging) print("SETTINGS: noiseAnimOptions updated");
  }

  AnimationOptions get textfxAnimOptions => _textfxAnimOptions;
  set textfxAnimOptions(AnimationOptions value) {
    _textfxAnimOptions = value;
    if (enableLogging) print("SETTINGS: textfxAnimOptions updated");
  }

  // Text layout getters/setters
  bool get textFitToWidth => _textFitToWidth;
  set textFitToWidth(bool v) {
    _textFitToWidth = v;
    if (enableLogging) print("SETTINGS: textFitToWidth set to $v");
  }

  int get textHAlign => _textHAlign;
  set textHAlign(int v) {
    _textHAlign = v;
    if (enableLogging) print("SETTINGS: textHAlign set to $v");
  }

  int get textVAlign => _textVAlign;
  set textVAlign(int v) {
    _textVAlign = v;
    if (enableLogging) print("SETTINGS: textVAlign set to $v");
  }

  // Title layout
  bool get titleFitToWidth => _titleFitToWidth;
  set titleFitToWidth(bool v) {
    _titleFitToWidth = v;
    if (enableLogging) print("SETTINGS: titleFitToWidth set to $v");
  }

  int get titleHAlign => _titleHAlign;
  set titleHAlign(int v) {
    _titleHAlign = v;
    if (enableLogging) print("SETTINGS: titleHAlign set to $v");
  }

  int get titleVAlign => _titleVAlign;
  set titleVAlign(int v) {
    _titleVAlign = v;
    if (enableLogging) print("SETTINGS: titleVAlign set to $v");
  }

  // Subtitle layout
  bool get subtitleFitToWidth => _subtitleFitToWidth;
  set subtitleFitToWidth(bool v) {
    _subtitleFitToWidth = v;
    if (enableLogging) print("SETTINGS: subtitleFitToWidth set to $v");
  }

  int get subtitleHAlign => _subtitleHAlign;
  set subtitleHAlign(int v) {
    _subtitleHAlign = v;
    if (enableLogging) print("SETTINGS: subtitleHAlign set to $v");
  }

  int get subtitleVAlign => _subtitleVAlign;
  set subtitleVAlign(int v) {
    _subtitleVAlign = v;
    if (enableLogging) print("SETTINGS: subtitleVAlign set to $v");
  }

  // Artist layout
  bool get artistFitToWidth => _artistFitToWidth;
  set artistFitToWidth(bool v) {
    _artistFitToWidth = v;
    if (enableLogging) print("SETTINGS: artistFitToWidth set to $v");
  }

  int get artistHAlign => _artistHAlign;
  set artistHAlign(int v) {
    _artistHAlign = v;
    if (enableLogging) print("SETTINGS: artistHAlign set to $v");
  }

  int get artistVAlign => _artistVAlign;
  set artistVAlign(int v) {
    _artistVAlign = v;
    if (enableLogging) print("SETTINGS: artistVAlign set to $v");
  }

  // Line height getters/setters
  double get textLineHeight => _textLineHeight;
  set textLineHeight(double v) {
    _textLineHeight = v;
    if (enableLogging) print("SETTINGS: textLineHeight set to $v");
  }

  double get titleLineHeight => _titleLineHeight;
  set titleLineHeight(double v) {
    _titleLineHeight = v;
    if (enableLogging) print("SETTINGS: titleLineHeight set to $v");
  }

  double get subtitleLineHeight => _subtitleLineHeight;
  set subtitleLineHeight(double v) {
    _subtitleLineHeight = v;
    if (enableLogging) print("SETTINGS: subtitleLineHeight set to $v");
  }

  double get artistLineHeight => _artistLineHeight;
  set artistLineHeight(double v) {
    _artistLineHeight = v;
    if (enableLogging) print("SETTINGS: artistLineHeight set to $v");
  }

  // Text color getters/setters
  Color get textColor => _textColor;
  set textColor(Color value) {
    _textColor = value;
    if (enableLogging) print("SETTINGS: textColor set to $value");
  }

  Color get titleColor => _titleColor;
  set titleColor(Color value) {
    _titleColor = value;
    if (enableLogging) print("SETTINGS: titleColor set to $value");
  }

  Color get subtitleColor => _subtitleColor;
  set subtitleColor(Color value) {
    _subtitleColor = value;
    if (enableLogging) print("SETTINGS: subtitleColor set to $value");
  }

  Color get artistColor => _artistColor;
  set artistColor(Color value) {
    _artistColor = value;
    if (enableLogging) print("SETTINGS: artistColor set to $value");
  }

  // Helper to safely get a color's value or default to white if null
  int _safeColorValue(Color? color) {
    return color?.value ?? Colors.white.value;
  }

  // Metal effect getters and setters
  bool get textMetalEnabled => _textMetalEnabled;
  set textMetalEnabled(bool value) {
    _textMetalEnabled = value;
    if (enableLogging) print("SETTINGS: textMetalEnabled set to $value");
  }

  double get textMetalShine => _textMetalShine;
  set textMetalShine(double value) {
    _textMetalShine = value;
    if (enableLogging) {
      print("SETTINGS: textMetalShine set to ${value.toStringAsFixed(3)}");
    }
  }

  Color get textMetalBaseColor => _textMetalBaseColor;
  set textMetalBaseColor(Color value) {
    _textMetalBaseColor = value;
    if (enableLogging) print("SETTINGS: textMetalBaseColor set to $value");
  }

  Color get textMetalShineColor => _textMetalShineColor;
  set textMetalShineColor(Color value) {
    _textMetalShineColor = value;
    if (enableLogging) print("SETTINGS: textMetalShineColor set to $value");
  }

  // Glass effect getters and setters
  bool get textGlassEnabled => _textGlassEnabled;
  set textGlassEnabled(bool value) {
    _textGlassEnabled = value;
    if (enableLogging) print("SETTINGS: textGlassEnabled set to $value");
  }

  double get textGlassOpacity => _textGlassOpacity;
  set textGlassOpacity(double value) {
    _textGlassOpacity = value;
    if (enableLogging) {
      print("SETTINGS: textGlassOpacity set to ${value.toStringAsFixed(3)}");
    }
  }

  double get textGlassBlur => _textGlassBlur;
  set textGlassBlur(double value) {
    _textGlassBlur = value;
    if (enableLogging) {
      print("SETTINGS: textGlassBlur set to ${value.toStringAsFixed(3)}");
    }
  }

  Color get textGlassColor => _textGlassColor;
  set textGlassColor(Color value) {
    _textGlassColor = value;
    if (enableLogging) print("SETTINGS: textGlassColor set to $value");
  }

  double get textGlassRefraction => _textGlassRefraction;
  set textGlassRefraction(double value) {
    _textGlassRefraction = value;
    if (enableLogging) {
      print("SETTINGS: textGlassRefraction set to ${value.toStringAsFixed(3)}");
    }
  }

  // Neon effect getters and setters
  bool get textNeonEnabled => _textNeonEnabled;
  set textNeonEnabled(bool value) {
    _textNeonEnabled = value;
    if (enableLogging) print("SETTINGS: textNeonEnabled set to $value");
  }

  Color get textNeonColor => _textNeonColor;
  set textNeonColor(Color value) {
    _textNeonColor = value;
    if (enableLogging) print("SETTINGS: textNeonColor set to $value");
  }

  Color get textNeonOuterColor => _textNeonOuterColor;
  set textNeonOuterColor(Color value) {
    _textNeonOuterColor = value;
    if (enableLogging) print("SETTINGS: textNeonOuterColor set to $value");
  }

  double get textNeonIntensity => _textNeonIntensity;
  set textNeonIntensity(double value) {
    _textNeonIntensity = value;
    if (enableLogging) {
      print("SETTINGS: textNeonIntensity set to ${value.toStringAsFixed(3)}");
    }
  }

  double get textNeonWidth => _textNeonWidth;
  set textNeonWidth(double value) {
    _textNeonWidth = value;
    if (enableLogging) {
      print("SETTINGS: textNeonWidth set to ${value.toStringAsFixed(3)}");
    }
  }

  ShaderSettings({
    // Enable flags
    bool colorEnabled = false,
    bool blurEnabled = false,
    bool noiseEnabled = false,
    bool textEnabled = false,
    bool textfxEnabled = false,

    // Color settings
    double hue = 0.0,
    double saturation = 0.0,
    double lightness = 0.0,
    double overlayHue = 0.0,
    double overlayIntensity = 0.0,
    double overlayOpacity = 0.0,

    // Blur settings
    double blurAmount = 0.0,
    double blurRadius = 15.0,
    double blurOpacity = 1.0,
    int blurBlendMode = 0,
    double blurIntensity = 1.0,
    double blurContrast = 0.0,

    // Noise settings
    double noiseScale = 5.0,
    double noiseSpeed = 0.5,
    double colorIntensity = 0.3,
    double waveAmount = 0.02,

    // Text effects settings
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

    // Advanced text effects
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

    // Animation flags
    bool colorAnimated = false,
    bool overlayAnimated = false,
    bool blurAnimated = false,
    bool noiseAnimated = false,
    bool textfxAnimated = false,

    // Animation options
    AnimationOptions? colorAnimOptions,
    AnimationOptions? overlayAnimOptions,
    AnimationOptions? blurAnimOptions,
    AnimationOptions? noiseAnimOptions,
    AnimationOptions? textfxAnimOptions,

    // Image setting
    bool fillScreen = false,

    // Text content
    String textTitle = '',
    String textSubtitle = '',
    String textArtist = '',
    String textFont = 'Roboto',
    double textSize = 0.05,
    double textPosX = 0.1,
    double textPosY = 0.1,
    Color textColor = Colors.white,

    // New weight defaults
    int textWeight = 400,

    // Per-line styling (independent font, size, position)
    String titleFont = '',
    double titleSize = 0.05,
    double titlePosX = 0.1,
    double titlePosY = 0.1,
    Color titleColor = Colors.white,

    String subtitleFont = '',
    double subtitleSize = 0.04,
    double subtitlePosX = 0.1,
    double subtitlePosY = 0.18,
    Color subtitleColor = Colors.white,

    String artistFont = '',
    double artistSize = 0.035,
    double artistPosX = 0.1,
    double artistPosY = 0.26,
    Color artistColor = Colors.white,

    // Per-line weight defaults
    int titleWeight = 400,
    int subtitleWeight = 400,
    int artistWeight = 400,

    // Text layout defaults
    bool textFitToWidth = false,
    int textHAlign = 0, // left
    int textVAlign = 0, // top
    double textLineHeight = 1.2,

    // Per-line layout defaults
    bool titleFitToWidth = false,
    int titleHAlign = 0,
    int titleVAlign = 0,
    double titleLineHeight = 1.2,

    bool subtitleFitToWidth = false,
    int subtitleHAlign = 0,
    int subtitleVAlign = 0,
    double subtitleLineHeight = 1.2,

    bool artistFitToWidth = false,
    int artistHAlign = 0,
    int artistVAlign = 0,
    double artistLineHeight = 1.2,
  }) : _colorEnabled = colorEnabled,
       _blurEnabled = blurEnabled,
       _noiseEnabled = noiseEnabled,
       _textfxEnabled = textfxEnabled,
       _hue = hue,
       _saturation = saturation,
       _lightness = lightness,
       _overlayHue = overlayHue,
       _overlayIntensity = overlayIntensity,
       _overlayOpacity = overlayOpacity,
       _blurAmount = blurAmount,
       _blurRadius = blurRadius,
       _blurOpacity = blurOpacity,
       _blurBlendMode = blurBlendMode,
       _blurIntensity = blurIntensity,
       _blurContrast = blurContrast,
       _noiseScale = noiseScale,
       _noiseSpeed = noiseSpeed,
       _colorIntensity = colorIntensity,
       _waveAmount = waveAmount,
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
       _colorAnimated = colorAnimated,
       _overlayAnimated = overlayAnimated,
       _blurAnimated = blurAnimated,
       _noiseAnimated = noiseAnimated,
       _textfxAnimated = textfxAnimated,
       _colorAnimOptions = colorAnimOptions ?? AnimationOptions(),
       _overlayAnimOptions = overlayAnimOptions ?? AnimationOptions(),
       _blurAnimOptions = blurAnimOptions ?? AnimationOptions(),
       _noiseAnimOptions = noiseAnimOptions ?? AnimationOptions(),
       _textfxAnimOptions = textfxAnimOptions ?? AnimationOptions(),
       _fillScreen = fillScreen,
       _textEnabled = textEnabled,
       _textTitle = textTitle,
       _textSubtitle = textSubtitle,
       _textArtist = textArtist,
       _textFont = textFont,
       _textSize = textSize,
       _textPosX = textPosX,
       _textPosY = textPosY,
       _textColor = textColor,
       _textWeight = textWeight,
       _titleWeight = titleWeight,
       _subtitleWeight = subtitleWeight,
       _artistWeight = artistWeight,
       _titleFont = titleFont,
       _titleSize = titleSize,
       _titlePosX = titlePosX,
       _titlePosY = titlePosY,
       _titleColor = titleColor,
       _subtitleFont = subtitleFont,
       _subtitleSize = subtitleSize,
       _subtitlePosX = subtitlePosX,
       _subtitlePosY = subtitlePosY,
       _subtitleColor = subtitleColor,
       _artistFont = artistFont,
       _artistSize = artistSize,
       _artistPosX = artistPosX,
       _artistPosY = artistPosY,
       _artistColor = artistColor,
       _textFitToWidth = textFitToWidth,
       _textHAlign = textHAlign,
       _textVAlign = textVAlign,
       _textLineHeight = textLineHeight,
       _titleFitToWidth = titleFitToWidth,
       _titleHAlign = titleHAlign,
       _titleVAlign = titleVAlign,
       _titleLineHeight = titleLineHeight,
       _subtitleFitToWidth = subtitleFitToWidth,
       _subtitleHAlign = subtitleHAlign,
       _subtitleVAlign = subtitleVAlign,
       _subtitleLineHeight = subtitleLineHeight,
       _artistFitToWidth = artistFitToWidth,
       _artistHAlign = artistHAlign,
       _artistVAlign = artistVAlign,
       _artistLineHeight = artistLineHeight {
    if (enableLogging) print("SETTINGS: ShaderSettings initialized");
  }

  // ---------------------------------------------------------------------------
  // Serialization helpers for persistence
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    try {
      return {
        'colorEnabled': _colorEnabled,
        'blurEnabled': _blurEnabled,
        'noiseEnabled': _noiseEnabled,
        'textfxEnabled': _textfxEnabled,
        'hue': _hue,
        'saturation': _saturation,
        'lightness': _lightness,
        'overlayHue': _overlayHue,
        'overlayIntensity': _overlayIntensity,
        'overlayOpacity': _overlayOpacity,
        'blurAmount': _blurAmount,
        'blurRadius': _blurRadius,
        'blurOpacity': _blurOpacity,
        'blurBlendMode': _blurBlendMode,
        'blurIntensity': _blurIntensity,
        'blurContrast': _blurContrast,
        'noiseScale': _noiseScale,
        'noiseSpeed': _noiseSpeed,
        'colorIntensity': _colorIntensity,
        'waveAmount': _waveAmount,
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
        'colorAnimated': _colorAnimated,
        'overlayAnimated': _overlayAnimated,
        'blurAnimated': _blurAnimated,
        'noiseAnimated': _noiseAnimated,
        'textfxAnimated': _textfxAnimated,
        'colorAnimOptions': _colorAnimOptions.toMap(),
        'overlayAnimOptions': _overlayAnimOptions.toMap(),
        'blurAnimOptions': _blurAnimOptions.toMap(),
        'noiseAnimOptions': _noiseAnimOptions.toMap(),
        'textfxAnimOptions': _textfxAnimOptions.toMap(),
        'fillScreen': _fillScreen,
        'textEnabled': _textEnabled,
        'textTitle': _textTitle,
        'textSubtitle': _textSubtitle,
        'textArtist': _textArtist,
        'textFont': _textFont,
        'textSize': _textSize,
        'textPosX': _textPosX,
        'textPosY': _textPosY,
        // Store color as integer value using safe helper
        'textColor': _safeColorValue(_textColor),
        'textWeight': _textWeight,
        'titleFont': _titleFont,
        'titleSize': _titleSize,
        'titlePosX': _titlePosX,
        'titlePosY': _titlePosY,
        // Store color as integer value using safe helper
        'titleColor': _safeColorValue(_titleColor),
        'subtitleFont': _subtitleFont,
        'subtitleSize': _subtitleSize,
        'subtitlePosX': _subtitlePosX,
        'subtitlePosY': _subtitlePosY,
        // Store color as integer value using safe helper
        'subtitleColor': _safeColorValue(_subtitleColor),
        'artistFont': _artistFont,
        'artistSize': _artistSize,
        'artistPosX': _artistPosX,
        'artistPosY': _artistPosY,
        // Store color as integer value using safe helper
        'artistColor': _safeColorValue(_artistColor),
        'titleWeight': _titleWeight,
        'subtitleWeight': _subtitleWeight,
        'artistWeight': _artistWeight,
        'textFitToWidth': _textFitToWidth,
        'textHAlign': _textHAlign,
        'textVAlign': _textVAlign,
        'textLineHeight': _textLineHeight,
        'titleFitToWidth': _titleFitToWidth,
        'titleHAlign': _titleHAlign,
        'titleVAlign': _titleVAlign,
        'titleLineHeight': _titleLineHeight,
        'subtitleFitToWidth': _subtitleFitToWidth,
        'subtitleHAlign': _subtitleHAlign,
        'subtitleVAlign': _subtitleVAlign,
        'subtitleLineHeight': _subtitleLineHeight,
        'artistFitToWidth': _artistFitToWidth,
        'artistHAlign': _artistHAlign,
        'artistVAlign': _artistVAlign,
        'artistLineHeight': _artistLineHeight,
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
      };
    } catch (e) {
      print('Error serializing ShaderSettings: $e');
      // Return default values to prevent serialization errors
      return {
        'colorEnabled': false,
        'blurEnabled': false,
        'noiseEnabled': false,
        'textfxEnabled': false,
        'textEnabled': false,
        'textColor': Colors.white.value,
        'titleColor': Colors.white.value,
        'subtitleColor': Colors.white.value,
        'artistColor': Colors.white.value,
        'textShadowColor': Colors.black.value,
        'textGlowColor': Colors.white.value,
        'textOutlineColor': Colors.black.value,
      };
    }
  }

  factory ShaderSettings.fromMap(Map<String, dynamic> map) {
    return ShaderSettings(
      colorEnabled: map['colorEnabled'] ?? false,
      blurEnabled: map['blurEnabled'] ?? false,
      noiseEnabled: map['noiseEnabled'] ?? false,
      textfxEnabled: map['textfxEnabled'] ?? false,
      hue: map['hue'] ?? 0.0,
      saturation: map['saturation'] ?? 0.0,
      lightness: map['lightness'] ?? 0.0,
      overlayHue: map['overlayHue'] ?? 0.0,
      overlayIntensity: map['overlayIntensity'] ?? 0.0,
      overlayOpacity: map['overlayOpacity'] ?? 0.0,
      blurAmount: map['blurAmount'] ?? 0.0,
      blurRadius: map['blurRadius'] ?? 15.0,
      blurOpacity: map['blurOpacity'] ?? 1.0,
      blurBlendMode: map['blurBlendMode'] ?? 0,
      blurIntensity: map['blurIntensity'] ?? 1.0,
      blurContrast: map['blurContrast'] ?? 0.0,
      noiseScale: map['noiseScale'] ?? 5.0,
      noiseSpeed: map['noiseSpeed'] ?? 0.5,
      colorIntensity: map['colorIntensity'] ?? 0.3,
      waveAmount: map['waveAmount'] ?? 0.02,
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
      colorAnimated: map['colorAnimated'] ?? false,
      overlayAnimated: map['overlayAnimated'] ?? false,
      blurAnimated: map['blurAnimated'] ?? false,
      noiseAnimated: map['noiseAnimated'] ?? false,
      textfxAnimated: map['textfxAnimated'] ?? false,
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
      blurAnimOptions: map['blurAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['blurAnimOptions']),
            )
          : null,
      noiseAnimOptions: map['noiseAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['noiseAnimOptions']),
            )
          : null,
      textfxAnimOptions: map['textfxAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['textfxAnimOptions']),
            )
          : null,
      fillScreen: map['fillScreen'] ?? false,
      textEnabled: map['textEnabled'] ?? false,
      textTitle: map['textTitle'] ?? '',
      textSubtitle: map['textSubtitle'] ?? '',
      textArtist: map['textArtist'] ?? '',
      textFont: map['textFont'] ?? 'Roboto',
      textSize: map['textSize'] ?? 0.05,
      textPosX: map['textPosX'] ?? 0.1,
      textPosY: map['textPosY'] ?? 0.1,
      textColor: map['textColor'] != null
          ? Color(map['textColor'])
          : Colors.white,
      textWeight: map['textWeight'] ?? 400,
      titleFont: map['titleFont'] ?? '',
      titleSize: map['titleSize'] ?? 0.05,
      titlePosX: map['titlePosX'] ?? 0.1,
      titlePosY: map['titlePosY'] ?? 0.1,
      titleColor: map['titleColor'] != null
          ? Color(map['titleColor'])
          : Colors.white,
      subtitleFont: map['subtitleFont'] ?? '',
      subtitleSize: map['subtitleSize'] ?? 0.04,
      subtitlePosX: map['subtitlePosX'] ?? 0.1,
      subtitlePosY: map['subtitlePosY'] ?? 0.18,
      subtitleColor: map['subtitleColor'] != null
          ? Color(map['subtitleColor'])
          : Colors.white,
      artistFont: map['artistFont'] ?? '',
      artistSize: map['artistSize'] ?? 0.035,
      artistPosX: map['artistPosX'] ?? 0.1,
      artistPosY: map['artistPosY'] ?? 0.26,
      artistColor: map['artistColor'] != null
          ? Color(map['artistColor'])
          : Colors.white,
      titleWeight: map['titleWeight'] ?? 400,
      subtitleWeight: map['subtitleWeight'] ?? 400,
      artistWeight: map['artistWeight'] ?? 400,
      textFitToWidth: map['textFitToWidth'] ?? false,
      textHAlign: map['textHAlign'] ?? 0,
      textVAlign: map['textVAlign'] ?? 0,
      textLineHeight: map['textLineHeight'] ?? 1.2,
      titleFitToWidth: map['titleFitToWidth'] ?? false,
      titleHAlign: map['titleHAlign'] ?? 0,
      titleVAlign: map['titleVAlign'] ?? 0,
      titleLineHeight: map['titleLineHeight'] ?? 1.2,
      subtitleFitToWidth: map['subtitleFitToWidth'] ?? false,
      subtitleHAlign: map['subtitleHAlign'] ?? 0,
      subtitleVAlign: map['subtitleVAlign'] ?? 0,
      subtitleLineHeight: map['subtitleLineHeight'] ?? 1.2,
      artistFitToWidth: map['artistFitToWidth'] ?? false,
      artistHAlign: map['artistHAlign'] ?? 0,
      artistVAlign: map['artistVAlign'] ?? 0,
      artistLineHeight: map['artistLineHeight'] ?? 1.2,
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
    );
  }
}
