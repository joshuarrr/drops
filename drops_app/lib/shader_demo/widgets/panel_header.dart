import 'package:flutter/material.dart';

class PanelHeader extends StatelessWidget {
  final String title;
  final bool showAnimToggle;
  final bool animationEnabled;
  final Function(bool) onAnimationToggled;

  const PanelHeader({
    Key? key,
    required this.title,
    this.showAnimToggle = false,
    this.animationEnabled = false,
    required this.onAnimationToggled,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color textColor = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const Spacer(),
          if (showAnimToggle) ...[
            Text('Animate', style: TextStyle(fontSize: 14, color: textColor)),
            const SizedBox(width: 8),
            Switch(value: animationEnabled, onChanged: onAnimationToggled),
          ],
        ],
      ),
    );
  }
}
