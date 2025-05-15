import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../models/effect_settings.dart';
import '../models/shader_effect.dart';
import 'custom_shader_widgets.dart';

/// Controls logging for effect application
bool enableEffectLogs = false;

class EffectController {
  // Apply all enabled effects to a widget
  static Widget applyEffects({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
  }) {
    // If no effects are enabled, return the original child
    if (!settings.colorEnabled && !settings.blurEnabled) {
      if (enableEffectLogs) print("EFFECTS: No effects enabled");
      return child;
    }

    // Start with the original child
    Widget result = child;

    // Wrap in a SizedBox.expand to maintain full dimensions
    result = SizedBox.expand(child: result);

    // Apply color effect first if enabled
    if (settings.colorEnabled) {
      if (enableEffectLogs) print("EFFECTS: Applying color");
      result = _applyColorEffect(
        child: result,
        settings: settings,
        animationValue: animationValue,
      );
    }

    // Apply blur effect last if enabled
    if (settings.blurEnabled) {
      if (enableEffectLogs) print("EFFECTS: Applying blur/shatter");
      result = _applyBlurEffect(
        child: result,
        settings: settings,
        animationValue: animationValue,
      );
    }

    return result;
  }

  // Helper method to apply color effect to any widget using custom shader
  static Widget _applyColorEffect({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
  }) {
    // Skip if all color settings are zero *and* no animation requested
    bool allZero =
        settings.hue == 0.0 &&
        settings.saturation == 0.0 &&
        settings.lightness == 0.0 &&
        settings.overlayOpacity == 0.0;

    if (allZero && !settings.colorAnimated && !settings.overlayAnimated) {
      if (enableEffectLogs) print("EFFECTS: Color settings zero, skipping");
      return child;
    }

    // Use custom shader implementation
    return ColorEffectShader(
      settings: settings,
      animationValue: animationValue,
      child: child,
    );
  }

  // Helper method to apply blur effect using custom shader
  static Widget _applyBlurEffect({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
  }) {
    // Skip if blur amount is zero
    if (settings.blurAmount <= 0.0 && !settings.blurAnimated) {
      if (enableEffectLogs) print("EFFECTS: Blur amount zero, skipping");
      return child;
    }

    // Use custom shader implementation
    return BlurEffectShader(
      settings: settings,
      animationValue: animationValue,
      child: child,
    );
  }
}
