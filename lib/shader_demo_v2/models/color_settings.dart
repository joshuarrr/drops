import 'package:flutter/material.dart';
import 'animation_options.dart';
import 'parameter_range.dart';
import 'targetable_effect_settings.dart';

class ColorSettings with TargetableEffectSettings {
  // Enable flags for color effects
  bool _colorEnabled;

  // Color settings
  ParameterRange _hueRange;
  ParameterRange _saturationRange;
  ParameterRange _lightnessRange;
  ParameterRange _overlayHueRange;
  ParameterRange _overlayIntensityRange;
  ParameterRange _overlayOpacityRange;

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
  double get hue => _hueRange.userMax;
  set hue(double value) {
    _hueRange.setCurrent(value);
  }

  ParameterRange get hueRange => _hueRange.copy();
  void updateHueRange({double? userMin, double? userMax}) {
    if (userMin != null) _hueRange.setUserMin(userMin);
    if (userMax != null) _hueRange.setUserMax(userMax);
    _hueRange.setCurrent(_hueRange.userMax, syncUserMax: false);
  }

  void setHueRange(ParameterRange range) {
    _hueRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get saturation => _saturationRange.userMax;
  set saturation(double value) {
    _saturationRange.setCurrent(value);
  }

  ParameterRange get saturationRange => _saturationRange.copy();
  void updateSaturationRange({double? userMin, double? userMax}) {
    if (userMin != null) _saturationRange.setUserMin(userMin);
    if (userMax != null) _saturationRange.setUserMax(userMax);
    _saturationRange.setCurrent(_saturationRange.userMax, syncUserMax: false);
  }

  void setSaturationRange(ParameterRange range) {
    _saturationRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get lightness => _lightnessRange.userMax;
  set lightness(double value) {
    _lightnessRange.setCurrent(value);
  }

  ParameterRange get lightnessRange => _lightnessRange.copy();
  void updateLightnessRange({double? userMin, double? userMax}) {
    if (userMin != null) _lightnessRange.setUserMin(userMin);
    if (userMax != null) _lightnessRange.setUserMax(userMax);
    _lightnessRange.setCurrent(_lightnessRange.userMax, syncUserMax: false);
  }

  void setLightnessRange(ParameterRange range) {
    _lightnessRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get overlayHue => _overlayHueRange.userMax;
  set overlayHue(double value) {
    _overlayHueRange.setCurrent(value);
  }

  ParameterRange get overlayHueRange => _overlayHueRange.copy();
  void updateOverlayHueRange({double? userMin, double? userMax}) {
    if (userMin != null) _overlayHueRange.setUserMin(userMin);
    if (userMax != null) _overlayHueRange.setUserMax(userMax);
    _overlayHueRange.setCurrent(_overlayHueRange.userMax, syncUserMax: false);
  }

  void setOverlayHueRange(ParameterRange range) {
    _overlayHueRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get overlayIntensity => _overlayIntensityRange.userMax;
  set overlayIntensity(double value) {
    _overlayIntensityRange.setCurrent(value);
  }

  ParameterRange get overlayIntensityRange => _overlayIntensityRange.copy();
  void updateOverlayIntensityRange({double? userMin, double? userMax}) {
    if (userMin != null) _overlayIntensityRange.setUserMin(userMin);
    if (userMax != null) _overlayIntensityRange.setUserMax(userMax);
    _overlayIntensityRange.setCurrent(
      _overlayIntensityRange.userMax,
      syncUserMax: false,
    );
  }

  void setOverlayIntensityRange(ParameterRange range) {
    _overlayIntensityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get overlayOpacity => _overlayOpacityRange.userMax;
  set overlayOpacity(double value) {
    _overlayOpacityRange.setCurrent(value);
  }

  ParameterRange get overlayOpacityRange => _overlayOpacityRange.copy();
  void updateOverlayOpacityRange({double? userMin, double? userMax}) {
    if (userMin != null) _overlayOpacityRange.setUserMin(userMin);
    if (userMax != null) _overlayOpacityRange.setUserMax(userMax);
    _overlayOpacityRange.setCurrent(
      _overlayOpacityRange.userMax,
      syncUserMax: false,
    );
  }

  void setOverlayOpacityRange(ParameterRange range) {
    _overlayOpacityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
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
    double? hueMin,
    double? hueMax,
    double? hueCurrent,
    double saturation = 0.0,
    double? saturationMin,
    double? saturationMax,
    double? saturationCurrent,
    double lightness = 0.0,
    double? lightnessMin,
    double? lightnessMax,
    double? lightnessCurrent,
    double overlayHue = 0.0,
    double? overlayHueMin,
    double? overlayHueMax,
    double? overlayHueCurrent,
    double overlayIntensity = 0.0,
    double? overlayIntensityMin,
    double? overlayIntensityMax,
    double? overlayIntensityCurrent,
    double overlayOpacity = 0.0,
    double? overlayOpacityMin,
    double? overlayOpacityMax,
    double? overlayOpacityCurrent,
    bool colorAnimated = false,
    bool overlayAnimated = false,
    AnimationOptions? colorAnimOptions,
    AnimationOptions? overlayAnimOptions,
    bool applyToImage = true,
    bool applyToText = true,
  }) : _colorEnabled = colorEnabled,
       _hueRange = ParameterRange(
         hardMin: -1.0,
         hardMax: 1.0,
         initialValue: hueCurrent ?? hue,
         userMin: hueMin ?? 0.0,
         userMax: hueMax ?? hue,
       ),
       _saturationRange = ParameterRange(
         hardMin: -1.0,
         hardMax: 1.0,
         initialValue: saturationCurrent ?? saturation,
         userMin: saturationMin ?? 0.0,
         userMax: saturationMax ?? saturation,
       ),
       _lightnessRange = ParameterRange(
         hardMin: -1.0,
         hardMax: 1.0,
         initialValue: lightnessCurrent ?? lightness,
         userMin: lightnessMin ?? 0.0,
         userMax: lightnessMax ?? lightness,
       ),
       _overlayHueRange = ParameterRange(
         hardMin: -1.0,
         hardMax: 1.0,
         initialValue: overlayHueCurrent ?? overlayHue,
         userMin: overlayHueMin ?? 0.0,
         userMax: overlayHueMax ?? overlayHue,
       ),
       _overlayIntensityRange = ParameterRange(
         hardMin: -1.0,
         hardMax: 1.0,
         initialValue: overlayIntensityCurrent ?? overlayIntensity,
         userMin: overlayIntensityMin ?? 0.0,
         userMax: overlayIntensityMax ?? overlayIntensity,
       ),
       _overlayOpacityRange = ParameterRange(
         hardMin: -1.0,
         hardMax: 1.0,
         initialValue: overlayOpacityCurrent ?? overlayOpacity,
         userMin: overlayOpacityMin ?? 0.0,
         userMax: overlayOpacityMax ?? overlayOpacity,
       ),
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
      'hue': hue,
      'hueMin': _hueRange.userMin,
      'hueMax': _hueRange.userMax,
      'hueCurrent': _hueRange.current,
      'hueRange': _hueRange.toMap(),
      'saturation': saturation,
      'saturationMin': _saturationRange.userMin,
      'saturationMax': _saturationRange.userMax,
      'saturationCurrent': _saturationRange.current,
      'saturationRange': _saturationRange.toMap(),
      'lightness': lightness,
      'lightnessMin': _lightnessRange.userMin,
      'lightnessMax': _lightnessRange.userMax,
      'lightnessCurrent': _lightnessRange.current,
      'lightnessRange': _lightnessRange.toMap(),
      'overlayHue': overlayHue,
      'overlayHueMin': _overlayHueRange.userMin,
      'overlayHueMax': _overlayHueRange.userMax,
      'overlayHueCurrent': _overlayHueRange.current,
      'overlayHueRange': _overlayHueRange.toMap(),
      'overlayIntensity': overlayIntensity,
      'overlayIntensityMin': _overlayIntensityRange.userMin,
      'overlayIntensityMax': _overlayIntensityRange.userMax,
      'overlayIntensityCurrent': _overlayIntensityRange.current,
      'overlayIntensityRange': _overlayIntensityRange.toMap(),
      'overlayOpacity': overlayOpacity,
      'overlayOpacityMin': _overlayOpacityRange.userMin,
      'overlayOpacityMax': _overlayOpacityRange.userMax,
      'overlayOpacityCurrent': _overlayOpacityRange.current,
      'overlayOpacityRange': _overlayOpacityRange.toMap(),
      'colorAnimated': _colorAnimated,
      'overlayAnimated': _overlayAnimated,
      'colorAnimOptions': _colorAnimOptions.toMap(),
      'overlayAnimOptions': _overlayAnimOptions.toMap(),
    };

    addTargetingToMap(map);

    return map;
  }

  factory ColorSettings.fromMap(Map<String, dynamic> map) {
    double _readDouble(dynamic value, double fallback) {
      if (value is num) return value.toDouble();
      return fallback;
    }

    double _readClamped(dynamic value, double fallback) {
      return _readDouble(value, fallback).clamp(-1.0, 1.0).toDouble();
    }

    final settings = ColorSettings(
      colorEnabled: map['colorEnabled'] ?? false,
      hue: _readClamped(map['hue'], 0.0),
      hueMin: _readClamped(map['hueMin'], 0.0),
      hueMax: _readClamped(map['hueMax'], _readDouble(map['hue'], 0.0)),
      hueCurrent: _readClamped(map['hueCurrent'], _readDouble(map['hue'], 0.0)),
      saturation: _readClamped(map['saturation'], 0.0),
      saturationMin: _readClamped(map['saturationMin'], 0.0),
      saturationMax: _readClamped(
        map['saturationMax'],
        _readDouble(map['saturation'], 0.0),
      ),
      saturationCurrent: _readClamped(
        map['saturationCurrent'],
        _readDouble(map['saturation'], 0.0),
      ),
      lightness: _readClamped(map['lightness'], 0.0),
      lightnessMin: _readClamped(map['lightnessMin'], 0.0),
      lightnessMax: _readClamped(
        map['lightnessMax'],
        _readDouble(map['lightness'], 0.0),
      ),
      lightnessCurrent: _readClamped(
        map['lightnessCurrent'],
        _readDouble(map['lightness'], 0.0),
      ),
      overlayHue: _readClamped(map['overlayHue'], 0.0),
      overlayHueMin: _readClamped(map['overlayHueMin'], 0.0),
      overlayHueMax: _readClamped(
        map['overlayHueMax'],
        _readDouble(map['overlayHue'], 0.0),
      ),
      overlayHueCurrent: _readClamped(
        map['overlayHueCurrent'],
        _readDouble(map['overlayHue'], 0.0),
      ),
      overlayIntensity: _readClamped(map['overlayIntensity'], 0.0),
      overlayIntensityMin: _readClamped(map['overlayIntensityMin'], 0.0),
      overlayIntensityMax: _readClamped(
        map['overlayIntensityMax'],
        _readDouble(map['overlayIntensity'], 0.0),
      ),
      overlayIntensityCurrent: _readClamped(
        map['overlayIntensityCurrent'],
        _readDouble(map['overlayIntensity'], 0.0),
      ),
      overlayOpacity: _readClamped(map['overlayOpacity'], 0.0),
      overlayOpacityMin: _readClamped(map['overlayOpacityMin'], 0.0),
      overlayOpacityMax: _readClamped(
        map['overlayOpacityMax'],
        _readDouble(map['overlayOpacity'], 0.0),
      ),
      overlayOpacityCurrent: _readClamped(
        map['overlayOpacityCurrent'],
        _readDouble(map['overlayOpacity'], 0.0),
      ),
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

    _maybeApplyRange(
      settings._hueRange,
      map['hueRange'],
      hardMin: -1.0,
      hardMax: 1.0,
      fallback: settings.hue,
    );
    _maybeApplyRange(
      settings._saturationRange,
      map['saturationRange'],
      hardMin: -1.0,
      hardMax: 1.0,
      fallback: settings.saturation,
    );
    _maybeApplyRange(
      settings._lightnessRange,
      map['lightnessRange'],
      hardMin: -1.0,
      hardMax: 1.0,
      fallback: settings.lightness,
    );
    _maybeApplyRange(
      settings._overlayHueRange,
      map['overlayHueRange'],
      hardMin: -1.0,
      hardMax: 1.0,
      fallback: settings.overlayHue,
    );
    _maybeApplyRange(
      settings._overlayIntensityRange,
      map['overlayIntensityRange'],
      hardMin: -1.0,
      hardMax: 1.0,
      fallback: settings.overlayIntensity,
    );
    _maybeApplyRange(
      settings._overlayOpacityRange,
      map['overlayOpacityRange'],
      hardMin: -1.0,
      hardMax: 1.0,
      fallback: settings.overlayOpacity,
    );

    settings.loadTargetingFromMap(map);

    return settings;
  }

  static void _maybeApplyRange(
    ParameterRange target,
    dynamic payload, {
    required double hardMin,
    required double hardMax,
    required double fallback,
  }) {
    if (payload is Map<String, dynamic>) {
      final range = ParameterRange.fromMap(
        Map<String, dynamic>.from(payload),
        hardMin: hardMin,
        hardMax: hardMax,
        fallbackValue: fallback,
      );
      target
        ..setUserMin(range.userMin)
        ..setUserMax(range.userMax)
        ..setCurrent(range.current, syncUserMax: false);
    }
  }
}
