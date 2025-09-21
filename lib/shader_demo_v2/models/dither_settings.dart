import 'animation_options.dart';

/// Settings for Image Dither effect
class DitherSettings {
  bool _effectEnabled;

  // Dither parameters
  // type: 0 = Ordered Bayer, 1 = Random, 2 = Atkinson (simulated)
  double _type;
  double _pixelSize; // in pixels
  double _colorSteps; // quantization steps per channel

  // Optional animation plumbing (kept for consistency but unused by panel)
  bool _effectAnimated;
  double _animationSpeed;
  AnimationOptions _animOptions;

  static bool enableLogging = false;

  DitherSettings({
    bool effectEnabled = false,
    double type = 0.0,
    double pixelSize = 3.0,
    double colorSteps = 4.0,
    bool effectAnimated = false,
    double animationSpeed = 1.0,
    AnimationOptions? animOptions,
  }) : _effectEnabled = effectEnabled,
       _type = type,
       _pixelSize = pixelSize,
       _colorSteps = colorSteps,
       _effectAnimated = effectAnimated,
       _animationSpeed = animationSpeed,
       _animOptions = animOptions ?? AnimationOptions();

  // Getters
  bool get effectEnabled => _effectEnabled;
  double get type => _type;
  double get pixelSize => _pixelSize;
  double get colorSteps => _colorSteps;
  bool get effectAnimated => _effectAnimated;
  double get animationSpeed => _animationSpeed;
  AnimationOptions get effectAnimOptions => _animOptions;

  // Setters
  set effectEnabled(bool value) => _effectEnabled = value;
  set type(double value) => _type = value;
  set pixelSize(double value) => _pixelSize = value;
  set colorSteps(double value) => _colorSteps = value;
  set effectAnimated(bool value) => _effectAnimated = value;
  set animationSpeed(double value) => _animationSpeed = value;
  set effectAnimOptions(AnimationOptions value) => _animOptions = value;

  bool get shouldApplyEffect => _effectEnabled;

  DitherSettings copyWith({
    bool? effectEnabled,
    double? type,
    double? pixelSize,
    double? colorSteps,
    bool? effectAnimated,
    double? animationSpeed,
    AnimationOptions? animOptions,
  }) {
    return DitherSettings(
      effectEnabled: effectEnabled ?? _effectEnabled,
      type: type ?? _type,
      pixelSize: pixelSize ?? _pixelSize,
      colorSteps: colorSteps ?? _colorSteps,
      effectAnimated: effectAnimated ?? _effectAnimated,
      animationSpeed: animationSpeed ?? _animationSpeed,
      animOptions: animOptions ?? _animOptions,
    );
  }

  void reset() {
    _effectEnabled = false;
    _type = 0.0;
    _pixelSize = 3.0;
    _colorSteps = 4.0;
    _effectAnimated = false;
    _animationSpeed = 1.0;
    _animOptions = AnimationOptions();
  }

  Map<String, dynamic> toMap() {
    return {
      'effectEnabled': _effectEnabled,
      'type': _type,
      'pixelSize': _pixelSize,
      'colorSteps': _colorSteps,
      'effectAnimated': _effectAnimated,
      'animationSpeed': _animationSpeed,
      'animOptions': _animOptions.toMap(),
    };
  }

  static DitherSettings fromMap(Map<String, dynamic> map) {
    double _readDouble(dynamic value, double fallback) {
      if (value is num) return value.toDouble();
      return fallback;
    }

    return DitherSettings(
      effectEnabled: map['effectEnabled'] ?? false,
      type: _readDouble(map['type'], 0.0),
      pixelSize: _readDouble(map['pixelSize'], 3.0),
      colorSteps: _readDouble(map['colorSteps'], 4.0),
      effectAnimated: map['effectAnimated'] ?? false,
      animationSpeed: _readDouble(map['animationSpeed'], 1.0),
      animOptions: map['animOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['animOptions']),
            )
          : null,
    );
  }

  @override
  String toString() {
    return 'DitherSettings(enabled: ' +
        _effectEnabled.toString() +
        ', type: ' +
        _type.toString() +
        ', pixelSize: ' +
        _pixelSize.toString() +
        ', colorSteps: ' +
        _colorSteps.toString() +
        ', animated: ' +
        _effectAnimated.toString() +
        ')';
  }
}
