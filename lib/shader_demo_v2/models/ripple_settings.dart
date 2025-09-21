import 'animation_options.dart';
import 'dart:math';
import 'parameter_range.dart';
import 'targetable_effect_settings.dart';

class RippleSettings with TargetableEffectSettings {
  // Enable flag for ripple effect
  bool _rippleEnabled;

  // Ripple settings
  ParameterRange _rippleIntensityRange; // Controls number of ripples (0-1)
  ParameterRange _rippleSizeRange; // Controls size of ripples (0-1)
  ParameterRange _rippleSpeedRange; // Controls speed of ripple expansion (0-1)
  ParameterRange _rippleOpacityRange; // Controls opacity of ripples (0-1)
  ParameterRange _rippleColorRange; // Controls color influence (0-1)
  int _rippleDropCount; // Controls number of ripple sources (1-30)
  double _rippleSeed; // Randomization seed for drop positions
  ParameterRange
  _rippleOvalnessRange; // Controls how oval the ripples are (0=circles, 1=very oval)
  ParameterRange
  _rippleRotationRange; // Controls rotation angle of oval ripples (0-1, scaled to 0-2π)

  // Random generator
  static final Random _random = Random();

  // Animation flag
  bool _rippleAnimated;

  // Animation options
  AnimationOptions _rippleAnimOptions;

  // Flag to control logging
  static bool enableLogging = false;

  // Property getters and setters
  bool get rippleEnabled => _rippleEnabled;
  set rippleEnabled(bool value) {
    _rippleEnabled = value;
  }

  double get rippleIntensity => _rippleIntensityRange.userMax;
  set rippleIntensity(double value) {
    _rippleIntensityRange.setCurrent(value);
  }

  ParameterRange get rippleIntensityRange => _rippleIntensityRange.copy();
  void setRippleIntensityRange(ParameterRange range) {
    _rippleIntensityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get rippleSize => _rippleSizeRange.userMax;
  set rippleSize(double value) {
    _rippleSizeRange.setCurrent(value);
  }

  ParameterRange get rippleSizeRange => _rippleSizeRange.copy();
  void setRippleSizeRange(ParameterRange range) {
    _rippleSizeRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get rippleSpeed => _rippleSpeedRange.userMax;
  set rippleSpeed(double value) {
    _rippleSpeedRange.setCurrent(value);
  }

  ParameterRange get rippleSpeedRange => _rippleSpeedRange.copy();
  void setRippleSpeedRange(ParameterRange range) {
    _rippleSpeedRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get rippleOpacity => _rippleOpacityRange.userMax;
  set rippleOpacity(double value) {
    _rippleOpacityRange.setCurrent(value);
  }

  ParameterRange get rippleOpacityRange => _rippleOpacityRange.copy();
  void setRippleOpacityRange(ParameterRange range) {
    _rippleOpacityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get rippleColor => _rippleColorRange.userMax;
  set rippleColor(double value) {
    _rippleColorRange.setCurrent(value);
  }

  ParameterRange get rippleColorRange => _rippleColorRange.copy();
  void setRippleColorRange(ParameterRange range) {
    _rippleColorRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  int get rippleDropCount => _rippleDropCount;
  set rippleDropCount(int value) {
    _rippleDropCount = value;
  }

  double get rippleSeed => _rippleSeed;
  set rippleSeed(double value) {
    _rippleSeed = value;
  }

  double get rippleOvalness => _rippleOvalnessRange.userMax;
  set rippleOvalness(double value) {
    _rippleOvalnessRange.setCurrent(value);
  }

  ParameterRange get rippleOvalnessRange => _rippleOvalnessRange.copy();
  void setRippleOvalnessRange(ParameterRange range) {
    _rippleOvalnessRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get rippleRotation => _rippleRotationRange.userMax;
  set rippleRotation(double value) {
    _rippleRotationRange.setCurrent(value);
  }

  ParameterRange get rippleRotationRange => _rippleRotationRange.copy();
  void setRippleRotationRange(ParameterRange range) {
    _rippleRotationRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  // Generate a new random seed to randomize drop positions
  void randomizeDropPositions() {
    _rippleSeed = _random.nextDouble() * 1000.0;
    if (enableLogging) {}
  }

  // Ripple animation toggle with logging
  bool get rippleAnimated => _rippleAnimated;
  set rippleAnimated(bool value) {
    _rippleAnimated = value;
  }

  AnimationOptions get rippleAnimOptions => _rippleAnimOptions;
  set rippleAnimOptions(AnimationOptions value) {
    _rippleAnimOptions = value;
  }

  // Constructor with default values
  RippleSettings({
    bool rippleEnabled = false,
    double rippleIntensity = 0.5,
    double? rippleIntensityMin,
    double? rippleIntensityMax,
    double? rippleIntensityCurrent,
    double rippleSize = 0.5,
    double? rippleSizeMin,
    double? rippleSizeMax,
    double? rippleSizeCurrent,
    double rippleSpeed = 0.5,
    double? rippleSpeedMin,
    double? rippleSpeedMax,
    double? rippleSpeedCurrent,
    double rippleOpacity = 0.7,
    double? rippleOpacityMin,
    double? rippleOpacityMax,
    double? rippleOpacityCurrent,
    double rippleColor = 0.3,
    double? rippleColorMin,
    double? rippleColorMax,
    double? rippleColorCurrent,
    int rippleDropCount = 9,
    double? rippleSeed,
    double rippleOvalness = 0.0,
    double? rippleOvalnessMin,
    double? rippleOvalnessMax,
    double? rippleOvalnessCurrent,
    double rippleRotation = 0.0,
    double? rippleRotationMin,
    double? rippleRotationMax,
    double? rippleRotationCurrent,
    bool rippleAnimated = false,
    AnimationOptions? rippleAnimOptions,
    bool applyToImage = true, // New parameter with default true
    bool applyToText = true, // New parameter with default true
  }) : _rippleEnabled = rippleEnabled,
       _rippleIntensityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: rippleIntensityCurrent ?? rippleIntensity,
         userMin: rippleIntensityMin ?? 0.0,
         userMax: rippleIntensityMax ?? rippleIntensity,
       ),
       _rippleSizeRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: rippleSizeCurrent ?? rippleSize,
         userMin: rippleSizeMin ?? 0.0,
         userMax: rippleSizeMax ?? rippleSize,
       ),
       _rippleSpeedRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: rippleSpeedCurrent ?? rippleSpeed,
         userMin: rippleSpeedMin ?? 0.0,
         userMax: rippleSpeedMax ?? rippleSpeed,
       ),
       _rippleOpacityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: rippleOpacityCurrent ?? rippleOpacity,
         userMin: rippleOpacityMin ?? 0.0,
         userMax: rippleOpacityMax ?? rippleOpacity,
       ),
       _rippleColorRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: rippleColorCurrent ?? rippleColor,
         userMin: rippleColorMin ?? 0.0,
         userMax: rippleColorMax ?? rippleColor,
       ),
       _rippleDropCount = rippleDropCount,
       _rippleSeed = rippleSeed ?? _random.nextDouble() * 1000.0,
       _rippleOvalnessRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: rippleOvalnessCurrent ?? rippleOvalness,
         userMin: rippleOvalnessMin ?? 0.0,
         userMax: rippleOvalnessMax ?? rippleOvalness,
       ),
       _rippleRotationRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: rippleRotationCurrent ?? rippleRotation,
         userMin: rippleRotationMin ?? 0.0,
         userMax: rippleRotationMax ?? rippleRotation,
       ),
       _rippleAnimated = rippleAnimated,
       _rippleAnimOptions = rippleAnimOptions ?? AnimationOptions() {
    // Set the targeting flags
    this.applyToImage = applyToImage;
    this.applyToText = applyToText;
  }

