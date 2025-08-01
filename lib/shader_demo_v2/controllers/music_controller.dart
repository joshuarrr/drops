import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../models/effect_settings.dart';
import '../services/audio_analyzer_service.dart';
import 'effect_controller.dart';

/// Controller for handling music playback in the shader demo app.
///
/// This controller integrates with the audioplayers package and keeps
/// the music settings model in sync with the actual audio playback state.
class MusicController with WidgetsBindingObserver {
  // Logging
  static const String _logTag = 'MusicController';
  static bool enableLogging = false;

  // Audio player instance
  late AudioPlayer _audioPlayer;

  // Store current source to avoid recreating it unnecessarily
  Source? _currentSource;

  // Audio analyzer for frequency analysis
  late AudioAnalyzerService _audioAnalyzer;

  // Track the current position with a stream subscriptions
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  Timer? _positionTimer;

  // Callback to update settings
  Function(ShaderSettings) onSettingsChanged;

  // Reference to current settings
  ShaderSettings _settings;

  // Cache of available tracks
  List<String> _availableTracks = [];

  // Flag to prevent multiple initializations
  bool _initialized = false;

  // A simple cache of durations discovered at runtime
  // This is NOT hardcoded - it's populated dynamically as tracks are loaded
  final Map<String, double> _durationCache = {};

