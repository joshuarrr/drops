import 'package:flutter/material.dart';
import '../models/shader_effect.dart';

/// A reusable toggle button for enabling, disabling and selecting a [ShaderAspect].
///
/// Long-press toggles the aspect on/off, tap selects it so the corresponding
/// sliders become visible.  The visual style is identical to the original
/// private `_buildAspectToggle` implementation but packaged as its own widget
/// for reuse and to shrink `effect_controls.dart`.
class AspectToggle extends StatelessWidget {
  const AspectToggle({
    super.key,
    required this.aspect,
    required this.isEnabled,
    required this.isCurrentImageDark,
    required this.onToggled,
    required this.onTap,
  });

  final ShaderAspect aspect;
  final bool isEnabled;
  final bool isCurrentImageDark;
  final void Function(ShaderAspect, bool) onToggled;
  final void Function(ShaderAspect) onTap;

  @override
  Widget build(BuildContext context) {
    final Color textColor = isCurrentImageDark ? Colors.white : Colors.black;
    // No background - let the glass effect handle visibility
    final Color backgroundColor = Colors.transparent;

    return Tooltip(
      message: isEnabled
          ? 'Long press to disable ${aspect.label}'
          : 'Long press to enable ${aspect.label}',
      preferBelow: true,
      showDuration: const Duration(seconds: 1),
      verticalOffset: 20,
      textStyle: TextStyle(
        color: isCurrentImageDark ? Colors.black : Colors.white,
        fontSize: 11,
      ),
      decoration: BoxDecoration(
        color: isCurrentImageDark
            ? Colors.white.withOpacity(0.9)
            : Colors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(4),
      ),
      child: GestureDetector(
        onTap: () => onTap(aspect),
        onLongPress: () => onToggled(aspect, !isEnabled),
        child: SizedBox(
          width: 70,
          height: 78,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(aspect.icon, color: textColor, size: 20),
                const SizedBox(height: 6),
                Text(
                  aspect.label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11,
                    fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 1),
                Container(
                  height: 6,
                  width: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isEnabled
                        ? Colors.green
                        : textColor.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
