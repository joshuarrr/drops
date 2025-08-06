import 'animation_options.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/material.dart' show Colors;

import 'color_settings.dart';
import 'blur_settings.dart';
import 'noise_settings.dart';
import 'text_fx_settings.dart';
import 'text_layout_settings.dart';
import 'rain_settings.dart';
import 'chromatic_settings.dart';
import 'ripple_settings.dart';
import 'highlights_settings.dart';
import 'music_settings.dart';
import 'cymatics_settings_stub.dart';
import 'background_settings.dart';

// Class to store all shader effect settings
class ShaderSettings {
  // Specialized settings classes
  ColorSettings _colorSettings;
  BlurSettings _blurSettings;
  NoiseSettings _noiseSettings;
  TextFXSettings _textfxSettings;
  TextLayoutSettings _textLayoutSettings;
  RainSettings _rainSettings;
  ChromaticSettings _chromaticSettings;
  RippleSettings _rippleSettings;
  HighlightsSettings _highlightsSettings;
  MusicSettings _musicSettings;
  CymaticsSettings _cymaticsSettings;
  BackgroundSettings _backgroundSettings;

  // Flag to control logging
  static bool enableLogging = true;

  // Expose settings objects
  ColorSettings get colorSettings => _colorSettings;
  BlurSettings get blurSettings => _blurSettings;
  NoiseSettings get noiseSettings => _noiseSettings;
  TextFXSettings get textfxSettings => _textfxSettings;
  TextLayoutSettings get textLayoutSettings => _textLayoutSettings;
  RainSettings get rainSettings => _rainSettings;
  ChromaticSettings get chromaticSettings => _chromaticSettings;
  RippleSettings get rippleSettings => _rippleSettings;
  HighlightsSettings get highlightsSettings => _highlightsSettings;
  MusicSettings get musicSettings => _musicSettings;
  CymaticsSettings get cymaticsSettings => _cymaticsSettings;
  BackgroundSettings get backgroundSettings => _backgroundSettings;

  // Convenience getters for most commonly used properties
  // These delegate to the specialized settings classes

  // Background settings
  bool get backgroundEnabled => _backgroundSettings.backgroundEnabled;
  set backgroundEnabled(bool value) {
    _backgroundSettings.backgroundEnabled = value;
  }

  bool get backgroundAnimated => _backgroundSettings.backgroundAnimated;
  set backgroundAnimated(bool value) {
    _backgroundSettings.backgroundAnimated = value;
  }

  // Image settings (simple boolean flag)
  bool _imageEnabled = true; // Default to true for backward compatibility

  bool get imageEnabled => _imageEnabled;
  set imageEnabled(bool value) {
    _imageEnabled = value;
    if (enableLogging) print("SETTINGS: imageEnabled set to $value");
  }

  // Color settings
  bool get colorEnabled => _colorSettings.colorEnabled;
  set colorEnabled(bool value) {
    _colorSettings.colorEnabled = value;
  }

  bool get colorAnimated => _colorSettings.colorAnimated;
  set colorAnimated(bool value) {
    _colorSettings.colorAnimated = value;
  }

  // Blur settings
  bool get blurEnabled => _blurSettings.blurEnabled;
  set blurEnabled(bool value) {
    _blurSettings.blurEnabled = value;
  }

  bool get blurAnimated => _blurSettings.blurAnimated;
  set blurAnimated(bool value) {
    _blurSettings.blurAnimated = value;
  }

  // Noise settings
  bool get noiseEnabled => _noiseSettings.noiseEnabled;
  set noiseEnabled(bool value) {
    _noiseSettings.noiseEnabled = value;
  }

  bool get noiseAnimated => _noiseSettings.noiseAnimated;
  set noiseAnimated(bool value) {
    _noiseSettings.noiseAnimated = value;
  }

  // Rain settings
  bool get rainEnabled => _rainSettings.rainEnabled;
  set rainEnabled(bool value) {
    _rainSettings.rainEnabled = value;
  }

  bool get rainAnimated => _rainSettings.rainAnimated;
  set rainAnimated(bool value) {
    _rainSettings.rainAnimated = value;
  }

  // Chromatic aberration settings
  bool get chromaticEnabled => _chromaticSettings.chromaticEnabled;
  set chromaticEnabled(bool value) {
    _chromaticSettings.chromaticEnabled = value;
  }

  bool get chromaticAnimated => _chromaticSettings.chromaticAnimated;
  set chromaticAnimated(bool value) {
    _chromaticSettings.chromaticAnimated = value;
  }

