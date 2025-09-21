// shatter effect
import 'animation_options.dart';
import 'parameter_range.dart';
import 'targetable_effect_settings.dart';

class BlurSettings with TargetableEffectSettings {
  // Enable flag for blur effect
  bool _blurEnabled;

  // Blur settings
  ParameterRange _blurAmountRange;
  ParameterRange _blurRadiusRange;
  ParameterRange _blurOpacityRange; // 0-1 opacity applied to effect
  int _blurBlendMode; // 0=normal,1=multiply,2=screen
  ParameterRange _blurIntensityRange; // Amplifies the intensity of shatter fragments
  ParameterRange _blurContrastRange; // Increases contrast between fragments

  // Animation flag
  bool _blurAnimated;

  // Animation options
  AnimationOptions _blurAnimOptions;

  // Flag to control logging
  static bool enableLogging = false;

  // Property getters and setters
  bool get blurEnabled => _blurEnabled;
  set blurEnabled(bool value) {
    _blurEnabled = value;
    if (enableLogging) print("SETTINGS: blurEnabled set to $value");
  }

  double get blurAmount => _blurAmountRange.userMax;
  set blurAmount(double value) {
    _blurAmountRange.setCurrent(value);
  }

  ParameterRange get blurAmountRange => _blurAmountRange.copy();
  void updateBlurAmountRange({double? userMin, double? userMax}) {
    if (userMin != null) _blurAmountRange.setUserMin(userMin);
    if (userMax != null) _blurAmountRange.setUserMax(userMax);
    _blurAmountRange.setCurrent(_blurAmountRange.userMax, syncUserMax: false);
  }

  void setBlurAmountRange(ParameterRange range) {
    _blurAmountRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get blurRadius => _blurRadiusRange.userMax;
  set blurRadius(double value) {
    _blurRadiusRange.setCurrent(value);
  }

  ParameterRange get blurRadiusRange => _blurRadiusRange.copy();
  void updateBlurRadiusRange({double? userMin, double? userMax}) {
    if (userMin != null) _blurRadiusRange.setUserMin(userMin);
    if (userMax != null) _blurRadiusRange.setUserMax(userMax);
    _blurRadiusRange.setCurrent(_blurRadiusRange.userMax, syncUserMax: false);
  }

  void setBlurRadiusRange(ParameterRange range) {
    _blurRadiusRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  // Blur animation toggle with logging
  bool get blurAnimated => _blurAnimated;
  set blurAnimated(bool value) {
    _blurAnimated = value;
    if (enableLogging) print("SETTINGS: blurAnimated set to $value");
  }

  // Settings with logging
  double get blurOpacity => _blurOpacityRange.userMax;
  set blurOpacity(double value) {
    _blurOpacityRange.setCurrent(value);
  }

  ParameterRange get blurOpacityRange => _blurOpacityRange.copy();
  void updateBlurOpacityRange({double? userMin, double? userMax}) {
    if (userMin != null) _blurOpacityRange.setUserMin(userMin);
    if (userMax != null) _blurOpacityRange.setUserMax(userMax);
    _blurOpacityRange.setCurrent(
      _blurOpacityRange.userMax,
      syncUserMax: false,
    );
  }

  void setBlurOpacityRange(ParameterRange range) {
    _blurOpacityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  int get blurBlendMode => _blurBlendMode;
  set blurBlendMode(int value) {
    _blurBlendMode = value;
    if (enableLogging) print("SETTINGS: blurBlendMode set to $value");
  }

  // Intensity and contrast controls
  double get blurIntensity => _blurIntensityRange.userMax;
  set blurIntensity(double value) {
    _blurIntensityRange.setCurrent(value);
  }

  ParameterRange get blurIntensityRange => _blurIntensityRange.copy();
  void updateBlurIntensityRange({double? userMin, double? userMax}) {
    if (userMin != null) _blurIntensityRange.setUserMin(userMin);
    if (userMax != null) _blurIntensityRange.setUserMax(userMax);
    _blurIntensityRange.setCurrent(
      _blurIntensityRange.userMax,
      syncUserMax: false,
    );
  }

  void setBlurIntensityRange(ParameterRange range) {
    _blurIntensityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get blurContrast => _blurContrastRange.userMax;
  set blurContrast(double value) {
    _blurContrastRange.setCurrent(value);
  }

  ParameterRange get blurContrastRange => _blurContrastRange.copy();
  void updateBlurContrastRange({double? userMin, double? userMax}) {
    if (userMin != null) _blurContrastRange.setUserMin(userMin);
    if (userMax != null) _blurContrastRange.setUserMax(userMax);
    _blurContrastRange.setCurrent(
      _blurContrastRange.userMax,
      syncUserMax: false,
    );
  }

  void setBlurContrastRange(ParameterRange range) {
    _blurContrastRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  AnimationOptions get blurAnimOptions => _blurAnimOptions;
  set blurAnimOptions(AnimationOptions value) {
    _blurAnimOptions = value;
    if (enableLogging) print("SETTINGS: blurAnimOptions updated");
  }

  BlurSettings({
    bool blurEnabled = false,
    double blurAmount = 0.0,
    double? blurAmountMin,
    double? blurAmountMax,
    double? blurAmountCurrent,
    double blurRadius = 15.0,
    double? blurRadiusMin,
    double? blurRadiusMax,
    double? blurRadiusCurrent,
    double blurOpacity = 1.0,
    double? blurOpacityMin,
    double? blurOpacityMax,
    double? blurOpacityCurrent,
    int blurBlendMode = 0,
    double blurIntensity = 1.0,
    double? blurIntensityMin,
    double? blurIntensityMax,
    double? blurIntensityCurrent,
    double blurContrast = 0.0,
    double? blurContrastMin,
    double? blurContrastMax,
    double? blurContrastCurrent,
    bool blurAnimated = false,
    AnimationOptions? blurAnimOptions,
    bool applyToImage = true, // New parameter with default true
    bool applyToText =
        false, // Changed default to false to prevent unwanted text effects
  }) : _blurEnabled = blurEnabled,
       _blurAmountRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: blurAmountCurrent ?? blurAmount,
         userMin: blurAmountMin ?? 0.0,
         userMax: blurAmountMax ?? blurAmount,
       ),
       _blurRadiusRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 120.0,
         initialValue: blurRadiusCurrent ?? blurRadius,
         userMin: blurRadiusMin ?? 0.0,
         userMax: blurRadiusMax ?? blurRadius,
       ),
       _blurOpacityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: blurOpacityCurrent ?? blurOpacity,
         userMin: blurOpacityMin ?? 0.0,
         userMax: blurOpacityMax ?? blurOpacity,
       ),
       _blurBlendMode = blurBlendMode,
       _blurIntensityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 3.0,
         initialValue: blurIntensityCurrent ?? blurIntensity,
         userMin: blurIntensityMin ?? 0.0,
         userMax: blurIntensityMax ?? blurIntensity,
       ),
        _blurContrastRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 2.0,
         initialValue: blurContrastCurrent ?? blurContrast,
         userMin: blurContrastMin ?? 0.0,
         userMax: blurContrastMax ?? blurContrast,
       ),
       _blurAnimated = blurAnimated,
       _blurAnimOptions = blurAnimOptions ?? AnimationOptions() {
    // Set the targeting flags
    this.applyToImage = applyToImage;
    this.applyToText = applyToText;

    if (enableLogging) print("SETTINGS: BlurSettings initialized");
  }

