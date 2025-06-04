import 'dart:math';
import 'package:flutter/material.dart';

/// Class responsible for generating and managing audio frequency analysis data
class AudioAnalysisGenerator {
  /// Generate frequency analysis data for a track
  /// Returns a map with left and right channel data, and stereo flag
  static Map<String, List<double>> generateAudioAnalysisForTrack(String track) {
    final Map<String, List<double>> data = {};

    // Use track name as seed for consistency
    final random = Random(track.hashCode);

    // Decide if this track should use stereo (based on track name hash)
    final useStereo = random.nextDouble() > 0.2; // 80% chance of stereo

    // Create an array with "samples" for every 50ms of a 3-minute track
    // (3min = 180s = 3600 samples at 50ms each)
    final sampleCount = 3600;
    List<double> bassData = [];
    List<double> midData = [];
    List<double> trebleData = [];

    // For stereo, we need separate right channel data
    List<double> bassDataRight = [];
    List<double> midDataRight = [];
    List<double> trebleDataRight = [];

    // For detailed visualization we'll use more bands (32 frequency bands)
    final List<List<double>> detailedBands = List.generate(32, (_) => []);
    final List<List<double>> detailedBandsRight = List.generate(32, (_) => []);

    // Create more realistic beat patterns
    // Define different beat patterns (4/4 time, etc.)
    final List<List<double>> beatPatterns = [
      // 4/4 beat pattern (kick on 1 and 3, snare on 2 and 4)
      [1.0, 0.4, 0.7, 0.3, 0.9, 0.4, 0.6, 0.3],
      // 2/4 beat pattern
      [1.0, 0.3, 0.8, 0.3],
      // Triplet feel
      [1.0, 0.3, 0.5, 0.8, 0.3, 0.5],
      // Complex beat
      [1.0, 0.2, 0.4, 0.7, 0.3, 0.6, 0.2, 0.8, 0.3, 0.5, 0.7, 0.2],
    ];

    // Select a beat pattern for this track
    final selectedPattern = beatPatterns[random.nextInt(beatPatterns.length)];
    final patternLength = selectedPattern.length;

    // Generate some "musical" parameters for this track
    final hasBassline = random.nextDouble() > 0.2; // 80% chance of bassline
    final hasBreakdown = random.nextDouble() > 0.3; // 70% chance of breakdown
    final breakdownStart =
        random.nextInt(sampleCount ~/ 2) +
        (sampleCount ~/ 4); // Between 25-75% of track
    final breakdownLength =
        (random.nextInt(400) + 200); // 10-30 seconds (200-600 samples)
    final buildupLength = breakdownLength ~/ 2; // Half the breakdown length

    // Stereo-specific parameters
    final stereoPanning =
        random.nextDouble() * 0.3 + 0.1; // 0.1-0.4 range for stereo width
    final hasStereoEffects =
        useStereo &&
        random.nextDouble() > 0.3; // 70% chance of special stereo effects
    final stereoDelay =
        (random.nextInt(3) + 1); // 1-3 sample delay for certain stereo effects

    // Create a more realistic audio frequency profile
    for (int i = 0; i < sampleCount; i++) {
      // Determine current beat position for patterns
      final beatPosition =
          i % (patternLength * 4); // Each beat is 4 samples (200ms)
      final beatIndex = (beatPosition / 4).floor() % patternLength;
      final beatStrength = selectedPattern[beatIndex];

      // Check if we're in breakdown section
      final inBreakdown =
          hasBreakdown &&
          i >= breakdownStart &&
          i < (breakdownStart + breakdownLength);

      // Buildup is right after breakdown
      final inBuildup =
          hasBreakdown &&
          i >= (breakdownStart + breakdownLength) &&
          i < (breakdownStart + breakdownLength + buildupLength);

      // Calculate intensity based on position in breakdown/buildup
      double intensityMultiplier = 1.0;
      if (inBreakdown) {
        // Intensity drops during breakdown
        final breakdownProgress = (i - breakdownStart) / breakdownLength;
        intensityMultiplier = 0.3 + (sin(breakdownProgress * pi) * 0.2);
      } else if (inBuildup) {
        // Intensity rises during buildup
        final buildupProgress =
            (i - (breakdownStart + breakdownLength)) / buildupLength;
        intensityMultiplier = 0.5 + (buildupProgress * 0.7);
      }

      // Bass tends to have longer sustained patterns
      double bassValue;
      if (hasBassline && !inBreakdown) {
        // Create bassline with regular pattern
        final basslinePattern = sin(i * 0.05) * 0.2 + 0.4; // Basic oscillation
        final beatImpact = beatPosition % 4 == 0
            ? beatStrength * 0.4
            : 0.0; // Add emphasis on beats
        bassValue = (basslinePattern + beatImpact) * intensityMultiplier;
      } else {
        // Just basic beat-driven bass
        final bassWave = sin(i * 0.02) * 0.15 + 0.3;
        final beatImpact = beatPosition % 4 == 0 ? beatStrength * 0.5 : 0.0;
        bassValue = (bassWave + beatImpact) * intensityMultiplier;
      }

      // Add some randomness
      bassValue += random.nextDouble() * 0.1;
      bassValue = bassValue.clamp(0.0, 1.0);

      // For right channel bass in stereo
      double bassValueRight = bassValue;
      if (useStereo) {
        // Bass is usually centered but can have slight variations
        final bassPan =
            random.nextDouble() * stereoPanning * 0.5; // Less panning for bass
        if (random.nextBool()) {
          // Sometimes slightly stronger in left
          bassValue *= (1.0 + bassPan);
          bassValueRight *= (1.0 - bassPan);
        } else {
          // Sometimes slightly stronger in right
          bassValue *= (1.0 - bassPan);
          bassValueRight *= (1.0 + bassPan);
        }
      }

      // Calculate mid and treble values (similar pattern)
      // Mids vary more frequently
      final midWave1 = sin(i * 0.08) * 0.2 + 0.2;
      final midWave2 = sin(i * 0.12 + 2) * 0.15 + 0.15; // Second harmonic
      final midRandom = random.nextDouble() * 0.15;
      double midValue = (midWave1 + midWave2 + midRandom) * intensityMultiplier;

      // Add some beat response to mids as well
      if (beatPosition % 4 == 2) {
        // Emphasis on off-beats for mids
        midValue += beatStrength * 0.3;
      }

      midValue = midValue.clamp(0.0, 1.0);

      // For right channel mids in stereo
      double midValueRight = midValue;
      if (useStereo) {
        // Mids can have more stereo separation
        final midPan = random.nextDouble() * stereoPanning;

        // Apply panning based on i to create movement
        final panDirection = sin(i * 0.01);
        if (panDirection > 0) {
          // Pan toward left
          midValue *= (1.0 + midPan);
          midValueRight *= (1.0 - midPan);
        } else {
          // Pan toward right
          midValue *= (1.0 - midPan);
          midValueRight *= (1.0 + midPan);
        }

        // For stereo effects, add occasional delay between channels
        if (hasStereoEffects && i % 40 == 0 && i + stereoDelay < sampleCount) {
          // Create a delayed copy of this mid value for the right channel
          // This will be added stereoDelay samples later
          if (midDataRight.length <= i + stereoDelay) {
            for (int j = midDataRight.length; j <= i + stereoDelay; j++) {
              if (j == i + stereoDelay) {
                midDataRight.add(midValue * 0.9); // Slightly quieter echo
              } else {
                midDataRight.add(0.0); // Padding
              }
            }
            continue; // Skip normal right channel addition
          }
        }
      }

      // Treble tends to be more sporadic and follows hi-hats/cymbals
      double trebleValue;
      // Hi-hats often on 8th or 16th notes
      final isHiHat = beatPosition % 2 == 0; // 8th notes
      if (isHiHat) {
        trebleValue = 0.3 + random.nextDouble() * 0.4 + (beatStrength * 0.3);
      } else {
        trebleValue = random.nextDouble() * 0.3;
      }

      // Add variation
      trebleValue = (trebleValue + sin(i * 0.2) * 0.1) * intensityMultiplier;
      trebleValue = trebleValue.clamp(0.0, 1.0);

      // For right channel treble in stereo
      double trebleValueRight = trebleValue;
      if (useStereo) {
        // Treble often has strong stereo placement (hi-hats, cymbals)
        final treblePan =
            random.nextDouble() *
            stereoPanning *
            1.5; // More panning for treble

        // Every few beats, place a hi-hat strongly in one channel
        if (isHiHat && i % 8 == 0) {
          if (random.nextBool()) {
            // Strong left pan for this hi-hat
            trebleValue *= (1.0 + treblePan * 2);
            trebleValueRight *= (1.0 - treblePan * 2);
          } else {
            // Strong right pan for this hi-hat
            trebleValue *= (1.0 - treblePan * 2);
            trebleValueRight *= (1.0 + treblePan * 2);
          }
        } else {
          // Regular panning based on position
          final treblePanPos = sin(i * 0.03 + 1);
          if (treblePanPos > 0) {
            trebleValue *= (1.0 + treblePan);
            trebleValueRight *= (1.0 - treblePan);
          } else {
            trebleValue *= (1.0 - treblePan);
            trebleValueRight *= (1.0 + treblePan);
          }
        }
      }

      // Add occasional "beats" - spikes in the bass
      if (beatPosition % 4 == 0) {
        // Main beats
        bassData.add(min(1.0, bassValue * 1.3 * beatStrength));
        if (useStereo) {
          bassDataRight.add(min(1.0, bassValueRight * 1.3 * beatStrength));
        }
      } else {
        bassData.add(bassValue);
        if (useStereo) {
          bassDataRight.add(bassValueRight);
        }
      }

      midData.add(midValue);
      trebleData.add(trebleValue);

      // Add right channel data if stereo
      if (useStereo) {
        // Only add if we haven't already added through special effects
        if (midDataRight.length <= i) {
          midDataRight.add(midValueRight);
        }
        trebleDataRight.add(trebleValueRight);
      }

      // Generate detailed frequency bands for left channel
      _generateDetailedBands(
        i,
        beatPosition,
        beatStrength,
        bassValue,
        midValue,
        trebleValue,
        intensityMultiplier,
        inBreakdown,
        inBuildup,
        breakdownStart,
        breakdownLength,
        buildupLength,
        random,
        detailedBands,
        sampleCount,
      );

      // Generate detailed frequency bands for right channel if stereo
      if (useStereo) {
        _generateDetailedBands(
          i,
          beatPosition,
          beatStrength,
          bassValueRight,
          midValueRight,
          trebleValueRight,
          intensityMultiplier,
          inBreakdown,
          inBuildup,
          breakdownStart,
          breakdownLength,
          buildupLength,
          random,
          detailedBandsRight,
          sampleCount,
          isRightChannel: true,
          stereoWidth: stereoPanning,
        );
      }
    }

    // Apply smoothing to all bands to prevent jarring transitions
    for (int band = 0; band < 32; band++) {
      final smoothedBand = _applySmoothingFilter(detailedBands[band]);
      detailedBands[band] = smoothedBand;

      if (useStereo) {
        final smoothedBandRight = _applySmoothingFilter(
          detailedBandsRight[band],
        );
        detailedBandsRight[band] = smoothedBandRight;
      }
    }

    // Also smooth the main bands
    bassData = _applySmoothingFilter(bassData);
    midData = _applySmoothingFilter(midData);
    trebleData = _applySmoothingFilter(trebleData);

    if (useStereo) {
      bassDataRight = _applySmoothingFilter(bassDataRight);
      midDataRight = _applySmoothingFilter(midDataRight);
      trebleDataRight = _applySmoothingFilter(trebleDataRight);
    }

    // Combine all frequency data
    List<double> combinedData = [];
    List<double> combinedRightData = [];

    for (int i = 0; i < sampleCount; i++) {
      // First add the main 3 bands for left channel
      if (i < bassData.length) combinedData.add(bassData[i]);
      if (i < midData.length) combinedData.add(midData[i]);
      if (i < trebleData.length) combinedData.add(trebleData[i]);

      // Then add the 32 detailed bands for left channel
      for (int band = 0; band < 32; band++) {
        if (i < detailedBands[band].length) {
          combinedData.add(detailedBands[band][i]);
        }
      }

      // If stereo, add right channel data
      if (useStereo) {
        // Add the main 3 bands for right channel
        if (i < bassDataRight.length) combinedRightData.add(bassDataRight[i]);
        if (i < midDataRight.length) combinedRightData.add(midDataRight[i]);
        if (i < trebleDataRight.length)
          combinedRightData.add(trebleDataRight[i]);

        // Then add the 32 detailed bands for right channel
        for (int band = 0; band < 32; band++) {
          if (i < detailedBandsRight[band].length) {
            combinedRightData.add(detailedBandsRight[band][i]);
          }
        }
      }
    }

    // Store the data
    data["${track}_left"] = combinedData;
    if (useStereo) {
      data["${track}_right"] = combinedRightData;
      data["${track}_stereo"] = [1.0]; // Flag to indicate stereo data
    } else {
      data["${track}_stereo"] = [0.0]; // Flag to indicate mono data
    }

    return data;
  }

