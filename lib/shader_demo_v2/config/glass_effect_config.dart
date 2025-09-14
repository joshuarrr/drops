import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

/// Centralized configuration for glass effects across the shader demo v2
/// This ensures consistent glass appearance between control buttons and panels
class GlassEffectConfig {
  /// Default glass settings for all UI elements
  /// These settings create a consistent liquid glass effect
  static final LiquidGlassSettings defaultSettings = LiquidGlassSettings(
    thickness:
        20.0, // Distortion strength: 0-30+ (higher = more background bending/refraction)
    glassColor: const Color(
      0xAA000000,
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

  /// Glass settings for control buttons (same as default for consistency)
  static final LiquidGlassSettings buttonSettings = defaultSettings;

  /// Glass settings for control panels (same as default for consistency)
  static final LiquidGlassSettings panelSettings = defaultSettings;

  /// Glass settings for modal containers (same as default for consistency)
  static final LiquidGlassSettings modalSettings = defaultSettings;
}
