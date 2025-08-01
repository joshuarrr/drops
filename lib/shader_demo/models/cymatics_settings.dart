import 'package:flutter/foundation.dart';
import 'animation_options.dart';

/// Settings class for the Cymatics effect.
///
/// Cymatics visualizes sound waves as patterns and shapes, reacting to music.
class CymaticsSettings extends ChangeNotifier {
  // Control flags
  bool _cymaticsEnabled = false;
  bool _applyToText = false;
  bool _applyToImage = true;
  bool _applyToBackground = true;

  // Effect parameters
  double _intensity = 0.5; // Overall intensity of the effect
  double _frequency = 0.5; // Base frequency (visual density)
  double _amplitude = 0.5; // Amplitude of the pattern
  double _complexity = 0.5; // Complexity/detail of the pattern
  double _speed = 0.5; // Animation speed
  double _colorIntensity = 0.5; // Color impact on patterns
  bool _audioReactive = true; // Whether patterns react to audio
  double _audioSensitivity = 0.7; // Sensitivity to audio input

  // Animation flags
  bool _cymaticsAnimated = false;
  AnimationOptions _animOptions = AnimationOptions();

  // Logging flag
  static bool enableLogging = true;

  // Getters
  bool get cymaticsEnabled => _cymaticsEnabled;
  bool get applyToText => _applyToText;
  bool get applyToImage => _applyToImage;
  bool get applyToBackground => _applyToBackground;
  double get intensity => _intensity;
  double get frequency => _frequency;
  double get amplitude => _amplitude;
  double get complexity => _complexity;
  double get speed => _speed;
  double get colorIntensity => _colorIntensity;
  bool get audioReactive => _audioReactive;
  double get audioSensitivity => _audioSensitivity;
  bool get cymaticsAnimated => _cymaticsAnimated;
  AnimationOptions get animOptions => _animOptions;

  // Setters with change notification
  set cymaticsEnabled(bool value) {
    if (_cymaticsEnabled != value) {
      _cymaticsEnabled = value;
      if (enableLogging) print("SETTINGS: Cymatics enabled set to $value");
      notifyListeners();
    }
  }

  set applyToText(bool value) {
    if (_applyToText != value) {
      _applyToText = value;
      if (enableLogging)
        print("SETTINGS: Apply cymatics to text set to $value");
      notifyListeners();
    }
  }

  set applyToImage(bool value) {
    if (_applyToImage != value) {
      _applyToImage = value;
      if (enableLogging)
        print("SETTINGS: Apply cymatics to image set to $value");
      notifyListeners();
    }
  }

  set applyToBackground(bool value) {
    if (_applyToBackground != value) {
      _applyToBackground = value;
      if (enableLogging)
        print("SETTINGS: Apply cymatics to background set to $value");
      notifyListeners();
    }
  }

  set intensity(double value) {
    if (_intensity != value) {
      _intensity = value.clamp(0.0, 1.0);
      if (enableLogging) print("SETTINGS: Cymatics intensity set to $value");
      notifyListeners();
    }
  }

  set frequency(double value) {
    if (_frequency != value) {
      _frequency = value.clamp(0.0, 1.0);
      if (enableLogging) print("SETTINGS: Cymatics frequency set to $value");
      notifyListeners();
    }
  }

  set amplitude(double value) {
    if (_amplitude != value) {
      _amplitude = value.clamp(0.0, 1.0);
      if (enableLogging) print("SETTINGS: Cymatics amplitude set to $value");
      notifyListeners();
    }
  }

  set complexity(double value) {
    if (_complexity != value) {
      _complexity = value.clamp(0.0, 1.0);
      if (enableLogging) print("SETTINGS: Cymatics complexity set to $value");
      notifyListeners();
    }
  }

  set speed(double value) {
    if (_speed != value) {
      _speed = value.clamp(0.0, 1.0);
      if (enableLogging) print("SETTINGS: Cymatics speed set to $value");
      notifyListeners();
    }
  }

  set colorIntensity(double value) {
    if (_colorIntensity != value) {
      _colorIntensity = value.clamp(0.0, 1.0);
      if (enableLogging)
        print("SETTINGS: Cymatics color intensity set to $value");
      notifyListeners();
    }
  }