  /// Helper method to generate detailed frequency bands
  static void _generateDetailedBands(
    int i,
    int beatPosition,
    double beatStrength,
    double bassValue,
    double midValue,
    double trebleValue,
    double intensityMultiplier,
    bool inBreakdown,
    bool inBuildup,
    int breakdownStart,
    int breakdownLength,
    int buildupLength,
    Random random,
    List<List<double>> detailedBands,
    int sampleCount, {
    bool isRightChannel = false,
    double stereoWidth = 0.0,
  }) {
    for (int band = 0; band < 32; band++) {
      // Lower bands are more influenced by bass, higher by treble
      double bandValue;

      // Create different frequency responses based on band
      if (band < 5) {
        // Sub-bass (0-4)
        bandValue = bassValue * 0.8 + random.nextDouble() * 0.2;
        // Add more emphasis on main beats
        if (beatPosition % 4 == 0) {
          bandValue *= 1.2;
        }
      } else if (band < 12) {
        // Bass (5-11)
        bandValue = bassValue * 0.7 + random.nextDouble() * 0.2;
        // Different emphasis for different bass frequencies
        final emphasis = sin(band * 0.5) * 0.2 + 0.8;
        bandValue *= emphasis;
      } else if (band < 20) {
        // Mids (12-19)
        bandValue = midValue * 0.6 + random.nextDouble() * 0.2;
        // Add some rhythmic variation in mids
        if (band % 2 == 0 && beatPosition % 2 == 0) {
          bandValue *= 1.1;
        }
      } else {
        // Highs (20-31)
        bandValue = trebleValue * 0.5 + random.nextDouble() * 0.2;
        // Add hi-hat patterns
        if (beatPosition % 2 == 0 && band > 25) {
          bandValue *= 1.3;
        }
      }

      // Apply stereo width enhancement for right channel
      if (isRightChannel && stereoWidth > 0.0) {
        // Apply different stereo effects based on frequency range
        if (band < 5) {
          // Minimal stereo for sub-bass (keep centered)
          // Do nothing special
        } else if (band < 12) {
          // Slight stereo for bass
          if (random.nextBool()) {
            bandValue *= 1.0 + (stereoWidth * 0.2);
          } else {
            bandValue *= 1.0 - (stereoWidth * 0.2);
          }
        } else if (band < 20) {
          // More stereo for mids
          final stereoPan = sin(i * 0.03 + band * 0.1) * stereoWidth * 0.6;
          bandValue *= 1.0 + stereoPan;
        } else {
          // Full stereo for highs
          final stereoPan = sin(i * 0.02 + band * 0.2) * stereoWidth;
          bandValue *= 1.0 + stereoPan;

          // Add occasional strong panning for certain high frequencies
          if (beatPosition % 4 == 0 && band > 28 && random.nextDouble() > 0.7) {
            bandValue *= 1.0 + stereoWidth * 2;
          }
        }
      }

      // Apply intensity multiplier
      bandValue *= intensityMultiplier;

      // Add variation based on band position to create a more natural spectrum
      final bandFactor = 0.7 + (sin(band * 0.2) * 0.3);
      bandValue *= bandFactor;

      // Add occasional "fills" across the spectrum
      if (random.nextDouble() > 0.997) {
        // Very rare special effects
        // Create a "sweep" effect across multiple consecutive samples
        final sweepLength = random.nextInt(10) + 5;
        final sweepIntensity = random.nextDouble() * 0.5 + 0.5;

        if (i + sweepLength < sampleCount) {
          for (int j = 0; j < sweepLength; j++) {
            if (detailedBands[band].length <= i + j) {
              // If we're still building the array, add the sweep
              final sweepValue = sweepIntensity * (1.0 - (j / sweepLength));
              detailedBands[band].add(min(1.0, bandValue + sweepValue));
            }
          }
          continue; // Skip adding the regular value since we added the sweep
        }
      }

      // Add special effects during buildup
      if (inBuildup && band > 15 && random.nextDouble() > 0.98) {
        // Rising filter effect common in buildups
        final buildupProgress =
            (i - (breakdownStart + breakdownLength)) / buildupLength;
        final filterEffect = buildupProgress * 0.7;
        bandValue = min(1.0, bandValue + filterEffect);
      }

      detailedBands[band].add(bandValue.clamp(0.0, 1.0));
    }
  }

