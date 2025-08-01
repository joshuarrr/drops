import 'dart:math';
import 'package:flutter/material.dart';

/// Class responsible for analyzing frequency data to detect dominant frequencies
/// for more accurate cymatics pattern generation
class FrequencyAnalyzer {
  /// Standard frequency bands for audio visualization (in Hz)
  static const List<double> standardFrequencyBands = [
    20,
    25,
    31.5,
    40,
    50,
    63,
    80,
    100,
    125,
    160,
    200,
    250,
    315,
    400,
    500,
    630,
    800,
    1000,
    1250,
    1600,
    2000,
    2500,
    3150,
    4000,
    5000,
    6300,
    8000,
    10000,
    12500,
    16000,
    20000,
  ];

  /// Analyze frequency data to find dominant frequencies
  /// Returns a map with frequency bands and their amplitudes
  static Map<double, double> findDominantFrequencies(
    List<double> frequencyData, {
    bool useLogScale = true,
  }) {
    if (frequencyData.isEmpty) {
      return {};
    }

    // Create a map to store the result
    final Map<double, double> dominantFrequencies = {};

    // Determine the frequency range represented by the data
    // We assume frequencyData is already processed into bands (e.g., from FFT)
    final int bandCount = frequencyData.length;

    // Map each band to a frequency value
    // Assuming the data spans from 20Hz to 20kHz in a logarithmic scale
    for (int i = 0; i < bandCount; i++) {
      double frequency;

      if (useLogScale) {
        // Logarithmic scale mapping (more natural for human hearing)
        frequency = 20.0 * pow(10, i * 3.0 / bandCount); // 20Hz to 20kHz
      } else {
        // Linear scale mapping
        frequency = 20.0 + (20000.0 - 20.0) * (i / bandCount);
      }

      // Map to closest standard frequency band
      final closestBand = _findClosestStandardBand(frequency);
      final amplitude = frequencyData[i];

      // Only store significant amplitudes
      if (amplitude > 0.1) {
        // If this band already exists, take the maximum amplitude
        if (dominantFrequencies.containsKey(closestBand)) {
          dominantFrequencies[closestBand] = max(
            dominantFrequencies[closestBand]!,
            amplitude,
          );
        } else {
          dominantFrequencies[closestBand] = amplitude;
        }
      }
    }

    return dominantFrequencies;
  }

  /// Find the closest standard frequency band to a given frequency
  static double _findClosestStandardBand(double frequency) {
    double closestBand = standardFrequencyBands.first;
    double minDifference = (frequency - closestBand).abs();

    for (final band in standardFrequencyBands) {
      final difference = (frequency - band).abs();
      if (difference < minDifference) {
        minDifference = difference;
        closestBand = band;
      }
    }

    return closestBand;
  }

  /// Convert a list of frequency bands into frequency ranges (octave bands)
  /// Returns a map with frequency ranges (low, mid, high) and their average amplitudes
  static Map<String, double> getFrequencyRanges(List<double> frequencyData) {
    if (frequencyData.isEmpty) {
      return {
        'sub_bass': 0.0, // 20-60 Hz
        'bass': 0.0, // 60-250 Hz
        'low_mid': 0.0, // 250-500 Hz
        'mid': 0.0, // 500-2000 Hz
        'high_mid': 0.0, // 2000-4000 Hz
        'high': 0.0, // 4000-6000 Hz
        'very_high': 0.0, // 6000-20000 Hz
      };
    }

    // Analyze full spectrum
    final dominantFreqs = findDominantFrequencies(frequencyData);

    // Calculate average amplitude for each frequency range
    final ranges = <String, List<double>>{
      'sub_bass': [], // 20-60 Hz
      'bass': [], // 60-250 Hz
      'low_mid': [], // 250-500 Hz
      'mid': [], // 500-2000 Hz
      'high_mid': [], // 2000-4000 Hz
      'high': [], // 4000-6000 Hz
      'very_high': [], // 6000-20000 Hz
    };

    // Categorize frequencies into ranges
    for (final entry in dominantFreqs.entries) {
      final freq = entry.key;
      final amp = entry.value;

      if (freq >= 20 && freq < 60) {
        ranges['sub_bass']!.add(amp);
      } else if (freq >= 60 && freq < 250) {
        ranges['bass']!.add(amp);
      } else if (freq >= 250 && freq < 500) {
        ranges['low_mid']!.add(amp);
      } else if (freq >= 500 && freq < 2000) {
        ranges['mid']!.add(amp);
      } else if (freq >= 2000 && freq < 4000) {
        ranges['high_mid']!.add(amp);
      } else if (freq >= 4000 && freq < 6000) {
        ranges['high']!.add(amp);
      } else if (freq >= 6000) {
        ranges['very_high']!.add(amp);
      }
    }

    // Calculate average for each range
    final result = <String, double>{};
    for (final rangeEntry in ranges.entries) {
      final range = rangeEntry.key;
      final values = rangeEntry.value;

      if (values.isEmpty) {
        result[range] = 0.0;
      } else {
        double sum = 0.0;
        for (final value in values) {
          sum += value;
        }
        result[range] = sum / values.length;
      }
    }

    return result;
  }