  // Ripple settings
  bool get rippleEnabled => _rippleSettings.rippleEnabled;
  set rippleEnabled(bool value) {
    _rippleSettings.rippleEnabled = value;
  }

  bool get rippleAnimated => _rippleSettings.rippleAnimated;
  set rippleAnimated(bool value) {
    _rippleSettings.rippleAnimated = value;
  }

  // Highlights settings
  bool get highlightsEnabled => _highlightsSettings.highlightsEnabled;
  set highlightsEnabled(bool value) {
    _highlightsSettings.highlightsEnabled = value;
  }

  bool get highlightsAnimated => _highlightsSettings.highlightsAnimated;
  set highlightsAnimated(bool value) {
    _highlightsSettings.highlightsAnimated = value;
  }

  // Music settings
  bool get musicEnabled => _musicSettings.musicEnabled;
  set musicEnabled(bool value) {
    _musicSettings.musicEnabled = value;
  }

  bool get musicAnimated => _musicSettings.musicAnimated;
  set musicAnimated(bool value) {
    _musicSettings.musicAnimated = value;
  }

  // Cymatics settings
  bool get cymaticsEnabled => _cymaticsSettings.cymaticsEnabled;
  set cymaticsEnabled(bool value) {
    _cymaticsSettings.cymaticsEnabled = value;
  }

  bool get cymaticsAnimated => _cymaticsSettings.cymaticsAnimated;
  set cymaticsAnimated(bool value) {
    _cymaticsSettings.cymaticsAnimated = value;
  }

  // Text effect settings
  bool get textfxEnabled => _textfxSettings.textfxEnabled;
  set textfxEnabled(bool value) {
    _textfxSettings.textfxEnabled = value;
  }

  bool get textfxAnimated => _textfxSettings.textfxAnimated;
  set textfxAnimated(bool value) {
    _textfxSettings.textfxAnimated = value;
  }

  // Text layout settings
  bool get textEnabled => _textLayoutSettings.textEnabled;
  set textEnabled(bool value) {
    _textLayoutSettings.textEnabled = value;
  }

  bool get fillScreen => _textLayoutSettings.fillScreen;
  set fillScreen(bool value) {
    _textLayoutSettings.fillScreen = value;
  }

  // Enable logging for all settings classes
  static void setLogging(bool enabled) {
    enableLogging = enabled;
    ColorSettings.enableLogging = enabled;
    BlurSettings.enableLogging = enabled;
    NoiseSettings.enableLogging = enabled;
    TextFXSettings.enableLogging = enabled;
    TextLayoutSettings.enableLogging = enabled;
    RainSettings.enableLogging = enabled;
    ChromaticSettings.enableLogging = enabled;
    RippleSettings.enableLogging = enabled;
    HighlightsSettings.enableLogging = enabled;
    MusicSettings.enableLogging = enabled;
    // CymaticsSettings.enableLogging = enabled; // Not needed in V2
    BackgroundSettings.enableLogging = enabled;
  }

  // Static default instance to avoid creating new instances just for default values
  static final ShaderSettings _defaults = ShaderSettings._internal();
  static ShaderSettings get defaults => _defaults;

  // Private constructor for default instance
  ShaderSettings._internal()
    : _colorSettings = ColorSettings(),
      _blurSettings = BlurSettings(),
      _noiseSettings = NoiseSettings(),
      _textfxSettings = TextFXSettings(),
      _textLayoutSettings = TextLayoutSettings(),
      _rainSettings = RainSettings(),
      _chromaticSettings = ChromaticSettings(),
      _rippleSettings = RippleSettings(),
      _highlightsSettings = HighlightsSettings(),
      _musicSettings = MusicSettings(),
      _cymaticsSettings = CymaticsSettings(),
      _backgroundSettings = BackgroundSettings() {
    // No logging for the static default instance
  }

  ShaderSettings({
    // Specialized settings
    ColorSettings? colorSettings,
    BlurSettings? blurSettings,
    NoiseSettings? noiseSettings,
    TextFXSettings? textfxSettings,
    TextLayoutSettings? textLayoutSettings,
    RainSettings? rainSettings,
    ChromaticSettings? chromaticSettings,
    RippleSettings? rippleSettings,
    HighlightsSettings? highlightsSettings,
    MusicSettings? musicSettings,
    CymaticsSettings? cymaticsSettings,
    BackgroundSettings? backgroundSettings,
    bool skipLogging =
        false, // Add parameter to skip logging when loading presets
  }) : _colorSettings = colorSettings ?? ColorSettings(),
       _blurSettings = blurSettings ?? BlurSettings(),
       _noiseSettings = noiseSettings ?? NoiseSettings(),
       _textfxSettings = textfxSettings ?? TextFXSettings(),
       _textLayoutSettings = textLayoutSettings ?? TextLayoutSettings(),
       _rainSettings = rainSettings ?? RainSettings(),
       _chromaticSettings = chromaticSettings ?? ChromaticSettings(),
       _rippleSettings = rippleSettings ?? RippleSettings(),
       _highlightsSettings = highlightsSettings ?? HighlightsSettings(),
       _musicSettings = musicSettings ?? MusicSettings(),
       _cymaticsSettings = cymaticsSettings ?? CymaticsSettings(),
       _backgroundSettings = backgroundSettings ?? BackgroundSettings() {}

