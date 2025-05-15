import 'package:flutter/material.dart';

/// A labelled slider with a numeric % read-out and a small reset button.
///
/// Originally implemented inline in `effect_controls.dart` as `buildSlider`,
/// this widget makes the control reusable and keeps `effect_controls.dart`
/// shorter.
class ValueSlider extends StatelessWidget {
  const ValueSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.sliderColor,
    this.defaultValue = 0.0,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final Color sliderColor;
  final double defaultValue;

  @override
  Widget build(BuildContext context) {
    final bool valueChanged = value != defaultValue;
    final bool isCurrentImageDark = sliderColor == Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isCurrentImageDark ? Colors.white : Colors.black,
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: sliderColor,
                  inactiveTrackColor: sliderColor.withOpacity(0.3),
                  thumbColor: sliderColor,
                  overlayColor: sliderColor.withOpacity(0.1),
                ),
                child: Slider(value: value, onChanged: onChanged),
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  color: isCurrentImageDark ? Colors.white : Colors.black,
                ),
              ),
            ),
            InkWell(
              onTap: valueChanged ? () => onChanged(defaultValue) : null,
              child: Container(
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: valueChanged
                      ? sliderColor.withOpacity(0.1)
                      : sliderColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.refresh,
                  color: valueChanged
                      ? sliderColor
                      : sliderColor.withOpacity(0.3),
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