  // Serialization helpers
  Map<String, dynamic> toMap() {
    final map = {
      'blurEnabled': _blurEnabled,
      'blurAmount': blurAmount,
      'blurAmountMin': _blurAmountRange.userMin,
      'blurAmountMax': _blurAmountRange.userMax,
      'blurAmountCurrent': _blurAmountRange.current,
      'blurAmountRange': _blurAmountRange.toMap(),
      'blurRadius': blurRadius,
      'blurRadiusMin': _blurRadiusRange.userMin,
      'blurRadiusMax': _blurRadiusRange.userMax,
      'blurRadiusCurrent': _blurRadiusRange.current,
      'blurRadiusRange': _blurRadiusRange.toMap(),
      'blurOpacity': blurOpacity,
      'blurOpacityMin': _blurOpacityRange.userMin,
      'blurOpacityMax': _blurOpacityRange.userMax,
      'blurOpacityCurrent': _blurOpacityRange.current,
      'blurOpacityRange': _blurOpacityRange.toMap(),
      'blurBlendMode': _blurBlendMode,
      'blurIntensity': blurIntensity,
      'blurIntensityMin': _blurIntensityRange.userMin,
      'blurIntensityMax': _blurIntensityRange.userMax,
      'blurIntensityCurrent': _blurIntensityRange.current,
      'blurIntensityRange': _blurIntensityRange.toMap(),
      'blurContrast': blurContrast,
      'blurContrastMin': _blurContrastRange.userMin,
      'blurContrastMax': _blurContrastRange.userMax,
      'blurContrastCurrent': _blurContrastRange.current,
      'blurContrastRange': _blurContrastRange.toMap(),
      'blurAnimated': _blurAnimated,
      'blurAnimOptions': _blurAnimOptions.toMap(),
    };

    // Add targeting flags from the mixin
    addTargetingToMap(map);

    return map;
  }