  // Serialization helpers
  Map<String, dynamic> toMap() {
    final map = {
      'rippleEnabled': _rippleEnabled,
      'rippleIntensity': rippleIntensity,
      'rippleSize': rippleSize,
      'rippleSpeed': rippleSpeed,
      'rippleOpacity': rippleOpacity,
      'rippleColor': rippleColor,
      'rippleDropCount': _rippleDropCount,
      'rippleSeed': _rippleSeed,
      'rippleOvalness': rippleOvalness,
      'rippleRotation': rippleRotation,
      'rippleAnimated': _rippleAnimated,
      'rippleAnimOptions': _rippleAnimOptions.toMap(),
      'rippleIntensityMin': _rippleIntensityRange.userMin,
      'rippleIntensityMax': _rippleIntensityRange.userMax,
      'rippleIntensityCurrent': _rippleIntensityRange.current,
      'rippleIntensityRange': _rippleIntensityRange.toMap(),
      'rippleSizeMin': _rippleSizeRange.userMin,
      'rippleSizeMax': _rippleSizeRange.userMax,
      'rippleSizeCurrent': _rippleSizeRange.current,
      'rippleSizeRange': _rippleSizeRange.toMap(),
      'rippleSpeedMin': _rippleSpeedRange.userMin,
      'rippleSpeedMax': _rippleSpeedRange.userMax,
      'rippleSpeedCurrent': _rippleSpeedRange.current,
      'rippleSpeedRange': _rippleSpeedRange.toMap(),
      'rippleOpacityMin': _rippleOpacityRange.userMin,
      'rippleOpacityMax': _rippleOpacityRange.userMax,
      'rippleOpacityCurrent': _rippleOpacityRange.current,
      'rippleOpacityRange': _rippleOpacityRange.toMap(),
      'rippleColorMin': _rippleColorRange.userMin,
      'rippleColorMax': _rippleColorRange.userMax,
      'rippleColorCurrent': _rippleColorRange.current,
      'rippleColorRange': _rippleColorRange.toMap(),
      'rippleOvalnessMin': _rippleOvalnessRange.userMin,
      'rippleOvalnessMax': _rippleOvalnessRange.userMax,
      'rippleOvalnessCurrent': _rippleOvalnessRange.current,
      'rippleOvalnessRange': _rippleOvalnessRange.toMap(),
      'rippleRotationMin': _rippleRotationRange.userMin,
      'rippleRotationMax': _rippleRotationRange.userMax,
      'rippleRotationCurrent': _rippleRotationRange.current,
      'rippleRotationRange': _rippleRotationRange.toMap(),
    };

    // Add targeting flags from the mixin
    addTargetingToMap(map);

    return map;
  }

