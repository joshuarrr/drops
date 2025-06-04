import 'package:flutter/material.dart';
import 'dart:math';

/// A customizable audio frequency visualizer widget that can display
/// various frequency bands with customizable appearance
class AudioVisualizer extends StatelessWidget {
  /// The audio frequency data to visualize
  /// Values should be between 0.0 and 1.0
  final List<double> frequencyData;

  /// Number of frequency bands to display
  final int bands;

  /// Colors for the visualization
  final List<Color> colors;

  /// Whether to use gradient coloring
  final bool useGradient;

  /// The height of the visualizer
  final double height;

  /// Space between bars
  final double barSpacing;

  /// Animation duration for smoothing transitions
  final Duration animationDuration;

  /// Bar rounding radius
  final double barRadius;

  const AudioVisualizer({
    super.key,
    required this.frequencyData,
    this.bands = 16,
    this.colors = const [Colors.blue, Colors.purple],
    this.useGradient = true,
    this.height = 100,
    this.barSpacing = 2.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.barRadius = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    // Use at least one data point
    final data = frequencyData.isEmpty ? [0.0] : frequencyData;

    // Sample or stretch the frequency data to match the number of bands
    final List<double> normalizedData = _normalizeData(data, bands);

    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(bands, (index) {
          // Get the value for this band
          final value = normalizedData[index].clamp(0.05, 1.0);

          // Determine color for this bar
          Color barColor;
          if (useGradient && colors.length >= 2) {
            // Create gradient color based on index position
            final colorPosition = index / bands;
            barColor = _getGradientColor(colorPosition, value);
          } else {
            // Use single color or pick from list based on index
            barColor = colors[index % colors.length];
          }

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: barSpacing / 2),
              child: AnimatedContainer(
                duration: animationDuration,
                height: value * height,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(barRadius),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: barColor.withOpacity(0.5),
                      blurRadius: 5.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Normalize the input data to the desired number of bands
  List<double> _normalizeData(List<double> data, int targetBands) {
    if (data.length == targetBands) {
      return data;
    }

    final result = List<double>.filled(targetBands, 0.0);

    if (data.length < targetBands) {
      // Stretch data to fill bands (interpolate)
      for (int i = 0; i < targetBands; i++) {
        final position = i * (data.length - 1) / (targetBands - 1);
        final lowerIndex = position.floor();
        final upperIndex = position.ceil();

        if (lowerIndex == upperIndex) {
          result[i] = data[lowerIndex];
        } else {
          final fraction = position - lowerIndex;
          result[i] =
              data[lowerIndex] * (1 - fraction) + data[upperIndex] * fraction;
        }
      }
    } else {
      // Sample data to reduce bands (average)
      final samplesPerBand = data.length / targetBands;

      for (int i = 0; i < targetBands; i++) {
        final startSample = (i * samplesPerBand).floor();
        final endSample = ((i + 1) * samplesPerBand).floor();
        double sum = 0;

        for (int j = startSample; j < endSample; j++) {
          sum += data[j];
        }

        result[i] = sum / (endSample - startSample);
      }
    }

    return result;
  }

  /// Get a color from the gradient at the specified position (0.0 to 1.0)
  /// Also takes into account the value to increase saturation for higher values
  Color _getGradientColor(double position, double value) {
    if (colors.length < 2) {
      final opacity = (0.3 + value * 0.7).clamp(0.0, 1.0);
      return colors.first.withOpacity(opacity);
    }

    // Find the color segments
    final segmentLength = 1.0 / (colors.length - 1);
    final segment = (position / segmentLength).floor();
    final segmentPosition =
        (position - segment * segmentLength) / segmentLength;

    // Get the two colors to interpolate between
    final color1 = segment < colors.length - 1 ? colors[segment] : colors.last;
    final color2 = segment < colors.length - 1
        ? colors[segment + 1]
        : colors.last;

    // Interpolate between the colors
    final baseColor = Color.lerp(color1, color2, segmentPosition)!;

    // Adjust opacity and brightness based on value - clamp to valid ranges
    final opacity = (0.3 + value * 0.7).clamp(0.0, 1.0);
    final brightness = (0.7 + value * 0.3).clamp(0.0, 1.0);
    final saturation = (0.7 + value * 0.3).clamp(0.0, 1.0);

    // Create HSL color without alpha first
    final hslColor = HSLColor.fromColor(baseColor);

    // Apply brightness and saturation
    final adjustedHslColor = hslColor
        .withLightness((hslColor.lightness * brightness).clamp(0.0, 1.0))
        .withSaturation((hslColor.saturation * saturation).clamp(0.0, 1.0));

    // Convert back to RGB and apply opacity
    return adjustedHslColor.toColor().withOpacity(opacity);
  }
}

/// A circular audio visualizer that displays frequency data in a circular pattern
class CircularAudioVisualizer extends StatelessWidget {
  /// The audio frequency data to visualize
  /// Values should be between 0.0 and 1.0
  final List<double> frequencyData;

  /// Optional right channel data for stereo visualization
  /// If provided, the visualizer will show stereo effects
  final List<double>? rightChannelData;

  /// Number of frequency bars to display
  final int bars;

  /// Colors for the visualization
  final List<Color> colors;

  /// The size of the circular visualizer
  final double size;

  /// Animation duration for smoothing transitions
  final Duration animationDuration;

  /// Maximum bar height as a percentage of radius
  final double maxBarHeight;

  /// Bar width in radians
  final double barWidth;

  /// The base opacity for the center of the circle
  final double baseOpacity;

  /// Whether to add a pulse effect based on bass
  final bool pulsateWithBass;

  /// Bass level (0.0-1.0) for pulsating effect
  final double bassLevel;

  /// Whether to use stereo separation effects
  final bool useStereoSeparation;

  const CircularAudioVisualizer({
    super.key,
    required this.frequencyData,
    this.rightChannelData,
    this.bars = 180,
    this.colors = const [Colors.blue, Colors.purple, Colors.pink],
    this.size = 200,
    this.animationDuration = const Duration(milliseconds: 100),
    this.maxBarHeight = 0.3,
    this.barWidth = 0.03,
    this.baseOpacity = 0.2,
    this.pulsateWithBass = true,
    this.bassLevel = 0.0,
    this.useStereoSeparation = true,
  });

  @override
  Widget build(BuildContext context) {
    // Use at least one data point
    final leftData = frequencyData.isEmpty ? [0.0] : frequencyData;

    // Process right channel data for stereo effect
    final bool hasStereoData =
        rightChannelData != null &&
        rightChannelData!.isNotEmpty &&
        useStereoSeparation;

    // Use right channel data if available, otherwise use left for both
    final rightData = hasStereoData ? rightChannelData! : leftData;

    // Sample or stretch the frequency data to match the number of bars
    final List<double> normalizedLeftData = _normalizeData(leftData, bars);
    final List<double> normalizedRightData = hasStereoData
        ? _normalizeData(rightData, bars)
        : normalizedLeftData;

    // Calculate current energy level to determine animation effects
    final leftEnergyLevel = _calculateEnergyLevel(normalizedLeftData);
    final rightEnergyLevel = hasStereoData
        ? _calculateEnergyLevel(normalizedRightData)
        : leftEnergyLevel;

    // Use average energy for overall effects
    final energyLevel = (leftEnergyLevel + rightEnergyLevel) / 2.0;

    // Calculate the size modifier based on bass level for pulsating effect
    final sizeModifier = pulsateWithBass
        ? (1.0 + bassLevel.clamp(0.0, 1.0) * 0.15)
        : 1.0;
    final animatedSize = size * sizeModifier;

    // Use a more reliable approach for colors list
    final safeColors = colors.isEmpty
        ? [Colors.blue, Colors.purple, Colors.pink]
        : colors;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Main circular visualizer (left channel or mono)
        AnimatedContainer(
          duration: animationDuration,
          curve: Curves.easeOutQuad,
          width: animatedSize,
          height: animatedSize,
          child: CustomPaint(
            painter: CircularVisualizerPainter(
              leftChannelData: normalizedLeftData,
              rightChannelData: normalizedRightData,
              hasStereo: false, // Main visualizer is just the left channel
              colors: safeColors,
              maxBarHeight: maxBarHeight * (1.0 + leftEnergyLevel * 0.3),
              barWidth: barWidth,
              baseOpacity:
                  (baseOpacity +
                          (pulsateWithBass
                              ? bassLevel.clamp(0.0, 1.0) * 0.3
                              : 0.0))
                      .clamp(0.0, 1.0),
              energyLevel: leftEnergyLevel,
            ),
            size: Size(animatedSize, animatedSize),
          ),
        ),

        // Overlay right channel visualizer for stereo effect
        if (hasStereoData)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            left:
                10, // Fixed offset instead of using sin function with current time
            child: AnimatedOpacity(
              opacity: 0.7,
              duration: const Duration(milliseconds: 300),
              child: AnimatedContainer(
                duration: animationDuration,
                curve: Curves.easeInOut,
                width: animatedSize * 0.9, // Slightly smaller
                height: animatedSize * 0.9,
                child: CustomPaint(
                  painter: CircularVisualizerPainter(
                    leftChannelData:
                        normalizedRightData, // Use right channel data
                    rightChannelData: normalizedLeftData,
                    hasStereo: false,
                    colors: [
                      safeColors.last, // Swap colors for visual distinction
                      safeColors.length > 1 ? safeColors[1] : safeColors.first,
                      safeColors.first,
                    ],
                    maxBarHeight: maxBarHeight * (1.0 + rightEnergyLevel * 0.3),
                    barWidth: barWidth * 0.9, // Slightly thinner bars
                    baseOpacity: (baseOpacity * 0.8).clamp(0.0, 1.0),
                    energyLevel: rightEnergyLevel,
                  ),
                  size: Size(animatedSize * 0.9, animatedSize * 0.9),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Calculate the energy level of the audio from the frequency data
  double _calculateEnergyLevel(List<double> data) {
    if (data.isEmpty) return 0.0;

    // Calculate the average of all frequency values
    double sum = 0.0;
    for (final value in data) {
      sum += value;
    }

    // Return average energy level, with emphasis on higher values
    double average = sum / data.length;

    // Apply a non-linear curve to emphasize higher energy moments
    return (average * 0.7 + (average * average) * 0.3).clamp(0.0, 1.0);
  }

  /// Normalize the input data to the desired number of bands
  List<double> _normalizeData(List<double> data, int targetBars) {
    if (data.length == targetBars) {
      return data;
    }

    final result = List<double>.filled(targetBars, 0.0);

    if (data.length < targetBars) {
      // Stretch data to fill bars (interpolate)
      for (int i = 0; i < targetBars; i++) {
        final position = i * (data.length - 1) / (targetBars - 1);
        final lowerIndex = position.floor();
        final upperIndex = position.ceil();

        if (lowerIndex == upperIndex) {
          result[i] = data[lowerIndex];
        } else {
          final fraction = position - lowerIndex;
          result[i] =
              data[lowerIndex] * (1 - fraction) + data[upperIndex] * fraction;
        }
      }
    } else {
      // Sample data to reduce bars (average)
      final samplesPerBar = data.length / targetBars;

      for (int i = 0; i < targetBars; i++) {
        final startSample = (i * samplesPerBar).floor();
        final endSample = ((i + 1) * samplesPerBar).floor();
        double sum = 0;

        for (int j = startSample; j < endSample; j++) {
          sum += data[j];
        }

        result[i] = sum / (endSample - startSample);
      }
    }

    // Apply smoothing between adjacent values to reduce jittering
    final smoothedResult = List<double>.filled(targetBars, 0.0);
    for (int i = 0; i < targetBars; i++) {
      // Take weighted average of current value and neighbors
      double value = result[i] * 0.6; // 60% current value

      // Add 20% of previous value if available
      if (i > 0) {
        value += result[i - 1] * 0.2;
      } else {
        value += result[targetBars - 1] * 0.2; // Wrap around for first element
      }

      // Add 20% of next value if available
      if (i < targetBars - 1) {
        value += result[i + 1] * 0.2;
      } else {
        value += result[0] * 0.2; // Wrap around for last element
      }

      smoothedResult[i] = value;
    }

    return smoothedResult;
  }
}

/// Custom painter for the circular audio visualizer
class CircularVisualizerPainter extends CustomPainter {
  final List<double> leftChannelData;
  final List<double> rightChannelData;
  final bool hasStereo;
  final List<Color> colors;
  final double maxBarHeight;
  final double barWidth;
  final double baseOpacity;
  final double energyLevel;

  CircularVisualizerPainter({
    required this.leftChannelData,
    required this.rightChannelData,
    this.hasStereo = false,
    required this.colors,
    required this.maxBarHeight,
    required this.barWidth,
    required this.baseOpacity,
    this.energyLevel = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Ensure we have valid data
    if (leftChannelData.isEmpty || size.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Ensure colors list is not empty
    final safeColors = colors.isEmpty
        ? [Colors.blue, Colors.purple, Colors.pink]
        : colors;

    // Draw tunnel effect with multiple concentric circles
    // Each circle has a gradient that creates depth perception
    final tunnelLayers = 12;
    for (int i = 0; i < tunnelLayers; i++) {
      // Modified radius calculation for bigger concentric circles
      final layerRadius = radius * (1.0 - (i / tunnelLayers) * 0.25);
      final nextLayerRadius = radius * (1.0 - ((i + 1) / tunnelLayers) * 0.25);

      // Create gradient that gives depth perception
      final tunnelGradient = RadialGradient(
        colors: [
          safeColors.first.withOpacity((0.35 - i * 0.03).clamp(0.0, 1.0)),
          safeColors.last.withOpacity((0.15 - i * 0.01).clamp(0.0, 1.0)),
        ],
        stops: const [0.0, 1.0],
        radius: 1.0 + (energyLevel * 0.4),
      );

      final tunnelRect = Rect.fromCircle(center: center, radius: layerRadius);
      final tunnelShader = tunnelGradient.createShader(tunnelRect);

      final tunnelPaint = Paint()
        ..shader = tunnelShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = layerRadius - nextLayerRadius + (energyLevel * 4.0);

      // Add wobble effect to the circles for a more dynamic tunnel
      final wobbleAmount = 3.0 + (energyLevel * 6.0);
      final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
      final wobbleX = sin(time * (1.0 + i * 0.2)) * wobbleAmount;
      final wobbleY = cos(time * (0.8 + i * 0.2)) * wobbleAmount;

      final wobbleCenter = Offset(center.dx + wobbleX, center.dy + wobbleY);

      canvas.drawCircle(wobbleCenter, layerRadius, tunnelPaint);
    }

    // Add background rotation effect based on energy level (clamped for safety)
    final safeEnergyLevel = energyLevel.clamp(0.0, 1.0);
    final rotationAngle = safeEnergyLevel * 0.05;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    // Draw background patterns for higher energy levels
    if (safeEnergyLevel > 0.3) {
      final patternOpacity = ((safeEnergyLevel - 0.3) / 0.7).clamp(0.0, 0.7);
      final patternPaint = Paint()
        ..color = safeColors.first.withOpacity(patternOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      // Draw radiating circles starting from a larger radius to avoid center shapes
      for (double r = 0.55; r <= 1.0; r += 0.13) {
        canvas.drawCircle(center, radius * r, patternPaint);
      }

      // Draw crossing lines that don't go through the center
      final lineCount = (10 + safeEnergyLevel * 14).round();

      // Save the current state before drawing the lines
      canvas.save();

      // Create a path for lines that avoid the center
      for (int i = 0; i < lineCount; i++) {
        final angle = i * pi / lineCount;
        final dx = cos(angle) * radius;
        final dy = sin(angle) * radius;

        // Calculate points that avoid the center
        final centerRadius = radius * 0.55;
        final startX = center.dx + centerRadius * cos(angle);
        final startY = center.dy + centerRadius * sin(angle);
        final endX = center.dx + radius * cos(angle);
        final endY = center.dy + radius * sin(angle);

        // Draw line from inner radius to outer edge (first half)
        canvas.drawLine(
          Offset(startX, startY),
          Offset(endX, endY),
          patternPaint,
        );

        // Draw line from inner radius to outer edge (second half)
        canvas.drawLine(
          Offset(
            center.dx - centerRadius * cos(angle),
            center.dy - centerRadius * sin(angle),
          ),
          Offset(
            center.dx - radius * cos(angle),
            center.dy - radius * sin(angle),
          ),
          patternPaint,
        );
      }

      // Restore after drawing the lines
      canvas.restore();

      // Save again for further drawing
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotationAngle);
      canvas.translate(-center.dx, -center.dy);
    }

    // Draw frequency bars
    final barCount = leftChannelData.length;
    final angleIncrement = 2 * pi / barCount;

    // Add a subtle oscillation effect to the bars
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    final oscillationSpeed =
        1.0 + safeEnergyLevel * 2.0; // Faster oscillation with higher energy

    for (int i = 0; i < barCount; i++) {
      // Apply a smooth oscillation to adjust positions slightly based on time
      final oscillation =
          sin(time * oscillationSpeed + i * 0.1) * 0.05 * safeEnergyLevel;
      final angle = i * angleIncrement + oscillation;

      // Determine stereo position - left channel is in left half, right channel in right half
      final bool isLeftHalf = angle < pi; // 0 to π is left half

      // Get value with bass boost for lower frequencies
      double value;

      if (hasStereo && rightChannelData.isNotEmpty) {
        // In stereo mode, use left channel data for left half, right channel for right half
        // Also blend at the boundaries for smooth transition
        if (isLeftHalf) {
          // Left half - primarily left channel
          value = leftChannelData[i].clamp(0.0, 1.0);

          // Blend a bit of right channel near the boundary (at π/2 and 3π/2)
          final blendFactor = sin(angle).abs(); // 0 at 0 and π, 1 at π/2
          value =
              value * (1.0 - blendFactor * 0.3) +
              rightChannelData[i % rightChannelData.length] *
                  (blendFactor * 0.3);
        } else {
          // Right half - primarily right channel
          value = rightChannelData[i % rightChannelData.length].clamp(0.0, 1.0);

          // Blend a bit of left channel near the boundary
          final blendFactor = sin(angle).abs(); // 0 at 0 and π, 1 at π/2
          value =
              value * (1.0 - blendFactor * 0.3) +
              leftChannelData[i] * (blendFactor * 0.3);
        }
      } else {
        // In mono mode, use left channel data for everything
        value = leftChannelData[i].clamp(0.0, 1.0);
      }

      // Apply bass boost to lower frequencies
      if (i < barCount / 3) {
        // Add extra boost to bass frequencies
        value = (value * (1.0 + safeEnergyLevel * 0.5)).clamp(0.0, 1.0);
      }

      // Apply dynamic scaling based on position and energy
      final positionFactor = sin(i * 8 / barCount * pi) * 0.3 + 0.7;
      value = (value * positionFactor * (1.0 + safeEnergyLevel * 0.3)).clamp(
        0.0,
        1.0,
      );

      // For stereo mode, add a slight channel emphasis
      if (hasStereo) {
        // Emphasize stereo separation for more dramatic effect
        final stereoEmphasis = isLeftHalf
            ? 1.1
            : 1.1; // Slightly boost both channels
        value = (value * stereoEmphasis).clamp(0.0, 1.0);
      }

      // Determine bar height - now with increased length based on amplitude
      // Increase maxBarHeight by up to 2x with higher energy levels
      final dynamicMaxBarHeight = maxBarHeight * (1.0 + safeEnergyLevel);
      final barHeight = radius * dynamicMaxBarHeight * value;
      if (barHeight < 0.5) continue; // Skip very tiny bars for performance

      // Determine bar color based on position and value
      final colorPosition = i / barCount;

      // For stereo, slightly shift the color balance
      final adjustedColorPosition = hasStereo
          ? (isLeftHalf
                ? colorPosition *
                      0.9 // Shift left channel toward first color
                : colorPosition * 1.1) // Shift right channel toward last color
          : colorPosition;

      final Color barColor = _getGradientColor(
        adjustedColorPosition.clamp(0.0, 1.0),
        value,
      );

      // Create paint for the bar
      final barPaint = Paint()
        ..color = barColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth =
            radius *
            barWidth *
            (1.0 + value * 0.5); // Thicker bars for higher values

      // Calculate dynamic inner radius for tunnel effect - INCREASE THIS VALUE to avoid center blob
      final innerRadiusFactor =
          0.5; // Larger inner radius (was 0.35) to avoid center blob
      final innerRadius = radius * innerRadiusFactor;

      // Calculate bar coordinates with slight curve
      final startX = center.dx + innerRadius * cos(angle);
      final startY = center.dy + innerRadius * sin(angle);

      // Add a slight curve to the bars for higher energy levels
      final curveFactor = safeEnergyLevel * 0.2;
      final midPointDistance = innerRadius + barHeight * 0.5;
      final midPointAngle = angle + curveFactor * sin(i * 0.1);
      final midX = center.dx + midPointDistance * cos(midPointAngle);
      final midY = center.dy + midPointDistance * sin(midPointAngle);

      final endX = center.dx + (innerRadius + barHeight) * cos(angle);
      final endY = center.dy + (innerRadius + barHeight) * sin(angle);

      // Draw bar with glow effect for higher values
      if (value > 0.7) {
        // Add glow effect for high energy bars
        final glowPaint = Paint()
          ..color = barColor.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = radius * barWidth * (1.0 + value) * 3.0;

        canvas.drawLine(Offset(startX, startY), Offset(endX, endY), glowPaint);
      }

      // Draw the main bar
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), barPaint);
    }

    canvas.restore();
  }

  /// Get a color from the gradient at the specified position (0.0 to 1.0)
  /// Also takes into account the value to increase saturation for higher values
  Color _getGradientColor(double position, double value) {
    if (colors.length < 2) {
      final opacity = (0.3 + value * 0.7).clamp(0.0, 1.0);
      return colors.first.withOpacity(opacity);
    }

    // Find the color segments
    final segmentLength = 1.0 / (colors.length - 1);
    final segment = (position / segmentLength).floor();
    final segmentPosition =
        (position - segment * segmentLength) / segmentLength;

    // Get the two colors to interpolate between
    final color1 = segment < colors.length - 1 ? colors[segment] : colors.last;
    final color2 = segment < colors.length - 1
        ? colors[segment + 1]
        : colors.last;

    // Interpolate between the colors
    final baseColor = Color.lerp(color1, color2, segmentPosition)!;

    // Adjust opacity and brightness based on value - clamp to valid ranges
    final opacity = (0.3 + value * 0.7).clamp(0.0, 1.0);
    final brightness = (0.7 + value * 0.3).clamp(0.0, 1.0);
    final saturation = (0.7 + value * 0.3).clamp(0.0, 1.0);

    // Create HSL color without alpha first
    final hslColor = HSLColor.fromColor(baseColor);

    // Apply brightness and saturation
    final adjustedHslColor = hslColor
        .withLightness((hslColor.lightness * brightness).clamp(0.0, 1.0))
        .withSaturation((hslColor.saturation * saturation).clamp(0.0, 1.0));

    // Convert back to RGB and apply opacity
    return adjustedHslColor.toColor().withOpacity(opacity);
  }

  @override
  bool shouldRepaint(CircularVisualizerPainter oldDelegate) {
    return oldDelegate.leftChannelData != leftChannelData ||
        oldDelegate.rightChannelData != rightChannelData ||
        oldDelegate.hasStereo != hasStereo ||
        oldDelegate.colors != colors ||
        oldDelegate.maxBarHeight != maxBarHeight ||
        oldDelegate.barWidth != barWidth ||
        oldDelegate.baseOpacity != baseOpacity ||
        oldDelegate.energyLevel != energyLevel;
  }
}
