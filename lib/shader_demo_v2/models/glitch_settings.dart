import 'animation_options.dart';
import 'parameter_range.dart';

class GlitchSettings {
  bool _effectEnabled;
  ParameterRange _opacityRange;
  ParameterRange _intensityRange;
  ParameterRange _frequencyRange;
  ParameterRange _blockSizeRange;
  ParameterRange _horizontalSliceIntensityRange;
  ParameterRange _verticalSliceIntensityRange;
  bool _effectAnimated;
  double _animationSpeed;
  AnimationOptions _animOptions;

  static bool enableLogging = false;

  GlitchSettings({
    bool effectEnabled = false,
    double opacity = 0.5,
    double? opacityMin,
    double? opacityMax,
    double? opacityCurrent,
    double intensity = 0.5,
    double? intensityMin,
    double? intensityMax,
    double? intensityCurrent,
    double frequency = 1.0,
    double? frequencyMin,
    double? frequencyMax,
    double? frequencyCurrent,
    double blockSize = 0.1,
    double? blockSizeMin,
    double? blockSizeMax,
    double? blockSizeCurrent,
    double horizontalSliceIntensity = 0.0,
    double? horizontalSliceIntensityMin,
    double? horizontalSliceIntensityMax,
    double? horizontalSliceIntensityCurrent,
    double verticalSliceIntensity = 0.0,
    double? verticalSliceIntensityMin,
    double? verticalSliceIntensityMax,
    double? verticalSliceIntensityCurrent,
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
       _intensityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: intensityCurrent ?? intensity,
         userMin: intensityMin ?? 0.0,
         userMax: intensityMax ?? intensity,
       ),
       _frequencyRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 2.0,
         initialValue: frequencyCurrent ?? frequency,
         userMin: frequencyMin ?? 0.0,
         userMax: frequencyMax ?? frequency,
       ),
       _blockSizeRange = ParameterRange(
         hardMin: 0.01,
         hardMax: 0.5,
         initialValue: blockSizeCurrent ?? blockSize,
         userMin: blockSizeMin ?? 0.01,
         userMax: blockSizeMax ?? blockSize,
       ),
       _horizontalSliceIntensityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue:
             horizontalSliceIntensityCurrent ?? horizontalSliceIntensity,
         userMin: horizontalSliceIntensityMin ?? 0.0,
         userMax: horizontalSliceIntensityMax ?? horizontalSliceIntensity,
       ),
       _verticalSliceIntensityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: verticalSliceIntensityCurrent ?? verticalSliceIntensity,
         userMin: verticalSliceIntensityMin ?? 0.0,
         userMax: verticalSliceIntensityMax ?? verticalSliceIntensity,
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

  double get intensity => _intensityRange.userMax;
  set intensity(double value) {
    _intensityRange.setCurrent(value);
  }

  ParameterRange get intensityRange => _intensityRange.copy();
  void setIntensityRange(ParameterRange range) {
    _intensityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get frequency => _frequencyRange.userMax;
  set frequency(double value) {
    _frequencyRange.setCurrent(value);
  }

  ParameterRange get frequencyRange => _frequencyRange.copy();
  void setFrequencyRange(ParameterRange range) {
    _frequencyRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get blockSize => _blockSizeRange.userMax;
  set blockSize(double value) {
    _blockSizeRange.setCurrent(value);
  }

  ParameterRange get blockSizeRange => _blockSizeRange.copy();
  void setBlockSizeRange(ParameterRange range) {
    _blockSizeRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get horizontalSliceIntensity => _horizontalSliceIntensityRange.userMax;
  set horizontalSliceIntensity(double value) {
    _horizontalSliceIntensityRange.setCurrent(value);
  }

  ParameterRange get horizontalSliceIntensityRange =>
      _horizontalSliceIntensityRange.copy();
  void setHorizontalSliceIntensityRange(ParameterRange range) {
    _horizontalSliceIntensityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get verticalSliceIntensity => _verticalSliceIntensityRange.userMax;
  set verticalSliceIntensity(double value) {
    _verticalSliceIntensityRange.setCurrent(value);
  }

  ParameterRange get verticalSliceIntensityRange =>
      _verticalSliceIntensityRange.copy();
  void setVerticalSliceIntensityRange(ParameterRange range) {
    _verticalSliceIntensityRange
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
  GlitchSettings copyWith({
    bool? effectEnabled,
    double? opacity,
    double? intensity,
    double? frequency,
    double? blockSize,
    double? horizontalSliceIntensity,
    double? verticalSliceIntensity,
    bool? effectAnimated,
    double? animationSpeed,
    AnimationOptions? animOptions,
  }) {
    return GlitchSettings(
      effectEnabled: effectEnabled ?? _effectEnabled,
      opacity: opacity ?? this.opacity,
      intensity: intensity ?? this.intensity,
      frequency: frequency ?? this.frequency,
      blockSize: blockSize ?? this.blockSize,
      horizontalSliceIntensity:
          horizontalSliceIntensity ?? this.horizontalSliceIntensity,
      verticalSliceIntensity:
          verticalSliceIntensity ?? this.verticalSliceIntensity,
      effectAnimated: effectAnimated ?? _effectAnimated,
      animationSpeed: animationSpeed ?? _animationSpeed,
      animOptions: animOptions ?? _animOptions,
    );
  }

  // Reset to default values
  void reset() {
    _effectEnabled = false;
    _opacityRange.resetToDefaults(defaultMin: 0.0, defaultMax: 0.5);
    _intensityRange.resetToDefaults(defaultMin: 0.0, defaultMax: 0.5);
    _frequencyRange.resetToDefaults(defaultMin: 0.0, defaultMax: 1.0);
    _blockSizeRange.resetToDefaults(defaultMin: 0.01, defaultMax: 0.1);
    _horizontalSliceIntensityRange.resetToDefaults(
      defaultMin: 0.0,
      defaultMax: 0.0,
    );
    _verticalSliceIntensityRange.resetToDefaults(
      defaultMin: 0.0,
      defaultMax: 0.0,
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
      'intensity': intensity,
      'intensityMin': _intensityRange.userMin,
      'intensityMax': _intensityRange.userMax,
      'intensityCurrent': _intensityRange.current,
      'intensityRange': _intensityRange.toMap(),
      'frequency': frequency,
      'frequencyMin': _frequencyRange.userMin,
      'frequencyMax': _frequencyRange.userMax,
      'frequencyCurrent': _frequencyRange.current,
      'frequencyRange': _frequencyRange.toMap(),
      'blockSize': blockSize,
      'blockSizeMin': _blockSizeRange.userMin,
      'blockSizeMax': _blockSizeRange.userMax,
      'blockSizeCurrent': _blockSizeRange.current,
      'blockSizeRange': _blockSizeRange.toMap(),
      'horizontalSliceIntensity': horizontalSliceIntensity,
      'horizontalSliceIntensityMin': _horizontalSliceIntensityRange.userMin,
      'horizontalSliceIntensityMax': _horizontalSliceIntensityRange.userMax,
      'horizontalSliceIntensityCurrent': _horizontalSliceIntensityRange.current,
      'horizontalSliceIntensityRange': _horizontalSliceIntensityRange.toMap(),
      'verticalSliceIntensity': verticalSliceIntensity,
      'verticalSliceIntensityMin': _verticalSliceIntensityRange.userMin,
      'verticalSliceIntensityMax': _verticalSliceIntensityRange.userMax,
      'verticalSliceIntensityCurrent': _verticalSliceIntensityRange.current,
      'verticalSliceIntensityRange': _verticalSliceIntensityRange.toMap(),
      'effectAnimated': _effectAnimated,
      'animationSpeed': _animationSpeed,
      'animOptions': _animOptions.toMap(),
    };
  }

  // Create from map for deserialization
  static GlitchSettings fromMap(Map<String, dynamic> map) {
    double _readDouble(dynamic value, double fallback) {
      if (value is num) return value.toDouble();
      return fallback;
    }

    final settings = GlitchSettings(
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
      intensity: _readDouble(map['intensity'], 0.3),
      intensityMin: _readDouble(map['intensityMin'], 0.0),
      intensityMax: _readDouble(
        map['intensityMax'],
        _readDouble(map['intensity'], 0.3),
      ),
      intensityCurrent: _readDouble(
        map['intensityCurrent'],
        _readDouble(map['intensity'], 0.3),
      ),
      frequency: _readDouble(map['frequency'], 1.0),
      frequencyMin: _readDouble(map['frequencyMin'], 0.0),
      frequencyMax: _readDouble(
        map['frequencyMax'],
        _readDouble(map['frequency'], 1.0),
      ),
      frequencyCurrent: _readDouble(
        map['frequencyCurrent'],
        _readDouble(map['frequency'], 1.0),
      ),
      blockSize: _readDouble(map['blockSize'], 0.1),
      blockSizeMin: _readDouble(map['blockSizeMin'], 0.0),
      blockSizeMax: _readDouble(
        map['blockSizeMax'],
        _readDouble(map['blockSize'], 0.1),
      ),
      blockSizeCurrent: _readDouble(
        map['blockSizeCurrent'],
        _readDouble(map['blockSize'], 0.1),
      ),
      horizontalSliceIntensity: _readDouble(
        map['horizontalSliceIntensity'],
        0.0,
      ),
      horizontalSliceIntensityMin: _readDouble(
        map['horizontalSliceIntensityMin'],
        0.0,
      ),
      horizontalSliceIntensityMax: _readDouble(
        map['horizontalSliceIntensityMax'],
        _readDouble(map['horizontalSliceIntensity'], 0.0),
      ),
      horizontalSliceIntensityCurrent: _readDouble(
        map['horizontalSliceIntensityCurrent'],
        _readDouble(map['horizontalSliceIntensity'], 0.0),
      ),
      verticalSliceIntensity: _readDouble(map['verticalSliceIntensity'], 0.0),
      verticalSliceIntensityMin: _readDouble(
        map['verticalSliceIntensityMin'],
        0.0,
      ),
      verticalSliceIntensityMax: _readDouble(
        map['verticalSliceIntensityMax'],
        _readDouble(map['verticalSliceIntensity'], 0.0),
      ),
      verticalSliceIntensityCurrent: _readDouble(
        map['verticalSliceIntensityCurrent'],
        _readDouble(map['verticalSliceIntensity'], 0.0),
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
      settings._intensityRange,
      map['intensityRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.intensity,
    );
    _maybeApplyRange(
      settings._frequencyRange,
      map['frequencyRange'],
      hardMin: 0.0,
      hardMax: 2.0,
      fallback: settings.frequency,
    );
    _maybeApplyRange(
      settings._blockSizeRange,
      map['blockSizeRange'],
      hardMin: 0.01,
      hardMax: 0.5,
      fallback: settings.blockSize,
    );
    _maybeApplyRange(
      settings._horizontalSliceIntensityRange,
      map['horizontalSliceIntensityRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.horizontalSliceIntensity,
    );
    _maybeApplyRange(
      settings._verticalSliceIntensityRange,
      map['verticalSliceIntensityRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.verticalSliceIntensity,
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
    return 'GlitchSettings(enabled: $_effectEnabled, opacity: $opacity, intensity: $intensity, frequency: $frequency, blockSize: $blockSize, horizontalSliceIntensity: $horizontalSliceIntensity, verticalSliceIntensity: $verticalSliceIntensity, animated: $_effectAnimated)';
  }
}
