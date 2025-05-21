import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/effect_settings.dart';
import 'effect_controller.dart';

/// Controller for handling music playback in the shader demo app.
///
/// This controller integrates with the audioplayers package and keeps
/// the music settings model in sync with the actual audio playback state.
class MusicController {
  // Logging
  static const String _logTag = 'MusicController';
  static bool enableLogging = true;

  // Audio player instance
  late AudioPlayer _audioPlayer;

  // Track the current position with a stream subscription
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  // Callback to update settings
  Function(ShaderSettings) onSettingsChanged;

  // Reference to current settings
  ShaderSettings _settings;

  // Cache of available tracks
  List<String> _availableTracks = [];

  // Flag to prevent multiple initializations
  bool _initialized = false;

  // Private constructor to enforce singleton pattern
  MusicController._({
    required ShaderSettings settings,
    required this.onSettingsChanged,
  }) : _settings = settings {
    _initPlayer();
  }

  // Singleton instance
  static MusicController? _instance;

  // Factory constructor to get the singleton instance
  static MusicController getInstance({
    required ShaderSettings settings,
    required Function(ShaderSettings) onSettingsChanged,
  }) {
    if (_instance == null) {
      _instance = MusicController._(
        settings: settings,
        onSettingsChanged: onSettingsChanged,
      );
    } else {
      // Update the settings reference to ensure we have the latest
      _instance!._settings = settings;
      _instance!.onSettingsChanged = onSettingsChanged;
    }

    return _instance!;
  }

