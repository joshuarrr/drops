import 'animation_options.dart';
import 'parameter_range.dart';
import 'targetable_effect_settings.dart';

class NoiseSettings with TargetableEffectSettings {
  // Enable flag for noise effect
  bool _noiseEnabled;

  // Noise effect settings
  ParameterRange _noiseScaleRange; // Scale of the noise pattern
  ParameterRange _noiseSpeedRange; // Speed of the animation
  ParameterRange _colorIntensityRange; // Intensity of the color overlay
  ParameterRange _waveAmountRange; // Amount of wave distortion

  // Animation flag
  bool _noiseAnimated; // Animation flag for noise effect

  // Animation options
  AnimationOptions _noiseAnimOptions;

  // Flag to control logging
  static bool enableLogging = false;

  // Property getters and setters
  bool get noiseEnabled => _noiseEnabled;
  set noiseEnabled(bool value) {
    _noiseEnabled = value;
  }

  // Noise effect getters and setters
  double get noiseScale => _noiseScaleRange.userMax;
  set noiseScale(double value) {
    _noiseScaleRange.setCurrent(value);
  }

  ParameterRange get noiseScaleRange => _noiseScaleRange.copy();
  void updateNoiseScaleRange({double? userMin, double? userMax}) {
    if (userMin != null) _noiseScaleRange.setUserMin(userMin);
    if (userMax != null) _noiseScaleRange.setUserMax(userMax);
    _noiseScaleRange.setCurrent(_noiseScaleRange.userMax, syncUserMax: false);
  }

