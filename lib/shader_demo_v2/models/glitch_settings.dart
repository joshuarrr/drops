import 'animation_options.dart';

class GlitchSettings {
  bool _effectEnabled;
  double _opacity;
  double _intensity;
  double _speed;
  double _blockSize;
  bool _effectAnimated;
  double _animationSpeed;
  AnimationOptions _animOptions;

  static bool enableLogging = false;

  GlitchSettings({
    bool effectEnabled = false,
    double opacity = 0.5,
    double intensity = 0.3,
    double speed = 1.0,
    double blockSize = 0.1,
    bool effectAnimated = false,
    double animationSpeed = 1.0,
    AnimationOptions? animOptions,
  }) : _effectEnabled = effectEnabled,
       _opacity = opacity,
       _intensity = intensity,
       _speed = speed,
       _blockSize = blockSize,
       _effectAnimated = effectAnimated,
       _animationSpeed = animationSpeed,
       _animOptions = animOptions ?? AnimationOptions();

  // Getters
  bool get effectEnabled => _effectEnabled;
  double get opacity => _opacity;
  double get intensity => _intensity;
  double get speed => _speed;
  double get blockSize => _blockSize;
  bool get effectAnimated => _effectAnimated;
  double get animationSpeed => _animationSpeed;
  AnimationOptions get effectAnimOptions => _animOptions;

  // Setters
  set effectEnabled(bool value) => _effectEnabled = value;
  set opacity(double value) => _opacity = value;
  set intensity(double value) => _intensity = value;
  set speed(double value) => _speed = value;
  set blockSize(double value) => _blockSize = value;
  set effectAnimated(bool value) => _effectAnimated = value;
  set animationSpeed(double value) => _animationSpeed = value;
  set effectAnimOptions(AnimationOptions value) => _animOptions = value;

  // Convenience getter to check if effect should be applied
  bool get shouldApplyEffect => _effectEnabled && _opacity >= 0.01;

  // Create a copy with updated values
  GlitchSettings copyWith({
    bool? effectEnabled,
    double? opacity,
    double? intensity,
    double? speed,
    double? blockSize,
    bool? effectAnimated,
    double? animationSpeed,
    AnimationOptions? animOptions,
  }) {
    return GlitchSettings(
      effectEnabled: effectEnabled ?? _effectEnabled,
      opacity: opacity ?? _opacity,
      intensity: intensity ?? _intensity,
      speed: speed ?? _speed,
      blockSize: blockSize ?? _blockSize,
      effectAnimated: effectAnimated ?? _effectAnimated,
      animationSpeed: animationSpeed ?? _animationSpeed,
      animOptions: animOptions ?? _animOptions,
    );
  }

  // Reset to default values
  void reset() {
    _effectEnabled = false;
    _opacity = 0.5;
    _intensity = 0.3;
    _speed = 1.0;
    _blockSize = 0.1;
    _effectAnimated = false;
    _animationSpeed = 1.0;
    _animOptions = AnimationOptions();
  }

  // Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'effectEnabled': _effectEnabled,
      'opacity': _opacity,
      'intensity': _intensity,
      'speed': _speed,
      'blockSize': _blockSize,
      'effectAnimated': _effectAnimated,
      'animationSpeed': _animationSpeed,
      'animOptions': _animOptions.toMap(),
    };
  }

  // Create from map for deserialization
  static GlitchSettings fromMap(Map<String, dynamic> map) {
    return GlitchSettings(
      effectEnabled: map['effectEnabled'] ?? false,
      opacity: map['opacity'] ?? 0.5,
      intensity: map['intensity'] ?? 0.3,
      speed: map['speed'] ?? 1.0,
      blockSize: map['blockSize'] ?? 0.1,
      effectAnimated: map['effectAnimated'] ?? false,
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
    return 'GlitchSettings(enabled: $_effectEnabled, opacity: $_opacity, intensity: $_intensity, speed: $_speed, blockSize: $_blockSize, animated: $_effectAnimated)';
  }
}
