import 'dart:math';
import 'package:flutter/material.dart';

/// Pattern types for cymatics visualization
enum PatternType {
  simpleCircular,
  segmentedRings,
  triangularSymmetry,
  complexSymmetry,
  flowerOfLife,
  mandalaStructure,
  chaotic,
}

/// Defines frequency-specific cymatics patterns and their characteristics
/// Based on actual cymatics research where different frequencies create distinct patterns
class CymaticsPatterns {
  /// Frequency ranges in Hz and their typical cymatics patterns
  static const Map<String, Map<String, dynamic>> frequencyPatterns = {
    'sub_bass': {
      'range': [20, 60],
      'pattern': PatternType.simpleCircular,
      'nodes': 2,
      'complexity': 0.2,
      'description': 'Simple circular patterns with minimal detail',
    },
    'bass': {
      'range': [60, 250],
      'pattern': PatternType.segmentedRings,
      'nodes': 4,
      'complexity': 0.4,
      'description': 'Segmented rings with emerging symmetrical divisions',
    },
    'low_mid': {
      'range': [250, 500],
      'pattern': PatternType.triangularSymmetry,
      'nodes': 6,
      'complexity': 0.5,
      'description': 'Triangular symmetry patterns with 6-fold geometry',
    },
    'mid': {
      'range': [500, 2000],
      'pattern': PatternType.complexSymmetry,
      'nodes': 8,
      'complexity': 0.7,
      'description': 'Complex symmetrical patterns with 8-12 segments',
    },
    'high_mid': {
      'range': [2000, 4000],
      'pattern': PatternType.flowerOfLife,
      'nodes': 12,
      'complexity': 0.8,
      'description':
          'Intricate flower of life patterns with multiple overlapping circles',
    },
    'high': {
      'range': [4000, 6000],
      'pattern': PatternType.mandalaStructure,
      'nodes': 16,
      'complexity': 0.9,
      'description': 'Detailed mandala-like structures with fine details',
    },
    'very_high': {
      'range': [6000, 20000],
      'pattern': PatternType.chaotic,
      'nodes': 24,
      'complexity': 1.0,
      'description': 'Chaotic patterns with fine crystal-like structures',
    },
  };

  /// Get the appropriate cymatics pattern for a specific frequency
  static Map<String, dynamic> getPatternForFrequency(double frequency) {
    // Default pattern if frequency is outside known ranges
    Map<String, dynamic> result = {
      'pattern': PatternType.simpleCircular,
      'nodes': 4,
      'complexity': 0.5,
    };

    // Find the matching frequency range
    for (final entry in frequencyPatterns.entries) {
      final range = entry.value['range'] as List<int>;
      if (frequency >= range[0] && frequency <= range[1]) {
        return entry.value;
      }
    }

    return result;
  }

  /// Generate a pattern based on a set of frequencies and their amplitudes
  static Map<String, dynamic> generateCompositePattern(
    List<double> frequencies,
    List<double> amplitudes,
  ) {
    if (frequencies.isEmpty ||
        amplitudes.isEmpty ||
        frequencies.length != amplitudes.length) {
      return {
        'pattern': PatternType.simpleCircular,
        'nodes': 4,
        'complexity': 0.5,
        'dominantFrequency': 0.0,
      };
    }

    // Find the dominant frequency (highest amplitude)
    int dominantIndex = 0;
    double maxAmplitude = amplitudes[0];
    for (int i = 1; i < amplitudes.length; i++) {
      if (amplitudes[i] > maxAmplitude) {
        maxAmplitude = amplitudes[i];
        dominantIndex = i;
      }
    }

    // Get base pattern from dominant frequency
    final dominantFrequency = frequencies[dominantIndex];
    final basePattern = getPatternForFrequency(dominantFrequency);

    // Calculate weighted average of nodes and complexity
    double totalNodes = 0;
    double totalComplexity = 0;
    double totalWeight = 0;

    for (int i = 0; i < frequencies.length; i++) {
      final pattern = getPatternForFrequency(frequencies[i]);
      final weight = amplitudes[i];

      totalNodes += (pattern['nodes'] as int) * weight;
      totalComplexity += (pattern['complexity'] as double) * weight;
      totalWeight += weight;
    }

    // Calculate final values
    final int averageNodes = (totalNodes / totalWeight).round();
    final double averageComplexity = totalComplexity / totalWeight;

    return {
      'pattern': basePattern['pattern'],
      'nodes': averageNodes,
      'complexity': averageComplexity,
      'dominantFrequency': dominantFrequency,
    };
  }

