import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:developer' as developer;

import '../models/effect_settings.dart';
import '../models/shader_effect.dart';
import 'custom_shader_widgets.dart';

/// Controls logging for effect application
enum LogLevel { debug, info, warning, error }

class EffectLogger {
  // Set to info to show all info logs including slider changes
  static LogLevel currentLevel = LogLevel.info;
  static bool enableEffectLogs = true;
  static const String _logTag = 'EffectController';

  // Caches for tracking previous values to avoid repeating logs
  static Map<String, String> _lastLoggedValues = {};
  static Map<String, DateTime> _lastLoggedTimes = {};
  static const _throttleMs = 500; // Throttle identical logs by 500ms

  // Helper for logging consistently
  static void log(String message, {LogLevel level = LogLevel.info}) {
    if (!enableEffectLogs || level.index < currentLevel.index) return;

    // Format message with level prefix
    final prefix = level == LogLevel.debug
        ? "[DEBUG]"
        : level == LogLevel.warning
        ? "[WARN]"
        : level == LogLevel.error
        ? "[ERROR]"
        : "";

    final formattedMessage = prefix.isEmpty ? message : "$prefix $message";

    developer.log(formattedMessage, name: _logTag);

    // Only print to console for higher level logs
    if (level.index >= LogLevel.info.index) {
      debugPrint('[$_logTag] $formattedMessage');
    }
  }

  // Log only if message is different from the last time this key was logged
  // and not logged too frequently
  static void logOnce(
    String key,
    String message, {
    LogLevel level = LogLevel.info,
  }) {
    if (!enableEffectLogs || level.index < currentLevel.index) return;

    // Add a hash of the message to prevent repeating identical content with different keys
    final String messageHash = message.hashCode.toString();
    final String cacheKey = "$key-$messageHash";
    final now = DateTime.now();

    // Skip if the same message was logged recently
    if (_lastLoggedValues[cacheKey] == message) {
      final lastTime = _lastLoggedTimes[cacheKey];
      if (lastTime != null &&
          now.difference(lastTime).inMilliseconds < _throttleMs) {
        return; // Skip this log due to throttling
      }
    }

    log(message, level: level);
    _lastLoggedValues[cacheKey] = message;
    _lastLoggedTimes[cacheKey] = now;

    // Keep cache from growing indefinitely
    if (_lastLoggedValues.length > 100) {
      // Remove oldest entries when cache gets too large
      final oldestKeys = _lastLoggedValues.keys.take(20).toList();
      for (final oldKey in oldestKeys) {
        _lastLoggedValues.remove(oldKey);
        _lastLoggedTimes.remove(oldKey);
      }
    }
  }
}

// Helper to format color settings consistently for logging
String _formatColorSettings(ShaderSettings settings) {
  return "hue: ${settings.colorSettings.hue.toStringAsFixed(2)}, " +
      "sat: ${settings.colorSettings.saturation.toStringAsFixed(2)}, " +
      "light: ${settings.colorSettings.lightness.toStringAsFixed(2)}, " +
      "overlay: [${settings.colorSettings.overlayHue.toStringAsFixed(2)}, " +
      "i=${settings.colorSettings.overlayIntensity.toStringAsFixed(2)}, " +
      "o=${settings.colorSettings.overlayOpacity.toStringAsFixed(2)}]";
}

// Reduces verbosity by only logging color settings that aren't all zeros
bool _shouldLogColorSettings(ShaderSettings settings) {
  // Skip logging if everything is minimal/zero
  const double threshold =
      0.01; // Small threshold to avoid floating point issues

  // Only log if we have significant color effect settings
  // For hue, only consider it significant if saturation or lightness is also non-zero
  bool hasColorEffect =
      (settings.colorSettings.saturation.abs() > threshold ||
      settings.colorSettings.lightness.abs() > threshold);

  // For overlay, only log when both intensity and opacity are non-zero
  bool hasOverlayEffect =
      (settings.colorSettings.overlayIntensity > threshold &&
      settings.colorSettings.overlayOpacity > threshold);

  return hasColorEffect || hasOverlayEffect;
}

class EffectController {
  // Cache for memoizing effect results
  static final Map<String, Widget> _effectCache = {};

