import 'animation_options.dart';
import 'parameter_range.dart';

class VHSSettings {
  bool _effectEnabled;
  ParameterRange _opacityRange;
  ParameterRange _noiseIntensityRange;
  ParameterRange _fieldLinesRange;
  ParameterRange _horizontalWaveStrengthRange;
  ParameterRange _horizontalWaveScreenSizeRange;
  ParameterRange _horizontalWaveVerticalSizeRange;
  ParameterRange _dottedNoiseStrengthRange;
  ParameterRange _horizontalDistortionStrengthRange;
  bool _effectAnimated;
  double _animationSpeed;
  AnimationOptions _animOptions;

  static bool enableLogging = false;

  VHSSettings({
    bool effectEnabled = false,
    double opacity = 0.5,
    double? opacityMin,
    double? opacityMax,
    double? opacityCurrent,
    double noiseIntensity = 0.7,
    double? noiseIntensityMin,
    double? noiseIntensityMax,
    double? noiseIntensityCurrent,
    double fieldLines = 240.0,
    double? fieldLinesMin,
    double? fieldLinesMax,
    double? fieldLinesCurrent,
    double horizontalWaveStrength = 0.15,
    double? horizontalWaveStrengthMin,
    double? horizontalWaveStrengthMax,
    double? horizontalWaveStrengthCurrent,
    double horizontalWaveScreenSize = 50.0,
    double? horizontalWaveScreenSizeMin,
    double? horizontalWaveScreenSizeMax,
    double? horizontalWaveScreenSizeCurrent,
    double horizontalWaveVerticalSize = 100.0,
    double? horizontalWaveVerticalSizeMin,
    double? horizontalWaveVerticalSizeMax,
    double? horizontalWaveVerticalSizeCurrent,
    double dottedNoiseStrength = 0.2,
    double? dottedNoiseStrengthMin,
    double? dottedNoiseStrengthMax,
    double? dottedNoiseStrengthCurrent,
    double horizontalDistortionStrength = 0.0087,
    double? horizontalDistortionStrengthMin,
    double? horizontalDistortionStrengthMax,
    double? horizontalDistortionStrengthCurrent,
    bool effectAnimated = false,
    double animationSpeed = 1.0,
    AnimationOptions? animOptions,
  }) : _effectEnabled = effectEnabled,
       _opacityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: opacityCurrent ?? opacity,
         userMin: opacityMin ?? 0.0,
         userMax: opacityMax ?? opacity,
       ),
       _noiseIntensityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: noiseIntensityCurrent ?? noiseIntensity,
         userMin: noiseIntensityMin ?? 0.0,
         userMax: noiseIntensityMax ?? noiseIntensity,
       ),
       _fieldLinesRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 400.0,
         initialValue: fieldLinesCurrent ?? fieldLines,
         userMin: fieldLinesMin ?? 0.0,
         userMax: fieldLinesMax ?? fieldLines,
       ),
       _horizontalWaveStrengthRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 0.5,
         initialValue: horizontalWaveStrengthCurrent ?? horizontalWaveStrength,
         userMin: horizontalWaveStrengthMin ?? 0.0,
         userMax: horizontalWaveStrengthMax ?? horizontalWaveStrength,
       ),
       _horizontalWaveScreenSizeRange = ParameterRange(
         hardMin: 10.0,
         hardMax: 200.0,
         initialValue:
             horizontalWaveScreenSizeCurrent ?? horizontalWaveScreenSize,
         userMin: horizontalWaveScreenSizeMin ?? 10.0,
         userMax: horizontalWaveScreenSizeMax ?? horizontalWaveScreenSize,
       ),
       _horizontalWaveVerticalSizeRange = ParameterRange(
         hardMin: 10.0,
         hardMax: 300.0,
         initialValue:
             horizontalWaveVerticalSizeCurrent ?? horizontalWaveVerticalSize,
         userMin: horizontalWaveVerticalSizeMin ?? 10.0,
         userMax: horizontalWaveVerticalSizeMax ?? horizontalWaveVerticalSize,
       ),
       _dottedNoiseStrengthRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: dottedNoiseStrengthCurrent ?? dottedNoiseStrength,
         userMin: dottedNoiseStrengthMin ?? 0.0,
         userMax: dottedNoiseStrengthMax ?? dottedNoiseStrength,
       ),
       _horizontalDistortionStrengthRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 0.02,
         initialValue:
             horizontalDistortionStrengthCurrent ??
             horizontalDistortionStrength,
         userMin: horizontalDistortionStrengthMin ?? 0.0,
         userMax:
             horizontalDistortionStrengthMax ?? horizontalDistortionStrength,
       ),
       _effectAnimated = effectAnimated,
       _animationSpeed = animationSpeed,
       _animOptions = animOptions ?? AnimationOptions();

  // Getters
  bool get effectEnabled => _effectEnabled;
  double get opacity => _opacityRange.userMax;
  set opacity(double value) {
    _opacityRange.setCurrent(value);
  }

  ParameterRange get opacityRange => _opacityRange.copy();
  void setOpacityRange(ParameterRange range) {
    _opacityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get noiseIntensity => _noiseIntensityRange.userMax;
  set noiseIntensity(double value) {
    _noiseIntensityRange.setCurrent(value);
  }

  ParameterRange get noiseIntensityRange => _noiseIntensityRange.copy();
  void setNoiseIntensityRange(ParameterRange range) {
    _noiseIntensityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get fieldLines => _fieldLinesRange.userMax;
  set fieldLines(double value) {
    _fieldLinesRange.setCurrent(value);
  }

  ParameterRange get fieldLinesRange => _fieldLinesRange.copy();
  void setFieldLinesRange(ParameterRange range) {
    _fieldLinesRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get horizontalWaveStrength => _horizontalWaveStrengthRange.userMax;
  set horizontalWaveStrength(double value) {
    _horizontalWaveStrengthRange.setCurrent(value);
  }

  ParameterRange get horizontalWaveStrengthRange =>
      _horizontalWaveStrengthRange.copy();
  void setHorizontalWaveStrengthRange(ParameterRange range) {
    _horizontalWaveStrengthRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get horizontalWaveScreenSize => _horizontalWaveScreenSizeRange.userMax;
  set horizontalWaveScreenSize(double value) {
    _horizontalWaveScreenSizeRange.setCurrent(value);
  }

  ParameterRange get horizontalWaveScreenSizeRange =>
      _horizontalWaveScreenSizeRange.copy();
  void setHorizontalWaveScreenSizeRange(ParameterRange range) {
    _horizontalWaveScreenSizeRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get horizontalWaveVerticalSize =>
      _horizontalWaveVerticalSizeRange.userMax;
  set horizontalWaveVerticalSize(double value) {
    _horizontalWaveVerticalSizeRange.setCurrent(value);
  }

  ParameterRange get horizontalWaveVerticalSizeRange =>
      _horizontalWaveVerticalSizeRange.copy();
  void setHorizontalWaveVerticalSizeRange(ParameterRange range) {
    _horizontalWaveVerticalSizeRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get dottedNoiseStrength => _dottedNoiseStrengthRange.userMax;
  set dottedNoiseStrength(double value) {
    _dottedNoiseStrengthRange.setCurrent(value);
  }

  ParameterRange get dottedNoiseStrengthRange =>
      _dottedNoiseStrengthRange.copy();
  void setDottedNoiseStrengthRange(ParameterRange range) {
    _dottedNoiseStrengthRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get horizontalDistortionStrength =>
      _horizontalDistortionStrengthRange.userMax;
  set horizontalDistortionStrength(double value) {
    _horizontalDistortionStrengthRange.setCurrent(value);
  }

  ParameterRange get horizontalDistortionStrengthRange =>
      _horizontalDistortionStrengthRange.copy();
  void setHorizontalDistortionStrengthRange(ParameterRange range) {
    _horizontalDistortionStrengthRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  bool get effectAnimated => _effectAnimated;
  double get animationSpeed => _animationSpeed;
  AnimationOptions get effectAnimOptions => _animOptions;

  // Setters
  set effectEnabled(bool value) => _effectEnabled = value;
  set effectAnimated(bool value) => _effectAnimated = value;
  set animationSpeed(double value) => _animationSpeed = value;
  set effectAnimOptions(AnimationOptions value) => _animOptions = value;

  // Convenience getter to check if effect should be applied
  bool get shouldApplyEffect => _effectEnabled && opacity >= 0.01;

  // Create a copy with updated values
  VHSSettings copyWith({
    bool? effectEnabled,
    double? opacity,
    double? noiseIntensity,
    double? fieldLines,
    double? horizontalWaveStrength,
    double? horizontalWaveScreenSize,
    double? horizontalWaveVerticalSize,
    double? dottedNoiseStrength,
    double? horizontalDistortionStrength,
    bool? effectAnimated,
    double? animationSpeed,
    AnimationOptions? animOptions,
  }) {
    return VHSSettings(
      effectEnabled: effectEnabled ?? _effectEnabled,
      opacity: opacity ?? this.opacity,
      noiseIntensity: noiseIntensity ?? this.noiseIntensity,
      fieldLines: fieldLines ?? this.fieldLines,
      horizontalWaveStrength:
          horizontalWaveStrength ?? this.horizontalWaveStrength,
      horizontalWaveScreenSize:
          horizontalWaveScreenSize ?? this.horizontalWaveScreenSize,
      horizontalWaveVerticalSize:
          horizontalWaveVerticalSize ?? this.horizontalWaveVerticalSize,
      dottedNoiseStrength: dottedNoiseStrength ?? this.dottedNoiseStrength,
      horizontalDistortionStrength:
          horizontalDistortionStrength ?? this.horizontalDistortionStrength,
      effectAnimated: effectAnimated ?? _effectAnimated,
      animationSpeed: animationSpeed ?? _animationSpeed,
      animOptions: animOptions ?? _animOptions,
    );
  }

  // Reset to default values
  void reset() {
    _effectEnabled = false;
    _opacityRange.resetToDefaults(defaultMin: 0.0, defaultMax: 0.5);
    _noiseIntensityRange.resetToDefaults(defaultMin: 0.0, defaultMax: 0.7);
    _fieldLinesRange.resetToDefaults(defaultMin: 0.0, defaultMax: 240.0);
    _horizontalWaveStrengthRange.resetToDefaults(
      defaultMin: 0.0,
      defaultMax: 0.15,
    );
    _horizontalWaveScreenSizeRange.resetToDefaults(
      defaultMin: 10.0,
      defaultMax: 50.0,
    );
    _horizontalWaveVerticalSizeRange.resetToDefaults(
      defaultMin: 10.0,
      defaultMax: 100.0,
    );
    _dottedNoiseStrengthRange.resetToDefaults(defaultMin: 0.0, defaultMax: 0.2);
    _horizontalDistortionStrengthRange.resetToDefaults(
      defaultMin: 0.0,
      defaultMax: 0.0087,
    );
    _effectAnimated = false;
    _animationSpeed = 1.0;
    _animOptions = AnimationOptions();
  }

  // Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'effectEnabled': _effectEnabled,
      'opacity': opacity,
      'opacityMin': _opacityRange.userMin,
      'opacityMax': _opacityRange.userMax,
      'opacityCurrent': _opacityRange.current,
      'opacityRange': _opacityRange.toMap(),
      'noiseIntensity': noiseIntensity,
      'noiseIntensityMin': _noiseIntensityRange.userMin,
      'noiseIntensityMax': _noiseIntensityRange.userMax,
      'noiseIntensityCurrent': _noiseIntensityRange.current,
      'noiseIntensityRange': _noiseIntensityRange.toMap(),
      'fieldLines': fieldLines,
      'fieldLinesMin': _fieldLinesRange.userMin,
      'fieldLinesMax': _fieldLinesRange.userMax,
      'fieldLinesCurrent': _fieldLinesRange.current,
      'fieldLinesRange': _fieldLinesRange.toMap(),
      'horizontalWaveStrength': horizontalWaveStrength,
      'horizontalWaveStrengthMin': _horizontalWaveStrengthRange.userMin,
      'horizontalWaveStrengthMax': _horizontalWaveStrengthRange.userMax,
      'horizontalWaveStrengthCurrent': _horizontalWaveStrengthRange.current,
      'horizontalWaveStrengthRange': _horizontalWaveStrengthRange.toMap(),
      'horizontalWaveScreenSize': horizontalWaveScreenSize,
      'horizontalWaveScreenSizeMin': _horizontalWaveScreenSizeRange.userMin,
      'horizontalWaveScreenSizeMax': _horizontalWaveScreenSizeRange.userMax,
      'horizontalWaveScreenSizeCurrent': _horizontalWaveScreenSizeRange.current,
      'horizontalWaveScreenSizeRange': _horizontalWaveScreenSizeRange.toMap(),
      'horizontalWaveVerticalSize': horizontalWaveVerticalSize,
      'horizontalWaveVerticalSizeMin': _horizontalWaveVerticalSizeRange.userMin,
      'horizontalWaveVerticalSizeMax': _horizontalWaveVerticalSizeRange.userMax,
      'horizontalWaveVerticalSizeCurrent':
          _horizontalWaveVerticalSizeRange.current,
      'horizontalWaveVerticalSizeRange': _horizontalWaveVerticalSizeRange
          .toMap(),
      'dottedNoiseStrength': dottedNoiseStrength,
      'dottedNoiseStrengthMin': _dottedNoiseStrengthRange.userMin,
      'dottedNoiseStrengthMax': _dottedNoiseStrengthRange.userMax,
      'dottedNoiseStrengthCurrent': _dottedNoiseStrengthRange.current,
      'dottedNoiseStrengthRange': _dottedNoiseStrengthRange.toMap(),
      'horizontalDistortionStrength': horizontalDistortionStrength,
      'horizontalDistortionStrengthMin':
          _horizontalDistortionStrengthRange.userMin,
      'horizontalDistortionStrengthMax':
          _horizontalDistortionStrengthRange.userMax,
      'horizontalDistortionStrengthCurrent':
          _horizontalDistortionStrengthRange.current,
      'horizontalDistortionStrengthRange': _horizontalDistortionStrengthRange
          .toMap(),
      'effectAnimated': _effectAnimated,
      'animationSpeed': _animationSpeed,
      'animOptions': _animOptions.toMap(),
    };
  }

  // Create from map for deserialization
  static VHSSettings fromMap(Map<String, dynamic> map) {
    double _readDouble(dynamic value, double fallback) {
      if (value is num) return value.toDouble();
      return fallback;
    }

    final settings = VHSSettings(
      effectEnabled: map['effectEnabled'] ?? false,
      opacity: _readDouble(map['opacity'], 0.5),
      opacityMin: _readDouble(map['opacityMin'], 0.0),
      opacityMax: _readDouble(
        map['opacityMax'],
        _readDouble(map['opacity'], 0.5),
      ),
      opacityCurrent: _readDouble(
        map['opacityCurrent'],
        _readDouble(map['opacity'], 0.5),
      ),
      noiseIntensity: _readDouble(map['noiseIntensity'], 0.7),
      noiseIntensityMin: _readDouble(map['noiseIntensityMin'], 0.0),
      noiseIntensityMax: _readDouble(
        map['noiseIntensityMax'],
        _readDouble(map['noiseIntensity'], 0.7),
      ),
      noiseIntensityCurrent: _readDouble(
        map['noiseIntensityCurrent'],
        _readDouble(map['noiseIntensity'], 0.7),
      ),
      fieldLines: _readDouble(map['fieldLines'], 240.0),
      fieldLinesMin: _readDouble(map['fieldLinesMin'], 0.0),
      fieldLinesMax: _readDouble(
        map['fieldLinesMax'],
        _readDouble(map['fieldLines'], 240.0),
      ),
      fieldLinesCurrent: _readDouble(
        map['fieldLinesCurrent'],
        _readDouble(map['fieldLines'], 240.0),
      ),
      horizontalWaveStrength: _readDouble(map['horizontalWaveStrength'], 0.15),
      horizontalWaveStrengthMin: _readDouble(
        map['horizontalWaveStrengthMin'],
        0.0,
      ),
      horizontalWaveStrengthMax: _readDouble(
        map['horizontalWaveStrengthMax'],
        _readDouble(map['horizontalWaveStrength'], 0.15),
      ),
      horizontalWaveStrengthCurrent: _readDouble(
        map['horizontalWaveStrengthCurrent'],
        _readDouble(map['horizontalWaveStrength'], 0.15),
      ),
      horizontalWaveScreenSize: _readDouble(
        map['horizontalWaveScreenSize'],
        50.0,
      ),
      horizontalWaveScreenSizeMin: _readDouble(
        map['horizontalWaveScreenSizeMin'],
        10.0,
      ),
      horizontalWaveScreenSizeMax: _readDouble(
        map['horizontalWaveScreenSizeMax'],
        _readDouble(map['horizontalWaveScreenSize'], 50.0),
      ),
      horizontalWaveScreenSizeCurrent: _readDouble(
        map['horizontalWaveScreenSizeCurrent'],
        _readDouble(map['horizontalWaveScreenSize'], 50.0),
      ),
      horizontalWaveVerticalSize: _readDouble(
        map['horizontalWaveVerticalSize'],
        100.0,
      ),
      horizontalWaveVerticalSizeMin: _readDouble(
        map['horizontalWaveVerticalSizeMin'],
        10.0,
      ),
      horizontalWaveVerticalSizeMax: _readDouble(
        map['horizontalWaveVerticalSizeMax'],
        _readDouble(map['horizontalWaveVerticalSize'], 100.0),
      ),
      horizontalWaveVerticalSizeCurrent: _readDouble(
        map['horizontalWaveVerticalSizeCurrent'],
        _readDouble(map['horizontalWaveVerticalSize'], 100.0),
      ),
      dottedNoiseStrength: _readDouble(map['dottedNoiseStrength'], 0.2),
      dottedNoiseStrengthMin: _readDouble(map['dottedNoiseStrengthMin'], 0.0),
      dottedNoiseStrengthMax: _readDouble(
        map['dottedNoiseStrengthMax'],
        _readDouble(map['dottedNoiseStrength'], 0.2),
      ),
      dottedNoiseStrengthCurrent: _readDouble(
        map['dottedNoiseStrengthCurrent'],
        _readDouble(map['dottedNoiseStrength'], 0.2),
      ),
      horizontalDistortionStrength: _readDouble(
        map['horizontalDistortionStrength'],
        0.0087,
      ),
      horizontalDistortionStrengthMin: _readDouble(
        map['horizontalDistortionStrengthMin'],
        0.0,
      ),
      horizontalDistortionStrengthMax: _readDouble(
        map['horizontalDistortionStrengthMax'],
        _readDouble(map['horizontalDistortionStrength'], 0.0087),
      ),
      horizontalDistortionStrengthCurrent: _readDouble(
        map['horizontalDistortionStrengthCurrent'],
        _readDouble(map['horizontalDistortionStrength'], 0.0087),
      ),
      effectAnimated: map['effectAnimated'] ?? false,
      animationSpeed: _readDouble(map['animationSpeed'], 1.0),
      animOptions: map['animOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['animOptions']),
            )
          : null,
    );

    // Apply range data if available
    _maybeApplyRange(
      settings._opacityRange,
      map['opacityRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.opacity,
    );
    _maybeApplyRange(
      settings._noiseIntensityRange,
      map['noiseIntensityRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.noiseIntensity,
    );
    _maybeApplyRange(
      settings._fieldLinesRange,
      map['fieldLinesRange'],
      hardMin: 0.0,
      hardMax: 400.0,
      fallback: settings.fieldLines,
    );
    _maybeApplyRange(
      settings._horizontalWaveStrengthRange,
      map['horizontalWaveStrengthRange'],
      hardMin: 0.0,
      hardMax: 0.5,
      fallback: settings.horizontalWaveStrength,
    );
    _maybeApplyRange(
      settings._horizontalWaveScreenSizeRange,
      map['horizontalWaveScreenSizeRange'],
      hardMin: 10.0,
      hardMax: 200.0,
      fallback: settings.horizontalWaveScreenSize,
    );
    _maybeApplyRange(
      settings._horizontalWaveVerticalSizeRange,
      map['horizontalWaveVerticalSizeRange'],
      hardMin: 10.0,
      hardMax: 300.0,
      fallback: settings.horizontalWaveVerticalSize,
    );
    _maybeApplyRange(
      settings._dottedNoiseStrengthRange,
      map['dottedNoiseStrengthRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.dottedNoiseStrength,
    );
    _maybeApplyRange(
      settings._horizontalDistortionStrengthRange,
      map['horizontalDistortionStrengthRange'],
      hardMin: 0.0,
      hardMax: 0.02,
      fallback: settings.horizontalDistortionStrength,
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

  @override
  String toString() {
    return 'VHSSettings(enabled: $_effectEnabled, opacity: $opacity, noiseIntensity: $noiseIntensity, fieldLines: $fieldLines, horizontalWaveStrength: $horizontalWaveStrength, horizontalWaveScreenSize: $horizontalWaveScreenSize, horizontalWaveVerticalSize: $horizontalWaveVerticalSize, dottedNoiseStrength: $dottedNoiseStrength, horizontalDistortionStrength: $horizontalDistortionStrength, animated: $_effectAnimated)';
  }
}
