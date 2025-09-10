import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

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
    // Default glass settings optimized for panel backgrounds - matching button style
    final defaultSettings = LiquidGlassSettings(
      thickness:
          20.0, // Distortion strength: 0-30+ (higher = more background bending/refraction)
      glassColor: const Color.fromARGB(
        170,
        0,
        0,
        0,
      ), // Glass tint: ARGB format (alpha=opacity, RGB=color tint)
      lightIntensity:
          0.25, // Highlight brightness: 0-2+ (higher = brighter top/bottom highlights)
      blend:
          100, // Edge blending: 0-100 (lower = sharper edges, higher = smoother)
      ambientStrength:
          0.6, // Ambient light: 0-1 (higher = more overall lighting, lower = darker)
      saturation:
          1.15, // Color vibrancy: 0-2 (1=normal, >1=more vibrant, <1=desaturated)
      lightness:
          1, // Refraction brightness: 0-2 (higher = brighter refracted colors)
    );

    final settings = glassSettings ?? defaultSettings;

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
