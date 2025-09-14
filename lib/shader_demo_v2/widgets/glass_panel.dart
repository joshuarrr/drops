import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../config/glass_effect_config.dart';

/// A reusable glass panel wrapper that applies liquid glass effect to control panels
/// This creates a frosted glass background container for panel content
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.glassSettings,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.symmetric(vertical: 8.0),
  });

  final Widget child;
  final LiquidGlassSettings? glassSettings;
  final EdgeInsets padding;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final settings = glassSettings ?? GlassEffectConfig.panelSettings;

    return Container(
      margin: margin,
      child: LiquidGlass(
        settings: settings,
        shape: const LiquidRoundedSuperellipse(
          borderRadius: Radius.circular(16),
        ),
        glassContainsChild: false, // Child renders on top of glass effect
        child: Container(padding: padding, child: child),
      ),
    );
  }
}
