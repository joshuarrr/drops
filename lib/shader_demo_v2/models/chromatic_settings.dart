import 'package:flutter/material.dart';
import 'animation_options.dart';
import 'parameter_range.dart';
import 'targetable_effect_settings.dart';

class ChromaticSettings with TargetableEffectSettings {
  // Main toggle
  bool _chromaticEnabled;

  // Effect properties
  ParameterRange _amountRange; // How much chromatic aberration to apply
  ParameterRange _angleRange; // Direction of the aberration (degrees)
  ParameterRange _spreadRange; // How far apart the color channels are spread
  ParameterRange _intensityRange; // Overall intensity of the effect

  // Animation controls
  bool _chromaticAnimated;
  AnimationOptions _animOptions;

  // Debug flag
  static bool enableLogging = false;

  // Getters and setters
  bool get chromaticEnabled => _chromaticEnabled;
  set chromaticEnabled(bool value) {
    _chromaticEnabled = value;
  }

  double get amount => _amountRange.userMax;
  set amount(double value) {
    _amountRange.setCurrent(value);
  }

  ParameterRange get amountRange => _amountRange.copy();
  void updateAmountRange({double? userMin, double? userMax}) {
    if (userMin != null) _amountRange.setUserMin(userMin);
    if (userMax != null) _amountRange.setUserMax(userMax);
    _amountRange.setCurrent(_amountRange.userMax, syncUserMax: false);
  }

  void setAmountRange(ParameterRange range) {
    _amountRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get angle => _angleRange.userMax;
  set angle(double value) {
    _angleRange.setCurrent(value);
  }

  ParameterRange get angleRange => _angleRange.copy();
  void updateAngleRange({double? userMin, double? userMax}) {
    if (userMin != null) _angleRange.setUserMin(userMin);
    if (userMax != null) _angleRange.setUserMax(userMax);
    _angleRange.setCurrent(_angleRange.userMax, syncUserMax: false);
  }

  void setAngleRange(ParameterRange range) {
    _angleRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get spread => _spreadRange.userMax;
  set spread(double value) {
    _spreadRange.setCurrent(value);
  }

  ParameterRange get spreadRange => _spreadRange.copy();
  void updateSpreadRange({double? userMin, double? userMax}) {
    if (userMin != null) _spreadRange.setUserMin(userMin);
    if (userMax != null) _spreadRange.setUserMax(userMax);
    _spreadRange.setCurrent(_spreadRange.userMax, syncUserMax: false);
  }

  void setSpreadRange(ParameterRange range) {
    _spreadRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  double get intensity => _intensityRange.userMax;
  set intensity(double value) {
    _intensityRange.setCurrent(value);
  }

  ParameterRange get intensityRange => _intensityRange.copy();
  void updateIntensityRange({double? userMin, double? userMax}) {
    if (userMin != null) _intensityRange.setUserMin(userMin);
    if (userMax != null) _intensityRange.setUserMax(userMax);
    _intensityRange.setCurrent(_intensityRange.userMax, syncUserMax: false);
  }

  void setIntensityRange(ParameterRange range) {
    _intensityRange
      ..setUserMin(range.userMin)
      ..setUserMax(range.userMax)
      ..setCurrent(range.current, syncUserMax: false);
  }

  bool get chromaticAnimated => _chromaticAnimated;
  set chromaticAnimated(bool value) {
    _chromaticAnimated = value;
  }

  AnimationOptions get animOptions => _animOptions;
  set animOptions(AnimationOptions value) {
    _animOptions = value;
  }

  // Constructor
  ChromaticSettings({
    bool chromaticEnabled = false,
    double amount = 0.5,
    double? amountMin,
    double? amountMax,
    double? amountCurrent,
    double angle = 0.0,
    double? angleMin,
    double? angleMax,
    double? angleCurrent,
    double spread = 0.5,
    double? spreadMin,
    double? spreadMax,
    double? spreadCurrent,
    double intensity = 0.5,
    double? intensityMin,
    double? intensityMax,
    double? intensityCurrent,
    bool chromaticAnimated = false,
    AnimationOptions? animOptions,
    bool applyToImage = true, // New parameter with default true
    bool applyToText = true, // New parameter with default true
  }) : _chromaticEnabled = chromaticEnabled,
       _amountRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 20.0,
         initialValue: amountCurrent ?? amount,
         userMin: amountMin ?? 0.0,
         userMax: amountMax ?? amount,
       ),
       _angleRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 360.0,
         initialValue: angleCurrent ?? angle,
         userMin: angleMin ?? 0.0,
         userMax: angleMax ?? angle,
       ),
       _spreadRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: spreadCurrent ?? spread,
         userMin: spreadMin ?? 0.0,
         userMax: spreadMax ?? spread,
       ),
       _intensityRange = ParameterRange(
         hardMin: 0.0,
         hardMax: 1.0,
         initialValue: intensityCurrent ?? intensity,
         userMin: intensityMin ?? 0.0,
         userMax: intensityMax ?? intensity,
       ),
       _chromaticAnimated = chromaticAnimated,
       _animOptions = animOptions ?? AnimationOptions() {
    // Set the targeting flags
    this.applyToImage = applyToImage;
    this.applyToText = applyToText;

    if (enableLogging) print("SETTINGS: ChromaticSettings initialized");
  }

