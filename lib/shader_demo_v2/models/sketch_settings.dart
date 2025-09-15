class SketchSettings {
  // Core effect controls
  bool _sketchEnabled;
  double _opacity;
  double _imageOpacity; // Opacity of the underlying image

  // Luminance thresholds for different hatching layers
  double _lumThreshold1;
  double _lumThreshold2;
  double _lumThreshold3;
  double _lumThreshold4;

  // Line properties
  double _hatchYOffset;
  double _lineSpacing;
  double _lineThickness;

  // Animation controls
  bool _sketchAnimated;
  double _animationSpeed;

  // Constructor with default values
  SketchSettings({
    bool sketchEnabled = false,
    double opacity = 0.5,
    double imageOpacity = 1.0,
    double lumThreshold1 = 0.7,
    double lumThreshold2 = 0.5,
    double lumThreshold3 = 0.3,
    double lumThreshold4 = 0.1,
    double hatchYOffset = 0.0,
    double lineSpacing = 15.0,
    double lineThickness = 2.0,
    bool sketchAnimated = false,
    double animationSpeed = 1.0,
  }) : _sketchEnabled = sketchEnabled,
       _opacity = opacity,
       _imageOpacity = imageOpacity,
       _lumThreshold1 = lumThreshold1,
       _lumThreshold2 = lumThreshold2,
       _lumThreshold3 = lumThreshold3,
       _lumThreshold4 = lumThreshold4,
       _hatchYOffset = hatchYOffset,
       _lineSpacing = lineSpacing,
       _lineThickness = lineThickness,
       _sketchAnimated = sketchAnimated,
       _animationSpeed = animationSpeed;

  // Getters
  bool get sketchEnabled => _sketchEnabled;
  double get opacity => _opacity;
  double get imageOpacity => _imageOpacity;
  double get lumThreshold1 => _lumThreshold1;
  double get lumThreshold2 => _lumThreshold2;
  double get lumThreshold3 => _lumThreshold3;
  double get lumThreshold4 => _lumThreshold4;
  double get hatchYOffset => _hatchYOffset;
  double get lineSpacing => _lineSpacing;
  double get lineThickness => _lineThickness;
  bool get sketchAnimated => _sketchAnimated;
  double get animationSpeed => _animationSpeed;

  // Setters
  set sketchEnabled(bool value) => _sketchEnabled = value;
  set opacity(double value) => _opacity = value;
  set imageOpacity(double value) => _imageOpacity = value;
  set lumThreshold1(double value) => _lumThreshold1 = value;
  set lumThreshold2(double value) => _lumThreshold2 = value;
  set lumThreshold3(double value) => _lumThreshold3 = value;
  set lumThreshold4(double value) => _lumThreshold4 = value;
  set hatchYOffset(double value) => _hatchYOffset = value;
  set lineSpacing(double value) => _lineSpacing = value;
  set lineThickness(double value) => _lineThickness = value;
  set sketchAnimated(bool value) => _sketchAnimated = value;
  set animationSpeed(double value) => _animationSpeed = value;

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
  }) {
    return SketchSettings(
      sketchEnabled: sketchEnabled ?? _sketchEnabled,
      opacity: opacity ?? _opacity,
      imageOpacity: imageOpacity ?? _imageOpacity,
      lumThreshold1: lumThreshold1 ?? _lumThreshold1,
      lumThreshold2: lumThreshold2 ?? _lumThreshold2,
      lumThreshold3: lumThreshold3 ?? _lumThreshold3,
      lumThreshold4: lumThreshold4 ?? _lumThreshold4,
      hatchYOffset: hatchYOffset ?? _hatchYOffset,
      lineSpacing: lineSpacing ?? _lineSpacing,
      lineThickness: lineThickness ?? _lineThickness,
      sketchAnimated: sketchAnimated ?? _sketchAnimated,
      animationSpeed: animationSpeed ?? _animationSpeed,
    );
  }

  // Reset to defaults
  void reset() {
    _sketchEnabled = false;
    _opacity = 0.5;
    _imageOpacity = 1.0;
    _lumThreshold1 = 0.7;
    _lumThreshold2 = 0.5;
    _lumThreshold3 = 0.3;
    _lumThreshold4 = 0.1;
    _hatchYOffset = 0.0;
    _lineSpacing = 15.0;
    _lineThickness = 2.0;
    _sketchAnimated = false;
    _animationSpeed = 1.0;
  }

  // Check if sketch should be applied
  bool get shouldApplySketch => _sketchEnabled && _opacity >= 0.01;

  // Debug string
  @override
  String toString() {
    return 'SketchSettings('
        'enabled: $_sketchEnabled, '
        'opacity: $_opacity, '
        'imageOpacity: $_imageOpacity, '
        'thresholds: [$_lumThreshold1, $_lumThreshold2, $_lumThreshold3, $_lumThreshold4], '
        'spacing: $_lineSpacing, '
        'thickness: $_lineThickness)';
  }

  // Serialization
  Map<String, dynamic> toMap() {
    return {
      'sketchEnabled': _sketchEnabled,
      'opacity': _opacity,
      'imageOpacity': _imageOpacity,
      'lumThreshold1': _lumThreshold1,
      'lumThreshold2': _lumThreshold2,
      'lumThreshold3': _lumThreshold3,
      'lumThreshold4': _lumThreshold4,
      'hatchYOffset': _hatchYOffset,
      'lineSpacing': _lineSpacing,
      'lineThickness': _lineThickness,
      'sketchAnimated': _sketchAnimated,
      'animationSpeed': _animationSpeed,
    };
  }

  factory SketchSettings.fromMap(Map<String, dynamic> map) {
    return SketchSettings(
      sketchEnabled: map['sketchEnabled'] ?? false,
      opacity: map['opacity'] ?? 0.5,
      imageOpacity: map['imageOpacity'] ?? 1.0,
      lumThreshold1: map['lumThreshold1'] ?? 0.7,
      lumThreshold2: map['lumThreshold2'] ?? 0.5,
      lumThreshold3: map['lumThreshold3'] ?? 0.3,
      lumThreshold4: map['lumThreshold4'] ?? 0.1,
      hatchYOffset: map['hatchYOffset'] ?? 0.0,
      lineSpacing: map['lineSpacing'] ?? 15.0,
      lineThickness: map['lineThickness'] ?? 2.0,
      sketchAnimated: map['sketchAnimated'] ?? false,
      animationSpeed: map['animationSpeed'] ?? 1.0,
    );
  }
}