  /// Draw a specific cymatics pattern on a canvas
  static void drawPattern(
    Canvas canvas,
    Size size,
    PatternType patternType,
    int nodes,
    double complexity,
    double amplitude,
    double animationValue,
    Color baseColor,
  ) {
    final center = Offset(size.width / 2, size.height / 2);

    // Significantly increase the radius to fill the screen
    final radius = max(size.width, size.height) * 0.6;

    // Use more opaque color for all patterns
    final enhancedColor = baseColor.withOpacity(0.8);

    switch (patternType) {
      case PatternType.simpleCircular:
        _drawSimpleCircularPattern(
          canvas,
          center,
          radius,
          nodes,
          complexity,
          amplitude,
          animationValue,
          enhancedColor,
        );
        break;
      case PatternType.segmentedRings:
        _drawSegmentedRingsPattern(
          canvas,
          center,
          radius,
          nodes,
          complexity,
          amplitude,
          animationValue,
          enhancedColor,
        );
        break;
      case PatternType.triangularSymmetry:
        _drawTriangularSymmetryPattern(
          canvas,
          center,
          radius,
          nodes,
          complexity,
          amplitude,
          animationValue,
          enhancedColor,
        );
        break;
      case PatternType.complexSymmetry:
        _drawComplexSymmetryPattern(
          canvas,
          center,
          radius,
          nodes,
          complexity,
          amplitude,
          animationValue,
          enhancedColor,
        );
        break;
      case PatternType.flowerOfLife:
        _drawFlowerOfLifePattern(
          canvas,
          center,
          radius,
          nodes,
          complexity,
          amplitude,
          animationValue,
          enhancedColor,
        );
        break;
      case PatternType.mandalaStructure:
        _drawMandalaStructurePattern(
          canvas,
          center,
          radius,
          nodes,
          complexity,
          amplitude,
          animationValue,
          enhancedColor,
        );
        break;
      case PatternType.chaotic:
        _drawChaoticPattern(
          canvas,
          center,
          radius,
          nodes,
          complexity,
          amplitude,
          animationValue,
          enhancedColor,
        );
        break;
    }
  }

  /// Simple circular pattern (20-60 Hz)
  static void _drawSimpleCircularPattern(
    Canvas canvas,
    Offset center,
    double radius,
    int nodes,
    double complexity,
    double amplitude,
    double animationValue,
    Color baseColor,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = baseColor
      ..strokeWidth = 2.5; // Increased thickness for better visibility

    // Draw concentric circles with smoother animation
    final minNodeIndex = (nodes * 0.2).ceil(); // Skip fewer inner circles

    // Draw more circles for a denser pattern
    final totalCircles = nodes * 2;

    for (int i = minNodeIndex; i < totalCircles; i++) {
      final progress = i / totalCircles;
      final ringRadius = radius * progress;

      // Smoother wave motion with slower animation
      final waveOffset =
          amplitude * 15 * sin(progress * 10 + animationValue * pi);

      // Make stroke width vary with radius for better aesthetics
      paint.strokeWidth = 1.5 + (1.0 - progress) * 2.0;

      // Adjust opacity based on radius - inner circles are more visible
      paint.color = baseColor.withOpacity(0.7 - progress * 0.3);

      canvas.drawCircle(center, ringRadius + waveOffset, paint);
    }
  }

