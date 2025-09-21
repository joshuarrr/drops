import 'animation_options.dart';
import 'parameter_range.dart';

class SketchSettings {
  // Core effect controls
  bool _sketchEnabled;
  ParameterRange _opacityRange;
  ParameterRange _imageOpacityRange; // Opacity of the underlying image

  // Luminance thresholds for different hatching layers
  ParameterRange _lumThreshold1Range;
  ParameterRange _lumThreshold2Range;
  ParameterRange _lumThreshold3Range;
  ParameterRange _lumThreshold4Range;

  // Line properties
  ParameterRange _hatchYOffsetRange;
  ParameterRange _lineSpacingRange;
  ParameterRange _lineThicknessRange;

  // Animation controls
  bool _sketchAnimated;
  double _animationSpeed;
  AnimationOptions _animOptions;

  // Constructor with default values
  SketchSettings({
    bool sketchEnabled = false,
    double opacity = 0.5,
    double? opacityMin,
    double? opacityMax,
    double? opacityCurrent,
    double imageOpacity = 1.0,
    double? imageOpacityMin,
    double? imageOpacityMax,
    double? imageOpacityCurrent,
    double lumThreshold1 = 0.7,
    double? lumThreshold1Min,
    double? lumThreshold1Max,
    double? lumThreshold1Current,
    double lumThreshold2 = 0.5,
    double? lumThreshold2Min,
    double? lumThreshold2Max,
    double? lumThreshold2Current,
    double lumThreshold3 = 0.3,
    double? lumThreshold3Min,
    double? lumThreshold3Max,
    double? lumThreshold3Current,
    double lumThreshold4 = 0.1,
    double? lumThreshold4Min,
    double? lumThreshold4Max,
    double? lumThreshold4Current,
    double hatchYOffset = 0.0,
    double? hatchYOffsetMin,
    double? hatchYOffsetMax,
    double? hatchYOffsetCurrent,
    double lineSpacing = 15.0,
    double? lineSpacingMin,
    double? lineSpacingMax,
    double? lineSpacingCurrent,
    double lineThickness = 2.0,
    double? lineThicknessMin,
    double? lineThicknessMax,
    double? lineThicknessCurrent,
    bool sketchAnimated = false,
    double animationSpeed = 1.0,
    AnimationOptions? animOptions,
  }) : _sketchEnabled = sketchEnabled,
       _opacityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: opacityCurrent ?? opacity,
         userMin: opacityMin ?? 0.0,
         userMax: opacityMax ?? opacity,
       ),
       _imageOpacityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: imageOpacityCurrent ?? imageOpacity,
         userMin: imageOpacityMin ?? 0.0,
         userMax: imageOpacityMax ?? imageOpacity,
       ),
       _lumThreshold1Range = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: lumThreshold1Current ?? lumThreshold1,
         userMin: lumThreshold1Min ?? 0.0,
         userMax: lumThreshold1Max ?? lumThreshold1,
       ),
       _lumThreshold2Range = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: lumThreshold2Current ?? lumThreshold2,
         userMin: lumThreshold2Min ?? 0.0,
         userMax: lumThreshold2Max ?? lumThreshold2,
       ),
       _lumThreshold3Range = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: lumThreshold3Current ?? lumThreshold3,
         userMin: lumThreshold3Min ?? 0.0,
         userMax: lumThreshold3Max ?? lumThreshold3,
       ),
       _lumThreshold4Range = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: lumThreshold4Current ?? lumThreshold4,
         userMin: lumThreshold4Min ?? 0.0,
         userMax: lumThreshold4Max ?? lumThreshold4,
       ),
       _hatchYOffsetRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 50.0,
         initialValue: hatchYOffsetCurrent ?? hatchYOffset,
         userMin: hatchYOffsetMin ?? 0.0,
         userMax: hatchYOffsetMax ?? hatchYOffset,
       ),
       _lineSpacingRange = ParameterRange(
         hardMin: 5.0,
         hardMax: 50.0,
         initialValue: lineSpacingCurrent ?? lineSpacing,
         userMin: lineSpacingMin ?? 5.0,
         userMax: lineSpacingMax ?? lineSpacing,
       ),
       _lineThicknessRange = ParameterRange(
         hardMin: 0.5,
         hardMax: 5.0,
         initialValue: lineThicknessCurrent ?? lineThickness,
         userMin: lineThicknessMin ?? 0.5,
         userMax: lineThicknessMax ?? 5.0,
       ),
       _sketchAnimated = sketchAnimated,
       _animationSpeed = animationSpeed,
       _animOptions = animOptions ?? AnimationOptions();

  // Getters
  bool get sketchEnabled => _sketchEnabled;
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

  double get imageOpacity => _imageOpacityRange.userMax;
  set imageOpacity(double value) {
    _imageOpacityRange.setCurrent(value);
  }

  ParameterRange get imageOpacityRange => _imageOpacityRange.copy();
  void setImageOpacityRange(ParameterRange range) {
    _imageOpacityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get lumThreshold1 => _lumThreshold1Range.userMax;
  set lumThreshold1(double value) {
    _lumThreshold1Range.setCurrent(value);
  }

  ParameterRange get lumThreshold1Range => _lumThreshold1Range.copy();
  void setLumThreshold1Range(ParameterRange range) {
    _lumThreshold1Range
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get lumThreshold2 => _lumThreshold2Range.userMax;
  set lumThreshold2(double value) {
    _lumThreshold2Range.setCurrent(value);
  }

  ParameterRange get lumThreshold2Range => _lumThreshold2Range.copy();
  void setLumThreshold2Range(ParameterRange range) {
    _lumThreshold2Range
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get lumThreshold3 => _lumThreshold3Range.userMax;
  set lumThreshold3(double value) {
    _lumThreshold3Range.setCurrent(value);
  }

  ParameterRange get lumThreshold3Range => _lumThreshold3Range.copy();
  void setLumThreshold3Range(ParameterRange range) {
    _lumThreshold3Range
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get lumThreshold4 => _lumThreshold4Range.userMax;
  set lumThreshold4(double value) {
    _lumThreshold4Range.setCurrent(value);
  }

  ParameterRange get lumThreshold4Range => _lumThreshold4Range.copy();
  void setLumThreshold4Range(ParameterRange range) {
    _lumThreshold4Range
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get hatchYOffset => _hatchYOffsetRange.userMax;
  set hatchYOffset(double value) {
    _hatchYOffsetRange.setCurrent(value);
  }

  ParameterRange get hatchYOffsetRange => _hatchYOffsetRange.copy();
  void setHatchYOffsetRange(ParameterRange range) {
    _hatchYOffsetRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get lineSpacing => _lineSpacingRange.userMax;
  set lineSpacing(double value) {
    _lineSpacingRange.setCurrent(value);
  }

  ParameterRange get lineSpacingRange => _lineSpacingRange.copy();
  void setLineSpacingRange(ParameterRange range) {
    _lineSpacingRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get lineThickness => _lineThicknessRange.userMax;
  set lineThickness(double value) {
    _lineThicknessRange.setCurrent(value);
  }

  ParameterRange get lineThicknessRange => _lineThicknessRange.copy();
  void setLineThicknessRange(ParameterRange range) {
    _lineThicknessRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  bool get sketchAnimated => _sketchAnimated;
  double get animationSpeed => _animationSpeed;
  AnimationOptions get sketchAnimOptions => _animOptions;

  // Setters
  set sketchEnabled(bool value) => _sketchEnabled = value;
  set sketchAnimated(bool value) => _sketchAnimated = value;
  set animationSpeed(double value) => _animationSpeed = value;
  set sketchAnimOptions(AnimationOptions value) => _animOptions = value;

  // Copy with method
  SketchSettings copyWith({
    bool? sketchEnabled,
    double? opacity,
    double? imageOpacity,
    double? lumThreshold1,
    double? lumThreshold2,
    double? lumThreshold3,
    double? lumThreshold4,
    double? hatchYOffset,
    double? lineSpacing,
    double? lineThickness,
    bool? sketchAnimated,
    double? animationSpeed,
    AnimationOptions? animOptions,
  }) {
    return SketchSettings(
      sketchEnabled: sketchEnabled ?? _sketchEnabled,
      opacity: opacity ?? this.opacity,
      imageOpacity: imageOpacity ?? this.imageOpacity,
      lumThreshold1: lumThreshold1 ?? this.lumThreshold1,
      lumThreshold2: lumThreshold2 ?? this.lumThreshold2,
      lumThreshold3: lumThreshold3 ?? this.lumThreshold3,
      lumThreshold4: lumThreshold4 ?? this.lumThreshold4,
      hatchYOffset: hatchYOffset ?? this.hatchYOffset,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      lineThickness: lineThickness ?? this.lineThickness,
      sketchAnimated: sketchAnimated ?? _sketchAnimated,
      animationSpeed: animationSpeed ?? _animationSpeed,
      animOptions: animOptions ?? _animOptions,
    );
  }

  // Reset to defaults
  void reset() {
    _sketchEnabled = false;
    _opacityRange.resetToDefaults(defaultMin: 0.0, defaultMax: 0.5);
    _imageOpacityRange.resetToDefaults(defaultMin: 0.0, defaultMax: 1.0);
    _lumThreshold1Range.resetToDefaults(defaultMin: 0.0, defaultMax: 0.7);
    _lumThreshold2Range.resetToDefaults(defaultMin: 0.0, defaultMax: 0.5);
    _lumThreshold3Range.resetToDefaults(defaultMin: 0.0, defaultMax: 0.3);
    _lumThreshold4Range.resetToDefaults(defaultMin: 0.0, defaultMax: 0.1);
    _hatchYOffsetRange.resetToDefaults(defaultMin: 0.0, defaultMax: 0.0);
    _lineSpacingRange.resetToDefaults(defaultMin: 5.0, defaultMax: 15.0);
    _lineThicknessRange.resetToDefaults(defaultMin: 0.5, defaultMax: 5.0);
    _sketchAnimated = false;
    _animationSpeed = 1.0;
    _animOptions = AnimationOptions();
  }

  // Check if sketch should be applied
  bool get shouldApplySketch => _sketchEnabled && opacity >= 0.01;

  // Debug string
  @override
  String toString() {
    return 'SketchSettings('
        'enabled: $_sketchEnabled, '
        'opacity: $opacity, '
        'imageOpacity: $imageOpacity, '
        'thresholds: [$lumThreshold1, $lumThreshold2, $lumThreshold3, $lumThreshold4], '
        'spacing: $lineSpacing, '
        'thickness: $lineThickness)';
  }

  // Serialization
  Map<String, dynamic> toMap() {
    return {
      'sketchEnabled': _sketchEnabled,
      'opacity': opacity,
      'opacityMin': _opacityRange.userMin,
      'opacityMax': _opacityRange.userMax,
      'opacityCurrent': _opacityRange.current,
      'opacityRange': _opacityRange.toMap(),
      'imageOpacity': imageOpacity,
      'imageOpacityMin': _imageOpacityRange.userMin,
      'imageOpacityMax': _imageOpacityRange.userMax,
      'imageOpacityCurrent': _imageOpacityRange.current,
      'imageOpacityRange': _imageOpacityRange.toMap(),
      'lumThreshold1': lumThreshold1,
      'lumThreshold1Min': _lumThreshold1Range.userMin,
      'lumThreshold1Max': _lumThreshold1Range.userMax,
      'lumThreshold1Current': _lumThreshold1Range.current,
      'lumThreshold1Range': _lumThreshold1Range.toMap(),
      'lumThreshold2': lumThreshold2,
      'lumThreshold2Min': _lumThreshold2Range.userMin,
      'lumThreshold2Max': _lumThreshold2Range.userMax,
      'lumThreshold2Current': _lumThreshold2Range.current,
      'lumThreshold2Range': _lumThreshold2Range.toMap(),
      'lumThreshold3': lumThreshold3,
      'lumThreshold3Min': _lumThreshold3Range.userMin,
      'lumThreshold3Max': _lumThreshold3Range.userMax,
      'lumThreshold3Current': _lumThreshold3Range.current,
      'lumThreshold3Range': _lumThreshold3Range.toMap(),
      'lumThreshold4': lumThreshold4,
      'lumThreshold4Min': _lumThreshold4Range.userMin,
      'lumThreshold4Max': _lumThreshold4Range.userMax,
      'lumThreshold4Current': _lumThreshold4Range.current,
      'lumThreshold4Range': _lumThreshold4Range.toMap(),
      'hatchYOffset': hatchYOffset,
      'hatchYOffsetMin': _hatchYOffsetRange.userMin,
      'hatchYOffsetMax': _hatchYOffsetRange.userMax,
      'hatchYOffsetCurrent': _hatchYOffsetRange.current,
      'hatchYOffsetRange': _hatchYOffsetRange.toMap(),
      'lineSpacing': lineSpacing,
      'lineSpacingMin': _lineSpacingRange.userMin,
      'lineSpacingMax': _lineSpacingRange.userMax,
      'lineSpacingCurrent': _lineSpacingRange.current,
      'lineSpacingRange': _lineSpacingRange.toMap(),
      'lineThickness': lineThickness,
      'lineThicknessMin': _lineThicknessRange.userMin,
      'lineThicknessMax': _lineThicknessRange.userMax,
      'lineThicknessCurrent': _lineThicknessRange.current,
      'lineThicknessRange': _lineThicknessRange.toMap(),
      'sketchAnimated': _sketchAnimated,
      'animationSpeed': _animationSpeed,
      'animOptions': _animOptions.toMap(),
    };
  }

  factory SketchSettings.fromMap(Map<String, dynamic> map) {
    double _readDouble(dynamic value, double fallback) {
      if (value is num) return value.toDouble();
      return fallback;
    }

    final settings = SketchSettings(
      sketchEnabled: map['sketchEnabled'] ?? false,
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
      imageOpacity: _readDouble(map['imageOpacity'], 1.0),
      imageOpacityMin: _readDouble(map['imageOpacityMin'], 0.0),
      imageOpacityMax: _readDouble(
        map['imageOpacityMax'],
        _readDouble(map['imageOpacity'], 1.0),
      ),
      imageOpacityCurrent: _readDouble(
        map['imageOpacityCurrent'],
        _readDouble(map['imageOpacity'], 1.0),
      ),
      lumThreshold1: _readDouble(map['lumThreshold1'], 0.7),
      lumThreshold1Min: _readDouble(map['lumThreshold1Min'], 0.0),
      lumThreshold1Max: _readDouble(
        map['lumThreshold1Max'],
        _readDouble(map['lumThreshold1'], 0.7),
      ),
      lumThreshold1Current: _readDouble(
        map['lumThreshold1Current'],
        _readDouble(map['lumThreshold1'], 0.7),
      ),
      lumThreshold2: _readDouble(map['lumThreshold2'], 0.5),
      lumThreshold2Min: _readDouble(map['lumThreshold2Min'], 0.0),
      lumThreshold2Max: _readDouble(
        map['lumThreshold2Max'],
        _readDouble(map['lumThreshold2'], 0.5),
      ),
      lumThreshold2Current: _readDouble(
        map['lumThreshold2Current'],
        _readDouble(map['lumThreshold2'], 0.5),
      ),
      lumThreshold3: _readDouble(map['lumThreshold3'], 0.3),
      lumThreshold3Min: _readDouble(map['lumThreshold3Min'], 0.0),
      lumThreshold3Max: _readDouble(
        map['lumThreshold3Max'],
        _readDouble(map['lumThreshold3'], 0.3),
      ),
      lumThreshold3Current: _readDouble(
        map['lumThreshold3Current'],
        _readDouble(map['lumThreshold3'], 0.3),
      ),
      lumThreshold4: _readDouble(map['lumThreshold4'], 0.1),
      lumThreshold4Min: _readDouble(map['lumThreshold4Min'], 0.0),
      lumThreshold4Max: _readDouble(
        map['lumThreshold4Max'],
        _readDouble(map['lumThreshold4'], 0.1),
      ),
      lumThreshold4Current: _readDouble(
        map['lumThreshold4Current'],
        _readDouble(map['lumThreshold4'], 0.1),
      ),
      hatchYOffset: _readDouble(map['hatchYOffset'], 0.0),
      hatchYOffsetMin: _readDouble(map['hatchYOffsetMin'], 0.0),
      hatchYOffsetMax: _readDouble(
        map['hatchYOffsetMax'],
        _readDouble(map['hatchYOffset'], 0.0),
      ),
      hatchYOffsetCurrent: _readDouble(
        map['hatchYOffsetCurrent'],
        _readDouble(map['hatchYOffset'], 0.0),
      ),
      lineSpacing: _readDouble(map['lineSpacing'], 15.0),
      lineSpacingMin: _readDouble(map['lineSpacingMin'], 5.0),
      lineSpacingMax: _readDouble(
        map['lineSpacingMax'],
        _readDouble(map['lineSpacing'], 15.0),
      ),
      lineSpacingCurrent: _readDouble(
        map['lineSpacingCurrent'],
        _readDouble(map['lineSpacing'], 15.0),
      ),
      lineThickness: _readDouble(map['lineThickness'], 2.0),
      lineThicknessMin: _readDouble(map['lineThicknessMin'], 0.5),
      lineThicknessMax: _readDouble(
        map['lineThicknessMax'],
        _readDouble(map['lineThickness'], 2.0),
      ),
      lineThicknessCurrent: _readDouble(
        map['lineThicknessCurrent'],
        _readDouble(map['lineThickness'], 2.0),
      ),
      sketchAnimated: map['sketchAnimated'] ?? false,
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
      settings._imageOpacityRange,
      map['imageOpacityRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.imageOpacity,
    );
    _maybeApplyRange(
      settings._lumThreshold1Range,
      map['lumThreshold1Range'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.lumThreshold1,
    );
    _maybeApplyRange(
      settings._lumThreshold2Range,
      map['lumThreshold2Range'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.lumThreshold2,
    );
    _maybeApplyRange(
      settings._lumThreshold3Range,
      map['lumThreshold3Range'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.lumThreshold3,
    );
    _maybeApplyRange(
      settings._lumThreshold4Range,
      map['lumThreshold4Range'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.lumThreshold4,
    );
    _maybeApplyRange(
      settings._hatchYOffsetRange,
      map['hatchYOffsetRange'],
      hardMin: 0.0,
      hardMax: 50.0,
      fallback: settings.hatchYOffset,
    );
    _maybeApplyRange(
      settings._lineSpacingRange,
      map['lineSpacingRange'],
      hardMin: 5.0,
      hardMax: 50.0,
      fallback: settings.lineSpacing,
    );
    _maybeApplyRange(
      settings._lineThicknessRange,
      map['lineThicknessRange'],
      hardMin: 0.5,
      hardMax: 5.0,
      fallback: settings.lineThickness,
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
