import 'package:flutter/material.dart';
import '../controllers/shader_controller.dart';

/// Color control panel for V3 demo
class ColorPanel extends StatelessWidget {
  final ShaderController controller;

  const ColorPanel({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorSettings = controller.settings.colorSettings;
    final colorEnabled = controller.settings.colorEnabled;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Color Effect',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Switch(
                  value: colorEnabled,
                  onChanged: (value) {
                    controller.toggleColorEffect(value);
                  },
                ),
              ],
            ),

            if (colorEnabled) ...[
              const SizedBox(height: 16),

              // Animation toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('HSL Animation'),
                  Switch(
                    value: colorSettings.colorAnimated,
                    onChanged: (value) {
                      controller.toggleColorAnimation(value);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Hue slider
              Row(
                children: [
                  const SizedBox(width: 16),
                  const Text('Hue'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Slider(
                      value: colorSettings.hue,
                      min: 0.0,
                      max: 1.0,
                      onChanged: (value) {
                        controller.updateColorHue(value);
                      },
                    ),
                  ),
                  Text(colorSettings.hue.toStringAsFixed(2)),
                  const SizedBox(width: 16),
                ],
              ),

              // Saturation slider
              Row(
                children: [
                  const SizedBox(width: 16),
                  const Text('Saturation'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Slider(
                      value: colorSettings.saturation,
                      min: -1.0,
                      max: 1.0,
                      onChanged: (value) {
                        controller.updateColorSaturation(value);
                      },
                    ),
                  ),
                  Text(colorSettings.saturation.toStringAsFixed(2)),
                  const SizedBox(width: 16),
                ],
              ),

              // Lightness slider
              Row(
                children: [
                  const SizedBox(width: 16),
                  const Text('Lightness'),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Slider(
                      value: colorSettings.lightness,
                      min: -1.0,
                      max: 1.0,
                      onChanged: (value) {
                        controller.updateColorLightness(value);
                      },
                    ),
                  ),
                  Text(colorSettings.lightness.toStringAsFixed(2)),
                  const SizedBox(width: 16),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