  /// Segmented rings pattern (60-250 Hz)
  static void _drawSegmentedRingsPattern(
    Canvas canvas,
    Offset center,
    double radius,
    int nodes,
    double complexity,
    double amplitude,
    double animationValue,
    Color baseColor,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = baseColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round; // Rounded ends for smoother appearance

    // Draw multiple rings with continuous animation
    final ringCount = 5; // Increased from 3 to 5 rings

    for (int i = 1; i <= ringCount; i++) {
      final ringRadius = radius * i / ringCount;

      // Draw complete circles instead of arcs for more continuity
      // Add wave effect for animation
      final waveOffset = amplitude * 10 * sin(animationValue * 2 * pi + i);
      final modulatedRadius = ringRadius + waveOffset;

      // Vary stroke width by ring position
      paint.strokeWidth = 3.0 - (i / ringCount) * 1.5;

      // Vary opacity by ring
      paint.color = baseColor.withOpacity(0.9 - (i / ringCount) * 0.3);

      canvas.drawCircle(center, modulatedRadius, paint);

      // Add subtle secondary rings for complex patterns
      if (complexity > 0.5) {
        final secondaryRadius = ringRadius * 0.9;
        paint.strokeWidth = 1.0;
        paint.color = baseColor.withOpacity(0.5);

        // Add wave offset in opposite phase
        final secondaryWaveOffset =
            amplitude * 5 * sin(animationValue * 3 * pi + i + pi);
        canvas.drawCircle(center, secondaryRadius + secondaryWaveOffset, paint);
      }
    }

    // Add radial lines that connect the rings for higher complexity
    if (complexity > 0.4) {
      paint.strokeWidth = 1.5;
      paint.color = baseColor.withOpacity(0.6);

      final lineCount = max(8, nodes);
      for (int j = 0; j < lineCount; j++) {
        final angle = j * 2 * pi / lineCount + animationValue * pi / 4;
        final innerPoint = Offset(
          center.dx + (radius * 0.3) * cos(angle),
          center.dy + (radius * 0.3) * sin(angle),
        );
        final outerPoint = Offset(
          center.dx + radius * cos(angle),
          center.dy + radius * sin(angle),
        );

        canvas.drawLine(innerPoint, outerPoint, paint);
      }
    }
  }

  /// Triangular symmetry pattern (250-500 Hz)
  static void _drawTriangularSymmetryPattern(
    Canvas canvas,
    Offset center,
    double radius,
    int nodes,
    double complexity,
    double amplitude,
    double animationValue,
    Color baseColor,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = baseColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Draw a complete triangular pattern rather than disconnected lines
    final adjustedNodes = max(6, nodes);
    final outerPoints = <Offset>[];

    // Calculate outer points of the polygon
    for (int i = 0; i < adjustedNodes; i++) {
      final angle = i * 2 * pi / adjustedNodes + animationValue * pi / 8;
      final r =
          radius * (1.0 + amplitude * 0.2 * sin(animationValue * 3 + i * 0.5));
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      outerPoints.add(Offset(x, y));
    }

    // Draw outer polygon
    final outerPath = Path();
    for (int i = 0; i < outerPoints.length; i++) {
      if (i == 0) {
        outerPath.moveTo(outerPoints[i].dx, outerPoints[i].dy);
      } else {
        outerPath.lineTo(outerPoints[i].dx, outerPoints[i].dy);
      }
    }
    outerPath.close();
    paint.color = baseColor.withOpacity(0.8);
    canvas.drawPath(outerPath, paint);

    // Draw inner polygon for visual depth
    if (complexity > 0.4) {
      final innerPath = Path();
      final innerRadius = radius * 0.6;

      for (int i = 0; i < adjustedNodes; i++) {
        final angle = i * 2 * pi / adjustedNodes + animationValue * pi / 6;
        final r =
            innerRadius *
            (1.0 + amplitude * 0.1 * sin(animationValue * 4 + i * 0.5));
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);

        if (i == 0) {
          innerPath.moveTo(x, y);
        } else {
          innerPath.lineTo(x, y);
        }
      }

      innerPath.close();
      paint.color = baseColor.withOpacity(0.7);
      paint.strokeWidth = 1.5;
      canvas.drawPath(innerPath, paint);
    }