  // Initialize the audio player
  void _initPlayer() {
    if (_initialized) return;

    _log('Initializing audio player');
    _audioPlayer = AudioPlayer();

    // Set up position tracking
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
      updatedSettings.musicSettings.playbackPosition = position.inSeconds
          .toDouble();

      // Don't call the main onSettingsChanged as it would cause too many rebuilds
      // Instead, just update our local copy
      _settings = updatedSettings;
    });

    // Set up duration tracking
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
      updatedSettings.musicSettings.duration = duration.inSeconds.toDouble();
      onSettingsChanged(updatedSettings);
    });

    // Set up player state tracking
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
      updatedSettings.musicSettings.isPlaying = state == PlayerState.playing;
      onSettingsChanged(updatedSettings);

      _log('Player state changed to: $state');
    });

    // Set up completion listener
    _audioPlayer.onPlayerComplete.listen((_) {
      _log('Track completed');

      final updatedSettings = ShaderSettings.fromMap(_settings.toMap());

      // If loop is enabled, restart the same track
      if (updatedSettings.musicSettings.loop) {
        _log('Looping track: ${updatedSettings.musicSettings.currentTrack}');
        play(); // Will restart the current track
      } else {
        // Otherwise, move to the next track if available
        final currentIndex = _availableTracks.indexOf(
          updatedSettings.musicSettings.currentTrack,
        );
        if (currentIndex < _availableTracks.length - 1) {
          final nextTrack = _availableTracks[currentIndex + 1];
          _log('Auto-advancing to next track: $nextTrack');

          updatedSettings.musicSettings.currentTrack = nextTrack;
          onSettingsChanged(updatedSettings);

          // Play the next track if autoplay is enabled
          if (updatedSettings.musicSettings.autoplay) {
            play();
          }
        } else {
          // We've reached the end of the playlist
          _log('End of playlist reached');
          updatedSettings.musicSettings.isPlaying = false;
          onSettingsChanged(updatedSettings);
        }
      }
    });

    _initialized = true;
  }

  // Load music tracks from directory (can be assets or file system)
  Future<List<String>> loadTracks(String directory) async {
    _log('Loading tracks from directory: $directory');

    if (directory.startsWith('assets/')) {
      // Handle asset directory using AssetManifest
      _log('Loading from assets directory: $directory');

      try {
        // Load asset manifest to get all registered assets
        final manifestContent = await rootBundle.loadString(
          'AssetManifest.json',
        );
        final Map<String, dynamic> manifestMap = json.decode(manifestContent);

        // Get all assets that are in the target directory and are audio files
        _availableTracks = manifestMap.keys
            .where(
              (String key) =>
                  key.startsWith(directory) &&
                  (key.toLowerCase().endsWith('.mp3') ||
                      key.toLowerCase().endsWith('.m4a') ||
                      key.toLowerCase().endsWith('.wav') ||
                      key.toLowerCase().endsWith('.aac') ||
                      key.toLowerCase().endsWith('.ogg')),
            )
            .toList();

        // Sort the tracks by filename
        _availableTracks.sort();

        _log('Found ${_availableTracks.length} tracks in assets');
        return _availableTracks;
      } catch (e) {
        _log('Error loading tracks from assets: $e', level: LogLevel.error);
        return [];
      }
    } else {
      // Handle file system directory
      try {
        final dir = Directory(directory);
        if (!await dir.exists()) {
          _log('Directory does not exist: $directory', level: LogLevel.warning);
          return [];
        }

        _availableTracks = await dir
            .list()
            .where(
              (entity) =>
                  entity.path.toLowerCase().endsWith('.mp3') ||
                  entity.path.toLowerCase().endsWith('.wav') ||
                  entity.path.toLowerCase().endsWith('.aac') ||
                  entity.path.toLowerCase().endsWith('.ogg'),
            )
            .map((file) => file.path)
            .toList();

        _log('Found ${_availableTracks.length} tracks');
        return _availableTracks;
      } catch (e) {
        _log('Error loading tracks: $e', level: LogLevel.error);
        return [];
      }
    }
  }

  // Play/resume current track
  Future<void> play() async {
    // Check if music is enabled at all before attempting to play
    if (!_settings.musicEnabled) {
      _log('Music is disabled, cannot play', level: LogLevel.warning);
      return;
    }

    final trackPath = _settings.musicSettings.currentTrack;

    // Double check track path
    if (trackPath.isEmpty) {
      _log('No track selected, cannot play', level: LogLevel.warning);
      _log(
        'Current settings track: ${_settings.musicSettings.currentTrack}',
        level: LogLevel.warning,
      );
      return;
    }

    _log('Play requested for track: $trackPath', level: LogLevel.info);

    try {
      _log('Playing track: $trackPath');

      // Set volume before playing
      await _audioPlayer.setVolume(_settings.musicSettings.volume);
      _log('Set volume to: ${_settings.musicSettings.volume}');

      // Always create a new source to ensure clean playback
      Source source;
      if (trackPath.startsWith('http')) {
        _log('Creating URL source for track: $trackPath');
        source = UrlSource(trackPath);
      } else if (trackPath.startsWith('assets/')) {
        final assetPath = trackPath.replaceFirst('assets/', '');
        _log('Creating asset source for track: $assetPath');
        source = AssetSource(assetPath);
      } else {
        _log('Creating file source for track: $trackPath');
        source = DeviceFileSource(trackPath);
      }

      // Stop any current playback before starting new
      try {
        await _audioPlayer.stop();
      } catch (e) {
        _log('Error stopping before play: $e', level: LogLevel.warning);
        // Continue anyway
      }

      _log('Playing audio with new source');
      await _audioPlayer.play(source);

      // Update settings
      final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
      updatedSettings.musicSettings.isPlaying = true;
      onSettingsChanged(updatedSettings);

      _log('Successfully started playback for track: $trackPath');
    } catch (e) {
      _log('Error playing track: $e', level: LogLevel.error);

      // Try to provide more info about what might have gone wrong
      if (trackPath.startsWith('assets/')) {
        _log(
          'Note: For asset paths, make sure the asset is included in pubspec.yaml',
          level: LogLevel.warning,
        );
      }

      // Make sure isPlaying is false if playing failed
      final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
      updatedSettings.musicSettings.isPlaying = false;
      onSettingsChanged(updatedSettings);
    }
  }

  // Pause playback
  Future<void> pause() async {
    _log('Pausing playback');
    try {
      // First pause the player to stop sound
      await _audioPlayer.pause();

      // Then also stop to ensure complete cancellation of playback
      // This helps for cases where pause doesn't completely work
      try {
        await _audioPlayer.stop();
      } catch (e) {
        _log(
          'Error stopping playback after pause: $e',
          level: LogLevel.warning,
        );
        // Continue anyway
      }

      // Update settings
      final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
      updatedSettings.musicSettings.isPlaying = false;
      onSettingsChanged(updatedSettings);

      _log('Successfully paused/stopped playback');
    } catch (e) {
      _log('Error pausing playback: $e', level: LogLevel.error);

      // Still try to update the UI state even if the pause failed
      final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
      updatedSettings.musicSettings.isPlaying = false;
      onSettingsChanged(updatedSettings);
    }
  }

  // Stop playback
  Future<void> stop() async {
    _log('Stopping playback');
    try {
      await _audioPlayer.stop();

      // Update settings
      final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
      updatedSettings.musicSettings.isPlaying = false;
      updatedSettings.musicSettings.playbackPosition = 0;
      onSettingsChanged(updatedSettings);
    } catch (e) {
      _log('Error stopping playback: $e', level: LogLevel.error);
    }
  }

  // Seek to position
  Future<void> seek(double positionInSeconds) async {
    _log('Seeking to position: $positionInSeconds seconds');
    try {
      // Ensure we're seeking to a valid position
      final double duration = _settings.musicSettings.duration;
      if (duration <= 0) {
        _log('Cannot seek - duration is unknown', level: LogLevel.warning);
        return;
      }

      // Clamp to valid range
      positionInSeconds = positionInSeconds.clamp(0, duration);

      // Apply seek to the audio player
      await _audioPlayer.seek(Duration(seconds: positionInSeconds.round()));
      _log('Seek successfully to $positionInSeconds seconds');

      // Update the position in settings immediately
      final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
      updatedSettings.musicSettings.playbackPosition = positionInSeconds;

      // Store locally first
      _settings = updatedSettings;
      onSettingsChanged(updatedSettings);
    } catch (e) {
      _log('Error seeking: $e', level: LogLevel.error);
    }
  }

  // Change volume
  Future<void> setVolume(double volume) async {
    _log('Setting volume to: $volume');
    try {
      // Make sure volume is in valid range
      volume = volume.clamp(0.0, 1.0);

      // Apply volume immediately to the audio player
      await _audioPlayer.setVolume(volume);
      _log('Volume set successfully to $volume');

      // Update settings
      final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
      updatedSettings.musicSettings.volume = volume;

      // Store locally first to ensure it's reflected
      _settings = updatedSettings;
      onSettingsChanged(updatedSettings);
    } catch (e) {
      _log('Error setting volume: $e', level: LogLevel.error);
    }
  }

  // Handle track selection
  Future<void> selectTrack(String trackPath) async {
    _log('Selecting track: $trackPath', level: LogLevel.info);

    // Verify the track path is not empty
    if (trackPath.isEmpty) {
      _log('Empty track path provided', level: LogLevel.warning);
      return;
    }

    // Check if we're already playing this track
    final bool sameTrack = _settings.musicSettings.currentTrack == trackPath;
    final bool wasPlaying = _settings.musicSettings.isPlaying;

    // Always stop any current playback to ensure clean state
    try {
      _log('Stopping any current playback before selecting new track');
      await _audioPlayer.stop();
      // Small delay to ensure audio system is ready
      await Future.delayed(Duration(milliseconds: 50));
    } catch (e) {
      _log('Error stopping current track: $e', level: LogLevel.warning);
      // Continue anyway as we're trying to play a new track
    }

    // Update settings - this is critical for track selection to persist
    final updatedSettings = ShaderSettings.fromMap(_settings.toMap());

    // Always update settings
    updatedSettings.musicSettings.currentTrack = trackPath;
    updatedSettings.musicSettings.playbackPosition = 0;
    updatedSettings.musicSettings.duration = 0;

    // Only set isPlaying to false if we're changing tracks
    // If it's the same track and was playing, we'll restart it
    updatedSettings.musicSettings.isPlaying = false;

    // Store the changes locally and notify listeners
    _settings = updatedSettings;
    onSettingsChanged(updatedSettings);

    _log(
      'Track selected successfully, current track is now: ${_settings.musicSettings.currentTrack}',
    );

    // Only try to play if music is enabled
    if (!_settings.musicEnabled) {
      _log(
        'Music is disabled, track selected but not playing',
        level: LogLevel.info,
      );
      return;
    }

    // Now try to play the track if it should be playing
    // (either it was playing before, or it's a new track and autoplay is enabled)
    if (wasPlaying || (!sameTrack && _settings.musicSettings.autoplay)) {
      try {
        _log('Attempting to play track: $trackPath');
        // Short delay to ensure UI updates before playback starts
        await Future.delayed(Duration(milliseconds: 100));

        // Set isPlaying to true before playing to ensure UI reflects correct state
        final playSettings = ShaderSettings.fromMap(_settings.toMap());
        playSettings.musicSettings.isPlaying = true;
        _settings = playSettings;
        onSettingsChanged(playSettings);

        // Now actually play
        await play();
      } catch (e) {
        _log('Error playing track after selection: $e', level: LogLevel.error);

        // If play fails, make sure isPlaying is reset to false
        final failedSettings = ShaderSettings.fromMap(_settings.toMap());
        failedSettings.musicSettings.isPlaying = false;
        _settings = failedSettings;
        onSettingsChanged(failedSettings);
      }
    }
  }

  // Skip to next track
  Future<void> nextTrack() async {
    _log('Skipping to next track');

    final currentTrack = _settings.musicSettings.currentTrack;
    final currentIndex = _availableTracks.indexOf(currentTrack);

    if (currentIndex < 0 || currentIndex >= _availableTracks.length - 1) {
      _log('No next track available', level: LogLevel.warning);
      return;
    }

    final nextTrack = _availableTracks[currentIndex + 1];
    await selectTrack(nextTrack);
  }

  // Skip to previous track
  Future<void> previousTrack() async {
    _log('Skipping to previous track');

    final currentTrack = _settings.musicSettings.currentTrack;
    final currentIndex = _availableTracks.indexOf(currentTrack);

    if (currentIndex <= 0) {
      _log('No previous track available', level: LogLevel.warning);
      return;
    }

    final prevTrack = _availableTracks[currentIndex - 1];
    await selectTrack(prevTrack);
  }

  // Toggle loop mode
  void toggleLoop() {
    _log('Toggling loop mode');

    final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
    updatedSettings.musicSettings.loop = !updatedSettings.musicSettings.loop;
    onSettingsChanged(updatedSettings);
  }

  // Toggle autoplay mode
  void toggleAutoplay() {
    _log('Toggling autoplay mode');

    final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
    updatedSettings.musicSettings.autoplay =
        !updatedSettings.musicSettings.autoplay;
    onSettingsChanged(updatedSettings);
  }

  // Cleanup resources
  void dispose() {
    _log('Disposing music controller');

    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();

    _initialized = false;
    _instance = null;
  }

  // Logging helper
  void _log(String message, {LogLevel level = LogLevel.info}) {
    if (!enableLogging) return;

    EffectLogger.log('[$_logTag] $message', level: level);
  }

  // Check if a track is selected
  bool hasTrackSelected() {
    return _settings.musicSettings.currentTrack.isNotEmpty;
  }

  // Get the current track path
  String get currentTrack => _settings.musicSettings.currentTrack;

  // Getter for available tracks
  List<String> get availableTracks => _availableTracks;

  // Get the current music enabled state
  bool getMusicEnabledState() {
    return _settings.musicEnabled;
  }

  // Check if music is currently playing
  bool isPlaying() {
    return _settings.musicSettings.isPlaying;
  }

  // Get a copy of the current settings
  ShaderSettings getCurrentSettings() {
    return ShaderSettings.fromMap(_settings.toMap());
  }

  // Update track selection without playing it
  void updateTrackWithoutPlaying(String track) {
    _log('Updating track without playing: $track');

    if (track.isEmpty) {
      _log('Empty track path provided', level: LogLevel.warning);
      return;
    }

    // Update the track selection in settings without playing
    final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
    updatedSettings.musicSettings.currentTrack = track;
    updatedSettings.musicSettings.isPlaying = false;

    // Update local state and notify listeners
    _settings = updatedSettings;
    onSettingsChanged(updatedSettings);
  }
}
