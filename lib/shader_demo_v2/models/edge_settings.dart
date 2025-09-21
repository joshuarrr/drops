import 'animation_options.dart';
import 'parameter_range.dart';

class EdgeSettings {
  // Core effect controls
  bool _edgeEnabled;
  ParameterRange _opacityRange;

  // Edge detection parameters
  ParameterRange _edgeIntensityRange;
  ParameterRange _edgeThicknessRange;
  ParameterRange
  _edgeColorRange; // 0.0 = black, 0.5 = original color, 1.0 = white

  // Animation controls
  bool _edgeAnimated;
  double _animationSpeed;
  AnimationOptions _animOptions;

  // Constructor with default values
  EdgeSettings({
    bool edgeEnabled = false,
    double opacity = 0.7,
    double? opacityMin,
    double? opacityMax,
    double? opacityCurrent,
    double edgeIntensity = 1.5,
    double? edgeIntensityMin,
    double? edgeIntensityMax,
    double? edgeIntensityCurrent,
    double edgeThickness = 1.0,
    double? edgeThicknessMin,
    double? edgeThicknessMax,
    double? edgeThicknessCurrent,
    double edgeColor = 0.0,
    double? edgeColorMin,
    double? edgeColorMax,
    double? edgeColorCurrent,
    bool edgeAnimated = false,
    double animationSpeed = 1.0,
    AnimationOptions? animOptions,
  }) : _edgeEnabled = edgeEnabled,
       _opacityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: opacityCurrent ?? opacity,
         userMin: opacityMin ?? 0.0,
         userMax: opacityMax ?? opacity,
       ),
       _edgeIntensityRange = ParameterRange(
         hardMin: 0.1,
         hardMax: 5.0,
         initialValue: edgeIntensityCurrent ?? edgeIntensity,
         userMin: edgeIntensityMin ?? 0.1,
         userMax: edgeIntensityMax ?? edgeIntensity,
       ),
       _edgeThicknessRange = ParameterRange(
         hardMin: 0.1,
         hardMax: 5.0,
         initialValue: edgeThicknessCurrent ?? edgeThickness,
         userMin: edgeThicknessMin ?? 0.1,
         userMax: edgeThicknessMax ?? edgeThickness,
       ),
       _edgeColorRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: edgeColorCurrent ?? edgeColor,
         userMin: edgeColorMin ?? 0.0,
         userMax: edgeColorMax ?? edgeColor,
       ),
       _edgeAnimated = edgeAnimated,
       _animationSpeed = animationSpeed,
       _animOptions = animOptions ?? AnimationOptions();

  // Getters
  bool get edgeEnabled => _edgeEnabled;
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

  double get edgeIntensity => _edgeIntensityRange.userMax;
  set edgeIntensity(double value) {
    _edgeIntensityRange.setCurrent(value);
  }

  ParameterRange get edgeIntensityRange => _edgeIntensityRange.copy();
  void setEdgeIntensityRange(ParameterRange range) {
    _edgeIntensityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get edgeThickness => _edgeThicknessRange.userMax;
  set edgeThickness(double value) {
    _edgeThicknessRange.setCurrent(value);
  }

  ParameterRange get edgeThicknessRange => _edgeThicknessRange.copy();
  void setEdgeThicknessRange(ParameterRange range) {
    _edgeThicknessRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get edgeColor => _edgeColorRange.userMax;
  set edgeColor(double value) {
    _edgeColorRange.setCurrent(value);
  }

  ParameterRange get edgeColorRange => _edgeColorRange.copy();
  void setEdgeColorRange(ParameterRange range) {
    _edgeColorRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  bool get edgeAnimated => _edgeAnimated;
  double get animationSpeed => _animationSpeed;
  AnimationOptions get edgeAnimOptions => _animOptions;

  // Setters
  set edgeEnabled(bool value) => _edgeEnabled = value;
  set edgeAnimated(bool value) => _edgeAnimated = value;
  set animationSpeed(double value) => _animationSpeed = value;
  set edgeAnimOptions(AnimationOptions value) => _animOptions = value;

  // Convenience getter to check if effect should be applied
  bool get shouldApplyEdge {
    return _edgeEnabled && opacity >= 0.01;
  }

  // Create a copy with updated values
  EdgeSettings copyWith({
    bool? edgeEnabled,
    double? opacity,
    double? edgeIntensity,
    double? edgeThickness,
    double? edgeColor,
    bool? edgeAnimated,
    double? animationSpeed,
    AnimationOptions? animOptions,
  }) {
    return EdgeSettings(
      edgeEnabled: edgeEnabled ?? _edgeEnabled,
      opacity: opacity ?? this.opacity,
      edgeIntensity: edgeIntensity ?? this.edgeIntensity,
      edgeThickness: edgeThickness ?? this.edgeThickness,
      edgeColor: edgeColor ?? this.edgeColor,
      edgeAnimated: edgeAnimated ?? _edgeAnimated,
      animationSpeed: animationSpeed ?? _animationSpeed,
      animOptions: animOptions ?? _animOptions,
    );
  }

  // Reset to default values
  void reset() {
    _edgeEnabled = false;
    _opacityRange.resetToDefaults(defaultMin: 0.0, defaultMax: 0.7);
    _edgeIntensityRange.resetToDefaults(defaultMin: 0.1, defaultMax: 1.5);
    _edgeThicknessRange.resetToDefaults(defaultMin: 0.1, defaultMax: 1.0);
    _edgeColorRange.resetToDefaults(defaultMin: 0.0, defaultMax: 0.0);
    _edgeAnimated = false;
    _animationSpeed = 1.0;
    _animOptions = AnimationOptions();
  }

  // Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'edgeEnabled': _edgeEnabled,
      'opacity': opacity,
      'opacityMin': _opacityRange.userMin,
      'opacityMax': _opacityRange.userMax,
      'opacityCurrent': _opacityRange.current,
      'opacityRange': _opacityRange.toMap(),
      'edgeIntensity': edgeIntensity,
      'edgeIntensityMin': _edgeIntensityRange.userMin,
      'edgeIntensityMax': _edgeIntensityRange.userMax,
      'edgeIntensityCurrent': _edgeIntensityRange.current,
      'edgeIntensityRange': _edgeIntensityRange.toMap(),
      'edgeThickness': edgeThickness,
      'edgeThicknessMin': _edgeThicknessRange.userMin,
      'edgeThicknessMax': _edgeThicknessRange.userMax,
      'edgeThicknessCurrent': _edgeThicknessRange.current,
      'edgeThicknessRange': _edgeThicknessRange.toMap(),
      'edgeColor': edgeColor,
      'edgeColorMin': _edgeColorRange.userMin,
      'edgeColorMax': _edgeColorRange.userMax,
      'edgeColorCurrent': _edgeColorRange.current,
      'edgeColorRange': _edgeColorRange.toMap(),
      'edgeAnimated': _edgeAnimated,
      'animationSpeed': _animationSpeed,
      'animOptions': _animOptions.toMap(),
    };
  }

  // Create from map for deserialization
  factory EdgeSettings.fromMap(Map<String, dynamic> map) {
    double _readDouble(dynamic value, double fallback) {
      if (value is num) return value.toDouble();
      return fallback;
    }

    final settings = EdgeSettings(
      edgeEnabled: map['edgeEnabled'] ?? false,
      opacity: _readDouble(map['opacity'], 0.7),
      opacityMin: _readDouble(map['opacityMin'], 0.0),
      opacityMax: _readDouble(
        map['opacityMax'],
        _readDouble(map['opacity'], 0.7),
      ),
      opacityCurrent: _readDouble(
        map['opacityCurrent'],
        _readDouble(map['opacity'], 0.7),
      ),
      edgeIntensity: _readDouble(map['edgeIntensity'], 1.5),
      edgeIntensityMin: _readDouble(map['edgeIntensityMin'], 0.1),
      edgeIntensityMax: _readDouble(
        map['edgeIntensityMax'],
        _readDouble(map['edgeIntensity'], 1.5),
      ),
      edgeIntensityCurrent: _readDouble(
        map['edgeIntensityCurrent'],
        _readDouble(map['edgeIntensity'], 1.5),
      ),
      edgeThickness: _readDouble(map['edgeThickness'], 1.0),
      edgeThicknessMin: _readDouble(map['edgeThicknessMin'], 0.1),
      edgeThicknessMax: _readDouble(
        map['edgeThicknessMax'],
        _readDouble(map['edgeThickness'], 1.0),
      ),
      edgeThicknessCurrent: _readDouble(
        map['edgeThicknessCurrent'],
        _readDouble(map['edgeThickness'], 1.0),
      ),
      edgeColor: _readDouble(map['edgeColor'], 0.0),
      edgeColorMin: _readDouble(map['edgeColorMin'], 0.0),
      edgeColorMax: _readDouble(
        map['edgeColorMax'],
        _readDouble(map['edgeColor'], 0.0),
      ),
      edgeColorCurrent: _readDouble(
        map['edgeColorCurrent'],
        _readDouble(map['edgeColor'], 0.0),
      ),
      edgeAnimated: map['edgeAnimated'] ?? false,
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
      settings._edgeIntensityRange,
      map['edgeIntensityRange'],
      hardMin: 0.1,
      hardMax: 5.0,
      fallback: settings.edgeIntensity,
    );
    _maybeApplyRange(
      settings._edgeThicknessRange,
      map['edgeThicknessRange'],
      hardMin: 0.1,
      hardMax: 5.0,
      fallback: settings.edgeThickness,
    );
    _maybeApplyRange(
      settings._edgeColorRange,
      map['edgeColorRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.edgeColor,
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
    return 'EdgeSettings('
        'enabled: $_edgeEnabled, '
        'opacity: $opacity, '
        'intensity: $edgeIntensity, '
        'thickness: $edgeThickness, '
        'color: $edgeColor, '
        'animated: $_edgeAnimated)';
  }
}
