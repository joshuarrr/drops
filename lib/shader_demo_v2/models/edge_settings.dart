import 'animation_options.dart';

class EdgeSettings {
  // Core effect controls
  bool _edgeEnabled;
  double _opacity;

  // Edge detection parameters
  double _edgeIntensity;
  double _edgeThickness;
  double _edgeColor; // 0.0 = black, 0.5 = original color, 1.0 = white

  // Animation controls
  bool _edgeAnimated;
  double _animationSpeed;
  AnimationOptions _animOptions;

  // Constructor with default values
  EdgeSettings({
    bool edgeEnabled = false,
    double opacity = 0.7,
    double edgeIntensity = 1.5,
    double edgeThickness = 1.0,
    double edgeColor = 0.0,
    bool edgeAnimated = false,
    double animationSpeed = 1.0,
    AnimationOptions? animOptions,
  }) : _edgeEnabled = edgeEnabled,
       _opacity = opacity,
       _edgeIntensity = edgeIntensity,
       _edgeThickness = edgeThickness,
       _edgeColor = edgeColor,
       _edgeAnimated = edgeAnimated,
       _animationSpeed = animationSpeed,
       _animOptions = animOptions ?? AnimationOptions();

  // Getters
  bool get edgeEnabled => _edgeEnabled;
  double get opacity => _opacity;
  double get edgeIntensity => _edgeIntensity;
  double get edgeThickness => _edgeThickness;
  double get edgeColor => _edgeColor;
  bool get edgeAnimated => _edgeAnimated;
  double get animationSpeed => _animationSpeed;
  AnimationOptions get edgeAnimOptions => _animOptions;

  // Setters
  set edgeEnabled(bool value) => _edgeEnabled = value;
  set opacity(double value) => _opacity = value;
  set edgeIntensity(double value) => _edgeIntensity = value;
  set edgeThickness(double value) => _edgeThickness = value;
  set edgeColor(double value) => _edgeColor = value;
  set edgeAnimated(bool value) => _edgeAnimated = value;
  set animationSpeed(double value) => _animationSpeed = value;
  set edgeAnimOptions(AnimationOptions value) => _animOptions = value;

  // Convenience getter to check if effect should be applied
  bool get shouldApplyEdge {
    return _edgeEnabled && _opacity >= 0.01;
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
      opacity: opacity ?? _opacity,
      edgeIntensity: edgeIntensity ?? _edgeIntensity,
      edgeThickness: edgeThickness ?? _edgeThickness,
      edgeColor: edgeColor ?? _edgeColor,
      edgeAnimated: edgeAnimated ?? _edgeAnimated,
      animationSpeed: animationSpeed ?? _animationSpeed,
      animOptions: animOptions ?? _animOptions,
    );
  }

  // Reset to default values
  void reset() {
    _edgeEnabled = false;
    _opacity = 0.7;
    _edgeIntensity = 1.5;
    _edgeThickness = 1.0;
    _edgeColor = 0.0;
    _edgeAnimated = false;
    _animationSpeed = 1.0;
    _animOptions = AnimationOptions();
  }

  // Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'edgeEnabled': _edgeEnabled,
      'opacity': _opacity,
      'edgeIntensity': _edgeIntensity,
      'edgeThickness': _edgeThickness,
      'edgeColor': _edgeColor,
      'edgeAnimated': _edgeAnimated,
      'animationSpeed': _animationSpeed,
      'animOptions': _animOptions.toMap(),
    };
  }

  // Create from map for deserialization
  factory EdgeSettings.fromMap(Map<String, dynamic> map) {
    return EdgeSettings(
      edgeEnabled: map['edgeEnabled'] ?? false,
      opacity: map['opacity'] ?? 0.7,
      edgeIntensity: map['edgeIntensity'] ?? 1.5,
      edgeThickness: map['edgeThickness'] ?? 1.0,
      edgeColor: map['edgeColor'] ?? 0.0,
      edgeAnimated: map['edgeAnimated'] ?? false,
      animationSpeed: map['animationSpeed'] ?? 1.0,
      animOptions: map['animOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['animOptions']),
            )
          : null,
    );
  }

  @override
  String toString() {
    return 'EdgeSettings('
        'enabled: $_edgeEnabled, '
        'opacity: $_opacity, '
        'intensity: $_edgeIntensity, '
        'thickness: $_edgeThickness, '
        'color: $_edgeColor, '
        'animated: $_edgeAnimated)';
  }
}