  set audioReactive(bool value) {
    if (_audioReactive != value) {
      _audioReactive = value;
      if (enableLogging)
        print("SETTINGS: Cymatics audio reactive set to $value");
      notifyListeners();
    }
  }

  set audioSensitivity(double value) {
    if (_audioSensitivity != value) {
      _audioSensitivity = value.clamp(0.0, 1.0);
      if (enableLogging)
        print("SETTINGS: Cymatics audio sensitivity set to $value");
      notifyListeners();
    }
  }

  set cymaticsAnimated(bool value) {
    if (_cymaticsAnimated != value) {
      _cymaticsAnimated = value;
      if (enableLogging) print("SETTINGS: Cymatics animation set to $value");
      notifyListeners();
    }
  }

  set animOptions(AnimationOptions value) {
    _animOptions = value;
    if (enableLogging) print("SETTINGS: Cymatics animation options updated");
    notifyListeners();
  }

  // Constructor
  CymaticsSettings({
    bool cymaticsEnabled = false,
    bool applyToText = false,
    bool applyToImage = true,
    bool applyToBackground = true,
    double intensity = 0.5,
    double frequency = 0.5,
    double amplitude = 0.5,
    double complexity = 0.5,
    double speed = 0.5,
    double colorIntensity = 0.5,
    bool audioReactive = true,
    double audioSensitivity = 0.7,
    bool cymaticsAnimated = false,
    AnimationOptions? animOptions,
  }) : _cymaticsEnabled = cymaticsEnabled,
       _applyToText = applyToText,
       _applyToImage = applyToImage,
       _applyToBackground = applyToBackground,
       _intensity = intensity,
       _frequency = frequency,
       _amplitude = amplitude,
       _complexity = complexity,
       _speed = speed,
       _colorIntensity = colorIntensity,
       _audioReactive = audioReactive,
       _audioSensitivity = audioSensitivity,
       _cymaticsAnimated = cymaticsAnimated,
       _animOptions = animOptions ?? AnimationOptions();

  // Serialization methods
  Map<String, dynamic> toMap() {
    return {
      'cymaticsEnabled': _cymaticsEnabled,
      'applyToText': _applyToText,
      'applyToImage': _applyToImage,
      'applyToBackground': _applyToBackground,
      'intensity': _intensity,
      'frequency': _frequency,
      'amplitude': _amplitude,
      'complexity': _complexity,
      'speed': _speed,
      'colorIntensity': _colorIntensity,
      'audioReactive': _audioReactive,
      'audioSensitivity': _audioSensitivity,
      'cymaticsAnimated': _cymaticsAnimated,
      'animOptions': _animOptions.toMap(),
    };
  }

  factory CymaticsSettings.fromMap(Map<String, dynamic> map) {
    return CymaticsSettings(
      cymaticsEnabled: map['cymaticsEnabled'] ?? false,
      applyToText: map['applyToText'] ?? false,
      applyToImage: map['applyToImage'] ?? true,
      applyToBackground: map['applyToBackground'] ?? true,
      intensity: map['intensity'] ?? 0.5,
      frequency: map['frequency'] ?? 0.5,
      amplitude: map['amplitude'] ?? 0.5,
      complexity: map['complexity'] ?? 0.5,
      speed: map['speed'] ?? 0.5,
      colorIntensity: map['colorIntensity'] ?? 0.5,
      audioReactive: map['audioReactive'] ?? true,
      audioSensitivity: map['audioSensitivity'] ?? 0.7,
      cymaticsAnimated: map['cymaticsAnimated'] ?? false,
      animOptions: map['animOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['animOptions']),
            )
          : null,
    );
  }

  // Create a copy with the same values
  CymaticsSettings copy() {
    return CymaticsSettings(
      cymaticsEnabled: _cymaticsEnabled,
      applyToText: _applyToText,
      applyToImage: _applyToImage,
      applyToBackground: _applyToBackground,
      intensity: _intensity,
      frequency: _frequency,
      amplitude: _amplitude,
      complexity: _complexity,
      speed: _speed,
      colorIntensity: _colorIntensity,
      audioReactive: _audioReactive,
      audioSensitivity: _audioSensitivity,
      cymaticsAnimated: _cymaticsAnimated,
      animOptions: _animOptions.copyWith(),
    );
  }
}