  // Serialization helper for persistence
  Map<String, dynamic> toMap() {
    try {
      return {
        'imageEnabled': _imageEnabled,
        'colorSettings': _colorSettings.toMap(),
        'blurSettings': _blurSettings.toMap(),
        'noiseSettings': _noiseSettings.toMap(),
        'textfxSettings': _textfxSettings.toMap(),
        'textLayoutSettings': _textLayoutSettings.toMap(),
        'rainSettings': _rainSettings.toMap(),
        'chromaticSettings': _chromaticSettings.toMap(),
        'rippleSettings': _rippleSettings.toMap(),
        'highlightsSettings': _highlightsSettings.toMap(),
        'musicSettings': _musicSettings.toMap(),
        'cymaticsSettings': _cymaticsSettings.toMap(),
        'backgroundSettings': _backgroundSettings.toMap(),
      };
    } catch (e) {
      print('Error serializing ShaderSettings: $e');
      // Return fallback settings but preserve current background color
      try {
        // Try to at least preserve the background settings
        final backgroundMap = _backgroundSettings.toMap();
        return {
          'imageEnabled': _imageEnabled,
          'colorSettings': ColorSettings().toMap(),
          'blurSettings': BlurSettings().toMap(),
          'noiseSettings': NoiseSettings().toMap(),
          'textfxSettings': TextFXSettings().toMap(),
          'textLayoutSettings': TextLayoutSettings().toMap(),
          'rainSettings': RainSettings().toMap(),
          'chromaticSettings': ChromaticSettings().toMap(),
          'rippleSettings': RippleSettings().toMap(),
          'musicSettings': MusicSettings().toMap(),
          'cymaticsSettings': CymaticsSettings().toMap(),
          'backgroundSettings':
              backgroundMap, // Use the actual background settings
        };
      } catch (innerError) {
        // If even that fails, return minimal settings but still try to preserve color
        print('Critical error serializing ShaderSettings: $innerError');
        return {
          'imageEnabled': true,
          'colorSettings': ColorSettings().toMap(),
          'blurSettings': BlurSettings().toMap(),
          'noiseSettings': NoiseSettings().toMap(),
          'textfxSettings': TextFXSettings().toMap(),
          'textLayoutSettings': TextLayoutSettings().toMap(),
          'rainSettings': RainSettings().toMap(),
          'chromaticSettings': ChromaticSettings().toMap(),
          'rippleSettings': RippleSettings().toMap(),
          'musicSettings': MusicSettings().toMap(),
          'cymaticsSettings': CymaticsSettings().toMap(),
          'backgroundSettings': {
            'backgroundEnabled': _backgroundSettings.backgroundEnabled,
            'backgroundColor': _backgroundSettings.backgroundColor.value,
            'backgroundAnimated': false,
            'backgroundAnimOptions': AnimationOptions().toMap(),
          },
        };
      }
    }
  }