  // Generate a unique cache key for a settings configuration
  static String _generateCacheKey(
    ShaderSettings settings,
    double animationValue,
    bool preserveTransparency,
    bool isTextContent,
  ) {
    // Create a compact representation of critical settings
    return [
      isTextContent ? 'text' : 'bg',
      preserveTransparency ? 'trans' : 'opaque',
      settings.colorEnabled ? 'c1' : 'c0',
      settings.blurEnabled ? 'b1' : 'b0',
      settings.noiseEnabled ? 'n1' : 'n0',
      settings.rainEnabled ? 'r1' : 'r0',
      settings.chromaticEnabled ? 'ch1' : 'ch0',
      settings.rippleEnabled ? 'rp1' : 'rp0',
      // Only include animation value if anything is animated
      if (settings.colorSettings.colorAnimated ||
          settings.blurSettings.blurAnimated ||
          settings.noiseSettings.noiseAnimated ||
          settings.rainSettings.rainAnimated ||
          settings.chromaticSettings.chromaticAnimated ||
          settings.rippleSettings.rippleAnimated)
        animationValue.toStringAsFixed(2),
      // Hash of settings values for color if enabled
      if (settings.colorEnabled)
        '${settings.colorSettings.hue.toStringAsFixed(2)}_${settings.colorSettings.saturation.toStringAsFixed(2)}_${settings.colorSettings.lightness.toStringAsFixed(2)}_${settings.colorSettings.overlayIntensity.toStringAsFixed(2)}_${settings.colorSettings.overlayOpacity.toStringAsFixed(2)}',
      // Hash of settings values for blur if enabled
      if (settings.blurEnabled)
        '${settings.blurSettings.blurAmount.toStringAsFixed(2)}_${settings.blurSettings.blurRadius.toStringAsFixed(2)}_${settings.blurSettings.blurOpacity.toStringAsFixed(2)}',
      // Hash of settings values for noise if enabled
      if (settings.noiseEnabled)
        '${settings.noiseSettings.waveAmount.toStringAsFixed(2)}_${settings.noiseSettings.colorIntensity.toStringAsFixed(2)}',
      // Hash of settings values for rain if enabled
      if (settings.rainEnabled)
        '${settings.rainSettings.rainIntensity.toStringAsFixed(2)}_${settings.rainSettings.dropSize.toStringAsFixed(2)}_${settings.rainSettings.fallSpeed.toStringAsFixed(2)}_${settings.rainSettings.refraction.toStringAsFixed(2)}_${settings.rainSettings.trailIntensity.toStringAsFixed(2)}',
      // Hash of settings values for chromatic aberration if enabled
      if (settings.chromaticEnabled)
        '${settings.chromaticSettings.amount.toStringAsFixed(2)}_${settings.chromaticSettings.angle.toStringAsFixed(2)}_${settings.chromaticSettings.spread.toStringAsFixed(2)}_${settings.chromaticSettings.intensity.toStringAsFixed(2)}',
      // Hash of settings values for ripple if enabled
      if (settings.rippleEnabled)
        '${settings.rippleSettings.rippleIntensity.toStringAsFixed(2)}_${settings.rippleSettings.rippleSize.toStringAsFixed(2)}_${settings.rippleSettings.rippleSpeed.toStringAsFixed(2)}_${settings.rippleSettings.rippleOpacity.toStringAsFixed(2)}_${settings.rippleSettings.rippleColor.toStringAsFixed(2)}',
    ].join('|');
  }

