// import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

import '../models/effect_settings.dart';
// import '../models/shader_effect.dart';
import 'custom_shader_widgets.dart';
import 'shaders/edge_effect_shader.dart';
import 'shaders/glitch_shader.dart';

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
  // Memoization cache for effect widgets
  static final Map<String, Widget> _effectCache = {};

  // Cache statistics
  static int _cacheHits = 0;
  static int _cacheMisses = 0;
  static int _totalCacheRequests = 0;

  // Maximum cache size (default 50)
  static const int _MAX_CACHE_SIZE = 50;

  // Clear cache when it exceeds this threshold
  static const int _CACHE_CLEAR_THRESHOLD = 150;

  // Memory management mode
  static bool _highMemoryMode = false;

  // Method to explicitly clear the effect cache
  static void clearEffectCache() {
    final cacheSize = _effectCache.length;

    // Only clear if there's something to clear (avoid pointless operations)
    if (cacheSize > 0) {
      _effectCache.clear();
      _cacheHits = 0;
      _cacheMisses = 0;
      // Don't reset _totalCacheRequests to track across cache clears
    }
  }

  // Set high memory mode to be even more aggressive with caching
  static void setHighMemoryMode(bool enabled) {
    if (_highMemoryMode != enabled) {
      _highMemoryMode = enabled;
      debugPrint(
        'EffectController: High memory mode ${enabled ? 'enabled' : 'disabled'}',
      );

      // Clear cache immediately when entering high memory mode
      if (enabled) {
        clearEffectCache();

        // Force lower texture resolution
        _setLowTextureResolution();
      }
    }
  }

  // Force lower texture resolution to reduce memory usage
  static void _setLowTextureResolution() {
    try {
      // Set texture quality to lower resolution
      // final platformDispatcher = ui.PlatformDispatcher.instance; // Not used anymore
      // final window = platformDispatcher.views.first; // Not used anymore

      // Reduce device pixel ratio for textures and rendering to save memory
      // Note: This is a private API and may change in future Flutter versions
      // but it's effective for reducing memory pressure in emergency situations
      {
        // Request the system to reduce memory usage for graphics
        debugPrint('Requesting low memory graphics mode');
        SystemChannels.skia.invokeMethod<void>(
          'setResourceCacheMaxBytes',
          10 * 1024 * 1024,
        ); // 10MB limit
      }

      // Clear all caches
      imageCache.clear();
      imageCache.clearLiveImages();
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      debugPrint('Set low texture resolution to reduce memory usage');
    } catch (e) {
      debugPrint('Error setting low texture resolution: $e');
    }
  }

  // Get the current size of the effect cache
  static int getEffectCacheSize() {
    return _effectCache.length;
  }

  // Get cache performance stats
  static Map<String, dynamic> getCacheStats() {
    final hitRatio = _totalCacheRequests > 0
        ? (_cacheHits / _totalCacheRequests) * 100
        : 0;

    return {
      'size': _effectCache.length,
      'hits': _cacheHits,
      'misses': _cacheMisses,
      'total_requests': _totalCacheRequests,
      'hit_ratio': hitRatio,
      'efficiency': hitRatio > 50
          ? 'good'
          : hitRatio > 20
          ? 'fair'
          : 'poor',
    };
  }

  // Generate a unique cache key for a settings configuration
  static String _generateCacheKey(
    ShaderSettings settings,
    Map<String, double> animationValues,
    bool preserveTransparency,
    bool isTextContent,
  ) {
    // We're not using settings.selectedImage since it doesn't exist in ShaderSettings
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
      settings.edgeEnabled ? 'e1' : 'e0',
      settings.glitchEnabled ? 'g1' : 'g0',
      // Only include animation values if anything is animated
      if (settings.colorSettings.colorAnimated ||
          settings.blurSettings.blurAnimated ||
          settings.noiseSettings.noiseAnimated ||
          settings.rainSettings.rainAnimated ||
          settings.chromaticSettings.chromaticAnimated ||
          settings.rippleSettings.rippleAnimated ||
          settings.edgeSettings.edgeAnimated ||
          settings.glitchSettings.effectAnimated)
        animationValues.entries
            .map((e) => '${e.key}:${e.value.toStringAsFixed(2)}')
            .join('|'),
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
      // Hash of settings values for edge if enabled
      if (settings.edgeEnabled)
        '${settings.edgeSettings.opacity.toStringAsFixed(2)}_${settings.edgeSettings.edgeIntensity.toStringAsFixed(2)}_${settings.edgeSettings.edgeThickness.toStringAsFixed(2)}_${settings.edgeSettings.edgeColor.toStringAsFixed(2)}',
      // Hash of settings values for glitch if enabled
      if (settings.glitchEnabled)
        '${settings.glitchSettings.opacity.toStringAsFixed(2)}_${settings.glitchSettings.intensity.toStringAsFixed(2)}_${settings.glitchSettings.speed.toStringAsFixed(2)}_${settings.glitchSettings.blockSize.toStringAsFixed(2)}',
    ].join('|');
  }

  // Force disable caching for this session
  static void disableCaching() {
    _highMemoryMode = true;
    clearEffectCache();
    print('Effect caching disabled to fix image update issues');
  }

  // Apply all enabled effects to a widget
  static Widget applyEffects({
    required Widget child,
    required ShaderSettings settings,
    required Map<String, double> animationValues,
    bool preserveTransparency = false,
    bool isTextContent = false, // Add parameter to identify text content
  }) {
    // Debug animation value received by effect controller - disabled for performance
    // print(
    //   "[DEBUG] EffectController.applyEffects called with animationValue=${animationValue.toStringAsFixed(3)}, " +
    //       "blur=${settings.blurEnabled}, blurAnimated=${settings.blurSettings.blurAnimated}, " +
    //       "color=${settings.colorEnabled}, colorAnimated=${settings.colorSettings.colorAnimated}",
    // );

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
        !settings.rippleEnabled &&
        !settings.sketchEnabled &&
        !settings.edgeEnabled &&
        !settings.glitchEnabled) {
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
        (settings.rippleSettings.rippleAnimated && settings.rippleEnabled) ||
        (settings.sketchSettings.sketchAnimated && settings.sketchEnabled) ||
        (settings.edgeSettings.edgeAnimated && settings.edgeEnabled) ||
        (settings.glitchSettings.effectAnimated && settings.glitchEnabled);

    // If not animated, check cache for existing widget
    if (!isAnimated) {
      // In high memory mode, skip caching entirely for non-animated effects
      if (_highMemoryMode) {
        _totalCacheRequests++;
        return _buildEffectsWidget(
          child: child,
          settings: settings,
          animationValues: animationValues,
          preserveTransparency: preserveTransparency,
          isTextContent: isTextContent,
        );
      }

      final cacheKey = _generateCacheKey(
        settings,
        animationValues,
        preserveTransparency,
        isTextContent,
      );

      _totalCacheRequests++;

      if (_effectCache.containsKey(cacheKey)) {
        // Use cached widget to avoid rebuilding
        _cacheHits++;
        return _effectCache[cacheKey]!;
      }

      _cacheMisses++;

      // Build and cache widget
      Widget result = _buildEffectsWidget(
        child: child,
        settings: settings,
        animationValues: animationValues,
        preserveTransparency: preserveTransparency,
        isTextContent: isTextContent,
      );

      // Only cache if we have less than MAX_CACHE_SIZE items to avoid memory issues
      // AND we're not in high memory mode
      if (_effectCache.length < _MAX_CACHE_SIZE) {
        _effectCache[cacheKey] = result;
      } else {
        // Clear cache when it exceeds the threshold to prevent memory leaks
        if (_effectCache.length > _CACHE_CLEAR_THRESHOLD) {
          clearEffectCache();

          // In high memory mode, don't cache the new result
          if (!_highMemoryMode) {
            // Cache this result since we just cleared the cache
            _effectCache[cacheKey] = result;
          }
        }
      }

      return result;
    }

    // For animated effects, don't cache
    return _buildEffectsWidget(
      child: child,
      settings: settings,
      animationValues: animationValues,
      preserveTransparency: preserveTransparency,
      isTextContent: isTextContent,
    );
  }

  // Internal method to build the effects widget without caching logic
  static Widget _buildEffectsWidget({
    required Widget child,
    required ShaderSettings settings,
    required Map<String, double> animationValues,
    required bool preserveTransparency,
    required bool isTextContent,
  }) {
    // Start with the original child
    Widget result = child;

    // Use LayoutBuilder to ensure consistent sizing throughout the effect chain
    return LayoutBuilder(
      builder: (context, constraints) {
        // Don't force size - let the child widget maintain its natural size and layout
        // This preserves ImageContainer's margins and fit/fill behavior

        // Apply color effect first if enabled and targeted to the current content type
        if (settings.colorEnabled &&
            ((isTextContent && settings.colorSettings.applyToText) ||
                (!isTextContent && settings.colorSettings.applyToImage))) {
          result = _applyColorEffect(
            child: result,
            settings: settings,
            animationValue: settings.colorSettings.colorAnimated
                ? (animationValues['color'] ?? 0.0)
                : (animationValues['overlay'] ?? 0.0),
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
            animationValue: animationValues['noise'] ?? 0.0,
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
            animationValue: animationValues['rain'] ?? 0.0,
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
            animationValue: animationValues['ripple'] ?? 0.0,
            preserveTransparency: preserveTransparency,
            isTextContent: isTextContent,
          );
        }

        // Cymatics effect removed in V2 for simplification

        // Apply chromatic aberration effect if enabled and targeted to the current content type
        if (settings.chromaticEnabled &&
            ((isTextContent && settings.chromaticSettings.applyToText) ||
                (!isTextContent && settings.chromaticSettings.applyToImage))) {
          result = _applyChromaticEffect(
            child: result,
            settings: settings,
            animationValue: animationValues['chromatic'] ?? 0.0,
            preserveTransparency: preserveTransparency,
            isTextContent: isTextContent,
          );
        }

        // Apply sketch effect if enabled
        if (settings.sketchEnabled) {
          result = _applySketchEffect(
            child: result,
            settings: settings,
            animationValue: animationValues['sketch'] ?? 0.0,
            preserveTransparency: preserveTransparency,
            isTextContent: isTextContent,
          );
        }

        // Apply edge effect if enabled
        if (settings.edgeEnabled) {
          result = _applyEdgeEffect(
            child: result,
            settings: settings,
            animationValue: animationValues['edge'] ?? 0.0,
            preserveTransparency: preserveTransparency,
            isTextContent: isTextContent,
          );
        }

        // Apply glitch effect if enabled
        if (settings.glitchEnabled) {
          result = _applyGlitchEffect(
            child: result,
            settings: settings,
            animationValue: animationValues['glitch'] ?? 0.0,
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
            animationValue: animationValues['blur'] ?? 0.0,
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
    // FIX A: Allow static wave effects to be visible even without animation
    // Only skip if ALL meaningful settings are minimal (not just wave and color)
    if (settings.noiseSettings.waveAmount <= 0.0 &&
        settings.noiseSettings.colorIntensity <= 0.0 &&
        !settings.noiseSettings.noiseAnimated) {
      return child;
    }

    // CRITICAL FIX: Memory mode check disabled - was preventing wave effects
    // The simplified version doesn't support wave distortion, so we always use the full shader

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

  // Cymatics effect removed in V2 for simplification

  // Helper method to apply sketch effect using custom shader
  static Widget _applySketchEffect({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
    bool preserveTransparency = false,
    bool isTextContent = false,
  }) {
    // Skip if sketch is disabled or opacity is too low
    if (!settings.sketchSettings.shouldApplySketch) {
      return child;
    }

    // Use custom shader implementation
    return SketchEffectShader(
      settings: settings,
      animationValue: animationValue,
      child: child,
      preserveTransparency: preserveTransparency,
      isTextContent: isTextContent,
    );
  }

  // Helper method to apply edge effect using custom shader
  static Widget _applyEdgeEffect({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
    bool preserveTransparency = false,
    bool isTextContent = false,
  }) {
    // Skip if edge is disabled or opacity is too low
    if (!settings.edgeSettings.shouldApplyEdge) {
      return child;
    }

    // Use custom shader implementation
    return applyEdgeEffect(
      settings: settings,
      animationValue: animationValue,
      child: child,
      preserveTransparency: preserveTransparency,
      isTextContent: isTextContent,
    );
  }

  // Helper method to apply glitch effect using custom shader
  static Widget _applyGlitchEffect({
    required Widget child,
    required ShaderSettings settings,
    required double animationValue,
    bool preserveTransparency = false,
    bool isTextContent = false,
  }) {
    // Skip if glitch is disabled or opacity is too low
    if (!settings.glitchSettings.shouldApplyEffect) {
      return child;
    }

    // Use custom shader implementation
    return applyGlitchEffect(
      settings: settings,
      animationValue: animationValue,
      child: child,
      preserveTransparency: preserveTransparency,
      isTextContent: isTextContent,
    );
  }
}
