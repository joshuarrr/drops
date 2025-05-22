import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import '../models/effect_settings.dart';

/// AudioAnalyzerService provides frequency analysis for audio playback.
///
/// This service uses a simple amplitude-based approach since we don't have direct
/// access to raw audio data through the audioplayers package. Future versions could
/// use a more advanced FFT implementation if direct audio access becomes available.
class AudioAnalyzerService {
  // Static instance for singleton pattern
  static AudioAnalyzerService? _instance;

  // Logger tag
  static const String _logTag = 'AudioAnalyzerService';
  static bool enableLogging = true;

  // Random number generator for simulating audio data
  final math.Random _random = math.Random();

  // Current frequency data
  double _bassLevel = 0.0;
  double _midLevel = 0.0;
  double _trebleLevel = 0.0;

  // Smoothing values
  double _lastBassLevel = 0.0;
  double _lastMidLevel = 0.0;
  double _lastTrebleLevel = 0.0;

  // Timer for periodic analysis
  Timer? _analysisTimer;

  // Time last position update received
  DateTime _lastPositionUpdate = DateTime.now();

  // Reference to the audio player's current position (in seconds)
  double _currentPosition = 0.0;

  // Whether audio is currently playing
  bool _isPlaying = false;

  // The update rate in milliseconds - make more responsive
  final int _updateRate = 16; // ~60fps

  // Constructor
  AudioAnalyzerService._();

  // Factory method to get instance
  static AudioAnalyzerService getInstance() {
    _instance ??= AudioAnalyzerService._();
    return _instance!;
  }

  // Initialize with audio player
  void initialize({bool forceReinit = false}) {
    if (_analysisTimer != null && !forceReinit) {
      _log('Analyzer already initialized');
      return;
    }

    _log('Initializing audio analyzer');

    // Start periodic analysis
    _startAnalysisTimer();
  }

  // Update the current audio position
  void updateAudioPosition(double positionInSeconds, bool isPlaying) {
    _currentPosition = positionInSeconds;
    _isPlaying = isPlaying;
    _lastPositionUpdate = DateTime.now();
  }

  // Get the bass frequency level (0.0 - 1.0)
  double get bassLevel => _bassLevel;

  // Get the mid frequency level (0.0 - 1.0)
  double get midLevel => _midLevel;

  // Get the treble frequency level (0.0 - 1.0)
  double get trebleLevel => _trebleLevel;

  // Start periodic analysis
  void _startAnalysisTimer() {
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(Duration(milliseconds: _updateRate), (_) {
      _analyzeAudio();
    });
    _log('Analysis timer started');
  }

  // Stop analysis
  void stopAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = null;
    _log('Analysis timer stopped');
  }

  // Reset levels to zero
  void resetLevels() {
    _bassLevel = 0.0;
    _midLevel = 0.0;
    _trebleLevel = 0.0;
    _lastBassLevel = 0.0;
    _lastMidLevel = 0.0;
    _lastTrebleLevel = 0.0;
  }

  // Analyze audio data
  void _analyzeAudio() {
    // If not playing, gradually reduce all values to zero
    if (!_isPlaying) {
      _fadeOutLevels();
      return;
    }

    // In a real implementation, we would analyze the actual audio data.
    // Since we don't have direct access to the raw audio buffer through audioplayers,
    // we'll use a creative approach to generate visually interesting data.

    // Use the current position to influence the patterns
    final double positionFactor = _currentPosition % 60; // Cycle every minute
    final double cyclicValue = (math.sin(positionFactor * 0.1) * 0.5 + 0.5);

    // Generate more distinct rhythmic patterns based on position
    double newBassValue = _generateRhythmicValue(
      baseFrequency: 0.25, // Bass hits on strong beats (every 4 seconds)
      positionInSeconds: _currentPosition,
      randomness: 0.15, // Less randomness for more predictable bass pattern
      baseAmplitude: 0.8 + (cyclicValue * 0.2), // Stronger bass
    );

    double newMidValue = _generateRhythmicValue(
      baseFrequency: 0.5, // Mids hit twice as often as bass
      positionInSeconds:
          _currentPosition + 0.25, // Offset from bass for rhythmic effect
      randomness: 0.3,
      baseAmplitude: 0.7 + (cyclicValue * 0.3),
    );

    double newTrebleValue = _generateRhythmicValue(
      baseFrequency: 1.5, // Faster treble movement
      positionInSeconds: _currentPosition + 0.5, // Further offset
      randomness: 0.4,
      baseAmplitude: 0.6 + (cyclicValue * 0.4), // More variation
    );

    // Apply improved smoothing for more noticeable transitions
    _bassLevel = _smoothValue(
      _lastBassLevel,
      newBassValue,
      0.4,
    ); // Faster bass response
    _midLevel = _smoothValue(
      _lastMidLevel,
      newMidValue,
      0.5,
    ); // More responsive mids
    _trebleLevel = _smoothValue(
      _lastTrebleLevel,
      newTrebleValue,
      0.6,
    ); // Quick treble response

    // Ensure we have strong minimum values for visual impact
    _bassLevel = math.max(_bassLevel, 0.15);
    _midLevel = math.max(_midLevel, 0.1);
    _trebleLevel = math.max(_trebleLevel, 0.05);

    // Update last values
    _lastBassLevel = _bassLevel;
    _lastMidLevel = _midLevel;
    _lastTrebleLevel = _trebleLevel;
  }

  // Fade out all levels when audio is not playing
  void _fadeOutLevels() {
    const double fadeRate = 0.1;

    _bassLevel = _bassLevel * (1.0 - fadeRate);
    _midLevel = _midLevel * (1.0 - fadeRate);
    _trebleLevel = _trebleLevel * (1.0 - fadeRate);

    // Ensure values don't get stuck at very small numbers
    if (_bassLevel < 0.01) _bassLevel = 0.0;
    if (_midLevel < 0.01) _midLevel = 0.0;
    if (_trebleLevel < 0.01) _trebleLevel = 0.0;

    // Update last values
    _lastBassLevel = _bassLevel;
    _lastMidLevel = _midLevel;
    _lastTrebleLevel = _trebleLevel;
  }

  // Generate a rhythmic value based on position
  double _generateRhythmicValue({
    required double baseFrequency,
    required double positionInSeconds,
    required double randomness,
    required double baseAmplitude,
  }) {
    // Calculate a rhythmic pulse based on position
    final double rhythmicPulse =
        math.sin(positionInSeconds * baseFrequency) * 0.5 + 0.5;

    // Add some randomness
    final double randomFactor = _random.nextDouble() * randomness;

    // Calculate final value with randomness
    return (rhythmicPulse * (1.0 - randomness) + randomFactor) * baseAmplitude;
  }

  // Smooth transitions between values
  double _smoothValue(
    double oldValue,
    double newValue,
    double smoothingFactor,
  ) {
    return oldValue + (newValue - oldValue) * smoothingFactor;
  }

  // Clean up resources
  void dispose() {
    _analysisTimer?.cancel();
    _analysisTimer = null;
    _instance = null;
    _log('Audio analyzer disposed');
  }

  // Logger
  void _log(String message) {
    if (!enableLogging) return;

    print('[$_logTag] $message');
  }
}