  // Serialization
  Map<String, dynamic> toMap() {
    final map = {
      'chromaticEnabled': _chromaticEnabled,
      'amount': amount,
      'amountMin': _amountRange.userMin,
      'amountMax': _amountRange.userMax,
      'amountCurrent': _amountRange.current,
      'amountRange': _amountRange.toMap(),
      'angle': angle,
      'angleMin': _angleRange.userMin,
      'angleMax': _angleRange.userMax,
      'angleCurrent': _angleRange.current,
      'angleRange': _angleRange.toMap(),
      'spread': spread,
      'spreadMin': _spreadRange.userMin,
      'spreadMax': _spreadRange.userMax,
      'spreadCurrent': _spreadRange.current,
      'spreadRange': _spreadRange.toMap(),
      'intensity': intensity,
      'intensityMin': _intensityRange.userMin,
      'intensityMax': _intensityRange.userMax,
      'intensityCurrent': _intensityRange.current,
      'intensityRange': _intensityRange.toMap(),
      'chromaticAnimated': _chromaticAnimated,
      'animOptions': _animOptions.toMap(),
    };

    // Add targeting flags from the mixin
    addTargetingToMap(map);

    return map;
  }

  factory ChromaticSettings.fromMap(Map<String, dynamic> map) {
    double _readDouble(dynamic value, double fallback) {
      if (value is num) return value.toDouble();
      return fallback;
    }

    final settings = ChromaticSettings(
      chromaticEnabled: map['chromaticEnabled'] ?? false,
      amount: _readDouble(map['amount'], 0.5).clamp(0.0, 20.0),
      amountMin: _readDouble(map['amountMin'], 0.0).clamp(0.0, 20.0),
      amountMax: _readDouble(map['amountMax'], _readDouble(map['amount'], 0.5))
          .clamp(0.0, 20.0),
      amountCurrent: _readDouble(
        map['amountCurrent'],
        _readDouble(map['amount'], 0.5),
      ).clamp(0.0, 20.0),
      angle: _readDouble(map['angle'], 0.0).clamp(0.0, 360.0),
      angleMin: _readDouble(map['angleMin'], 0.0).clamp(0.0, 360.0),
      angleMax: _readDouble(map['angleMax'], _readDouble(map['angle'], 0.0))
          .clamp(0.0, 360.0),
      angleCurrent: _readDouble(
        map['angleCurrent'],
        _readDouble(map['angle'], 0.0),
      ).clamp(0.0, 360.0),
      spread: _readDouble(map['spread'], 0.5).clamp(0.0, 1.0),
      spreadMin: _readDouble(map['spreadMin'], 0.0).clamp(0.0, 1.0),
      spreadMax: _readDouble(map['spreadMax'], _readDouble(map['spread'], 0.5))
          .clamp(0.0, 1.0),
      spreadCurrent: _readDouble(
        map['spreadCurrent'],
        _readDouble(map['spread'], 0.5),
      ).clamp(0.0, 1.0),
      intensity: _readDouble(map['intensity'], 0.5).clamp(0.0, 1.0),
      intensityMin: _readDouble(map['intensityMin'], 0.0).clamp(0.0, 1.0),
      intensityMax:
          _readDouble(map['intensityMax'], _readDouble(map['intensity'], 0.5))
              .clamp(0.0, 1.0),
      intensityCurrent: _readDouble(
        map['intensityCurrent'],
        _readDouble(map['intensity'], 0.5),
      ).clamp(0.0, 1.0),
      chromaticAnimated: map['chromaticAnimated'] ?? false,
      animOptions: map['animOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['animOptions']),
            )
          : null,
    );

    _maybeApplyRange(
      settings._amountRange,
      map['amountRange'],
      hardMin: 0.0,
      hardMax: 20.0,
      fallback: settings.amount,
    );
    _maybeApplyRange(
      settings._angleRange,
      map['angleRange'],
      hardMin: 0.0,
      hardMax: 360.0,
      fallback: settings.angle,
    );
    _maybeApplyRange(
      settings._spreadRange,
      map['spreadRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.spread,
    );
    _maybeApplyRange(
      settings._intensityRange,
      map['intensityRange'],
      hardMin: 0.0,
      hardMax: 1.0,
      fallback: settings.intensity,
    );

    // Load targeting flags from the map
    settings.loadTargetingFromMap(map);

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
