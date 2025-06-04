import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../common/app_scaffold.dart';
import 'widgets/audio_visualizer.dart';
import 'models/audio_analysis.dart';
import 'painters/cymatics_painter.dart';
import 'services/audio_service.dart';
import 'models/frequency_analyzer.dart';

/// The Cymatics Demo implementation
class CymaticsDemoImpl extends StatefulWidget {
  const CymaticsDemoImpl({super.key});

  // Static method to stop any playing audio from cymatics demo
  static Future<void> stopAudio() async {
    await CymaticsAudioService.stopAudio();
  }

  @override
  State<CymaticsDemoImpl> createState() => _CymaticsDemoImplState();
}

class _CymaticsDemoImplState extends State<CymaticsDemoImpl>
    with SingleTickerProviderStateMixin {
  // Animation controller for visualizations
  late AnimationController _animationController;

  // Parameters that will now evolve automatically with the music
  double _frequency = 0.5;
  double _amplitude = 0.7;
  double _density = 0.5;

  // Color for visualization - will also evolve with music
  Color _baseColor = Colors.blue;
  List<Color> _availableColors = [
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.teal,
    Colors.amber,
    Colors.cyan,
    Colors.deepPurple,
    Colors.indigo,
  ];

  // Audio service
  late CymaticsAudioService _audioService;

  // Available tracks
  List<String> _availableTracks = [];
  String? _selectedTrack;
  bool _isPlaying = false;

  // Audio levels
  double _bassLevel = 0.0;
  double _midLevel = 0.0;
  double _trebleLevel = 0.0;

  // Audio analysis data
  Map<String, List<double>> _audioFrequencyData = {};
  List<double> _currentTrackAnalysis = [];
  List<double> _rightChannelAnalysis = []; // Right channel data for stereo
  Duration _lastKnownPosition = Duration.zero;
  bool _usesStereoData = false;

  // Timer for audio analysis and parameter evolution
  Timer? _analysisTimer;
  Timer? _parameterEvolutionTimer;

  // Variables for smooth parameter transitions
  double _targetFrequency = 0.5;
  double _targetAmplitude = 0.7;
  double _targetDensity = 0.5;
  Color _targetColor = Colors.blue;

  // Time tracking for color transitions
  double _colorTransitionProgress = 0.0;

  // Subscriptions to audio service streams
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with slower animation for smoother morphing
    _animationController = AnimationController(
      duration: const Duration(seconds: 10), // Increased from 5 to 10 seconds
      vsync: this,
    )..repeat();

    // Initialize audio service
    _audioService = CymaticsAudioService();
    _audioService.initialize();

    // Set up listeners for audio service
    _setupAudioServiceListeners();

    // Load available tracks
    _loadMusicTracks();

    // Generate audio analysis
    _generateAudioAnalysis();

    // Start audio analysis and parameter evolution
    _startAudioAnalysis();
    _startParameterEvolution();

    // Set immersive mode after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    });
  }

  // Set up listeners for audio service
  void _setupAudioServiceListeners() {
    _playerStateSubscription = _audioService.onPlayerStateChanged.listen((
      state,
    ) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _positionSubscription = _audioService.onPositionChanged.listen((position) {
      _lastKnownPosition = position;
      if (_selectedTrack != null && _isPlaying) {
        _updateVisualizationFromPosition(position);
      }
    });
  }

  // Generate audio analysis for available tracks
  void _generateAudioAnalysis() {
    _audioFrequencyData = {};

    // Generate sample data for demo tracks
    for (String track in _availableTracks) {
      // Use the AudioAnalysisGenerator to create frequency data
      final trackData = AudioAnalysisGenerator.generateAudioAnalysisForTrack(
        track,
      );
      _audioFrequencyData.addAll(trackData);
    }

    debugPrint(
      'Generated frequency data for ${_audioFrequencyData.length} tracks',
    );
  }

  // Update visualization based on current playback position
  void _updateVisualizationFromPosition(Duration position) {
    if (_selectedTrack == null) {
      return;
    }

    // Check if we have stereo data for this track
    final stereoKey = "${_selectedTrack}_stereo";
    final leftKey = "${_selectedTrack}_left";
    final rightKey = "${_selectedTrack}_right";

    bool hasStereo = false;

    if (_audioFrequencyData.containsKey(stereoKey) &&
        _audioFrequencyData[stereoKey]!.isNotEmpty &&
        _audioFrequencyData[stereoKey]![0] > 0.5) {
      // This track has stereo data
      hasStereo = true;
    }

    // Update the stereo state
    _usesStereoData = hasStereo;

    // Check if we have left channel data
    if (!_audioFrequencyData.containsKey(leftKey)) {
      return;
    }

    final leftTrackData = _audioFrequencyData[leftKey]!;

    // Get right channel data if available
    List<double> rightTrackData = [];
    if (hasStereo && _audioFrequencyData.containsKey(rightKey)) {
      rightTrackData = _audioFrequencyData[rightKey]!;
    }

    // Calculate position in our data array (each position represents 50ms)
    final positionMs = position.inMilliseconds;
    final sampleIndex =
        (positionMs / 50).floor() *
        35; // *35 because each data point has 3 main bands + 32 detailed bands

    // Make sure we're within bounds for left channel
    if (sampleIndex < leftTrackData.length - 34) {
      // Update the main 3 bands
      final newBassLevel = leftTrackData[sampleIndex];
      final newMidLevel = leftTrackData[sampleIndex + 1];
      final newTrebleLevel = leftTrackData[sampleIndex + 2];

      // Get the 32 detailed bands for visualizer from left channel
      final detailedBands = leftTrackData.sublist(
        sampleIndex + 3,
        sampleIndex + 35,
      );

      // Get the right channel data if available
      List<double> rightDetailedBands = [];
      if (hasStereo && sampleIndex < rightTrackData.length - 34) {
        rightDetailedBands = rightTrackData.sublist(
          sampleIndex + 3,
          sampleIndex + 35,
        );
      }

      // Use the FrequencyAnalyzer to analyze the frequency data
      final prominentPattern =
          FrequencyAnalyzer.detectProminentPatternWithReducedMids(
            detailedBands,
          );
      final spectralBalance = FrequencyAnalyzer.calculateSpectralBalance(
        detailedBands,
      );

      // Use the results to adjust parameters for more accurate cymatics effects
      // This could dynamically influence the visualization
      _adjustParametersForFrequencyPattern(
        prominentPattern,
        spectralBalance,
        newBassLevel,
        newMidLevel,
        newTrebleLevel,
      );

      setState(() {
        // Update the main bands with smoothing
        _bassLevel = AudioAnalysisGenerator.smoothValue(
          _bassLevel,
          newBassLevel,
          0.3,
        );
        _midLevel = AudioAnalysisGenerator.smoothValue(
          _midLevel,
          newMidLevel,
          0.3,
        );
        _trebleLevel = AudioAnalysisGenerator.smoothValue(
          _trebleLevel,
          newTrebleLevel,
          0.3,
        );

        // Update the detailed bands
        _currentTrackAnalysis = detailedBands;

        // Update right channel if available
        if (hasStereo) {
          _rightChannelAnalysis = rightDetailedBands;
        } else {
          // If no right channel data, clear the array
          _rightChannelAnalysis = [];
        }
      });
    }
  }

  /// Adjust the visualization parameters based on the detected frequency pattern
  void _adjustParametersForFrequencyPattern(
    String prominentPattern,
    double spectralBalance,
    double bassLevel,
    double midLevel,
    double trebleLevel,
  ) {
    // Default transition speed - how quickly parameters change
    const transitionSpeed = 0.1;

    // Adjust target parameters based on the prominent frequency pattern
    switch (prominentPattern) {
      case 'sub_bass':
        // Very low frequencies - deep, slow patterns
        _targetFrequency = 0.2 + (bassLevel * 0.4);
        _targetAmplitude = 0.6 + (bassLevel * 0.6);
        _targetDensity = 0.3 + (bassLevel * 0.4);
        // Choose colors suitable for sub-bass (deep blues, purples)
        _targetColor = Colors.indigo;
        break;

      case 'bass':
        // Bass frequencies - strong, regular patterns
        _targetFrequency = 0.3 + (bassLevel * 0.5);
        _targetAmplitude = 0.7 + (bassLevel * 0.7);
        _targetDensity = 0.4 + (bassLevel * 0.5);
        // Rich deep colors for bass
        _targetColor = Colors.purple;
        break;

      case 'low_mid':
        // Low-mid frequencies - direct to bass patterns instead
        _targetFrequency = 0.35 + (bassLevel * 0.4);
        _targetAmplitude = 0.65 + (bassLevel * 0.6);
        _targetDensity = 0.45 + (bassLevel * 0.4);
        // Use bass colors
        _targetColor = Colors.deepPurple;
        break;

      case 'mid':
        // Mid frequencies - skip these and use either bass or high depending on levels
        if (bassLevel > trebleLevel) {
          // Redirect to bass patterns
          _targetFrequency = 0.3 + (bassLevel * 0.5);
          _targetAmplitude = 0.7 + (bassLevel * 0.7);
          _targetDensity = 0.4 + (bassLevel * 0.5);
          _targetColor = Colors.purple;
        } else {
          // Redirect to high patterns
          _targetFrequency = 0.7 + (trebleLevel * 0.5);
          _targetAmplitude = 0.3 + (trebleLevel * 0.4);
          _targetDensity = 0.8 + (trebleLevel * 0.4);
          _targetColor = Colors.cyan;
        }
        break;

      case 'high_mid':
        // High-mid frequencies - direct to high patterns instead
        _targetFrequency = 0.65 + (trebleLevel * 0.4);
        _targetAmplitude = 0.35 + (trebleLevel * 0.4);
        _targetDensity = 0.75 + (trebleLevel * 0.4);
        // Use high frequency colors
        _targetColor = Colors.cyan;
        break;

      case 'high':
        // High frequencies - mandala-like patterns
        _targetFrequency = 0.7 + (trebleLevel * 0.5);
        _targetAmplitude = 0.3 + (trebleLevel * 0.4);
        _targetDensity = 0.8 + (trebleLevel * 0.4);
        // Bright colors for highs
        _targetColor = Colors.cyan;
        break;

      case 'very_high':
        // Very high frequencies - chaotic, crystalline patterns
        _targetFrequency = 0.8 + (trebleLevel * 0.6);
        _targetAmplitude = 0.2 + (trebleLevel * 0.4);
        _targetDensity = 0.9 + (trebleLevel * 0.3);
        // Very bright colors for very high frequencies
        _targetColor = Colors.lightBlue;
        break;

      default:
        // Default - use bass patterns instead of mid-range
        _targetFrequency = 0.3 + (bassLevel * 0.5);
        _targetAmplitude = 0.7 + (bassLevel * 0.6);
        _targetDensity = 0.4 + (bassLevel * 0.5);
        _targetColor = Colors.purple;
        break;
    }

    // Use spectral balance to influence color intensity and saturation
    // More balanced spectrum = more vivid colors
    if (spectralBalance > 0.7) {
      // Highly balanced spectrum - use more saturated, brighter colors
      final hsl = HSLColor.fromColor(_targetColor);
      _targetColor = hsl
          .withSaturation(min(1.0, hsl.saturation + 0.2))
          .withLightness(min(0.7, hsl.lightness + 0.1))
          .toColor();
    }

    // Apply transitions more smoothly rather than immediately changing
    _frequency += (_targetFrequency - _frequency) * 0.05;
    _amplitude += (_targetAmplitude - _amplitude) * 0.1;
    _density += (_targetDensity - _density) * 0.08;

    // Color transitions happen in the parameter evolution timer
    _colorTransitionProgress = 0.0; // Reset transition to start a new one
  }

  // Load music tracks from assets
  Future<void> _loadMusicTracks() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = Map.from(
        const JsonDecoder().convert(manifestContent),
      );

      final musicFiles = manifestMap.keys
          .where((String key) => key.startsWith('assets/music/'))
          .where((String key) => key.endsWith('.mp3'))
          .toList();

      setState(() {
        _availableTracks = musicFiles.map((path) {
          final fileName = path.split('/').last;
          return fileName;
        }).toList();

        // Select first track by default
        if (_availableTracks.isNotEmpty && _selectedTrack == null) {
          _selectedTrack = _availableTracks.first;
        }
      });

      // Generate audio analysis after loading tracks
      _generateAudioAnalysis();

      debugPrint('Loaded ${_availableTracks.length} music tracks');
    } catch (e) {
      debugPrint('Error loading music tracks: $e');
    }
  }

  // Play selected track
  Future<void> _playSelectedTrack() async {
    if (_selectedTrack == null) return;

    try {
      await _audioService.playTrack(_selectedTrack!);

      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      debugPrint('Error playing track: $e');
    }
  }

  // Toggle play/pause
  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioService.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        if (_audioService.currentTrack != null) {
          await _audioService.resume();
        } else {
          await _playSelectedTrack();
        }
        setState(() {
          _isPlaying = true;
        });
      }
    } catch (e) {
      debugPrint('Error in toggle play/pause: $e');
    }
  }

  // New method to evolve parameters based on music
  void _startParameterEvolution() {
    _parameterEvolutionTimer?.cancel();
    _parameterEvolutionTimer = Timer.periodic(const Duration(milliseconds: 300), (
      _,
    ) {
      // Increased from 200 to 300 ms
      if (!mounted) return;

      // Only evolve parameters when playing
      if (_isPlaying) {
        setState(() {
          // Use audio levels to influence parameters

          // 1. Frequency evolves with treble - higher treble = higher frequency
          _targetFrequency = 0.3 + (_trebleLevel * 0.8);
          // Smooth transition for frequency
          _frequency +=
              (_targetFrequency - _frequency) *
              0.05; // Reduced from 0.1 to 0.05

          // 2. Amplitude responds to bass - stronger bass = higher amplitude
          _targetAmplitude = 0.5 + (_bassLevel * 0.9);
          // Smooth transition for amplitude
          _amplitude +=
              (_targetAmplitude - _amplitude) * 0.1; // Reduced from 0.2 to 0.1

          // 3. Density responds to mid frequencies
          _targetDensity = 0.4 + (_midLevel * 0.8);
          // Smooth transition for density
          _density +=
              (_targetDensity - _density) * 0.08; // Reduced from 0.15 to 0.08

          // 4. Color evolves with overall energy
          final energy = (_bassLevel + _midLevel + _trebleLevel) / 3.0;

          // Change color on significant energy peaks
          if (energy > 0.8 && _colorTransitionProgress >= 1.0) {
            // Select a new target color
            final currentColorIndex = _availableColors.indexOf(_targetColor);
            final nextColorIndex =
                (currentColorIndex + 1) % _availableColors.length;
            _targetColor = _availableColors[nextColorIndex];
            _colorTransitionProgress = 0.0;
          }

          // Progress the color transition more slowly
          _colorTransitionProgress += 0.01; // Reduced from 0.02 to 0.01
          if (_colorTransitionProgress < 1.0) {
            // Transition to the target color more slowly
            _baseColor = Color.lerp(
              _baseColor,
              _targetColor,
              0.03,
            )!; // Reduced from 0.05 to 0.03
          }
        });
      } else {
        // When not playing, slowly return to default values
        setState(() {
          _frequency = _frequency * 0.95 + 0.5 * 0.05;
          _amplitude = _amplitude * 0.95 + 0.7 * 0.05;
          _density = _density * 0.95 + 0.5 * 0.05;
        });
      }
    });
  }

  // Start audio analysis timer
  void _startAudioAnalysis() {
    _analysisTimer?.cancel();
    _analysisTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      // If not playing, gradually reduce values
      if (!_isPlaying) {
        setState(() {
          _bassLevel *= 0.9;
          _midLevel *= 0.9;
          _trebleLevel *= 0.9;

          if (_bassLevel < 0.01) _bassLevel = 0.0;
          if (_midLevel < 0.01) _midLevel = 0.0;
          if (_trebleLevel < 0.01) _trebleLevel = 0.0;
        });
        return;
      }

      // Check if we have position updates from player; if not, use our own timer
      if (_lastKnownPosition == Duration.zero) {
        final positionFactor = _animationController.value * 10;

        // Generate more distinct rhythmic patterns
        double newBassValue = AudioAnalysisGenerator.generateRhythmicValue(
          baseFrequency: 0.25,
          positionInSeconds: positionFactor,
          randomness: 0.2,
          baseAmplitude: 0.7,
        );

        double newMidValue = AudioAnalysisGenerator.generateRhythmicValue(
          baseFrequency: 0.5,
          positionInSeconds: positionFactor + 0.25,
          randomness: 0.3,
          baseAmplitude: 0.6,
        );

        double newTrebleValue = AudioAnalysisGenerator.generateRhythmicValue(
          baseFrequency: 1.0,
          positionInSeconds: positionFactor + 0.5,
          randomness: 0.4,
          baseAmplitude: 0.5,
        );

        // Apply smoothing
        setState(() {
          _bassLevel = AudioAnalysisGenerator.smoothValue(
            _bassLevel,
            newBassValue,
            0.3,
          );
          _midLevel = AudioAnalysisGenerator.smoothValue(
            _midLevel,
            newMidValue,
            0.4,
          );
          _trebleLevel = AudioAnalysisGenerator.smoothValue(
            _trebleLevel,
            newTrebleValue,
            0.5,
          );
        });
      }
    });
  }

  // Stop playback when navigating away
  Future<void> _stopAudioPlayback() async {
    if (_isPlaying) {
      await _audioService.stop();
      setState(() {
        _isPlaying = false;
      });
      debugPrint('Manually stopped audio playback when leaving cymatics demo');
    }
  }

  @override
  void dispose() {
    // Cancel all subscriptions
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _parameterEvolutionTimer?.cancel();
    _analysisTimer?.cancel();

    // Make sure we stop the audio
    _stopAudioPlayback();

    _animationController.dispose();

    // Clean up the system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _stopAudioPlayback();
        return true;
      },
      child: AppScaffold(
        title: 'Cymatics Demo',
        showBackButton: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.black, _baseColor.withOpacity(0.2), Colors.black],
            ),
          ),
          child: _audioFrequencyData.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Preparing audio analysis...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Audio controls
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.black.withOpacity(0.7),
                      child: Column(
                        children: [
                          // Track selector dropdown
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Select Track',
                              labelStyle: TextStyle(color: _baseColor),
                              border: OutlineInputBorder(
                                borderSide: BorderSide(color: _baseColor),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: _baseColor),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: _baseColor,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            dropdownColor: Colors.black87,
                            style: const TextStyle(color: Colors.white),
                            value: _selectedTrack,
                            items: _availableTracks.map((track) {
                              return DropdownMenuItem<String>(
                                value: track,
                                child: Text(track),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedTrack = value;
                                // Reset visualization when track changes
                                _bassLevel = 0.0;
                                _midLevel = 0.0;
                                _trebleLevel = 0.0;
                                _currentTrackAnalysis = List.filled(32, 0.0);

                                // If already playing, automatically start the new track
                                if (_isPlaying) {
                                  _playSelectedTrack();
                                }
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Play/pause button
                          ElevatedButton.icon(
                            onPressed: _togglePlayPause,
                            icon: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                            ),
                            label: Text(_isPlaying ? 'Pause' : 'Play'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _baseColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Visualization area with only cymatics painter - no frequency bars
                    Expanded(
                      child: Center(
                        child: Stack(
                          children: [
                            // Cymatics visualization (concentric circles)
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                // Get screen dimensions for proper scaling
                                final screenSize = MediaQuery.of(context).size;

                                return SizedBox.expand(
                                  child: CustomPaint(
                                    painter: CymaticsPainter(
                                      animationValue:
                                          _animationController.value,
                                      frequency: _frequency,
                                      // Amplify amplitude even more with bass
                                      amplitude:
                                          _amplitude * (1 + _bassLevel * 2.0),
                                      // Increase density with mid level
                                      density: _density * (1 + _midLevel * 1.5),
                                      baseColor: _baseColor,
                                      audioLevels: [
                                        _bassLevel * 1.2, // Boost bass level
                                        _midLevel * 1.2, // Boost mid level
                                        _trebleLevel,
                                      ],
                                      frequencyBands:
                                          _currentTrackAnalysis.isNotEmpty
                                          ? _currentTrackAnalysis
                                          : null,
                                      fullScreen: true, // Fill the screen
                                    ),
                                    size: screenSize,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
