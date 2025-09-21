import 'animation_options.dart';
import 'parameter_range.dart';
import 'targetable_effect_settings.dart';

class RainSettings with TargetableEffectSettings {
  // Enable flag for rain effect
  bool _rainEnabled;

  // Rain settings
  ParameterRange _rainIntensityRange; // Controls number of drops (0-1)
  ParameterRange
  _dropSizeRange; // Controls size of droplets (0-1, scaled internally)
  ParameterRange _fallSpeedRange; // Controls speed of falling drops (0-1)
  ParameterRange
  _refractionRange; // Controls visual distortion from drops (0-1)
  ParameterRange
  _trailIntensityRange; // Controls length/opacity of trails behind drops (0-1)

  // Animation flag
  bool _rainAnimated;

  // Animation options
  AnimationOptions _rainAnimOptions;

  // Flag to control logging
  static bool enableLogging = false;

  // Property getters and setters
  bool get rainEnabled => _rainEnabled;
  set rainEnabled(bool value) {
    _rainEnabled = value;
  }

  double get rainIntensity => _rainIntensityRange.userMax;
  set rainIntensity(double value) {
    _rainIntensityRange.setCurrent(value);
  }

  ParameterRange get rainIntensityRange => _rainIntensityRange.copy();
  void setRainIntensityRange(ParameterRange range) {
    _rainIntensityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get dropSize => _dropSizeRange.userMax;
  set dropSize(double value) {
    _dropSizeRange.setCurrent(value);
  }

  ParameterRange get dropSizeRange => _dropSizeRange.copy();
  void setDropSizeRange(ParameterRange range) {
    _dropSizeRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get fallSpeed => _fallSpeedRange.userMax;
  set fallSpeed(double value) {
    _fallSpeedRange.setCurrent(value);
  }

  ParameterRange get fallSpeedRange => _fallSpeedRange.copy();
  void setFallSpeedRange(ParameterRange range) {
    _fallSpeedRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get refraction => _refractionRange.userMax;
  set refraction(double value) {
    _refractionRange.setCurrent(value);
  }

  ParameterRange get refractionRange => _refractionRange.copy();
  void setRefractionRange(ParameterRange range) {
    _refractionRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get trailIntensity => _trailIntensityRange.userMax;
  set trailIntensity(double value) {
    _trailIntensityRange.setCurrent(value);
  }

  ParameterRange get trailIntensityRange => _trailIntensityRange.copy();
  void setTrailIntensityRange(ParameterRange range) {
    _trailIntensityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  // Rain animation toggle with logging
  bool get rainAnimated => _rainAnimated;
  set rainAnimated(bool value) {
    _rainAnimated = value;
  }

  AnimationOptions get rainAnimOptions => _rainAnimOptions;
  set rainAnimOptions(AnimationOptions value) {
    _rainAnimOptions = value;
  }

  // Constructor with default values
  RainSettings({
    bool rainEnabled = false,
    double rainIntensity = 0.5,
    double? rainIntensityMin,
    double? rainIntensityMax,
    double? rainIntensityCurrent,
    double dropSize = 0.5,
    double? dropSizeMin,
    double? dropSizeMax,
    double? dropSizeCurrent,
    double fallSpeed = 0.5,
    double? fallSpeedMin,
    double? fallSpeedMax,
    double? fallSpeedCurrent,
    double refraction = 0.5,
    double? refractionMin,
    double? refractionMax,
    double? refractionCurrent,
    double trailIntensity = 0.3,
    double? trailIntensityMin,
    double? trailIntensityMax,
    double? trailIntensityCurrent,
    bool rainAnimated = false,
    AnimationOptions? rainAnimOptions,
    bool applyToImage = true, // New parameter with default true
    bool applyToText = true, // New parameter with default true
  }) : _rainEnabled = rainEnabled,
       _rainIntensityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: rainIntensityCurrent ?? rainIntensity,
         userMin: rainIntensityMin ?? 0.0,
         userMax: rainIntensityMax ?? rainIntensity,
       ),
       _dropSizeRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: dropSizeCurrent ?? dropSize,
         userMin: dropSizeMin ?? 0.0,
         userMax: dropSizeMax ?? dropSize,
       ),
       _fallSpeedRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: fallSpeedCurrent ?? fallSpeed,
         userMin: fallSpeedMin ?? 0.0,
         userMax: fallSpeedMax ?? fallSpeed,
       ),
       _refractionRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: refractionCurrent ?? refraction,
         userMin: refractionMin ?? 0.0,
         userMax: refractionMax ?? refraction,
       ),
       _trailIntensityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: trailIntensityCurrent ?? trailIntensity,
         userMin: trailIntensityMin ?? 0.0,
         userMax: trailIntensityMax ?? trailIntensity,
       ),
       _rainAnimated = rainAnimated,
       _rainAnimOptions = rainAnimOptions ?? AnimationOptions() {
    // Set the targeting flags
    this.applyToImage = applyToImage;
    this.applyToText = applyToText;
  }