  /// Detect the most prominent frequency pattern based on frequency data
  /// Returns a String indicating which pattern would be most appropriate
  static String detectProminentPattern(List<double> frequencyData) {
    if (frequencyData.isEmpty) {
      return 'mid'; // Default to mid-range pattern
    }

    final ranges = getFrequencyRanges(frequencyData);

    // Find the range with maximum amplitude
    String dominantRange = 'mid'; // Default
    double maxAmplitude = 0.0;

    for (final entry in ranges.entries) {
      if (entry.value > maxAmplitude) {
        maxAmplitude = entry.value;
        dominantRange = entry.key;
      }
    }

    return dominantRange;
  }

  /// Calculate the energy distribution across frequency spectrum
  /// Returns a value between 0.0 and 1.0 indicating how evenly distributed the energy is
  static double calculateSpectralBalance(List<double> frequencyData) {
    if (frequencyData.length < 3) return 0.5; // Default for insufficient data

    final ranges = getFrequencyRanges(frequencyData);

    // Calculate the coefficient of variation (normalized standard deviation)
    final values = ranges.values.toList();

    // Calculate mean
    double sum = 0.0;
    for (final value in values) {
      sum += value;
    }
    final mean = sum / values.length;

    // Calculate variance
    double squaredDiffSum = 0.0;
    for (final value in values) {
      squaredDiffSum += pow(value - mean, 2);
    }
    final variance = squaredDiffSum / values.length;

    // Calculate standard deviation
    final stdDev = sqrt(variance);

    // Calculate coefficient of variation (CV)
    final cv = mean > 0 ? stdDev / mean : 0.0;

    // Convert to a balance score (0 = perfectly balanced, 1 = totally unbalanced)
    // A lower CV means more balanced
    final balanceScore = 1.0 - min(1.0, cv);

    return balanceScore;
  }

  /// Get frequency ranges with adjusted weights to reduce mid-range emphasis
  static Map<String, double> getFrequencyRangesWithReducedMids(
    List<double> frequencyData,
  ) {
    final ranges = getFrequencyRanges(frequencyData);

    // Apply weights to reduce mid-range emphasis
    final weightedRanges = <String, double>{};

    // Define weights for each range - amplify bass and highs, reduce mids
    final weights = {
      'sub_bass': 1.5, // Boost sub-bass
      'bass': 1.3, // Boost bass
      'low_mid': 0.9, // Slightly reduce low-mids
      'mid': 0.5, // Significantly reduce mids
      'high_mid': 0.7, // Moderately reduce high-mids
      'high': 1.2, // Boost highs
      'very_high': 1.4, // Boost very high frequencies
    };

    // Apply weights
    for (final entry in ranges.entries) {
      final range = entry.key;
      final value = entry.value;
      final weight = weights[range] ?? 1.0;

      weightedRanges[range] = value * weight;
    }

    return weightedRanges;
  }

  /// Detect the most prominent frequency pattern with reduced mid-range emphasis
  static String detectProminentPatternWithReducedMids(
    List<double> frequencyData,
  ) {
    if (frequencyData.isEmpty) {
      return 'bass'; // Default to bass pattern instead of mid
    }

    final ranges = getFrequencyRangesWithReducedMids(frequencyData);

    // Find the range with maximum amplitude
    String dominantRange = 'bass'; // Default to bass instead of mid
    double maxAmplitude = 0.0;

    for (final entry in ranges.entries) {
      if (entry.value > maxAmplitude) {
        maxAmplitude = entry.value;
        dominantRange = entry.key;
      }
    }

    return dominantRange;
  }
}
