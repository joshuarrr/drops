import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../models/shader_effect.dart';
import 'aspect_toggle.dart';

/// A glass-effect wrapper around AspectToggle that creates a liquid glass effect
/// for the control panel buttons. This provides a beautiful frosted glass appearance
/// that refracts the background content.
class GlassAspectToggle extends StatelessWidget {
  const GlassAspectToggle({
    super.key,
    required this.aspect,
    required this.isEnabled,
    required this.isCurrentImageDark,
    required this.onToggled,
    required this.onTap,
    this.glassSettings,
  });

  final ShaderAspect aspect;
  final bool isEnabled;
  final bool isCurrentImageDark;
  final void Function(ShaderAspect, bool) onToggled;
  final void Function(ShaderAspect) onTap;
  final LiquidGlassSettings? glassSettings;

  @override
  Widget build(BuildContext context) {
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

    return LiquidGlass(
      settings: settings,
      shape: const LiquidRoundedSuperellipse(borderRadius: Radius.circular(10)),
      glassContainsChild: false, // Child renders on top of glass effect
      child: AspectToggle(
        aspect: aspect,
        isEnabled: isEnabled,
        isCurrentImageDark: isCurrentImageDark,
        onToggled: onToggled,
        onTap: onTap,
      ),
    );
  }
}
