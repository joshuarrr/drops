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
    final Color textColor = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
                shadows: [
                  Shadow(
                    color: theme.shadowColor.withOpacity(0.3),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showAnimToggle) ...[
            SizedBox(width: 8),
            Text(
              'Animate',
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                shadows: [
                  Shadow(
                    color: theme.shadowColor.withOpacity(0.3),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8),
            Switch(value: animationEnabled, onChanged: onAnimationToggled),
          ],
        ],
      ),
    );
  }
}
