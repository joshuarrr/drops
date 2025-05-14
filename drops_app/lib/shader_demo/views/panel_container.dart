import 'package:flutter/material.dart';

/// A reusable container for shader control panels that applies the common
/// translucent background and rounded corners used throughout the demo.
///
/// By centralising this decoration we ensure all panels look consistent and we
/// can tweak the style (e.g. remove/add a border) from one place.
class PanelContainer extends StatelessWidget {
  const PanelContainer({
    super.key,
    required this.isDark,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
  });

  /// Whether the content behind the panel is considered dark. This controls
  /// whether we use a dark or light translucent colour.
  final bool isDark;

  /// The widget placed inside the panel.
  final Widget child;

  /// Padding applied inside the container. Defaults to 16 on all sides.
  final EdgeInsets padding;

  /// Optional margin around the container.
  final EdgeInsets? margin;

  /// Corner radius. Defaults to 16.
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        // Use a semi-opaque white background in light mode and a
        // semi-opaque black background in dark mode so controls are
        // clearly visible against the image.
        color: isDark
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
