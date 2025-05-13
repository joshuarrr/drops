import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../models/effect_settings.dart';
import '../models/shader_effect.dart';
import 'custom_shader_widgets.dart';

class EffectController {
  // Apply all enabled effects to a widget
  static Widget applyEffects({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
  }) {
    // If no effects are enabled, return the original child
    if (!settings.colorEnabled && !settings.blurEnabled) {
      return child;
    }

    // Start with the original child
    Widget result = child;

    // Apply color effect first if enabled
    if (settings.colorEnabled) {
      result = _applyColorEffect(
        child: result,
        settings: settings,
        animationValue: animationValue,
      );
    }

    // Apply blur effect last if enabled
    if (settings.blurEnabled) {
      result = _applyBlurEffect(child: result, settings: settings);
    }

    return result;
  }

  // Helper method to apply color effect to any widget using custom shader
  static Widget _applyColorEffect({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
  }) {
    // Skip if all color settings are zero
    if (settings.hue == 0.0 &&
        settings.saturation == 0.0 &&
        settings.lightness == 0.0 &&
        settings.overlayOpacity == 0.0) {
      return child;
    }

    // Use custom shader implementation
    return ColorEffectShader(
      child: child,
      settings: settings,
      animationValue: animationValue,
    );
  }

  // Helper method to apply blur effect using custom shader
  static Widget _applyBlurEffect({
    required Widget child,
    required ShaderSettings settings,
  }) {
    // Skip if blur amount is zero
    if (settings.blurAmount <= 0.0) {
      return child;
    }

    // Use custom shader implementation
    return BlurEffectShader(child: child, settings: settings);
  }
}