  // Serialization helpers
  Map<String, dynamic> toMap() {
    final map = {
      'rainEnabled': _rainEnabled,
      'rainIntensity': rainIntensity,
      'rainIntensityMin': _rainIntensityRange.userMin,
      'rainIntensityMax': _rainIntensityRange.userMax,
      'rainIntensityCurrent': _rainIntensityRange.current,
      'rainIntensityRange': _rainIntensityRange.toMap(),
      'dropSize': dropSize,
      'dropSizeMin': _dropSizeRange.userMin,
      'dropSizeMax': _dropSizeRange.userMax,
      'dropSizeCurrent': _dropSizeRange.current,
      'dropSizeRange': _dropSizeRange.toMap(),
      'fallSpeed': fallSpeed,
      'fallSpeedMin': _fallSpeedRange.userMin,
      'fallSpeedMax': _fallSpeedRange.userMax,
      'fallSpeedCurrent': _fallSpeedRange.current,
      'fallSpeedRange': _fallSpeedRange.toMap(),
      'refraction': refraction,
      'refractionMin': _refractionRange.userMin,
      'refractionMax': _refractionRange.userMax,
      'refractionCurrent': _refractionRange.current,
      'refractionRange': _refractionRange.toMap(),
      'trailIntensity': trailIntensity,
      'trailIntensityMin': _trailIntensityRange.userMin,
      'trailIntensityMax': _trailIntensityRange.userMax,
      'trailIntensityCurrent': _trailIntensityRange.current,
      'trailIntensityRange': _trailIntensityRange.toMap(),
      'rainAnimated': _rainAnimated,
      'rainAnimOptions': _rainAnimOptions.toMap(),
    };

    // Add targeting flags from the mixin
    addTargetingToMap(map);

    return map;
  }

  factory RainSettings.fromMap(Map<String, dynamic> map) {
    double _readDouble(dynamic value, double fallback) {
      if (value is num) return value.toDouble();
      return fallback;
    }

    final settings = RainSettings(
      rainEnabled: map['rainEnabled'] ?? false,
      rainIntensity: _readDouble(map['rainIntensity'], 0.5),
      rainIntensityMin: _readDouble(map['rainIntensityMin'], 0.0),
      rainIntensityMax: _readDouble(
        map['rainIntensityMax'],
        _readDouble(map['rainIntensity'], 0.5),
      ),
      rainIntensityCurrent: _readDouble(
        map['rainIntensityCurrent'],
        _readDouble(map['rainIntensity'], 0.5),
      ),
      dropSize: _readDouble(map['dropSize'], 0.5),
      dropSizeMin: _readDouble(map['dropSizeMin'], 0.0),
      dropSizeMax: _readDouble(
        map['dropSizeMax'],
        _readDouble(map['dropSize'], 0.5),
      ),
      dropSizeCurrent: _readDouble(
        map['dropSizeCurrent'],
        _readDouble(map['dropSize'], 0.5),
      ),
      fallSpeed: _readDouble(map['fallSpeed'], 0.5),
      fallSpeedMin: _readDouble(map['fallSpeedMin'], 0.0),
      fallSpeedMax: _readDouble(
        map['fallSpeedMax'],
        _readDouble(map['fallSpeed'], 0.5),
      ),
      fallSpeedCurrent: _readDouble(
        map['fallSpeedCurrent'],
        _readDouble(map['fallSpeed'], 0.5),
      ),
      refraction: _readDouble(map['refraction'], 0.5),
      refractionMin: _readDouble(map['refractionMin'], 0.0),
      refractionMax: _readDouble(
        map['refractionMax'],
        _readDouble(map['refraction'], 0.5),
      ),
      refractionCurrent: _readDouble(
        map['refractionCurrent'],
        _readDouble(map['refraction'], 0.5),
      ),
      trailIntensity: _readDouble(map['trailIntensity'], 0.3),
      trailIntensityMin: _readDouble(map['trailIntensityMin'], 0.0),
      trailIntensityMax: _readDouble(
        map['trailIntensityMax'],
        _readDouble(map['trailIntensity'], 0.3),
      ),
      trailIntensityCurrent: _readDouble(
        map['trailIntensityCurrent'],
        _readDouble(map['trailIntensity'], 0.3),
      ),
      rainAnimated: map['rainAnimated'] ?? false,
      rainAnimOptions: map['rainAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['rainAnimOptions']),
            )
          : null,
    );

    // Apply range data if available
    _maybeApplyRange(
      settings._rainIntensityRange,
      map['rainIntensityRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.rainIntensity,
    );
    _maybeApplyRange(
      settings._dropSizeRange,
      map['dropSizeRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.dropSize,
    );
    _maybeApplyRange(
      settings._fallSpeedRange,
      map['fallSpeedRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.fallSpeed,
    );
    _maybeApplyRange(
      settings._refractionRange,
      map['refractionRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.refraction,
    );
    _maybeApplyRange(
      settings._trailIntensityRange,
      map['trailIntensityRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.trailIntensity,
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
