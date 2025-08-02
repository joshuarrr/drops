import 'package:flutter/material.dart';

class LabeledSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String displayValue;
  final Function(double) onChanged;
  final Color activeColor;

  // Optional parameter to show a marker at a specific position
  // This is used to show the user-set position during animation
  final double? markerPosition;

  const LabeledSlider({
    Key? key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.displayValue,
    required this.onChanged,
    required this.activeColor,
    this.markerPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: TextStyle(color: activeColor)),
            const Spacer(),
            Text(displayValue, style: TextStyle(color: activeColor)),
          ],
        ),
        Stack(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: activeColor,
                inactiveTrackColor: activeColor.withOpacity(0.3),
                thumbColor: activeColor,
                // Make tick marks visible or invisible based on division settings
                tickMarkShape: divisions != null
                    ? SliderTickMarkShape.noTickMark
                    : null,
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions,
                activeColor: activeColor,
                onChanged: onChanged,
              ),
            ),

            // Show a marker at the user-set position during animation
            if (markerPosition != null && markerPosition != value)
              Positioned(
                left:
                    ((markerPosition! - min) / (max - min)) *
                    (MediaQuery.of(context).size.width - 32),
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 2,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.6),
                          blurRadius: 2,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
