import 'package:flutter/material.dart';
import 'dart:math';
import '../models/cymatics_patterns.dart';

/// Custom painter for the cymatics visualization
class CymaticsPainter extends CustomPainter {
  final double animationValue;
  final double frequency;
  final double amplitude;
  final double density;
  final Color baseColor;
  final List<double>? audioLevels;
  final List<double>? frequencyBands;
  final bool fullScreen;

  // Static fields for pattern transitions
  static PatternType _lastPatternType = PatternType.simpleCircular;
  static int _lastNodes = 8;
  static double _lastComplexity = 0.5;
  static double _transitionProgress = 1.0; // 0.0 to 1.0

  CymaticsPainter({
    required this.animationValue,
    required this.frequency,
    required this.amplitude,
    required this.density,
    required this.baseColor,
    this.audioLevels,
    this.frequencyBands,
    this.fullScreen = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height / 2);

    // Calculate the radius based on the largest dimension to ensure it fills the screen
    final radius = fullScreen ? max(width, height) : width / 2;

    // Get audio levels or use defaults
    final bassLevel = audioLevels != null && audioLevels!.length > 0
        ? audioLevels![0]
        : 0.0;
    final midLevel = audioLevels != null && audioLevels!.length > 1
        ? audioLevels![1]
        : 0.0;
    final trebleLevel = audioLevels != null && audioLevels!.length > 2
        ? audioLevels![2]
        : 0.0;

    // Create gradient for wave
    final gradient = RadialGradient(
      colors: [
        baseColor.withOpacity(0.45),
        baseColor.withOpacity(0.2),
        baseColor.withOpacity(0.0),
      ],
      stops: const [0.0, 0.7, 1.0],
    );

    // Create shader from gradient
    final rect = Rect.fromCenter(
      center: center,
      width: width * 3,
      height: height * 3,
    );
    final shader = gradient.createShader(rect);

    // Determine which cymatics pattern to use based on frequency bands
    PatternType currentPatternType = PatternType.simpleCircular;
    PatternType previousPatternType = currentPatternType;
    int nodes = 8;
    double complexity = 0.5;

    // Determine current pattern
    if (frequencyBands != null && frequencyBands!.isNotEmpty) {
      // Create frequency list based on typical audio spectrum ranges
      // These are rough estimates of frequencies represented by each band
      List<double> frequencies = [];
      List<double> amplitudes = [];

      // Map frequency bands to actual frequencies (estimates)
      // Assuming 32 bands covering 20Hz to 20kHz logarithmically
      for (int i = 0; i < frequencyBands!.length; i++) {
        // Estimate frequency for this band using logarithmic scale
        // 20Hz * 10^(i * log10(1000) / 32)
        final bandFreq = 20.0 * pow(10, i * 3 / frequencyBands!.length);
        final bandAmp = frequencyBands![i];

        // Reduce mid-range frequencies (500-2000 Hz)
        double adjustedAmp = bandAmp;
        if (bandFreq >= 500 && bandFreq <= 2000) {
          adjustedAmp *= 0.5; // Reduce mid-range by 50%
        } else if (bandFreq < 250 || bandFreq > 4000) {
          adjustedAmp *= 1.3; // Boost lows and highs by 30%
        }

        // Only add bands with significant amplitude
        if (adjustedAmp > 0.1) {
          frequencies.add(bandFreq);
          amplitudes.add(adjustedAmp);
        }
      }

      // Store pattern info for current frame
      final patternInfo = CymaticsPatterns.generateCompositePattern(
        frequencies,
        amplitudes,
      );

      currentPatternType = patternInfo['pattern'] as PatternType;

      // Skip mid-range patterns in favor of bass or high frequency patterns
      if (currentPatternType == PatternType.complexSymmetry) {
        // Replace mid-range pattern with either bass or high patterns
        currentPatternType = bassLevel > trebleLevel
            ? PatternType.segmentedRings
            : PatternType.flowerOfLife;
      }

      nodes = patternInfo['nodes'] as int;
      complexity = patternInfo['complexity'] as double;
    } else {
      // Fallback if no frequency bands available - use bass/mid/treble to estimate
      if (bassLevel > midLevel * 1.2 || bassLevel > 0.6) {
        // Give bass more weight
        // Bass dominant - lower frequency patterns
        currentPatternType = bassLevel > 0.6
            ? PatternType.segmentedRings
            : PatternType.simpleCircular;
        nodes = (4 + bassLevel * 6).round();
        complexity = 0.3 + bassLevel * 0.3;
      } else if (trebleLevel > midLevel * 1.2 || trebleLevel > 0.6) {
        // Give treble more weight
        // Treble dominant - higher frequency patterns
        currentPatternType = trebleLevel > 0.5
            ? PatternType.flowerOfLife
            : PatternType.mandalaStructure;
        nodes = (10 + trebleLevel * 14).round();
        complexity = 0.6 + trebleLevel * 0.4;
      } else {
        // If mid frequencies would be dominant, pick either bass or treble based on which is stronger
        if (bassLevel >= trebleLevel) {
          currentPatternType = PatternType.segmentedRings;
          nodes = (5 + bassLevel * 7).round();
          complexity = 0.4 + bassLevel * 0.4;
        } else {
          currentPatternType = PatternType.flowerOfLife;
          nodes = (9 + trebleLevel * 12).round();
          complexity = 0.6 + trebleLevel * 0.3;
        }
      }
    }

    // Smooth transitions between patterns - don't change pattern abruptly
    if (currentPatternType != _lastPatternType) {
      // If pattern type is changing, keep track of previous pattern and start transition
      previousPatternType = _lastPatternType;
      _lastPatternType = currentPatternType;
      _transitionProgress = 0.0; // Start transition
    } else {
      // Continue transition or maintain completed transition
      _transitionProgress = min(
        1.0,
        _transitionProgress + 0.05,
      ); // Gradually transition
    }

    // Smooth nodes and complexity transitions
    final smoothedNodes =
        _lastNodes + ((nodes - _lastNodes) * _transitionProgress).round();
    final smoothedComplexity =
        _lastComplexity + (complexity - _lastComplexity) * _transitionProgress;

    // Update last values
    _lastNodes = smoothedNodes;
    _lastComplexity = smoothedComplexity;

    // If transitioning between patterns, draw both with opacity based on transition
    if (_transitionProgress < 1.0) {
      // Draw previous pattern with fading opacity
      final previousOpacity = 1.0 - _transitionProgress;
      final previousColor = baseColor.withOpacity(
        baseColor.opacity * previousOpacity,
      );

      CymaticsPatterns.drawPattern(
        canvas,
        size,
        previousPatternType,
        smoothedNodes,
        smoothedComplexity,
        amplitude,
        animationValue,
        previousColor,
      );

      // Draw current pattern with increasing opacity
      final currentColor = baseColor.withOpacity(
        baseColor.opacity * _transitionProgress,
      );

      CymaticsPatterns.drawPattern(
        canvas,
        size,
        currentPatternType,
        smoothedNodes,
        smoothedComplexity,
        amplitude,
        animationValue,
        currentColor,
      );
    } else {
      // Just draw current pattern at full opacity
      CymaticsPatterns.drawPattern(
        canvas,
        size,
        currentPatternType,
        smoothedNodes,
        smoothedComplexity,
        amplitude,
        animationValue,
        baseColor,
      );
    }

    // Traditional circles visualization - calculate number of rings based on density
    final int rings = fullScreen
        ? (30 + density * 30).round()
        : (15 + density * 20).round();

    // Paint for drawing rings
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..shader = shader;

    for (int i = 0; i < rings; i++) {
      // Calculate ring radius and thickness
      final progress = i / rings;

      // Calculate baseRadius - larger when fullScreen is true
      final baseRadius = fullScreen
          ? progress * max(width, height) * 1.2
          : progress * width / 1.8;

      // Vary radius based on animation, frequency and amplitude
      // Now also modulate with bass level
      final bassFactor = 1.0 + (bassLevel * 3.0);

      // Make waves more pronounced when fullScreen is true but with more subtle animation
      final amplitudeFactor = fullScreen ? 40.0 : 25.0;

      // Create more complex wave patterns with additional sine waves at different frequencies
      final waveOffset =
          amplitude *
          amplitudeFactor *
          bassFactor *
          (sin(progress * frequency * 15 + animationValue * 2 * pi) * 0.6 +
              sin(progress * frequency * 8 + animationValue * 3 * pi) *
                  0.2 *
                  midLevel);

      final radius = baseRadius + waveOffset;

      // Vary stroke width based on mid level - thicker for better visibility
      final strokeWidth = fullScreen
          ? 1.2 + amplitude * (1 - progress) * 3 * (1 + midLevel)
          : 0.8 + amplitude * (1 - progress) * 2 * (1 + midLevel);
      paint.strokeWidth = strokeWidth;

      // Draw the circle with reduced opacity for a more subtle effect
      final baseOpacity = fullScreen ? 0.25 : 0.2;
      final opacityFalloff = 0.15 * progress;

      paint.color = baseColor.withOpacity(baseOpacity - opacityFalloff);
      canvas.drawCircle(center, radius.abs(), paint);
    }
  }

  @override
  bool shouldRepaint(CymaticsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.frequency != frequency ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.density != density ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.audioLevels != audioLevels ||
        oldDelegate.frequencyBands != frequencyBands ||
        oldDelegate.fullScreen != fullScreen;
  }
}
