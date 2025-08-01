import 'package:flutter/material.dart';

class LabeledSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;
  final Color? activeColor;

  const LabeledSwitch({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.activeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = activeColor ?? theme.colorScheme.onSurface;

    return Row(
      children: [
        Text(label, style: TextStyle(color: textColor)),
        const Spacer(),
        Switch(value: value, activeColor: activeColor, onChanged: onChanged),
      ],
    );
  }
}