  // Apply all enabled effects to a widget
  static Widget applyEffects({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
    bool preserveTransparency = false,
    bool isTextContent = false, // Add parameter to identify text content
  }) {
    // Generate log message first before deciding whether to show it
    String logMessage = "";

    if (_shouldLogColorSettings(settings)) {
      logMessage =
          "applyEffects: mode=${isTextContent ? 'text' : 'background'}, preserveTransparency=$preserveTransparency, " +
          "color=${settings.colorEnabled}, " +
          _formatColorSettings(settings);

      // Only log if the message is different from previous logs with same parameters
      if (logMessage.isNotEmpty) {
        String cacheKey =
            "${isTextContent ? 'text' : 'bg'}-$preserveTransparency";
        EffectLogger.logOnce(cacheKey, logMessage, level: LogLevel.debug);
      }
    }

    // If no effects are enabled, return the original child
    if (!settings.colorEnabled &&
        !settings.blurEnabled &&
        !settings.noiseEnabled &&
        !settings.rainEnabled &&
        !settings.chromaticEnabled &&
        !settings.rippleEnabled) {
      return child;
    }

    // For animated effects, we need to recompute every frame.
    // For static effects, we can memoize results.
    bool isAnimated =
        (settings.colorSettings.colorAnimated && settings.colorEnabled) ||
        (settings.blurSettings.blurAnimated && settings.blurEnabled) ||
        (settings.noiseSettings.noiseAnimated && settings.noiseEnabled) ||
        (settings.rainSettings.rainAnimated && settings.rainEnabled) ||
        (settings.chromaticSettings.chromaticAnimated &&
            settings.chromaticEnabled) ||
        (settings.rippleSettings.rippleAnimated && settings.rippleEnabled);

    // If not animated, check cache for existing widget
    if (!isAnimated) {
      final cacheKey = _generateCacheKey(
        settings,
        animationValue,
        preserveTransparency,
        isTextContent,
      );

      if (_effectCache.containsKey(cacheKey)) {
        // Use cached widget to avoid rebuilding
        return _effectCache[cacheKey]!;
      }

      // Build and cache widget
      Widget result = _buildEffectsWidget(
        child: child,
        settings: settings,
        animationValue: animationValue,
        preserveTransparency: preserveTransparency,
        isTextContent: isTextContent,
      );

      // Only cache if we have less than 30 items to avoid memory issues
      if (_effectCache.length < 30) {
        _effectCache[cacheKey] = result;
      } else {
        // Clear cache occasionally to prevent memory leaks
        if (_effectCache.length > 50) {
          _effectCache.clear();
        }
      }

      return result;
    }

    // For animated effects, don't cache
    return _buildEffectsWidget(
      child: child,
      settings: settings,
      animationValue: animationValue,
      preserveTransparency: preserveTransparency,
      isTextContent: isTextContent,
    );
  }

