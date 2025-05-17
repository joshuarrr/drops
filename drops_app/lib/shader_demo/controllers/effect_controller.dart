import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:developer' as developer;

import '../models/effect_settings.dart';
import '../models/shader_effect.dart';
import 'custom_shader_widgets.dart';

/// Controls logging for effect application
bool enableEffectLogs = true;
const String _logTag = 'EffectController';

// Helper for logging consistently
void _log(String message) {
  if (!enableEffectLogs) return;
  developer.log(message, name: _logTag);
  debugPrint('[$_logTag] $message');
}

// Reduces verbosity by only logging color settings that aren't all zeros
bool _shouldLogColorSettings(ShaderSettings settings) {
  // Skip logging if everything is zero
  return !(settings.colorSettings.hue == 0.0 &&
      settings.colorSettings.saturation == 0.0 &&
      settings.colorSettings.lightness == 0.0 &&
      settings.colorSettings.overlayIntensity == 0.0 &&
      settings.colorSettings.overlayOpacity == 0.0);
}

class EffectController {
  // Apply all enabled effects to a widget
  static Widget applyEffects({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
    bool preserveTransparency = false,
  }) {
    // Log key settings at point of application, but only if there are meaningful values
    if (_shouldLogColorSettings(settings)) {
      _log(
        "applyEffects called with preserveTransparency=$preserveTransparency, color=${settings.colorEnabled}",
      );
      _log(
        "Color settings - hue: ${settings.colorSettings.hue.toStringAsFixed(2)}, sat: ${settings.colorSettings.saturation.toStringAsFixed(2)}, light: ${settings.colorSettings.lightness.toStringAsFixed(2)}, overlay: [${settings.colorSettings.overlayHue.toStringAsFixed(2)}, i=${settings.colorSettings.overlayIntensity.toStringAsFixed(2)}, o=${settings.colorSettings.overlayOpacity.toStringAsFixed(2)}]",
      );
    }

    // If no effects are enabled, return the original child
    if (!settings.colorEnabled &&
        !settings.blurEnabled &&
        !settings.noiseEnabled) {
      return child;
    }

    // Start with the original child
    Widget result = child;

    // Wrap in a SizedBox.expand to maintain full dimensions
    result = SizedBox.expand(child: result);

    // Apply color effect first if enabled
    if (settings.colorEnabled) {
      result = _applyColorEffect(
        child: result,
        settings: settings,
        animationValue: animationValue,
        preserveTransparency: preserveTransparency,
      );
    }

    // Apply noise effect if enabled
    if (settings.noiseEnabled) {
      result = _applyNoiseEffect(
        child: result,
        settings: settings,
        animationValue: animationValue,
        preserveTransparency: preserveTransparency,
      );
    }

    // Apply blur effect last if enabled
    if (settings.blurEnabled) {
      result = _applyBlurEffect(
        child: result,
        settings: settings,
        animationValue: animationValue,
        preserveTransparency: preserveTransparency,
      );
    }

    return result;
  }

  // Helper method to apply color effect to any widget using custom shader
  static Widget _applyColorEffect({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
    bool preserveTransparency = false,
  }) {
    // Skip if all color settings are zero *and* no animation requested
    bool allZero =
        settings.colorSettings.hue == 0.0 &&
        settings.colorSettings.saturation == 0.0 &&
        settings.colorSettings.lightness == 0.0 &&
        settings.colorSettings.overlayOpacity == 0.0;

    if (allZero &&
        !settings.colorSettings.colorAnimated &&
        !settings.colorSettings.overlayAnimated) {
      return child;
    }

    // CRITICAL: Clone the settings so we don't modify the original if preserveTransparency is used
    if (preserveTransparency) {
      // Log only if there's actual overlay data that would be changed
      if (settings.colorSettings.overlayIntensity > 0 ||
          settings.colorSettings.overlayOpacity > 0) {
        _log(
          "Creating cloned settings for text overlay - zeroing overlay (original values: intensity=${settings.colorSettings.overlayIntensity.toStringAsFixed(2)}, opacity=${settings.colorSettings.overlayOpacity.toStringAsFixed(2)})",
        );
      }

      var clonedSettings = ShaderSettings.fromMap(settings.toMap());

      // When applying to text, we want color adjustments but no solid background overlay
      clonedSettings.colorSettings.overlayIntensity = 0.0;
      clonedSettings.colorSettings.overlayOpacity = 0.0;

      // Use custom shader implementation with cloned settings
      return ColorEffectShader(
        settings: clonedSettings,
        animationValue: animationValue,
        child: child,
        preserveTransparency: preserveTransparency,
      );
    } else {
      // Use custom shader implementation with original settings
      return ColorEffectShader(
        settings: settings,
        animationValue: animationValue,
        child: child,
        preserveTransparency: preserveTransparency,
      );
    }
  }

  // Helper method to apply blur effect using custom shader
  static Widget _applyBlurEffect({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
    bool preserveTransparency = false,
  }) {
    // Skip if blur amount is zero
    if (settings.blurSettings.blurAmount <= 0.0 &&
        !settings.blurSettings.blurAnimated) {
      return child;
    }

    // Use custom shader implementation
    return BlurEffectShader(
      settings: settings,
      animationValue: animationValue,
      child: child,
      preserveTransparency: preserveTransparency,
    );
  }

  // Helper method to apply noise effect using custom shader
  static Widget _applyNoiseEffect({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
    bool preserveTransparency = false,
  }) {
    // Skip if noise settings are minimal and no animation
    if (settings.noiseSettings.waveAmount <= 0.0 &&
        settings.noiseSettings.colorIntensity <= 0.0 &&
        !settings.noiseSettings.noiseAnimated) {
      return child;
    }

    // Use custom shader implementation
    return NoiseEffectShader(
      settings: settings,
      animationValue: animationValue,
      child: child,
      preserveTransparency: preserveTransparency,
    );
  }
}