  void setNoiseScaleRange(ParameterRange range) {
    _noiseScaleRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get noiseSpeed => _noiseSpeedRange.userMax;
  set noiseSpeed(double value) {
    _noiseSpeedRange.setCurrent(value);
  }

  ParameterRange get noiseSpeedRange => _noiseSpeedRange.copy();
  void updateNoiseSpeedRange({double? userMin, double? userMax}) {
    if (userMin != null) _noiseSpeedRange.setUserMin(userMin);
    if (userMax != null) _noiseSpeedRange.setUserMax(userMax);
    _noiseSpeedRange.setCurrent(_noiseSpeedRange.userMax, syncUserMax: false);
  }

  void setNoiseSpeedRange(ParameterRange range) {
    _noiseSpeedRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get colorIntensity => _colorIntensityRange.userMax;
  set colorIntensity(double value) {
    _colorIntensityRange.setCurrent(value);
  }

  ParameterRange get colorIntensityRange => _colorIntensityRange.copy();
  void updateColorIntensityRange({double? userMin, double? userMax}) {
    if (userMin != null) _colorIntensityRange.setUserMin(userMin);
    if (userMax != null) _colorIntensityRange.setUserMax(userMax);
    _colorIntensityRange.setCurrent(
      _colorIntensityRange.userMax,
      syncUserMax: false,
    );
  }

  void setColorIntensityRange(ParameterRange range) {
    _colorIntensityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get waveAmount => _waveAmountRange.userMax;
  set waveAmount(double value) {
    _waveAmountRange.setCurrent(value);
  }

  ParameterRange get waveAmountRange => _waveAmountRange.copy();
  void updateWaveAmountRange({double? userMin, double? userMax}) {
    if (userMin != null) _waveAmountRange.setUserMin(userMin);
    if (userMax != null) _waveAmountRange.setUserMax(userMax);
    _waveAmountRange.setCurrent(_waveAmountRange.userMax, syncUserMax: false);
  }

  void setWaveAmountRange(ParameterRange range) {
    _waveAmountRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  bool get noiseAnimated => _noiseAnimated;
  set noiseAnimated(bool value) {
    _noiseAnimated = value;
  }

  AnimationOptions get noiseAnimOptions => _noiseAnimOptions;
  set noiseAnimOptions(AnimationOptions value) {
    _noiseAnimOptions = value;
  }

  NoiseSettings({
    bool noiseEnabled = false,
    double noiseScale = 5.0,
    double? noiseScaleMin,
    double? noiseScaleMax,
    double? noiseScaleCurrent,
    double noiseSpeed = 0.5,
    double? noiseSpeedMin,
    double? noiseSpeedMax,
    double? noiseSpeedCurrent,
    double colorIntensity = 0.3,
    double? colorIntensityMin,
    double? colorIntensityMax,
    double? colorIntensityCurrent,
    double waveAmount = 0.02,
    double? waveAmountMin,
    double? waveAmountMax,
    double? waveAmountCurrent,
    bool noiseAnimated = false,
    AnimationOptions? noiseAnimOptions,
    bool applyToImage = true, // New parameter with default true
    bool applyToText = true, // New parameter with default true
  }) : _noiseEnabled = noiseEnabled,
       _noiseScaleRange = ParameterRange(
         hardMin: 0.1,
         hardMax: 20.0,
         initialValue: noiseScaleCurrent ?? noiseScale,
         userMin: noiseScaleMin ?? 0.1,
         userMax: noiseScaleMax ?? noiseScale,
       ),
       _noiseSpeedRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: noiseSpeedCurrent ?? noiseSpeed,
         userMin: noiseSpeedMin ?? 0.0,
         userMax: noiseSpeedMax ?? noiseSpeed,
       ),
       _colorIntensityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: colorIntensityCurrent ?? colorIntensity,
         userMin: colorIntensityMin ?? 0.0,
         userMax: colorIntensityMax ?? colorIntensity,
       ),
       _waveAmountRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 0.1,
         initialValue: waveAmountCurrent ?? waveAmount,
         userMin: waveAmountMin ?? 0.0,
         userMax: waveAmountMax ?? waveAmount,
       ),
       _noiseAnimated = noiseAnimated,
       _noiseAnimOptions = noiseAnimOptions ?? AnimationOptions() {
    // Set the targeting flags
    this.applyToImage = applyToImage;
    this.applyToText = applyToText;
  }

  // Serialization helpers
  Map<String, dynamic> toMap() {
    final map = {
      'noiseEnabled': _noiseEnabled,
      'noiseScale': noiseScale,
      'noiseScaleMin': _noiseScaleRange.userMin,
      'noiseScaleMax': _noiseScaleRange.userMax,
      'noiseScaleCurrent': _noiseScaleRange.current,
      'noiseScaleRange': _noiseScaleRange.toMap(),
      'noiseSpeed': noiseSpeed,
      'noiseSpeedMin': _noiseSpeedRange.userMin,
      'noiseSpeedMax': _noiseSpeedRange.userMax,
      'noiseSpeedCurrent': _noiseSpeedRange.current,
      'noiseSpeedRange': _noiseSpeedRange.toMap(),
      'colorIntensity': colorIntensity,
      'colorIntensityMin': _colorIntensityRange.userMin,
      'colorIntensityMax': _colorIntensityRange.userMax,
      'colorIntensityCurrent': _colorIntensityRange.current,
      'colorIntensityRange': _colorIntensityRange.toMap(),
      'waveAmount': waveAmount,
      'waveAmountMin': _waveAmountRange.userMin,
      'waveAmountMax': _waveAmountRange.userMax,
      'waveAmountCurrent': _waveAmountRange.current,
      'waveAmountRange': _waveAmountRange.toMap(),
      'noiseAnimated': _noiseAnimated,
      'noiseAnimOptions': _noiseAnimOptions.toMap(),
    };

    // Add targeting flags from the mixin
    addTargetingToMap(map);

    return map;
  }

  factory NoiseSettings.fromMap(Map<String, dynamic> map) {
    double _readDouble(dynamic value, double fallback) {
      if (value is num) return value.toDouble();
      return fallback;
    }

    double _readClamped(dynamic value, double fallback, double min, double max) {
      return _readDouble(value, fallback).clamp(min, max).toDouble();
    }

    final settings = NoiseSettings(
      noiseEnabled: map['noiseEnabled'] ?? false,
      noiseScale: _readClamped(map['noiseScale'], 5.0, 0.1, 20.0),
      noiseScaleMin: _readClamped(map['noiseScaleMin'], 0.1, 0.1, 20.0),
      noiseScaleMax: _readClamped(
        map['noiseScaleMax'],
        _readDouble(map['noiseScale'], 5.0),
        0.1,
        20.0,
      ),
      noiseScaleCurrent: _readClamped(
        map['noiseScaleCurrent'],
        _readDouble(map['noiseScale'], 5.0),
        0.1,
        20.0,
      ),
      noiseSpeed: _readClamped(map['noiseSpeed'], 0.5, 0.0, 1.0),
      noiseSpeedMin: _readClamped(map['noiseSpeedMin'], 0.0, 0.0, 1.0),
      noiseSpeedMax: _readClamped(
        map['noiseSpeedMax'],
        _readDouble(map['noiseSpeed'], 0.5),
        0.0,
        1.0,
      ),
      noiseSpeedCurrent: _readClamped(
        map['noiseSpeedCurrent'],
        _readDouble(map['noiseSpeed'], 0.5),
        0.0,
        1.0,
      ),
      colorIntensity: _readClamped(map['colorIntensity'], 0.3, 0.0, 1.0),
      colorIntensityMin: _readClamped(map['colorIntensityMin'], 0.0, 0.0, 1.0),
      colorIntensityMax: _readClamped(
        map['colorIntensityMax'],
        _readDouble(map['colorIntensity'], 0.3),
        0.0,
        1.0,
      ),
      colorIntensityCurrent: _readClamped(
        map['colorIntensityCurrent'],
        _readDouble(map['colorIntensity'], 0.3),
        0.0,
        1.0,
      ),
      waveAmount: _readClamped(map['waveAmount'], 0.02, 0.0, 0.1),
      waveAmountMin: _readClamped(map['waveAmountMin'], 0.0, 0.0, 0.1),
      waveAmountMax: _readClamped(
        map['waveAmountMax'],
        _readDouble(map['waveAmount'], 0.02),
        0.0,
        0.1,
      ),
      waveAmountCurrent: _readClamped(
        map['waveAmountCurrent'],
        _readDouble(map['waveAmount'], 0.02),
        0.0,
        0.1,
      ),
      noiseAnimated: map['noiseAnimated'] ?? false,
      noiseAnimOptions: map['noiseAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['noiseAnimOptions']),
            )
          : null,
    );

    _maybeApplyRange(
      settings._noiseScaleRange,
      map['noiseScaleRange'],
      hardMin: 0.1,
      hardMax: 20.0,
      fallback: settings.noiseScale,
    );
    _maybeApplyRange(
      settings._noiseSpeedRange,
      map['noiseSpeedRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.noiseSpeed,
    );
    _maybeApplyRange(
      settings._colorIntensityRange,
      map['colorIntensityRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.colorIntensity,
    );
    _maybeApplyRange(
      settings._waveAmountRange,
      map['waveAmountRange'],
      hardMin: 0.0,
      hardMax: 0.1,
      fallback: settings.waveAmount,
    );

    // Load targeting flags from the map
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