  // Internal method to build the effects widget without caching logic
  static Widget _buildEffectsWidget({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
    required bool preserveTransparency,
    required bool isTextContent,
  }) {
    // Start with the original child
    Widget result = child;

    // Use LayoutBuilder to ensure consistent sizing throughout the effect chain
    return LayoutBuilder(
      builder: (context, constraints) {
        // Wrap in a SizedBox with explicit dimensions to maintain size throughout effects chain
        result = SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: result,
        );

        // Apply color effect first if enabled and targeted to the current content type
        if (settings.colorEnabled &&
            ((isTextContent && settings.colorSettings.applyToText) ||
                (!isTextContent && settings.colorSettings.applyToImage))) {
          result = _applyColorEffect(
            child: result,
            settings: settings,
            animationValue: animationValue,
            preserveTransparency: preserveTransparency,
            isTextContent: isTextContent,
          );
        }

        // Apply noise effect if enabled and targeted to the current content type
        if (settings.noiseEnabled &&
            ((isTextContent && settings.noiseSettings.applyToText) ||
                (!isTextContent && settings.noiseSettings.applyToImage))) {
          result = _applyNoiseEffect(
            child: result,
            settings: settings,
            animationValue: animationValue,
            preserveTransparency: preserveTransparency,
            isTextContent: isTextContent,
          );
        }

        // Apply rain effect if enabled and targeted to the current content type
        if (settings.rainEnabled &&
            ((isTextContent && settings.rainSettings.applyToText) ||
                (!isTextContent && settings.rainSettings.applyToImage))) {
          result = _applyRainEffect(
            child: result,
            settings: settings,
            animationValue: animationValue,
            preserveTransparency: preserveTransparency,
            isTextContent: isTextContent,
          );
        }

        // Apply ripple effect if enabled and targeted to the current content type
        if (settings.rippleEnabled &&
            ((isTextContent && settings.rippleSettings.applyToText) ||
                (!isTextContent && settings.rippleSettings.applyToImage))) {
          result = _applyRippleEffect(
            child: result,
            settings: settings,
            animationValue: animationValue,
            preserveTransparency: preserveTransparency,
            isTextContent: isTextContent,
          );
        }

        // Apply cymatics effect if enabled and targeted to the current content type
        if (settings.cymaticsEnabled &&
            ((isTextContent && settings.cymaticsSettings.applyToText) ||
                (!isTextContent && settings.cymaticsSettings.applyToImage))) {
          result = _applyCymaticsEffect(
            child: result,
            settings: settings,
            animationValue: animationValue,
            preserveTransparency: preserveTransparency,
            isTextContent: isTextContent,
          );
        }

        // Apply chromatic aberration effect if targeted to the current content type
        // Without checking chromaticEnabled flag
        if ((isTextContent && settings.chromaticSettings.applyToText) ||
            (!isTextContent && settings.chromaticSettings.applyToImage)) {
          result = _applyChromaticEffect(
            child: result,
            settings: settings,
            animationValue: animationValue,
            preserveTransparency: preserveTransparency,
            isTextContent: isTextContent,
          );
        }

        // Apply blur effect last if enabled and targeted to the current content type
        if (settings.blurEnabled &&
            ((isTextContent && settings.blurSettings.applyToText) ||
                (!isTextContent && settings.blurSettings.applyToImage))) {
          result = _applyBlurEffect(
            child: result,
            settings: settings,
            animationValue: animationValue,
            preserveTransparency: preserveTransparency,
            isTextContent: isTextContent,
          );
        }

        return result;
      },
    );
  }

  // Helper method to apply color effect to any widget using custom shader
  static Widget _applyColorEffect({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
    bool preserveTransparency = false,
    bool isTextContent = false,
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

    // CRITICAL: Clone the settings so we don't modify the original for text content or when preserveTransparency is used
    if (preserveTransparency || isTextContent) {
      // Only log if we'd be changing meaningful values
      if (settings.colorSettings.overlayIntensity > 0 ||
          settings.colorSettings.overlayOpacity > 0) {
        String logMessage =
            "Creating cloned settings for ${isTextContent ? 'text' : 'transparent'} content - " +
            "zeroing overlay (original values: intensity=${settings.colorSettings.overlayIntensity.toStringAsFixed(2)}, " +
            "opacity=${settings.colorSettings.overlayOpacity.toStringAsFixed(2)})";

        String cacheKey =
            "clone-${isTextContent ? 'text' : 'transp'}-${settings.colorSettings.overlayIntensity.toStringAsFixed(2)}-${settings.colorSettings.overlayOpacity.toStringAsFixed(2)}";
        EffectLogger.logOnce(cacheKey, logMessage, level: LogLevel.debug);
      }

      var clonedSettings = ShaderSettings.fromMap(settings.toMap());

      // When applying to text or when transparency preservation is needed,
      // we want color adjustments but no solid background overlay
      clonedSettings.colorSettings.overlayIntensity = 0.0;
      clonedSettings.colorSettings.overlayOpacity = 0.0;

      // Use custom shader implementation with cloned settings
      return ColorEffectShader(
        settings: clonedSettings,
        animationValue: animationValue,
        child: child,
        preserveTransparency:
            true, // Always preserve transparency for text/transparent content
        isTextContent: isTextContent, // Pass isTextContent flag to shader
      );
    } else {
      // Use custom shader implementation with original settings
      return ColorEffectShader(
        settings: settings,
        animationValue: animationValue,
        child: child,
        preserveTransparency: preserveTransparency,
        isTextContent: isTextContent, // Pass isTextContent flag to shader
      );
    }
  }

  // Helper method to apply blur effect using custom shader
  static Widget _applyBlurEffect({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
    bool preserveTransparency = false,
    bool isTextContent = false,
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
      isTextContent: isTextContent,
    );
  }

  // Helper method to apply noise effect using custom shader
  static Widget _applyNoiseEffect({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
    bool preserveTransparency = false,
    bool isTextContent = false,
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
      isTextContent: isTextContent,
    );
  }

  // Helper method to apply rain effect using custom shader
  static Widget _applyRainEffect({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
    bool preserveTransparency = false,
    bool isTextContent = false,
  }) {
    // Skip if rain settings are minimal and no animation
    if (settings.rainSettings.rainIntensity <= 0.0 &&
        settings.rainSettings.dropSize <= 0.0 &&
        settings.rainSettings.fallSpeed <= 0.0 &&
        settings.rainSettings.refraction <= 0.0 &&
        settings.rainSettings.trailIntensity <= 0.0 &&
        !settings.rainSettings.rainAnimated) {
      return child;
    }

    // Use custom shader implementation
    return RainEffectShader(
      settings: settings,
      animationValue: animationValue,
      child: child,
      preserveTransparency: preserveTransparency,
      isTextContent: isTextContent,
    );
  }

  // Helper method to apply ripple effect using custom shader
  static Widget _applyRippleEffect({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
    bool preserveTransparency = false,
    bool isTextContent = false,
  }) {
    // Skip if ripple settings are minimal and no animation
    if (settings.rippleSettings.rippleIntensity <= 0.0 &&
        settings.rippleSettings.rippleSize <= 0.0 &&
        settings.rippleSettings.rippleSpeed <= 0.0 &&
        settings.rippleSettings.rippleOpacity <= 0.0 &&
        !settings.rippleSettings.rippleAnimated) {
      return child;
    }

    // Use custom shader implementation - directly without additional wrapping
    return RippleEffectShader(
      settings: settings,
      animationValue: animationValue,
      child: child,
      preserveTransparency: preserveTransparency,
      isTextContent: isTextContent,
    );
  }

  // Helper method to apply chromatic aberration effect using custom shader
  static Widget _applyChromaticEffect({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
    bool preserveTransparency = false,
    bool isTextContent = false,
  }) {
    // Skip only if ALL settings values are zero/minimal
    // No longer check settings.chromaticEnabled
    if (settings.chromaticSettings.amount <= 0.0 &&
        settings.chromaticSettings.spread <= 0.0 &&
        settings.chromaticSettings.intensity <= 0.0 &&
        !settings.chromaticSettings.chromaticAnimated) {
      return child;
    }

    // Use shader directly without additional wrapping
    return ChromaticEffectShader(
      settings: settings,
      animationValue: animationValue,
      child: child,
      preserveTransparency: preserveTransparency,
      isTextContent: isTextContent,
    );
  }

  // Helper method to apply cymatics effect using custom shader
  static Widget _applyCymaticsEffect({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
    bool preserveTransparency = false,
    bool isTextContent = false,
  }) {
    // Skip if cymatics settings are minimal and no animation
    if (settings.cymaticsSettings.intensity <= 0.0 &&
        settings.cymaticsSettings.frequency <= 0.0 &&
        settings.cymaticsSettings.amplitude <= 0.0 &&
        settings.cymaticsSettings.complexity <= 0.0 &&
        settings.cymaticsSettings.speed <= 0.0 &&
        !settings.cymaticsSettings.cymaticsAnimated) {
      return child;
    }

    // Ensure valid settings - for the background-based approach, we need higher
    // intensity values to show the effect clearly
    var modifiedSettings = ShaderSettings.fromMap(settings.toMap());

    // Ensure minimum values for key parameters to make the effect visible
    if (modifiedSettings.cymaticsSettings.intensity < 0.1) {
      modifiedSettings.cymaticsSettings.intensity = 0.1;
    }
    if (modifiedSettings.cymaticsSettings.amplitude < 0.1) {
      modifiedSettings.cymaticsSettings.amplitude = 0.1;
    }

    // Determine background color based on app theme or settings
    Color backgroundColor = const Color(0xFF1A237E); // Default deep blue

    // If color effect is enabled, use its overlay color as base
    if (settings.colorEnabled && settings.colorSettings.overlayOpacity > 0.3) {
      // Create color from overlay hue
      final hue = settings.colorSettings.overlayHue;
      backgroundColor = HSLColor.fromAHSL(
        1.0,
        hue * 360,
        0.7, // Higher saturation for more vibrant background
        0.3, // Darker for better pattern visibility
      ).toColor();
    }

    // Use custom shader implementation
    return CymaticsEffectShader(
      settings: modifiedSettings,
      animationValue: animationValue,
      child: child,
      preserveTransparency: preserveTransparency,
      isTextContent: isTextContent,
      backgroundColor: backgroundColor,
    );
  }
}
