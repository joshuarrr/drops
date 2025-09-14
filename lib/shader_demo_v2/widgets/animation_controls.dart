import 'package:flutter/material.dart';
import '../models/animation_options.dart';

class AnimationControls extends StatelessWidget {
  final double animationSpeed;
  final ValueChanged<double> onSpeedChanged;
  final AnimationMode animationMode;
  final ValueChanged<AnimationMode> onModeChanged;
  final AnimationEasing animationEasing;
  final ValueChanged<AnimationEasing> onEasingChanged;
  final Color sliderColor;

  const AnimationControls({
    super.key,
    required this.animationSpeed,
    required this.onSpeedChanged,
    required this.animationMode,
    required this.onModeChanged,
    required this.animationEasing,
    required this.onEasingChanged,
    required this.sliderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Speed', style: TextStyle(color: sliderColor, fontSize: 14)),
            const Spacer(),
            Text(
              _formatDuration(animationSpeed),
              style: TextStyle(color: sliderColor, fontSize: 12),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: sliderColor,
            inactiveTrackColor: sliderColor.withOpacity(0.3),
            thumbColor: sliderColor,
          ),
          child: Slider(
            value: animationSpeed,
            min: 0.0,
            max: 1.0,
            divisions: null,
            onChanged: onSpeedChanged,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Animation Type',
          style: TextStyle(color: sliderColor, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Column(
          children: AnimationMode.values.map((mode) {
            final String label = mode == AnimationMode.pulse
                ? 'Pulse'
                : 'Randomixed';
            return RadioListTile<AnimationMode>(
              value: mode,
              groupValue: animationMode,
              activeColor: sliderColor,
              contentPadding: EdgeInsets.zero,
              title: Text(label, style: TextStyle(color: sliderColor)),
              dense: true,
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (val) {
                if (val != null) onModeChanged(val);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Text('Easing', style: TextStyle(color: sliderColor, fontSize: 14)),
        const SizedBox(height: 8),
        Column(
          children: AnimationEasing.values.map((ease) {
            final String label;
            switch (ease) {
              case AnimationEasing.linear:
                label = 'Linear';
                break;
              case AnimationEasing.easeIn:
                label = 'Ease In';
                break;
              case AnimationEasing.easeOut:
                label = 'Ease Out';
                break;
              case AnimationEasing.easeInOut:
                label = 'Ease In Out';
                break;
            }
            return RadioListTile<AnimationEasing>(
              value: ease,
              groupValue: animationEasing,
              activeColor: sliderColor,
              contentPadding: EdgeInsets.zero,
              title: Text(label, style: TextStyle(color: sliderColor)),
              dense: true,
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (val) {
                if (val != null) onEasingChanged(val);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Format the animation speed (0-1) as a readable duration (60s to 500ms)
  String _formatDuration(double speed) {
    // Map speed (0-1) to duration (60000ms to 500ms)
    final durationMs = 60000 - (speed * 59500);

    if (durationMs >= 1000) {
      final seconds = (durationMs / 1000).toStringAsFixed(1);
      return '${seconds}s';
    } else {
      return '${durationMs.round()}ms';
    }
  }
}