  factory ShaderSettings.fromMap(Map<String, dynamic> map) {
    final settings = ShaderSettings(
      colorSettings: map['colorSettings'] != null
          ? ColorSettings.fromMap(
              Map<String, dynamic>.from(map['colorSettings']),
            )
          : null,
      blurSettings: map['blurSettings'] != null
          ? BlurSettings.fromMap(Map<String, dynamic>.from(map['blurSettings']))
          : null,
      noiseSettings: map['noiseSettings'] != null
          ? NoiseSettings.fromMap(
              Map<String, dynamic>.from(map['noiseSettings']),
            )
          : null,
      textfxSettings: map['textfxSettings'] != null
          ? TextFXSettings.fromMap(
              Map<String, dynamic>.from(map['textfxSettings']),
            )
          : null,
      textLayoutSettings: map['textLayoutSettings'] != null
          ? TextLayoutSettings.fromMap(
              Map<String, dynamic>.from(map['textLayoutSettings']),
            )
          : null,
      rainSettings: map['rainSettings'] != null
          ? RainSettings.fromMap(Map<String, dynamic>.from(map['rainSettings']))
          : null,
      chromaticSettings: map['chromaticSettings'] != null
          ? ChromaticSettings.fromMap(
              Map<String, dynamic>.from(map['chromaticSettings']),
            )
          : null,
      rippleSettings: map['rippleSettings'] != null
          ? RippleSettings.fromMap(
              Map<String, dynamic>.from(map['rippleSettings']),
            )
          : null,
      musicSettings: map['musicSettings'] != null
          ? MusicSettings.fromMap(
              Map<String, dynamic>.from(map['musicSettings']),
            )
          : null,
      cymaticsSettings: map['cymaticsSettings'] != null
          ? CymaticsSettings.fromMap(
              Map<String, dynamic>.from(map['cymaticsSettings']),
            )
          : null,
      backgroundSettings: map['backgroundSettings'] != null
          ? BackgroundSettings.fromMap(
              Map<String, dynamic>.from(map['backgroundSettings']),
              skipLogging: true, // Skip logging during preset loading
            )
          : null,
      skipLogging: true, // Skip logging when loading from map (preset loading)
    );

    // Set imageEnabled after creating the instance
    settings._imageEnabled = map['imageEnabled'] ?? true;

    return settings;
  }