  factory BlurSettings.fromMap(Map<String, dynamic> map) {
    double _readDouble(dynamic value, double fallback) {
      if (value is num) return value.toDouble();
      return fallback;
    }

    double _readClamped(dynamic value, double fallback, double min, double max) {
      return _readDouble(value, fallback).clamp(min, max).toDouble();
    }

    final settings = BlurSettings(
      blurEnabled: map['blurEnabled'] ?? false,
      blurAmount: _readClamped(map['blurAmount'], 0.0, 0.0, 1.0),
      blurAmountMin: _readClamped(map['blurAmountMin'], 0.0, 0.0, 1.0),
      blurAmountMax: _readClamped(
        map['blurAmountMax'],
        _readDouble(map['blurAmount'], 0.0),
        0.0,
        1.0,
      ),
      blurAmountCurrent: _readClamped(
        map['blurAmountCurrent'],
        _readDouble(map['blurAmount'], 0.0),
        0.0,
        1.0,
      ),
      blurRadius: _readClamped(map['blurRadius'], 15.0, 0.0, 120.0),
      blurRadiusMin: _readClamped(map['blurRadiusMin'], 0.0, 0.0, 120.0),
      blurRadiusMax: _readClamped(
        map['blurRadiusMax'],
        _readDouble(map['blurRadius'], 15.0),
        0.0,
        120.0,
      ),
      blurRadiusCurrent: _readClamped(
        map['blurRadiusCurrent'],
        _readDouble(map['blurRadius'], 15.0),
        0.0,
        120.0,
      ),
      blurOpacity: _readClamped(map['blurOpacity'], 1.0, 0.0, 1.0),
      blurOpacityMin: _readClamped(map['blurOpacityMin'], 0.0, 0.0, 1.0),
      blurOpacityMax: _readClamped(
        map['blurOpacityMax'],
        _readDouble(map['blurOpacity'], 1.0),
        0.0,
        1.0,
      ),
      blurOpacityCurrent: _readClamped(
        map['blurOpacityCurrent'],
        _readDouble(map['blurOpacity'], 1.0),
        0.0,
        1.0,
      ),
      blurBlendMode: map['blurBlendMode'] ?? 0,
      blurIntensity: _readClamped(map['blurIntensity'], 1.0, 0.0, 3.0),
      blurIntensityMin: _readClamped(map['blurIntensityMin'], 0.0, 0.0, 3.0),
      blurIntensityMax: _readClamped(
        map['blurIntensityMax'],
        _readDouble(map['blurIntensity'], 1.0),
        0.0,
        3.0,
      ),
      blurIntensityCurrent: _readClamped(
        map['blurIntensityCurrent'],
        _readDouble(map['blurIntensity'], 1.0),
        0.0,
        3.0,
      ),
      blurContrast: _readClamped(map['blurContrast'], 0.0, 0.0, 2.0),
      blurContrastMin: _readClamped(map['blurContrastMin'], 0.0, 0.0, 2.0),
      blurContrastMax: _readClamped(
        map['blurContrastMax'],
        _readDouble(map['blurContrast'], 0.0),
        0.0,
        2.0,
      ),
      blurContrastCurrent: _readClamped(
        map['blurContrastCurrent'],
        _readDouble(map['blurContrast'], 0.0),
        0.0,
        2.0,
      ),
      blurAnimated: map['blurAnimated'] ?? false,
      blurAnimOptions: map['blurAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['blurAnimOptions']),
            )
          : null,
    );

    // Override with range payloads when provided (new schema)
    _maybeApplyRange(
      settings._blurAmountRange,
      map['blurAmountRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.blurAmount,
    );
    _maybeApplyRange(
      settings._blurRadiusRange,
      map['blurRadiusRange'],
      hardMin: 0.0,
      hardMax: 120.0,
      fallback: settings.blurRadius,
    );
    _maybeApplyRange(
      settings._blurOpacityRange,
      map['blurOpacityRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.blurOpacity,
    );
    _maybeApplyRange(
      settings._blurIntensityRange,
      map['blurIntensityRange'],
      hardMin: 0.0,
      hardMax: 3.0,
      fallback: settings.blurIntensity,
    );
    _maybeApplyRange(
      settings._blurContrastRange,
      map['blurContrastRange'],
      hardMin: 0.0,
      hardMax: 2.0,
      fallback: settings.blurContrast,
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
        payload,
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
