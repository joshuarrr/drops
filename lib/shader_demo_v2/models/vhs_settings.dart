import 'animation_options.dart';

class VHSSettings {
  bool _effectEnabled;
  double _opacity;
  double _noiseIntensity;
  double _fieldLines;
  double _horizontalWaveStrength;
  double _horizontalWaveScreenSize;
  double _horizontalWaveVerticalSize;
  double _dottedNoiseStrength;
  double _horizontalDistortionStrength;
  bool _effectAnimated;
  double _animationSpeed;
  AnimationOptions _animOptions;

  static bool enableLogging = false;

  VHSSettings({
    bool effectEnabled = false,
    double opacity = 0.5,
    double noiseIntensity = 0.7,
    double fieldLines = 240.0,
    double horizontalWaveStrength = 0.15,
    double horizontalWaveScreenSize = 50.0,
    double horizontalWaveVerticalSize = 100.0,
    double dottedNoiseStrength = 0.2,
    double horizontalDistortionStrength = 0.0087, // 1.0/115.0
    bool effectAnimated = false,
    double animationSpeed = 1.0,
    AnimationOptions? animOptions,
  }) : _effectEnabled = effectEnabled,
       _opacity = opacity,
       _noiseIntensity = noiseIntensity,
       _fieldLines = fieldLines,
       _horizontalWaveStrength = horizontalWaveStrength,
       _horizontalWaveScreenSize = horizontalWaveScreenSize,
       _horizontalWaveVerticalSize = horizontalWaveVerticalSize,
       _dottedNoiseStrength = dottedNoiseStrength,
       _horizontalDistortionStrength = horizontalDistortionStrength,
       _effectAnimated = effectAnimated,
       _animationSpeed = animationSpeed,
       _animOptions = animOptions ?? AnimationOptions();

  // Getters
  bool get effectEnabled => _effectEnabled;
  double get opacity => _opacity;
  double get noiseIntensity => _noiseIntensity;
  double get fieldLines => _fieldLines;
  double get horizontalWaveStrength => _horizontalWaveStrength;
  double get horizontalWaveScreenSize => _horizontalWaveScreenSize;
  double get horizontalWaveVerticalSize => _horizontalWaveVerticalSize;
  double get dottedNoiseStrength => _dottedNoiseStrength;
  double get horizontalDistortionStrength => _horizontalDistortionStrength;
  bool get effectAnimated => _effectAnimated;
  double get animationSpeed => _animationSpeed;
  AnimationOptions get effectAnimOptions => _animOptions;

  // Setters
  set effectEnabled(bool value) => _effectEnabled = value;
  set opacity(double value) => _opacity = value;
  set noiseIntensity(double value) => _noiseIntensity = value;
  set fieldLines(double value) => _fieldLines = value;
  set horizontalWaveStrength(double value) => _horizontalWaveStrength = value;
  set horizontalWaveScreenSize(double value) =>
      _horizontalWaveScreenSize = value;
  set horizontalWaveVerticalSize(double value) =>
      _horizontalWaveVerticalSize = value;
  set dottedNoiseStrength(double value) => _dottedNoiseStrength = value;
  set horizontalDistortionStrength(double value) =>
      _horizontalDistortionStrength = value;
  set effectAnimated(bool value) => _effectAnimated = value;
  set animationSpeed(double value) => _animationSpeed = value;
  set effectAnimOptions(AnimationOptions value) => _animOptions = value;

  // Convenience getter to check if effect should be applied
  bool get shouldApplyEffect => _effectEnabled && _opacity >= 0.01;

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
      opacity: opacity ?? _opacity,
      noiseIntensity: noiseIntensity ?? _noiseIntensity,
      fieldLines: fieldLines ?? _fieldLines,
      horizontalWaveStrength: horizontalWaveStrength ?? _horizontalWaveStrength,
      horizontalWaveScreenSize:
          horizontalWaveScreenSize ?? _horizontalWaveScreenSize,
      horizontalWaveVerticalSize:
          horizontalWaveVerticalSize ?? _horizontalWaveVerticalSize,
      dottedNoiseStrength: dottedNoiseStrength ?? _dottedNoiseStrength,
      horizontalDistortionStrength:
          horizontalDistortionStrength ?? _horizontalDistortionStrength,
      effectAnimated: effectAnimated ?? _effectAnimated,
      animationSpeed: animationSpeed ?? _animationSpeed,
      animOptions: animOptions ?? _animOptions,
    );
  }

  // Reset to default values
  void reset() {
    _effectEnabled = false;
    _opacity = 0.5;
    _noiseIntensity = 0.7;
    _fieldLines = 240.0;
    _horizontalWaveStrength = 0.15;
    _horizontalWaveScreenSize = 50.0;
    _horizontalWaveVerticalSize = 100.0;
    _dottedNoiseStrength = 0.2;
    _horizontalDistortionStrength = 0.0087;
    _effectAnimated = false;
    _animationSpeed = 1.0;
    _animOptions = AnimationOptions();
  }

  // Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'effectEnabled': _effectEnabled,
      'opacity': _opacity,
      'noiseIntensity': _noiseIntensity,
      'fieldLines': _fieldLines,
      'horizontalWaveStrength': _horizontalWaveStrength,
      'horizontalWaveScreenSize': _horizontalWaveScreenSize,
      'horizontalWaveVerticalSize': _horizontalWaveVerticalSize,
      'dottedNoiseStrength': _dottedNoiseStrength,
      'horizontalDistortionStrength': _horizontalDistortionStrength,
      'effectAnimated': _effectAnimated,
      'animationSpeed': _animationSpeed,
      'animOptions': _animOptions.toMap(),
    };
  }

  // Create from map for deserialization
  static VHSSettings fromMap(Map<String, dynamic> map) {
    return VHSSettings(
      effectEnabled: map['effectEnabled'] ?? false,
      opacity: map['opacity'] ?? 0.5,
      noiseIntensity: map['noiseIntensity'] ?? 0.7,
      fieldLines: map['fieldLines'] ?? 240.0,
      horizontalWaveStrength: map['horizontalWaveStrength'] ?? 0.15,
      horizontalWaveScreenSize: map['horizontalWaveScreenSize'] ?? 50.0,
      horizontalWaveVerticalSize: map['horizontalWaveVerticalSize'] ?? 100.0,
      dottedNoiseStrength: map['dottedNoiseStrength'] ?? 0.2,
      horizontalDistortionStrength:
          map['horizontalDistortionStrength'] ?? 0.0087,
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
    return 'VHSSettings(enabled: $_effectEnabled, opacity: $_opacity, noiseIntensity: $_noiseIntensity, fieldLines: $_fieldLines, horizontalWaveStrength: $_horizontalWaveStrength, horizontalWaveScreenSize: $_horizontalWaveScreenSize, horizontalWaveVerticalSize: $_horizontalWaveVerticalSize, dottedNoiseStrength: $_dottedNoiseStrength, horizontalDistortionStrength: $_horizontalDistortionStrength, animated: $_effectAnimated)';
  }
}