    // Draw connecting lines between inner and outer shapes for high complexity
    if (complexity > 0.6) {
      paint.color = baseColor.withOpacity(0.6);
      paint.strokeWidth = 1.0;

      // Draw every other connecting line for cleaner look
      for (int i = 0; i < adjustedNodes; i += 2) {
        final outerPoint = outerPoints[i];
        final angle = i * 2 * pi / adjustedNodes + animationValue * pi / 6;
        final innerRadius = radius * 0.6;
        final innerX = center.dx + innerRadius * cos(angle);
        final innerY = center.dy + innerRadius * sin(angle);

        canvas.drawLine(Offset(innerX, innerY), outerPoint, paint);
      }
    }
  }

  /// Complex symmetry pattern (500-2000 Hz)
  static void _drawComplexSymmetryPattern(
    Canvas canvas,
    Offset center,
    double radius,
    int nodes,
    double complexity,
    double amplitude,
    double animationValue,
    Color baseColor,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = baseColor.withOpacity(0.8)
      ..strokeWidth = 1.2;

    // Draw complex symmetrical pattern
    final path = Path();
    final adjustedNodes = max(8, nodes); // Ensure at least 8 nodes

    // Draw outer pattern
    for (int i = 0; i < adjustedNodes; i++) {
      final angle1 = i * 2 * pi / adjustedNodes + animationValue * pi;
      final angle2 =
          ((i + 2) % adjustedNodes) * 2 * pi / adjustedNodes +
          animationValue * pi;

      // Apply amplitude modulation
      final r1 =
          radius * (1.0 + amplitude * 0.2 * sin(i * 0.5 + animationValue * 4));
      final r2 =
          radius *
          (1.0 + amplitude * 0.2 * sin((i + 2) * 0.5 + animationValue * 4));

      final x1 = center.dx + r1 * cos(angle1);
      final y1 = center.dy + r1 * sin(angle1);
      final x2 = center.dx + r2 * cos(angle2);
      final y2 = center.dy + r2 * sin(angle2);

      // Draw connecting lines
      if (i % 2 == 0 || complexity > 0.6) {
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
      }

      // Add points at vertices
      if (i == 0) {
        path.moveTo(x1, y1);
      } else {
        path.lineTo(x1, y1);
      }
    }

    path.close();
    canvas.drawPath(path, paint);

    // Add inner details if complexity is high enough
    if (complexity > 0.5) {
      final innerPath = Path();
      final innerRadius = radius * 0.6;

      for (int i = 0; i < adjustedNodes; i++) {
        final angle = i * 2 * pi / adjustedNodes + animationValue * pi * 1.5;
        final r =
            innerRadius * (1.0 + amplitude * 0.3 * sin(i + animationValue * 3));
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);

        if (i == 0) {
          innerPath.moveTo(x, y);
        } else {
          innerPath.lineTo(x, y);
        }
      }

      innerPath.close();
      canvas.drawPath(innerPath, paint);
    }
  }

  /// Flower of Life pattern (2000-4000 Hz)
  static void _drawFlowerOfLifePattern(
    Canvas canvas,
    Offset center,
    double radius,
    int nodes,
    double complexity,
    double amplitude,
    double animationValue,
    Color baseColor,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = baseColor.withOpacity(0.9)
      ..strokeWidth = 2.0;

    // Number of circles in the flower pattern
    final circleCount = min(24, max(7, nodes));

    // Add a central circle with pulsating animation
    final centralPulse = 1.0 + (amplitude * 0.3 * sin(animationValue * pi));
    final centralRadius = radius / 4.0 * centralPulse;
    canvas.drawCircle(center, centralRadius, paint);

    // Draw surrounding circles in the first layer
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3 + animationValue * pi / 6;
      final circleDistance = radius * 0.4;
      final x = center.dx + circleDistance * cos(angle);
      final y = center.dy + circleDistance * sin(angle);

      final modulatedRadius =
          radius /
          4.0 *
          (1.0 + amplitude * 0.2 * sin(animationValue * 2 * pi + i));
      canvas.drawCircle(Offset(x, y), modulatedRadius, paint);
    }

    // Second layer of circles
    if (complexity > 0.4 && circleCount > 7) {
      paint.strokeWidth = 1.8;

      for (int j = 0; j < 12; j++) {
        final angle = j * pi / 6 + animationValue * pi / 8;
        final distance = radius * 0.7;
        final x = center.dx + distance * cos(angle);
        final y = center.dy + distance * sin(angle);

        final modulatedRadius =
            radius /
            4.5 *
            (1.0 + amplitude * 0.15 * sin(animationValue * 3 * pi + j));
        canvas.drawCircle(Offset(x, y), modulatedRadius, paint);
      }
    }

    // Third layer - outer circles
    if (complexity > 0.7 && circleCount > 13) {
      paint.strokeWidth = 1.5;

      for (int k = 0; k < 12; k++) {
        final angle = k * 2 * pi / 12 + animationValue * pi / 10;
        final distance = radius * 0.9;
        final x = center.dx + distance * cos(angle);
        final y = center.dy + distance * sin(angle);

        final modulatedRadius =
            radius /
            5.0 *
            (1.0 + amplitude * 0.1 * sin(animationValue * 4 * pi + k));
        canvas.drawCircle(Offset(x, y), modulatedRadius, paint);
      }
    }
  }

  /// Mandala structure pattern (4000-6000 Hz)
  static void _drawMandalaStructurePattern(
    Canvas canvas,
    Offset center,
    double radius,
    int nodes,
    double complexity,
    double amplitude,
    double animationValue,
    Color baseColor,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = baseColor.withOpacity(0.6)
      ..strokeWidth = 0.8;

    // Draw the mandala base, avoiding the inner circle
    final outerRadius = radius;
    final middleRadius = radius * 0.7;
    // Removed innerRadius to avoid center blob

    canvas.drawCircle(center, outerRadius, paint);
    canvas.drawCircle(center, middleRadius, paint);
    // Removed inner circle

    // Draw radiating spokes
    final adjustedNodes = max(12, nodes);
    final spokePath = Path();

    for (int i = 0; i < adjustedNodes; i++) {
      final angle = i * 2 * pi / adjustedNodes + animationValue * pi / 2;

      final outerX = center.dx + outerRadius * cos(angle);
      final outerY = center.dy + outerRadius * sin(angle);

      // Modify to start spokes from middle radius instead of center
      final midX = center.dx + middleRadius * 0.5 * cos(angle);
      final midY = center.dy + middleRadius * 0.5 * sin(angle);

      // Amplitude modulation for outer points
      final modulatedOuterX =
          outerX + amplitude * 5 * sin(animationValue * 4 + i);
      final modulatedOuterY =
          outerY + amplitude * 5 * cos(animationValue * 4 + i);

      // Draw lines starting from mid radius, not center
      canvas.drawLine(
        Offset(midX, midY),
        Offset(modulatedOuterX, modulatedOuterY),
        paint,
      );

      // Add decorative elements at spoke intersections
      if (i % 2 == 0 && complexity > 0.6) {
        final decorX = center.dx + middleRadius * cos(angle);
        final decorY = center.dy + middleRadius * sin(angle);
        canvas.drawCircle(Offset(decorX, decorY), 3, paint);
      }

      // Connect adjacent points along outer circle if complexity is high
      if (complexity > 0.7) {
        final nextAngle =
            ((i + 1) % adjustedNodes) * 2 * pi / adjustedNodes +
            animationValue * pi / 2;
        final nextOuterX = center.dx + outerRadius * cos(nextAngle);
        final nextOuterY = center.dy + outerRadius * sin(nextAngle);

        final nextModulatedOuterX =
            nextOuterX + amplitude * 5 * sin(animationValue * 4 + i + 1);
        final nextModulatedOuterY =
            nextOuterY + amplitude * 5 * cos(animationValue * 4 + i + 1);

        canvas.drawLine(
          Offset(modulatedOuterX, modulatedOuterY),
          Offset(nextModulatedOuterX, nextModulatedOuterY),
          paint,
        );
      }
    }

    // Add intricate details for very complex mandalas
    if (complexity > 0.9) {
      paint.strokeWidth = 0.5;

      // Draw petal-like structures
      for (int i = 0; i < adjustedNodes; i++) {
        final angle = i * 2 * pi / adjustedNodes + animationValue * pi / 3;
        final controlRadius = middleRadius * 1.3;

        final startX = center.dx + middleRadius * cos(angle);
        final startY = center.dy + middleRadius * sin(angle);

        final endX = center.dx + middleRadius * cos(angle + pi / adjustedNodes);
        final endY = center.dy + middleRadius * sin(angle + pi / adjustedNodes);

        final controlX =
            center.dx + controlRadius * cos(angle + pi / (adjustedNodes * 2));
        final controlY =
            center.dy + controlRadius * sin(angle + pi / (adjustedNodes * 2));

        final petalPath = Path();
        petalPath.moveTo(startX, startY);
        petalPath.quadraticBezierTo(controlX, controlY, endX, endY);

        // Don't connect back to center
        petalPath.lineTo(
          center.dx + middleRadius * 0.6 * cos(angle + pi / adjustedNodes),
          center.dy + middleRadius * 0.6 * sin(angle + pi / adjustedNodes),
        );
        petalPath.lineTo(
          center.dx + middleRadius * 0.6 * cos(angle),
          center.dy + middleRadius * 0.6 * sin(angle),
        );
        petalPath.close();

        canvas.drawPath(petalPath, paint);
      }
    }
  }

  /// Chaotic pattern (6000-20000 Hz)
  static void _drawChaoticPattern(
    Canvas canvas,
    Offset center,
    double radius,
    int nodes,
    double complexity,
    double amplitude,
    double animationValue,
    Color baseColor,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = baseColor.withOpacity(0.5)
      ..strokeWidth = 0.7;

    // Create a more chaotic, crystal-like pattern
    // High frequency cymatics often create fine, intricate patterns
    final adjustedNodes = max(24, nodes);
    final random = Random(adjustedNodes); // Deterministic randomness

    // Draw primary structure
    final points = <Offset>[];
    for (int i = 0; i < adjustedNodes; i++) {
      final angle = i * 2 * pi / adjustedNodes + animationValue * pi / 2;

      // Add some randomness to the radius
      final randomFactor = 0.8 + random.nextDouble() * 0.4;
      final r =
          radius *
          randomFactor *
          (1.0 + amplitude * 0.2 * sin(i * 3 + animationValue * 8));

      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);

      points.add(Offset(x, y));
    }

    // Connect points in a chaotic web
    for (int i = 0; i < points.length; i++) {
      // Connect to several other random points
      final connectionCount = (complexity * 5).round();
      for (int j = 0; j < connectionCount; j++) {
        // Choose connection strategy based on position
        final targetIndex = (i + j * 3) % points.length;

        // Modulate line opacity based on animation
        paint.color = baseColor.withOpacity(
          0.3 + 0.2 * sin(animationValue * 2 + i * 0.1),
        );

        canvas.drawLine(points[i], points[targetIndex], paint);
      }
    }

    // Add crystalline structures at high complexity
    if (complexity > 0.7) {
      paint.strokeWidth = 0.5;

      // Draw additional geometric elements
      for (int i = 0; i < points.length; i += 2) {
        if (random.nextDouble() > 0.3) {
          final path = Path();
          final x1 = points[i].dx;
          final y1 = points[i].dy;
          final x2 = points[(i + 1) % points.length].dx;
          final y2 = points[(i + 1) % points.length].dy;
          final x3 = points[(i + 2) % points.length].dx;
          final y3 = points[(i + 2) % points.length].dy;

          path.moveTo(x1, y1);
          path.lineTo(x2, y2);
          path.lineTo(x3, y3);
          path.close();

          canvas.drawPath(path, paint);
        }
      }
    }

    // Highest complexity adds fractal-like elements
    if (complexity > 0.9) {
      paint.strokeWidth = 0.3;

      // Add smaller detailed elements
      for (int i = 0; i < points.length; i++) {
        final fractalRadius = radius * 0.2;
        final fractalCenter = points[i];

        for (int j = 0; j < 5; j++) {
          final fractalAngle = random.nextDouble() * 2 * pi;
          final fractalR = fractalRadius * random.nextDouble();

          final fractalX = fractalCenter.dx + fractalR * cos(fractalAngle);
          final fractalY = fractalCenter.dy + fractalR * sin(fractalAngle);

          canvas.drawLine(fractalCenter, Offset(fractalX, fractalY), paint);
        }
      }
    }
  }
}