  // For backward compatibility with the old settings format
  factory ShaderSettings.fromLegacyMap(Map<String, dynamic> map) {
    // Create settings using individual fields from the old map format
    final settings = ShaderSettings(
      colorSettings: ColorSettings(
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
      ),
      blurSettings: BlurSettings(
        blurEnabled: map['blurEnabled'] ?? false,
        blurAmount: (map['blurAmount'] ?? 0.0).clamp(0.0, 1.0),
        blurRadius: (map['blurRadius'] ?? 15.0).clamp(0.0, 120.0),
        blurOpacity: (map['blurOpacity'] ?? 1.0).clamp(0.0, 1.0),
        blurBlendMode: map['blurBlendMode'] ?? 0,
        blurIntensity: (map['blurIntensity'] ?? 1.0).clamp(0.0, 3.0),
        blurContrast: (map['blurContrast'] ?? 0.0).clamp(0.0, 2.0),
        blurAnimated: map['blurAnimated'] ?? false,
        blurAnimOptions: map['blurAnimOptions'] != null
            ? AnimationOptions.fromMap(
                Map<String, dynamic>.from(map['blurAnimOptions']),
              )
            : null,
      ),
      noiseSettings: NoiseSettings(
        noiseEnabled: map['noiseEnabled'] ?? false,
        noiseScale: map['noiseScale'] ?? 5.0,
        noiseSpeed: map['noiseSpeed'] ?? 0.5,
        colorIntensity: map['colorIntensity'] ?? 0.3,
        waveAmount: map['waveAmount'] ?? 0.02,
        noiseAnimated: map['noiseAnimated'] ?? false,
        noiseAnimOptions: map['noiseAnimOptions'] != null
            ? AnimationOptions.fromMap(
                Map<String, dynamic>.from(map['noiseAnimOptions']),
              )
            : null,
      ),
      rainSettings: RainSettings(
        rainEnabled: map['rainEnabled'] ?? false,
        rainIntensity: map['rainIntensity'] ?? 0.5,
        dropSize: map['dropSize'] ?? 0.5,
        fallSpeed: map['fallSpeed'] ?? 0.5,
        refraction: map['refraction'] ?? 0.5,
        trailIntensity: map['trailIntensity'] ?? 0.3,
        rainAnimated: map['rainAnimated'] ?? false,
        rainAnimOptions: map['rainAnimOptions'] != null
            ? AnimationOptions.fromMap(
                Map<String, dynamic>.from(map['rainAnimOptions']),
              )
            : null,
      ),
      chromaticSettings: ChromaticSettings(
        chromaticEnabled: map['chromaticEnabled'] ?? false,
        amount: map['chromaticAmount'] ?? 0.5,
        angle: map['chromaticAngle'] ?? 0.0,
        spread: map['chromaticSpread'] ?? 0.5,
        intensity: map['chromaticIntensity'] ?? 0.5,
        chromaticAnimated: map['chromaticAnimated'] ?? false,
        animOptions: map['chromaticAnimOptions'] != null
            ? AnimationOptions.fromMap(
                Map<String, dynamic>.from(map['chromaticAnimOptions']),
              )
            : null,
      ),
      rippleSettings: RippleSettings(
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
      ),
      cymaticsSettings: CymaticsSettings(
        cymaticsEnabled: map['cymaticsEnabled'] ?? false,
        intensity: map['cymaticsIntensity'] ?? 0.5,
        frequency: map['cymaticsFrequency'] ?? 0.5,
        amplitude: map['cymaticsAmplitude'] ?? 0.5,
        complexity: map['cymaticsComplexity'] ?? 0.5,
        speed: map['cymaticsSpeed'] ?? 0.5,
        colorIntensity: map['cymaticsColorIntensity'] ?? 0.5,
        audioReactive: map['cymaticsAudioReactive'] ?? true,
        audioSensitivity: map['cymaticsAudioSensitivity'] ?? 0.7,
        cymaticsAnimated: map['cymaticsAnimated'] ?? false,
        animOptions: map['cymaticsAnimOptions'] != null
            ? AnimationOptions.fromMap(
                Map<String, dynamic>.from(map['cymaticsAnimOptions']),
              )
            : null,
      ),
      textfxSettings: TextFXSettings(
        textfxEnabled: map['textfxEnabled'] ?? false,
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
            : Colors.blue,
        textNeonOuterColor: map['textNeonOuterColor'] != null
            ? Color(map['textNeonOuterColor'])
            : Colors.purple,
        textNeonIntensity: map['textNeonIntensity'] ?? 0.8,
        textNeonWidth: map['textNeonWidth'] ?? 0.3,
        applyToText: map['applyShaderEffectsToText'] ?? true,
        textfxAnimated: map['textfxAnimated'] ?? false,
        textfxAnimOptions: map['textfxAnimOptions'] != null
            ? AnimationOptions.fromMap(
                Map<String, dynamic>.from(map['textfxAnimOptions']),
              )
            : null,
      ),
      textLayoutSettings: TextLayoutSettings(
        textEnabled: map['textEnabled'] ?? false,
        fillScreen: map['fillScreen'] ?? false,
        textTitle: map['textTitle'] ?? '',
        textSubtitle: map['textSubtitle'] ?? '',
        textArtist: map['textArtist'] ?? '',
        textLyrics: map['textLyrics'] ?? '',
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
        lyricsFont: map['lyricsFont'] ?? '',
        lyricsSize: map['lyricsSize'] ?? 0.03,
        lyricsPosX: map['lyricsPosX'] ?? 0.1,
        lyricsPosY: map['lyricsPosY'] ?? 0.5,
        lyricsColor: map['lyricsColor'] != null
            ? Color(map['lyricsColor'])
            : Colors.white,
        titleWeight: map['titleWeight'] ?? 400,
        subtitleWeight: map['subtitleWeight'] ?? 400,
        artistWeight: map['artistWeight'] ?? 400,
        lyricsWeight: map['lyricsWeight'] ?? 400,
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
        lyricsFitToWidth: map['lyricsFitToWidth'] ?? false,
        lyricsHAlign: map['lyricsHAlign'] ?? 0,
        lyricsVAlign: map['lyricsVAlign'] ?? 0,
        lyricsLineHeight: map['lyricsLineHeight'] ?? 1.2,
      ),
      musicSettings: MusicSettings(
        musicEnabled: map['musicEnabled'] ?? false,
        currentTrack: map['currentTrack'] ?? '',
        volume: map['volume'] ?? 0.8,
        loop: map['loop'] ?? true,
        autoplay: map['autoplay'] ?? false,
        musicAnimated: map['musicAnimated'] ?? false,
        musicAnimOptions: map['musicAnimOptions'] != null
            ? AnimationOptions.fromMap(
                Map<String, dynamic>.from(map['musicAnimOptions']),
              )
            : null,
      ),
      backgroundSettings: BackgroundSettings(
        backgroundEnabled: map['backgroundEnabled'] ?? false,
        backgroundColor: map['backgroundColor'] != null
            ? Color(map['backgroundColor'])
            : Colors.black,
        backgroundAnimated: map['backgroundAnimated'] ?? false,
        backgroundAnimOptions: map['backgroundAnimOptions'] != null
            ? AnimationOptions.fromMap(
                Map<String, dynamic>.from(map['backgroundAnimOptions']),
              )
            : null,
      ),
      skipLogging: true, // Skip logging when loading legacy presets
    );

    // Set imageEnabled for legacy maps
    settings._imageEnabled = map['imageEnabled'] ?? true;

    return settings;
  }

  // Create a deep copy of the settings
  ShaderSettings copy() {
    return ShaderSettings.fromMap(this.toMap());
  }
}
