import 'package:flutter/foundation.dart';
import 'animation_options.dart';

class MusicSettings extends ChangeNotifier {
  // Control flags
  bool _musicEnabled = false;
  String _currentTrack = '';
  double _volume = 0.8;
  bool _loop = false;
  bool _autoplay = true;
  double _playbackPosition = 0.0;
  double _duration = 0.0;
  bool _isPlaying = false;

  // Animation flag
  bool _musicAnimated = false;
  AnimationOptions _musicAnimOptions = AnimationOptions();

  // Logging flag
  static bool enableLogging = true;

  // Getters
  bool get musicEnabled => _musicEnabled;
  String get currentTrack => _currentTrack;
  double get volume => _volume;
  bool get loop => _loop;
  bool get autoplay => _autoplay;
  double get playbackPosition => _playbackPosition;
  double get duration => _duration;
  bool get isPlaying => _isPlaying;
  bool get musicAnimated => _musicAnimated;
  AnimationOptions get musicAnimOptions => _musicAnimOptions;

  // Setters
  set musicEnabled(bool value) {
    if (_musicEnabled != value) {
      _musicEnabled = value;
      if (enableLogging) print("SETTINGS: Music enabled set to $value");
      notifyListeners();
    }
  }

  set currentTrack(String value) {
    if (_currentTrack != value) {
      _currentTrack = value;
      if (enableLogging) print("SETTINGS: Current track set to $value");
      notifyListeners();
    }
  }

  set volume(double value) {
    if (_volume != value) {
      _volume = value.clamp(0.0, 1.0);
      if (enableLogging) print("SETTINGS: Volume set to $value");
      notifyListeners();
    }
  }

  set loop(bool value) {
    if (_loop != value) {
      _loop = value;
      if (enableLogging) print("SETTINGS: Loop set to $value");
      notifyListeners();
    }
  }

  set autoplay(bool value) {
    if (_autoplay != value) {
      _autoplay = value;
      if (enableLogging) print("SETTINGS: Autoplay set to $value");
      notifyListeners();
    }
  }

  set playbackPosition(double value) {
    if (_playbackPosition != value) {
      _playbackPosition = value;
      // Notify listeners for position updates
      // This is necessary for the UI to reflect position changes
      notifyListeners();
    }
  }

  set duration(double value) {
    if (_duration != value) {
      _duration = value;
      if (enableLogging) print("SETTINGS: Duration set to $value");
      notifyListeners();
    }
  }

  set isPlaying(bool value) {
    if (_isPlaying != value) {
      _isPlaying = value;
      if (enableLogging) print("SETTINGS: Playing state set to $value");
      notifyListeners();
    }
  }

  set musicAnimated(bool value) {
    if (_musicAnimated != value) {
      _musicAnimated = value;
      if (enableLogging) print("SETTINGS: Music animation set to $value");
      notifyListeners();
    }
  }

  set musicAnimOptions(AnimationOptions value) {
    _musicAnimOptions = value;
    if (enableLogging) print("SETTINGS: Music animation options updated");
    notifyListeners();
  }

  // Force a notification to any listeners
  void forceNotify() {
    notifyListeners();
  }

  MusicSettings({
    bool musicEnabled = false,
    String currentTrack = '',
    double volume = 0.8,
    bool loop = false,
    bool autoplay = true,
    double playbackPosition = 0.0,
    double duration = 0.0,
    bool isPlaying = false,
    bool musicAnimated = false,
    AnimationOptions? musicAnimOptions,
  }) : _musicEnabled = musicEnabled,
       _currentTrack = currentTrack,
       _volume = volume,
       _loop = loop,
       _autoplay = autoplay,
       _playbackPosition = playbackPosition,
       _duration = duration,
       _isPlaying = isPlaying,
       _musicAnimated = musicAnimated,
       _musicAnimOptions = musicAnimOptions ?? AnimationOptions();

  // Serialization methods
  Map<String, dynamic> toMap() {
    return {
      'musicEnabled': _musicEnabled,
      'currentTrack': _currentTrack,
      'volume': _volume,
      'loop': _loop,
      'autoplay': _autoplay,
      'musicAnimated': _musicAnimated,
      'musicAnimOptions': _musicAnimOptions.toMap(),
    };
  }

  factory MusicSettings.fromMap(Map<String, dynamic> map) {
    return MusicSettings(
      musicEnabled: map['musicEnabled'] ?? false,
      currentTrack: map['currentTrack'] ?? '',
      volume: map['volume'] ?? 0.8,
      loop: map['loop'] ?? false,
      autoplay: map['autoplay'] ?? true,
      musicAnimated: map['musicAnimated'] ?? false,
      musicAnimOptions: map['musicAnimOptions'] != null
          ? AnimationOptions.fromMap(
              Map<String, dynamic>.from(map['musicAnimOptions']),
            )
          : null,
    );
  }

  // Create a copy with the same values
  MusicSettings copy() {
    return MusicSettings(
      musicEnabled: _musicEnabled,
      currentTrack: _currentTrack,
      volume: _volume,
      loop: _loop,
      autoplay: _autoplay,
      playbackPosition: _playbackPosition,
      duration: _duration,
      isPlaying: _isPlaying,
      musicAnimated: _musicAnimated,
      musicAnimOptions: _musicAnimOptions.copyWith(),
    );
  }
}
