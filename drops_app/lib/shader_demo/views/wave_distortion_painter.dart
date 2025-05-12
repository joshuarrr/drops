import 'dart:math';
import 'package:flutter/material.dart';

// Custom painter for wave distortion effect
class WaveDistortionPainter extends CustomPainter {
  final double time;
  final double intensity;
  final double speed;

  WaveDistortionPainter({
    required this.time,
    required this.intensity,
    required this.speed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Create a blend mode that works well with the wave effect
    paint.blendMode = BlendMode.plus;

    // Number of wave lines to draw
    final int horizontalWaves = (5 + intensity * 0.1).round().clamp(4, 15);
    final int verticalWaves = (4 + intensity * 0.1).round().clamp(3, 12);

    // Line attributes
    final lineThickness = (1.0 + intensity * 0.05).clamp(0.5, 3.0);

    // Create a subtle wave pattern
    _drawWaveGrid(
      canvas,
      size,
      paint,
      horizontalWaves,
      verticalWaves,
      lineThickness,
    );

    // Add a circular ripple effect if intensity is high
    if (intensity > 10) {
      _drawRippleEffect(canvas, size, paint, lineThickness);
    }
  }

  void _drawWaveGrid(
    Canvas canvas,
    Size size,
    Paint paint,
    int horizontalWaves,
    int verticalWaves,
    double lineThickness,
  ) {
    // Draw horizontal wave lines
    for (int i = 0; i <= horizontalWaves; i++) {
      final y = size.height * i / horizontalWaves;
      final path = Path();

      path.moveTo(0, y);

      for (double x = 0; x <= size.width; x += 5) {
        final waveHeight =
            sin(x / size.width * 8 * pi + time * speed * 8) * intensity;
        path.lineTo(x, y + waveHeight);
      }

      paint.color = Colors.white.withOpacity(0.15);
      paint.strokeWidth = lineThickness;
      paint.style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }

    // Draw vertical wave lines
    for (int i = 0; i <= verticalWaves; i++) {
      final x = size.width * i / verticalWaves;
      final path = Path();

      path.moveTo(x, 0);

      for (double y = 0; y <= size.height; y += 5) {
        final waveWidth =
            cos(y / size.height * 6 * pi + time * speed * 6) * intensity;
        path.lineTo(x + waveWidth, y);
      }

      paint.color = Colors.white.withOpacity(0.15);
      paint.strokeWidth = lineThickness;
      paint.style = PaintingStyle.stroke;
      canvas.drawPath(path, paint);
    }
  }

  void _drawRippleEffect(
    Canvas canvas,
    Size size,
    Paint paint,
    double lineThickness,
  ) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw concentric ripple circles
    for (int i = 0; i < 8; i++) {
      final radius = (i * 30 + time * speed * 100) % (size.width * 0.8);
      final ripplePath = Path();

      ripplePath.addOval(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: radius * 2,
          height: radius * 2,
        ),
      );

      paint.color = Colors.white.withOpacity(0.1);
      paint.strokeWidth = lineThickness * 0.8;
      paint.style = PaintingStyle.stroke;
      canvas.drawPath(ripplePath, paint);
    }
  }

  @override
  bool shouldRepaint(WaveDistortionPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.intensity != intensity ||
        oldDelegate.speed != speed;
  }
}
