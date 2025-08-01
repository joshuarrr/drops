import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// Service for managing audio playback in the Cymatics Demo
class CymaticsAudioService {
  // Singleton instance
  static final CymaticsAudioService _instance =
      CymaticsAudioService._internal();
  factory CymaticsAudioService() => _instance;
  CymaticsAudioService._internal();

  // The audio player instance
  AudioPlayer? _audioPlayer;

  // Current state
  bool _isPlaying = false;
  String? _currentTrack;

  // Stream controllers for broadcasting state changes
  final _playerStateController = StreamController<PlayerState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _audioLevelsController = StreamController<List<double>>.broadcast();

  // Getters
  Stream<PlayerState> get onPlayerStateChanged => _playerStateController.stream;
  Stream<Duration> get onPositionChanged => _positionController.stream;
  Stream<List<double>> get onAudioLevelsChanged =>
      _audioLevelsController.stream;
  bool get isPlaying => _isPlaying;
  String? get currentTrack => _currentTrack;

  /// Initialize the audio service
  Future<void> initialize() async {
    // Create the audio player if it doesn't exist
    _audioPlayer ??= AudioPlayer();

    // Set up listeners
    _setupListeners();
  }

  /// Set up audio player listeners
  void _setupListeners() {
    // Clear any existing subscriptions
    _clearSubscriptions();

    _audioPlayer?.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      _playerStateController.add(state);
    });

    _audioPlayer?.onPositionChanged.listen((position) {
      _positionController.add(position);
    });

    _audioPlayer?.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _playerStateController.add(PlayerState.completed);
    });
  }

  /// Play a track from assets
  Future<void> playTrack(String trackName) async {
    if (_audioPlayer == null) {
      await initialize();
    }

    try {
      // Stop any currently playing audio
      await stop();

      // Set the current track
      _currentTrack = trackName;

      // Prepare the audio source
      final source = AssetSource('music/$trackName');

      // Play the track
      await _audioPlayer?.play(source);

      _isPlaying = true;
    } catch (e) {
      debugPrint('Error playing track: $e');
      // Reset player if error occurs
      _audioPlayer = AudioPlayer();
      _setupListeners();
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await _audioPlayer?.pause();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error pausing: $e');
    }
  }

  /// Resume playback
  Future<void> resume() async {
    try {
      if (_audioPlayer?.source != null) {
        await _audioPlayer?.resume();
        _isPlaying = true;
      } else if (_currentTrack != null) {
        // If no source, try to play the track again
        await playTrack(_currentTrack!);
      }
    } catch (e) {
      debugPrint('Error resuming: $e');
      // Try to replay the track
      if (_currentTrack != null) {
        await playTrack(_currentTrack!);
      }
    }
  }

  /// Stop playback
  Future<void> stop() async {
    try {
      await _audioPlayer?.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Error stopping: $e');
    }
  }

  /// Update audio levels based on the current position
  /// This would normally be done by analyzing the audio in real-time,
  /// but for the demo we'll use the generated frequency data
  void updateAudioLevels(List<double> levels) {
    _audioLevelsController.add(levels);
  }

  /// Get the current playback position
  Future<Duration> getPosition() async {
    try {
      return await _audioPlayer?.getCurrentPosition() ?? Duration.zero;
    } catch (e) {
      debugPrint('Error getting position: $e');
      return Duration.zero;
    }
  }

  /// Clear all subscriptions
  void _clearSubscriptions() {
    // Note: we don't need to explicitly cancel the subscriptions
    // as AudioPlayer handles this internally when setting up new listeners
  }

  /// Dispose the service
  void dispose() {
    _audioPlayer?.dispose();
    _audioPlayer = null;
    _isPlaying = false;
    _currentTrack = null;

    // Close stream controllers
    _playerStateController.close();
    _positionController.close();
    _audioLevelsController.close();
  }

  /// Static method to stop any playing audio
  static Future<void> stopAudio() async {
    if (_instance._isPlaying) {
      await _instance.stop();
    }
  }
}