  factory RippleSettings.fromMap(Map<String, dynamic> map) {
    double _readDouble(dynamic value, double fallback) {
      if (value is num) return value.toDouble();
      return fallback;
    }

    final settings = RippleSettings(
      rippleEnabled: map['rippleEnabled'] ?? false,
      rippleIntensity: _readDouble(map['rippleIntensity'], 0.5),
      rippleIntensityMin: _readDouble(map['rippleIntensityMin'], 0.0),
      rippleIntensityMax: _readDouble(
        map['rippleIntensityMax'],
        _readDouble(map['rippleIntensity'], 0.5),
      ),
      rippleIntensityCurrent: _readDouble(
        map['rippleIntensityCurrent'],
        _readDouble(map['rippleIntensity'], 0.5),
      ),
      rippleSize: _readDouble(map['rippleSize'], 0.5),
      rippleSizeMin: _readDouble(map['rippleSizeMin'], 0.0),
      rippleSizeMax: _readDouble(
        map['rippleSizeMax'],
        _readDouble(map['rippleSize'], 0.5),
      ),
      rippleSizeCurrent: _readDouble(
        map['rippleSizeCurrent'],
        _readDouble(map['rippleSize'], 0.5),
      ),
      rippleSpeed: _readDouble(map['rippleSpeed'], 0.5),
      rippleSpeedMin: _readDouble(map['rippleSpeedMin'], 0.0),
      rippleSpeedMax: _readDouble(
        map['rippleSpeedMax'],
        _readDouble(map['rippleSpeed'], 0.5),
      ),
      rippleSpeedCurrent: _readDouble(
        map['rippleSpeedCurrent'],
        _readDouble(map['rippleSpeed'], 0.5),
      ),
      rippleOpacity: _readDouble(map['rippleOpacity'], 0.7),
      rippleOpacityMin: _readDouble(map['rippleOpacityMin'], 0.0),
      rippleOpacityMax: _readDouble(
        map['rippleOpacityMax'],
        _readDouble(map['rippleOpacity'], 0.7),
      ),
      rippleOpacityCurrent: _readDouble(
        map['rippleOpacityCurrent'],
        _readDouble(map['rippleOpacity'], 0.7),
      ),
      rippleColor: _readDouble(map['rippleColor'], 0.3),
      rippleColorMin: _readDouble(map['rippleColorMin'], 0.0),
      rippleColorMax: _readDouble(
        map['rippleColorMax'],
        _readDouble(map['rippleColor'], 0.3),
      ),
      rippleColorCurrent: _readDouble(
        map['rippleColorCurrent'],
        _readDouble(map['rippleColor'], 0.3),
      ),
      rippleDropCount: map['rippleDropCount'] ?? 9,
      rippleSeed: map['rippleSeed'],
      rippleOvalness: _readDouble(map['rippleOvalness'], 0.0),
      rippleOvalnessMin: _readDouble(map['rippleOvalnessMin'], 0.0),
      rippleOvalnessMax: _readDouble(
        map['rippleOvalnessMax'],
        _readDouble(map['rippleOvalness'], 0.0),
      ),
      rippleOvalnessCurrent: _readDouble(
        map['rippleOvalnessCurrent'],
        _readDouble(map['rippleOvalness'], 0.0),
      ),
      rippleRotation: _readDouble(map['rippleRotation'], 0.0),
      rippleRotationMin: _readDouble(map['rippleRotationMin'], 0.0),
      rippleRotationMax: _readDouble(
        map['rippleRotationMax'],
        _readDouble(map['rippleRotation'], 0.0),
      ),
      rippleRotationCurrent: _readDouble(
        map['rippleRotationCurrent'],
        _readDouble(map['rippleRotation'], 0.0),
      ),
      rippleAnimated: map['rippleAnimated'] ?? false,
      rippleAnimOptions: map['rippleAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['rippleAnimOptions']),
            )
          : null,
    );

    // Load targeting flags from the map
    settings.loadTargetingFromMap(map);

    _maybeApplyRange(
      settings._rippleIntensityRange,
      map['rippleIntensityRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.rippleIntensity,
    );
    _maybeApplyRange(
      settings._rippleSizeRange,
      map['rippleSizeRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.rippleSize,
    );
    _maybeApplyRange(
      settings._rippleSpeedRange,
      map['rippleSpeedRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.rippleSpeed,
    );
    _maybeApplyRange(
      settings._rippleOpacityRange,
      map['rippleOpacityRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.rippleOpacity,
    );
    _maybeApplyRange(
      settings._rippleColorRange,
      map['rippleColorRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.rippleColor,
    );
    _maybeApplyRange(
      settings._rippleOvalnessRange,
      map['rippleOvalnessRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.rippleOvalness,
    );
    _maybeApplyRange(
      settings._rippleRotationRange,
      map['rippleRotationRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.rippleRotation,
    );

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
