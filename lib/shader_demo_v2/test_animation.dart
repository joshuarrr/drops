import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;

/// A super simple animation test to isolate the issue
class AnimationTestScreen extends StatefulWidget {
  const AnimationTestScreen({super.key});

  @override
  State<AnimationTestScreen> createState() => _AnimationTestScreenState();
}

class _AnimationTestScreenState extends State<AnimationTestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Add listener for debugging
    _animationController.addListener(() {
      if (_animationController.value % 0.1 < 0.01) {
        print(
          "[TEST] Animation value: ${_animationController.value.toStringAsFixed(3)}",
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleAnimation() {
    setState(() {
      _isAnimating = !_isAnimating;

      if (_isAnimating) {
        print("[TEST] Starting animation");
        _animationController.repeat();
      } else {
        print("[TEST] Stopping animation");
        _animationController.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animation Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated container that changes color based on animation value
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                final hue = _animationController.value;
                final saturation = 1.0;
                final lightness = 0.5;

                // Convert HSL to RGB
                final color = HSLColor.fromAHSL(
                  1.0,
                  hue * 360,
                  saturation,
                  lightness,
                ).toColor();

                // Log the color values
                if (_animationController.value % 0.1 < 0.01) {
                  print("[TEST] Color: $color, hue: $hue");
                }

                return Container(
                  width: 200,
                  height: 200,
                  color: color,
                  child: Center(
                    child: Text(
                      'Animation Value:\n${_animationController.value.toStringAsFixed(3)}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Toggle button
            ElevatedButton(
              onPressed: _toggleAnimation,
              child: Text(_isAnimating ? 'Stop Animation' : 'Start Animation'),
            ),
          ],
        ),
      ),
    );
  }
}
