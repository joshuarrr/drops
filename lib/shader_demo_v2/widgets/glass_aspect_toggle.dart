import 'package:flutter/material.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import '../models/shader_effect.dart';
import '../config/glass_effect_config.dart';
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
    final settings = glassSettings ?? GlassEffectConfig.buttonSettings;

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