  // Private constructor to enforce singleton pattern
  MusicController._({
    required ShaderSettings settings,
    required this.onSettingsChanged,
  }) : _settings = settings {
    _initPlayer();
    // Register for app lifecycle events
    WidgetsBinding.instance.addObserver(this);
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

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _log('App lifecycle state changed to: $state', level: LogLevel.info);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // App is in background or being restarted, stop playback
        _stopAndSavePlaybackState();
        break;
      case AppLifecycleState.resumed:
        // App resumed, optionally restore playback if needed
        // (Leaving this empty to prevent auto-resuming on app restart)
        break;
      case AppLifecycleState.inactive:
        // App is inactive but still visible
        break;
    }
  }

  // Stop playback and save current state
  void _stopAndSavePlaybackState() {
    _log('Stopping playback due to app lifecycle change', level: LogLevel.info);

    if (_audioPlayer.state == PlayerState.playing) {
      // Save current position before stopping
      _audioPlayer
          .getCurrentPosition()
          .then((position) {
            if (position != null) {
              final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
              updatedSettings.musicSettings.playbackPosition = position
                  .inSeconds
                  .toDouble();
              updatedSettings.musicSettings.isPlaying = false;
              _settings = updatedSettings;
              onSettingsChanged(updatedSettings);

              // Now stop the player
              _audioPlayer.stop();
            }
          })
          .catchError((_) {
            // If we can't get position, just stop
            _audioPlayer.stop();
          });
    }
  }

  // Initialize the audio player
  void _initPlayer() {
    if (_initialized) return;

    _log('Initializing audio player');
    _audioPlayer = AudioPlayer();

    // Initialize audio analyzer
    _audioAnalyzer = AudioAnalyzerService.getInstance();
    _audioAnalyzer.initialize();

    // Configure audio context for better control across platforms
    _configureAudioContext();

    // Set release mode to stop (better performance than release)
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    // Use event-based position updates instead of polling timer
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (_audioPlayer.state == PlayerState.playing) {
        // Only update if position changed by at least 1 second to reduce UI churn
        final currentPosition = position.inSeconds.toDouble();
        final lastPosition = _settings.musicSettings.playbackPosition;

        if ((currentPosition - lastPosition).abs() >= 1.0) {
          // Update position directly without recreating settings object
          _settings.musicSettings.playbackPosition = currentPosition;

          // Update audio analyzer with current position and playing state
          _audioAnalyzer.updateAudioPosition(currentPosition, true);

          // Ensure state synchronization
          if (_settings.musicSettings.isPlaying != true) {
            _settings.musicSettings.isPlaying = true;
            // Only trigger full rebuild when playing state changes, not for position updates
            onSettingsChanged(_settings);
          }

          // For position-only updates, don't trigger full shader rebuilds
          // The music panel will update via its own listener in MusicSettings
        }
      }
    });

    // Set up duration tracking - much simpler now
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (duration.inSeconds > 0) {
        // PERFORMANCE FIX: Use direct mutation instead of expensive fromMap/toMap recreation
        final currentDuration = _settings.musicSettings.duration;
        final newDuration = duration.inSeconds.toDouble();

        // Only update if we don't already have a duration or if it's significantly different
        if (currentDuration <= 0 ||
            (currentDuration - newDuration).abs() > 1.0) {
          // Direct mutation - no object recreation!
          _settings.musicSettings.duration = newDuration;

          // Only log duration when we first discover it, not on every update
          _log('Set duration: ${duration.inSeconds}s', level: LogLevel.info);

          // Add to duration cache to avoid redundant lookups
          if (_settings.musicSettings.currentTrack.isNotEmpty) {
            _durationCache[_settings.musicSettings.currentTrack] = newDuration;
          }

          // Only call onSettingsChanged if this is the first time we're setting duration
          if (currentDuration <= 0) {
            onSettingsChanged(_settings);
          }
        }
      }
    });

    // Set up player state tracking with better synchronization
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
      state,
    ) {
      final bool playing = state == PlayerState.playing;

      // Only update if there's an actual state change
      if (_settings.musicSettings.isPlaying != playing) {
        // Log state changes less frequently
        _log('Player state changed to: $state', level: LogLevel.info);

        // Direct mutation - no object recreation!
        _settings.musicSettings.isPlaying = playing;
        onSettingsChanged(_settings);

        // Update audio analyzer playing state
        _audioPlayer
            .getCurrentPosition()
            .then((position) {
              if (position != null) {
                _audioAnalyzer.updateAudioPosition(
                  position.inSeconds.toDouble(),
                  playing,
                );
              }
            })
            .catchError((_) {
              // If we can't get position, still update playing state with current position
              _audioAnalyzer.updateAudioPosition(
                _settings.musicSettings.playbackPosition,
                playing,
              );
            });
      }
    });

    // Set up completion listener
    _audioPlayer.onPlayerComplete.listen((_) {
      _log('Track completed');

      // PERFORMANCE FIX: Direct access instead of expensive fromMap/toMap
      // If loop is enabled, restart the same track
      if (_settings.musicSettings.loop) {
        _log('Looping track: ${_settings.musicSettings.currentTrack}');
        play(); // Will restart the current track
      } else {
        // Otherwise, move to the next track if available
        final currentIndex = _availableTracks.indexOf(
          _settings.musicSettings.currentTrack,
        );
        if (currentIndex < _availableTracks.length - 1) {
          final nextTrack = _availableTracks[currentIndex + 1];
          _log('Auto-advancing to next track: $nextTrack');

          _settings.musicSettings.currentTrack = nextTrack;
          onSettingsChanged(_settings);

          // Play the next track if autoplay is enabled
          if (_settings.musicSettings.autoplay) {
            play();
          }
        } else {
          // We've reached the end of the playlist
          _log('End of playlist reached');
          _settings.musicSettings.isPlaying = false;
          onSettingsChanged(_settings);
        }
      }
    });

    _initialized = true;
  }

  // Configure the audio context for best performance across platforms
  void _configureAudioContext() {
    try {
      // Create platform-specific optimized audio context
      final audioContext = AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.media,
          audioFocus: AndroidAudioFocus.gain,
        ),
      );

      // Apply the audio context
      _audioPlayer.setAudioContext(audioContext);
      _log('Audio context configured successfully');
    } catch (e) {
      _log('Error configuring audio context: $e', level: LogLevel.warning);
      // Continue anyway as this is an optimization
    }
  }

  // Helper method to update duration
  Future<void> _updateDuration() async {
    final trackPath = _settings.musicSettings.currentTrack;
    if (trackPath.isEmpty) {
      return;
    }

    // Check if we have this duration in our runtime cache first
    if (_durationCache.containsKey(trackPath)) {
      final cachedDuration = _durationCache[trackPath]!;

      // Only update if the current duration is invalid
      if (_settings.musicSettings.duration <= 0) {
        // PERFORMANCE FIX: Direct mutation instead of expensive fromMap/toMap
        _settings.musicSettings.duration = cachedDuration;
        onSettingsChanged(_settings);
        _log('Using cached duration: ${cachedDuration}s', level: LogLevel.info);
      }
      return;
    }

    try {
      // First approach: Try getDuration directly
      Duration? duration = await _audioPlayer.getDuration();

      // If that fails, try a more forceful approach with a temporary player
      if (duration == null || duration.inSeconds <= 0) {
        _log(
          'Direct duration fetch failed, trying alternative methods',
          level: LogLevel.info,
        );

        // Create a temporary audio player just to get the duration
        final tempPlayer = AudioPlayer();

        try {
          Source source;
          if (trackPath.startsWith('http')) {
            source = UrlSource(trackPath);
          } else if (trackPath.startsWith('assets/')) {
            final assetPath = trackPath.replaceFirst('assets/', '');
            source = AssetSource(assetPath);
          } else {
            source = DeviceFileSource(trackPath);
          }

          // Set the source without playing
          await tempPlayer.setSource(source);

          // Use event listener instead of delay
          final completer = Completer<Duration?>();
          StreamSubscription? durationSub;

          durationSub = tempPlayer.onDurationChanged.listen((dur) {
            if (dur.inSeconds > 0) {
              durationSub?.cancel();
              completer.complete(dur);
            }
          });

          // Fallback timeout to prevent hanging
          Timer(const Duration(seconds: 2), () {
            if (!completer.isCompleted) {
              durationSub?.cancel();
              completer.complete(null);
            }
          });

          // Try to get duration
          duration = await completer.future ?? await tempPlayer.getDuration();

          // Clean up
          await tempPlayer.dispose();
        } catch (e) {
          _log('Error with temp player approach: $e', level: LogLevel.warning);
          // Clean up on error too
          await tempPlayer.dispose();
        }
      }

      // If we successfully got a duration
      if (duration != null && duration.inSeconds > 0) {
        final durationSeconds = duration.inSeconds.toDouble();

        // Cache the duration for future use
        _durationCache[trackPath] = durationSeconds;

        // PERFORMANCE FIX: Direct mutation instead of expensive fromMap/toMap
        _settings.musicSettings.duration = durationSeconds;
        onSettingsChanged(_settings);

        _log(
          'Successfully determined duration: ${durationSeconds}s',
          level: LogLevel.info,
        );
      } else {
        // If all else fails, use a conservative default
        // This is not ideal, but it's better than a hardcoded value per track
        final estimatedDuration = 240.0; // 4 minutes as a safe default

        _log(
          'Could not determine duration, using default (${estimatedDuration}s)',
          level: LogLevel.warning,
        );

        // PERFORMANCE FIX: Direct mutation instead of expensive fromMap/toMap
        _settings.musicSettings.duration = estimatedDuration;
        onSettingsChanged(_settings);
      }
    } catch (e) {
      _log('Error getting duration: $e', level: LogLevel.warning);

      // Last resort fallback
      final fallbackDuration = 240.0; // 4 minutes
      // PERFORMANCE FIX: Direct mutation instead of expensive fromMap/toMap
      _settings.musicSettings.duration = fallbackDuration;
      onSettingsChanged(_settings);
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

      // Update UI state first to show we're trying to play
      // PERFORMANCE FIX: Direct mutation instead of expensive fromMap/toMap
      final double existingDuration = _settings.musicSettings.duration;
      _settings.musicSettings.isPlaying = true;
      onSettingsChanged(_settings);

      // Set volume before playing
      await _audioPlayer.setVolume(_settings.musicSettings.volume);
      _log('Set volume to: ${_settings.musicSettings.volume}');

      // CRITICAL FIX: Force reset _currentSource if source doesn't match track
      if (_currentSource == null ||
          (_currentSource.toString() != trackPath &&
              !_currentSource.toString().contains(
                trackPath.replaceFirst('assets/', ''),
              ))) {
        _currentSource = null;
      }

      // Check if we need to create a new source
      Source? source = _currentSource;
      if (source == null) {
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
        _currentSource = source;
      }

      // Only stop if we need to restart playback
      if (_audioPlayer.state != PlayerState.paused) {
        try {
          await _audioPlayer.stop();
        } catch (e) {
          _log('Error stopping before play: $e', level: LogLevel.warning);
          // Continue anyway
        }
      }

      _log('Playing audio with source');
      await _audioPlayer.play(source);

      // Preserve existing duration if available
      if (existingDuration > 0) {
        // Duration is already set, just ensure playing state is correct
        _settings.musicSettings.isPlaying = true;
        _log(
          'Preserved existing duration: ${existingDuration}s',
          level: LogLevel.info,
        );
      } else {
        // If we don't have a duration yet, we need to get it
        _updateDuration();
      }

      // The position stream listener will handle position updates automatically
      // No need for artificial delays - event-driven approach is more efficient

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
      // PERFORMANCE FIX: Direct mutation instead of expensive fromMap/toMap
      _settings.musicSettings.isPlaying = false;
      onSettingsChanged(_settings);
    }
  }

  // Pause playback
  Future<void> pause() async {
    _log('Pausing playback');
    try {
      // Get position before pausing to ensure we have the latest
      final position = await _audioPlayer.getCurrentPosition();

      // Pause the audio
      await _audioPlayer.pause();

      // Update settings with final position
      final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
      updatedSettings.musicSettings.isPlaying = false;

      // If we got a valid position, use it
      if (position != null) {
        _log('Final position before pause: ${position.inSeconds}s');
        updatedSettings.musicSettings.playbackPosition = position.inSeconds
            .toDouble();
      }

      // Update settings
      _settings = updatedSettings;
      onSettingsChanged(updatedSettings);

      _log('Successfully paused playback');
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

      // If we don't have a duration yet, check known durations
      if (duration <= 0) {
        final trackPath = _settings.musicSettings.currentTrack;

        // Check if we have a known duration for this track
        if (_durationCache.containsKey(trackPath)) {
          final knownDuration = _durationCache[trackPath]!;

          // Update the duration
          final updatedDurationSettings = ShaderSettings.fromMap(
            _settings.toMap(),
          );
          updatedDurationSettings.musicSettings.duration = knownDuration;
          _settings = updatedDurationSettings;
          onSettingsChanged(updatedDurationSettings);

          _log(
            'Using known duration for seek: ${knownDuration}s',
            level: LogLevel.info,
          );
        } else {
          _log('Cannot seek - duration is unknown', level: LogLevel.warning);
          return;
        }
      }

      // Now use the updated duration
      final finalDuration = _settings.musicSettings.duration;

      // Clamp to valid range
      positionInSeconds = positionInSeconds.clamp(0, finalDuration);

      // Update the position in settings before seeking
      final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
      updatedSettings.musicSettings.playbackPosition = positionInSeconds;
      _settings = updatedSettings;
      onSettingsChanged(updatedSettings);

      // Apply seek to the audio player
      await _audioPlayer.seek(Duration(seconds: positionInSeconds.round()));
      _log('Seek successful to $positionInSeconds seconds');

      // Get the actual position right after seeking for verification
      final actualPosition = await _audioPlayer.getCurrentPosition();
      if (actualPosition != null) {
        _log(
          'Actual position after seek: ${actualPosition.inSeconds}s',
          level: LogLevel.info,
        );

        // If the position is significantly different from what we expected,
        // update the UI again with the actual position
        if ((actualPosition.inSeconds - positionInSeconds).abs() > 2) {
          final verifySettings = ShaderSettings.fromMap(_settings.toMap());
          verifySettings.musicSettings.playbackPosition = actualPosition
              .inSeconds
              .toDouble();
          _settings = verifySettings;
          onSettingsChanged(verifySettings);
        }
      }
    } catch (e) {
      _log('Error seeking: $e', level: LogLevel.error);
    }
  }

  // Add a new method to get final position when paused
  Future<void> _updatePositionOnPause() async {
    try {
      final position = await _audioPlayer.getCurrentPosition();
      if (position != null) {
        _log(
          'Final position update on pause: ${position.inSeconds}s',
          level: LogLevel.info,
        );

        final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
        updatedSettings.musicSettings.playbackPosition = position.inSeconds
            .toDouble();
        updatedSettings.musicSettings.isPlaying =
            false; // Ensure this is false when paused
        _settings = updatedSettings;
        onSettingsChanged(updatedSettings);
      }
    } catch (e) {
      _log(
        'Error getting final position on pause: $e',
        level: LogLevel.warning,
      );
    }
  }

  // Get detailed debug information about the player state
  Map<String, dynamic> getDebugInfo() {
    final currentTrackPath = _settings.musicSettings.currentTrack;

    Map<String, dynamic> info = {
      'player_id': _audioPlayer.playerId,
      'player_state': _audioPlayer.state.toString(),
      'current_source': _currentSource?.toString() ?? 'null',
      'settings_is_playing': _settings.musicSettings.isPlaying,
      'settings_duration': _settings.musicSettings.duration,
      'settings_position': _settings.musicSettings.playbackPosition,
      'settings_track': currentTrackPath,
      'enabled': _settings.musicEnabled,
      'initialized': _initialized,
    };

    // Add known track duration if available
    if (currentTrackPath.isNotEmpty &&
        _durationCache.containsKey(currentTrackPath)) {
      info['known_duration'] = _durationCache[currentTrackPath];
    }

    // Try to get additional player information that might fail
    try {
      info['volume'] = _audioPlayer.volume;
    } catch (e) {
      info['volume_error'] = e.toString();
    }

    try {
      info['release_mode'] = _audioPlayer.releaseMode.toString();
    } catch (e) {
      info['release_mode_error'] = e.toString();
    }

    // Add current position from player if possible
    try {
      _audioPlayer
          .getCurrentPosition()
          .then((position) {
            if (position != null) {
              info['current_position'] = position.inSeconds;
            }
          })
          .catchError((e) {
            print('Error getting current position: $e');
          });
    } catch (e) {
      info['position_error'] = e.toString();
    }

    return info;
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

  // Properly dispose of resources
  void dispose() {
    _log('Disposing music controller', level: LogLevel.info);

    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    // Cancel position timer if it exists
    _positionTimer?.cancel();

    // Cancel all stream subscriptions
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();

    // Stop and release the audio player
    _audioPlayer.stop();
    _audioPlayer.release();
    _audioPlayer.dispose();

    // Reset singleton instance
    _instance = null;
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

      // PERFORMANCE FIX: Direct mutation instead of expensive fromMap/toMap
      _settings.musicSettings.volume = volume;
      onSettingsChanged(_settings);
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
      // Clear the current source if we're changing tracks
      if (!sameTrack) {
        _currentSource = null;
      }
    } catch (e) {
      _log('Error stopping current track: $e', level: LogLevel.warning);
      // Continue anyway as we're trying to play a new track
    }

    // Update settings - this is critical for track selection to persist
    final updatedSettings = ShaderSettings.fromMap(_settings.toMap());

    // Store the previous duration if it's the same track
    final double previousDuration = sameTrack
        ? updatedSettings.musicSettings.duration
        : 0.0;

    // Always update settings
    updatedSettings.musicSettings.currentTrack = trackPath;
    updatedSettings.musicSettings.playbackPosition = 0;

    // Don't reset duration to 0 unless we're changing tracks
    if (!sameTrack) {
      updatedSettings.musicSettings.duration = 0;
    } else {
      // Keep the previous duration to avoid UI flicker
      updatedSettings.musicSettings.duration = previousDuration;
    }

    // CRITICAL FIX: Make sure the isPlaying state is set to false until we actually start playing
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
        // CRITICAL FIX: Set isPlaying to true only after successful playback
        await play();
      } catch (e) {
        _log('Error playing track after selection: $e', level: LogLevel.error);

        // If play fails, make sure isPlaying is reset to false
        final failedSettings = ShaderSettings.fromMap(_settings.toMap());
        failedSettings.musicSettings.isPlaying = false;
        _settings = failedSettings;
        onSettingsChanged(failedSettings);
      }
    } else {
      // Even if we're not playing, try to get the duration for the track
      // to update the UI display of track length
      _updateDuration();
    }
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
    _log('Setting autoplay mode to true');

    final updatedSettings = ShaderSettings.fromMap(_settings.toMap());
    updatedSettings.musicSettings.autoplay = true; // Always set to true
    onSettingsChanged(updatedSettings);
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

    // Clear the current source since we changed tracks
    _currentSource = null;
  }

  // Manual position updater method removed - using event-driven approach only

  // Common method to update playback position
  void _updatePlaybackPosition(double positionSeconds) {
    if (positionSeconds <= 0) {
      return; // Skip zero/negative positions
    }

    final updatedSettings = ShaderSettings.fromMap(_settings.toMap());

    // Only update if the position actually changed by at least 0.5 seconds
    if ((updatedSettings.musicSettings.playbackPosition - positionSeconds)
            .abs() >=
        0.5) {
      // Keep a copy of the current duration to avoid losing it during position update
      final currentDuration = updatedSettings.musicSettings.duration;

      // Update position
      updatedSettings.musicSettings.playbackPosition = positionSeconds;

      // CRITICAL FIX: Make sure isPlaying state is correct with position update
      // If we're getting position updates, the player must be playing
      final bool currentlyPlaying = _audioPlayer.state == PlayerState.playing;
      if (currentlyPlaying && !updatedSettings.musicSettings.isPlaying) {
        // Silently fix the state without logging
        updatedSettings.musicSettings.isPlaying = true;
      }

      // Restore duration if we had it but position update would remove it
      if (currentDuration > 0 && updatedSettings.musicSettings.duration <= 0) {
        // Silently restore the duration without logging
        updatedSettings.musicSettings.duration = currentDuration;
      }

      // Update our local copy immediately for every position change
      _settings = updatedSettings;

      // Notify the UI when position changes to ensure the playback slider moves smoothly
      onSettingsChanged(updatedSettings);

      // If we still don't have a duration, try to get one
      // Only log this once to avoid spam by using a more severe log level
      if (_settings.musicSettings.duration <= 0) {
        // Just update duration silently without logging each time
        _updateDuration();
      }
    }
  }

  // Get current audio frequency data for shaders
  Map<String, double> getAudioFrequencyData() {
    return {
      'bassLevel': _audioAnalyzer.bassLevel,
      'midLevel': _audioAnalyzer.midLevel,
      'trebleLevel': _audioAnalyzer.trebleLevel,
    };
  }

  // Get individual frequency components
  double getBassLevel() => _audioAnalyzer.bassLevel;
  double getMidLevel() => _audioAnalyzer.midLevel;
  double getTrebleLevel() => _audioAnalyzer.trebleLevel;
}