  /// Apply a smoothing filter to a list of values
  static List<double> _applySmoothingFilter(List<double> values) {
    if (values.length <= 3) return values;

    final smoothed = List<double>.from(values);

    for (int i = 1; i < values.length - 1; i++) {
      // Simple 3-point moving average
      smoothed[i] =
          (values[i - 1] * 0.25 + values[i] * 0.5 + values[i + 1] * 0.25);
    }

    return smoothed;
  }

  /// Generate a rhythmic value based on position
  static double generateRhythmicValue({
    required double baseFrequency,
    required double positionInSeconds,
    required double randomness,
    required double baseAmplitude,
  }) {
    // Create a cyclic pattern based on time
    final cyclePosition = positionInSeconds * baseFrequency;
    final baseCycle = sin(cyclePosition * 2 * pi);

    // Add some randomness
    final random = Random();
    final randomFactor = random.nextDouble() * randomness;

    // Combine base cycle with randomness
    double value = (baseCycle * 0.5 + 0.5) * baseAmplitude;
    value = value * (1.0 - randomness) + randomFactor * baseAmplitude;

    return value.clamp(0.0, 1.0);
  }

  /// Smooth transitions between values
  static double smoothValue(
    double currentValue,
    double targetValue,
    double smoothFactor,
  ) {
    return currentValue + (targetValue - currentValue) * smoothFactor;
  }
}
