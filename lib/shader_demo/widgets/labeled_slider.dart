import 'package:flutter/material.dart';

class LabeledSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String displayValue;
  final Function(double) onChanged;
  final Color activeColor;

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
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: activeColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
