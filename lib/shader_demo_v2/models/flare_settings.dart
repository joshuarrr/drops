import 'package:flutter/material.dart';
import 'animation_options.dart';
import 'targetable_effect_settings.dart';
import 'parameter_range.dart';

class FlareSettings with TargetableEffectSettings {
  bool _effectEnabled;

  // Core controls inspired by Paper Shaders MeshGradient
  ParameterRange _distortionRange; // 0..1
  ParameterRange _swirlRange; // 0..1
  double _grainMixer; // 0..1 (edge grain)
  double _grainOverlay; // 0..1 (rgb grain)
  ParameterRange _offsetXRange; // -1..1
  ParameterRange _offsetYRange; // -1..1
  ParameterRange _scaleRange; // 0.01..4
  ParameterRange _rotationRange; // 0..360 (degrees)
  ParameterRange _opacityRange; // 0..1

  // Animation
  bool _effectAnimated;
  double _speed; // 0..2 (matches paper docs)
  AnimationOptions _animOptions;

  // Colors (up to 4)
  List<Color> _colors;

  static bool enableLogging = false;

  FlareSettings({
    bool effectEnabled = false,
    double distortion = 0.8,
    double swirl = 0.1,
    double grainMixer = 0.0,
    double grainOverlay = 0.0,
    double offsetX = 0.0,
    double offsetY = 0.0,
    double scale = 1.0,
    double rotation = 0.0,
    double opacity = 0.7,
    bool effectAnimated = false,
    double speed = 1.0,
    AnimationOptions? animOptions,
    List<Color>? colors,
    bool applyToImage = true,
    bool applyToText = false,
  }) : _effectEnabled = effectEnabled,
       _distortionRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: distortion,
         userMin: 0.0,
         userMax: distortion,
       ),
       _swirlRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: swirl,
         userMin: 0.0,
         userMax: swirl,
       ),
       _grainMixer = grainMixer,
       _grainOverlay = grainOverlay,
       _offsetXRange = ParameterRange(
         hardMin: -1.0,
         hardMax: 1.0,
         initialValue: offsetX,
         userMin: -1.0,
         userMax: offsetX,
       ),
       _offsetYRange = ParameterRange(
         hardMin: -1.0,
         hardMax: 1.0,
         initialValue: offsetY,
         userMin: -1.0,
         userMax: offsetY,
       ),
       _scaleRange = ParameterRange(
         hardMin: 0.01,
         hardMax: 4.0,
         initialValue: scale,
         userMin: 0.01,
         userMax: scale,
       ),
       _rotationRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 360.0,
         initialValue: rotation,
         userMin: 0.0,
         userMax: rotation,
       ),
       _opacityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: opacity,
         userMin: 0.0,
         userMax: opacity,
       ),
       _effectAnimated = effectAnimated,
       _speed = speed,
       _animOptions = animOptions ?? AnimationOptions(),
       _colors = (colors != null && colors.isNotEmpty)
           ? colors.take(4).toList()
           : [
               const Color(0xFFCC3333),
               const Color(0xFFCC9933),
               const Color(0xFF99CC33),
               const Color(0xFF33CC33),
             ] {
    this.applyToImage = applyToImage;
    this.applyToText = applyToText;
  }

  // Getters
  bool get effectEnabled => _effectEnabled;
  double get distortion => _distortionRange.userMax;
  double get swirl => _swirlRange.userMax;
  double get grainMixer => _grainMixer;
  double get grainOverlay => _grainOverlay;
  double get offsetX => _offsetXRange.userMax;
  double get offsetY => _offsetYRange.userMax;
  double get scale => _scaleRange.userMax;
  double get rotation => _rotationRange.userMax;
  double get opacity => _opacityRange.userMax;
  bool get effectAnimated => _effectAnimated;
  double get speed => _speed;
  AnimationOptions get animOptions => _animOptions;
  List<Color> get colors => List.unmodifiable(_colors);

  // Setters
  set effectEnabled(bool v) => _effectEnabled = v;
  set distortion(double v) {
    _distortionRange.setCurrent(v);
  }

  set swirl(double v) {
    _swirlRange.setCurrent(v);
  }

  set grainMixer(double v) => _grainMixer = v;
  set grainOverlay(double v) => _grainOverlay = v;
  set offsetX(double v) {
    _offsetXRange.setCurrent(v);
  }

  set offsetY(double v) {
    _offsetYRange.setCurrent(v);
  }

  set scale(double v) {
    _scaleRange.setCurrent(v);
  }

  set rotation(double v) {
    _rotationRange.setCurrent(v);
  }

  ParameterRange get distortionRange => _distortionRange.copy();
  void setDistortionRange(ParameterRange range) {
    _distortionRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  ParameterRange get swirlRange => _swirlRange.copy();
  void setSwirlRange(ParameterRange range) {
    _swirlRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  ParameterRange get offsetXRange => _offsetXRange.copy();
  void setOffsetXRange(ParameterRange range) {
    _offsetXRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  ParameterRange get offsetYRange => _offsetYRange.copy();
  void setOffsetYRange(ParameterRange range) {
    _offsetYRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  ParameterRange get scaleRange => _scaleRange.copy();
  void setScaleRange(ParameterRange range) {
    _scaleRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  ParameterRange get rotationRange => _rotationRange.copy();
  void setRotationRange(ParameterRange range) {
    _rotationRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  set opacity(double v) {
    _opacityRange.setCurrent(v);
  }

  ParameterRange get opacityRange => _opacityRange.copy();
  void setOpacityRange(ParameterRange range) {
    _opacityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  set effectAnimated(bool v) => _effectAnimated = v;
  set speed(double v) => _speed = v;
  set animOptions(AnimationOptions v) => _animOptions = v;
  void setColors(List<Color> c) {
    _colors = c.take(4).toList();
    while (_colors.length < 4) {
      _colors.add(Colors.black);
    }
  }

  bool get shouldApplyEffect => _effectEnabled;

  void reset() {
    _effectEnabled = false;
    // Ranges reset
    _grainMixer = 0.0;
    _grainOverlay = 0.0;
    _offsetXRange.resetToDefaults(defaultMin: -1.0, defaultMax: 0.0);
    _offsetYRange.resetToDefaults(defaultMin: -1.0, defaultMax: 0.0);
    _scaleRange.resetToDefaults(defaultMin: 0.01, defaultMax: 1.0);
    _rotationRange.resetToDefaults(defaultMin: 0.0, defaultMax: 0.0);
    _distortionRange.resetToDefaults(defaultMin: 0.0, defaultMax: 0.8);
    _swirlRange.resetToDefaults(defaultMin: 0.0, defaultMax: 0.1);
    _opacityRange.resetToDefaults(defaultMin: 0.0, defaultMax: 0.7);
    _effectAnimated = false;
    _speed = 1.0;
    _animOptions = AnimationOptions();
    _colors = [
      const Color(0xFFCC3333),
      const Color(0xFFCC9933),
      const Color(0xFF99CC33),
      const Color(0xFF33CC33),
    ];
    applyToImage = true;
    applyToText = false;
  }

  Map<String, dynamic> toMap() {
    final map = {
      'effectEnabled': _effectEnabled,
      'distortion': distortion,
      'swirl': swirl,
      'grainMixer': _grainMixer,
      'grainOverlay': _grainOverlay,
      'offsetX': offsetX,
      'offsetXMin': _offsetXRange.userMin,
      'offsetXMax': _offsetXRange.userMax,
      'offsetXCurrent': _offsetXRange.current,
      'offsetXRange': _offsetXRange.toMap(),
      'offsetY': offsetY,
      'offsetYMin': _offsetYRange.userMin,
      'offsetYMax': _offsetYRange.userMax,
      'offsetYCurrent': _offsetYRange.current,
      'offsetYRange': _offsetYRange.toMap(),
      'scale': scale,
      'scaleMin': _scaleRange.userMin,
      'scaleMax': _scaleRange.userMax,
      'scaleCurrent': _scaleRange.current,
      'scaleRange': _scaleRange.toMap(),
      'rotation': rotation,
      'rotationMin': _rotationRange.userMin,
      'rotationMax': _rotationRange.userMax,
      'rotationCurrent': _rotationRange.current,
      'rotationRange': _rotationRange.toMap(),
      'distortionMin': _distortionRange.userMin,
      'distortionMax': _distortionRange.userMax,
      'distortionCurrent': _distortionRange.current,
      'distortionRange': _distortionRange.toMap(),
      'swirlMin': _swirlRange.userMin,
      'swirlMax': _swirlRange.userMax,
      'swirlCurrent': _swirlRange.current,
      'swirlRange': _swirlRange.toMap(),
      'opacity': opacity,
      'opacityMin': _opacityRange.userMin,
      'opacityMax': _opacityRange.userMax,
      'opacityCurrent': _opacityRange.current,
      'opacityRange': _opacityRange.toMap(),
      'effectAnimated': _effectAnimated,
      'speed': _speed,
      'animOptions': _animOptions.toMap(),
      'colors': _colors.map((c) => c.value).toList(),
    };
    addTargetingToMap(map);
    return map;
  }

  static FlareSettings fromMap(Map<String, dynamic> map) {
    double _rd(dynamic v, double fb) => v is num ? v.toDouble() : fb;
    List<Color> _rc(dynamic v) {
      if (v is List) {
        return v.whereType<num>().map((n) => Color(n.toInt())).take(4).toList();
      }
      return [];
    }

    final settings = FlareSettings(
      effectEnabled: map['effectEnabled'] ?? false,
      distortion: _rd(map['distortion'], 0.8).clamp(0.0, 1.0),
      swirl: _rd(map['swirl'], 0.1).clamp(0.0, 1.0),
      grainMixer: _rd(map['grainMixer'], 0.0).clamp(0.0, 1.0),
      grainOverlay: _rd(map['grainOverlay'], 0.0).clamp(0.0, 1.0),
      offsetX: _rd(map['offsetX'], 0.0).clamp(-1.0, 1.0),
      offsetY: _rd(map['offsetY'], 0.0).clamp(-1.0, 1.0),
      scale: _rd(map['scale'], 1.0).clamp(0.01, 4.0),
      rotation: _rd(map['rotation'], 0.0).clamp(0.0, 360.0),
      opacity: _rd(map['opacity'], 0.7).clamp(0.0, 1.0),
      effectAnimated: map['effectAnimated'] ?? false,
      speed: _rd(map['speed'], 1.0).clamp(0.0, 2.0),
      animOptions: map['animOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['animOptions']),
            )
          : null,
      colors: _rc(map['colors']),
    );

    settings.loadTargetingFromMap(map);

    // Apply opacity range data if present
    if (map['opacityRange'] is Map<String, dynamic>) {
      final range = ParameterRange.fromMap(
        Map<String, dynamic>.from(map['opacityRange']),
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: settings.opacity,
      );
      settings._opacityRange
        ..setUserMin(range.userMin)
        ..setUserMax(range.userMax)
        ..setCurrent(range.current, syncUserMax: false);
    } else {
      // Back-compat fields
      final double omin = _rd(map['opacityMin'], 0.0).clamp(0.0, 1.0);
      final double omax = _rd(
        map['opacityMax'],
        settings.opacity,
      ).clamp(0.0, 1.0);
      final double ocur = _rd(
        map['opacityCurrent'],
        settings.opacity,
      ).clamp(0.0, 1.0);
      settings._opacityRange
        ..setUserMin(omin)
        ..setUserMax(omax)
        ..setCurrent(ocur, syncUserMax: false);
    }
    return settings;
  }
}
